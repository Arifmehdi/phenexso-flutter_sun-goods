import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/banner_provider.dart';
import 'package:sungoods/models/slider_image.dart';

class BannerManagementScreen extends StatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BannerProvider>(context, listen: false).loadBanners();
    });
  }

  Future<void> _pickAndAddBanner() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (!mounted) return;
    
    String? title;
    String? link;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Banner Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title (Optional)'),
              onChanged: (value) => title = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Link (Optional)'),
              onChanged: (value) => link = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Provider.of<BannerProvider>(context, listen: false).addBanner(
      image: File(image.path),
      title: title,
      link: link,
    );
  }

  Future<void> _editBanner(SliderImage banner) async {
    final TextEditingController titleController = TextEditingController(text: banner.title);
    final TextEditingController linkController = TextEditingController(text: banner.link);
    File? newImage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Banner'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(labelText: 'Link'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
                  if (img != null) {
                    newImage = File(img.path);
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Change Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<BannerProvider>(context, listen: false).updateBanner(
                id: banner.id,
                title: titleController.text,
                link: linkController.text,
                image: newImage,
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<BannerProvider>(context, listen: false).loadBanners();
            },
          ),
        ],
      ),
      body: Consumer<BannerProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recommended Image Size: 1200x300 pixels.\nActive banners will appear on the Home page between sections.',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              if (provider.isLoading)
                const LinearProgressIndicator(),
              Expanded(
                child: _buildBannerList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndAddBanner,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBannerList(BannerProvider provider) {
    if (provider.isLoading && provider.banners.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.banners.isEmpty) {
      return const Center(child: Text('No banners found. Click + to add one.'));
    }

    return ListView.builder(
      itemCount: provider.banners.length,
      itemBuilder: (context, index) {
        final banner = provider.banners[index];
        final bool isVisible = banner.status == 1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildBannerPreview(banner),
            ),
            title: Text(
              banner.title ?? 'Banner #${banner.id}',
              style: TextStyle(
                decoration: isVisible ? TextDecoration.none : TextDecoration.lineThrough,
                color: isVisible ? Colors.black : Colors.grey,
              ),
            ),
            subtitle: Text(
              isVisible ? 'Status: Visible' : 'Status: Hidden',
              style: TextStyle(
                color: isVisible ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editBanner(banner);
                } else if (value == 'delete') {
                  provider.deleteBanner(banner.id);
                } else if (value == 'toggle') {
                  provider.toggleBannerVisibility(banner);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(isVisible ? 'Hide' : 'Show'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerPreview(SliderImage banner) {
    if (banner.imageUrl.startsWith('http')) {
      return Image.network(
        banner.imageUrl,
        width: 80, height: 45, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 45),
      );
    } else if (banner.imageUrl.startsWith('assets/')) {
      return Image.asset(
        banner.imageUrl,
        width: 80, height: 45, fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(banner.imageUrl),
        width: 80, height: 45, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 45),
      );
    }
  }
}
