import 'package:flutter/material.dart';

void main() {
  runApp(const CCCounter());
}

class CCCounter extends StatelessWidget {
  const CCCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardio Controller Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CCCounterHome(title: 'Cardio Controller Counter'),
    );
  }
}

class CCCounterHome extends StatefulWidget {
  const CCCounterHome({super.key, required this.title});

  final String title;

  @override
  State<CCCounterHome> createState() => _CCCounterHomeState();
}

class _CCCounterHomeState extends State<CCCounterHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const Text('Cardio Controller Counter')],
        ),
      ),
    );
  }
}
