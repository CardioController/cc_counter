import 'package:cc_counter/helper/pb.dart';
import 'package:cc_counter/screen/to_exercise_sessions.dart';
import 'package:flutter/material.dart';

class CCLogin extends StatefulWidget {
  const CCLogin({super.key});

  @override
  State<CCLogin> createState() => _CCLoginState();
}

class _CCLoginState extends State<CCLogin> {
  bool handling = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final pbAddrController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    pbAddrController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    setState(() {
      handling = true;
    });
    debugPrint("Handling");
    final loginSuccess = await tryLogin(
      pbAddrController.text,
      emailController.text,
      passwordController.text,
    );
    if (loginSuccess) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => CCToExerciseSessions()),
          (r) => false,
        );
      }
    } else {
      if (mounted) {
        const snackbar = SnackBar(
          content: Text('Login credentials incorrect, please retry'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }

    setState(() {
      handling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Cardio Controller Login"),
      ),
      body: Form(
        key: formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Column(
                  children: [
                    ListTile(
                      title: TextFormField(
                        controller: pbAddrController,
                        decoration: InputDecoration(
                          label: Row(
                            children: [
                              Text("Server Address "),
                              Text("*", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          hintText: "https://frontend.cardio.controller",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          label: Row(
                            children: [
                              Text("Email "),
                              Text("*", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          hintText: "musle@cardiocontroller.com",
                        ),
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          label: Row(
                            children: [
                              Text("Password "),
                              Text("*", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState != null &&
                          formKey.currentState!.validate() &&
                          !handling) {
                        handleSubmit();
                      }
                    },
                    child:
                        handling
                            ? const CircularProgressIndicator()
                            : const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
