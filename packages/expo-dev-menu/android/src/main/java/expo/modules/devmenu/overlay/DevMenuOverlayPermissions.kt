package expo.modules.devmenu.overlay

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings

const val REQUEST_CODE_ASK_PERMISSIONS = 1201


fun requiresPermission(context: Context) = Build.VERSION.SDK_INT >= 23 && !Settings.canDrawOverlays(context)

fun startPermissionRequester(activity: Activity) {
  if (Build.VERSION.SDK_INT >= 23 && requiresPermission(activity)) {
    val intent = Intent(
      Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
      Uri.parse("package:" + activity.packageName));
    activity.startActivityForResult(
      intent,
      REQUEST_CODE_ASK_PERMISSIONS)
  }
}

