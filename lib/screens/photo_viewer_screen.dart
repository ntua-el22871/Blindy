import 'package:flutter/material.dart';
import 'dart:convert';

class PhotoViewerScreen extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: photos.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: Hero(
                  tag: photos[index],
                  child: InteractiveViewer(
                    child: Image.memory(
                      base64Decode(photos[index]),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}