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
    private var keepOn = true
    
    func setOperand(operand: Double) {
        accumulator = operand
        keepOn = false
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
        "Rand"  : Operation.Random
    ]
    
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
    }
    
    func random0to1() -> Double {
        let intMax = Double(UInt32.max)
        
        return Double(arc4random()) / intMax
    }

    private func unaryDescscription(symbol: String, strAccumulator: String) {
        if keepOn == false {
            if description != " " {
                lastButtonTouched.size = Int(strlen(strAccumulator)) + Int(strlen(symbol)) + 2
            }
            description += symbol + "(" + strAccumulator + ")"
        }
        else if description != " " {
            lastButtonTouched.size = 0
            description = symbol + "(" + description + ")"
        }
    }
    
    private func binaryDescription(symbol: String, strAccumulator: String) {
        if keepOn == false {
            deleteLastActionIfNecessary()
            description += strAccumulator + symbol
        } else {
            description += symbol
        }
    }
    
    private func equalDescription(strAccumulator: String) {
        if keepOn == false {
            deleteLastActionIfNecessary()
            description += strAccumulator
        } else if case .BinaryOperation = lastButtonTouched.type {
            description += strAccumulator
        }
    }
    
    private func randomDescription(strAccumulator: String) {
        deleteLastActionIfNecessary()
        lastButtonTouched.size = Int(strlen(strAccumulator))
        description += strAccumulator
    }
    
    private func deleteLastActionIfNecessary() {
        if case .Random = lastButtonTouched.type {
            let index = description.index(description.endIndex, offsetBy: (0 - lastButtonTouched.size))
            description = description.substring(to: index)
        } else if case .Constant = lastButtonTouched.type  {
            description = description.substring(to: description.index(before: description.endIndex))
        } else if case .UnaryOperation = lastButtonTouched.type {
            let index = description.index(description.endIndex, offsetBy: (0 - lastButtonTouched.size))
            description = description.substring(to: index)
        }
    }
    
    func performOperation(symbol: String) {
        if let constant = operations[symbol] {
            let strAccumulator = percentFormatter(doubleToConvertInString: accumulator)
            switch constant {
            case .Constant(let value):
                deleteLastActionIfNecessary()
                description += symbol
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
            keepOn = true
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
