
/**
 A protocol that allows initializing the object with a dictionary.
 */
public protocol DictionaryConvertible: AnyMethodArgument {
  init()
  init(dictionary: [AnyHashable : Any?])
}

/**
 Provides the default implementation of `ConvertibleFromDictionary` protocol.
 */
public extension DictionaryConvertible {
  /**
   Initializes an object from given dictionary. Only members wrapped by `@bind` will be set in the object.
   */
  init(dictionary: [AnyHashable : Any?]) {
    self.init()

    forEachBoundMember(self) { key, value in
      value.set(dictionary[key] as Any?)
    }
  }

  /**
   Converts an object back to the dictionary. Only members wrapped by `@bind` will be set in the dictionary.
   */
  func toDictionary() -> [String: Any?] {
    var dict = [String: Any?]()

    forEachBoundMember(self) { key, value in
      dict[key] = value.get()
    }
    return dict
  }
}

fileprivate func forEachBoundMember(_ object: DictionaryConvertible, _ closure: (String, AnyBoundValue) -> Void) {
  let mirror = Mirror(reflecting: object)

  mirror.children.forEach { (label, value) in
    guard let value = value as? AnyBoundValue,
          let key = value.customKey ?? normalizeMirrorChildLabel(label) else {
      return
    }
    closure(key, value)
  }
}

fileprivate func normalizeMirrorChildLabel(_ label: String?) -> String? {
  return (label != nil && label!.starts(with: "_")) ? String(label!.dropFirst()) : label
}

protocol AnyBoundValue {
  var customKey: String? { get }

  func get() -> Any?
  func set(_ newValue: Any?)
}

@propertyWrapper
public class bind<Type>: AnyBoundValue {
  public private(set) var wrappedValue: Type
  public private(set) var customKey: String?

  public init(wrappedValue: Type) {
    self.wrappedValue = wrappedValue
  }

  public convenience init(wrappedValue: Type, key: String?) {
    self.init(wrappedValue: wrappedValue)
    self.customKey = key
  }

  func get() -> Any? {
    return wrappedValue
  }

  func set(_ newValue: Any?) {
    self.wrappedValue = newValue as! Type
  }
}
