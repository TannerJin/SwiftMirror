//
//  MetadataKind.swift
//  MirrorExtension
//
//  Created by jintao on 2020/1/2.
//  Copyright © 2020 jintao. All rights reserved.
//

import Foundation

let MetadataKindIsNonType = 0x400
let MetadataKindIsNonHeap = 0x200
let MetadataKindIsRuntimePrivate = 0x100
let LastEnumerated = 0x7FF

public func isHeapMetadataKind(flag: Int) -> Bool {
    return flag & MetadataKindIsNonHeap == 0
}

public func swiftMedadataKind(flag: Int) -> Mirror.DisplayStyle? {
    if flag > LastEnumerated {
        return .class
    }
    
    switch flag {
    case (0 | MetadataKindIsNonHeap): return .struct
    case 0,                                                          // A class type
        (5 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap),  // An ObjC class wrapper
        (3 | MetadataKindIsNonHeap):                                 // A foreign class, such as a Core Foundation class
            return .class
    case (1 | MetadataKindIsNonHeap): return .enum
    case (1 | MetadataKindIsRuntimePrivate | MetadataKindIsNonHeap): return .tuple
    case (2 | MetadataKindIsNonHeap): return .optional
    default:
        return nil
    }
}
