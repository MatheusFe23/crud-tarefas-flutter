/// Controller responsável pela lógica de autenticação.
///
/// Mantém credenciais fixas para fins didáticos.
/// Em produção, substitua por chamada a uma API ou banco seguro.
class AuthController {
  // Credenciais fixas — altere conforme necessário
  static const String _validUser = 'admin';
  static const String _validPassword = '1234';

  /// Verifica se as credenciais informadas são válidas.
  ///
  /// Retorna `true` se usuário e senha correspondem aos valores esperados.
  bool login(String username, String password) {
    return username.trim() == _validUser && password == _validPassword;
  }
}
