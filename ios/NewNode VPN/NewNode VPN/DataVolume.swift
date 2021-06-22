//
//  DataVolume.swift
//  NewNode VPN
//
//  Created by Mikhail Koroteev on 06/02/21.
//  Copyright © 2021 Clostra. All rights reserved.
//

import Foundation

class DataVolume {
    var direct: Int64 = 0
    var peer: Int64 = 0
    
    init(direct: Int64 = 0, peer: Int64 = 0) {
        self.direct = direct
        self.peer = peer
    }
}
