package expo.modules.devmenu.helpers

import android.util.DisplayMetrics
import kotlin.math.roundToInt

fun dpToPixels(displayMetrics: DisplayMetrics, dpSize: Int): Int {
  return (dpSize * (displayMetrics.densityDpi / DisplayMetrics.DENSITY_DEFAULT)).toFloat().roundToInt()
}
