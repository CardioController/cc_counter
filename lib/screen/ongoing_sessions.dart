import 'package:cc_counter/helper/keys.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';

class CCOnGoingSessions extends StatefulWidget {
  const CCOnGoingSessions({super.key});

  @override
  State<CCOnGoingSessions> createState() => _CCOnGoingSessionsState();
}

class _CCOnGoingSessionsState extends State<CCOnGoingSessions> {
  List<RecordModel> sessions = [];

  Future<void> fetchOngoingSessions() async {
    final pb = GetIt.instance.get<PocketBase>();

    var result = await pb
        .collection(pbCollectionSessions)
        .getList(
          page: 1,
          perPage: 100,
          filter:
              'session_metric_stage!="finished" || video_process_stage !="finished"',
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
      appBar: AppBar(title: Text("Ongoing Sesisons")),
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          children:
              sessions.map((s) {
                return Card(
                  child: ListTile(
                    title: Text("H"),
                    onTap: () {}, //
                  ), //
                );
              }).toList(),
        ),
      ),
    );
  }
}
