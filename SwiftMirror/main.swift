//
//  main.swift
//  MirrorExtension
//
//  Created by jintao on 2020/1/2.
//  Copyright © 2020 jintao. All rights reserved.
//

import Foundation

print("Hello, Mirror!\n")

// MARK: - Struct
struct StructType {
    var a_1: String
    var a_2: Int?
    var a_3: String?
    var a_1_1: String?
    var a_2_2: Int?
    var a_3_3: String?
    var a_1_1_1: String?
    var a_2_2_2: Int?
    var a_3_3_3: String?
}

print("Struct:")
let structMirror = SwiftMirror(type: StructType.self)
structMirror.children.forEach({ print($0!) })
print("")


// MARK: - Enum
enum EnumType {
    case aa_1
    case aa_2
    case aa_3
}

print("Enum:")
let enumMirror = SwiftMirror(type: EnumType.self)
enumMirror.children.forEach({ print($0!) })
print("")


// MARK: - Class
class SuperClassType: NSObject {
    var b_1: NSObject?
}

class ClassType: SuperClassType {
    var c_1: String?
    var c_2: Int?
    var c_3: String?
}

print("Class:")
let classMirror = SwiftMirror(type: ClassType.self)
classMirror.children.forEach({ print($0!) })

print("SuperClass:")
classMirror.superClassMirror?.children.forEach({ print($0!) })
