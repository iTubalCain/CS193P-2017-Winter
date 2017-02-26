//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Tubal Cain on 2/23/17.
//  Copyright © 2017 Will Wagers. All rights reserved.///
//
// struct: no inheritance, free initializer, lives in Stack, copy-on-write

import Foundation

struct CalculatorModel {
    
// MARK: - Data structures
    
    /**
     Defines the types of calculator function which can be handled on pressing 
     a function key. Functions include constant values like pi, unary functions 
     like square root, binary functions like add and subtract, and equals 
     to trigger eva;uation.
     */
    
    private enum Function {
        case constant(Double)
        case equals
        case nullaryFunction(() -> Double)
        case unaryFunction((Double) -> Double)
        case binaryFunction((Double, Double) -> Double)
    }
    
    private var functions: Dictionary<String, Function> =
        [
            "e":    Function.constant(M_E),
            "π":    Function.constant(Double.pi),
            "=":    Function.equals,
            "rand": Function.nullaryFunction(CalculatorModel.randomNumber),
            "%":    Function.unaryFunction({ $0 / 100.0 }),
            "√":    Function.unaryFunction(sqrt),
            "x²":   Function.unaryFunction({ $0 * $0 }),
            "1/X":  Function.unaryFunction({ 1 / $0 }),
            "abs":  Function.unaryFunction(abs),
            "log":  Function.unaryFunction(log10),
            "±":    Function.unaryFunction({ -$0 }),
            "+":    Function.binaryFunction({ $0 + $1 }),
            "−":    Function.binaryFunction({ $0 - $1 }),
            "×":    Function.binaryFunction({ $0 * $1 }),
            "÷":    Function.binaryFunction({ $0 / $1 })
        ]
    
    private var accumulator: Double?
    private var pendingBinaryFunction: PendingBinaryFunction?
    private var tape = " "      // record of keystrokes
    
    private struct PendingBinaryFunction {
        let function:       ((Double, Double) -> Double)
        let firstOperand:   Double
        
        func perform(secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    var calculationPending : Bool {     // isPartialResult()
        get {
            return (pendingBinaryFunction != nil)
        }
    }
    
    mutating func reset() {
        accumulator = nil
        tape = ""
//        description = " "
        pendingBinaryFunction = nil
//        internalProgram.removeAll()
    }
    
    var description : String {
        get {
            return tape
        }
        set {
            tape += newValue + " "
        }
    }
    
    var result: Double? { get { return accumulator } }  
    
    // MARK: - Functions

    mutating func performPendingBinaryFunction() {
        if (pendingBinaryFunction != nil) && (accumulator != nil) {
            accumulator = pendingBinaryFunction!.perform(secondOperand: accumulator!)
        }
        pendingBinaryFunction = nil
    }
    
    /**
     Performs the function designated by the function key pressed.
     
     - Parameter functionKey: Function calculator key pressed by the user.
     */
    
    mutating func performFunction(_ functionKey: String) {
//        internalProgram.append(symbol as AnyObject)
        if let function = functions[functionKey] {
            switch function {
                case .equals:   break
                default:        description = functionKey
            }
            switch function {
                case .constant(let constant):
                    accumulator = constant
//                    tape = ""
                case .equals:
                    performPendingBinaryFunction()
                case .nullaryFunction(let function):
                    accumulator = function()
                case .unaryFunction(let function):
                    if accumulator != nil {
                        accumulator = function(accumulator!)
                    }
                case .binaryFunction(let function):
                    if accumulator != nil {
                        performPendingBinaryFunction()
                        pendingBinaryFunction = PendingBinaryFunction(function: function, firstOperand: accumulator!)
                    }
            }
        }
    }
    
    mutating func setAccumulator(_ operand: Double) {
        accumulator = operand
//        internalProgram.append(operand as AnyObject)
        if let operandString = formatter.string(from: NSNumber(value: operand)) {
            description = operandString

        }
    }
    
    // MARK: - Function implementations
    
    private static func randomNumber() -> Double {
        return Double(arc4random()).truncatingRemainder(dividingBy: 1000001.0) * 0.000001
    }

}
