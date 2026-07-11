import SwiftUI

struct LightCardView: View {
    let isLit: Bool
    let glowColor: Color
    let action: () -> Void

    @State private var pulse = false
    @State private var tapScale = false


    var body: some View {

        Button(action: {

            withAnimation(
                .spring(
                    response: 0.25,
                    dampingFraction: 0.6
                )
            ) {
                tapScale = true
            }


            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.12
            ) {
                tapScale = false
            }


            action()

        }) {


            ZStack {

                RoundedRectangle(
                    cornerRadius:18
                )

                .fill(
                    isLit
                    ? glowColor.opacity(0.18)
                    : Color.white.opacity(0.07)
                )


                .overlay(

                    RoundedRectangle(
                        cornerRadius:18
                    )

                    .stroke(

                        isLit
                        ? glowColor
                        : Color.white.opacity(0.15),

                        lineWidth:
                            isLit ? 3 : 1
                    )
                )


                .shadow(

                    color:
                        isLit
                        ? glowColor.opacity(0.75)
                        : .clear,

                    radius:
                        isLit ? 18 : 0
                )


                if isLit {


                    VStack(spacing:4) {


                        Text("🌼")

                            .font(
                                .system(
                                    size:42
                                )
                            )


                            .scaleEffect(
                                pulse
                                ? 1.12
                                : 0.95
                            )


                            .shadow(
                                color:
                                    glowColor.opacity(0.9),

                                radius:10
                            )


                            .transition(

                                .scale
                                .combined(
                                    with:.opacity
                                )
                            )



                        Text("Tap!")

                            .font(
                                .caption.bold()
                            )

                            .foregroundColor(
                                .white.opacity(0.8)
                            )
                    }


                    .onAppear {


                        pulse = true
                    }


                    .onDisappear {


                        pulse = false
                    }


                    .animation(

                        .easeInOut(
                            duration:0.45
                        )

                        .repeatForever(
                            autoreverses:true
                        ),

                        value:pulse
                    )
                }


                if isWilting {


                    Text("🥀")

                        .font(
                            .system(
                                size:38
                            )
                        )

                        .transition(
                            .opacity
                        )
                }

            }


            .frame(
                height:92
            )
        }


        .buttonStyle(.plain)


        .scaleEffect(

            tapScale
            ? 0.92
            :
            (isLit ? 1.05 : 1.0)
        )



        .animation(

            .spring(
                response:0.30,
                dampingFraction:0.65
            ),

            value:isLit
        )


        .animation(

            .easeOut(
                duration:0.20
            ),

            value:isWilting
        )
    }
}