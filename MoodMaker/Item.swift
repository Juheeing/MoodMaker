//
//  Item.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
