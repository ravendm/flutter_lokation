package com.example.lokation

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry

/** LokationPlugin */
class LokationPlugin : FlutterPlugin, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, ActivityAware {
    companion object {
        const val TAG = "LokationPlugin"
    }

    private lateinit var locationEventChannel: EventChannel
    private lateinit var serviceEventChannel: EventChannel
    private lateinit var methodChannel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var locationPositionStreamHandler: LokationPositionStreamHandler
    private lateinit var serviceStreamHandler: ServiceStreamHandler

    private var locationStatusListener: LokationStatusListener? = null

    private val listeners = mutableMapOf<String, LocationListener>()

    private val locationManager: LocationManager by lazy {
        context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "startPositionUpdates" -> startPositionUpdates(call, result)
            "stopPositionUpdates" -> stopPositionUpdates(call, result)
            "isServiceEnabled" -> isServiceEnabled(call, result)
            "checkPermission" -> checkPermission(call, result)
            "requestPermission" -> requestPermission(call, result)
            else -> result.notImplemented()
        }
    }

    private fun startPositionUpdates(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        Log.d(TAG, "startPositionUpdates")

        val enabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        if (enabled) {
            requestLocationUpdates()
        }
        result.success(null)
    }

    private fun stopPositionUpdates(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        Log.d(TAG, "stopPositionUpdates")
        // locationManager.removeUpdates(this)
        result.success(null)
    }

    private fun isServiceEnabled(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        result.success(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "lokation_method_channel")
        methodChannel.setMethodCallHandler(this)

        locationPositionStreamHandler = LokationPositionStreamHandler()
        locationEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "lokation_position_event_channel")
        locationEventChannel.setStreamHandler(locationPositionStreamHandler)

        serviceStreamHandler = ServiceStreamHandler()
        serviceEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "lokation_service_event_channel")
        serviceEventChannel.setStreamHandler(serviceStreamHandler)


        if (checkPermission()) {
            setupStatusListener();
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    private fun onLocationChanged(location: Location) {
        Log.d(TAG, "onLocationChanged ${location.latitude} ${location.longitude} ${location.accuracy}")
        locationPositionStreamHandler.onLocation(location)
    }

    private fun setupStatusListener() {
        Log.d(TAG, "setupStatusListener")
        locationStatusListener = LokationStatusListener(::onServiceStatus)
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0L, 0F, locationStatusListener!!)
    }

    private fun onServiceStatus(status: Boolean) {
        serviceStreamHandler.onService(status)
        if (status) {
            requestLocationUpdates()
        }
    }

    private fun requestLocationUpdates() {
        Log.d(TAG, "requestLocationUpdates")
        for (provider in locationManager.allProviders) {
            if (!listeners.containsKey(provider)) {
                listeners[provider] = LokationListener(provider, ::onLocationChanged)
            }
            locationManager.requestLocationUpdates(provider, 0L, 0F, listeners[provider]!!)
        }
    }

    private fun checkPermission(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        result.success(checkPermission())
    }

    private fun checkPermission(): Boolean {
        val permissions = listOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)
        for (permission in permissions) {
            val result = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
            if (result != PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return true
    }

    private val requestedPermissions: List<String> =
        listOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)

    private var permissionResult: MethodChannel.Result? = null

    private fun requestPermission(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (activity == null) {
            Log.d(TAG, "requestPermission activity == null")
        }
        permissionResult = result
        ActivityCompat.requestPermissions(activity!!, requestedPermissions.toTypedArray(), 999)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        Log.d(TAG, "onRequestPermissionsResult $requestCode $permissions $grantResults")

        if (requestCode != 999) {
            return false
        }

        if (permissionResult == null) {
            return false
        }

        val results: MutableMap<String, Boolean> = mutableMapOf()

        for (permission in requestedPermissions) {
            results[permission] = false
            val index = permissions.indexOf(permission)
            if (index == -1) {
                continue
            }
            val grandResult = grantResults[index]
            if (grandResult == PackageManager.PERMISSION_GRANTED) {
                results[permission] = true
            }

            // Log.d(TAG, ActivityCompat.shouldShowRequestPermissionRationale(activity!!, permission).toString())
        }

        val result = results.values.all { it }

        Log.d(TAG, "onRequestPermissionsResult result: $result")

        permissionResult!!.success(result)
        permissionResult = null

        if (result && locationStatusListener == null) {
            setupStatusListener()
        }

        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }
}
