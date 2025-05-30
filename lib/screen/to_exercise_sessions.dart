import 'package:cc_counter/helper/keys.dart';
import 'package:cc_counter/screen/exercise_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';

class CCToExerciseSessions extends StatefulWidget {
  const CCToExerciseSessions({super.key});

  @override
  State<CCToExerciseSessions> createState() => _CCToExerciseSessionsState();
}

class _CCToExerciseSessionsState extends State<CCToExerciseSessions> {
  List<RecordModel> sessions = [];

  Future<void> fetchOngoingSessions() async {
    final pb = GetIt.instance.get<PocketBase>();

    var result = await pb
        .collection(pbCollectionSessions)
        .getList(
          page: 1,
          perPage: 100,
          filter: ' exercise_sets > finished_sets',
          expand: 'game',
          sort: '-created',
        );
    setState(() {
      sessions = result.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchOngoingSessions();
    return Scaffold(
      appBar: AppBar(title: Text("To Exercise Sessions")),
      body: SafeArea(
        child: Column(
          children:
              sessions.isEmpty
                  ? [Center(child: Text("No Sessions to exercise"))]
                  : sessions.map((s) {
                    return Card(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${s.get('expand.game.title')}"),
                            Text(s.get("created").toString().split(' ').first),
                          ],
                        ),
                        subtitle: Table(
                          children: [
                            TableRow(
                              children: [
                                Text("Gameplay Metrics"),
                                s.getBoolValue("exercise_videos_checked")
                                    ? Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    )
                                    : Icon(
                                      Icons.highlight_off_outlined,
                                      color: Colors.red,
                                    ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text("Exercises"),
                                s.getBoolValue("exercises_checked")
                                    ? Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    )
                                    : Icon(
                                      Icons.highlight_off_outlined,
                                      color: Colors.red,
                                    ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text("Exercises Videos"),
                                s.getBoolValue("exercise_videos_checked")
                                    ? Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    )
                                    : Icon(
                                      Icons.highlight_off_outlined,
                                      color: Colors.red,
                                    ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text("Exercise Sets"),
                                Text(s.get("exercise_sets")),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text("Finished Sets"),
                                Text("${s.get("finished_sets")}"),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CCExerciseList(session: s),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
        ),
      ),
    );
  }
}
