//
//  VM.swift
//  Kenyan Droughts
//
//  Created by Bidan on 24/12/2021.
//

import Foundation
import SwiftUI

class VM:ObservableObject{
    
    
    @Published var pins = 30
    @Published var spacings:[Int] = []
    @Published var glowing:[Int] = []
    @Published var sizes:[Int] = []
    @Published var funky = false
    public var gameTimer:Timer? = nil
    
    init(){
        var increment = 5
        var spacing = 0
        (0..<pins).forEach{ pin in
            spacing += 5
            if pin % 5 == 0{
                spacing = 0
                spacings.append(spacing)
                increment += 5
            }else{
                spacing += increment
                spacings.append(spacing)
            }
        }
        initEffects()
    }
    
    func initEffects(){
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            
            let count = self.pins/2
            self.glowing = []
            self.sizes = []
            (0..<count).forEach{ g in
                let r = Int.random(in: 0..<self.pins)
                self.glowing.append(r)
            }
//            withAnimation{
            if self.funky{
                self.sizes.append(contentsOf: self.glowing)
            }
//            }
            
        }
        
    }
    
}
