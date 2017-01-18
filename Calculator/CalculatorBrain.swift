//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Marc FAMILARI on 1/9/17.
//  Copyright © 2017 Marc FAMILARI. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var description = " "
    private var digitTouched = false
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        digitTouched = true
        if isPartialResult == false {
            description = " "
        }
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
        case Random
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π"     : Operation.Constant(M_PI),
        "e"     : Operation.Constant(M_E),
        "±"     : Operation.UnaryOperation({ -$0 }),
        "√"     : Operation.UnaryOperation(sqrt),
        "sin"   : Operation.UnaryOperation(sin),
        "tan"   : Operation.UnaryOperation(tan),
        "×"     : Operation.BinaryOperation({ $0 * $1 }),
        "+"     : Operation.BinaryOperation({ $0 + $1 }),
        "-"     : Operation.BinaryOperation({ $0 - $1 }),
        "÷"     : Operation.BinaryOperation({ $0 / $1 }),
        "="     : Operation.Equals,
        "C"     : Operation.Clear,
        "rand"  : Operation.Random
    ]
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operand = op as? String {
                        performOperation(symbol: operand)
                    }
                }
            }
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var isPartialResult: Bool {
        get {
            if pending != nil {
                return true
            }
            return false
        }
    }
    
    private var lastButtonTouched = Button(type: .Clear, size: 0)
    
    private struct Button {
        var type: CalculatorBrain.Operation
        var size: Int
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private func clear() {
        accumulator = 0.0
        pending = nil
        description = " "
        internalProgram.removeAll()
    }
    
    func random0to1() -> Double {
        let intMax = Double(UInt32.max)
        
        return Double(arc4random()) / intMax
    }

    private func unaryDescscription(symbol: String, strAccumulator: String) {
        if digitTouched == true {
            deleteLastActionIfNecessary()
            lastButtonTouched.size = Int(strlen(strAccumulator)) + Int(symbol.characters.count) + 2
            description += symbol + "(" + strAccumulator + ")"
            return
        }
        if description != " " {
            description = symbol + "(" + description + ")"
        }
        lastButtonTouched.size = 0
    }
    
    private func binaryDescription(symbol: String, strAccumulator: String) {
        if digitTouched == true {
            deleteLastActionIfNecessary()
            description += strAccumulator + symbol
        } else {
            description += symbol
        }
    }
    
    private func equalDescription(strAccumulator: String) {
        if digitTouched == true {
            deleteLastActionIfNecessary()
            description += strAccumulator
        } else if case .BinaryOperation = lastButtonTouched.type {
            description += strAccumulator
        }
    }
    
    private func randomDescription(strAccumulator: String) {
        deleteLastActionIfNecessary()
        lastButtonTouched.size = Int(strlen(strAccumulator))
        if case .Equals = lastButtonTouched.type {
            description = strAccumulator
        } else {
            description += strAccumulator
        }
    }
    
    private func constantDescription(symbol: String) {
        deleteLastActionIfNecessary()
        if case .Equals = lastButtonTouched.type {
            description = symbol
        } else {
            description += symbol
        }
    }
    
    private func deleteLastActionIfNecessary() {
        if description != " " {
            let constant = lastButtonTouched.type
            switch constant {
            case .Random, .UnaryOperation:
                let index = description.index(description.endIndex, offsetBy: (0 - lastButtonTouched.size))
                description = description.substring(to: index)
            case .Constant:
                description = description.substring(to: description.index(before: description.endIndex))
            default:
                break
            }
        }
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let constant = operations[symbol] {
            let strAccumulator = percentFormatter(doubleToConvertInString: accumulator)
            switch constant {
            case .Constant(let value):
                constantDescription(symbol: symbol)
                accumulator = value
            case .UnaryOperation(let foo):
                unaryDescscription(symbol: symbol, strAccumulator: strAccumulator)
                accumulator = foo(accumulator)
            case .BinaryOperation(let function):
                binaryDescription(symbol: symbol, strAccumulator: strAccumulator)
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                equalDescription(strAccumulator: strAccumulator)
                executePendingBinaryOperation()
            case .Clear:
                clear()
            case .Random:
                accumulator = random0to1()
                randomDescription(strAccumulator: percentFormatter(doubleToConvertInString: accumulator))
            }
            digitTouched = false
            lastButtonTouched.type = constant
        }
    }
    
     func percentFormatter(doubleToConvertInString: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        
        if let ret = formatter.string(for: doubleToConvertInString) {
            return ret
        }
        return String(doubleToConvertInString)
    }

    var result: Double {
        get {
            return accumulator
        }
    }
    
    var history: String {
        get {
            if isPartialResult {
                return description + "..."
            } else if description != " " {
                return description + "="
            }
            return description
        }
    }
}
