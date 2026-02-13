import 'package:get/get.dart';
import '../feature/create_match/create_match_controller.dart';
import '../feature/match_rule/match_rule_controller.dart';
import '../feature/matches_list/my_matches_list_controller.dart';
import '../feature/resume_match/resume_match_controller.dart';
import '../feature/create_team/create_team_controller.dart';

class AppControllers {
  // Static final instances - initialized once, permanent in memory
  static final CreateMatchController createMatch =
      Get.put(CreateMatchController(), permanent: true);

  static final MatchController match =
      Get.put(MatchController(), permanent: true);

  static final MyMatchesController myMatches =
      Get.put(MyMatchesController(), permanent: true);

  static final ResumeMatchController resumeMatch =
      Get.put(ResumeMatchController(), permanent: true);

  static final CreateTeamController createTeam =
      Get.put(CreateTeamController(), permanent: true);
}
