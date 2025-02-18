import ProjectDescription

extension Product {
  public static var current: Self {
    if case let .string(productType) = Environment.productType,
      let type = Product(rawValue: productType)
    {
      return type
    }
    return .staticFramework
  }
}
