import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_app/schedule/schedule_view_model.dart';
import 'package:soccer_app/schedule/schedule_model.dart';
import 'chat_page.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScheduleViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Schedule'),
        ),
        body: Consumer<ScheduleViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index - 3));
                      return GestureDetector(
                        onTap: () => viewModel.selectDate(date),
                        child: Container(
                          width: 80,
                          color: viewModel.selectedDate == date
                              ? Colors.blue
                              : Colors.grey,
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
                  child: ListView.builder(
                    itemCount: viewModel.matchesForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final match = viewModel.matchesForSelectedDate[index];
                      final now = DateTime.now();
                      final isBeforeStartTime =
                          match.startTime.difference(now).inMinutes > 60;
                      return ListTile(
                        leading: Icon(Icons.sports_soccer),
                        title: Text('${match.homeTeam} vs ${match.awayTeam}'),
                        subtitle: Text('${match.league} - ${match.startTime.hour}:${match.startTime.minute}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(matchId: match.toString()),
                              ),
                            );
                          },
                          child: Text('응원하기'),
                        ),
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
      ),
    );
  }
}

class MatchDetailPage extends StatelessWidget {
  final Match match;

  MatchDetailPage({required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Details'),
      ),
      body: Center(
        child: Text('Details for ${match.homeTeam} vs ${match.awayTeam}'),
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