//
//  Mirror.swift
//  MirrorExtension
//
//  Created by jintao on 2020/1/2.
//  Copyright © 2020 jintao. All rights reserved.
//

import Foundation

public struct SwiftMirror {
    public typealias Child = String?
    
    public let children: [Child]
    
    public let displayStyle: Mirror.DisplayStyle?
    
    private let superClass: Int?
    
    public var superClassMirror: SwiftMirror? {
        get {
            getSuperClassMirror()
        }
    }
    
    
    public init(type: Any.Type) {
        let pointer = unsafeBitCast(type, to: UnsafePointer<Int>.self)
        self = Self.init(typePointer: pointer)
    }
    
    fileprivate init(typePointer pointer: UnsafePointer<Int>) {
        displayStyle = swiftMedadataKind(flag: pointer.pointee)
                
        switch displayStyle {
        case .struct,
             .enum:
            children = Self.structConfigure(pointer)
            superClass = nil
        case .class:
            children = Self.classConfigure(pointer)
            superClass = pointer.advanced(by: 1).pointee
        default:
            children = []
            superClass = nil
        }
    }
    
    // MARK: - Children
    private static func structConfigure(_ typePointer: UnsafePointer<Int>) -> [Child] {
        let contextDescriptor = typePointer.advanced(by: 1).pointee
        guard let contextDescriptorPointer = UnsafeMutableRawPointer(bitPattern: contextDescriptor) else { return [] }
        return configureChildren(contextDescriptorPointer)
    }
    
    private static func classConfigure(_ typePointer: UnsafePointer<Int>) -> [Child] {
        let contextDescriptor = typePointer.advanced(by: 8).pointee
        guard let contextDescriptorPointer = UnsafeMutableRawPointer(bitPattern: contextDescriptor) else { return [] }
        return configureChildren(contextDescriptorPointer)
    }
    
    private static func configureChildren(_ contextDescriptorPointer: UnsafeMutableRawPointer) -> [Child] {
        // advance to TypeDescriptorHeader.fieldReflection
        let fieldReflectionPointer = contextDescriptorPointer.advanced(by: 4*MemoryLayout<Int32>.size)
        let fieldReflectionOffset = contextDescriptorPointer.assumingMemoryBound(to: TypeDescriptorHeader.self).pointee.fieldReflection
        
        // FieldDescriptor
        let fieldDescriptorPointer = fieldReflectionPointer.advanced(by: Int(fieldReflectionOffset)).assumingMemoryBound(to: FieldDescriptor.self)
        
        // FieldRecords
        let fieldsCount = Int(fieldDescriptorPointer.pointee.numFields)
        let fieldRecordPointer = UnsafeMutableRawPointer(fieldDescriptorPointer.advanced(by: 1)).assumingMemoryBound(to: FieldRecord.self)
        
        var children = [Child](repeating: nil, count: fieldsCount)
        
        for i in 0..<fieldsCount {
            let fieldRecord = fieldRecordPointer.advanced(by: i)
            // advance to FieldRecord.fieldNameOffset
            let fieldNameAddress = UnsafeRawPointer(fieldRecord).advanced(by: 2*MemoryLayout<Int32>.size)
            let fieldNameOffset = Int(fieldRecord.pointee.fieldNameOffset)
            
            let fieldNameCStr = (fieldNameAddress+fieldNameOffset).assumingMemoryBound(to: CChar.self)
            let fieldName = String(cString: fieldNameCStr)
            children[i] = fieldName   // doesn't copy on write
        }
        return children
    }
    
    // MARK: - SuperClassMirror
    private func getSuperClassMirror() -> SwiftMirror? {
        guard let superClassAddress = self.superClass, let pointer = UnsafePointer<Int>(bitPattern: superClassAddress) else { return nil }
        
        // MemoryLayout of Any = (UInt64, UInt64, UInt64, UInt64)
        if let swiftObjectClass = objc_getClass("Swift._SwiftObject"), superClassAddress == unsafeBitCast(swiftObjectClass, to: (UInt64, UInt64, UInt64, UInt64).self).0 {
            return nil
        }
        if let NSObjectClass = objc_getClass("NSObject"), superClassAddress == unsafeBitCast(NSObjectClass, to: (UInt64, UInt64, UInt64, UInt64).self).0 {
            return nil
        }
        return SwiftMirror(typePointer: pointer)
    }
}
