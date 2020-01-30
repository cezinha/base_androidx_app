import 'package:base_androidx_app/model.dart';
import 'package:base_androidx_app/redux/middleware.dart';
import 'package:base_androidx_app/redux/actions.dart';
import 'package:base_androidx_app/redux/reducers.dart';
import 'package:base_androidx_app/util/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';

/*Store<AppState> createStore = Store<AppState>(
  appReducer,
  initialState: new AppState(),
  middleware: createStoreMiddleware()
);*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Create your store as a final variable in the main function or inside a
  // State object. This works better with Hot Reload than creating it directly
  // in the `build` function.
  //final store = createStore;
  var remoteDevtools = RemoteDevToolsMiddleware('192.168.1.30:8000');

  List<Middleware<AppState>> createStoreMiddleware() => [
    remoteDevtools,
    TypedMiddleware<AppState, InitConnectionAction>(initConnectionStatus)
  ];

  final store = new DevToolsStore<AppState>(
    appReducer,
    initialState: new AppState(),
    middleware: createStoreMiddleware()
  );

  remoteDevtools.store = store;
  await remoteDevtools.connect();

  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  runApp(BaseApp(store: store));
}

class BaseApp extends StatelessWidget {
  final Store<AppState> store;

  BaseApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The StoreProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    return StoreProvider<AppState>(
      // Pass the store to the StoreProvider. Any ancestor `StoreConnector`
      // Widgets will find and use this value as the `Store`.
      store: store,
      child: MaterialApp(
        theme: ThemeData.dark(),
        title: 'Base App',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Base App'),
          ),
          body: Center(
            child: Container(
              child: ConnectionWidget(),
            )
          ),
        ),
      ),
    );
  }
}

class ConnectionWidget extends StatefulWidget {
  ConnectionWidget({Key key}) : super(key: key);

  @override
  _ConnectionWidgetState createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends State<ConnectionWidget> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.isOffline,
      onInit: (store) => store.dispatch(InitConnectionAction()),
      builder: (context, isOffline) {
        return (isOffline)? new Text("Not connected") : new Text("Connected");
      }
    );
  }
}