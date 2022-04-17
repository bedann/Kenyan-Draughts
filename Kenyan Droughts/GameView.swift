//
//  GameView.swift
//  Kenyan Droughts
//
//  Created by Bidan on 25/09/2021.
//

import SwiftUI

struct GameView: View {
    
    @StateObject var model = GameViewModel()
    @State var replayAlpha = 1.0
    @Namespace var namespace
    
    
    var body: some View {
        GeometryReader{ reader in
            VStack{
                
                    VStack{
                        if let error = model.error{
                            Text(error)
                                .foregroundColor(.orange)
                                .onAppear{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                        withAnimation(.spring()){
                                            model.error = nil
                                        }
                                    })
                                }
                        }else if let _ = model.score{
                            Text("  ")
                                .foregroundColor(.clear)
                                .onAppear{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                        model.score = nil
                                    })
                                }
                        }else{
                            Text("")
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                
                HStack{
                    ForEach(model.winnings.filter{$0.player == 1}){ puck in
                        PuckView(puck: puck)
                    }
                }
                .frame(minHeight: reader.size.width/CGFloat(K.row_count), maxHeight: reader.size.width/CGFloat(K.row_count))
                .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.black, lineWidth: 2))
                
                
                GeometryReader{ parent in
                    
                    VStack(alignment: .center, spacing: 0){
                        ForEach(0 ..< K.row_count, id:\.self){ c in
                            HStack(spacing: 0){
                                ForEach(0 ..< K.row_count, id:\.self){ r in
                                    let index = model.getRealIndex(column: c, index: r)
                                    let puck = model.pucks.first(where: {$0.index == index})
                                    Box(puck: puck, actualIndex: index, x: r, y: c)
                                        .environmentObject(model)
                                }
                            }
                        }
                    }
                    .frame(width: parent.size.width, height: parent.size.width, alignment: .center)
                    .background(Color.white)
                    .overlay(Rectangle().strokeBorder())
                    
                }
                .frame(width: reader.size.width, height: reader.size.width, alignment: .center)
                
                HStack{
                    ForEach(model.winnings.filter{$0.player == 2}){ puck in
                        PuckView(puck: puck)
                    }
                }
                .frame(minHeight: reader.size.width/CGFloat(K.row_count), maxHeight: reader.size.width/CGFloat(K.row_count))
                .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.black, lineWidth: 2))
                
                
            }
            .frame(maxHeight: .infinity)
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                if model.replay{
                    Text("📽 Replaying ...")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .onAppear{
                            withAnimation{
                                self.replayAlpha = 0.6
                            }
                        }
                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true))
                }else{
                    Button("Replay"){
                        model.replay = true
                        model.replayMoves()
                    }
                }
            })
        })
        .padding()
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle(model.score ?? "Kenyan Draughts")
        .preferredColorScheme(.dark)
    }
    
    
}

struct Box:View{
    
    let playable:Bool
    var puck:Puck?
    let actualIndex:Int
    let x:Int
    let y:Int
    @EnvironmentObject var model:GameViewModel
    
    init(puck:Puck?, actualIndex:Int, x:Int?, y:Int?){
        self.puck = puck
        self.x = x ?? 0
        self.y = y ?? 0
        self.puck?.x = x
        self.puck?.y = y
        self.actualIndex = actualIndex
        self.playable = K.validPostion(i: actualIndex)
    }
    
    var body: some View{
        ZStack{
            if playable {
                Button(action:{
                    if puck != nil{
                        model.selectedPuck = puck
                    }else if let selected = model.selectedPuck{
                        if model.validMove(from: (selected.x, selected.y), to: (self.x, self.y), puck: selected){
                            model.move(selected, actualIndex, from: (selected.x, selected.y), to: (self.x, self.y))
                        }
                    }
                }){
                    if let puck = self.puck{
                        PuckView(puck: puck)
                    }else{
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color.clear)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(playable ? Color.black : Color.white)
    }
}


struct PuckView:View{
    let puck:Puck
    let kingIcons:[Int:String] = [
        1: "king",
        2: "crown"
    ]
    let icons:[Int:String] = [
        1: "coin",
        2: "puck"
    ]
    
    var body: some View{
//        Circle()
//            .fill(puck.color)
//            .padding(8)
//            .overlay(
//                Image(systemName: "crown.fill")
//                    .foregroundColor(puck.isKing ? Color.white : Color.clear)
//
//            )
        Image((puck.isKing ? kingIcons[puck.player] : icons[puck.player])!)
            .resizable()
            .aspectRatio(0.9, contentMode: .fit)
            .overlay(
                Image(systemName: "crown.fill")
                    .foregroundColor(puck.isKing ? Color.white : Color.clear)
                
            )
    }
}


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            GameView()
        }
    }
}
