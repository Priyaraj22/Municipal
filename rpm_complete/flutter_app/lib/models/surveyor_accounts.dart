// models/surveyor_accounts.dart

class SurveyorAccount {
  final String username;
  final String password;

  const SurveyorAccount(this.username, this.password);
}

// List of 20 predefined default accounts (user1 to user20)
const List<SurveyorAccount> SURVEYOR_ACCOUNTS = [
  SurveyorAccount('user1', 'rpm1'),
  SurveyorAccount('user2', 'rpm2'),
  SurveyorAccount('user3', 'rpm3'),
  SurveyorAccount('user4', 'rpm4'),
  SurveyorAccount('user5', 'rpm5'),
  SurveyorAccount('user6', 'rpm6'),
  SurveyorAccount('user7', 'rpm7'),
  SurveyorAccount('user8', 'rpm8'),
  SurveyorAccount('user9', 'rpm9'),
  SurveyorAccount('user10', 'rpm10'),
  SurveyorAccount('user11', 'rpm11'),
  SurveyorAccount('user12', 'rpm12'),
  SurveyorAccount('user13', 'rpm13'),
  SurveyorAccount('user14', 'rpm14'),
  SurveyorAccount('user15', 'rpm15'),
  SurveyorAccount('user16', 'rpm16'),
  SurveyorAccount('user17', 'rpm17'),
  SurveyorAccount('user18', 'rpm18'),
  SurveyorAccount('user19', 'rpm19'),
  SurveyorAccount('user20', 'rpm20'),
];
