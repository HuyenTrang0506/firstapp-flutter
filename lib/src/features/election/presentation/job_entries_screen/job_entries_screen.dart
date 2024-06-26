import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voting_app/src/common_widgets/async_value_widget.dart';
import 'package:voting_app/src/features/election/data/jobs_repository.dart';
import 'package:voting_app/src/features/election/domain/job.dart';
import 'package:voting_app/src/features/election/presentation/job_entries_screen/job_entries_list.dart';

class ElecEntriesScreen extends ConsumerWidget {
  const ElecEntriesScreen({super.key, required this.jobId});
  final JobID jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobStreamProvider(jobId));
    return ScaffoldAsyncValueWidget<Job>(
      value: jobAsync,
      data: (job) => JobEntriesPageContents(job: job),
    );
  }
}

class JobEntriesPageContents extends StatelessWidget {
  const JobEntriesPageContents({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.indigo, Colors.blue],
            ),
          ),
        ),
        elevation: 0.0,
        title: Text(job.name),
        actions: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.info_outline_rounded),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationVersion: '^1.0.0',
                  applicationName: 'ElectChain',
                );
              },
            ),
          ),
        ],
      ),
      body: JobEntriesList(job: job),
    );
  }
}
