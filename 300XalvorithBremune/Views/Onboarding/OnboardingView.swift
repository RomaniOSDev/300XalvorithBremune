import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var page = 0
    @State private var ringProgress: CGFloat = 0

    private let pages: [(headline: String, body: String, image: String)] = [
        (
            "Plan Your Day",
            "Understand how the app helps you plan activities around daylight.",
            "bgSunrise"
        ),
        (
            "Track Sun Times",
            "Easily check today's sunrise and sunset times with a single tap.",
            "bannerSunset"
        ),
        (
            "Get Started Now",
            "Begin tracking your local sunrise and sunset data today.",
            "sunIcon"
        )
    ]

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            ZStack {
                Circle()
                    .stroke(Color("AppSurface"), lineWidth: 10)
                    .frame(width: 240, height: 240)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        AngularGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))

                Image(pages[page].image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .shadow(color: Color("AppAccent").opacity(0.45), radius: 18)
                    .id(page)
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }

            VStack(spacing: 12) {
                Text(pages[page].headline)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(pages[page].body)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == page ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()

            Button {
                HapticFeedback.light()
                if page < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        page += 1
                    }
                    animateRing()
                } else {
                    store.completeOnboarding()
                }
            } label: {
                Text(page < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("AppPrimary"))
                            .shadow(color: Color("AppPrimary").opacity(0.45), radius: 10, y: 4)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color("AppBackground")
                .overlay {
                    Image("bgSunrise")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.18)
                }
                .clipped()
                .ignoresSafeArea()
        }
        .onAppear { animateRing() }
        .onChange(of: page) { _ in animateRing() }
    }

    private func animateRing() {
        ringProgress = 0
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
            ringProgress = CGFloat(page + 1) / CGFloat(pages.count)
        }
    }
}
