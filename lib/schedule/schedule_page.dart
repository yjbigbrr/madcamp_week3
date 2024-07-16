import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart';
import 'package:soccer_app/schedule/schedule_detail_page.dart';
import 'package:soccer_app/schedule/schedule_view_model.dart';
import 'chat_page.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late ScheduleViewModel _viewModel;
  late ProfileViewModel _profileViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ScheduleViewModel>(context, listen: false);
    _profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("What time is it now??????????? ${DateTime.now()}");
      _viewModel.selectDate(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: Consumer<ScheduleViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = DateTime.now().add(Duration(days: index - 3));
                    final isSelected = viewModel.selectedDate.year == date.year &&
                        viewModel.selectedDate.month == date.month &&
                        viewModel.selectedDate.day == date.day;
                    return GestureDetector(
                      onTap: () {
                        viewModel.selectDate(date);
                      },
                      child: Container(
                        width: 80,
                        color: isSelected ? Colors.blue : Colors.grey,
                        child: Center(
                          child: Text(
                            '${date.month}/${date.day}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: viewModel.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: viewModel.matchesForSelectedDate.length,
                  itemBuilder: (context, index) {
                    final match = viewModel.matchesForSelectedDate[index];
                    final now = DateTime.now();
                    final startTime = match.startTime;
                    final oneHourBeforeStart = startTime.subtract(Duration(hours: 1));
                    final fourHoursAfterStart = startTime.add(Duration(hours: 4));

                    final isBeforeOneHour = now.isBefore(oneHourBeforeStart);
                    final isDuringMatch = !now.isBefore(startTime) && now.isBefore(fourHoursAfterStart);
                    final isAfterFourHours = now.isAfter(fourHoursAfterStart);

                    return ListTile(
                      leading: Icon(Icons.sports_soccer),
                      title: Text('${match.homeTeam} vs ${match.awayTeam}'),
                      subtitle: Text(
                          '${match.league} - ${match.startTime.toLocal().hour}:${match.startTime.toLocal().minute}'
                      ),
                      trailing: isBeforeOneHour
                          ? ElevatedButton(
                        onPressed: () async {
                          try {
                            await viewModel.addUserToWaitList(match.matchId);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관전 예약이 완료되었습니다.')));
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관전 예약에 실패했습니다.')));
                            }
                          }
                        },
                        child: Text('관전 예약'),
                      )
                          : isDuringMatch
                          ? ElevatedButton(
                        onPressed: () {
                          // Action for cheering
                          // Implement your cheering logic here
                        },
                        child: Text('응원하기'),
                      )
                          : Text('경기 종료', style: TextStyle(color: Colors.grey)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchDetailPage(match: match),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:soccer_app/schedule/schedule_view_model.dart';
// import 'package:soccer_app/schedule/schedule_model.dart';

// class SchedulePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => ScheduleViewModel(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Schedule'),
//         ),
//         body: Consumer<ScheduleViewModel>(
//           builder: (context, viewModel, child) {
//             return Column(
//               children: [
//                 Container(
//                   height: 100,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 7,
//                     itemBuilder: (context, index) {
//                       final date = DateTime.now().add(Duration(days: index - 3));
//                       return GestureDetector(
//                         onTap: () => viewModel.selectDate(date),
//                         child: Container(
//                           width: 80,
//                           color: viewModel.selectedDate == date
//                               ? Colors.blue
//                               : Colors.grey,
//                           child: Center(
//                             child: Text(
//                               '${date.month}/${date.day}',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: viewModel.matchesForSelectedDate.length,
//                     itemBuilder: (context, index) {
//                       final match = viewModel.matchesForSelectedDate[index];
//                       final now = DateTime.now();
//                       final isBeforeStartTime =
//                           match.startTime.difference(now).inMinutes > 60;
//                       return ListTile(
//                         leading: Icon(Icons.sports_soccer),
//                         title: Text('${match.homeTeam} vs ${match.awayTeam}'),
//                         subtitle: Text('${match.league} - ${match.startTime.hour}:${match.startTime.minute}'),
//                         trailing: ElevatedButton(
//                           onPressed: () {
//                             if (isBeforeStartTime) {
//                               // 관전 예약 기능 구현
//                             } else {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       SupportPage(match: match),
//                                 ),
//                               );
//                             }
//                           },
//                           child: Text(
//                               isBeforeStartTime ? '관전 예약' : '응원하기'),
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => MatchDetailPage(match: match),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class MatchDetailPage extends StatelessWidget {
//   final Match match;

//   MatchDetailPage({required this.match});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Match Details'),
//       ),
//       body: Center(
//         child: Text('Details for ${match.homeTeam} vs ${match.awayTeam}'),
//       ),
//     );
//   }
// }

// class SupportPage extends StatelessWidget {
//   final Match match;

//   SupportPage({required this.match});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Support ${match.homeTeam} vs ${match.awayTeam}'),
//       ),
//       body: Center(
//         child: Text('Support page for ${match.homeTeam} vs ${match.awayTeam}'),
//       ),
//     );
//   }
// }