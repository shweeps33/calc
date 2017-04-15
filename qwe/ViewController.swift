//
//  ViewController.swift
//  qwe
//
//  Created by Admin on 03.01.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var history: UILabel!
    
    private var defaultDisplayText = "0"
    private var defaultHistoryText = ""
    private var brain = CalculatorBrain()

    private var userIsInTheMiddleOfFloatingPointNummer = false
    
    private var historyString = ""
    
    private var userIsInTheMiddleOfTyping = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNummer = false
            }
        }
    }
    
    private var displayValue: Double? {
        get {
            if Double(display.text!) != nil {
                return Double(display.text!)!
            } else {
                display.text = defaultDisplayText
            }
            return Double(display.text!)!
            
        }
        set {
            if newValue != nil {
                display.text = newValue!.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", newValue!) : String(newValue!)
            } else {
                display.text = defaultDisplayText
            }
            
        }
    }
    
    private var displayHistory: String? {
        get {
            return String(history.text!)!
        }
        set {
            history.text = String(newValue!)
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        var digit = sender.currentTitle!
        //historyString = historyString + digit
        if userIsInTheMiddleOfTyping {
            
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
            if digit == "." {
                if userIsInTheMiddleOfFloatingPointNummer {
                    return
                }
                if !userIsInTheMiddleOfTyping {
                    digit = "0."
                }
                display.text = textCurrentlyInDisplay + digit
                userIsInTheMiddleOfFloatingPointNummer = true
            }
            
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
//    @IBAction func setX(_ sender: UIButton) {
//        userIsInTheMiddleOfTyping = false
//        if displayValue != nil {
//            brain.varValues["\(sender.currentTitle)"] = displayValue
//        }
//    }
//    
//    @IBAction func getX(_ sender: UIButton) {
//        if userIsInTheMiddleOfTyping {
//            brain.setOperand(operand: brain.varValues["\(sender.currentTitle)"]!)
//            userIsInTheMiddleOfTyping = false
//        }
//
//    }
    
    @IBAction private func cleanAll(_ sender: UIButton) {
        displayValue = nil
    }
    
//    @IBAction func backspace() {
//        if let displayNotEmpty = display.text {
//            display.text = String(displayNotEmpty.characters.dropLast())
//        } else {
//            display.text = defaultDisplayText
//        }
//
//    }
    
//    var savedProgram = CalculatorBrain.PropertyList.self
//    
//    @IBAction func save() {
//        savedProgram = brain.program as! CalculatorBrain.PropertyList.Protocol
//    }
//    
//    @IBAction func restore() {
//        if savedProgram != nil {
//            brain.program = savedProgram as CalculatorBrain.PropertyList
//            displayValue = brain.result
//        }
//    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        
        let mathSymbol = sender.currentTitle
        
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            
        }
        
        if mathSymbol != "AC" {
            if brain.isPartialResult {
                displayHistory! = brain.description + "..."
            } else {
                displayHistory! = brain.description + "="
            }
        } else {
            displayHistory! = defaultHistoryText
        }
        displayValue! = brain.result
        
    }
    
    
}
