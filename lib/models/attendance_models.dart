import 'package:intl/intl.dart';

class DtrRecordModel {
  final String id;
  final String idEnroll;
  final String dated;
  final String timeIn;
  final String timeOut;
  final String paid;
  final String label;
  final String remarks;
  final String programName;
  final String branchName;

  DtrRecordModel({
    required this.id,
    required this.idEnroll,
    required this.dated,
    required this.timeIn,
    required this.timeOut,
    required this.paid,
    required this.label,
    required this.remarks,
    required this.programName,
    required this.branchName,
  });

  factory DtrRecordModel.fromJson(Map<String, dynamic> json) {
    return DtrRecordModel(
      id: json['id']?.toString() ?? '',
      idEnroll: json['id_enroll']?.toString() ?? '',
      dated: json['dated']?.toString() ?? '',
      timeIn: json['t_in']?.toString() ?? '',
      timeOut: json['t_out']?.toString() ?? '',
      paid: json['paid']?.toString() ?? '0.00',
      label: json['label']?.toString() ?? 'Workout Day',
      remarks: json['remarks']?.toString() ?? '',
      programName: json['program']?.toString() ?? 'N/A',
      branchName: json['branch']?.toString() ?? 'N/A',
    );
  }

  // Check if session is complete (has time-out)
  bool get isComplete => timeOut.isNotEmpty;

  // Check if session is paid
  bool get isPaid {
    final amount = double.tryParse(paid) ?? 0.0;
    return amount > 0;
  }

  // Get formatted date (e.g., "Oct 24, 2025")
  String get formattedDate {
    try {
      final date = DateTime.parse(dated);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dated;
    }
  }

  // Get day of week (e.g., "Monday")
  String get dayOfWeek {
    try {
      final date = DateTime.parse(dated);
      return DateFormat('EEEE').format(date);
    } catch (e) {
      return '';
    }
  }

  // Get formatted time in (e.g., "06:30 AM")
  String get formattedTimeIn {
    return timeIn.isEmpty ? '--:--' : timeIn;
  }

  // Get formatted time out (e.g., "08:00 AM")
  String get formattedTimeOut {
    return timeOut.isEmpty ? '--:--' : timeOut;
  }

  // Calculate duration in hours and minutes
  String get duration {
    if (timeIn.isEmpty || timeOut.isEmpty) return '--';

    try {
      // Parse time strings (format: "HH:MM:SS" or "HH:MM AM/PM")
      final inParts = _parseTime(timeIn);
      final outParts = _parseTime(timeOut);

      if (inParts == null || outParts == null) return '--';

      final inMinutes = inParts[0] * 60 + inParts[1];
      final outMinutes = outParts[0] * 60 + outParts[1];

      int diffMinutes = outMinutes - inMinutes;
      if (diffMinutes < 0) diffMinutes += 24 * 60; // Handle overnight sessions

      final hours = diffMinutes ~/ 60;
      final minutes = diffMinutes % 60;

      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return '--';
    }
  }

  // Helper to parse time string
  List<int>? _parseTime(String time) {
    try {
      // Remove AM/PM and trim
      time = time.replaceAll(RegExp(r'[APM\s]'), '').trim();

      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return [hour, minute];
      }
    } catch (e) {
      // Ignore parse errors
    }
    return null;
  }

  // Get duration in minutes (for statistics)
  int get durationInMinutes {
    if (timeIn.isEmpty || timeOut.isEmpty) return 0;

    try {
      final inParts = _parseTime(timeIn);
      final outParts = _parseTime(timeOut);

      if (inParts == null || outParts == null) return 0;

      final inMinutes = inParts[0] * 60 + inParts[1];
      final outMinutes = outParts[0] * 60 + outParts[1];

      int diffMinutes = outMinutes - inMinutes;
      if (diffMinutes < 0) diffMinutes += 24 * 60;

      return diffMinutes;
    } catch (e) {
      return 0;
    }
  }
}

class AttendanceStatsModel {
  final int totalSessions;
  final int completedSessions;
  final int currentMonthSessions;
  final double totalHours;
  final double totalPaid;
  final int currentStreak;
  final String mostFrequentWorkout;

  AttendanceStatsModel({
    required this.totalSessions,
    required this.completedSessions,
    required this.currentMonthSessions,
    required this.totalHours,
    required this.totalPaid,
    required this.currentStreak,
    required this.mostFrequentWorkout,
  });

  factory AttendanceStatsModel.fromRecords(List<DtrRecordModel> records) {
    final now = DateTime.now();

    int totalSessions = records.length;
    int completedSessions = records.where((r) => r.isComplete).length;
    int currentMonthSessions = records.where((r) {
      try {
        final date = DateTime.parse(r.dated);
        return date.year == now.year && date.month == now.month;
      } catch (e) {
        return false;
      }
    }).length;

    double totalMinutes = 0;
    for (var record in records) {
      totalMinutes += record.durationInMinutes;
    }
    double totalHours = totalMinutes / 60;

    double totalPaid = 0;
    for (var record in records) {
      totalPaid += double.tryParse(record.paid) ?? 0.0;
    }

    // Calculate streak (consecutive days with attendance)
    int streak = _calculateStreak(records);

    // Find most frequent workout label
    Map<String, int> labelCount = {};
    for (var record in records) {
      labelCount[record.label] = (labelCount[record.label] ?? 0) + 1;
    }
    String mostFrequent = 'N/A';
    int maxCount = 0;
    labelCount.forEach((label, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = label;
      }
    });

    return AttendanceStatsModel(
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      currentMonthSessions: currentMonthSessions,
      totalHours: totalHours,
      totalPaid: totalPaid,
      currentStreak: streak,
      mostFrequentWorkout: mostFrequent,
    );
  }

  static int _calculateStreak(List<DtrRecordModel> records) {
    if (records.isEmpty) return 0;

    // Sort records by date descending
    final sorted = List<DtrRecordModel>.from(records);
    sorted.sort((a, b) {
      try {
        return DateTime.parse(b.dated).compareTo(DateTime.parse(a.dated));
      } catch (e) {
        return 0;
      }
    });

    int streak = 0;
    DateTime? lastDate;

    for (var record in sorted) {
      try {
        final date = DateTime.parse(record.dated);
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (lastDate == null) {
          // First record - check if it's today or yesterday
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));

          if (dateOnly == today || dateOnly == yesterday) {
            streak = 1;
            lastDate = dateOnly;
          } else {
            break; // Streak broken
          }
        } else {
          // Check if this date is exactly one day before last date
          final expectedDate = lastDate.subtract(const Duration(days: 1));
          if (dateOnly == expectedDate) {
            streak++;
            lastDate = dateOnly;
          } else if (dateOnly == lastDate) {
            // Same day, multiple sessions - don't increment but continue
            continue;
          } else {
            break; // Streak broken
          }
        }
      } catch (e) {
        break;
      }
    }

    return streak;
  }
}
