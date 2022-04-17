//
//  GameViewModel.swift
//  Kenyan Droughts
//
//  Created by Bidan on 25/09/2021.
//

import Foundation
import SwiftUI


class GameViewModel: ObservableObject{
    
    @Published var pucks = [Puck]()
    @Published var selectedPuck:Puck? = nil
    
    @Published var winnings = [Puck]()
    @Published var moves = [Move]()
    @Published var replay = false
    @Published var error:String? = nil
    @Published var score:String? = nil
    @Published var me:Int? = nil // player 1 or 2
    
    
    private let maxPlayerIndices = K.row_count * 3 // 9 * 3
    private let maxBoxes = K.row_count * K.row_count;
    
    var p2Kings:[Int]{
        let kings = ((maxBoxes - K.row_count) ..< maxBoxes).filter{K.validPostion(i: $0)}
        return kings
    }
    
    var p1Kings:[Int]{
        let kings = (0 ..< K.row_count).filter{K.validPostion(i: $0)}
        return kings
    }
    
    init() {
        initPlayer1()
        initPlayer2()
    }
    
    func initPlayer2(){
        (0 ..< maxPlayerIndices).filter{K.validPostion(i: $0)}.forEach{ i in
            pucks.append(Puck(index: i, isKing: false, color: .yellow, player: 2))
        }
    }
    
    
    func initPlayer1(){
        ((maxBoxes - maxPlayerIndices) ..< maxBoxes).filter{K.validPostion(i: $0)}.forEach{ i in
            pucks.append(Puck(index: i, isKing: false, color: .accentColor))
        }
    }
    
    func move(_ puck:Puck, _ destinationIndex:Int, from:(x:Int?, y:Int?), to:(x:Int?, y:Int?)){
        if let index = pucks.firstIndex(where: {$0.index == puck.index}){
            if !replay{
                moves.append(Move(puck: puck, from: puck.index, to: destinationIndex, fromX: from.x, fromY: from.y, toX: to.x, toY: to.y))
            }
            withAnimation(.linear){
                pucks[index].index = destinationIndex
            }
            if !puck.isKing, (puck.player == 1 ? p1Kings : p2Kings).contains(destinationIndex){
                pucks[index].isKing = true
            }
            selectedPuck = nil
            
        }
    }
    
    func replayMoves(){
        pucks = []
        winnings = []
        selectedPuck = nil
        initPlayer1()
        initPlayer2()
        print(moves)
        (0 ..< moves.count).map{ ($0, moves[$0]) }.forEach{ d in
            DispatchQueue.main.asyncAfter(deadline: .now() + (1 * Double(d.0)), execute: {
                let from = (d.1.fromX, d.1.fromY)
                let to = (d.1.toX, d.1.toY)
                if self.validMove(from: from, to: to, puck: d.1.puck, previousMove: d.0 == 0 ? nil : self.moves[d.0 - 1]){
                    self.move(d.1.puck, d.1.to, from: from, to: to)
                }
                if d.0 == self.moves.count - 1{
                    self.replay = false
                }
            })
        }
    }
    
    func showError(_ s:String?){
        if !replay{
            withAnimation(.spring()){
                error = s
            }
        }
    }
    
    func validMove(from:(x:Int?, y:Int?), to:(x:Int?, y:Int?), puck: Puck? = nil, previousMove:Move? = nil)->Bool{
        let dx = (to.x ?? 0) - (from.x ?? 0)
        let dy = (to.y ?? 0) - (from.y ?? 0)
        let d = abs(dx) - abs(dy)
        let down = dy >= 0
        let moves = abs(dx) //any axis
        let middlePucks = middlePucks(from: from, to: to)
        if middlePucks.contains(where: {$0.player == puck?.player}){
            showError("One of your soldiers is in the crossfire")
            return false // Huezi jikula bro
        }
        var doubleScore = false
        //check if the last move was for this player
        let previous = previousMove ??  self.moves.last
        if previous?.puck.player == puck?.player && middlePucks.count != 1{
            showError("Next player please. Acha ulafi")
            return false
        }else if(previous?.puck.player == puck?.player && middlePucks.count == 1){
            doubleScore = true
        }
        var valid = d == 0 && (moves == 1 || (moves == 2 && middlePucks.count == 1))
        if let p = puck, !p.isKing, p.player == 1, down{
            showError("Can't go that way yo!")
            return false
        }
        if let p = puck, !p.isKing, p.player == 2, !down{
            showError("Can't go that way yo!")
            return false
        }
        
        if let puck = puck{
            if puck.isKing{
                valid =  d == 0 && ((middlePucks.isEmpty && moves == 1) || middlePucks.count == 1)
            }
        }
        if !middlePucks.isEmpty{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [self] in
                middlePucks.forEach{ puck in
                    withAnimation(.spring()){
                        self.pucks.removeAll(where: {$0.index == puck.index})
                        self.winnings.append(puck)
                    }
                    withAnimation(.spring()){
                        if doubleScore{
                            self.score = "🔥🔥Double Score🔥🔥"
                        }else{
                            self.score = "🔥Score!🔥"
                        }
                    }
                }
            }
        }
        return valid
    }
    
    
    func middlePucks(from:(x:Int?, y:Int?), to:(x:Int?, y:Int?))->[Puck]{
        var candidates = [Puck]()
        let dx = (to.x ?? 0) - (from.x ?? 0)
        let dy = (to.y ?? 0) - (from.y ?? 0)
        let moves = abs(dx) //any axis
        let down = dy >= 0
        let right = dx >= 0
        (1 ..< moves).forEach{ i in
            let y = down ? (from.y! + i) : (from.y! - i)
            let x = right ? (from.x! + i) : (from.x! - i)
            let mdx = (from.x ?? 0) - x
            let mdy = (from.y ?? 0) - y
            if (abs(mdx) - abs(mdy)) == 0{
                let index = getRealIndex(column: y, index: x)
                print(index)
                if let puck = pucks.first(where: {$0.index == index}){
                    candidates.append(puck)
                }
            }
        }
        return candidates
    }
    
    func getRealIndex(column:Int, index:Int)->Int{
        return (column * K.row_count) + index
    }
}
