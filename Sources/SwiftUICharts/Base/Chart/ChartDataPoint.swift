//
//  File.swift
//  
//
//  Created by Carlton Jester on 1/5/22.
//

import Foundation

public protocol ChartDataPoint: Equatable {
    
    /// The value shown for the label of the data in the basic form
    var chartValue: String { get }
    
    /// The value shown above the indicator
    var graphTransactionTime: String { get }
}
