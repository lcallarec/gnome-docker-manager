using global::Dockery.DockerSdk;

private void register_image_deserializer_test() {
    Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/GetImageFromWellFormattedPayload", () => {

        var deserializer = new Serializer.ImageDeserializer();
        var images = deserializer.deserializeList(one_complete_json_image());

        var firstImage = images.get(0);

        assert(firstImage.full_id == "8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c");
        assert(firstImage.id == "8dbd9e392a96");
        assert(firstImage.name == "ubuntu:12.04");
        assert(firstImage.created_at.equal(new DateTime.utc(2013, 4, 11, 21, 13, 15)));
        assert(firstImage.repository == "ubuntu");
        assert(firstImage.tag == "12.04");
        assert(firstImage.raw_size == (uint) 131506275);
        assert(firstImage.size == "132MB");
    });

     Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/GetImagesFromWellFormattedPayload", () => {

        var deserializer = new Serializer.ImageDeserializer();
        var images = deserializer.deserializeList(many_complete_json_image());

        assert(images.size == 2);
        assert(images.get(0).id == "8dbd9e392a96");
        assert(images.get(0).name == "ubuntu:12.04");
        assert(images.get(1).id == "bafe274aa7c0");
        assert(images.get(1).name == "ubuntu:14.04");
    });

    Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/GetImagesFromBadFormattedPayload", () => {

        var deserializer = new Serializer.ImageDeserializer();

        try {
          var images = deserializer.deserializeList(malformatted_json());
          assert_not_reached();
        } catch(Error e) {
          assert(e is Serializer.DeserializationError.IMAGES);
        }
    });
}

private string one_complete_json_image() {
  return """
        [{
          "RepoTags": [
            "ubuntu:12.04",
            "ubuntu:precise",
            "ubuntu:latest"
          ],
          "Id": "8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c",
          "Created": 1365714795,
          "Size": 131506275,
          "VirtualSize": 131506275,
          "Labels": {}
        }]
        """;
}

private string many_complete_json_image() {
  return """
        [{
          "RepoTags": [
            "ubuntu:12.04",
            "ubuntu:precise",
            "ubuntu:latest"
          ],
          "Id": "8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c",
          "Created": 1365714795,
          "Size": 131506275,
          "VirtualSize": 131506275,
          "Labels": {}
        },{
          "RepoTags": [
            "ubuntu:14.04",
            "ubuntu:trusty"
          ],
          "Id": "bafe274aa7c05b403e1b71ad8167c0283bff6fe95055be8157de218b7206daa9",
          "Created": 1565714795,
          "Size": 131506275,
          "VirtualSize": 131506275,
          "Labels": {}
        }]
        """;
}

private string malformatted_json() {
  return "[{]";
}