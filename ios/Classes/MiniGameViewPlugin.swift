import Flutter
import UIKit

public class MiniGameViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mini_game_view", binaryMessenger: registrar.messenger())
    let instance = MiniGameViewPlugin()
      let factory = MyCustomViewFactory(messenger: registrar.messenger())
         registrar.register(factory, withId: "my_custom_view")
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
