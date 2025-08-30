import 'dart:ui';
import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.locale = const Locale('en')]);

  @override
  String get appTitle => 'Salon Booking App';

  String get home => 'Home';

  String get booking => 'Booking';

  String get maps => 'Maps';

  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get bookAppointment => 'Book Appointment';

  String get selectService => 'Select Service';

  String get selectDate => 'Select Date';

  String get selectTime => 'Select Time';

  String get customerName => 'Customer Name';

  String get customerPhone => 'Phone Number';

  String get customerEmail => 'Email (Optional)';

  String get notes => 'Notes (Optional)';

  String get confirmBooking => 'Confirm Booking';

  String get bookingSuccess => 'Booking confirmed successfully!';

  String get bookingError => 'Error creating booking. Please try again.';

  String get loading => 'Loading...';

  String get error => 'Error';

  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  String get ok => 'OK';

  @override
  String get save => 'Save';

  String get delete => 'Delete';

  String get edit => 'Edit';

  String get search => 'Search';

  String get filter => 'Filter';

  String get sort => 'Sort';

  @override
  String get location => 'Location';

  String get address => 'Address';

  String get phone => 'Phone';

  String get email => 'Email';

  String get website => 'Website';

  String get about => 'About';

  String get contact => 'Contact';

  String get services => 'Services';

  String get workers => 'Workers';

  String get appointments => 'Appointments';

  String get history => 'History';

  String get upcoming => 'Upcoming';

  String get completed => 'Completed';

  String get cancelled => 'Cancelled';

  String get pending => 'Pending';

  String get confirmed => 'Confirmed';

  String get available => 'Available';

  String get unavailable => 'Unavailable';

  String get distance => 'Distance';

  String get duration => 'Duration';

  String get price => 'Price';

  String get total => 'Total';

  String get tax => 'Tax';

  String get discount => 'Discount';

  String get payment => 'Payment';

  String get payNow => 'Pay Now';

  String get payLater => 'Pay Later';

  String get online => 'Online';

  String get offline => 'Offline';

  String get connected => 'Connected';

  String get disconnected => 'Disconnected';

  String get noInternet => 'No Internet Connection';

  String get checkConnection =>
      'Please check your internet connection and try again.';

  String get tryAgain => 'Try Again';

  String get goBack => 'Go Back';

  String get continue_ => 'Continue';

  String get skip => 'Skip';

  String get next => 'Next';

  String get previous => 'Previous';

  String get finish => 'Finish';

  String get done => 'Done';

  String get close => 'Close';

  String get open => 'Open';

  String get closed => 'Closed';

  String get openingHours => 'Opening Hours';

  String get monday => 'Monday';

  String get tuesday => 'Tuesday';

  String get wednesday => 'Wednesday';

  String get thursday => 'Thursday';

  String get friday => 'Friday';

  String get saturday => 'Saturday';

  String get sunday => 'Sunday';

  String get today => 'Today';

  String get tomorrow => 'Tomorrow';

  String get yesterday => 'Yesterday';

  String get dateFormat => 'MM/dd/yyyy';

  String get timeFormat => 'hh:mm a';

  String get currencySymbol => '\$';

  String get currencyFormat => '\$#,##0.00';

  String get language => 'Language';

  String get english => 'English';

  String get spanish => 'Spanish';

  String get theme => 'Theme';

  String get light => 'Light';

  String get dark => 'Dark';

  String get system => 'System';

  String get notifications => 'Notifications';

  String get enableNotifications => 'Enable Notifications';

  String get reminderHours => 'Reminder Hours';

  String get privacy => 'Privacy';

  String get terms => 'Terms of Service';

  String get policy => 'Privacy Policy';

  String get help => 'Help';

  String get support => 'Support';

  String get feedback => 'Feedback';

  String get rateApp => 'Rate App';

  String get shareApp => 'Share App';

  String get logout => 'Logout';

  String get login => 'Login';

  String get register => 'Register';

  String get forgotPassword => 'Forgot Password?';

  String get resetPassword => 'Reset Password';

  String get changePassword => 'Change Password';

  String get currentPassword => 'Current Password';

  String get newPassword => 'New Password';

  String get confirmPassword => 'Confirm Password';

  String get passwordMismatch => 'Passwords do not match';

  String get invalidEmail => 'Invalid email address';

  String get invalidPhone => 'Invalid phone number';

  String get fieldRequired => 'This field is required';

  String get minLength => 'Minimum length is {count} characters';

  String get maxLength => 'Maximum length is {count} characters';

  String get invalidFormat => 'Invalid format';

  String get networkError => 'Network error. Please check your connection.';

  String get serverError => 'Server error. Please try again later.';

  String get unknownError => 'An unknown error occurred. Please try again.';

  String get permissionDenied => 'Permission denied';

  String get locationPermissionRequired =>
      'Location permission is required to show nearby services';

  String get cameraPermissionRequired =>
      'Camera permission is required to take photos';

  String get storagePermissionRequired =>
      'Storage permission is required to save files';

  String get notificationPermissionRequired =>
      'Notification permission is required to send reminders';

  String get enableLocation => 'Enable Location';

  String get enableCamera => 'Enable Camera';

  String get enableStorage => 'Enable Storage';

  String get enableNotifications_ => 'Enable Notifications';

  String get goToSettings => 'Go to Settings';

  String get later => 'Later';

  String get allow => 'Allow';

  String get deny => 'Deny';

  String get bookingReminder => 'Appointment Reminder';

  String get bookingReminderMessage =>
      'You have an appointment in {hours} hours';

  String get bookingConfirmed => 'Booking Confirmed';

  String get bookingConfirmedMessage =>
      'Your appointment has been confirmed for {date} at {time}';

  String get bookingCancelled => 'Booking Cancelled';

  String get bookingCancelledMessage =>
      'Your appointment for {date} at {time} has been cancelled';

  String get bookingUpdated => 'Booking Updated';

  String get bookingUpdatedMessage => 'Your appointment has been updated';

  String get welcome => 'Welcome';

  String get welcomeMessage => 'Welcome to our salon booking app';

  String get getStarted => 'Get Started';

  String get onboardingTitle1 => 'Find the Perfect Service';

  String get onboardingDesc1 =>
      'Browse through our wide range of beauty services';

  String get onboardingTitle2 => 'Book with Ease';

  String get onboardingDesc2 => 'Schedule appointments at your convenience';

  String get onboardingTitle3 => 'Track Your Appointments';

  String get onboardingDesc3 =>
      'Keep track of all your upcoming and past appointments';

  String get noBookings => 'No bookings found';

  String get noBookingsDesc =>
      'You haven\'t made any bookings yet. Start by booking a service!';

  String get noServices => 'No services available';

  String get noServicesDesc =>
      'No services are currently available. Please try again later.';

  String get noWorkers => 'No workers available';

  String get noWorkersDesc =>
      'No workers are currently available. Please try again later.';

  String get serviceUnavailable => 'Service Unavailable';

  String get serviceUnavailableDesc =>
      'This service is currently unavailable. Please choose another service.';

  String get workerUnavailable => 'Worker Unavailable';

  String get workerUnavailableDesc =>
      'This worker is currently unavailable. Please choose another worker.';

  String get timeSlotUnavailable => 'Time Slot Unavailable';

  String get timeSlotUnavailableDesc =>
      'This time slot is no longer available. Please choose another time.';

  String get bookingConflict => 'Booking Conflict';

  String get bookingConflictDesc =>
      'There is a conflict with your booking. Please choose a different time or service.';

  String get bookingLimitReached => 'Booking Limit Reached';

  String get bookingLimitReachedDesc =>
      'You have reached the maximum number of bookings allowed.';

  String get accountSuspended => 'Account Suspended';

  String get accountSuspendedDesc =>
      'Your account has been suspended. Please contact support.';

  String get maintenance => 'Maintenance';

  String get maintenanceDesc =>
      'The app is currently under maintenance. Please try again later.';

  String get updateRequired => 'Update Required';

  String get updateRequiredDesc =>
      'Please update the app to continue using it.';

  String get updateNow => 'Update Now';

  String get updateAvailable => 'Update Available';

  String get updateAvailableDesc =>
      'A new version of the app is available. Would you like to update?';

  String get whatsNew => 'What\'s New';

  String get version => 'Version';

  String get build => 'Build';

  String get releaseDate => 'Release Date';

  String get changelog => 'Changelog';

  String get bugFixes => 'Bug Fixes';

  String get improvements => 'Improvements';

  String get newFeatures => 'New Features';

  String get experimental => 'Experimental';

  String get beta => 'Beta';

  String get stable => 'Stable';

  String get development => 'Development';

  String get production => 'Production';

  String get debug => 'Debug';

  String get info => 'Info';

  String get warning => 'Warning';

  String get critical => 'Critical';

  String get error_ => 'Error';

  String get success => 'Success';

  String get failure => 'Failure';

  String get pending_ => 'Pending';

  String get processing => 'Processing';

  String get completed_ => 'Completed';

  String get failed => 'Failed';

  String get cancelled_ => 'Cancelled';

  String get expired => 'Expired';

  String get active => 'Active';

  String get inactive => 'Inactive';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  String get on => 'On';

  String get off => 'Off';

  String get yes => 'Yes';

  String get no => 'No';

  String get true_ => 'True';

  String get false_ => 'False';

  String get none => 'None';

  String get all => 'All';

  String get any => 'Any';

  String get other => 'Other';

  String get custom => 'Custom';

  String get default_ => 'Default';

  String get automatic => 'Automatic';

  String get manual => 'Manual';

  String get advanced => 'Advanced';

  String get basic => 'Basic';

  String get simple => 'Simple';

  String get complex => 'Complex';

  String get easy => 'Easy';

  String get hard => 'Hard';

  String get fast => 'Fast';

  String get slow => 'Slow';

  String get small => 'Small';

  String get medium => 'Medium';

  String get large => 'Large';

  String get short => 'Short';

  String get long => 'Long';

  String get high => 'High';

  String get low => 'Low';

  String get normal => 'Normal';

  String get priority => 'Priority';

  String get urgent => 'Urgent';

  String get important => 'Important';

  String get optional => 'Optional';

  String get required => 'Required';

  String get recommended => 'Recommended';

  String get suggested => 'Suggested';

  String get popular => 'Popular';

  String get trending => 'Trending';

  String get featured => 'Featured';

  String get new_ => 'New';

  String get hot => 'Hot';

  String get cool => 'Cool';

  String get warm => 'Warm';

  String get cold => 'Cold';

  String get fresh => 'Fresh';

  String get old => 'Old';

  String get recent => 'Recent';

  String get latest => 'Latest';

  String get oldest => 'Oldest';

  String get first => 'First';

  String get last => 'Last';

  String get next_ => 'Next';

  String get previous_ => 'Previous';

  String get current => 'Current';

  String get future => 'Future';

  String get past => 'Past';

  String get now => 'Now';

  String get soon => 'Soon';

  String get later_ => 'Later';

  String get ago => 'ago';

  String get fromNow => 'from now';

  String get justNow => 'just now';

  String get seconds => 'seconds';

  String get minutes => 'minutes';

  String get hours => 'hours';

  String get days => 'days';

  String get weeks => 'weeks';

  String get months => 'months';

  String get years => 'years';

  String get second => 'second';

  String get minute => 'minute';

  String get hour => 'hour';

  String get day => 'day';

  String get week => 'week';

  String get month => 'month';

  String get year => 'year';

  String plural(String word, int count) {
    if (count == 1) return word;
    return '${word}s';
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${plural('year', years)} $ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${plural('month', months)} $ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${plural('week', weeks)} $ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${plural('day', difference.inDays)} $ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${plural('hour', difference.inHours)} $ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${plural('minute', difference.inMinutes)} $ago';
    } else {
      return justNow;
    }
  }

  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${plural('day', duration.inDays)} ${duration.inHours % 24} ${plural('hour', duration.inHours % 24)}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${plural('hour', duration.inHours)} ${duration.inMinutes % 60} ${plural('minute', duration.inMinutes % 60)}';
    } else {
      return '${duration.inMinutes} ${plural('minute', duration.inMinutes)} ${duration.inSeconds % 60} ${plural('second', duration.inSeconds % 60)}';
    }
  }
}
