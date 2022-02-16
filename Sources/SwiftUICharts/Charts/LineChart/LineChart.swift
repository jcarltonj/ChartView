import SwiftUI

/// A type of chart that displays a line connecting the data points
public struct AdvancedLineChart<Root: ChartDataPoint, ChartValueType: ChartValue>: View, AdvancedChartBase where Root == ChartValueType.Root  {
    

    @EnvironmentObject var data: ChartData<Root>
    @EnvironmentObject var style: ChartStyle
    
    public var swipeFunction: (LeftRight) -> Void
	/// The content and behavior of the `LineChart`.
	///
	///
    public var body: some View {
        Line<Root, ChartValueType>(chartData: data, style: style, swipeFunction: swipeFunction)
    }
    
    public init(swipeFunction: @escaping (LeftRight)->Void) {
        self.swipeFunction = swipeFunction
    }

}

/// A type of chart that displays a line connecting the data points
public struct LineChart: View, ChartBase {
    public var chartData = ChartData<SimpleChartDataPoint>()
    
    public typealias Root = SimpleChartDataPoint
    
    public typealias ChartValueType = SimpleChartValue
    
    public var swipeFunction: (LeftRight) -> Void
    
    @EnvironmentObject var data: ChartData<Root>
    @EnvironmentObject var style: ChartStyle
    
    public var body: some View {
        Line<SimpleChartDataPoint, SimpleChartValue>(chartData: data, style: style, swipeFunction: swipeFunction)
    }
    
    
    public init(swipeFunction: @escaping (LeftRight)->Void) {
        self.swipeFunction = swipeFunction
    }
}
