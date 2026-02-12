class CacheWrapper<T> {
  final T data;
  final int cachedDate;

  CacheWrapper(this.data, this.cachedDate);

  CacheWrapper.fromJson(Map<String, dynamic> json)
      : cachedDate = json['cachedDate'],
        data = json['data'];

  Map toJsonObject() => {'cachedDate': cachedDate, 'data': data};

  @override
  String toString() => "CacheWrapper{cachedDate=$cachedDate, data=$data}";
}
