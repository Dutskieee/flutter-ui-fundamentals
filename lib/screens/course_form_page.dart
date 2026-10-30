import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormPage extends StatefulWidget {
  final Course? course; // TAHAP 7: Jika null = Tambah, Jika ada isinya = Edit

  const CourseFormPage({super.key, this.course});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController();
  String _status = 'planned'; 

  bool get isEditMode => widget.course != null;

  @override
  void initState() {
    super.initState();
    // TAHAP 7: Pre-fill data jika dalam mode edit
    if (isEditMode) {
      _codeCtrl.text = widget.course!.code;
      _titleCtrl.text = widget.course!.title;
      _creditsCtrl.text = widget.course!.credits.toString();
      _status = widget.course!.status;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final courseInput = Course(
      code: _codeCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      credits: int.parse(_creditsCtrl.text.trim()),
      status: _status,
    );

    final provider = context.read<CourseProvider>();
    try {
      bool success;
      // TAHAP 7: Pilih fungsi yang tepat berdasarkan mode
      if (isEditMode) {
        success = await provider.editCourse(widget.course!.id!, courseInput);
      } else {
        success = await provider.addCourse(courseInput);
      }
      
      if (!context.mounted) return; 
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Berhasil mengupdate Course!' : 'Berhasil menambahkan Course!'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CourseProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Course' : 'Tambah Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Kode Course', border: OutlineInputBorder()),
                // TAHAP 7: Kode Course read-only saat edit agar kunci favorite tidak rusak
                enabled: !isSaving && !isEditMode, 
                validator: (val) => val == null || val.isEmpty ? 'Kode wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul Course', border: OutlineInputBorder()),
                enabled: !isSaving,
                validator: (val) => val == null || val.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditsCtrl,
                decoration: const InputDecoration(labelText: 'SKS (Credits)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                enabled: !isSaving,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'SKS wajib diisi';
                  if (int.tryParse(val) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'planned', child: Text('Planned')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
                onChanged: isSaving ? null : (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
                child: isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('SIMPAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}