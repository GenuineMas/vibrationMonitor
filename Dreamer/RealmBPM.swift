//
//  RealmBPM.swift
//  Dreamer
//
//  Created by Genuine on 13.10.2021.
//  Copyright © 2021 Genuine. All rights reserved.
//

import Foundation
import RealmSwift

class PersistBPM: Object {
    
    @Persisted var bpm: Int = 0
    
    convenience init(bpm: Int) {
        self.init()
        self.bpm = bpm
    }
}
