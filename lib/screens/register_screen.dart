import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final errorMsg = await ApiService().registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      setState(() => _isLoading = false);
      
      if (errorMsg == null && mounted) {
        context.go('/splash');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Error: $errorMsg')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF6366F1)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTile({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
          width: isFocused ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? const Color(0xFF6366F1).withOpacity(0.12)
                : const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: isFocused ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isFocused
                    ? const Color(0xFFEEF2FF)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFocused
                      ? const Color(0xFFC7D2FE)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                icon,
                color: isFocused
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF64748B),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isFocused
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    obscureText: isPassword ? _obscurePassword : false,
                    keyboardType: keyboardType,
                    validator: validator,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      hintText: 'Enter your ${label.toLowerCase()}',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isPassword)
              IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            final now = DateTime.now();
            if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
              _lastBackPress = now;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Press back again to exit GoalFlow'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            } else {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: AmbientWatercolorBackground(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(26.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.95),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.06),
                            blurRadius: 36,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Brand Icon Header
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withOpacity(0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.rocket_launch_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // App title badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'START YOUR JOURNEY',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4F46E5),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sync your AI roadmaps & habits securely in the cloud',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),

                            // Feature Pills
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildFeaturePill(Icons.psychology_rounded, 'AI Engine'),
                                _buildFeaturePill(Icons.calendar_month_rounded, 'Daily Flow'),
                                _buildFeaturePill(Icons.cloud_done_rounded, 'Auto-Sync'),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Input Tiles
                            _buildFieldTile(
                              label: 'Full Name',
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              icon: Icons.person_outline_rounded,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Name is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildFieldTile(
                              label: 'Email Address',
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Email is required';
                                if (!val.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildFieldTile(
                              label: 'Password',
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Password is required';
                                if (val.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 26),

                            // Submit Button Tile
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withOpacity(0.28),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _isLoading ? null : _handleRegister,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 17),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_isLoading)
                                          const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        else ...[
                                          const Text(
                                            'Create Free Account',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Switch to Login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Color(0xFF4F46E5),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
