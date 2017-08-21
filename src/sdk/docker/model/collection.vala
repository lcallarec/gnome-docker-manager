namespace Sdk.Docker.Model {
    
    using global::Sdk.Docker.Model;
    
    public class Collection<T> : Gee.ArrayList<T> {

        private Gee.HashMap<string, T> id_idx = new  Gee.HashMap<string, T>();

        public new void add(BaseModel item) {
            id_idx.set(item.id, item);
            base.add(item);
        }

        public T get_by_id(string id) {
            return id_idx.get(id);
        }

        public bool has_id(string id) {
            return id_idx.has_key(id);
        }
        
        /**
         * Get an array of id 
         */ 
        public string[] get_ids() {
            string[] ids = new string[0];
            foreach (string id in id_idx.keys) {
                ids += id;
            }
            
            return ids;
        }
        
        public T? first() {
            if (iterator().has_next()) {
                return iterator().next();
            }
            
            return null;
        }

    }
}
