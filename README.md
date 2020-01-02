
# SwiftMirror

## Usage

1. Struct and Enum

```swift
struct StructType {
    var a_1: String?
    var a_2: Int?
    var a_3: String?
}

// original Mirror
let mirror = Mirror(reflecting: StructType.init())
mirror.children.forEach({ print($0.label!) }    // print a_1, a_2, a_3


// Now, SwiftMirror:
let structMirror = SwiftMirror(type: StructType.self)
structMirror.children.forEach({ print($0!) })   // print a_1, a_2, a_3
```

```swift
enum EnumType {
    case aa_1
    case aa_2
    case aa_3
}

let enumMirror = SwiftMirror(type: EnumType.self)
enumMirror.children.forEach({ print($0!) })   // print aa_1, aa_2, aa_3
```

2. Class

```swift
class SuperClassType: NSObject {
    var b_1: NSObject?
}

class ClassType: SuperClassType {
    var c_1: String?
    var c_2: Int?
    var c_3: String?
}

let classMirror = SwiftMirror(type: ClassType.self)
classMirror.children.forEach({ print($0!) })  // print c_1, c_2, c_3
classMirror.superClassMirror?.children.forEach({ print($0!) })  // print b_1
```
