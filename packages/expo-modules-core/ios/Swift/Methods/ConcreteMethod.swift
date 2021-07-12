
func castReturnValue<T>(_ value: T) -> AnyMethodArgument {
  print(String(describing: T.self))
  let m = Mirror(reflecting: value)
  return Conversions.toExportable(value)!
}

func castReturnValue<T>(_ value: T) -> AnyMethodArgument where T: RawRepresentable {
  return Conversions.toExportable(value.rawValue)!
}

public enum TestEnum: Int {
  case zero = 0
  case one = 1
  case two = 2
}

public struct ConcreteMethod<Args, ReturnType>: AnyMethod {
  public typealias ClosureType = (Args) -> ReturnType

  public let name: String

  public let takesPromise: Bool

  public let argumentsCount: Int

  public var queue: DispatchQueue?

  let closure: ClosureType

  let argTypes: [AnyArgumentType]

  init(
    _ name: String,
    argTypes: [AnyArgumentType],
    queue: DispatchQueue? = nil,
    _ closure: @escaping ClosureType
  ) {
    self.name = name
    self.argTypes = argTypes
    self.queue = queue
    self.closure = closure
    self.takesPromise = argTypes.last?.canCast(Promise.self) ?? false
    self.argumentsCount = argTypes.count - (takesPromise ? 1 : 0)
  }

  public func call(args: [Any?], promise: Promise) {
    do {
      let finalArgs = try castArguments(args) + (takesPromise ? [promise] : [])
      let tuple = try Conversions.toTuple(finalArgs) as! Args
      let returnedValue = closure(tuple)

      if !takesPromise {
        let castedReturn = castReturnValue(returnedValue)
        promise.resolve(castedReturn)
      }
    } catch let error {
      promise.reject(error)
    }
  }

  private func argumentType(atIndex index: Int) -> AnyArgumentType? {
    return (0..<argTypes.count).contains(index) ? argTypes[index] : nil
  }

  private func castArguments(_ args: [Any?]) throws -> [AnyMethodArgument?] {
    return try args.enumerated().map { (index, arg) in
      guard let desiredType = argumentType(atIndex: index) else {
        return nil
      }

      // If the type of argument matches the desired type, just cast and return it.
      // This usually covers all cases for primitive types or plain dicts and arrays.
      if desiredType.canCast(arg) {
        return desiredType.cast(arg)
      }

      // TODO: (@tsapeta) Handle structs convertible to dictionary
//      // If we get here, the argument can be converted (not casted!) to the desired type.
//      if let arg = arg as? [AnyHashable : Any?], let dt = desiredType.castWrappedType(ConvertibleFromDictionary.Type.self) {
//        return dt.init(dictionary: arg)
//      }

      // TODO: (@tsapeta) Handle convertible arrays
      throw Errors.IncompatibleArgumentType(
        argument: arg,
        atIndex: index,
        desiredType: type(of: desiredType)
      )
    }
  }
}
