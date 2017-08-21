namespace Sdk.Docker.Model {

    public class ImageCollection : Collection<Image> {
        
        public ImageCollection.from_model(BaseModel item) {
            this.add(item);
        }
    }
}
