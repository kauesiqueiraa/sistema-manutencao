import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/mecanico_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final MecanicoService _mecanicoService;
  bool _isLoading = false;
  String _error = '';
  AuthModel? _authModel;
  UserModel? _user;

  AuthViewModel(this._authService, this._userService, this._mecanicoService);

  bool get isLoading => _isLoading;
  String get error => _error;
  AuthModel? get authModel => _authModel;
  UserModel? get user => _user;
  bool get isAuthenticated => _authModel != null;

  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _authModel = await _authService.login(username, password);
      final userData = await _userService.getUserData(username, _authModel!.accessToken);
      final mecanico = await _mecanicoService.findMecanicoByUserId(userData.id);
      
      if (mecanico != null) {
        _user = UserModel(
          id: userData.id,
          nome: userData.nome,
          email: userData.email,
          setmanu: mecanico.setmanu,
          matricula: mecanico.matricula,
        );
      } else {
        _user = userData;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _authModel!.accessToken);
      await prefs.setString('refresh_token', _authModel!.refreshToken);
      await prefs.setString('username', username);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
    _authModel = null;
    _user = null;
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

      try {
        final userData = await _userService.getUserData(username, accessToken);
        final mecanico = await _mecanicoService.findMecanicoByUserId(userData.id);
        
        if (mecanico != null) {
          _user = UserModel(
            id: userData.id,
            nome: userData.nome,
            email: userData.email,
            setmanu: mecanico.setmanu,
            matricula: mecanico.matricula,
          );
        } else {
          _user = userData;
        }

        notifyListeners();
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    return false;
  }
} 


