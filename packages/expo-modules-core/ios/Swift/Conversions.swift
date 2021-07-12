
public protocol PrimitiveValue {}
extension Bool: PrimitiveValue {}
extension Int: PrimitiveValue {}
extension Double: PrimitiveValue {}
extension String: PrimitiveValue {}

extension RawRepresentable {
  func asAny() -> Any {
    return rawValue
  }
}

internal class Conversions {
  /**
   Converts given value to the exportable type.
   */
  static func toExportable(_ value: Any?) -> AnyMethodArgument? {
    if let value = value as? PrimitiveValue {
      return value as? AnyMethodArgument
    }
    if let value = value as? DictionaryConvertible {
      return value.toDictionary()
    }
    return nil
  }

  /**
   Converts raw representable values (typed enums) to the exportable type.
   `RawRepresentable` is a protocol with associated types so it can only be used with `where` clause.
   */
  static func toExportable<T: RawRepresentable>(_ value: T?) -> AnyMethodArgument? where T.RawValue: AnyMethodArgument {
    print("toExportable: RawRepresentable")
    return toExportable(value?.rawValue)
  }

  static func unwrapRawValue<T: RawRepresentable>(_ value: T) -> PrimitiveValue where T.RawValue: PrimitiveValue {
    return value.rawValue
  }

  /**
   Converts an array to tuple. Because of tuples nature, it's not possible to convert an array of any size, so we can support only up to some fixed size.
   */
  static func toTuple(_ array: [Any?]) throws -> Any? {
    switch (array.count) {
    case 0:
      return ()
    case 1:
      return (array[0])
    case 2:
      return (array[0], array[1])
    case 3:
      return (array[0], array[1], array[2])
    case 4:
      return (array[0], array[1], array[2], array[3])
    case 5:
      return (array[0], array[1], array[2], array[3], array[4])
    case 6:
      return (array[0], array[1], array[2], array[3], array[4], array[5])
    case 7:
      return (array[0], array[1], array[2], array[3], array[4], array[5], array[6])
    case 8:
      return (array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7])
    case 9:
      return (array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7], array[8])
    case 10:
      return (array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7], array[8], array[9])
    default:
      throw Errors.ArrayTooLong(size: array.count, limit: 10)
    }
  }
}
