//
//  IndicatorLine.swift
//
//
//  Created by Jon Huynh on 2/10/22.
//

import SwiftUI

/// A line representing a single data point as user moves finger over line chart in `LineChart`
struct IndicatorLine: View {
    
    @EnvironmentObject var chartStyle: ChartStyle
    @State private var offset: Double = 0.0
    @Binding var timeLabel: String
    /// The content and behavior of the `IndicatorPoint`.
    ///
    /// A filled circle with a thick white outline and a shadow
    public var body: some View {
        VStack(spacing: 4.0) {
            Text(timeLabel)
                .font(.system(size: 14.0))
                .onSizeChanged { size in
                    offset = size.height * 1.45
                }
            Rectangle()
                .frame(width: 1, height: 160)
        }
        .foregroundColor(Color(.sRGB, red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0))
        .offset(y: offset)
    }
}

struct IndicatorLine_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorLine(timeLabel: .constant("9:47 AM"))
            .environmentObject(ChartStyle(backgroundColor: .blue, foregroundColor: ColorGradient.greenRed))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
