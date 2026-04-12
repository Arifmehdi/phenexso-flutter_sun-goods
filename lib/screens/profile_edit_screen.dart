import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/auth_provider.dart';
import 'package:sungoods/models/user.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bkashNumberController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(); // Initialize directly
  final TextEditingController _bloodGroupController =
      TextEditingController(); // Initialize directly
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nidController =
      TextEditingController(); // Initialize directly
  final TextEditingController _shortBioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController.text = user?.name ?? '';
    _fatherNameController.text = user?.father_name ?? '';
    _addressController.text = user?.address ?? '';
    _bkashNumberController.text = user?.bkash_number ?? '';
    _dobController.text = user?.dob ?? ''; // Update text
    _bloodGroupController.text = user?.blood_group ?? ''; // Update text
    _mobileController.text = user?.mobile ?? '';
    _nidController.text = user?.nid ?? ''; // Update text
    _shortBioController.text = user?.short_bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
    _bkashNumberController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _mobileController.dispose();
    _nidController.dispose(); // Re-added NID disposal
    _shortBioController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        return;
      }

      final updatedUser = User(
        id: currentUser.id,
        name: _nameController.text,
        email: currentUser.email, // Email cannot be changed here
        role: currentUser.role, // Role cannot be changed here
        is_admin: currentUser.is_admin,
        is_approve: currentUser.is_approve,
        father_name: _fatherNameController.text.isEmpty
            ? null
            : _fatherNameController.text,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        bkash_number: _bkashNumberController.text.isEmpty
            ? null
            : _bkashNumberController.text,
        dob: _dobController.text.isEmpty ? null : _dobController.text,
        blood_group: _bloodGroupController.text.isEmpty
            ? null
            : _bloodGroupController.text,
        mobile: _mobileController.text.isEmpty ? null : _mobileController.text,
        nid: _nidController.text.isEmpty
            ? null
            : _nidController.text, // Re-added NID
        short_bio: _shortBioController.text.isEmpty
            ? null
            : _shortBioController.text,
        user_type: currentUser.user_type, // User type cannot be changed here
      );

      try {
        await authProvider.updateProfile(updatedUser);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back to account screen
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dobController.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null &&
        picked.toString().split(' ')[0] != _dobController.text) {
      setState(() {
        _dobController.text = picked.toString().split(
          ' ',
        )[0]; // Format as YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: TextEditingController(
                  text:
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).user?.email ??
                      '',
                ),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey,
                ),
                readOnly: true, // Email is not editable
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(labelText: "Father's Name"),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _bkashNumberController,
                decoration: const InputDecoration(labelText: 'Bkash Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                initialValue: _bloodGroupController.text.isEmpty
                    ? null
                    : _bloodGroupController.text,
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
                items:
                    <String>[
                      'A+',
                      'A-',
                      'B+',
                      'B-',
                      'AB+',
                      'AB-',
                      'O+',
                      'O-',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _bloodGroupController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your blood group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nidController,
                decoration: const InputDecoration(labelText: 'NID'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _shortBioController,
                decoration: const InputDecoration(labelText: 'Short Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
