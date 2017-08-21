namespace View.Docker.Dialog {

    using global::Sdk.Docker.Model;
    
    public class RemoveImagesDialogMessageGenerator : Object {
        
        private Collection containers;
        private Collection images;
        
        /**
         * images : images we want to remove
         * containers : containers created from images we want to remove
         */
        public RemoveImagesDialogMessageGenerator(Collection containers, Collection images) {
            this.containers = containers;
            this.images      = images;
        }
        
        public string get_title() {
            if (images.size > 1) {
                return "Do you really want to remove the selected images ?";
            } else {
                return "Do you really want to remove the selected image ?";
            }
        }

        public string? get_important_message() {
            
            string important_message;
            
            if (containers.size == 0 && images.size == 1) {
                return "The selected image isn't being used by any container. It can be removed safely.";
            } else if (containers.size == 0 && images.size > 1) {
                return "The selected images aren't being used by any container. They can be removed safely.";
            } else if (containers.size == 1 && images.size == 1) {
                return "The selected image is being used by one container, listed below.\nRemoving this image will also remove the following container :";
            } else if (containers.size > 1 && images.size == 1) {
                return "The selected image is being used by %d containers, listed below.\nRemoving this image will also remove the following containers :".printf(containers.size);
            } else if (containers.size > 1 && images.size > 1) {
                return "The selected images are being used by %d containers, listed below.\nRemoving these images will also remove all the following containers :".printf(containers.size);
            }

            return null;
        }
        
        public string get_warning() {
            return "Caution : This operation can't be reverted.";
        }
    }

}
