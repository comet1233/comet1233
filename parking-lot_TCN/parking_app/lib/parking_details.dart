// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:url_launcher/url_launcher.dart';

// void _showParkingDetails(BuildContext context, Map<String, dynamic> lot) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(lot['name']),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Remaining Spaces: ${lot['remaining']}'),
//             Text('Rate: \$${lot['rate']} per hour'),
//             Text('Address: ${lot['address']}'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop();  // 先關閉對話框
//                 final LatLng initialPosition = LatLng(24.166666, 120.683333); // Taichung, Jinping St
//                 final url = 'https://www.google.com/maps/dir/?api=1&origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${lot['location'].latitude},${lot['location'].longitude}';
//                 if (await canLaunch(url)) {
//                   await launch(url);
//                 } else {
//                   throw 'Could not launch $url';
//                 }
//               },
//               child: Text('Navigate'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('Close'),
//           ),
//         ],
//       );
//     },
//   );
// }
