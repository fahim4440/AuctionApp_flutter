import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class FirebaseAuthentication {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> signinWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication?.accessToken,
      idToken: googleSignInAuthentication?.idToken,
    );
    final authResult = await _auth.signInWithCredential(credential);
    final user = authResult.user;
    return UserModel(user?.email, user?.displayName, user?.photoURL, user?.uid);
  }

  signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}