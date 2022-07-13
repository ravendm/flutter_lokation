package com.example.lokation

import android.location.Location
import android.location.LocationListener
import android.os.Bundle

class LokationStatusListener(private val onStatus: (Boolean) -> Unit) : LocationListener {
    override fun onLocationChanged(location: Location) {

    }

    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {

    }

    override fun onProviderEnabled(provider: String) {
        onStatus(true)
    }

    override fun onProviderDisabled(provider: String) {
        onStatus(false)
    }
}

class LokationListener(private val provider: String, private val onLocation: (Location) -> Unit) :
    LocationListener {
    override fun onLocationChanged(location: Location) {
        // Log.d("LokationListener", "$provider $location")
        onLocation(location)
    }

    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {

    }

    override fun onProviderEnabled(provider: String) {

    }

    override fun onProviderDisabled(provider: String) {

    }
}