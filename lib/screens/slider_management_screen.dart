import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/slider_provider.dart';
import 'package:sungoods/models/slider_image.dart';
import 'package:sungoods/utils/api_constants.dart';

class SliderManagementScreen extends StatefulWidget {
  const SliderManagementScreen({super.key});

  @override
  State<SliderManagementScreen> createState() => _SliderManagementScreenState();
}

class _SliderManagementScreenState extends State<SliderManagementScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<SliderProvider>(context, listen: false);
      provider.fetchSliders();
    });
  }

  Future<void> _pickAndAddSlider() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (!mounted) return;
    
    String? title;
    String? link;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Slider Details'),
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
    Provider.of<SliderProvider>(context, listen: false).addSlider(
      image: File(image.path),
      title: title,
      link: link,
    );
  }

  Future<void> _editSlider(SliderImage slider) async {
    final TextEditingController titleController = TextEditingController(text: slider.title);
    final TextEditingController linkController = TextEditingController(text: slider.link);
    File? newImage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Slider'),
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
              Provider.of<SliderProvider>(context, listen: false).updateSlider(
                id: slider.id,
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
        title: const Text('Slider Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SliderProvider>(context, listen: false).fetchSliders();
            },
          ),
        ],
      ),
      body: Consumer<SliderProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.amber.shade50,
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Recommended Image Size: 1920x1080 pixels (16:9 Aspect Ratio).\nYou can now manage both API and Local sliders.',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Enable API Data'),
                subtitle: Text(provider.isApiEnabled 
                  ? 'Currently showing sliders from server' 
                  : 'Currently showing sliders from local database'),
                value: provider.isApiEnabled,
                onChanged: (value) {
                  provider.setApiEnabled(value);
                },
              ),
              const Divider(),
              if (provider.isLoading)
                const LinearProgressIndicator(),
              Expanded(
                child: _buildSliderList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndAddSlider,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSliderList(SliderProvider provider) {
    if (provider.isLoading && provider.sliders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.errorMessage != null) {
      return Center(child: Text('Error: ${provider.errorMessage}'));
    }

    if (provider.sliders.isEmpty) {
      return const Center(child: Text('No sliders found. Click + to add one.'));
    }

    return ListView.builder(
      itemCount: provider.sliders.length,
      itemBuilder: (context, index) {
        final slider = provider.sliders[index];
        final bool isVisible = slider.status == 1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildSliderPreview(slider),
            ),
            title: Text(
              slider.title ?? 'Slider #${slider.id}',
              style: TextStyle(
                decoration: isVisible ? TextDecoration.none : TextDecoration.lineThrough,
                color: isVisible ? Colors.black : Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (slider.link != null && slider.link!.isNotEmpty) 
                  Text(slider.link!, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  isVisible ? 'Status: Visible' : 'Status: Hidden',
                  style: TextStyle(
                    color: isVisible ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editSlider(slider);
                } else if (value == 'delete') {
                  provider.deleteSlider(slider.id);
                } else if (value == 'toggle') {
                  provider.toggleSliderVisibility(slider);
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

  Widget _buildSliderPreview(SliderImage slider) {
    if (slider.imageUrl.startsWith('http')) {
      return Image.network(
        slider.imageUrl,
        width: 80, height: 45, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 45),
      );
    } else if (slider.imageUrl.startsWith('assets/')) {
      return Image.asset(
        slider.imageUrl,
        width: 80, height: 45, fit: BoxFit.cover,
      );
    } else {
      // Local file path
      return Image.file(
        File(slider.imageUrl),
        width: 80, height: 45, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 45),
      );
    }
  }
}
