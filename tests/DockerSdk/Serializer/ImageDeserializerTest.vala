using global::Dockery.DockerSdk.Serializer;

private void register_image_deserializer_test() {
    Test.add_func ("/Dockery/DockerSdk/Serializer/ImageDeserializer/GetImagesFromWellFormattedPayload", () => {

        string payload = """
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

        var deserializer = new ImageDeserializer();
        var images = deserializer.deserializeList(payload);

        var firstImage = images.get(0);

        if (firstImage == null) assert_not_reached();

        assert(firstImage.full_id == "8dbd9e392a964056420e5d58ca5cc376ef18e2de93b5cc90e868a1bbc8318c1c");
        assert(firstImage.name == "ubuntu:12.04");
        assert(firstImage.created_at.equal(new DateTime.utc(2013, 4, 11, 21, 13, 15)));
        assert(firstImage.repository == "ubuntu");
        assert(firstImage.tag == "12.04");
        assert(firstImage.raw_size == (uint) 131506275);
        assert(firstImage.size == "132MB");
        stdout.printf(firstImage.size);
    });
}