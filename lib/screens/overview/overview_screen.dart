import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:kisgeri24/data/dto/challenge_view.dart';
import 'package:kisgeri24/data/dto/sector_dto.dart';
import 'package:kisgeri24/data/dto/wall_dto.dart';
import 'package:kisgeri24/logging.dart';
import 'package:kisgeri24/screens/challenge/challenges_screen.dart';
import 'package:kisgeri24/screens/common/bottom_nav_bar.dart';
import 'package:kisgeri24/screens/overview/dto/overview_dto.dart';
import 'package:kisgeri24/screens/overview/misc/slider_components.dart';
import 'package:kisgeri24/screens/overview/overview_bloc.dart';
import 'package:kisgeri24/screens/routes/routes_screen.dart';
import 'package:kisgeri24/screens/overview/popups/start_timer_overlay.dart';
import 'package:kisgeri24/ui/figma_design.dart' as kisgeri_design;

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  OverviewScreenState createState() => OverviewScreenState();
}

class OverviewScreenState extends State<OverviewScreen>
    with WidgetsBindingObserver {
  SliderCategory _selectedTab = SliderCategory.routes;
  final Map<SectorDto, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OverviewBloc(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: AppBar(
            centerTitle: true,
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu),
              color: kisgeri_design.Figma.colors.primaryColor,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: kisgeri_design.Figma.colors.primaryColor,
                ),
                onPressed: () {
                  logger.d('Notification button pressed.');
                },
              )
            ],
            title: Text('KISGERI24',
                style: kisgeri_design.Figma.typo.body.copyWith(
                    color: kisgeri_design.Figma.colors.primaryColor,
                    fontWeight: FontWeight.bold)),
            backgroundColor: kisgeri_design.Figma.colors.backgroundColor,
          ),
        ),
        bottomNavigationBar: const MainBottomNavigationBar(),
        body: BlocListener<OverviewBloc, OverviewState>(
          listenWhen: (previous, current) {
            return current != previous;
          },
          listener: (context, state) {
            /*logger.d('State in listener: $state');
            if (state is OverviewInitial) {
              context.read<OverviewBloc>().add(const LoadDataEvent());
            }*/
          },
          child: BlocBuilder<OverviewBloc, OverviewState>(
            builder: (context, state) {
              if (state is OverviewInitial) {
                context.read<OverviewBloc>().add(LoadDataEvent()); // init state happens upon start but timer could have been started already, this this value has to be checked beforehand (maybe stored in shared prefs)
              }
              if (state is LoadingState) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Color(0xFF1e1e1e),
                    color: Color(0xFF1e1e1e),
                  ),
                );
              } else if (state is LoadedState) {
                return getCompleteView(context, state.data);
              } else if (state is ErrorState) {
                return Center(
                    child: Text('Error: ${state.errorMessage}',
                        style: const TextStyle(
                            color: Colors.red, fontStyle: FontStyle.italic)));
              }

              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color(0xff181305),
                  color: Color(0xFFFFBA00),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getCompleteView(BuildContext context, OverviewDto dto) {
    return ListView(
        scrollDirection: Axis.vertical,
        primary: false,
        shrinkWrap: true,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Text('Áttekintő',
                  style: kisgeri_design.Figma.typo.header2.copyWith(
                    color: kisgeri_design.Figma.colors.secondaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: kisgeri_design.Figma.colors.secondaryColor,
                  )),
              const SizedBox(height: 30),
              getPointsOrStartSection(context, dto),
              const SizedBox(height: 30),
              CustomSlidingSegmentedControl<SliderCategory>(
                fixedWidth: 172.0,
                // 152.0?
                initialValue: _selectedTab,
                children: {
                  SliderCategory.routes: Text(
                    SliderCategory.routes.value,
                    style: SliderCategory.routes.getTextStyle(_selectedTab),
                  ),
                  SliderCategory.challenges: Text(
                    SliderCategory.challenges.value,
                    style: SliderCategory.challenges.getTextStyle(_selectedTab),
                  ),
                },
                decoration: BoxDecoration(
                    color: kisgeri_design.Figma.colors.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kisgeri_design.Figma.colors.primaryColor,
                      style: BorderStyle.solid,
                    )),
                thumbDecoration: BoxDecoration(
                  color: kisgeri_design.Figma.colors.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) {
                  setState(() {
                    logger.d(
                        'slider value changed from ${_selectedTab.value} to ${v.value}');
                    _selectedTab = v;
                  });
                },
              ),
              const SizedBox(height: 20),
              getContentBasedOnSliderValue(dto),
            ],
          )
        ]);
  }

  Widget getContentBasedOnSliderValue(OverviewDto dto) {
    if (_selectedTab == SliderCategory.routes) {
      return SizedBox(
        width: 350,
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  dto.sectors.map((route) => buildSectorCard(route)).toList()),
        ),
      );
    }
    return SizedBox(
        width: 310,
        child: Center(
          child: composeChallengeView(dto),
        ));
  }

  Column composeChallengeView(OverviewDto dto) {
    List<Widget> elements = [];
    for (var element in dto.challenges) {
      elements.add(const SizedBox(height: 20));
      elements.add(buildChallengeCard(element));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...elements],
    );
  }

  Row buildChallengeCard(ChallengeView challenge) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        challenge.name,
        style: kisgeri_design.Figma.typo.body.copyWith(
          color: kisgeri_design.Figma.colors.secondaryColor,
        ),
      ),
      InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChallengesScreen(challenge)),
            );
          },
          child: Icon(
            kisgeri_design.Figma.icons.edit,
            color: kisgeri_design.Figma.colors.secondaryColor,
          )),
    ]);
  }

  Widget getPointsOrStartSection(BuildContext context, OverviewDto dto) {
    if (dto.started != null) {
      return getPointsAndCountdownSection(dto);
    }
    return getStartTimeSection(context);
  }

  Widget getPointsAndCountdownSection(OverviewDto dto) {
    return const Text('data');
  }

  Widget getStartTimeSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'A gomb megnyomásával elindítjátok a számlálót',
          style: TextStyle(
            fontFamily: "Lato",
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: kisgeri_design.Figma.colors.secondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 240,
          height: 50,
          child: ButtonTheme(
            child: ElevatedButton(
              style: kisgeri_design.Figma.buttons.primaryButtonStyle,
              onPressed: () {
                StartTimerOverlay.showTimerConfirmationDialog(context);
              },
              child: Text(
                'INDULHAT A VERSENY!',
                style: TextStyle(
                  fontFamily: "Lato",
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: kisgeri_design.Figma.colors.backgroundColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSectorCard(SectorDto sector) {
    if (sector.walls.length == 1) {
      return Center(
        child: SizedBox(
            width: 312,
            child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutesScreen(
                        wall: sector.walls.first,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      kisgeri_design.Figma.colors.backgroundColor),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(0.0)),
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(sector.name,
                      style: kisgeri_design.Figma.typo.body.copyWith(
                          color: kisgeri_design.Figma.colors.secondaryColor)),
                ))),
      );
    }
    bool isExpanded = _expandedStates[sector] ?? false;
    return Card(
      elevation: 0.0,
      color: kisgeri_design.Figma.colors.backgroundColor,
      child: ExpansionTile(
        onExpansionChanged: (value) {
          setState(() {
            _expandedStates[sector] = value;
          });
        },
        textColor: kisgeri_design.Figma.colors.secondaryColor,
        title: Text(sector.name,
            style: kisgeri_design.Figma.typo.body
                .copyWith(color: kisgeri_design.Figma.colors.secondaryColor)),
        trailing: _getRotatingTrailingIconIfNecessary(sector, isExpanded),
        children: [
          ListView(
            shrinkWrap: true,
            children: sector.walls.map((wall) => buildWallCard(wall)).toList(),
          ),
        ],
      ),
    );
  }

  Widget? _getRotatingTrailingIconIfNecessary(
      SectorDto sectorDto, bool isExpanded) {
    if (sectorDto.walls.length == 1) {
      return Icon(
        kisgeri_design.Figma.icons.chevronDown,
        color: Colors.transparent,
      );
    }
    return AnimatedRotation(
      turns: isExpanded ? 0.5 : 0,
      duration: const Duration(milliseconds: 400),
      child: Icon(kisgeri_design.Figma.icons.chevronDown,
          color: kisgeri_design.Figma.colors.secondaryColor),
    );
  }

  Card buildWallCard(WallDto wall) {
    return Card(
        elevation: 1.0,
        color: kisgeri_design.Figma.colors.backgroundColor,
        child: ListTile(
            title: Text(wall.name,
                style: kisgeri_design.Figma.typo.body.copyWith(
                    color: kisgeri_design.Figma.colors.secondaryColor)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoutesScreen(
                    wall: wall,
                  ),
                ),
              );
            }));
  }
}
