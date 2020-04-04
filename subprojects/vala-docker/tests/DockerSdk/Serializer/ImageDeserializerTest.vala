using global::Dockery.DockerSdk;

private void register_image_deserializer_test() {
    Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/DeserializeList#OneImageWellFormattedPayload", () => {

        var deserializer = new Serializer.ImageDeserializer();
        try {
          var images = deserializer.deserialize(one_complete_json_image());
  
          var firstImage = images.get("8dbd9e392a96");
  
          assert(firstImage.full_id == "8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c");
          assert(firstImage.id == "8dbd9e392a96");
          assert(firstImage.name == "ubuntu:12.04");
          assert(firstImage.created_at.equal(new DateTime.utc(2013, 4, 11, 21, 13, 15)));
          assert(firstImage.repository == "ubuntu");
          assert(firstImage.tag == "12.04");
          assert(firstImage.size.to_human().to_string() == "131.51MB");
          assert(firstImage.size.bytes == (uint) 131506275);
        } catch (Error e) {
          assert_not_reached();
        }
    });

     Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/deserialize#ManyImagesWellFormattedPayload", () => {

        var deserializer = new Serializer.ImageDeserializer();
        try {
          var images = deserializer.deserialize(many_complete_json_image());

          assert(images.size == 2);
          assert(images.get("8dbd9e392a96").name == "ubuntu:12.04");
          assert(images.get("bafe274aa7c0").name == "ubuntu:14.04");
        } catch (Error e) {
          assert_not_reached();
        }
    });

    Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/deserialize#BadFormattedPayload", () => {

        var deserializer = new Serializer.ImageDeserializer();

        try {
          deserializer.deserialize(image_malformatted_json());
          assert_not_reached();
        } catch(Error e) {
          assert(e is DeserializationError.IMAGE);
        }
    });

    //  Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/deserialize#NoErrorsWhenEmptyRepoTags", () => {
    //      var deserializer = new Serializer.ImageDeserializer();
    //      try {
    //        deserializer.deserialize(one_complete_json_image_with_empty_repotags());
    //      } catch (Error e) {
    //        assert_not_reached();
    //      }
    //  });


    //  Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/deserialize#NoErrorsWhenNullRepoTags", () => {
    //      var deserializer = new Serializer.ImageDeserializer();

    //      try {
    //       deserializer.deserialize(one_complete_json_image_with_null_repotags());
    //      } catch (Error e) {
    //        assert_not_reached();
    //      }
    //  });   
}

internal string one_complete_json_image() {
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

internal string one_complete_json_image_with_empty_repotags() {
  return """
        [{
          "RepoTags": [],
          "Id": "8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c",
          "Created": 1365714795,
          "Size": 131506275,
          "VirtualSize": 131506275,
          "Labels": {}
        }]
        """;
}

internal string one_complete_json_image_with_null_repotags() {
  return """
        [{
          "RepoTags": null,
          "Id": "8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c",
          "Created": 1365714795,
          "Size": 131506275,
          "VirtualSize": 131506275,
          "Labels": {}
        }]
        """;
}

internal string many_complete_json_image() {
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

internal string image_malformatted_json() {
  return "[{]";
}