import 'dart:async';

import 'package:cc_counter/helper/keys.dart';
import 'package:cc_counter/screen/finished.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CCCounter extends StatefulWidget {
  const CCCounter({super.key, required this.session});
  final RecordModel session;

  @override
  State<CCCounter> createState() => _CCCounterState();
}

class _CCCounterState extends State<CCCounter> {
  List<RecordModel> exercises = [];
  int currentDone = 0;
  late RecordModel currentExercise;
  RecordModel? nextExercise;
  int finishedSets = 0;
  Timer? durationTimer;
  FlutterTts flutterTts = FlutterTts();

  static const counterFontSize = 80.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    exercises = widget.session.get("expand.session_exercises_via_session");
    exercises.sort(
      (ea, eb) => ea
          .getIntValue("exercise_order")
          .compareTo(eb.getIntValue("exercise_order")),
    );
    currentExercise = exercises.first;
    nextExercise = exercises[1];
    finishedSets = widget.session.getIntValue("finished_sets");
    speakExerciseStart();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  Future speakRemain() async {
    final remain =
        currentExercise.getIntValue("expand.exercise.value") - currentDone;
    if (currentExercise.getStringValue("expand.exercise.type") == "duration") {
      if (currentDone % 10 == 0) {
        await flutterTts.speak(
          "${currentExercise.getStringValue("expand.exercise.name")}, $remain seconds remain",
        );
      }
    } else {
      await flutterTts.speak("$remain remain");
    }
  }

  Future speakExerciseStart({
    bool speakNext = false,
    bool speakFinished = false,
    bool speakSetFinished = false,
  }) async {
    var text = currentExercise.getStringValue("expand.exercise.name");
    if (speakNext) {
      text = "Next Exercise is $text";
    }
    if (speakFinished) {
      text = "Finished. $text";
    } else if (speakSetFinished) {
      text = "Finished and Set Completed. Please rest before next set. $text";
    }
    final value = currentExercise.getStringValue("expand.exercise.value");
    if (currentExercise.getStringValue("expand.exercise.type") == "duration") {
      text += ", $value seconds, press to start.";
    } else {
      text += ", $value moves.";
    }
    await flutterTts.speak(text);
  }

  void countOne() async {
    // check if is duration-based
    if (currentDone == 0 &&
        (durationTimer == null || !durationTimer!.isActive) &&
        currentExercise.getStringValue("expand.exercise.type") == "duration") {
      setState(() {
        durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            countOne();
          });
        });
      });
      flutterTts.speak("Started");
      return;
    }

    setState(() {
      currentDone += 1;
    });

    // next exercise
    if (currentExercise.getIntValue("expand.exercise.value") - currentDone ==
        0) {
      if (durationTimer != null) {
        durationTimer!.cancel();
        durationTimer = null;
      }

      // check if to next set
      if (exercises.indexOf(currentExercise) == exercises.length - 1) {
        // to next set
        setState(() {
          finishedSets += 1;
          currentExercise = exercises.first;
          nextExercise = exercises[1];
          currentDone = 0;
        });
        // update db: finished_set += 1
        final pb = GetIt.instance.get<PocketBase>();
        pb
            .collection(pbCollectionSessions)
            .update(widget.session.id, body: {"finished_sets": finishedSets});

        // check if exercise finished
        if (finishedSets == widget.session.get("exercise_sets") && mounted) {
          speakExerciseStart(speakNext: true, speakFinished: true);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => CCFinished()),
            (x) => true,
          );
          return;
        }

        // TODO: Add start set logic
        speakExerciseStart(speakNext: true, speakSetFinished: true);
        // return;
      } else {
        // not next set, go to next exercise
        final currentIndex = exercises.indexOf(currentExercise);
        setState(() {
          currentExercise = exercises[currentIndex + 1];
          nextExercise =
              currentIndex + 2 >= exercises.length
                  ? null
                  : exercises[currentIndex + 2];
          currentDone = 0;
        });
        speakExerciseStart(speakNext: true, speakFinished: true);
      }
    } else {
      speakRemain();
    }
  }

  Widget exerciseCounterDisplay() {
    late Widget counterText;
    Widget? hintText;
    if (currentExercise.getStringValue("expand.exercise.type") ==
        "repetition") {
      counterText = Text(
        "${currentExercise.getIntValue("expand.exercise.value") - currentDone}",
      );
    } else {
      if (durationTimer == null || !durationTimer!.isActive) {
        hintText = Text("Press To Start");
      }
      counterText = Text(
        Duration(
          seconds:
              currentExercise.getIntValue("expand.exercise.value") -
              currentDone,
        ).toString().split('.').first,
      );
    }

    return DefaultTextStyle(
      style: TextStyle(color: Colors.white, fontSize: counterFontSize),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${currentExercise.get("expand.exercise.name")}"),
            counterText,
            hintText ?? SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: countOne,
      onDoubleTap: countOne,
      onHorizontalDragEnd: (details) {
        countOne();
      },
      onVerticalDragEnd: (details) {
        countOne();
      },
      child: Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              exerciseCounterDisplay(),
              Positioned(
                top: 5.0,
                left: 5.0,
                child: Text(
                  "Remaing sets: ${widget.session.get("exercise_sets") - finishedSets}",
                ),
              ),
              Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Text(
                  nextExercise == null
                      ? "Set completed after this exercise"
                      : "Next Exercise: ${nextExercise?.get("expand.exercise.name")}",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
