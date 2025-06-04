import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  String? _error;
  AuthModel? _authModel;
  UserModel? _userModel;
  String? _username;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthModel? get authModel => _authModel;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _authModel != null;

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      _username = username;
      notifyListeners();

      _authModel = await _authService.login(username, password);
      
      // Buscar dados do usuário
      _userModel = await _userService.getUserData(username, _authModel!.accessToken);
      
      // Salvar token no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _authModel!.accessToken);
      await prefs.setString('refresh_token', _authModel!.refreshToken);
      await prefs.setString('username', username);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
    _authModel = null;
    _userModel = null;
    _username = null;
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');
    final username = prefs.getString('username');

    if (accessToken != null && refreshToken != null && username != null) {
      _authModel = AuthModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        scope: 'default',
        tokenType: 'Bearer',
        expiresIn: 30,
      );
      _username = username;

      try {
        _userModel = await _userService.getUserData(username, accessToken);
      } catch (e) {
        // Se não conseguir buscar os dados do usuário, faz logout
        await logout();
        return false;
      }

      notifyListeners();
      return true;
    }
    return false;
  }
} 

