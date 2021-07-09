package expo.modules.devmenu.overlay

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ValueAnimator
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import expo.modules.devmenu.databinding.BottomBarOverlayBinding


class DevMenuOverlayManager(private val windowManager: WindowManager, private val viewInflater: DevMenuBottomOverlayViewInflater, private val onToggle: () -> Unit) {
  private var currentOverlayViewBinding: BottomBarOverlayBinding? = null
  private val yOffset = viewInflater.yOffset()
  private var state = State.Extended
  private var originalWidth: Int? = null

  enum class State {
    InAnimation, Collapsed, Extended
  }

  fun showOverlay() {
    if (currentOverlayViewBinding != null) {
      return
    }
    state = State.Extended

    val params = getDefaultWindowParams(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT)
    params.gravity = Gravity.BOTTOM or Gravity.CENTER
    params.y = yOffset

    val overlayViewBinding = viewInflater.createView()
    windowManager.addView(overlayViewBinding.root, params)

    overlayViewBinding.container.setOnClickListener {
      if (state == State.InAnimation) {
        return@setOnClickListener
      }

      onToggle()
    }

    overlayViewBinding.container.setOnLongClickListener {
      if (state == State.Collapsed) {
        state = State.InAnimation

        val slideAnimator = ValueAnimator
          .ofInt(overlayViewBinding.container.width, originalWidth!!)
          .setDuration(250)

        slideAnimator.addUpdateListener {
          val value = it.animatedValue as Int
          overlayViewBinding.container.translationX = (originalWidth!! - value).toFloat()
          overlayViewBinding.container.layoutParams.width = value
          overlayViewBinding.container.requestLayout()
        }

        val animationSet = AnimatorSet()
        animationSet.interpolator = AccelerateDecelerateInterpolator()
        animationSet.play(slideAnimator)
        animationSet.addListener(object : AnimatorListenerAdapter() {
          override fun onAnimationEnd(animation: Animator?) {
            super.onAnimationEnd(animation)
            state = State.Extended
            overlayViewBinding.text.text = "DevMenu"
            overlayViewBinding.button.visibility = View.VISIBLE
          }
        })
        animationSet.start()

        return@setOnLongClickListener true
      }

      return@setOnLongClickListener false
    }

    overlayViewBinding.button.setOnClickListener {
      if (state != State.Extended) {
        return@setOnClickListener
      }

      state = State.InAnimation
      originalWidth = overlayViewBinding.container.width
      val slideAnimator = ValueAnimator
        .ofInt(overlayViewBinding.container.width, 100)
        .setDuration(250)

      slideAnimator.addUpdateListener {
        val value = it.animatedValue as Int
        overlayViewBinding.container.translationX = (originalWidth!! - value).toFloat()
        overlayViewBinding.container.layoutParams.width = value
        overlayViewBinding.container.requestLayout()
      }

      val animationSet = AnimatorSet()
      animationSet.interpolator = AccelerateDecelerateInterpolator()
      animationSet.play(slideAnimator)
      animationSet.addListener(object : AnimatorListenerAdapter() {
        override fun onAnimationEnd(animation: Animator?) {
          super.onAnimationEnd(animation)
          state = State.Collapsed
        }
      })
      animationSet.start()

      overlayViewBinding.text.text = "..."
      overlayViewBinding.button.visibility = View.GONE
    }
    currentOverlayViewBinding = overlayViewBinding
  }

  fun hideOverlay() {
    currentOverlayViewBinding?.root?.let {
      windowManager.removeView(it)
    }
    currentOverlayViewBinding = null
  }

  private fun getDefaultWindowParams(width: Int, height: Int): WindowManager.LayoutParams {
    return WindowManager.LayoutParams(
      width,
      height,
      if (Build.VERSION.SDK_INT >= 26) {
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
      } else {
        WindowManager.LayoutParams.TYPE_PHONE
      },
      WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
        or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
      PixelFormat.TRANSLUCENT)
      .apply {
        windowAnimations = android.R.style.Animation_Translucent
      }
  }

}
