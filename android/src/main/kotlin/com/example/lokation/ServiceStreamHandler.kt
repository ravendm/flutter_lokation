package com.example.lokation

import android.util.Log
import io.flutter.plugin.common.EventChannel

class ServiceStreamHandler : EventChannel.StreamHandler {
    companion object {
        const val TAG = "ServiceStreamHandler"
    }

    private val sinkList: MutableList<EventChannel.EventSink> = mutableListOf()

    fun onService(status: Boolean) {
        Log.d(TAG, "onService $status")
        for (eventSink in sinkList) {
            eventSink.success(status)
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