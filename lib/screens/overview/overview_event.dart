part of 'overview_bloc.dart';

abstract class OverviewEvent extends Equatable {
  const OverviewEvent();
}

class LoadDataEvent extends OverviewEvent {
  LoadDataEvent();

  LoadDataEvent.withTimer(this._timer);

  int? _timer;

  set timer(int value) {
    _timer = value;
  }

  int? get getTimer => _timer;

  @override
  List<Object> get props => [];

}
