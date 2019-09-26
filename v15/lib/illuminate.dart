import 'package:flutter/material.dart';
import 'package:samohiConnect/constants.dart';
import 'color_loader_3.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart'as dom;
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';


class Illuminate extends StatefulWidget {

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
 static String tag = "illuminate";
  Illuminate();

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  _IlluminateState createState() => new _IlluminateState();
}

class _IlluminateState extends State<Illuminate> with TickerProviderStateMixin {
  Widget bodyWidget;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController usernameController;
  TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    bodyWidget =loginPage();
  }

  FutureBuilder<http.Response> loginPage() {
    return FutureBuilder(
      future:http.get("https://smmusd.illuminatehc.com/login"),
      builder: (c,s){
        if(s.hasError){
          return Center(child: Text("Network Handshake Error, Check your connection"),);
        }
        if(s.connectionState!=ConnectionState.done){
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(child: ColorLoader3(),),
              Text("Establishing connection with Illuminate")
            ],
          );
        }else{
          //print(s.data.body);
          http.Response response = s.data;
          print("JEADERS");
          
          String header = response.headers["set-cookie"].split(',').last.split(';').first;
          print(header);
          return Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Image.asset('assets/university.png', width: MediaQuery.of(context).size.width/3),
                    Container(height: 12,),
                    Text("Illuminate", textAlign: TextAlign.center,style: TextStyle(fontSize: 32),),
                  ],
                ),

                
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Username:", style: TextStyle(fontSize: 18),)
                      ],
                    ),
                    TextField(
                      controller: usernameController,
                      autocorrect: false,
                      
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),

                        labelText: "Username"
                      ),
                    ),
                    Container(height: 40,),
                    Row(
                      children: <Widget>[
                        Text("Password:", style: TextStyle(fontSize: 18),)
                      ],
                    ),
                    TextField(
                      controller: passwordController,
                      autocorrect: false,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "Password"
                      ),
                    ),
                    Container(height: 50,),
                    Container(
                      child: FlatButton(
                        padding: EdgeInsets.symmetric(vertical:25, horizontal:(MediaQuery.of(context).size.width-140)/2),
                        color: Constants.baseColor,
                        onPressed: (){
                          setState(() {
                            bodyWidget = checkLogin(header, usernameController.text, passwordController.text);
                          });
                        },
                        child: Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 22),),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
                      ),
                    ),
                    Container(height: 40,),
                  ],
                )
                

              ],
            ),
          );//checkLogin(header,"595537","123456");
        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent[700],
        title: Text("Illuminate"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            color: Colors.white,
            splashColor: Colors.yellowAccent,
            onPressed: (){
              Constants.showInfoBottomSheet([
                Constants.officialWebsiteAction(context, "https://smmusd.illuminatehc.com/"),
                Constants.ratingAction(context),
                CupertinoActionSheetAction(
                  child: Text("Extra Info"),
                  onPressed: ()=>showCupertinoModalPopup(
                    context: context,
                    builder: (c)=>CupertinoAlertDialog(
                      title: Text("Extra Info"),
                      content: Text("In-app illuminate makes accessing your gradebook easy. Your information completely safe, it is only used for when you login, and cleared when you press the back button."),
                      actions: <Widget>[CupertinoDialogAction(child: Text("Ok"),onPressed: ()=>Navigator.of(context).pop(),)],
                    )
                  ),
                ),
                CupertinoActionSheetAction(
                  child: Text("Share"),
                  onPressed: ()=>Constants.shareString("Hate using illuminate on your phone? SAMOHI Connect offers a true, formatted, in-app illuminate experience -- https://swerd.tech/samoconnect.html"),
                )
              ], context);
            },
          )
        ],
      ),
      key: scaffoldKey,
      body: bodyWidget
    );
  }

  FutureBuilder<http.Response> checkLogin(String header,String username, String password) {
    return FutureBuilder(
            future: http.post("https://smmusd.illuminatehc.com/login_check", headers: {"cookie":header}, body: {"_username":username,"_password":password}),
            builder: (c, s){
              if(s.connectionState!=ConnectionState.done){
                return Center(child: ColorLoader3(),);
              }else{
                http.Response r = s.data;
                print(r.headers['set-cookie']);
                header = r.headers['set-cookie'].split(",").last.split(";").first;

                print("header");
                print(header);
                dom.Document theDoc = parse(s.data.body);
                
                
                  print("Logged In success");
                try {
                  return loggedInBuilder(header);

                } catch (e) {
                  return loginPage();
                }


              }
            },
          );
  }

  FutureBuilder<http.Response> loggedInBuilder(String header) {
    try {
      
    
      return FutureBuilder(
                    future: http.get("https://smmusd.illuminatehc.com/student-path?login=1", headers: {"cookie":header}),
                    builder: (c,s){
                      if(s.connectionState!=ConnectionState.done){
                        return Center(child: ColorLoader3(),);
                      }else{
                        dom.Document doc = parse(s.data.body);
                        print(doc.children.first.children);
                        print(doc.body.innerHtml);
                        try {
                          return gradebookBuilder(header);

                        } catch (e) {
                        }

                        
                      }
                    },
                  );
    } catch (e) {
      return loginPage();
    }
  }

  FutureBuilder<http.Response> gradebookBuilder(String header) {
    try {
      return FutureBuilder(
                        future: http.get("https://smmusd.illuminatehc.com/gradebooks/", headers: {"cookie":header}),
                        builder: (c,s){
                          if(s.connectionState!=ConnectionState.done){
                            return Center(child: ColorLoader3(),);
                          }else{
                            try {
                              
                            
                            dom.Document doc = parse(s.data.body);
                            print(doc.children.first.children);
                            print(doc.body.innerHtml);
                            if(doc.body.innerHtml.contains("Gradebook Summary")){
                              print("TRUEEEEE");
                              if(doc.body.innerHtml.contains("ENGLISH 10 HP")){
                                print("ALSO TRURRRR");
                              }
                            }
                            //https://smmusd.illuminatehc.com/gradebooks/
                            List<dom.Element> unformattedGrades = doc.body.getElementsByClassName("ibox-content").last.children.first.children.first.children.last.children;
                            List formattedGrades = [];
                            for (dom.Element grade in unformattedGrades) {
                              Map classMap = new Map();
                              classMap['grade'] = grade.children.first.innerHtml.split(" ").first;
                              Color color = Colors.black;
                              try {
                                color = Color(int.parse("0xff"+grade.attributes['style'].split("#").last.toString().toLowerCase()));
                              } catch (e) {
                                color = Colors.black;
                              }
                              classMap['gradeColor'] = color;
                              double gradePercent = 100;
                              try {
                                gradePercent = double.parse(grade.children.first.innerHtml.split(" ").last.split('%').first.toString());
                              } catch (e) {
                                gradePercent = 100;
                              }
                              classMap['gradePercent'] = gradePercent;
                              classMap['class'] = grade.children[1].innerHtml;
                              classMap['teacher'] = grade.children[3].innerHtml;
                              classMap['lastUpdated'] = grade.children[4].innerHtml;
                              classMap['url'] = grade.children[2].children.first.attributes['href'];

                              formattedGrades.add(classMap);
                            }
                            return ListView.separated(
                              padding: EdgeInsets.all(50),
                              itemCount: formattedGrades.length,

                              separatorBuilder: (c,i)=>Container(height: 30,),
                              itemBuilder: (c,i)=>RaisedButton(
                                elevation: 15,
                                
                                splashColor: Constants.baseColor,
                                padding: EdgeInsets.all(15),
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(formattedGrades[i]['class'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                        Text(formattedGrades[i]['grade'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(formattedGrades[i]['teacher'], style: TextStyle(fontSize: 19, fontWeight: FontWeight.normal, color: Colors.grey[600]),),
                                        Text(formattedGrades[i]['lastUpdated'], style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                    AnimatedCircularChart(
                                      chartType: CircularChartType.Radial,
                                      size: Size(MediaQuery.of(context).size.width-160,MediaQuery.of(context).size.width-160),
                                      holeLabel: formattedGrades[i]['gradePercent'].toString()+"%",
                                      labelStyle: TextStyle(color: Colors.black, fontSize: 28),
                                      initialChartData: [
                                        CircularStackEntry(
                                          [
                                            CircularSegmentEntry(
                                              formattedGrades[i]['gradePercent'],Colors.greenAccent[400]
                                            ),
                                            CircularSegmentEntry(
                                              100-formattedGrades[i]['gradePercent'],Colors.redAccent[400]
                                            )
                                          ]
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                onPressed: ()=>openClassGradebook(header, formattedGrades[i]['url'], formattedGrades[i]['class']),
                              ),
                            );//
                            } catch (e) {
                              //LOGIN ERROR
                              try {
                                scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.redAccent[400],
                                  action: SnackBarAction(label: "OK",onPressed: ()=>scaffoldKey.currentState.hideCurrentSnackBar(),textColor: Colors.white,),
                                  content: Text("Sorry, we can't log you in right now."),
                                )
                              );
                              } catch (e) {
                              }
                              
                              return loginPage();
                            }
                          }
                          
                        }
                        
                      );

    } catch (e) {
      return loginPage();
    }
  }

  openClassGradebook(String header, String url, String subject){
    print("THE URLLL");
    print(url);
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        maintainState: true,
        builder: (c)=>Scaffold(
          appBar: AppBar(
            title: Text(subject),
          ),
          body: FutureBuilder(
            future: http.get("https://smmusd.illuminatehc.com"+url, headers: {"cookie":header}),
            builder: (c,s){
              try {
                
              
              if(s.connectionState!=ConnectionState.done){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(child: ColorLoader3(),),
                    Text("Loading your "+subject+" class", textAlign: TextAlign.center,)
                  ],
                );
              }else{
                dom.Document theDoc = parse(s.data.body);
                dom.Element theGradebook = theDoc.getElementById("assignment_list");
                List<dom.Element> theAssignments = theGradebook.children.last.children;
                List<Map> theAssignmentsF = [];
                for (dom.Element item in theAssignments) {
                  Map theMap = new Map();
                  theMap['category'] = item.children.first.text;
                  theMap['name'] = item.children[1].children.first.text.toString();
                  theMap['points'] = item.children[2].text.trim().split("\n").join(" ");
                  theMap['missing'] = item.children[2].text.trim()=="Missing";
                  theMap['grade'] = item.children[3].text.trim();
                  theMap['due'] = item.children[5].text.trim();
                  theAssignmentsF.add(theMap);
                }
                return ListView.separated(
                  padding: EdgeInsets.all(25),
                  itemCount: theAssignmentsF.length,
                  separatorBuilder: (c,i)=>Container(height: 30,),
                  itemBuilder: (c,i)=>RaisedButton(
                    padding: EdgeInsets.all(10),
                    color: Colors.white,
                    onPressed: (){},
                    elevation: 15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(theAssignmentsF[i]['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            Text(theAssignmentsF[i]['points'], style: TextStyle(fontSize: 21, fontWeight: FontWeight.normal),),

                        ],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(theAssignmentsF[i]['category'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.grey[700]),),
                            theAssignmentsF[i]['missing']?FloatingActionButton(backgroundColor: Colors.redAccent[400],onPressed: (){},tooltip: "Missing",child: Icon(MdiIcons.alertCircleOutline),mini: true,):Container()

                        ],),
                      ],
                    ),
                  ),
                );
              }
              } catch (e) {
                try {
                  scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent[400],
                    action: SnackBarAction(label: "OK",onPressed: ()=>scaffoldKey.currentState.hideCurrentSnackBar(),textColor: Colors.white,),
                    content: Text("Sorry, we can't log you in right now."),
                  )
                  );
                } catch (e) {
                }
                              
               return loginPage();
              }
            }
            ,
          ),
        )
      )
    );
  }
              
                
}
Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
  return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
}