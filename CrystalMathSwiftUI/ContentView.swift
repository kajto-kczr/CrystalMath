//
//  ContentView.swift
//  CrystalMathSwiftUI
//
//  Created by Kajetan Kuczorski on 07.07.20.
//  Copyright © 2020 Kajetan Kuczorski. All rights reserved.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var searchedNum: Int = 0
    var dimension: Int = 4
    var difficulty: Int = 2
    var possibleCombos: [[Int]] = []
    @State var buttonValues: [Int] = []
    @State var buttonValuesWithoutSimplest: [Int] = []
    @State var allValues: [Int] = []
    @State var i = 0
    
    var body: some View {
        ZStack {
            Color.offWhite
            Text("Searched Number: \(searchedNum)")
                .fontWeight(.bold)
                .background(RoundedRectangle(cornerRadius: 25)
                    .fill(Color.offWhite)
                    .frame(width: 300, height: 100)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5))
                .foregroundColor(.gray)
            VStack(alignment: .center, spacing: 30, content: {
                ForEach(0..<4) {i in
                    HStack(alignment: .center, spacing: 30, content: {
                        ForEach(0..<4) { j in
                            Button(action: {
                                self.buttonPressed()
                            }) {
                                Text(self.buttonText(int: [i, j]))
                                    .foregroundColor(.gray)
                                    .fontWeight(.heavy)
                            }
                            .buttonStyle(NeumorphicButtonStyle())
                        }
                    })
                }
            })
        }.onAppear(perform: {
            self.startOfTheGame()
        })
            .edgesIgnoringSafeArea(.all)
    }
    
    func buttonText(int: [Int]) -> String {
        let a = int[0]; let b = int[1]
        if buttonValues.isEmpty {
            return "EMPTY"
        } else {
            let title = buttonValues[a*b]
            return "\(title)"
        }
    }
    
    func startOfTheGame() {
        searchedNum = getRandomInt(difficulty: difficulty)
        for i in 1..<searchedNum {
            allValues.append(i)
        }
        let firstNum = Int.random(in: 1..<searchedNum)
        let secondNum = searchedNum - firstNum
        print("\(firstNum) + \(secondNum) = \(searchedNum)")
        buttonValues.append(contentsOf: [firstNum, secondNum])
        var leftCount = dimension*dimension - 2
        allValues.shuffle()
        
        while leftCount > 0 {
            let num = allValues.first!
            buttonValuesWithoutSimplest.append(num)
            if !hasPossibilities(sNumber: searchedNum, maK: 2) {
                if !buttonValues.contains(num) {
                    buttonValues.append(num)
                    allValues.remove(at: 0)
                    leftCount -= 1
                }
            } else {
                buttonValuesWithoutSimplest = buttonValuesWithoutSimplest.filter { $0 != num }
            }
            print("Left Count: \(leftCount)")
        }
        buttonValues.shuffle()
        
//        buttonValues += buttonValuesWithoutSimplest
        print(buttonValues)
    }
    
    
    
    func buttonPressed() {
        print("Button was pressed")
    }
    
    func getRandomInt(difficulty d: Int) -> Int {
        switch d {
        case 0:
            return Int.random(in: 5...20)
        case 1:
            return Int.random(in: 10...100)
        case 2:
            return Int.random(in: 50...300)
        case 3:
            return Int.random(in: 100...1000)
        default:
            return 1
        }
    }
    
    func newButton(text: String, action: @escaping () -> Void) -> some View {
        
        let button = Button(action: action) {
            self.newText(text)
        }
        
        return button
    }
    
    func newText(_ text: String) -> some View {
        let text = Text(text)
            .fontWeight(.bold)
            .font(.title)
            .padding()
            .cornerRadius(40)
            .foregroundColor(.white)
            //        .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.white, lineWidth: 3)
        )
        
        
        
        return text
    }
    
    func hasPossibilities(sNumber: Int, maK: Int) -> Bool {
        for k in 1...maK {
                for combo in combos(elements: buttonValuesWithoutSimplest[0..<buttonValuesWithoutSimplest.count], k: k) {
                    var amount = 0
                    for number in combo {
                        amount += number
                    }
    
                    if amount == sNumber {
                        return true
                    } else {
                        return false
                    }
                }
            }
//            if possibleCombos.isEmpty {
//                return false
//            } else {
//                return true
//            }
        return false
        }
    
    func combos<T>(elements: ArraySlice<T>, k: Int) -> [[T]] {
        guard k >= 1 else {
            return [[]]
        }
        
        guard let first = elements.first else {
            return []
        }
        
        let head = [first]
        let subCombos = combos(elements: elements.dropFirst(), k: k-1)
        var ret = subCombos.map { head + $0 }
        ret += combos(elements: elements.dropFirst(), k: k)
        
        return ret
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(30)
            .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6, alignment: .center)
            .contentShape(Circle())
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(Color.offWhite)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                        )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                        )
                    } else {
                        Circle()
                            .fill(Color.offWhite)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    }
                }
        )
    }
}

extension Color {
    static let offWhite = Color(red: 225/255, green: 225/255, blue: 235/255)
    static let darkStart = Color(red: 50/255, green: 60/255, blue: 65/255)
    static let darkEnd = Color(red: 25/255, green: 25/255, blue: 30/255)
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}


