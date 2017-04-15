//
//  CalculatorBrain.swift
//  qwe
//
//  Created by Admin on 03.01.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

func powOperation(op1: Double, op2: Double) -> Double {
    return pow(op1, op2)
}
func factorial (op1: Int) -> Int {
    let fac = op1 == 0 ? 1 : factorial(op1: op1-1)*op1
    return fac
}

class CalculatorBrain
{
    private var accumulator = 0.0
    private var memory = 0.0
    private var internalProgram = [AnyObject]()
    private var defaultDisplayText = "0"
    private var defaultHistoryText = ""
    private var equalsWasInUse = false
    var description = ""
    var isPartialResult = false
    var varValues: Dictionary<String, Double> = [:]
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    func setOperandX(varName: String) {
        internalProgram.append(varName as AnyObject)
    }
    
    
    
    private enum Operation {
        case Constant(Double) //here we are associating Double with Constant
        case UnaryOperation((Double) -> Double) // associating a function that gets Double and return Double
        case BinaryOperation((Double, Double) -> Double)
        case PowOperationSqr
        case Factorial
        case Equals
        case CleanAll
        case Backspace
        case MemOperation(String)
        case MemClear
        case MemDisplay
        case ChangeSign
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : .Constant(M_PI),
        "e" : .Constant(M_E),
        "√" : .UnaryOperation(sqrt),
        "^2" : .PowOperationSqr,
        "×" : .BinaryOperation({ $0 * $1 }),
        "÷" : .BinaryOperation({ $0 / $1 }),
        "−" : .BinaryOperation({ $0 - $1 }),
        "+" : .BinaryOperation({ $0 + $1 }),
        "^" : .BinaryOperation(powOperation),
        "=" : .Equals,
        "←" : .Backspace,
        "AC" : .CleanAll,
        "m+" : .MemOperation("+"),
        "m-" : .MemOperation("-"),
        "mc" : .MemClear,
        "mr" : .MemDisplay,
        "!" : .Factorial,
        "+/-" : .ChangeSign
    ]
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol] {
            
            
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
            case .UnaryOperation(let associatedFunction):
                accumulator = associatedFunction(accumulator)
            case .BinaryOperation(let associatedFunction):
                if equalsWasInUse {
                    description = String(accumulator)
                } else {
                    description.append(String(accumulator))
                }
                isPartialResult = true
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: associatedFunction, firstOperand: accumulator) //saving sign of operation and a first operand
            case .PowOperationSqr:
                if equalsWasInUse {
                    description = String(accumulator)
                } else {
                    description.append(String(accumulator))
                }
                accumulator = pow(accumulator, 2)
            case .Equals:
                equalsWasInUse = true
                if isPartialResult {
                    description.append(String(accumulator))
                    isPartialResult = false
                }
                executePendingBinaryOperation()
            case .Backspace:
                executeBackspaceOperation()
            case .CleanAll:
                clear()
            case .MemOperation(let associatedValue):
                //memOperation(op1: associatedConstantValue)
                if Double(associatedValue + String(accumulator)) != nil {
                     memory += Double(associatedValue + String(accumulator))!
                }
            case .MemClear:
                memory = 0.0
            case .MemDisplay:
                accumulator = memory
            case .Factorial:
                accumulator = Double(factorial(op1: Int(accumulator)))
            case .ChangeSign:
                accumulator = -accumulator
            }
            if symbol != "=" && symbol != "AC" {
                description.insert("(", at: description.startIndex)
                description.append(")" + symbol)
            }
            
        }
   
    }
    
    private func memOperation(op1: Double) {
        memory += op1
    }
    
    private func executeBackspaceOperation () {
        var accumString = accumulator.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", accumulator) : String(accumulator)
        if accumString.characters.count <= 1 {
            accumulator = 0
        } else {
            accumString = String(accumString.characters.dropLast(1))
            accumulator = Double(accumString)!
            
        }
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo? //contain current state of BinaryOperation (saves the sign of operation and a first operand)
    
    
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    func clear() {
        accumulator = 0.0
        description = defaultHistoryText
        isPartialResult = false
        pending = nil
        internalProgram.removeAll()
        equalsWasInUse = false
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList{
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
}
