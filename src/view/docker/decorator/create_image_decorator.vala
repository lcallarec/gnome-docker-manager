/** @author Laurent Calalrec <l.callarec@gmail.com> **/
namespace View.Docker.Decorator {
    
    public class CreateImageDecorator {
        
        private Json.Parser parser = new Json.Parser();
        private Gtk.Label label;
        
        public CreateImageDecorator(Gtk.Label label) {
            this.label = label;
        }
        
        public void update(string? line) {
            
            string text;
            try {
                
                if (null != line) {
                    text = parse_json(line);
                } else {
                    text = "Image created.";
                }
                
                label.set_label(text);
            
            } catch (Error e) {
                stderr.printf ("I guess something is not working... with %s\n", line);
            }
            
            parser = null;
            
            return;
        }
        
        private string build_body(string status, string id, int64 current, int64 total) {
            string body = "";
            if (status != "") {
                body += "Status: %s\n".printf(status);
            }

            if (id != "") {
                body += "ID: %s\n".printf(id);
            }

            if (current > 0) {
                body += "Downloading... %d of %d".printf((int) current, (int) total);
            }

            return body;
        }
        
        private string parse_json(string line) {
            stdout.printf("==============parsing : %s\n", line);
            Json.Parser parser = new Json.Parser();
            
            parser.load_from_data(line);
            
            var node = parser.get_root();

            int64 current = 0;
            int64 total   = 0;
            string id     = "";
            string status = "";
            
            if (node.get_object().has_member("id")) {
                id = node.get_object().get_string_member("id");
            }
            
            if (node.get_object().has_member("status")) {
                status = node.get_object().get_string_member("status");
            }
            
            if (node.get_object().has_member("progressDetail")) {
                var progress_details = node.get_object().get_object_member("progressDetail");
                if (progress_details.has_member("current") && progress_details.has_member("total")) {
                    current = progress_details.get_int_member("current");
                    total   = progress_details.get_int_member("total");    
                }
            }
            
            return build_body(status, id, current, total);
        }
    }
}
