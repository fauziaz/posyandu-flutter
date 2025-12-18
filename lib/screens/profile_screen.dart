// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../screens/landing_screen.dart';
import '../screens/bookmarks_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  DateTime? _selectedDate;
  bool _isEditing = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _selectedDate = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final bytes = await image.readAsBytes();
        final extension = image.name.split('.').last;

        if (!mounted) return;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final imageUrl = await authProvider.uploadAvatar(bytes, extension);

        if (imageUrl != null) {
          final error = await authProvider.updateProfile(
            name: _nameController.text,
            phoneNumber: _phoneController.text,
            dateOfBirth: _selectedDate,
            avatarUrl: imageUrl,
          );

          if (mounted) {
            if (error == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto profil berhasil diperbarui'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal upload foto: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;

        // 1. Update Email if changed
        if (_emailController.text != user?.email) {
          final emailError = await authProvider.updateEmail(
            _emailController.text,
          );
          if (emailError != null) {
            throw emailError;
          }
        }

        // 2. Update Password if provided
        if (_passwordController.text.isNotEmpty) {
          final passError = await authProvider.updatePassword(
            _passwordController.text,
          );
          if (passError != null) {
            throw passError;
          }
        }

        // 3. Update Profile Data
        final error = await authProvider.updateProfile(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          dateOfBirth: _selectedDate,
        );

        if (mounted) {
          if (error == null) {
            setState(() {
              _isEditing = false;
              _passwordController.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil berhasil diperbarui')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal update profil: $error')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal update profil: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil Akun'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset controllers
                  _nameController.text = user?.name ?? '';
                  _emailController.text = user?.email ?? '';
                  _phoneController.text = user?.phoneNumber ?? '';
                  _passwordController.clear();
                  _selectedDate = user?.dateOfBirth;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 3,
                        ),
                        color: Colors.white,
                        image: user?.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user!.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primaryColor,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User Name Display (Only in View Mode)
              if (!_isEditing) ...[
                Text(
                  user?.name ?? 'Pengguna',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.subTextColor,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              if (_isEditing) ...[
                _buildEditField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (val) =>
                      val!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                _buildEditField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      val!.isEmpty ? 'Email tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                _buildEditField(
                  controller: _passwordController,
                  label: 'Password Baru (Opsional)',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildEditField(
                  controller: _phoneController,
                  label: 'No. Handphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildEditField(
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                            : '',
                      ),
                      label: 'Tanggal Lahir',
                      icon: Icons.cake_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                // Info Cards
                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: 'Nama Lengkap',
                  value: user?.name ?? '-',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: user?.email ?? '-',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  title: 'No. Handphone',
                  value: user?.phoneNumber ?? 'Belum diisi',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.cake_outlined,
                  title: 'Tanggal Lahir',
                  value: user?.dateOfBirth != null
                      ? DateFormat('dd MMMM yyyy').format(user!.dateOfBirth!)
                      : 'Belum diisi',
                ),

                const SizedBox(height: 24),

                // Bookmarks Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookmarksScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bookmark_rounded,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Artikel Disimpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Edit/Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_isEditing) {
                            _saveProfile();
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                  icon: Icon(_isEditing ? Icons.save : Icons.edit_outlined),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditing ? 'Simpan Perubahan' : 'Edit Profil',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button (Only in View Mode)
              if (!_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: AppTheme.subTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
