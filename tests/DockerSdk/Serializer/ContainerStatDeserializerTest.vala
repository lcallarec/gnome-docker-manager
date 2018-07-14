using global::Dockery.DockerSdk;

private void register_container_stat_deserializer_test() {
    Test.add_func ("/Dockery/DockerSdk/Serializer/ContainerStatDeserializer/Deserialize", () => {

      //Given
      var deserializer = new Serializer.ContainerStatDeserializer();
      
      //When
      var stat = deserializer.deserialize(one_stat());

      //Then
      assert(stat.read_at.compare(new DateTime.from_iso8601("2015-01-08T22:57:31.547920715Z", new TimeZone.utc())) == 0);
      assert(stat.memory_stats.max_usage == 6651904);
      assert(stat.memory_stats.usage == 6537216);
      assert(stat.memory_stats.limit == 67108864);
    });
}

internal string one_stat() {
  return """
          {
            "read": "2015-01-08T22:57:31.547920715Z",
            "memory_stats": {
              "max_usage": 6651904,
              "usage": 6537216,
              "limit": 67108864
            }
          }""";
}