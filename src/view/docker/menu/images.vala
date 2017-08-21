namespace View.Docker.Menu {

    using global::Sdk.Docker.Model;

    public class ImageMenuFactory {
        public static ImageMenu create_single(Image image) {
            return new SingleSelectedImageMenu(image);
        }
        
        public static ImageMenu create_multi(ImageCollection images) {
            return new MultiSelectedImageMenu(images);
        }
    }

    public class ImageMenu : Signals.ImageRequestAction, Menu {
        
    }
    
    public class SingleSelectedImageMenu : ImageMenu {
        
        protected Image image;

        public SingleSelectedImageMenu(Image image) {

            this.image = image;

            this.append_create_container_menu_item();
            this.append_create_container_with_menu_item();
            this.append_separator_menu_item();
            this.append_remove_menu_item();
        }

        /**
         * Remove image menu
         */
        protected void append_remove_menu_item() {
            this.append_menu_item("_Remove image", null, () => {
                this.images_remove_request(new ImageCollection.from_model(image));
            });
        }

        /**
         * Simple create container from image menu
         */
        protected void append_create_container_menu_item() {
            this.append_menu_item("_Create container", null, () => {
                this.image_create_container_request(image);
            });
        }

        /**
         * Create (with...) container from image menu
         */
        protected void append_create_container_with_menu_item() {
            this.append_menu_item("_Create container with...", null, () => {
                this.image_create_container_with_request(image);
            });
        }
    }
    
    public class MultiSelectedImageMenu : ImageMenu {
        
        protected ImageCollection images;
        
        public MultiSelectedImageMenu(ImageCollection images) {
            this.images = images;
            this.append_remove_menu_items();
        }
        
         /**
         * Remove images menu
         */
        protected void append_remove_menu_items() {
            this.append_menu_item("_Remove selected images", null, () => {
                this.images_remove_request(images);
            });
        }
    }
}
