import 'package:deadline_ai/features/syllabus_ingestion/presentation/cubit/syllabus_ingestion_cubit.dart';
import 'package:deadline_ai/features/syllabus_ingestion/presentation/cubit/syllabus_ingestion_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadSyllabusPage extends StatelessWidget {
  const UploadSyllabusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Syllabus PDFs')),
      body: BlocConsumer<SyllabusIngestionCubit, SyllabusIngestionState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<SyllabusIngestionCubit>().pickPdfFiles(),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Pick PDFs'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<SyllabusIngestionCubit>().extractDeadlines(),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Extract Deadlines'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Selected files: ${state.files.length}'),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: [
                      ...state.files.map((f) => ListTile(
                            leading: const Icon(Icons.picture_as_pdf),
                            title: Text(f.name),
                            subtitle: Text('${(f.size / 1024).toStringAsFixed(1)} KB'),
                          )),
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (state.extractedDeadlines.isNotEmpty) ...[
                        const Divider(height: 32),
                        const Text(
                          'Extraction Review',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...state.extractedDeadlines.map(
                          (deadline) => Card(
                            child: ListTile(
                              title: Text(deadline.title),
                              subtitle: Text(
                                '${deadline.course} • ${deadline.date.toLocal().toString().split(' ').first}',
                              ),
                              trailing: Text('${(deadline.confidence * 100).toStringAsFixed(0)}%'),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
