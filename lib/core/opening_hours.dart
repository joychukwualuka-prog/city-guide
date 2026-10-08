// lib/core/opening_hours.dart
//
// Expected Firestore shape on each attraction:
//   openingHours: { mon: "09:00-22:00", tue: "09:00-22:00", ...,
//                   sat: "10:00-02:00", sun: "closed" }
// Allowed values: "HH:mm-HH:mm", "24h", "closed".
// Overnight ranges (close earlier than open) are supported.

const _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// Returns true if the place is open at [now].
/// Returns false when there is no usable hours data.
bool isOpenNow(Map<String, String>? hours, DateTime now) {
  if (hours == null || hours.isEmpty) return false;

  final todayKey = _dayKeys[now.weekday - 1];
  final yesterdayKey = _dayKeys[(now.weekday + 5) % 7];
  final nowMin = now.hour * 60 + now.minute;

  // Today's range.
  final today = _parse(hours[todayKey]);
  if (today != null) {
    if (today.is24h) return true;
    if (today.close > today.open) {
      if (nowMin >= today.open && nowMin < today.close) return true;
    } else {
      // Overnight: open until midnight today, closes tomorrow.
      if (nowMin >= today.open) return true;
    }
  }

  // Yesterday's overnight range spilling into this morning.
  final yesterday = _parse(hours[yesterdayKey]);
  if (yesterday != null && !yesterday.is24h && yesterday.close <= yesterday.open) {
    if (nowMin < yesterday.close) return true;
  }

  return false;
}

class _Range {
  final int open;
  final int close;
  final bool is24h;
  const _Range(this.open, this.close, {this.is24h = false});
}

_Range? _parse(String? raw) {
  if (raw == null) return null;
  final v = raw.trim().toLowerCase();
  if (v.isEmpty || v == 'closed') return null;
  if (v == '24h') return const _Range(0, 0, is24h: true);

  final parts = v.split('-');
  if (parts.length != 2) return null;
  final open = _toMinutes(parts[0]);
  final close = _toMinutes(parts[1]);
  if (open == null || close == null) return null;
  return _Range(open, close);
}

int? _toMinutes(String hhmm) {
  final p = hhmm.trim().split(':');
  if (p.length != 2) return null;
  final h = int.tryParse(p[0]);
  final m = int.tryParse(p[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}

/// Uses structured [weekly] hours when present, otherwise tries to read
/// the display [text] (e.g. "9AM - 6PM Daily", "9:00 AM - 10:00 PM",
/// "Open 24 hours"). Returns false when nothing can be understood.
bool isAttractionOpenNow({
  Map<String, String>? weekly,
  required String text,
  required DateTime now,
}) {
  if (weekly != null && weekly.isNotEmpty) return isOpenNow(weekly, now);
  return isOpenNowFromText(text, now);
}

/// Handles one time range applied every day. Day-specific text such as
/// "Mon-Fri 9-5, Sat 10-2" is not understood and counts as not open.
bool isOpenNowFromText(String text, DateTime now) {
  final t = text.trim().toLowerCase();
  if (t.isEmpty || t.startsWith('closed')) return false;
  if (t.contains('24 hours') || t.contains('24hrs') || t.contains('24/7') || t == '24h') {
    return true;
  }

  final m = RegExp(
    r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\s*(?:-|–|—|to)\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
  ).firstMatch(t);
  if (m == null) return false;

  final close = _clock(int.parse(m.group(4)!), m.group(5), m.group(6));
  var open = _clock(int.parse(m.group(1)!), m.group(2), m.group(3));

  // "9-6PM": the first time has no am/pm, so pick the reading that
  // comes before closing time.
  if (m.group(3) == null && m.group(6) != null && open >= close) {
    open = _clock(int.parse(m.group(1)!), m.group(2), 'am');
  }

  final nowMin = now.hour * 60 + now.minute;
  if (close > open) return nowMin >= open && nowMin < close;
  return nowMin >= open || nowMin < close; // overnight
}

int _clock(int hour, String? minute, String? meridiem) {
  var h = hour % 24;
  if (meridiem == 'pm' && h < 12) h += 12;
  if (meridiem == 'am' && h == 12) h = 0;
  return h * 60 + (int.tryParse(minute ?? '0') ?? 0);
}