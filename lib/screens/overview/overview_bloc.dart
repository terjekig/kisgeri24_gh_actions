import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kisgeri24/data/converter/route_route_dto_converter.dart';
import 'package:kisgeri24/data/converter/sector_sector_dto_converter.dart';
import 'package:kisgeri24/data/dto/challenge_view.dart';
import 'package:kisgeri24/data/dto/sector_dto.dart';
import 'package:kisgeri24/data/models/sector.dart';
import 'package:kisgeri24/data/models/user.dart';
import 'package:kisgeri24/data/models/year.dart';
import 'package:kisgeri24/data/notification/user_notification.dart';
import 'package:kisgeri24/data/repositories/challenge_repository.dart';
import 'package:kisgeri24/data/repositories/sector_repository.dart';
import 'package:kisgeri24/data/repositories/year_repository.dart';
import 'package:kisgeri24/logging.dart';
import 'package:kisgeri24/screens/overview/dto/overview_dto.dart';
import 'package:kisgeri24/services/authenticator.dart';
import 'package:kisgeri24/services/challenge_service.dart';
import 'package:kisgeri24/services/firebase_service.dart';
import 'package:kisgeri24/services/sector_service.dart';
import 'package:kisgeri24/services/year_service.dart';

part 'overview_event.dart';

part 'overview_state.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final Converter<Sector, SectorDto> sectorToSectorDtoConverter =
      SectorToSectorDtoConverter(RouteToRouteDtoConverter());

  OverviewBloc() : super(OverviewInitial()) {
    on<LoadDataEvent>((event, emit) async {
      await _load(timerStarted: event._timer == null).then((value) {
        emit(value);
      });
    });
  }

  Future<OverviewState> _load({bool? timerStarted = false}) async {
    try {
      List<SectorDto> routes = await fetchSectors();
      int userPoints = await fetchTeamPoints();
      final notifications = await fetchNotifications();
      final challenges = await fetchChallenges();
      final endTime = 0;

      final overviewData = OverviewDto(
          null, routes, userPoints, notifications, challenges, endTime);

      return LoadedState(overviewData);
    } catch (error) {
      return ErrorState('Failed to fetch data: ${error.toString()}');
    }
  }

  Future<List<SectorDto>> fetchSectors() async {
    List<SectorDto> dtos = [];
    List<Sector> sectors = await SectorService(SectorRepository(
            FirebaseSingletonProvider.instance.firestoreInstance))
        .getSectorsWithRoutes();
    logger
        .d('Converting ${sectors.length} Sector(s) to a list of SectorDto(s)');
    for (Sector sector in sectors) {
      dtos.add(sectorToSectorDtoConverter.convert(sector));
    }
    logger.d('${dtos.length} SectorDto got converted and about to return');
    return Future.value(dtos);
  }

  Future<int> fetchTeamPoints() {
    logger.d('collecting team points');
    return Future.value(1234);
  }

  Future<List<TeamNotification>> fetchNotifications() {
    logger.d('collecting notifications');
    return Future.value([]);
  }

  Future<List<ChallengeView>> fetchChallenges() {
    logger.d('collecting challenges');
    return ChallengeService(ChallengeRepository(
            FirebaseSingletonProvider.instance.firestoreInstance))
        .getViewsByYear('kzU99Z2APtOBhvNFgPvv');
  }

  Future<int?> getRemainingTimeIfTimerStarted() async {
    logger.d('calculating remaining time');
    Year yearData = await YearService(YearRepository(
            FirebaseSingletonProvider.instance.firestoreInstance))
        .getYearByTenantId('kzU99Z2APtOBhvNFgPvv'); // TODO: remove hardcoded tenantId
    User? currentUser = await Auth(FirebaseSingletonProvider.instance.authInstance, FirebaseSingletonProvider.instance.firestoreInstance).getAuthUser();
    if (currentUser != null) {
      logger.d('current user is: $currentUser');
      if (currentUser.startTime != null) {
        logger.d('current user has startTime: ${currentUser.startTime}');
        int remainingTime = yearData.compEnd! - currentUser.startTime!;
        logger.d('remaining time is: $remainingTime');
        return remainingTime;
      }
    }
    return Future.value(null);
  }
}
