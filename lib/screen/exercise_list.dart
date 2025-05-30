import 'package:cc_counter/helper/keys.dart';
import 'package:cc_counter/screen/counter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';

class CCExerciseList extends StatefulWidget {
  const CCExerciseList({super.key, required this.session});
  final RecordModel session;

  @override
  State<CCExerciseList> createState() => _CCExerciseListState();
}

class _CCExerciseListState extends State<CCExerciseList> {
  bool handlingFetch = true;
  List<RecordModel> exercises = [];
  late RecordModel expandedSession;

  Future<void> fetchExercises() async {
    final pb = GetIt.instance.get<PocketBase>();
    expandedSession = await pb
        .collection(pbCollectionSessions)
        .getOne(
          widget.session.id,
          expand:
              "session_exercises_via_session.exercise,session_metrics_via_session",
        );
    setState(() {
      exercises = expandedSession.get("expand.session_exercises_via_session");
      exercises.sort(
        (ea, eb) => ea
            .getIntValue("exercise_order")
            .compareTo(eb.getIntValue("exercise_order")),
      );
      debugPrint(exercises.length.toString());
      handlingFetch = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Widget exercisesList() {
    return Column(
      children: [
        const Divider(),
        ListTile(
          title: Text("Sets: ${widget.session.get("exercise_sets")}"), //
          subtitle: Text("Finished: ${widget.session.get("finished_sets")}"),
        ),
        const Divider(),
        ...exercises.map((e) {
          return ListTile(
            title: Text(e.get("expand.exercise.name")), //
            subtitle: Text(
              "${e.get("expand.exercise.value")} ${e.get("expand.exercise.type")}(s) per set",
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.session.get("created")}")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Game: ${widget.session.get("expand.game.title")}"),
          ),
          handlingFetch
              ? const Center(child: CircularProgressIndicator())
              : exercisesList(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: ListTile(
          title: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CCCounter(session: expandedSession),
                ),
              );
            },
            child: Text(
              widget.session.getIntValue("finished_sets") > 0
                  ? "Continue"
                  : "Start!",
            ),
          ),
        ),
      ),
    );
  }
}
