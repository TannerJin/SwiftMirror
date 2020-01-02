//
//  main.swift
//  MirrorExtension
//
//  Created by jintao on 2020/1/2.
//  Copyright © 2020 jintao. All rights reserved.
//

import Foundation

print("Hello, Mirror!")

// MARK: - Struct
struct A {
    var a_1: String?
    var a_2: Int?
    var a_3: String?
}

print("Struct:")
let structMirror = SwiftMirror(type: A.self)
structMirror.children.forEach({ print($0!) })
print("")

// MARK: - Enum
enum AA {
    case aa_1
    case aa_2
    case aa_3
}

print("Enum:")
let enumMirror = SwiftMirror(type: AA.self)
enumMirror.children.forEach({ print($0!) })
print("")

// MARK: - Class
class B: NSObject {
    var b_1: NSObject?
}

class C: B {
    var c_1: String?
    var c_2: Int?
    var c_3: String?
}

print("Class:")
let classMirror = SwiftMirror(type: C.self)
classMirror.superClassMirror?.children.forEach({ print($0!) })
classMirror.children.forEach({ print($0!) })
