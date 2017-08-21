namespace Sdk.Docker.Model {

    /**
     * BaseModel model
     */
    public class BaseModel : GLib.Object {
        private string _id;
        private string _full_id;

        public string id {
            get { return _id; }
            private set { _id = value.substring(0, 12); }
        }

        public string full_id {
            get { return _full_id; }
            set { _full_id = value; id = value; }
        }

        public DateTime created_at {get; set;}
    }
}
