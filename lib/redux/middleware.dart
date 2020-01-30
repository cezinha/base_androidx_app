import 'dart:async';

import 'package:redux/redux.dart';
import 'package:base_androidx_app/util/connection.dart';
import 'package:base_androidx_app/redux/actions.dart';
import 'package:base_androidx_app/model.dart';

Future initConnectionStatus(Store<AppState> store, InitConnectionAction action, NextDispatcher next) async {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.connectionChange.listen((dynamic hasConnection) {
    bool isOffline = !hasConnection;

    if (store.state.isOffline != isOffline) {
      print(store.state);
      store.dispatch(ChangedConnectionAction(isOffline));
    }
  });
  next(action);
}