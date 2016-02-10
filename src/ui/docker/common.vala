namespace Ui.Docker {
    
    using global::Docker.Model;
    
    public interface ContainerActionable : GLib.Object {
        public signal void container_status_change_request(ContainerStatus status, Container container);
        public signal void container_remove_request(Container container);
        public signal void container_start_request(Container container);
        public signal void container_stop_request(Container container);
        public signal void container_rename_request(Container container, Gtk.Label? label = null);
        public signal void container_kill_request(Container container);
    }

    public interface Flushable : Gtk.Container {
        /**
         * Remove all child widgets from the container
         */
        public virtual void flush() {
            this.@foreach((widget) => {
                this.remove(widget);
            });
        }
    }

    public interface ImageViewable : Gtk.Widget {

        /**
         * Init the images view from a given (nullable) list of images
         */
        public abstract int init(Image[]? images, bool show_after_refresh = true);
    }

    /**
     * 
     */ 
    public interface ContainerViewable : Gtk.Widget {

        /**
         * Init the container view from a given (nullable) list of containers and return it
         */
        public abstract Ui.Docker.List.BaseContainers init(Containers? containers, bool show_after_refresh = true);
    }
    
    public interface IconMessageBoxBuilder {
        
        public static Gtk.Box create_icon_message_box(string message, string icon_name) {
            
            var image = new Gtk.Image.from_icon_name(icon_name, Gtk.IconSize.DIALOG);
            
            image.pixel_size = 164;
            image.opacity = 0.2;
            
            var label = new Gtk.Label(message);
            label.attributes = Fonts.get_panel_empty_major();
            
            var box = new Gtk.VBox(false, 0);

            box.valign = Gtk.Align.CENTER;
            box.pack_start(image, true, false, 0);
            box.pack_start(label, false, false, 0);
            
            return box;
        }
        
    }
}
