//
//  FieldDescriptor.swift
//  MirrorExtension
//
//  Created by jintao on 2020/1/2.
//  Copyright © 2020 jintao. All rights reserved.
//

import Foundation

// come from swiftReflection Records.h

import Foundation

struct FieldDescriptor {
    let mangledTypeNameOffset: Int32
    let superClassOffset: Int32
    let fieldDescriptorKind: Int8  // enum
    let fieldRecordSize: Int16
    let numFields: Int32
}

struct FieldRecord {
    let fieldRecordFlags: Int32
    let mangledTypeNameOffset: Int32
    let fieldNameOffset: Int32
}
