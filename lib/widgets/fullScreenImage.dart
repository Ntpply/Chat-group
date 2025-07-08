import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class FullScreenImage extends StatefulWidget {
  final Uint8List imageBytes;

  const FullScreenImage({super.key, required this.imageBytes});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    
    // Set system UI to immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _isAppBarVisible
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              foregroundColor: Colors.white,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _showOptionsBottomSheet(context);
                    },
                  ),
                ),
              ],
            )
          : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: _toggleAppBarVisibility,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              clipBehavior: Clip.none,
              child: Center(
                child: Hero(
                  tag: 'image_${widget.imageBytes.hashCode}',
                  child: Image.memory(
                    widget.imageBytes,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_rounded,
                              size: 80,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ไม่สามารถโหลดรูปภาพได้',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'กรุณาลองใหม่อีกครั้ง',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Options
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.download_rounded,
                  color: Colors.blue[600],
                ),
              ),
              title: const Text(
                'บันทึกรูปภาพ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text('บันทึกรูปภาพลงในเครื่อง'),
              onTap: () {
                Navigator.pop(context);
                _saveImage();
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: Colors.green[600],
                ),
              ),
              title: const Text(
                'แชร์รูปภาพ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text('แชร์รูปภาพไปยังแอปอื่น'),
              onTap: () {
                Navigator.pop(context);
                _shareImage();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveImage() {
    // TODO: Implement save image functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Text('ฟีเจอร์บันทึกรูปภาพยังไม่พร้อมใช้งาน'),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _shareImage() {
    // TODO: Implement share image functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Text('ฟีเจอร์แชร์รูปภาพยังไม่พร้อมใช้งาน'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}