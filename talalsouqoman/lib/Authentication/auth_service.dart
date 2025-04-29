import 'package:talalsouqoman/imports.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get the current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return res.user;
    } catch (e) {
      print("Signup error: $e");
      return null;
    }
  }

  // Login with email and password
  Future<User?> login(String email, String password) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print("Signout error: $e");
    }
  }
}