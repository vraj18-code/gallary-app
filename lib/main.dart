import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

/// Entry point of the application.
void main() {
  runApp(const ImageGalleryApp());
}

/// The main app widget which sets up the [MaterialApp].
class ImageGalleryApp extends StatelessWidget {
  const ImageGalleryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixabay Image Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageGalleryPage(),
    );
  }
}

/// The main page that displays the image gallery.
class ImageGalleryPage extends StatefulWidget {
  const ImageGalleryPage({Key? key}) : super(key: key);

  @override
  _ImageGalleryPageState createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  /// Controller for handling scroll events.
  final ScrollController _scrollController = ScrollController();

  /// List to hold fetched image data.
  final List<dynamic> _images = [];

  /// Page number for pagination.
  int _page = 1;

  /// Flag to indicate if images are being loaded.
  bool _isLoading = false;

  /// Query to specify the type of images (e.g., 'nature', 'cars').
  String _query = 'nature'; // Modify this to fetch specific images like 'cars', 'animals', etc.

  @override
  void initState() {
    super.initState();
    _fetchImages();

    // Adding a listener to the scroll controller to detect when the user reaches the bottom.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchImages();
      }
    });
  }

  /// Fetches images from the Pixabay API based on the query.
  Future<void> _fetchImages() async {
    // Prevent loading multiple times at once.
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Replace this with your own Pixabay API key.
    const String apiKey = '46238701-9bd442ac0e990369f9620d1d9';
    final String apiUrl =
        'https://pixabay.com/api/?key=$apiKey&q=$_query&image_type=photo&per_page=20&page=$_page';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _images.addAll(data['hits']);
        _page++;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixabay Image Gallery'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Image Category:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _query,
                  onChanged: (String? newValue) {
                    setState(() {
                      _query = newValue!;
                      _images.clear(); // Clear the previous results.
                      _page = 1; // Reset the page number.
                      _fetchImages(); // Fetch new images based on the selected category.
                    });
                  },
                  items: <String>['nature', 'cars', 'animals', 'technology']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _images.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 0.8,
              ),
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                // If it's the last item, show a loader if still loading more images.
                if (index == _images.length) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }

                // Build the image card with likes and views.
                final image = _images[index];
                return _buildImageCard(image);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Determines the number of columns for the grid based on screen width.
  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 5;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  /// Builds the image card widget with cached image, likes, and views.
  Widget _buildImageCard(dynamic image) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: image['webformatURL'],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Likes: ${image['likes']}'),
                Text('Views: ${image['views']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


//46238701-9bd442ac0e990369f9620d1d9