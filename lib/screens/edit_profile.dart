// lib/screens/profile/edit_profile_screen.dart
import 'package:app/services/di/service_locator.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/profile_api.dart';
import '../../models/auth/user.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  File? _imageFile;
  bool _isLoading = false;
  String? _error;
  
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current user data
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    
    _selectedGender = user?.gender;
    _selectedBirthDate = user?.birthDate;
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final profileApi = getIt<ProfileApiService>();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Upload profile photo if changed
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await profileApi.uploadProfilePhoto(_imageFile!);
      }
      
      // Update profile
      final updatedUser = await profileApi.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        bio: _bioController.text,
        gender: _selectedGender,
        birthDate: _selectedBirthDate,
        photoUrl: photoUrl,
      );
      
      // Update user in auth provider
      authProvider.updateUser(updatedUser);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        
        // Go back to profile screen
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile photo
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.lightGrey,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (user.profilePictureUrl != null
                              ? NetworkImage(user.profilePictureUrl!)
                              : null),
                      child: (_imageFile == null && user.profilePictureUrl == null)
                          ? Text(
                              _getInitials(user),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // First name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Last name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Birth date
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Birth Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _selectedBirthDate != null
                          ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                          : '',
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  hintText: 'Tell others about yourself and your music taste',
                ),
                maxLines: 5,
                maxLength: 250,
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              GradientButton(
                onPressed: _isLoading ? (){} : _saveProfile,
              text: "Save profile",
              isLoading: _isLoading,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getInitials(User user) {
    String initials = '';
    
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      initials += user.firstName![0];
    }
    
    if (user.lastName != null && user.lastName!.isNotEmpty) {
      initials += user.lastName![0];
    }
    
    if (initials.isEmpty && user.username.isNotEmpty) {
      initials = user.username[0].toUpperCase();
    }
    
    return initials;
  }
}