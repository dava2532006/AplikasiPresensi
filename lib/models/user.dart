class User {
  final String _username;
  final String _password;
  final String _name;
  final String _position; 
  final String _email;   

  User(this._username, this._password, this._name, this._position, this._email);

  String get username => _username;
  String get password => _password;
  String get name => _name;
  String get position => _position;
  String get email => _email;
}