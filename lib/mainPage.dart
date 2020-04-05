import 'package:covedtrack/Data.dart';
import 'package:covedtrack/DataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'myColors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'DataModel.dart';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:autocompeletetxtfield/autocompeletetxtfield.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  var width;
  var height;
  double lat = 16.8132798;
  double lng = 50.8084798;

  double intZoom = 2.0;
  CameraPosition initPosition;
  CameraPosition nxtPosition;
  var infectedRate = 0.0;
  var recoverdRate = 0.0;

  TextEditingController txtCntrll;
  ScrollController scrolController;
  var textFieldCurrPlace;
  Completer<GoogleMapController> _controller = Completer();
  DataFetch dataFetch;
  var indx;
  List<String> countries;
  Animation animation;
  AnimationController animationController;

  bool isLocated=true;
  myBehave my_bhave;

  @override
  void initState() {
    my_bhave = myBehave();
    initPosition = CameraPosition(target: LatLng(lat, lng), zoom: intZoom);
    scrolController = ScrollController();
    CheckConnection();
    DecodeLocation("Egypt").then((val) {
      print('Country : Egypt , Pos : ${val.latitude},${val.longitude}');
    });
    Future.delayed(Duration(seconds: 3), () async {
      await showMyDialog(context);
    });
    dataFetch = DataFetch();
    dataFetch.getData().then((val) {
      countries = dataFetch.countries;
    });

    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LinearGradient background = myColors.mainBackGround;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Stack(
        children: <Widget>[
          Align(
            child: Container(
              width: width,
              height: height * 0.6,
              decoration: BoxDecoration(
                  gradient: background,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(90),
                    bottomLeft: Radius.circular(90),
                  )),
            ),
            alignment: Alignment.topCenter,
          ),
          Align(
            child: Padding(
              child: Card(
                color: Colors.transparent,
                margin: EdgeInsets.all(0),
                child: ClipRRect(
                  child: Container(
                      height: height * 0.85,
                      width: width - 20,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          GoogleMap(
                            initialCameraPosition: initPosition,
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            onCameraMove: (val){
                              setState(() {
                                infectedRate=0.0;
                                recoverdRate=0.0;
                              });
                            },
                          ),
                          CovedRate(20, 20),
                        ],
                      )),
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              padding: EdgeInsets.only(top: 80),
            ),
            alignment: Alignment.center,
          ),
          Padding(
            padding: EdgeInsets.only(top: height*0.70),
            child: Align(
              child: FutureBuilder(
                future: dataFetch.getData(),
                builder: (context, snap) {
                  var view;
                  if (!snap.hasData) {
                    view = ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, indx) {
                          return Container(
                              width: width,
                              alignment: Alignment.center,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(myColors.AlphaRed),
                                ),
                              ));
                        });
                  } else {
                    view = AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.translationValues(
                              0.0, animation.value * height, 0.0),
                          child: ScrollConfiguration(
                            child: ListView.builder(
                                controller: scrolController,
                                scrollDirection: Axis.horizontal,
                                itemCount: dataFetch.dataLst.length,
                                itemBuilder: (context, indx) {
                                  return itm(
                                      dataFetch.dataLst[indx].countryName,
                                      dataFetch.dataLst[indx].infected,
                                      dataFetch.dataLst[indx].recovered,
                                      dataFetch.dataLst[indx].deaths,
                                      dataFetch.dataLst[indx].newInfected,
                                      dataFetch.dataLst[indx].newDeaths);
                                }),
                            behavior: my_bhave,
                          ),
                        );
                      },
                    );
                    animationController.forward();
                  }
                  return view;
                },
              ),
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  width: width - 50,
                  height: 55,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        child: Align(
                          child: TextField(
                            decoration: InputDecoration.collapsed(
                                hintText: "Search Here ... Global"),
                            onChanged: (val) => textFieldCurrPlace=val,
                            onSubmitted: (val) {
                              if (val != null) {
                                print(val);
                                setState(() {
                                  recoverdRate = 0.0;
                                  infectedRate = 0.0;
                                });
                                GotoPlace(val).then((val){

                                });
                              }
                            },
                          ),
                          alignment: Alignment.center,
                        ),
                        padding: EdgeInsets.only(left: 30),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10,top: 5 , bottom: 5),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: isLocated ? IconButton(
                            highlightColor: Colors.redAccent[100],
                            splashColor: Colors.redAccent[100],
                            icon: Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                recoverdRate = 0.0;
                                infectedRate = 0.0;
                              });
                              GotoPlace(textFieldCurrPlace);
                            },
                            color: myColors.Red,
                          ) : CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(myColors.AlphaRed),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            top: 70,
            left: 15,
            right: 15,
          ),
        ],
      )),
    );
  }

  Widget itm(country, infected, recovered, deaths, newInfc, newDths) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: width - 60,
        height: 10,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "$country",
                style: TextStyle(
                    fontSize: 40,
                    color: myColors.Red,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      child: Stack(
                        children: <Widget>[
                          Table(
                            defaultColumnWidth: IntrinsicColumnWidth(),
                            textDirection: TextDirection.ltr,
                            children: [
                              TableRow(
                                children: <Widget>[
                                  Padding(
                                    child: CircleAvatar(
                                      backgroundColor: myColors.Red,
                                      radius: 10,
                                    ),
                                    padding:
                                        EdgeInsets.only(left: 0, bottom: 10),
                                  ),
                                  Padding(
                                    child: Text(
                                      "Infected",
                                      style: TextStyle(
                                          color: myColors.Red, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 10),
                                  ),
                                  Padding(
                                    child: Text(
                                      "$newInfc",
                                      style: TextStyle(
                                          color: myColors.Red, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 30),
                                  ),
                                  Padding(
                                    child: Text(
                                      "$infected",
                                      style: TextStyle(
                                          color: myColors.Red, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 95),
                                  )
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  Padding(
                                    child: CircleAvatar(
                                      backgroundColor: myColors.Green,
                                      radius: 10,
                                    ),
                                    padding:
                                        EdgeInsets.only(left: 0, bottom: 10),
                                  ),
                                  Padding(
                                    child: Text(
                                      "Recoverd",
                                      style: TextStyle(
                                          color: myColors.Green, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 10),
                                  ),
                                  Padding(
                                    child: Text(
                                      "$recovered",
                                      style: TextStyle(
                                          color: myColors.Green, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 30),
                                  ),
                                  Padding(
                                    child: Text(
                                      "$recovered",
                                      style: TextStyle(
                                          color: myColors.Green, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 95),
                                  )
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  Padding(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      backgroundImage:
                                          AssetImage('images/skull.png'),
                                      radius: 10,
                                    ),
                                    padding: EdgeInsets.only(left: 0),
                                  ),
                                  Padding(
                                    child: Text(
                                      "Deathes",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 10),
                                  ),
                                  Padding(
                                    child: Text(
                                      "$newDths",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 30),
                                  ),
                                  Padding(
                                    child: Text(
                                      "$deaths",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                    padding: EdgeInsets.only(left: 95),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            child: Text(
                              "|\n|\n|\n|\n|\n",
                              style: TextStyle(color: Colors.grey[200]),
                            ),
                            padding: EdgeInsets.only(
                              left: width * 0.45,
                            ),
                          )
                        ],
                      ),
                      padding: EdgeInsets.only(left: 20, top: 30),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Coordinates> DecodeLocation(String country) async {
    var pos = await Geocoder.local.findAddressesFromQuery(country);
    var coordinates = pos.first.coordinates;
    return coordinates;
  }

  Future<void> GotoPlace(country) async {
    indx = countries.indexOf(country);
    setState(()=> isLocated = false);
    var RRate = double.parse(dataFetch.dataLst[indx].recovered);
    var INFRate = double.parse(dataFetch.dataLst[indx].infected);
    final GoogleMapController controller = await _controller.future;
    try {
      DecodeLocation(country).then((Pos) {
        print("Location Decoded Successfully");
        setState(()=> isLocated=true);
        nxtPosition = CameraPosition(
            target: LatLng(Pos.latitude, Pos.longitude), zoom: 5.4);
        scrolController.animateTo((340.3) * indx,
            duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
        controller
            .animateCamera(CameraUpdate.newCameraPosition(nxtPosition))
            .then((val) {
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              recoverdRate = RRate / width;
              infectedRate = INFRate / width;
            });
          });
          print('Location Arrived Successfuly');
        });
      });
    } catch (e) {
      print("Somthing WentWrong " + e);
    }
  }

  Widget CovedRate(infected, coverd) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(
          child: CircleAvatar(
            radius: infectedRate,
            backgroundColor: myColors.Red,
          ),
          opacity: 0.5,
        ),
        Opacity(
          child: CircleAvatar(
            radius: recoverdRate,
            backgroundColor: myColors.Green,
          ),
          opacity: 0.5,
        )
      ],
    );
  }

  Future<void> showMyDialog(BuildContext context) async {
    var currTime = TimeOfDay.now().hour;
   var imgs = ["images/soap.png", "images/stay-home.png"];
   var txts = {
      "1":["DONT FORGET !" , "Wach Your Hands"],
      "2":["PLEASE!","Stay At Home"]};
    var img;
    var txt1,txt2;
    if (currTime >= 17) {
      img = imgs[1];
      txt1 = txts["2"][0];
      txt2 = txts["2"][1];
    } else {
      img = imgs[0];
      txt1 = txts["1"][0];
      txt2 = txts["1"][1];
    }
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            child: Container(
              height: height * 0.5,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(50)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Align(
                    child: Image.asset(
                      img,
                      fit: BoxFit.contain,
                      width: 230,
                      height: 180,
                    ),
                    alignment: Alignment.center,
                  ),
                  Container(
                    height: height * 0.25,
                    width: width,
                    decoration: BoxDecoration(
                        color: myColors.AlphaRed,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(50),
                            bottomLeft: Radius.circular(50))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(txt1,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 30)),
                        Text(
                          txt2,
                          style: TextStyle(color: Colors.black54, fontSize: 24),
                        ),
                        Padding(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Ok,Thanks!"),
                          ),
                          padding: EdgeInsets.only(top: 20),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: myColors.AlphaRed,
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          );
        });
  }

  void showToast(color, txt) {
    Toast.show(txt, context,
        backgroundColor: color,
        backgroundRadius: 10,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER);
  }

  Future<void> CheckConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        showToast(myColors.Green, "Connected");
      }
    } on SocketException catch (_) {
      showToast(myColors.Red, "Not Connected");
    }
  }
}
class myBehave extends ScrollBehavior{
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
