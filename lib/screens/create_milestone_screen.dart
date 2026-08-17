import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:goalflow/services/goal_provider.dart';
import 'package:goalflow/services/api_service.dart';
import 'package:goalflow/widgets/ambient_watercolor_background.dart';

class CreateMilestoneScreen extends StatefulWidget {
  final String goalId;
  const CreateMilestoneScreen({super.key, required this.goalId});

  @override
  State<CreateMilestoneScreen> createState() => _CreateMilestoneScreenState();
}

class _CreateMilestoneScreenState extends State<CreateMilestoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveMilestone() {
    if (_formKey.currentState!.validate()) {
      _saveToBackend();
    }
  }

  Future<void> _saveToBackend() async {
    final provider = Provider.of<GoalProvider>(context, listen: false);
    // 1. Persist to Supabase
    await ApiService().createMilestone(
      goalId: widget.goalId,
      title: _titleController.text,
    );
    // 2. Refresh goals from backend so UI reflects real data
    await provider.fetchGoals();
    if (mounted) context.pop();
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
                    const Text('New Milestone', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
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
                        const Text('Milestone Title', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          decoration: InputDecoration(
                            hintText: 'e.g. Master intermediate grammar',
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
                        const SizedBox(height: 48),
                        
                        GestureDetector(
                          onTap: _saveMilestone,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Center(
                              child: Text('Save Milestone', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
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
