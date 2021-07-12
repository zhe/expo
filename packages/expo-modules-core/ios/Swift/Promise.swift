
public struct Promise: AnyMethodArgument {
  public typealias ResolveClosure = (Any?) -> Void
  public typealias RejectClosure = (String?, String?, Error?) -> Void

  public var resolver: ResolveClosure
  public var rejecter: RejectClosure

  public func resolve(_ dict: [String: Any?]) {
    resolver(dict)
  }

  public func resolve(_ value: Any?) {
    resolver(Conversions.toExportable(value))
  }

//  public func resolve<T: AnyMethodArgument>(_ value: T?) {
//    resolver(Conversions.toExportable(value))
//  }
//
//  public func resolve<T: AnyMethodArgument>(_ value: [T?]) {
//    resolver(value.enumerated().map { Conversions.toExportable($1) })
//  }
//
//  public func resolve<T: RawRepresentable>(_ value: T?) where T.RawValue: AnyMethodArgument {
//    resolver(Conversions.toExportable(value))
//  }
//
//  public func resolve<T: RawRepresentable>(_ value: [T?]) where T.RawValue: AnyMethodArgument {
//    resolver(value.enumerated().map { Conversions.toExportable($1) })
//  }

  public func reject(_ code: String?, _ description: String?, _ error: Error? = nil) -> Void {
    rejecter(code, description, error)
  }

  public func reject(_ description: String?, _ error: Error? = nil) -> Void {
    rejecter("ERR", description, error)
  }

  public func reject(_ error: Error) -> Void {
    reject("ERR", error.localizedDescription, error)
  }
}
