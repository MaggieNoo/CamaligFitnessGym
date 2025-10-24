class EnrollmentInfoModel {
  final String id;
  final String amount;
  final String paid;
  final String duration;
  final String sessions;
  final String ended;
  final String endDate;
  final String branch;
  final String trainor;
  final String program;
  final int sessionsConsumed;
  final double totalPaid;

  EnrollmentInfoModel({
    required this.id,
    required this.amount,
    required this.paid,
    required this.duration,
    required this.sessions,
    required this.ended,
    required this.endDate,
    required this.branch,
    required this.trainor,
    required this.program,
    required this.sessionsConsumed,
    required this.totalPaid,
  });

  factory EnrollmentInfoModel.fromJson(Map<String, dynamic> json) {
    // Parse "con" field: "5^^^250.00" -> sessions^^^amount
    // Handle empty string or missing "con" field
    final conValue = json['con']?.toString() ?? '';
    final conParts = conValue.isEmpty ? ['0', '0'] : conValue.split('^^^');
    final sessions = int.tryParse(conParts[0]) ?? 0;
    final paid =
        conParts.length > 1 ? (double.tryParse(conParts[1]) ?? 0.0) : 0.0;

    return EnrollmentInfoModel(
      id: json['id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      paid: json['paid']?.toString() ?? '0.00',
      duration: json['dur']?.toString() ?? '0',
      sessions: json['ses']?.toString() ?? '0',
      ended: json['ended']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      branch: json['branch']?.toString() ?? 'N/A',
      trainor: json['trainor']?.toString() ?? 'No Trainor',
      program: json['program']?.toString() ?? 'N/A',
      sessionsConsumed: sessions,
      totalPaid: paid,
    );
  }

  bool get isEnrolled => id.isNotEmpty;

  // Check if this enrollment uses sessions (Consumable programs)
  bool get hasSessionTracking {
    final total = int.tryParse(sessions) ?? 0;
    return total > 0;
  }

  int get remainingSessions {
    final total = int.tryParse(sessions) ?? 0;
    return total > 0 ? total - sessionsConsumed : 0;
  }

  String get sessionsDisplay {
    if (!hasSessionTracking) return 'N/A';
    return '$sessionsConsumed/$sessions';
  }

  String get remainingSessionsDisplay {
    if (!hasSessionTracking) return 'N/A';
    return remainingSessions.toString();
  }

  double get remainingBalance {
    final total = double.tryParse(amount) ?? 0.0;
    final paidAmount = double.tryParse(paid) ?? 0.0;
    return total - paidAmount - totalPaid;
  }

  // Get complete total paid including enrollment payment
  double get completeTotalPaid {
    final paidAmount = double.tryParse(paid) ?? 0.0;
    return paidAmount + totalPaid;
  }

  int get daysLeft {
    if (ended.isEmpty) return 0;
    try {
      // Parse the ended date which is in MySQL format (YYYY-MM-DD)
      final end = DateTime.parse(ended);
      final now = DateTime.now();
      // Calculate days difference (only date part, ignore time)
      final endDateOnly = DateTime(end.year, end.month, end.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      final diff = endDateOnly.difference(nowDateOnly).inDays;
      return diff > 0 ? diff : 0;
    } catch (e) {
      print('❌ Error parsing ended date: $ended - $e');
      return 0;
    }
  }

  // Check if enrollment is expired
  bool get isExpired {
    if (ended.isEmpty) return false;
    try {
      final end = DateTime.parse(ended);
      final now = DateTime.now();
      final endDateOnly = DateTime(end.year, end.month, end.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      return endDateOnly.isBefore(nowDateOnly);
    } catch (e) {
      return false;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String dated;
  final String title;
  final String description;
  final String userName;
  final String? userImage;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.dated,
    required this.title,
    required this.description,
    required this.userName,
    this.userImage,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      dated: json['dated']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['des']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? 'Admin',
      userImage: json['image'],
    );
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(dated);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          return '${diff.inMinutes} minutes ago';
        }
        return '${diff.inHours} hours ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return dated;
      }
    } catch (e) {
      return dated;
    }
  }
}

class DtrEventModel {
  final String id;
  final String dated;
  final String timeIn;
  final String timeOut;
  final String label;
  final String remarks;

  DtrEventModel({
    required this.id,
    required this.dated,
    required this.timeIn,
    required this.timeOut,
    required this.label,
    required this.remarks,
  });

  factory DtrEventModel.fromJson(Map<String, dynamic> json) {
    return DtrEventModel(
      id: json['id']?.toString() ?? '',
      dated: json['dated']?.toString() ?? '',
      timeIn: json['tin']?.toString() ?? '',
      timeOut: json['tout']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Workout Day',
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  bool get hasTimeIn => timeIn.isNotEmpty;
  bool get hasTimeOut => timeOut.isNotEmpty;
}
