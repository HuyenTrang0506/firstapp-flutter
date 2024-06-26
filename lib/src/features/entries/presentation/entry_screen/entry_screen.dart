import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voting_app/src/common_widgets/date_time_picker.dart';
import 'package:voting_app/src/common_widgets/responsive_center.dart';
import 'package:voting_app/src/constants/app_sizes.dart';
import 'package:voting_app/src/constants/breakpoints.dart';
import 'package:voting_app/src/features/entries/domain/entry.dart';
import 'package:voting_app/src/features/entries/presentation/entry_screen/entry_screen_controller.dart';
import 'package:voting_app/src/features/jobs/domain/job.dart';
import 'package:voting_app/src/utils/async_value_ui.dart';
import 'package:voting_app/src/utils/format.dart';

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, required this.jobId, this.entryId, this.entry});
  final JobID jobId;
  final EntryID? entryId;
  final Entry? entry;

  @override
  ConsumerState<EntryScreen> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryScreen> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late String _comment;

  DateTime get start => DateTime(_startDate.year, _startDate.month,
      _startDate.day, _startTime.hour, _startTime.minute);
  DateTime get end => DateTime(_endDate.year, _endDate.month, _endDate.day,
      _endTime.hour, _endTime.minute);

  @override
  void initState() {
    super.initState();
    final start = widget.entry?.start ?? DateTime.now();
    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);

    final end = widget.entry?.end ?? DateTime.now();
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay.fromDateTime(end);

    _comment = widget.entry?.comment ?? '';
    
  }

  Future<void> _setEntryAndDismiss() async {
    final success =
        await ref.read(entryScreenControllerProvider.notifier).submit(
              entryId: widget.entryId,
              jobId: widget.jobId,
              start: start,
              end: end,
              comment: _comment,              
            );
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      entryScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
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
        title: Text(widget.entry != null ? 'Edit Vote' : 'New Vote'),
        actions: [
          TextButton(
            child: Text(
              widget.entry != null ? 'Update' : 'Create',
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: () => _setEntryAndDismiss(),
          ),
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
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: Breakpoint.tablet,
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDuration(),
              gapH8,
              _buildComment(),
              gapH8,
              _buildStartDate(),
              _buildEndDate(),
              gapH8,
              _buildOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartDate() {
    return DateTimePicker(
      labelText: 'Start',
      selectedDate: _startDate,
      selectedTime: _startTime,
      onSelectedDate: (date) => setState(() => _startDate = date),
      onSelectedTime: (time) => setState(() => _startTime = time),
    );
  }

  Widget _buildEndDate() {
    return DateTimePicker(
      labelText: 'End',
      selectedDate: _endDate,
      selectedTime: _endTime,
      onSelectedDate: (date) => setState(() => _endDate = date),
      onSelectedTime: (time) => setState(() => _endTime = time),
    );
  }

  Widget _buildDuration() {
    final durationInHours = end.difference(start).inMinutes.toDouble() / 60.0;
    final durationFormatted = Format.hours(durationInHours);
    //state
    final currentTime = DateTime.now();
    final isExpired = currentTime.isAfter(end);
    final isInProgress =
        currentTime.isAfter(start) && currentTime.isBefore(end);

    String state;
    if (isExpired) {
      state = 'Expired';
    } else if (isInProgress) {
      state = 'In Progress';
    } else {
      final remainingTime = start.difference(currentTime);
      final remainingHours = remainingTime.inHours;
      state = 'Will start in $remainingHours hours';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Duration: $durationFormatted',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          Text(
            'State: $state',
            style: TextStyle(fontSize: 16.0, color: _getStateColor(state)),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'Expired':
        return Colors.red;
      case 'In Progress':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _buildComment() {
    return TextField(
      keyboardType: TextInputType.text,
      maxLength: 50,
      controller: TextEditingController(text: _comment),
      decoration: const InputDecoration(
        labelText: 'Content',
        labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      keyboardAppearance: Brightness.light,
      style: const TextStyle(fontSize: 20.0, color: Colors.black),
      maxLines: null,
      onChanged: (comment) => _comment = comment,
    );
  }
}

Widget _buildOptions() {
  return Column(
    children: <Widget>[
      _buildOptionField('Option 1'),
      SizedBox(height: 8.0),
      _buildOptionField('Option 2'),
      SizedBox(height: 8.0),
      _buildOptionField('Option 3'),
      SizedBox(height: 8.0),
      _buildOptionField('Option 4'),
    ],
  );
}

Widget _buildOptionField(String option) {
  return TextField(
    decoration: InputDecoration(
      labelText: option,
      labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
    ),
    keyboardAppearance: Brightness.light,
    style: TextStyle(fontSize: 20.0, color: Colors.black),
    onChanged: (value) {
      // Handle the changed value
    },
  );
}
