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
    public var superClassMirror: SwiftMirror? {
        get {
            getSuperClassMirror()
        }
    }
    private let superClass: Int?
    
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
        let fieldReflectionPointer = contextDescriptorPointer.advanced(by: 4*MemoryLayout<Int32>.size)
        let fieldReflectionOffset = contextDescriptorPointer.assumingMemoryBound(to: TypeDescriptorHeader.self).pointee.fieldReflection
        
        let fieldDescriptorPointer = fieldReflectionPointer.advanced(by: Int(fieldReflectionOffset))
        
        let fieldsCount = Int(fieldDescriptorPointer.assumingMemoryBound(to: FieldDescriptor.self).pointee.numFields)
        let fieldRecordPointer = fieldDescriptorPointer.advanced(by: MemoryLayout<FieldDescriptor>.stride).assumingMemoryBound(to: FieldRecord.self)
        
        var children = [Child](repeating: nil, count: fieldsCount)
        
        for i in 0..<fieldsCount {
            let fieldRecord = fieldRecordPointer.advanced(by: i)
            let address = UnsafeRawPointer(fieldRecord) + 2*4
            let nameOffset = fieldRecord.pointee.fieldNameOffset
            
            let cStr = (address+Int(nameOffset)).assumingMemoryBound(to: UInt8.self)
            let str = String(cString: cStr)
            children[i] = str
        }
        
        return children
    }
    
    // MARK: - SuperClassMirror
    private func getSuperClassMirror() -> SwiftMirror? {
        guard let superClassAddress = self.superClass, let pointer = UnsafePointer<Int>(bitPattern: superClassAddress) else { return nil }
        
        #if swift(>=5)
        let className = "Swift._SwiftObject"
        #else
        let className = "SwiftObject"  // 4.2
        #endif
        
        if let swiftObjectClass = objc_getClass(className), superClassAddress == unsafeBitCast(swiftObjectClass, to: (UInt64, UInt64, UInt64, UInt64).self).0 {
            return nil
        }
        if let NSObjectClass = objc_getClass("NSObject"), superClassAddress == unsafeBitCast(NSObjectClass, to: (UInt64, UInt64, UInt64, UInt64).self).0 {
            return nil
        }
        return SwiftMirror(typePointer: pointer)
    }
}
