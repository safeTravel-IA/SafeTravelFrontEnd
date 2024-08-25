class Destination {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });
factory Destination.fromJson(Map<String, dynamic> json) {
  return Destination(
    id: json['_id'], // Make sure this key exists in the JSON response
    name: json['name'],
    description: json['description'],
    imageUrl: json['image'], // Match this with the backend field
  );
}

}
