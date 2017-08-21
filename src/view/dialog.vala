namespace View {

    public delegate void DialogResponse(Gtk.Dialog source, int response_id);
    public delegate void MessageDialogResponse(int response_id);

    public class Dialog : Gtk.Dialog {
        
        construct {
            this.border_width = 0;
        }
        
        public Dialog(int width, int height, string title, Gtk.Window parent, bool is_modal = true, int use_header_bar = 1) {
            
            #if GTK_GTE_3_18
            Object(use_header_bar: use_header_bar);
            #endif
            
            this.set_default_size(width, height);
            this.title  = title;
            this.set_transient_for(parent);
            this.set_modal(is_modal);
        }

        public void add_body(Gtk.Box widget) {
            Gtk.Box box = this.get_content_area() as Gtk.Box;
            box.spacing = 10;
            box.pack_start(widget, false, true, 0);
        }

        public void on_response(DialogResponse response) {
            this.response.connect((source, response_id) => response(source, response_id));
        }
    }

    public class MessageDialog : Gtk.Bin {

        private Gtk.MessageDialog dialog;

        public MessageDialog(Gtk.Window? parent, Gtk.DialogFlags flags, Gtk.MessageType type, Gtk.ButtonsType buttons, string message) {
            dialog = new Gtk.MessageDialog(parent, flags, type, buttons, message);
        }

        public void on_response(MessageDialogResponse response) {
            dialog.response.connect((response_id) => response);
        }
    }
}
