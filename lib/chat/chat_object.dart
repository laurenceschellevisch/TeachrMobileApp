class ChatroomData {
  //db values
  final int chatroomID;
  final int jobID;
  final int teacherID;
  final int userID;

  //json values
  final String teacherName;
  final String jobTitle;
  final String schoolName;
  final String avatar;

  ChatroomData(
      {this.chatroomID,
      this.jobID,
      this.teacherID,
      this.userID,
      this.teacherName,
      this.jobTitle,
      this.schoolName,
      this.avatar});
}
