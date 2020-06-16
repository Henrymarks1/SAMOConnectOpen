import 'package:flutter/foundation.dart';

class Assignment {
  final String name;
  final String gradeString;
  final String dueString;
  final String category;
  final String pointsString;
  final bool graded;
  final bool missing;
  final bool extraCredit;
  final bool ace;

  Assignment({
    @required this.name,
    @required this.gradeString,
    @required this.dueString,
    @required this.category,
    @required this.pointsString,
    @required this.graded,
    @required this.missing,
    @required this.extraCredit,
    @required this.ace,
  });

  AssignmentState get assignmentState {
    if(this.graded == false){
      return AssignmentState.NotGraded;
    }else if(this.extraCredit == true){
      return AssignmentState.ExtraCredit;
    }else if(this.missing){
      return AssignmentState.Missing;
    }else if(this.excused) {
      return AssignmentState.Excused;
    }else if(this.ace){
      return AssignmentState.Aced;
    }else if(this.points.passingGrade){
      return AssignmentState.Pass;
    }else if(this.points.failingGrade){
      return AssignmentState.Fail;
    }else{
      return AssignmentState.UNKNOWN;

    }
  }
  Points get points => Points.fromString(pointsString);

  bool get excused => this.pointsString.trim() == "Excused";
}

///Points doesn't work for extra credit, or excused assignments
class Points {
  final double pointsScored;
  final double fullPoints;

  Points({@required this.pointsScored, @required this.fullPoints,});

  factory Points.fromString(String pointsString){
    List<String> pointParts = pointsString.split("/");
    double points = double.parse(pointParts.first.trim());
    double outOf = double.parse(pointParts.last.trim());
    return Points(
      pointsScored: points,
      fullPoints: outOf,
    );

  }
  ///70 & ABOVE
  bool get passingGrade => percent>=70;

  bool get failingGrade => percent<70;


  double get percent =>(this.pointsScored/this.fullPoints);
}

enum AssignmentState {
  Aced,
  Pass,
  ExtraCredit,
  Excused,
  Missing,
  Fail,
  NotGraded,
  UNKNOWN,

}
