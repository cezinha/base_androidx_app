import 'package:base_androidx_app/model.dart';
import 'package:base_androidx_app/redux/middleware.dart';
import 'package:base_androidx_app/redux/actions.dart';
import 'package:base_androidx_app/redux/reducers.dart';
import 'package:base_androidx_app/util/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'dart:developer' as developer;

Store<AppState> createStore = Store<AppState>(
  appReducer,
  initialState: new AppState(),
  middleware: createStoreMiddleware()
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Create your store as a final variable in the main function or inside a
  // State object. This works better with Hot Reload than creating it directly
  // in the `build` function.
  final store = createStore;

  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  runApp(BaseApp(store: store));
}

class BaseApp extends StatelessWidget {
  final Store<AppState> store;

  BaseApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    //String prettyprint = encoder.convert(store.state);
    developer.log(store.state.toString(), name: 'state');
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
      onInit: (store) {
        developer.log('onInit', name: 'store');
        store.dispatch(InitConnectionAction());
      },
      builder: (context, isOffline) {
        return (isOffline)? new Text("Not connected") : new Text("Connected");
      }
    );
  }
}