import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

import 'app.dart';

/// Requests all required permissions on app startup.
/// This will only show system dialogs for permissions that are not yet granted.
/// Note: nearbyWifiDevices is optional and won't block the app if not granted.
Future<void> _requestAllPermissionsOnStartup() async {
  final requiredPermissions = [
    // Location is required for Wi-Fi scanning on older Android versions
    Permission.locationWhenInUse,
    // Bluetooth runtime permissions (Android 12+ granular permissions)
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
  ];

  final optionalPermissions = [
    // Android 13+ permission for nearby Wi-Fi devices (optional)
    if (Platform.isAndroid) Permission.nearbyWifiDevices,
  ];

  // Check current status of required permissions
  final requiredStatuses = await Future.wait(
    requiredPermissions.map((p) => p.status),
  );

  // Request only required permissions that are not granted
  for (int i = 0; i < requiredPermissions.length; i++) {
    if (!requiredStatuses[i].isGranted) {
      await requiredPermissions[i].request();
    }
  }

  // Try to request optional permissions, but don't fail if they're not granted
  for (final permission in optionalPermissions) {
    try {
      final status = await permission.status;
      if (!status.isGranted) {
        await permission.request();
      }
    } catch (e) {
      // Ignore errors for optional permissions
      // They may not be available on this Android version
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request all required permissions on first app launch
  // This will only show dialogs for permissions that are not yet granted
  await _requestAllPermissionsOnStartup();

  runApp(const ProviderScope(child: EasaccApp()));
}
// //دلوقتي انا عايز اغير شوية حجات 
// 1- انا عايز الغي الصفحة بتاعت requiremnt permissions 
// 2- عايز اول لم افتح الابلكيشن اول مره خالص يطلب من اليوزر كل البرميشن ال محتاجهم او لم يكون في بيرميشن مش موجود يعني مش عايز كل مره افتح البرنامج يطلبهم مني 
// 3- هبعتلك التاسك كامله و افهمها ونفذها لو في حاجه ناقصه 
// التاسك اهيه
// Create ios and android application .

// social media login:
// login page (Facebook - google).
// 2.Setting page:

// Note: Please send the Task to hiring@easacc.com
// This app must contain 3 pages:
// 1.

// - Input to insert web url to show in web view
// page(user can change this url).
// - Access network devices (wifi - bluetooth) like
// printer in dropdown list.
// 3. web view page:
// Show the site that has been set in the setting.


// متنفذش ال Auth متعملش اي حاجه في ولا حتي ui كأنهم مش طالبين دي 
// //════════ Exception caught by widgets library ═══════════════════════════════════
// The following _TypeError was thrown building Builder:
// Null check operator used on a null value

// The relevant error-causing widget was:
//     MaterialApp MaterialApp:file:///E:/course/easacc/lib/app.dart:51:12

// When the exception was thrown, this was the stack:
// #0      _WidgetsAppState._onGenerateRoute.<anonymous closure> (package:flutter/src/widgets/app.dart:1476:48)
// app.dart:1476
// #1      MaterialPageRoute.buildContent (package:flutter/src/material/page.dart:53:55)
// page.dart:53
// #2      MaterialRouteTransitionMixin.buildPage (package:flutter/src/material/page.dart:133:27)
// page.dart:133
// #3      _ModalScopeState.build.<anonymous closure>.<anonymous closure> (package:flutter/src/widgets/routes.dart:1107:53)
// routes.dart:1107
// #4      Builder.build (package:flutter/src/widgets/basic.dart:7716:48)
// basic.dart:7716
// #5      StatelessElement.build (package:flutter/src/widgets/framework.dart:5701:49)
// framework.dart:5701
// #6      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5631:15)
// framework.dart:5631
// #7      Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #8      StatelessElement.update (package:flutter/src/widgets/framework.dart:5707:5)
// framework.dart:5707
// #9      Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #10     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #11     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #12     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #13     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #14     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #15     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #16     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #17     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #18     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #19     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #20     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #21     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #22     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #23     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #24     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #25     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #26     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #27     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #28     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #29     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #30     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #31     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #32     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #33     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #34     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #35     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #36     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #37     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #38     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #39     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #40     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #41     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #42     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #43     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #44     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #45     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #46     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #47     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #48     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #49     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #50     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #51     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #52     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #53     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #54     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #55     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #56     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #57     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #58     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #59     StatelessElement.update (package:flutter/src/widgets/framework.dart:5707:5)
// framework.dart:5707
// #60     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #61     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #62     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #63     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #64     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #65     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #66     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #67     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #68     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #69     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #70     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #71     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #72     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #73     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #74     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #75     ProxyElement.update (package:flutter/src/widgets/framework.dart:5960:5)
// framework.dart:5960
// #76     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:112:11)
// inherited_notifier.dart:112
// #77     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #78     SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #79     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #80     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #81     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #82     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #83     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #84     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #85     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #86     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #87     ProxyElement.update (package:flutter/src/widgets/framework.dart:5960:5)
// framework.dart:5960
// #88     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #89     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #90     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #91     ProxyElement.update (package:flutter/src/widgets/framework.dart:5960:5)
// framework.dart:5960
// #92     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #93     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #94     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #95     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #96     StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #97     Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #98     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #99     Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #100    StatelessElement.update (package:flutter/src/widgets/framework.dart:5707:5)
// framework.dart:5707
// #101    Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #102    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #103    Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #104    StatelessElement.update (package:flutter/src/widgets/framework.dart:5707:5)
// framework.dart:5707
// #105    Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #106    SingleChildRenderObjectElement.update (package:flutter/src/widgets/framework.dart:6921:14)
// framework.dart:6921
// #107    Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #108    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #109    Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #110    ProxyElement.update (package:flutter/src/widgets/framework.dart:5960:5)
// framework.dart:5960
// #111    Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #112    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #113    Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #114    ProxyElement.update (package:flutter/src/widgets/framework.dart:5960:5)
// framework.dart:5960
// #115    Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #116    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #117    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #118    Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #119    StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #120    Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #121    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #122    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #123    Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #124    StatefulElement.update (package:flutter/src/widgets/framework.dart:5817:5)
// framework.dart:5817
// #125    Element.updateChild (package:flutter/src/widgets/framework.dart:3941:15)
// framework.dart:3941
// #126    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5656:16)
// framework.dart:5656
// #127    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5794:11)
// framework.dart:5794
// #128    Element.rebuild (package:flutter/src/widgets/framework.dart:5347:7)
// framework.dart:5347
// #129    BuildScope._tryRebuild (package:flutter/src/widgets/framework.dart:2694:15)
// framework.dart:2694
// #130    BuildScope._flushDirtyElements (package:flutter/src/widgets/framework.dart:2753:11)
// framework.dart:2753
// #131    BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3048:18)
// framework.dart:3048
// #132    WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:1176:21)
// binding.dart:1176
// #133    RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:475:5)
// binding.dart:475
// #134    SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1397:15)
// binding.dart:1397
// #135    SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1318:9)
// binding.dart:1318
// #136    SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1176:5)
// binding.dart:1176
// #137    _invoke (dart:ui/hooks.dart:312:13)
// hooks.dart:312
// #138    PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:427:5)
// platform_dispatcher.dart:427
// #139    _drawFrame (dart:ui/hooks.dart:283:31)
// hooks.dart:283

// ════════════════════════════════════════════════════════════════════════════════
// D/ProfileInstaller( 6449): Installing profile for com.example.easacc
// I/MESA    ( 6449): exportSyncFdForQSRILocked: call for image 0x7c4672e4e510 hos timage handle 0x70002000008ec
// I/MESA    ( 6449): exportSyncFdForQSRILocked: got fd: 158
// I/MESA    ( 6449): exportSyncFdForQSRILocked: call for image 0x7c4672e3e9d0 hos timage handle 0x70002000008ed
// I/MESA    ( 6449): exportSyncFdForQSRILocked: got fd: 164
