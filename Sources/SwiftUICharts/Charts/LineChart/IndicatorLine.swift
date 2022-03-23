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
    @Binding var indicatorLineX: Double
    
    var labelXOffset: Double {
        indicatorLineX < 30 ? 20 : indicatorLineX > UIScreen.main.bounds.maxX - 30 ? -20 : .zero
    }
    
    public var body: some View {
        VStack(spacing: 4.0) {
            Text(timeLabel)
                .font(chartStyle.font ?? .system(size: 14.0))
                .onSizeChanged { size in
                    offset = size.height * 1.35
                }
                .offset(x: labelXOffset)
            Rectangle()
                .frame(width: 1, height: 136)
        }
        .foregroundColor(Color(.sRGB, red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0))
        .offset(y: offset)
    }
}

struct IndicatorLine_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorLine(timeLabel: .constant("9:47 AM"), indicatorLineX: .constant(40.0))
            .environmentObject(ChartStyle(backgroundColor: .blue, foregroundColor: ColorGradient.greenRed))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
