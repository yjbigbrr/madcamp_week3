import 'package:flutter/cupertino.dart';

import '../../server/model/Meetings.dart';
import '../../server/service/meetings_service.dart';
import '../profile/profile_view_model.dart';

class MeetingViewModel extends ChangeNotifier {
  final MeetingService meetingService;
  final ProfileViewModel profileViewModel;

  List<Meeting> _meetings = [];
  List<Meeting> get meetings => _meetings;

  MeetingViewModel(this.meetingService, this.profileViewModel);

  Future<void> fetchUserMeetings() async {
    try {
      final userId = profileViewModel.profile?.id ?? '';
      _meetings = await meetingService.getMeetings(userId);
      notifyListeners();
    } catch (error) {
      print('Failed to fetch meetings: $error');
    }
  }

  Future<void> joinMeeting(String meetingId) async {
    try {
      final userId = profileViewModel.profile?.id ?? '';
      await meetingService.joinMeeting(meetingId, userId);
      await fetchUserMeetings();
    } catch (error) {
      print('Failed to join meeting: $error');
    }
  }
}