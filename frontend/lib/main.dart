import 'package:flutter/material.dart';
import 'package:pos_communicator/network_discovery.dart';
import 'package:pos_communicator/pos_communicator.dart';
import 'package:pos_communicator/pos_server.dart';
import 'package:pos_communicator/remote_device.dart';

final networkDiscovery = NetworkDiscovery();
final posServer = POSServer();
final remoteDevice = RemoteDevice();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await networkDiscovery.register();
  await posServer.start(networkDiscovery.port);
  networkDiscovery.deviceStream.listen((event) async {
    print('----------------------------------------');
    print(event);
    print('========================================');
    for(final deviceInfo in event) {
      await remoteDevice.get('deviceData', deviceInfo);
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:  Center(
        child: Column(
          children: [
            FutureBuilder(builder: (ctx, snapshot) {
              return Text('${snapshot.data}');
            }, future: PosCommunicator.platformVersion,),
            const SizedBox(height: 20,),
            StreamBuilder(builder: (ctx, snapshot){
              return Text('${snapshot.data}', style: const TextStyle(fontSize: 20),);
            }, stream: PosCommunicator.getRandomNumberStream,)
          ],
        ),
      ),
    );
  }
}
