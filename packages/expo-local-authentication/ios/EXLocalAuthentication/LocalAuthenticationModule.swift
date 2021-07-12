import LocalAuthentication
import ExpoModulesCore

public class LocalAuthenticationModule: Module {
  public func definition() -> ModuleDefinition {
    name("ExpoLocalAuthentication")

    method("supportedAuthenticationTypesAsync") { () -> [AuthenticationType] in
      var results = [AuthenticationType]()

      if biometryType == .touchID {
        results.append(.fingerprint)
      }
      if biometryType == .faceID {
        results.append(.facial)
      }
      return results
    }

    method("hasHardwareAsync") { () -> Bool in
      let authContext = LAContext()
      var error: NSError?
      let isSupported = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

      return isSupported || error?.code != LAError.biometryNotAvailable.rawValue
    }

    method("isEnrolledAsync") { () -> Bool in
      let authContext = LAContext()
      var error: NSError?
      let isSupported = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

      return isSupported && error == nil
    }

    method("getEnrolledLevelAsync") { () -> SecurityLevel in
      let authContext = LAContext()
      var error: NSError?

      if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) && error == nil {
        return .secret
      }
      if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) && error == nil {
        return .biometric
      }
      return .none
    }

    method("authenticateAsync") { (options: AuthenticateOptions, promise: Promise) in
      let authContext = LAContext()
      let policy: LAPolicy = options.disableDeviceFallback ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
      var warning: String?

      authContext.localizedFallbackTitle = options.fallbackLabel
      authContext.localizedCancelTitle = options.cancelLabel
      authContext.interactionNotAllowed = false

      if biometryType == .faceID && Bundle.main.infoDictionary?["NSFaceIDUsageDescription"] == nil {
        warning = "FaceID is available but has not been configured. To enable FaceID, provide `NSFaceIDUsageDescription`."
      }

      if options.disableDeviceFallback && warning != nil {
        // If the warning message is set (NSFaceIDUsageDescription is not configured) then we can't use
        // authentication with biometrics — it would crash, so let's just resolve with no success.
        // We could reject, but we already resolve even if there are any errors, so sadly we would need to introduce a breaking change.
        promise.resolve([
          "success": false,
          "error": "missing_usage_description",
          "warning": warning as Any
        ])
        return
      }

      authContext.evaluatePolicy(policy, localizedReason: options.promptMessage) { success, error in
        promise.resolve([
          "success": success,
          "error": convertError(error),
          "warning": warning
        ])
      }
    }
  }
}

enum AuthenticationType: Int {
  case fingerprint = 1
  case facial = 2
}

enum SecurityLevel: Int {
  case none = 0
  case secret = 1
  case biometric = 2
}

struct AuthenticateOptions: DictionaryConvertible {
  @bind var promptMessage: String = ""
  @bind var cancelLabel: String?
  @bind var fallbackLabel: String?
  @bind var disableDeviceFallback: Bool = false
}

var biometryType: LABiometryType = {
  let authContext = LAContext()
  authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  return authContext.biometryType
}()

fileprivate func convertError(_ error: Error?) -> String? {
  guard let error = error as? LAError else {
    return nil
  }
  switch error.code {
  case .systemCancel:
    return "system_cancel"
  case .appCancel:
    return "app_cancel"
  case .biometryLockout, .touchIDLockout:
    return "lockout"
  case .userFallback:
    return "user_fallback"
  case .userCancel:
    return "user_cancel"
  case .biometryNotAvailable, .touchIDNotAvailable:
    return "not_available"
  case .invalidContext:
    return "invalid_context"
  case .biometryNotEnrolled, .touchIDNotEnrolled:
    return "not_enrolled"
  case .passcodeNotSet:
    return "passcode_not_set"
  case .authenticationFailed:
    return "authentication_failed"
  case .notInteractive:
    return "not_interactive"
  @unknown default:
    return "Unknown error: \(error.localizedDescription)"
  }
}
