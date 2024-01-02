class RouteDto {
  final String name;
  final String grade;
  final double points;
  final String type;

  RouteDto(this.name, this.grade, this.points, this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteDto &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          grade == other.grade &&
          points == other.points &&
          type == other.type;

  @override
  int get hashCode =>
      name.hashCode ^ grade.hashCode ^ points.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'RouteDto{name: $name, grade: $grade, points: $points, type: $type}';
  }
}
