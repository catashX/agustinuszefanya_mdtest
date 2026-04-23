import 'package:google_sign_in/google_sign_in.dart';

void main() {
  try {
    print(GoogleSignIn.instance);
  } catch (e) {
    print(e);
  }
}
