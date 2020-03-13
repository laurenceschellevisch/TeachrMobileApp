class User {
// all fields in order from generate auth cookie:
  final int id;
  final int role;
  // final String username;
  // final String nicename;
  String email;
  // final String url;
  // final String registered;
  // final String displayname;
  String firstname;
  String lastname;
  // final String nickname;
  String description;
  String skillset;
  String avatar;

  User(this.id, this.role, this.email, this.firstname, this.lastname,
      this.description, this.skillset, this.avatar);

  User.fromJson(Map<String, dynamic> json)
      : id = json['user']['id'],
        role = json['user']['role'],
        email = json['user']['email'],
        firstname = json['user']['firstname'],
        lastname = json['user']['lastname'],
        description = json['user']['description'],
        skillset = json['user']['skillset'],
        avatar = json['avatar'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'email': email,
        'firstname': firstname,
        'lastname': lastname,
        'description': description,
        'skillset': skillset,
        'avatar': avatar
      };
}
