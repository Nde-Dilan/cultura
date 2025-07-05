class UserCreationReq {
  String ? firstName;
  String ? lastName;
  String ? email;
  String ? password; 
  String ? learningLanguage;

  UserCreationReq({
      this.firstName,
      this.email,
      this.lastName,
      this.password,
      this.learningLanguage,
  });
}