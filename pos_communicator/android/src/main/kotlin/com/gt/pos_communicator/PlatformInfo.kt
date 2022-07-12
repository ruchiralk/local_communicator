package com.gt.pos_communicator

class PlatformInfo {

    companion object {
        const val TAG = "PlatformInfo"

        fun platformVersion(): String {
            return  "Android ${android.os.Build.VERSION.RELEASE}"
        }
    }
}