import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
class LocationService {
  final String key = 'AIzaSyD8cSpXblSHe3WKK0VVjwF-lxO8qQ5yoh4';
  Future<String> getPlacedID(String input) async{
    final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);
    var placeID = json['candidates'][0]['place_id'] as String;
    print (placeID);
    return placeID;
  }
  Future<Map<String, double>> getPlace(String input) async{
    final placeID = await getPlacedID(input);
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$key';
    

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var result = json['result']['geometry']['location'];
    print (result);
    return result;
  }


}