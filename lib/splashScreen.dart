import 'package:covedtrack/main.dart';
import 'package:flutter/material.dart';
import 'mainPage.dart';
import 'myColors.dart';


class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  LinearGradient background = myColors.mainBackGround;
  var opc=0.0;
  @override
  void initState() {
    setState(() => this.opc=1.0);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds:4),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainPage()));
    });
    return  Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: background,
        ),
        child:AnimatedOpacity(
          curve: Curves.fastOutSlowIn,
          opacity: opc,
          duration: Duration(seconds: 2),
          child:  Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(
                opacity: 0.07,
                child: Image.asset('images/bacteria.png',width: 600,height: 600,fit:BoxFit.cover,),
              ),
              Image.asset('images/tracking.png',width: 350,height: 350,),
              Padding(
                child: Column(
                  children: <Widget>[
                    Text('COVED-19',style: TextStyle(
                        color: Colors.white,
                        fontSize: 60
                    ),),
                    Padding(
                      child: Text('Tracker',style: TextStyle(
                          color: Colors.black54,
                          fontSize: 45
                      ),),
                      padding: EdgeInsets.only(top: 20),
                    )
                  ],
                ),
                padding: EdgeInsets.only(top: 650),
              ),
            ],
          ),
        )
    );
  }
}


