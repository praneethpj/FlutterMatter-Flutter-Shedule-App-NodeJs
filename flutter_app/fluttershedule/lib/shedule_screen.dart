import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'TimeSlot.dart';

class SheduleScreen extends StatefulWidget {
  const SheduleScreen({super.key});

  @override
  State<SheduleScreen> createState() => _SheduleScreenState();
}

class _SheduleScreenState extends State<SheduleScreen> {
  var client = Client();
  String selectedTime = "";

  Future<List<TimeSlot>> fetchData() async {
    var response = client.get(Uri.parse("http://192.168.43.98:3000/getslot"));
    var responseHttp = await response;
    var responseHttpDecode = json.decode(responseHttp.body);
    return timeSlotFromJson(json.encode(responseHttpDecode['data']));
  }

  Future<void> updateTime() async {
    Map<String, dynamic> body = {
      "userid": "1",
      "timerange": selectedTime,
    };

    final encodeType = Encoding.getByName("UTF-8");

    var response = client.post(
        Uri.parse("http://192.168.43.98:3000/updateslot"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
        encoding: encodeType);
    var responseHttp = await response;
    var responseHttpDecode = json.decode(responseHttp.body);

    fetchData();
    setState(() {});
  }

  getTodayDay() {
    return DateFormat("d").format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    double deviceSize = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SafeArea(
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back)),
                Text(
                  "${getTodayDay()}",
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.arrow_forward)),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Flexible(
              child: FutureBuilder<List<TimeSlot>>(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      itemCount: snapshot.data!.length,
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return snapshot.data![index].status == 0
                            ? ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.black12)),
                                onPressed: null,
                                child:
                                    Text("${snapshot.data![index].timerange}"))
                            : ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.blue)),
                                onPressed: () {
                                  setState(() {
                                    selectedTime =
                                        snapshot.data![index].timerange;
                                  });
                                },
                                child:
                                    Text("${snapshot.data![index].timerange}"));
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            Container(
                width: deviceSize,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedTime == null
                      ? null
                      : () {
                          updateTime();
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Make a Book !",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.bookmark)
                    ],
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueAccent)),
                ))
          ],
        ),
      ),
    ));
  }
}
