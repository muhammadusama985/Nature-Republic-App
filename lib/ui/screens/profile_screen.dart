import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_text.dart';
import '../../core/theme/app_theme.dart';
import '../../state/customer_store.dart';
import '../widgets/common_widgets.dart';
import '../widgets/customer_shell.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _labelController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isDefaultAddress = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<CustomerStore>().user;
    _firstNameController.text = user?.firstName ?? '';
    _lastNameController.text = user?.lastName ?? '';
    _phoneController.text = user?.phone ?? '';
    _fullNameController.text = user?.fullName ?? '';
    _addressPhoneController.text = user?.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();
    final user = store.user;

    return CustomerShell(
      title: store.isArabic ? 'الملف الشخصي' : 'Profile',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SurfaceCard(
            child: user == null
                ? Text(store.isArabic
                    ? 'سجلي الدخول لإدارة الملف الشخصي.'
                    : 'Login to manage your profile.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      Text(user.email,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _firstNameController,
                        decoration:
                            const InputDecoration(labelText: 'First name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lastNameController,
                        decoration:
                            const InputDecoration(labelText: 'Last name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await store.saveProfile(
                            firstName: _firstNameController.text.trim(),
                            lastName: _lastNameController.text.trim(),
                            phone: _phoneController.text.trim(),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated')),
                            );
                          }
                        },
                        child: Text(
                            store.isArabic ? 'حفظ التغييرات' : 'Save Changes'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        store.isArabic
                            ? 'العناوين المحفوظة'
                            : 'Saved Addresses',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (user.addresses.isEmpty)
                        Text(store.isArabic
                            ? 'لا توجد عناوين محفوظة.'
                            : 'No saved addresses yet.')
                      else
                        ...user.addresses.map(
                          (address) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF8),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${address.fullName}${address.isDefault ? ' • Default' : ''}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${address.addressLine1}, ${address.city}, ${address.country}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      store.deleteAddress(address.id),
                                  icon:
                                      const Icon(Icons.delete_outline_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        store.isArabic ? 'إضافة عنوان جديد' : 'Add New Address',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _labelController,
                        decoration: const InputDecoration(labelText: 'Label'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _fullNameController,
                        decoration:
                            const InputDecoration(labelText: 'Full name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressPhoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _areaController,
                        decoration: const InputDecoration(labelText: 'Area'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _line1Controller,
                        decoration:
                            const InputDecoration(labelText: 'Address line 1'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _line2Controller,
                        decoration:
                            const InputDecoration(labelText: 'Address line 2'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _postalCodeController,
                        decoration:
                            const InputDecoration(labelText: 'Postal code'),
                      ),
                      const SizedBox(height: 6),
                      CheckboxListTile(
                        value: _isDefaultAddress,
                        contentPadding: EdgeInsets.zero,
                        title: Text(store.isArabic
                            ? 'تعيين كعنوان افتراضي'
                            : 'Set as default address'),
                        onChanged: (value) =>
                            setState(() => _isDefaultAddress = value ?? false),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await store.addAddress({
                            'label': _labelController.text.trim(),
                            'fullName': _fullNameController.text.trim(),
                            'phone': _addressPhoneController.text.trim(),
                            'country': 'UAE',
                            'city': _cityController.text.trim(),
                            'area': _areaController.text.trim(),
                            'addressLine1': _line1Controller.text.trim(),
                            'addressLine2': _line2Controller.text.trim(),
                            'postalCode': _postalCodeController.text.trim(),
                            'isDefault': _isDefaultAddress,
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Address added')),
                            );
                          }
                          _labelController.clear();
                          _cityController.clear();
                          _areaController.clear();
                          _line1Controller.clear();
                          _line2Controller.clear();
                          _postalCodeController.clear();
                          setState(() => _isDefaultAddress = false);
                        },
                        child: Text(
                            store.isArabic ? 'إضافة عنوان' : 'Add Address'),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.legal(store.isArabic),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppTheme.text),
                  title: Text(AppText.privacyPolicy(store.isArabic)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(
                      context, PrivacyPolicyScreen.routeName),
                ),
                if (store.isAuthenticated) ...[
                  const Divider(height: 28),
                  Text(
                    AppText.dangerZone(store.isArabic),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red.shade700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppText.deleteAccountWarning(store.isArabic),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => _confirmDeleteAccount(context, store),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side:
                          BorderSide(color: Colors.red.withValues(alpha: 0.35)),
                    ),
                    child: Text(AppText.deleteAccount(store.isArabic)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, CustomerStore store) async {
    final isArabic = store.isArabic;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppText.deleteAccount(isArabic)),
        content: Text(AppText.deleteAccountWarning(isArabic)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppText.cancel(isArabic)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: Text(AppText.deleteAccountConfirm(isArabic)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await store.deleteAccount();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.accountDeleted(isArabic))),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
}
