import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/models/action_item.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class CreateActionScreen extends StatefulWidget {
  final String goalId;
  const CreateActionScreen({super.key, required this.goalId});

  @override
  State<CreateActionScreen> createState() => _CreateActionScreenState();
}

class _CreateActionScreenState extends State<CreateActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();

  String _priority = 'Medium';

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveAction() {
    if (_formKey.currentState!.validate()) {
      _saveToBackend();
    }
  }

  Future<void> _saveToBackend() async {
    final provider = Provider.of<GoalProvider>(context, listen: false);
    // 1. Persist to Supabase
    await ApiService().createAction(
      goalId: widget.goalId,
      title: _titleController.text,
      priority: _priority.toLowerCase(),
    );
    // 2. Refresh goals so UI shows the new action
    await provider.fetchGoals();
    if (mounted) context.pop();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isNumeric = false,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
          validator: (val) {
            if (isRequired && (val == null || val.trim().isEmpty)) return 'Required';
            if (isNumeric && val != null && val.isNotEmpty && int.tryParse(val) == null) return 'Must be a number';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF64748B).withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AmbientWatercolorBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text('New Action', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Action Title',
                          hint: 'e.g. Learn 20 words',
                          isRequired: true,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildTextField(
                          controller: _durationController,
                          label: 'Estimated Duration (mins)',
                          hint: 'e.g. 30',
                          isNumeric: true,
                        ),
                        const SizedBox(height: 24),

                        const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Low', 'Medium', 'High'].map((p) {
                            final isSelected = _priority == p;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _priority = p),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(right: p == 'High' ? 0 : 8),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSelected ? const Color(0xFF1E293B) : Colors.grey.withOpacity(0.2)),
                                    boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      p,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 48),
                        
                        GestureDetector(
                          onTap: _saveAction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Center(
                              child: Text('Save Action', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
