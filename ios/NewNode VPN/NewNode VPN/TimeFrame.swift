//
//  TimeFrame.swift
//  NewNode VPN
//
//  Created by Mikhail Koroteev on 06/02/21.
//  Copyright © 2021 Clostra. All rights reserved.
//

import Foundation

class TimeFrame
{
    enum Period: Int {
        case day = 1
        case week = 2
        case allTime = 3
    }
    
    func getTimeStartInMillis(period: Period) -> Int64 {
        // todo:
        return 86400 * 1000
    }
}


