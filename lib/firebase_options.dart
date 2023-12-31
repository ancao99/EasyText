// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBh4VSIuiZW7G0309ExWFHEF3JxndXfed4',
    appId: '1:769018740492:web:4a8394ead3e735b6fa5329',
    messagingSenderId: '769018740492',
    projectId: 'final-449c6',
    authDomain: 'final-449c6.firebaseapp.com',
    storageBucket: 'final-449c6.appspot.com',
    measurementId: 'G-PQH6W7YER6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCi4a1b_EzpbCu3y50CPlhQKzEONn1dUMk',
    appId: '1:769018740492:android:a7f70fa68981ce21fa5329',
    messagingSenderId: '769018740492',
    projectId: 'final-449c6',
    storageBucket: 'final-449c6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsmgbDxr6f0jghh6liUTR0xzv6BD5MxiA',
    appId: '1:769018740492:ios:ed99f9497fad2957fa5329',
    messagingSenderId: '769018740492',
    projectId: 'final-449c6',
    storageBucket: 'final-449c6.appspot.com',
    iosClientId: '769018740492-p51c7ld1p5cl99puiop7ra2cvv18kjd2.apps.googleusercontent.com',
    iosBundleId: 'com.example.easytext',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsmgbDxr6f0jghh6liUTR0xzv6BD5MxiA',
    appId: '1:769018740492:ios:348c31207e628857fa5329',
    messagingSenderId: '769018740492',
    projectId: 'final-449c6',
    storageBucket: 'final-449c6.appspot.com',
    iosClientId: '769018740492-9ecuk45bs38cr96ojjio7jto40khceet.apps.googleusercontent.com',
    iosBundleId: 'com.example.easytext.RunnerTests',
  );
}
