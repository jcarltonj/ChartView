import SwiftUI
public enum LeftRight {
    case left
    case right
}
/// A single line of data, a view in a `LineChart`
public struct Line<Root: ChartDataPoint, ChartValueType: ChartValue>: View where ChartValueType.Root == Root {
    @EnvironmentObject var chartValue: ChartValueType
    @ObservedObject var chartData: ChartData<Root>

    var style: ChartStyle

    @State private var showIndicator: Bool = false
    @State private var touchLocation: CGPoint = .zero
    @State private var didCellAppear: Bool = false
    
    @State private var timeLabel: String = ""
    
    @State private var indicatorLineX: Double = 0.0
    @State private var indicatorLineY: Double = 0.0
    @State private var didTapOnce: Bool = false
    var swipeFunction: (LeftRight) -> Void
    var curvedLines: Bool = true
    @State private var date: Date = Date()
    var path: Path {
        Path.quadCurvedPathWithPoints(points: chartData.normalisedPoints,
                                      step: CGPoint(x: 1.0, y: 1.0))
    }
    
	/// The content and behavior of the `Line`.
	/// Draw the background if showing the full line (?) and the `showBackground` option is set. Above that draw the line, and then the data indicator if the graph is currently being touched.
	/// On appear, set the frame so that the data graph metrics can be calculated. On a drag (touch) gesture, highlight the closest touched data point.
	/// TODO: explain rotation
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if self.didCellAppear && self.style.showBackground {
                    LineBackgroundShapeView(chartData: chartData,
                                            geometry: geometry,
                                            style: style)
                } else {
                    //Fully fill with a color for tapping
                    VStack {
                        HStack {
                            Spacer()
                            Color.blue.opacity(0.001) //Needs to take up some space for swiping to work
                        }
                        Spacer()
                    }
                }
                LineShapeView(chartData: chartData,
                              geometry: geometry,
                              style: style,
                              trimTo: didCellAppear ? 1.0 : 0.0)
                    .onViewLayout(coordinateSpace: .local) { rect in
                        indicatorLineY = rect.minY
                    }

                if self.showIndicator {
                    IndicatorLine(timeLabel: $timeLabel, indicatorLineX: $indicatorLineX)
                        .position(x: indicatorLineX, y: indicatorLineY)
                }
            }
            .onAppear {
                didCellAppear = true
            }
            .onDisappear() {
                didCellAppear = false
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        
                        if !didTapOnce {
                            date = Date()
                            self.touchLocation = value.location
                            self.showIndicator = true
                            self.chartValue.interactionInProgress = true
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            self.getClosestDataPoint(geometry: geometry, touchLocation: value.location)
                            didTapOnce = true
                        }
                    })
                    .onEnded({ value in
                        self.touchLocation = .zero
                        self.showIndicator = false
                        self.chartValue.interactionInProgress = false
                        didTapOnce = false
                    })
                    .simultaneously(with:
                                        DragGesture(minimumDistance: 10)
                                            .onChanged({ value in
                                                if didTapOnce {
                                                    self.touchLocation = value.location
                                                    self.showIndicator = true
                                                    self.chartValue.interactionInProgress = true
                                                    self.getClosestDataPoint(geometry: geometry, touchLocation: value.location)
                                                }
                                                print(value.translation.width)
                                                if abs(value.translation.width) > 100 && abs(date.timeIntervalSinceNow) < 0.2 {
                                                    swipeFunction(value.translation.width > 0 ? .right : .left)
                                                }
                                            })
                                   )
            )
            
        }
    }
}

// MARK: - Private functions

extension Line {
	/// Calculate point closest to where the user touched
	/// - Parameter touchLocation: location in view where touched
	/// - Returns: `CGPoint` of data point on chart
    private func getClosestPointOnPath(geometry: GeometryProxy, touchLocation: CGPoint) -> CGPoint {
        let geometryWidth = geometry.frame(in: .local).width
        let normalisedTouchLocationX = (touchLocation.x / geometryWidth) * CGFloat(chartData.normalisedPoints.count - 1)
        let closest = self.path.point(to: normalisedTouchLocationX)
        var denormClosest = closest.denormalize(with: geometry)
        denormClosest.x = denormClosest.x / CGFloat(chartData.normalisedPoints.count - 1)
        denormClosest.y = denormClosest.y / CGFloat(chartData.normalisedRange)
        return denormClosest
    }

//	/// Figure out where closest touch point was
//	/// - Parameter point: location of data point on graph, near touch location
    private func getClosestDataPoint(geometry: GeometryProxy, touchLocation: CGPoint) {
        let geometryWidth = geometry.frame(in: .local).width
        let index = Int(round((touchLocation.x / geometryWidth) * CGFloat(chartData.points.count - 1)))
        if (index >= 0 && index < self.chartData.data.count){
            self.chartValue.currentValue = self.chartData.data[index]
            withAnimation(.none) {
                self.timeLabel = self.chartData.data[index].graphTransactionTime
            }
            self.indicatorLineX = touchLocation.x
        } else {
            self.chartValue.currentValue = nil
        }
    }
}

struct Line_Previews: PreviewProvider {
    /// Predefined style, black over white, for preview
    static let blackLineStyle = ChartStyle(backgroundColor: ColorGradient(.white), foregroundColor: ColorGradient(.black))

    /// Predefined style red over white, for preview
    static let redLineStyle = ChartStyle(backgroundColor: .whiteBlack, foregroundColor: ColorGradient(.red))

    static var previews: some View {
        Group {
            Line<SimpleChartDataPoint, SimpleChartValue>(chartData:  ChartData([8, 23, 32, 7, 23, -4]), style: blackLineStyle, swipeFunction: {_ in })
            Line<SimpleChartDataPoint, SimpleChartValue>(chartData:  ChartData([8, 23, 32, 7, 23, 43]), style: redLineStyle, swipeFunction: {_ in })
        }
    }
}

