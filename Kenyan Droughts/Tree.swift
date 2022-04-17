//
//  Tree.swift
//  Kenyan Droughts
//
//  Created by Bidan on 24/12/2021.
//

import SwiftUI

struct Tree: View {
    
    @StateObject var vm = VM()
    @State var colors:[Color] = [.red, .blue]
    
    
    var body: some View {
        VStack(spacing: 0){
            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(.bottom)
            ForEach(0..<vm.pins, id:\.self){ index in
                HStack{
                    if index > 0 {
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: vm.sizes.contains(index) ? 12 : 10, height: vm.sizes.contains(index) ? 12 : 10)
                            .foregroundColor(vm.glowing.contains(index) ? colors.randomElement() : .green)
                        HStack{
                            VStack{
                                
                            }
                            .frame(width: 10, height: 10)
                            .background(Color.green)
                        }
                        .frame(maxWidth: CGFloat(vm.spacings[index]))
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: vm.sizes.contains(index) ? 12 : 10, height: vm.sizes.contains(index) ? 12 : 10)
                            .foregroundColor(vm.glowing.contains(index) ? colors.randomElement() : .green)
                    }
                }
            }
            
            VStack{
                
            }
            .frame(width: 70, height: 10)
            .background(Color.green)
            VStack{
                
            }
            .frame(width: 50, height: 50)
            .background(Color.green)
            Toggle("Shake", isOn: $vm.funky)
                .padding()
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onDisappear{
            self.vm.gameTimer?.invalidate()
        }
    }
}

struct Tree_Previews: PreviewProvider {
    static var previews: some View {
        Tree()
    }
}
