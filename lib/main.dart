// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

User? user;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int load = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Google with Login and Logout',style: TextStyle(fontSize: 15),),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                load == 0 ? ElevatedButton(
                  onPressed: ()async{
                    setState(() {
                      load = 1;
                    });
                    await Firebase.initializeApp();
                    await service.signInwithGoogle();
                    user = FirebaseAuth.instance.currentUser;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile(),));
                    setState(() {
                      load = 0;
                    });
                  }, 
                  child: const Text("Google with Login")
                ) : const SizedBox()
              ],
            ),
          ),
          load == 1 ? 
          Center(
            child: Container(
              color: Colors.black.withOpacity(0.2),
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              child: const CircularProgressIndicator(),
            ),
          ) : const SizedBox()
        ],
      ),
    );
  }
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile",style: TextStyle(fontSize: 15),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              backgroundImage: NetworkImage(user!.photoURL.toString()),
            ),
            const SizedBox(height: 20,),
            Text(user!.email.toString(),style: const TextStyle(fontSize: 15,),),
            const SizedBox(height: 10,),
            Text(user!.displayName.toString(),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            const SizedBox(height: 20,),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: ()async{
                  await service.signOutFromGoogle();
                  Navigator.pop(context);
                }, 
                child: const Text("Logout")
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> signInwithGoogle() async {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
  }

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

FirebaseService service = FirebaseService();
