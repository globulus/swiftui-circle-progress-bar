import SwiftUI

public struct RingProgressViewStyle: ProgressViewStyle {
    let progressLabelPosition: ProgressLabelPosition
    let configuration: Configuration
    
    @State private var labelSize = CGSize.zero
    @State private var fillRotationAngle = Angle.zero
    
    public init(progressLabelPosition: ProgressLabelPosition = .below,
                configuration: Configuration = .init()) {
        self.progressLabelPosition = progressLabelPosition
        self.configuration = configuration
    }
    
    public func makeBody(configuration: ProgressViewStyleConfiguration) -> some View {
        VStack {
            configuration.label
            if progressLabelPosition == .inside {
                ZStack {
                    configuration.currentValueLabel?.measureSize {
                        labelSize = $0
                    }
                    progressCircleView(size: labelSize, configuration: configuration)
                }
            } else {
                progressCircleView(size: CGSize(width: self.configuration.defaultDiameter,
                                                height: self.configuration.defaultDiameter),
                                   configuration: configuration)
                configuration.currentValueLabel
            }
        }
    }
    
    private func progressCircleView(size: CGSize,
                                    configuration: ProgressViewStyleConfiguration) -> some View {
        let lineWidth = self.configuration.lineWidth
        let diameter = max(size.width, size.height) * self.configuration.outsideScale + lineWidth * 2
        return Circle()
            .strokeBorder(self.configuration.trackColor, lineWidth: lineWidth, antialiased: true)
            .overlay(fillView(diameter: diameter,
                              lineWidth: lineWidth,
                              fractionCompleted: configuration.fractionCompleted ?? 0.2,
                              animate: configuration.fractionCompleted == nil))
            .frame(width: diameter, height: diameter)
    }
    
    private func fillView(diameter: CGFloat,
                          lineWidth: CGFloat,
                          fractionCompleted: Double,
                          animate: Bool) -> some View {
        let startAngle = animate ? .degrees(configuration.startAngle.degrees - 180 * fractionCompleted) : configuration.startAngle
        return Circle()
            .trim(from: 0, to: CGFloat(fractionCompleted))
            .stroke(self.configuration.fillColor, lineWidth: self.configuration.lineWidth)
            .frame(width: diameter - lineWidth, height: diameter - lineWidth)
            .rotationEffect(fillRotationAngle)
            .onAppear {
                fillRotationAngle = startAngle
                if animate {
                    withAnimation(.easeInOut(duration: 1).repeatForever()) {
                        fillRotationAngle = .degrees(startAngle.degrees + 360)
                    }
                }
            }
    }
    
    public enum ProgressLabelPosition {
        case inside, below
    }
    
    public struct Configuration {
        let trackColor: Color
        let fillColor: Color
        let lineWidth: CGFloat
        let outsideScale: CGFloat
        let defaultDiameter: CGFloat
        let startAngle: Angle
        
        public init(trackColor: Color = .gray.opacity(0.6),
                    fillColor: Color = .accentColor,
                    lineWidth: CGFloat = 6,
                    outsideScale: CGFloat = 1.2,
                    defaultDiameter: CGFloat = 24,
                    startAngle: Angle = .degrees(-90)) {
            self.trackColor = trackColor
            self.fillColor = fillColor
            self.lineWidth = lineWidth
            self.outsideScale = outsideScale
            self.defaultDiameter = defaultDiameter
            self.startAngle = startAngle
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct MeasureSizeModifier: ViewModifier {
  func body(content: Content) -> some View {
    content.background(GeometryReader { geometry in
      Color.clear.preference(key: SizePreferenceKey.self,
                             value: geometry.size)
    })
  }
}

extension View {
  func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
    self.modifier(MeasureSizeModifier())
      .onPreferenceChange(SizePreferenceKey.self, perform: action)
  }
}

struct TestView: View {
    @State private var progress = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            Slider(value: $progress, in: 0.0...1.0) {
                Text("Slider")
            }

            ProgressView(value: progress, total: 1.0) {
                Text("Label inside")
            } currentValueLabel: {
                Text(String(format: "%0.2f%%", progress))
                    .font(.system(size: 12).monospacedDigit())
            }.progressViewStyle(RingProgressViewStyle(progressLabelPosition: .inside))

            ProgressView(value: progress, total: 1.0) {
                Text("Label below")
            } currentValueLabel: {
                Text(String(format: "%0.2f%%", progress))
            }.progressViewStyle(RingProgressViewStyle(progressLabelPosition: .below,
                                                    configuration: .init(trackColor: .green.opacity(0.4),
                                                                         fillColor: .red,
                                                                         lineWidth: 5,
                                                                         startAngle: .degrees(90))))
            
            ProgressView("Indefinite")
                .progressViewStyle(RingProgressViewStyle(configuration: .init(trackColor: .orange,
                                                                            fillColor: .purple)))


        }.padding()
    }
}

struct RingProgressBars_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
