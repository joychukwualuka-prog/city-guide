import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../models/attraction_model.dart';

class ManageListingsScreen extends StatelessWidget {
  const ManageListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Listings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddListingSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add listing'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection('attractions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No listings yet — add one below.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final attraction = AttractionModel.fromMap(docs[index].id, docs[index].data());
              return Card(
                child: ListTile(
                  title: Text(attraction.name),
                  subtitle: Text('${attraction.category.name} · ${attraction.cityId}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _confirmDelete(context, attraction),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, AttractionModel attraction) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('This removes "${attraction.name}" and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('attractions').doc(attraction.id).delete();
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddListingSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final cityIdController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    final addressController = TextEditingController();
    AttractionCategory category = AttractionCategory.attraction;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.md,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add listing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: cityIdController,
                        decoration: const InputDecoration(
                          labelText: 'City document ID',
                          helperText: 'Must match an existing city doc ID in Firestore',
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<AttractionCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: AttractionCategory.values
                            .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => category = v!),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(labelText: 'Image URL'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          await FirebaseFirestore.instance.collection('attractions').add({
                            'name': nameController.text.trim(),
                            'cityId': cityIdController.text.trim(),
                            'category': category.name,
                            'description': descriptionController.text.trim(),
                            'imageUrls': imageUrlController.text.trim().isEmpty
                                ? <String>[]
                                : [imageUrlController.text.trim()],
                            'location': const GeoPoint(0, 0),
                            'address': addressController.text.trim(),
                            'contact': '',
                            'openingHours': '',
                            'avgRating': 0,
                            'ratingCount': 0,
                          });
                          if (context.mounted) Navigator.pop(sheetContext);
                        },
                        child: const Text('Save listing'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
