//
//  Item.swift
//  MRFileBrowserDemo
//
//  Created by Mukilarasan Ravi on 20/02/26.
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
