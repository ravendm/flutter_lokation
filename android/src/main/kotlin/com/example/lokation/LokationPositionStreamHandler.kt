package com.example.lokation

import android.location.Location
import android.util.Log
import io.flutter.plugin.common.EventChannel

class LokationPositionStreamHandler : EventChannel.StreamHandler {
    companion object {
        const val TAG = "LokationStreamHandler"
    }

    private val sinkList: MutableList<EventChannel.EventSink> = mutableListOf()

    fun onLocation(location: Location) {
        for (eventSink in sinkList) {
            eventSink.success(
                mapOf(
                    "latitude" to location.latitude,
                    "longitude" to location.longitude,
                    "accuracy" to location.accuracy,
                )
            )
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "onListen $arguments")
        if (events == null) {
            return
        }
        sinkList.add(events)
    }

    override fun onCancel(arguments: Any?) {

    }
}