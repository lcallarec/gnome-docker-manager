namespace Sdk.Docker.Model {

    /**
     * Image model
     */
    public class Image : BaseModel {

        private uint _raw_size;
        private string _size;

        public string repository {get; private set;}
        public string tag {get; private set;}
        public string name {get; private set;}

        public Image.from(string id, int64 created_at, string repotags, uint size) {

            string[] _repotags = repotags.split(":", 2);

            this.full_id    = id;
            this.name       = repotags;
            this.created_at = new DateTime.from_unix_local(created_at);
            this.repository = _repotags[0];
            this.tag        = _repotags[1];
            this.raw_size   = size;
        }

        public uint raw_size {
            get { return _raw_size; }
            set { _raw_size = value; size = value.to_string();}
        }

        public string size {
            get { return _size; }
            set { _size = SizeFormatter.string_bytes_to_human(value); }
        }

    }
}
