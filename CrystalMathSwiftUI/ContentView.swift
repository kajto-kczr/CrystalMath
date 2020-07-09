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
    
    @State var searchedNum: Int = 0
    @State var dimension: Int = 3
    var difficulty: Int = 1
    //    var possibleCombos: [[Int]] = []
    @State var buttonValues: [Int] = []
    @State var buttonValuesWithoutSimplest: [Int] = []
    @State var allValues: [Int] = []
    @State var currentlySelectedIds: [Int] = []
    @State var newNumComing: Bool = false
    @State var bgColor: Color = Color.offWhite
    @State var foregroundColor: Color = Color.gray
    @State var menuIsTapped: Bool = false
    
    var body: some View {
        ZStack {
            Color.offWhite
            VStack(alignment: .trailing, spacing: 0, content: {
                HStack {
                    FloatingMenu()
                        .offset(x: dimension < 4 ? 100 : 50, y: -80)
                        .frame(width: 80, height: 80, alignment: .topTrailing)
                }
                VStack(alignment: .center, spacing: 30, content: {
                    Text("Searched Number: \(searchedNum)")
                        .fontWeight(.bold)
                        .background(
                            Group {
                                if !menuIsTapped {
                                    RoundedRectangle(cornerRadius: 25)
                                    .fill(bgColor)
                                    .frame(width: 300, height: 100)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                                }
                                
                        })
                        .foregroundColor(menuIsTapped ? Color.clear : foregroundColor)
                    Spacer()
                        .frame(height: 50)
                    ForEach(0..<dimension) {i in
                        HStack(alignment: .center, spacing: 30, content: {
                            ForEach(0..<self.dimension) { j in
                                Button(action: {
                                    self.buttonPressed(int: [i, j])
                                    
                                    guard !self.newNumComing else {
                                        return
                                    }
                                    self.updateSelectedIds(id: i*self.dimension+j)
                                    
                                    print("Currently Selected Ids: \(self.currentlySelectedIds)")
                                }) {
                                    Text(self.assignValuesToButtons(int: [i, j]))
                                        .foregroundColor(.gray)
                                        .fontWeight(.heavy)
                                }
                                .buttonStyle(NeumorphicButtonStyle(id: i*self.dimension+j, selectedIds: self.$currentlySelectedIds))
                            }
                        })
                    }
                })
            })
            
        }.onAppear(perform: {
            self.startOfTheGame()
        })
            .edgesIgnoringSafeArea(.all)
    }
    
    func assignValuesToButtons(int: [Int]) -> String {
        guard !buttonValues.isEmpty else {
            return "0"
        }
        
        let a = int[0]
        let b = int[1]
        
        let x = a * dimension + b
        
        return String(buttonValues[x])
    }
    
    func updateSelectedIds(id: Int) {
        if buttonAlreadySelected(id: id) {
            currentlySelectedIds = currentlySelectedIds.filter({ $0 != id })
        } else {
            currentlySelectedIds.append(id)
        }
    }
    
    func changeColors() {
        menuIsTapped.toggle()
    }
    
    func buttonAlreadySelected(id: Int) -> Bool {
        for i in currentlySelectedIds {
            if i == id {
                return true
            }
        }
        return false
    }
    
    func startOfTheGame() {
        var repetitionCounter = 0
        buttonValues.removeAll()
        allValues.removeAll()
        UserDefaults.standard.set(dimension, forKey: "dimension")
        UserDefaults.standard.set(difficulty, forKey: "lvl")
        
        searchedNum = getRandomInt(difficulty: difficulty)
        for i in 1..<searchedNum {
            allValues.append(i)
        }
        
        let firstNum = Int.random(in: 1..<searchedNum)
        let secondNum = searchedNum - firstNum
        print("\(firstNum) + \(secondNum) = \(searchedNum)")
        allValues = allValues.filter({ $0 != firstNum && $0 != secondNum })
        buttonValues.append(contentsOf: [firstNum, secondNum])
        
        
        var leftCount = dimension*dimension - 2
        allValues.shuffle()
        
        while leftCount > 0 {
            var num = allValues.first
            if num != nil {
                buttonValuesWithoutSimplest.append(num!)
            } else {
                num = searchedNum - leftCount
            }
            
            if !hasPossibilities(sNumber: searchedNum, maK: 2) {
                if !buttonValues.contains(num!) && repetitionCounter < 50 {
                    buttonValues.append(num!)
                    allValues.remove(at: 0)
                    leftCount -= 1
                } else {
                    buttonValues.append(num!)
                    if allValues.count > 0 {
                        allValues.remove(at: 0)
                    }
                    leftCount -= 1
                }
            } else {
                buttonValuesWithoutSimplest = buttonValuesWithoutSimplest.filter { $0 != num }
            }
            print("Left Count: \(leftCount)")
            repetitionCounter += 1
        }
        buttonValues.shuffle()
        
        //        buttonValues += buttonValuesWithoutSimplest
        print(buttonValues)
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
    
    func buttonPressed(int: [Int]) {
        newNumComing = false
        let a = int[0]
        let b = int[1]
        let i = a*dimension+b
        let pressedValue = buttonValues[i]
        
        if buttonAlreadySelected(id: i) {
            searchedNum += pressedValue
        } else {
            searchedNum -= pressedValue
            if searchedNum == 0 {
                getNewSearchedNum()
                self.newNumComing = true
            }
        }
    }
    
    func getNewSearchedNum() {
        currentlySelectedIds.removeAll()
        startOfTheGame()
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

struct BottomMenuItem: View {
    var icon: String
    var id: Int
    
    var body: some View {
        ZStack {
            Button(action: {
                self.bottomMenuItemTapped()
            }) {
                Image(systemName: icon)
                    .scaleEffect(1.4)
                    .frame(width: 55, height: 55)
                    .foregroundColor(Color.gray)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            }
            .background(
                Circle()
                    .fill(Color.offWhite)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5))
        }
        .transition(.move(edge: .trailing))
    }
    
    func bottomMenuItemTapped() {
        let str = String(id)
        let digits = str.digits
        let cat = digits[0]
        let choice = digits[1]
        
        switch cat {
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
}

struct MenuItem: View {
    var icon: String
    var id: Int
    @State var isPressed = false
    @State var showBottomMenuItem1 = false
    @State var showBottomMenuItem2 = false
    @State var showBottomMenuItem3 = false
    @State var showBottomMenuItem4 = false
    @State var showBottomMenuItem5 = false
    @State var showBottomMenuItem6 = false
    @State var showBottomMenuItem7 = false
    @State var showBottomMenuItem8 = false
    @State var showBottomMenuItem9 = false
    
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    self.showMenu(id: self.id)
                }) {
                    Image(systemName: icon)
                        .scaleEffect(1.4)
                        .frame(width: 55, height: 55)
                        .foregroundColor(Color.gray)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                        .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                }
                .background(
                    Group {
                        if !isPressed {
                            Circle()
                                .fill(Color.offWhite)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                                .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                        } else {
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
                        }
                    }
                    
                )
                
                if showBottomMenuItem1 {
                    BottomMenuItem(icon: "2.square.fill", id: 11)
                }
                
                if showBottomMenuItem2 {
                    BottomMenuItem(icon: "3.square.fill", id: 12)
                }
                
                if showBottomMenuItem3 {
                    BottomMenuItem(icon: "4.square.fill", id: 13)
                }
                if showBottomMenuItem4 {
                    BottomMenuItem(icon: "1.circle", id: 21)
                }
                
                if showBottomMenuItem5 {
                    BottomMenuItem(icon: "2.circle", id: 22)
                }
                
                if showBottomMenuItem6 {
                    BottomMenuItem(icon: "3.circle", id: 23)
                }
                if showBottomMenuItem7 {
                    BottomMenuItem(icon: "plus.square.fill", id: 31)
                }
                if showBottomMenuItem8 {
                    BottomMenuItem(icon: "minus.square.fill", id: 32)
                }
                
                if showBottomMenuItem9 {
                    BottomMenuItem(icon: "multiply.square.fill", id: 33)
                }
            }
            
        }
        .transition(.move(edge: .trailing))
    }
    
    func showMenu(id: Int) {
        isPressed.toggle()
        
        switch id {
        case 1:
            withAnimation {
                showBottomMenuItem1.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                withAnimation {
                    self.showBottomMenuItem2.toggle()
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation {
                    self.showBottomMenuItem3.toggle()
                }
            })
        case 2:
            withAnimation {
                showBottomMenuItem4.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                withAnimation {
                    self.showBottomMenuItem5.toggle()
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation {
                    self.showBottomMenuItem6.toggle()
                }
            })
        case 3:
            withAnimation {
                showBottomMenuItem7.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                withAnimation {
                    self.showBottomMenuItem8.toggle()
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation {
                    self.showBottomMenuItem9.toggle()
                }
            })
        default:
            break
        }
    }
}

struct FloatingMenu: View {
    
    @State var showMenuItem1 = false
    @State var showMenuItem2 = false
    @State var showMenuItem3 = false
    @State var isPressed = false
    
    let d = UserDefaults.standard.integer(forKey: "dimension")
    let lvl = UserDefaults.standard.integer(forKey: "lvl")
    
    var body: some View {
        VStack {
            //                                    Spacer()
            Button(action: {
                self.showMenu()
            }) {
                Image(systemName: "gear")
                    //                    .resizable()
                    .scaleEffect(1.4)
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.gray)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            }
            .background(
                Group {
                    if !isPressed {
                        Circle()
                            .fill(Color.offWhite)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    } else {
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
                    }
                }
                
            )
            if showMenuItem1 {
                MenuItem(icon: "\(d).square.fill", id: 1)
            }
            if showMenuItem2 {
                MenuItem(icon: "\(lvl).circle", id: 2)
            }
            if showMenuItem3 {
                MenuItem(icon: "plus.square.fill", id: 3)
            }
        }
    }
    
    func showMenu() {
        isPressed.toggle()
        withAnimation {
            showMenuItem1.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            withAnimation {
                self.showMenuItem2.toggle()
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            withAnimation {
                self.showMenuItem3.toggle()
            }
        })
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    
    
    let id: Int
    @Binding var selectedIds: [Int]
    
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        NeumorphicButton(id: id, currentlySelectedIds: $selectedIds, configuration: configuration)
    }
    
    struct NeumorphicButton: View, Identifiable {
        let id: Int
        @Binding var currentlySelectedIds: [Int]
        
        let configuration: ButtonStyleConfiguration
        
        var body: some View {
            return configuration.label
                .padding(30)
                .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6, alignment: .center)
                .contentShape(Circle())
                .background(
                    Group {
                        if isSelected() {
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
        
        func isSelected() -> Bool {
            for i in currentlySelectedIds {
                if i == id {
                    return true
                }
            }
            return false
        }
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

extension StringProtocol {
    var digits: [Int] { compactMap(\.wholeNumberValue) }
}
