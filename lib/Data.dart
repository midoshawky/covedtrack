import 'package:covedtrack/DataModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:convert/convert.dart';
import 'dart:async';

class DataFetch {
  var _url = "https://covid-193.p.rapidapi.com/statistics";
  List<DataModel> dataLst = [];
  List<String> countries = [];
  Future<List<DataModel>> getData() async {
    var URL = Uri.encodeFull(_url);
    var response = await http.get(URL, headers: {
      'x-rapidapi-host': "covid-193.p.rapidapi.com",
      'x-rapidapi-key': "Put your Rapied api key here"
    });
    var body = response.body;
    var convert = json.decode(body);
    for (var key in convert["response"]) {
      dataLst.add(DataModel(
          key["country"],
          key["cases"]["recovered"].toString() == 'null' ? "N/A" : key["cases"]["recovered"].toString(),
          key["cases"]["active"].toString() == 'null' ? "N/A" : key["cases"]["active"].toString(),
          key["deaths"]["total"].toString() == 'null' ? "N/A" :  key["deaths"]["total"].toString(),
          key["cases"]["new"].toString() == 'null' ? "N/A" :  key["cases"]["new"].toString(),
          key["deaths"]["new"].toString() == 'null' ? "N/A" : key["deaths"]["new"].toString()));
    }
    for (var key in convert["response"]) {
      countries.add(key["country"]);
    }
    return dataLst;
  }
}
