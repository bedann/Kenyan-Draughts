//
//  Puck.swift
//  Kenyan Droughts
//
//  Created by Bidan on 25/09/2021.
//

import Foundation
import SwiftUI

struct Puck:Identifiable{
    var index:Int
    var isKing:Bool = false
    var color:Color = .accentColor
    var player:Int = 1
    var x:Int? = nil
    var y:Int? = nil
    
    var id: Int{
        return index
    }
}
