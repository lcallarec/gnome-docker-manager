namespace Sdk.Docker.Model {

    /**
     * Container model
     */
    public class Container : BaseModel, Validatable {

        /** attribute for name properties */
        private string[] _names;

        public string command {get; set;}

        public Container.from(string id, int64 created_at, string command, string image_id, string[] names, ContainerStatus status) {
            this.full_id    = id;
            this.created_at = new DateTime.from_unix_local(created_at);
            this.command    = command;
            this.image_id   = image_id;
            this.names      = names;
            this.status     = status;
        }

        /**
         * Container names property
         */
        public string[] names {
            get {
                return _names;
            }

            set {
                _names = value;
                name   = value[0].replace("/", "");
            }
        }

        public string image_id {get; set;}

        /**
         * Container name property
         */
        public string name {get; set;}

        public ContainerStatus status {get; set;}


        public string get_status_string() {
            return ContainerStatusConverter.convert_from_enum(status);
        }

        /** @inherit */
        public ValidationFailures? validate() {

            ValidationFailures failures = new ValidationFailures();

            if (false == Regex.match_simple("^[a-zA-Z0-9][a-zA-Z0-9_.-]+$", name)) {
                failures.add("name", "Container name must match [a-zA-Z0-9][a-zA-Z0-9_.-]");
            }

            if (failures.size > 0) {
                return failures;
            }

            return null;
        }
    }

    public enum ContainerStatus {
        CREATED,
        RESTARTING,
        RUNNING,
        PAUSED,
        EXITED;

        public static ContainerStatus[] all() {
            return {RUNNING, PAUSED, EXITED, CREATED, RESTARTING};
        }

        public static ContainerStatus[] active() {
            return {RUNNING, PAUSED};
        }

        public static bool is_active(ContainerStatus status) {
            return status in ContainerStatus.active();
        }
    }

   /**
    * Convert container status from a type / to another type
    */
    public class ContainerStatusConverter {

        /**
         * Convert a container status from enum to string (according to remote docker api)
         */
        public static string convert_from_enum(ContainerStatus status) {
            string s_status;
            switch(status) {
                case ContainerStatus.RUNNING:
                    s_status = "running";
                    break;
                case ContainerStatus.PAUSED:
                    s_status = "paused";
                    break;
                case ContainerStatus.EXITED:
                    s_status = "exited";
                    break;
                case ContainerStatus.CREATED:
                    s_status = "created";
                    break;
                case ContainerStatus.RESTARTING:
                    s_status = "restarting";
                    break;
                default:
                    assert_not_reached();
            }

            return s_status;
        }

        /**
         * Convert a container status from string to enum (according to remote docker api)
         */
        public static ContainerStatus convert_to_enum(string s_status) {
            ContainerStatus status;
            switch(s_status) {
                case "running":
                    status = ContainerStatus.RUNNING;
                    break;
                case "pause":
                    status = ContainerStatus.PAUSED;
                    break;
                case "exited" :
                    status = ContainerStatus.EXITED;
                    break;
                case "created":
                    status = ContainerStatus.CREATED;
                    break;
                case "restarting":
                    status = ContainerStatus.RESTARTING;
                    break;
                default:
                    assert_not_reached();
            }

            return status;
        }
    }
}
