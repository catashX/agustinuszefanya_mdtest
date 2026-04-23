import 'package:google_sign_in/google_sign_in.dart';
import 'dart:mirrors';

void main() {
  // We can't use mirrors in Flutter easily, but let's try a different approach.
  // Let's just try to access common names and see what sticks.
  var auth = GoogleSignInAuthentication;
  print('Checking GoogleSignInAuthentication...');
}
