// Copyright 2015-present 650 Industries. All rights reserved.
package host.exp.exponent.kernel.services.sensors

import android.content.Context
import android.hardware.Sensor

class GyroscopeKernelService(context: Context) : SubscribableSensorKernelService(
  context
) {
  override val sensorType: Int
    get() = Sensor.TYPE_GYROSCOPE
}
