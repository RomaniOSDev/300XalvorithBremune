import SwiftUI

struct NeonProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppSurface"), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(1, max(0, progress)))
                .stroke(
                    AngularGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color("AppAccent").opacity(0.55), radius: 10, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.45), value: progress)
        }
    }
}

struct SunDialView: View {
    var progress: Double
    var sunriseLabel: String
    var sunsetLabel: String
    var size: CGFloat = 240

    var body: some View {
        let tickRadius = size * 0.45
        let iconSize = size * 0.22
        let ringPadding = size * 0.07

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppSurface"), Color("AppBackground")],
                        center: .center,
                        startRadius: 10,
                        endRadius: size * 0.54
                    )
                )
                .shadow(color: Color("AppPrimary").opacity(0.35), radius: 18, x: 0, y: 8)

            NeonProgressRing(progress: progress, lineWidth: max(12, size * 0.06))
                .padding(ringPadding)

            ForEach(0..<12, id: \.self) { tick in
                Capsule()
                    .fill(Color("AppTextSecondary").opacity(0.45))
                    .frame(width: 2, height: tick % 3 == 0 ? 14 : 8)
                    .offset(y: -tickRadius)
                    .rotationEffect(.degrees(Double(tick) * 30))
            }

            Image("sunIcon")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .shadow(color: Color("AppAccent").opacity(0.6), radius: 12)

            VStack(spacing: 4) {
                Spacer()
                HStack {
                    Text(sunriseLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    Text(sunsetLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(.horizontal, size * 0.11)
                .padding(.bottom, size * 0.08)
            }
        }
        .frame(width: size, height: size)
    }
}

struct LandscapeBanner: View {
    var height: CGFloat = 140

    var body: some View {
        Image("bannerSunset")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            .overlay {
                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0.15),
                        Color("AppBackground").opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }
}

/// Shared screen title header — same height and title baseline on every main tab.
struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    static let height: CGFloat = 120

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LandscapeBanner(height: Self.height)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(subtitle ?? " ")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .opacity(subtitle == nil ? 0 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
    }
}

struct BarChartView: View {
    let values: [Double]
    let labels: [String]

    var body: some View {
        GeometryReader { geo in
            let maxV = max(values.max() ?? 1, 0.1)
            let count = max(values.count, 1)
            let spacing: CGFloat = 6
            let barWidth = max((geo.size.width - spacing * CGFloat(count - 1)) / CGFloat(count), 4)

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                width: barWidth,
                                height: max(4, geo.size.height * 0.75 * CGFloat(value / maxV))
                            )
                        if index < labels.count {
                            Text(labels[index])
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct AchievementBannerOverlay: View {
    @Binding var achievementId: String?
    let definitions: [AchievementDef]

    var body: some View {
        VStack {
            if let id = achievementId,
               let def = definitions.first(where: { $0.id == id }) {
                HStack(spacing: 12) {
                    Image(systemName: def.symbol)
                        .foregroundStyle(Color("AppAccent"))
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievement Unlocked")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text(def.title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("AppSurface"))
                        .shadow(color: Color("AppPrimary").opacity(0.4), radius: 12, y: 4)
                )
                .padding(.horizontal, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            achievementId = nil
                        }
                    }
                }
            }
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: achievementId)
        .allowsHitTesting(false)
    }
}

struct SuccessPulse: View {
    @Binding var visible: Bool

    var body: some View {
        if visible {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color("AppAccent"))
                .shadow(color: Color("AppAccent").opacity(0.6), radius: 12)
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            visible = false
                        }
                    }
                }
        }
    }
}

struct MiniDaylightChart: View {
    let points: [DaylightPoint]

    var body: some View {
        GeometryReader { geo in
            let values = points.map(\.durationHours)
            let minV = (values.min() ?? 0) - 0.2
            let maxV = (values.max() ?? 24) + 0.2
            let range = max(maxV - minV, 0.1)
            Path { path in
                guard points.count > 1 else { return }
                for (index, point) in points.enumerated() {
                    let x = geo.size.width * CGFloat(index) / CGFloat(points.count - 1)
                    let y = geo.size.height * (1 - CGFloat((point.durationHours - minV) / range))
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: Color("AppAccent").opacity(0.45), radius: 4)
        }
    }
}
