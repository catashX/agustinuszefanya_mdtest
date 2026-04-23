import 'package:google_sign_in/google_sign_in.dart';

void main() {
  // This is just to check types during analysis
  GoogleSignInAuthentication? auth;
  print(auth?.accessToken);
  print(auth?.idToken);
}
