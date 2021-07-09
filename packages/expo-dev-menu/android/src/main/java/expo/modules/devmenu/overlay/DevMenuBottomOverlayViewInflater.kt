package expo.modules.devmenu.overlay

import android.annotation.SuppressLint
import android.content.Context
import android.view.LayoutInflater
import expo.modules.devmenu.databinding.BottomBarOverlayBinding
import expo.modules.devmenu.helpers.dpToPixels

class DevMenuBottomOverlayViewInflater(private val context: Context) {
  private val layoutInflater
    get() = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

  private val displayMetrics
    get() = context.resources.displayMetrics

  @SuppressLint("InflateParams")
  fun createView(): BottomBarOverlayBinding {
    return BottomBarOverlayBinding.inflate(layoutInflater)
  }

  fun yOffset(): Int {
    return dpToPixels(displayMetrics, 20)
  }
}
