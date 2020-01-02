//
//  ContextDescriptor.swift
//  MirrorExtension
//
//  Created by jintao on 2020/1/2.
//  Copyright © 2020 jintao. All rights reserved.
//

import Foundation

// include struct and class
struct TypeDescriptorHeader {
    let king: Int32     // struct: 51 00 00 00;  class: 50 00 00 80
    let parent: Int32
    let nameOffset: Int32
    let fieldTypes: Int32
    let fieldReflection: Int32
}
