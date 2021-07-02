package expo.modules.updates;

import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;

import com.facebook.react.bridge.JavaScriptContextHolder;
import com.facebook.react.bridge.ReactApplicationContext;

import org.unimodules.core.BasePackage;
import org.unimodules.core.ExportedModule;
import org.unimodules.core.interfaces.ApplicationLifecycleListener;
import org.unimodules.core.interfaces.InternalModule;
import org.unimodules.core.interfaces.ReactNativeHostHandler;

import java.util.Collections;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class UpdatesPackage extends BasePackage {
  @Override
  public List<InternalModule> createInternalModules(Context context) {
    return Collections.singletonList((InternalModule) new UpdatesService(context));
  }

  @Override
  public List<ExportedModule> createExportedModules(Context context) {
    return Collections.singletonList((ExportedModule) new UpdatesModule(context));
  }

  @Override
  public List<? extends ReactNativeHostHandler> createReactNativeHostHandlers(Context context) {
    final ReactNativeHostHandler handler = new ReactNativeHostHandler() {
      private boolean mUseDeveloperSupport = false;

      @Override
      public void onRegisterJSIModules(@NonNull ReactApplicationContext reactApplicationContext,
                                       @NonNull JavaScriptContextHolder jsContext) {
      }

      @Nullable
      @Override
      public String getJSBundleFile() {
        return mUseDeveloperSupport
          ? null
          : UpdatesController.getInstance().getLaunchAssetFile();

      }

      @Nullable
      @Override
      public String getBundleAssetName() {
        return mUseDeveloperSupport
          ? null
          : UpdatesController.getInstance().getBundleAssetName();
      }

      @Override
      public void onWillCreateReactInstanceManager(boolean useDeveloperSupport) {
        mUseDeveloperSupport = useDeveloperSupport;
        if (!mUseDeveloperSupport) {
          UpdatesController.initialize(context);
        }
      }
    };
    return Collections.singletonList(handler);
  }
}
