namespace View.Docker.Dialog {

    using global::Sdk.Docker.Model;

    /**
     * This Dialog is displayed when one or more images are being removed.
     */
    public class RemoveImagesDialog : View.Dialog {

        private Gtk.ListStore liststore = new Gtk.ListStore(2, typeof (string),  typeof (string));
        private Gtk.TreeView tv         = null;
        private RemoveImagesDialogMessageGenerator message_generator;
        
        /**
         * images : images we want to remove
         * containers : containers created from images we want to remove
         */ 
        public RemoveImagesDialog(ImageCollection images, ContainerCollection containers, Gtk.Window parent) {

            base(600, 250, "", parent);
            
            message_generator = new RemoveImagesDialogMessageGenerator(containers, images);    
            
            this.title = message_generator.get_title();
            
            this.add_button("No, abort", Gtk.ResponseType.CLOSE);

            Gtk.Widget yes_button = this.add_button("Yes, proceed", Gtk.ResponseType.APPLY);
            yes_button.get_style_context().add_class("destructive-action");

            var view = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

            var infobar = new Gtk.InfoBar();
            infobar.show_close_button = false;
            
            infobar.response.connect((id) => {
                infobar.hide();
            });

            view.pack_start(infobar, false, false, 0);

            infobar.get_content_area().add(new Gtk.Label(message_generator.get_important_message()));
            infobar.set_message_type(Gtk.MessageType.WARNING);
            infobar.show();

            var body = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            view.pack_start(body, false, false, 0);

            var symbol_box = View.Docker.IconMessageBoxBuilder.create_icon_box("media-optical-symbolic");
            if (containers.size == 0) {
                body.pack_start(symbol_box, true, false, 0);
            } else {
                body.pack_start(symbol_box, false, false, 0);
                populate_liststore_from_containers(containers);
                tv = create_treeview();
                body.pack_start(tv, true, true, 0);
            }

            this.add_body(view);
        }

        private void populate_liststore_from_containers(Sdk.Docker.Model.ContainerCollection linked_containers) {

            Gtk.TreeIter iter;
            foreach(Sdk.Docker.Model.ContainerStatus status in Sdk.Docker.Model.ContainerStatus.all()) {
                foreach(Sdk.Docker.Model.Container container in linked_containers.get_by_status(status)) {
                    liststore.append (out iter);
                    liststore.set(iter, 0, container.name, 1, container.get_status_string());
                }
            }
        }

        private Gtk.TreeView create_treeview() {

            tv = new Gtk.TreeView();
            tv.set_model(liststore);

            tv.vexpand = true;
            tv.hexpand = true;

            tv.insert_column_with_attributes(-1, "Id", new Gtk.CellRendererText(), "text", 0);
            tv.insert_column_with_attributes(-1, "Status", new Gtk.CellRendererText(), "text", 1);

            return tv;
        }
    }
}
