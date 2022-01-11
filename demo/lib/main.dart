
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:wifi/wifi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discover Printers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String localIp = '';
  List devices = [];
  bool isDiscovering = false;
  int found = -1;
  TextEditingController portController = TextEditingController(text: '9100');
  bool isPrintBlue = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  void discover(BuildContext ctx) async {
    setState(() {
      isPrintBlue = false;
      isDiscovering = true;
      devices = [];
      found = -1;
    });
    String ip;
    try {
      ip = await Wifi.ip;
      print('local ip:\t$ip');
    } catch (e) {
      final snackBar = SnackBar(
          content: Text('WiFi is not connected', textAlign: TextAlign.center));
      Scaffold.of(ctx).showSnackBar(snackBar);
      return;
    }
    setState(() {
      localIp = ip;
    });

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;

    print('subnet:\t$subnet, port:\t$port');

    // Fluttertoast.showToast(
    //     msg:  " subnet:  $subnet port:$port",
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0
    // );

    final stream = NetworkAnalyzer.discover2(subnet, port);

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        setState(() {
          devices.add(addr.ip);
          found = devices.length;
        });
      }
    })
      ..onDone(() {
        setState(() {
          isDiscovering = false;
          found = devices.length;
        });
        // Fluttertoast.showToast(
        //     msg:  "Scanner success",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0
        // );
      })
      ..onError((dynamic e) {
        // Fluttertoast.showToast(
        //     msg:  "Scanner fail $e",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.CENTER,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0
        // );
      });
  }


  void scanBluetooth() async {
    setState(() {
      isPrintBlue = true;
      devices = [];
    });
    // printerManager.startScan(Duration(seconds: 4));

    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      devices = bluetooths;
    });
  }

  // Ticket testTicketBlue() {
  //   final Ticket ticket = Ticket(PaperSize.mm80);
  //
  //   ticket.text(
  //       'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  //   ticket.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
  //       styles: PosStyles(codeTable: PosCodeTable.westEur));
  //   ticket.text('Special 2: blåbærgrød',
  //       styles: PosStyles(codeTable: PosCodeTable.westEur));
  //
  //   ticket.text('Bold text', styles: PosStyles(bold: true));
  //   ticket.text('Reverse text', styles: PosStyles(reverse: true));
  //   ticket.text('Underlined text',
  //       styles: PosStyles(underline: true), linesAfter: 1);
  //   ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
  //   ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
  //   ticket.text('Align right',
  //       styles: PosStyles(align: PosAlign.right), linesAfter: 1);
  //
  //   ticket.text('Text size 200%',
  //       styles: PosStyles(
  //         height: PosTextSize.size2,
  //         width: PosTextSize.size2,
  //       ));
  //
  //   ticket.feed(2);
  //   ticket.cut();
  //   return ticket;
  // }

  // void printBluetooth(BluetoothOption.PrinterBluetooth printer) async {
  //   printerManager.selectPrinter(printer);
  //   final BluetoothOption.PosPrintResult res = await printerManager.printTicket(testTicketBlue());
  //
  //   print('Print result: ${res.msg}');
  // }

  void printBluetooth(String select) async {
    List list = select.split("#");
    // String name = list[0];
    String mac = list[1];
    final String result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result mac = $mac");
    if (result == "true") {
      String isConnected = await BluetoothThermalPrinter.connectionStatus;
      if (isConnected == "true") {
        // List<int> bytes = await getTicket();
        final result = await BluetoothThermalPrinter.writeText('text demo');
        print("Print $result");

      } else {

      }
    }
  }


  Future<Ticket> testTicket() async {
    final Ticket ticket = Ticket(PaperSize.mm80);

    ticket.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    ticket.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: PosCodeTable.westEur));
    ticket.text('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: PosCodeTable.westEur));

    ticket.text('Bold text', styles: PosStyles(bold: true));
    ticket.text('Reverse text', styles: PosStyles(reverse: true));
    ticket.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
    ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
    ticket.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    ticket.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    ticket.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    // Print image
    // final ByteData data = await rootBundle.load('assets/logo.png');
    // final Uint8List bytes = data.buffer.asUint8List();
    // final Image image = decodeImage(bytes);
    // ticket.image(image);
    // Print image using alternative commands
    // ticket.imageRaster(image);
    // ticket.imageRaster(image, imageFn: PosImageFn.graphics);

    // Print barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    ticket.barcode(Barcode.upcA(barData));

    // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
    // ticket.text(
    //   'hello ! 中文字 # world @ éphémère &',
    //   styles: PosStyles(codeTable: PosCodeTable.westEur),
    //   containsChinese: true,
    // );

    ticket.feed(2);

    ticket.cut();
    return ticket;
  }



  void testPrint(String printerIp, BuildContext ctx) async {
    // TODO Don't forget to choose printer's paper size
    final PrinterNetworkManager printerManager = PrinterNetworkManager();
    printerManager.selectPrinter(printerIp, port: 9100);

    final PosPrintResult res =
    await printerManager.printTicket(await testTicket());
    print('Print result: ${res.msg}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Printers'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                Text('Local ip: $localIp', style: TextStyle(fontSize: 16)),
                SizedBox(height: 15),
                RaisedButton(
                    child: Text(
                        '${isDiscovering ? 'Discovering...' : 'Discover'}'),
                    onPressed: isDiscovering ? null : () => discover(context)),
                RaisedButton(
                    child: Text('Bluetooth'),
                    onPressed: () => scanBluetooth()),
                SizedBox(height: 15),
                found >= 0
                    ? Text('Found: $found device(s)',
                    style: TextStyle(fontSize: 16))
                    : Container(),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => this.isPrintBlue ? printBluetooth(devices[index]) : testPrint(devices[index], context),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 60,
                              padding: EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.print),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${devices[index]}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Click to print a test receipt',
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:ping_discover_network/ping_discover_network.dart';
// import 'package:wifi/wifi.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   String localIp = '';
//   List<String> devices = [];
//   bool isDiscovering = false;
//   int found = -1;
//   TextEditingController portController = TextEditingController(text: '80');
//
//   void discover(BuildContext ctx) async {
//     setState(() {
//       isDiscovering = true;
//       devices.clear();
//       found = -1;
//     });
//
//     String ip;
//     try {
//       ip = await Wifi.ip;
//       print('local ip:\t$ip');
//     } catch (e) {
//       final snackBar = SnackBar(
//           content: Text('WiFi is not connected', textAlign: TextAlign.center));
//       Scaffold.of(ctx).showSnackBar(snackBar);
//       return;
//     }
//     setState(() {
//       localIp = ip;
//     });
//
//     final String subnet = ip.substring(0, ip.lastIndexOf('.'));
//     int port = 80;
//     try {
//       port = int.parse(portController.text);
//     } catch (e) {
//       portController.text = port.toString();
//     }
//     print('subnet:\t$subnet, port:\t$port');
//
//     final stream = NetworkAnalyzer.discover2(subnet, port);
//
//     stream.listen((NetworkAddress addr) {
//       if (addr.exists) {
//         print('Found device: ${addr.ip}');
//         setState(() {
//           devices.add(addr.ip);
//           found = devices.length;
//         });
//       }
//     })
//       ..onDone(() {
//         setState(() {
//           isDiscovering = false;
//           found = devices.length;
//         });
//       })
//       ..onError((dynamic e) {
//         final snackBar = SnackBar(
//             content: Text('Unexpected exception', textAlign: TextAlign.center));
//         Scaffold.of(ctx).showSnackBar(snackBar);
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Discover Local Network'),
//       ),
//       body: Builder(
//         builder: (BuildContext context) {
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 TextField(
//                   controller: portController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: 'Port',
//                     hintText: 'Port',
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text('Local ip: $localIp', style: TextStyle(fontSize: 16)),
//                 SizedBox(height: 15),
//                 RaisedButton(
//                     child: Text(
//                         '${isDiscovering ? 'Discovering...' : 'Discover'}'),
//                     onPressed: isDiscovering ? null : () => discover(context)),
//                 SizedBox(height: 15),
//                 found >= 0
//                     ? Text('Found: $found device(s)',
//                     style: TextStyle(fontSize: 16))
//                     : Container(),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: devices.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return Column(
//                         children: <Widget>[
//                           Container(
//                             height: 60,
//                             padding: EdgeInsets.only(left: 10),
//                             alignment: Alignment.centerLeft,
//                             child: Row(
//                               children: <Widget>[
//                                 Icon(Icons.devices),
//                                 SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: <Widget>[
//                                       Text(
//                                         '${devices[index]}:${portController.text}',
//                                         style: TextStyle(fontSize: 16),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Icon(Icons.chevron_right),
//                               ],
//                             ),
//                           ),
//                           Divider(),
//                         ],
//                       );
//                     },
//                   ),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
