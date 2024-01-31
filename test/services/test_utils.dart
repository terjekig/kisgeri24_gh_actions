import 'package:kisgeri24/data/models/user.dart';
import 'package:kisgeri24/data/dto/user_dto.dart';

final User testUser = User(
    email: "someUser@email.com",
    category: "24H",
    firstClimberName: "First Test Climber",
    secondClimberName: "Second Test Climber",
    teamName: "Awesome Test Team",
    tenantId: "Some More Awesome Tenant ID",
    userID: "Even More Awesome User ID");

final UserDto testUserAsDto = UserDto.all(
    testUser.email,
    testUser.firstClimberName,
    testUser.secondClimberName,
    testUser.userID,
    testUser.teamName,
    testUser.category,
    testUser.appIdentifier,
    testUser.startTime,
    testUser.tenantId,
    testUser.yearId,
    testUser.enabled);
