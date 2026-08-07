// Copyright 2018 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

// ignore_for_file: use_named_constants
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';

class _TestPlugin extends PhotoManagerPlugin {
  @override
  Future<PermissionState> requestPermissionExtend(_) {
    return Future<PermissionState>.value(PermissionState.notDetermined);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('RequestType equality test', () {
    expect(RequestType.image == const RequestType(1), equals(true));
    expect(RequestType.video == const RequestType(2), equals(true));
    expect(RequestType.audio == const RequestType(4), equals(true));
    expect(RequestType.common == const RequestType(3), equals(true));
    expect(RequestType.all == const RequestType(7), equals(true));
  });

  test('Construct custom plugin', () async {
    final _TestPlugin testPlugin = _TestPlugin();
    PhotoManager.withPlugin(testPlugin);
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    expect(permission == PermissionState.notDetermined, equals(true));
  });

  test('getLatestAssetFromPath uses the dedicated method channel call',
      () async {
    const MethodChannel channel = MethodChannel(
      'com.fluttercandies/photo_manager',
    );
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      capturedCall = call;
      return <String, dynamic>{'data': <dynamic>[]};
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final AssetEntity? result =
        await PhotoManagerPlugin().getLatestAssetFromPath(
      AssetPathEntity(
        id: 'album-id',
        name: 'Album',
        type: RequestType.image,
      ),
    );

    expect(result, isNull);
    expect(capturedCall?.method, 'getLatestAssetFromPath');
    final Map<dynamic, dynamic> arguments =
        capturedCall?.arguments as Map<dynamic, dynamic>;
    expect(arguments['id'], 'album-id');
    expect(arguments['type'], RequestType.image.value);
    expect(arguments['option'], isNull);
  });
}
