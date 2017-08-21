namespace Sdk.Docker.Model {

    /**
     * ContainerCreate is a domain used used when a container creation is requested
     */
    public class ContainerCreate : BaseModel, Serializable {

        public Image image {get; construct set;}

        public string[] command {get; set;}

        public ContainerCreate.from_image(Image image) {
            this.image = image;
        }

        public ContainerCreate.from_hash_map(Image image, Gee.HashMap<string, string> hash_map) {
            this.image = image;
            if (hash_map.has_key("Command")) command = hash_map.get("Command").split(" ");
        }

        public string serialize() {

            Json.Builder builder = new Json.Builder();
            Json.Generator generator = new Json.Generator();

            builder.begin_object();

            builder.set_member_name("Image");
            builder.add_string_value(this.image.id);

            if (command.length > 0) {
                builder.set_member_name("Command");
                builder.begin_array();
                foreach (string cmd_part in command) {
                    builder.add_string_value(cmd_part);
                }
                builder.end_array();
            }

            builder.end_object();

            Json.Node root = builder.get_root();
            generator.set_root(root);

            return generator.to_data(null);
        }
    }
}
