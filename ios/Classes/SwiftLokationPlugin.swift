import Flutter
import UIKit
import CoreLocation

public class SwiftLokationPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    lazy var manager: CLLocationManager = {
        let m = CLLocationManager()
        m.delegate = self
        return m
    }()

    var positionHandler: SwiftLokationPositionStreamHandler!
    var serviceHandler: SwiftLokationServiceStreamHandler!

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "lokation_method_channel", binaryMessenger: registrar.messenger())
        let instance = SwiftLokationPlugin()

        registrar.addMethodCallDelegate(instance, channel: channel)

        let pec = FlutterEventChannel(name: "lokation_position_event_channel", binaryMessenger: registrar.messenger())
        let sec = FlutterEventChannel(name: "lokation_service_event_channel", binaryMessenger: registrar.messenger())

        instance.positionHandler = SwiftLokationPositionStreamHandler()
        instance.serviceHandler = SwiftLokationServiceStreamHandler()

        pec.setStreamHandler(instance.positionHandler)
        sec.setStreamHandler(instance.serviceHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startPositionUpdates":
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            manager.distanceFilter = kCLDistanceFilterNone
            manager.startUpdatingLocation()
            result(nil)
        case "stopPositionUpdates":
            manager.stopUpdatingLocation()
            result(nil)
        case "isServiceEnabled":
            print("CLLocationManager.locationServicesEnabled(): \(CLLocationManager.locationServicesEnabled())")
            result(CLLocationManager.locationServicesEnabled())
        case "checkPermission":
            let perm: CLAuthorizationStatus
            if #available(iOS 14, *) {
                perm = manager.authorizationStatus
            } else {
                perm = CLLocationManager.authorizationStatus()
            }
            result(perm == .authorizedAlways || perm == .authorizedWhenInUse)
        case "requestPermission":
            manager.requestWhenInUseAuthorization()
            authorizationCallback = { success in
                result(success)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    var authorizationCallback: ((Bool) -> ())?

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let result = status == .authorizedAlways || status == .authorizedWhenInUse
        if let authorizationCallback = authorizationCallback {
            authorizationCallback(result)
        }
        authorizationCallback = nil

        for eventSink in serviceHandler.eventSinkList {
            eventSink(CLLocationManager.locationServicesEnabled())
        }
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let perm = manager.authorizationStatus
        let result = perm == .authorizedAlways || perm == .authorizedWhenInUse
        if let authorizationCallback = authorizationCallback {
            authorizationCallback(result)
        }
        authorizationCallback = nil
    }

    @available(iOS 6.0, *)
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let data: [String: Any] = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
            for eventSink in positionHandler.eventSinkList {
                eventSink(data)
            }
        }
    }


}

class SwiftLokationPositionStreamHandler: NSObject, FlutterStreamHandler {
    var eventSinkList: [FlutterEventSink] = []

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSinkList.append(events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // fatalError("onCancel(withArguments:) has not been implemented")
        return nil
    }
}

class SwiftLokationServiceStreamHandler: NSObject, FlutterStreamHandler {
    var eventSinkList: [FlutterEventSink] = []

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSinkList.append(events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // fatalError("onCancel(withArguments:) has not been implemented")
        return nil
    }
}