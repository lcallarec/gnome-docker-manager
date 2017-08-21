namespace View.Docker.Dialog {

    using global::Sdk.Docker.Model;

    /**
     * This Dialog is displayed when an image is being removed.
     */
    public class SearchHubDialog : View.Dialog, Signals.DockerHubImageRequestAction {

        private Gtk.ListStore liststore = new Gtk.ListStore(5, typeof (string),  typeof (string), typeof (string), typeof (string), typeof (string));
        private Gtk.TreeView treeview   = null;
        private Gtk.Box message_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        public Gtk.Label message_box_label = new Gtk.Label(null);
        
        public SearchHubDialog(Gtk.Window parent) {

            base(600, 500, "Search image in Docker hub", parent, false, 0);

            var body = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

            var scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.add(get_treeview());

            var search_entry = new Gtk.Entry();
            this.on_search(search_entry);
            search_entry.width_chars = 30;
            search_entry.set_icon_from_icon_name(Gtk.EntryIconPosition.SECONDARY, "edit-find-symbolic");

            message_box_label.set_alignment(0,0);
            message_box_label.wrap = true;
            message_box_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
            
            message_box.pack_start(message_box_label, true, true, 0);            

            body.pack_start(search_entry, false, false, 5);
            body.pack_start(scrolled_window, false, true, 5);
            body.pack_end(message_box, false, true, 5);

            this.add_body(body);

            this.on_row_click_register();
        }

        /** Set images collecyion to the view */
        public void set_images(Sdk.Docker.Model.HubImage[] images) {

            Gtk.TreeIter iter;
            liststore.clear();
            foreach(Sdk.Docker.Model.HubImage image in images) {
                liststore.append (out iter);
                liststore.set(iter, 0, image.name, 1, image.description, 2, image.is_official.to_string(), 3, image.is_automated.to_string(), 4, image.star_count.to_string());
            }
        }

        /** Search signals */
        private void on_search(Gtk.Entry entry) {

            entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    this.search_image_in_docker_hub(this, entry.text);
                }
            });

            entry.activate.connect (() => {
                this.search_image_in_docker_hub(this, entry.text);
            });
        }

        /** Treeview singleton factory */
        private Gtk.TreeView get_treeview() {
            if (null == treeview) {

                treeview = new Gtk.TreeView();
                treeview.set_model(liststore);

                treeview.vexpand = true;
                treeview.hexpand = true;

                treeview.insert_column_with_attributes(-1, "Name", new Gtk.CellRendererText(), "text", 0);
                treeview.insert_column_with_attributes(-1, "Description", new Gtk.CellRendererText(), "text", 1);
                treeview.insert_column_with_attributes(-1, "Official ?", new Gtk.CellRendererText(), "text", 2);
                treeview.insert_column_with_attributes(-1, "Automated ?", new Gtk.CellRendererText(), "text", 3);
                treeview.insert_column_with_attributes(-1, "Stars", new Gtk.CellRendererText(), "text", 4);

                return treeview;
            }

            return treeview;
        }

        private void on_row_click_register() {

            treeview.button_press_event.connect((e) => {

                if (e.button == 3) {
                    Gtk.TreePath tp;
                    treeview.get_path_at_pos((int) e.x, (int) e.y, out tp, null, null, null);

                    var selection = treeview.get_selection();
                    selection.set_mode(Gtk.SelectionMode.SINGLE);
                    selection.select_path(tp);

                    Gtk.TreeModel m;
                    Gtk.TreeIter i;
                    selection.get_selected(out m, out i);

                    Value oname;
                    m.get_value(i, 0, out oname);

                    string name = oname as string;

                    HubImage image = new HubImage.from(name, true, true, name, 0);

                    var menu = View.Docker.Menu.SearchHubMenuFactory.create(image);

                    menu.show_all();
                    menu.popup(null, this, null, e.button, e.time);

                    menu.pull_image_from_docker_hub.connect((target, image) => {
                        this.pull_image_from_docker_hub(this, image);
                    });

                    return true;
                }

                return false;
            });


        }
    }
}
