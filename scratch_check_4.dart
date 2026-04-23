import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  // This is just to check types
  GoogleSignInAccount? account;
  // Let's try common names
  print(account?.id);
  print(account?.email);
  print(account?.displayName);
  print(account?.photoUrl);
  print(account?.idToken);
  print(account?.serverAuthCode);
  print(account?.authorizationClient);
}
