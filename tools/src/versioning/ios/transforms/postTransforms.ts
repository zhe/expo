import chalk from 'chalk';

import { TransformPipeline } from '.';

export function postTransforms(versionName: string): TransformPipeline {
  return {
    logHeader(filePath: string) {
      console.log(`Post-transforming ${chalk.magenta(filePath)}:`);
    },
    transforms: [
      // react-native
      {
        paths: ['RCTRedBox.m', 'RCTLog.mm'],
        replace: /#if (ABI\d+_\d+_\d+)RCT_DEBUG/g,
        with: '#if $1RCT_DEV',
      },
      {
        paths: ['NSTextStorage+FontScaling.h', 'NSTextStorage+FontScaling.m'],
        replace: /NSTextStorage \(FontScaling\)/,
        with: `NSTextStorage (${versionName}FontScaling)`,
      },
      {
        paths: [
          'NSTextStorage+FontScaling.h',
          'NSTextStorage+FontScaling.m',
          'RCTTextShadowView.m',
        ],
        replace: /\b(scaleFontSizeToFitSize|scaleFontSizeWithRatio|compareToSize)\b/g,
        with: `${versionName.toLowerCase()}_rct_$1`,
      },
      {
        paths: 'RCTWebView.m',
        replace: /@"ABI\d+_\d+_\d+React-js-navigation"/,
        with: '@"react-js-navigation"',
      },
      {
        replace: new RegExp(`FB${versionName}ReactNativeSpec`, 'g'),
        with: 'FBReactNativeSpec',
      },
      {
        replace: new RegExp('\\b(Native\\w+Spec)\\b', 'g'),
        with: `${versionName}$1`,
      },
      {
        paths: 'RCTInspectorPackagerConnection.m',
        replace: /\b(RECONNECT_DELAY_MS)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: `${versionName}FBReactNativeSpec`,
        replace: /\b(NSStringToNativeAppearanceColorSchemeName|NativeAppearanceColorSchemeNameToNSString)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'RCTView.m',
        replace: /\b(SwitchAccessibilityTrait)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'RCTSpringAnimation.m',
        replace: /\b(MAX_DELTA_TIME)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'ModuleRegistry.cpp',
        replace: /(std::string normalizeName\(std::string name\) \{)/,
        with: `$1\n  if (name.compare(0, ${versionName.length}, "${versionName}") == 0) {\n    name = name.substr(${versionName.length});\n  }\n`,
      },
      {
        paths: 'ModuleRegistry.cpp',
        replace: /(\(name\.compare\(\d+, \d+, ")([^"]+)(RCT"\))/,
        with: '$1$3',
      },

      // Universal modules
      {
        paths: `UniversalModules/${versionName}EXScoped`,
        replace: /(EXScopedABI\d+_\d+_\d+ReactNative)/g,
        with: 'EXScopedReactNative',
      },
      {
        paths: `${versionName}EXFileSystem`,
        replace: new RegExp(`NSData\\+${versionName}EXFileSystem\\.h`, 'g'),
        with: `${versionName}NSData+EXFileSystem.h`,
      },
      {
        paths: [`${versionName}EXNotifications`, `${versionName}EXUpdates`],
        replace: new RegExp(
          `NSDictionary\\+${versionName}(EXNotificationsVerifyingClass|EXUpdatesRawManifest)\\.h`,
          'g'
        ),
        with: `${versionName}NSDictionary+$1.h`,
      },
      {
        // Versioned ExpoKit has to use versioned modules provider
        paths: 'EXVersionManager.mm',
        replace: /@"(ExpoModulesProvider)"/,
        with: `@"${versionName}$1"`,
      },

      // react-native-maps
      {
        paths: 'AIRMapWMSTile',
        replace: /\b(TileOverlay)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'AIRGoogleMapWMSTile',
        replace: /\b(WMSTileOverlay)\b/g,
        with: `${versionName}$1`,
      },

      // react-native-svg
      {
        paths: 'RNSVGRenderable.m',
        replace: /\b(saturate)\(/g,
        with: `${versionName}$1(`,
      },
      {
        paths: 'RNSVGPainter.m',
        replace: /\b(PatternFunction)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'RNSVGFontData.m',
        replace: /\b(AbsoluteFontWeight|bolder|lighter|nearestFontWeight)\(/gi,
        with: `${versionName}$1(`,
      },
      {
        paths: 'RNSVGTSpan.m',
        replace: new RegExp(`\\b(${versionName}RNSVGTopAlignedLabel\\s*\\*\\s*label)\\b`, 'gi'),
        with: 'static $1',
      },
      {
        paths: 'RNSVGMarker.m',
        replace: /\b(deg2rad)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'RNSVGMarkerPosition.m',
        replace: /\b(PathIsDone|rad2deg|SlopeAngleRadians|CurrentAngle|subtract|ExtractPathElementFeatures|UpdateFromPathElement)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'RNSVGMarkerPosition.m',
        replace: /\b(positions_|element_index_|origin_|subpath_start_|in_slope_|out_slope_|auto_start_reverse_)\b/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'RNSVGPathMeasure.m',
        replace: /\b(distance|subdivideBezierAtT)\b/g,
        with: `${versionName}$1`,
      },

      // react-native-webview
      {
        paths: 'RNCWebView.m',
        replace: new RegExp(`#import "objc/${versionName}runtime\\.h"`, ''),
        with: '#import "objc/runtime.h"',
      },
      {
        paths: 'RNCWebView.m',
        replace: /\b(_SwizzleHelperWK)\b/g,
        with: `${versionName}$1`,
      },
      {
        // see issue: https://github.com/expo/expo/issues/4463
        paths: 'RNCWebView.m',
        replace: /MessageHandlerName = @"ABI\d+_\d+_\d+ReactNativeWebView";/,
        with: `MessageHandlerName = @"ReactNativeWebView";`,
      },

      // react-native-reanimated
      {
        paths: 'EXVersionManager.mm',
        replace: /(_bridge_reanimated)/g,
        with: `${versionName}$1`,
      },
      {
        paths: 'NativeProxy.mm',
        replace: /@"ABI\d+_\d+_\d+RCTView"/g,
        with: `@"RCTView"`,
      },

      // react-native-shared-element
      {
        paths: 'RNSharedElementNode.m',
        replace: /\b(NSArray\s*\*\s*_imageResolvers)\b/,
        with: 'static $1',
      },

      // react-native-safe-area-context
      {
        paths: [
          'RCTView+SafeAreaCompat.h',
          'RCTView+SafeAreaCompat.m',
          'RNCSafeAreaProvider.m',
          'RNCSafeAreaView.m',
        ],
        replace: /\b(UIEdgeInsetsEqualToEdgeInsetsWithThreshold)\b/g,
        with: `${versionName}$1`,
      },
    ],
  };
}
