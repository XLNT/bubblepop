import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geohash/geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

final decimals = BigInt.from(math.pow(10, 18));
final extent = 0.009; // about 1k in either direction

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Page(),
      ),
    );
  }
}

class Page extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _error = useState<String>(null);
    final _loading = useState<bool>(false);
    final _data = useState<Map<String, dynamic>>(null);
    final _position = useState<Position>(null);

    void getLocation() async {
      _position.value =
          await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

      _error.value = null;
      _loading.value = true;

      try {
        final swLng = _position.value.longitude - extent;
        final swLat = _position.value.latitude - extent;
        final neLng = _position.value.longitude + extent;
        final neLat = _position.value.latitude + extent;
        debugPrint("$swLng, $swLat, $neLng, $neLat");
        final res = await http.post("http://localhost:3000/location",
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "swLng": swLng,
              "swLat": swLat,
              "neLng": neLng,
              "neLat": neLat,
            }));
        final data = json.decode(res.body);
        debugPrint("$data");
        _data.value = data;
      } catch (error) {
        _error.value = "$error"; // cast to string
      } finally {
        _loading.value = false;
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _loading.value
                  ? CircularProgressIndicator()
                  : _error.value != null
                      ? ErrorPage(
                          errorText: _error.value,
                        )
                      : _data.value != null
                          ? InfoPage(
                              data: _data.value,
                            )
                          : SizedBox(),
              _loading.value
                  ? SizedBox()
                  : OutlineButton(
                      child: Text(
                          "find${_data.value != null ? ' another' : ''} a way to contribute to the FOAM map"),
                      onPressed: getLocation,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorPage extends HookWidget {
  ErrorPage({
    Key key,
    this.errorText,
  }) : super(key: key);

  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(errorText),
    );
  }
}

class InfoPage extends HookWidget {
  InfoPage({
    Key key,
    this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final deposit = data['poi']['state']['deposit'] as String;
    final depositInFOAM = BigInt.parse(deposit) / decimals;
    final humanDeposit = "${depositInFOAM.toStringAsFixed(2)} FOAM";
    final status = data['poi']['state']['status']['type'] as String;
    final humanStatus = status == 'applied' ? 'application' : 'challenge';

    final address = data['info']['address'] as String;
    final name = data['info']['name'] as String;

    Future<void> launchUrl(String url) async {
      if (await canLaunch(url)) {
        debugPrint("launching $url");
        await launch(url);
      } else {
        debugPrint("can't open $url");
      }
    }

    Future<void> onPressed() async {
      final g = Geohash.decode(data['info']['geohash']);
      final lat = g.x;
      final lng = g.y;
      final url = Platform.isIOS
          ? "https://maps.apple.com/?q=$lat,$lng"
          : "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
      await launchUrl(url);
    }

    Future<void> onFoamMapPressed() async {
      final listingHash = data['poi']['listingHash'] as String;
      await launchUrl("https://map.foam.space/#/dashboard/$listingHash/?zoom=15.00");
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "🎉 🎉 🎉",
          style: Theme.of(context).textTheme.display2,
        ),
        SizedBox(height: 12),
        Text(
          "We found a nearby POI with a deposit of $humanDeposit called $name at $address that is in $humanStatus mode.",
          style: Theme.of(context).textTheme.body1.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          "Hit it up and contribute to the FOAM map by verifying the details of the place of interest or pop someone's bubble by challenging their listing.",
        ),
        SizedBox(height: 12),
        FlatButton(
          child: Text("Open in Apple/Google Maps 📍"),
          onPressed: onPressed,
        ),
        FlatButton(
          child: Column(
            children: <Widget>[
              Text("See the POI on map.foam.space ➡"),
              Text(
                "(open in your favorite dApp browser)",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          onPressed: onFoamMapPressed,
        ),
        SizedBox(height: 12),
        Text(
          "🍿 🍿 🍿",
          style: Theme.of(context).textTheme.display2,
        ),
      ],
    );
  }
}
