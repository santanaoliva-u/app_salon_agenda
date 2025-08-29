import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Agregar tu API key aquí
    GMSServices.provideAPIKey("TU_API_KEY_AQUI")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
