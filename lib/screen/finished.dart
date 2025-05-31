import 'package:cc_counter/screen/to_exercise_sessions.dart';
import 'package:flutter/material.dart';

class CCFinished extends StatelessWidget {
  const CCFinished({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Finished"),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => CCToExerciseSessions()),
                  (x) => true,
                );
              },
              child: Text("Back to ongoing sessions"),
            ),
          ],
        ),
      ),
    );
  }
}
