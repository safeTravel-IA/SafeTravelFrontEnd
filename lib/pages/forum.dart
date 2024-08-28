import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safetravelfrontend/providers/user_provider.dart';

class Forum extends StatefulWidget {
  @override
  _ForumState createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  late Future<Map<String, dynamic>> _forumPostsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch forum posts on page load
    _forumPostsFuture = Provider.of<UserProvider>(context, listen: false).getAllForumPosts();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/blocs.png'),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 40),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Travel Community',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        
  future: _forumPostsFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error fetching forum posts'));
    } else if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
      return Center(child: Text('No forum posts available'));
    } else {
      List<dynamic> forumPosts = snapshot.data!['data'];
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: forumPosts.length,
        itemBuilder: (context, index) {
           final post = forumPosts[index];
                final currentUser = Provider.of<UserProvider>(context, listen: false).userId;
                final creatorId = post['userId'] is Map<String, dynamic> && post['userId']['_id'] is String
                    ? post['userId']['_id']
                    : '';

                return Dismissible(
                  key: Key(post['_id']),
                  direction: currentUser == creatorId ? DismissDirection.endToStart : DismissDirection.none,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (currentUser == creatorId) {
                      return _confirmDeletePost(context, post['_id']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You are not authorized to delete this post'),
                        ),
                      );
                      return false;
                    }
                  },
child: _buildForumPost(
  
  postId: post['_id'] is String ? post['_id'] : '', // Ensure _id is a string
  image: post['image'] is String ? post ['image'] : '',
  userName: post['userName'] is String ? post['userName'] : 'Unknown User', // Ensure userName is a string
  daysAgo: post['timeAgo'] is String ? post['timeAgo'] : 'N/A', // Ensure daysAgo is a string
  rating: post['rating'] is int ? post['rating'] as int : 0, // Ensure rating is an int
  title: post['title'] is String ? post['title'] : 'No Title', // Ensure title is a string
  content: post['content'] is String ? post['content'] : 'No Content', // Ensure content is a string
  likes: post['likes'] is int ? post['likes'] : 0, // Ensure likes is an int
  comments: post['comments'] is List<dynamic> // Ensure comments is a list of strings
      ? (post['comments'] as List<dynamic>).map((e) => e.toString()).toList()
      : [],
  tag: post['hashtags'] is List<dynamic> // Ensure comments is a list of strings
      ? (post['hashtags'] as List<dynamic>).map((e) => e.toString()).toList()
      : [],

                    creatorId: post['userId'] is Map<String, dynamic> && post['userId']['_id'] is String
                        ? post['userId']['_id']
                        : '',
                  ),

          );
        },
      );
    }
  },
),


    );
  }
Widget _buildForumPost({
  required String postId,
  required String image,
  required String? userName,
  required String? daysAgo,
  required int? rating, // Optional int
  required String? title,
  required String? content,
  required List<String>? comments, // List of comments
  required int? likes, // Number of likes
  required List<String>? tag,  // Changed from String to List<String>
  required String creatorId,
}) {
  final baseUrl = 'http://10.0.2.2:3000/api/image/';
  
  // Check if the image path contains "/uploads/" and remove it
  String cleanedImage = image.startsWith('/uploads/')
      ? image.substring(9)  // Remove the "/uploads/" prefix
      : image;

  final currentUser = Provider.of<UserProvider>(context, listen: false).userId;

    print('currentUser: $currentUser');
    print('creatorId: $creatorId');
    print('Is current user the creator? ${currentUser == creatorId}');
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(baseUrl + cleanedImage),
                radius: 20,
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName ?? 'Unknown User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    daysAgo ?? 'N/A',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: List.generate(
                  (rating ?? 0), // Ensure rating is an int
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Image.asset(
                      'assets/images/star.png',
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              if (currentUser == creatorId)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editForumPost(postId, title ?? '', content ?? ''),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title ?? 'No Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content ?? 'No Content',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildIconTextRow(
                iconPath: 'assets/images/like.png',
                text: (likes ?? 0).toString(), // Display number of likes
              ),
              SizedBox(width: 16),
              _buildIconTextRow(
                iconPath: 'assets/images/comment.png',
                text: (comments?.length ?? 0).toString(), // Display count of comments
              ),
              Spacer(),
Wrap(
  spacing: 8.0,
  children: tag?.map((t) => Chip(
    label: Text(t),
    backgroundColor: Colors.teal.withOpacity(0.1),
    labelStyle: TextStyle(
      color: Colors.teal,
      fontWeight: FontWeight.bold,
    ),
  ))?.toList() ?? [],
),

            ]
              ),
            ],
          ),
    )
  
    
  );
}


Widget _buildIconTextRow({
  required String iconPath,
  required String text,
}) {
  return Row(
    children: [
      Image.asset(
        iconPath,
        height: 20,
        width: 20,
      ),
      SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    ],
  );
}



Future<bool> _confirmDeletePost(BuildContext context, String postId) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Confirm Delete'),
      content: Text('Are you sure you want to delete this post?'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(ctx).pop(false); // Return false on cancel
          },
        ),
        
        TextButton(
          child: Text('Delete'),
          
          onPressed: () async {
            final result = await Provider.of<UserProvider>(context, listen: false).deleteForumPost(postId);
            if (result.containsKey('error')) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Failed to delete post'),
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Post deleted successfully'),
              ));
              setState(() {
                _forumPostsFuture = Provider.of<UserProvider>(context, listen: false).getAllForumPosts();
              });
            }
            Navigator.of(ctx).pop(true); // Return true on delete
          },
        ),
      ],
    ),
  ) ?? false; // Ensure the return type is always a boolean
}

  void _editForumPost(String postId, String currentTitle, String currentContent, {String? currentImagePath}) {
  final titleController = TextEditingController(text: currentTitle);
  final contentController = TextEditingController(text: currentContent);
  String? selectedImagePath = currentImagePath; // Start with the current image path

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Edit Forum Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: contentController,
            decoration: InputDecoration(labelText: 'Content'),
            maxLines: 3,
          ),
          if (selectedImagePath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.file(
                File(selectedImagePath??""),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          TextButton(
            child: Text('Select Image'),
            onPressed: () async {
              // Implement image picking logic here
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  selectedImagePath = pickedFile.path;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            final newTitle = titleController.text;
            final newContent = contentController.text;

            final result = await Provider.of<UserProvider>(context, listen: false).updateForumPost(
              postId: postId, // Named parameter
              title: newTitle, // Named parameter
              content: newContent, // Named parameter
              imagePath: selectedImagePath, // Named parameter
            );

            if (result.containsKey('error')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['error']),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Post edited successfully'),
                ),
              );
              setState(() {
                _forumPostsFuture = Provider.of<UserProvider>(context, listen: false).getAllForumPosts();
              });
            }

            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}


}
