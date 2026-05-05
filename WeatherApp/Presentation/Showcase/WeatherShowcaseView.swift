import SwiftUI

struct WeatherShowcaseView: View {
    
    @State private var viewModel = WeatherShowcaseViewModel()
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // Card especial — ancho completo
                        Button {
                            viewModel.showCustomScene = true
                        } label: {
                            CustomSceneCard()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)

                        // Grid de presets
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.showcaseItems) { item in
                                Button {
                                    viewModel.selectCondition(item)
                                } label: {
                                    ShowcaseCardView(
                                        title: item.title,
                                        condition: item.condition
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Escenas del clima")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }
            }
            .fullScreenCover(isPresented: $viewModel.showDetail) {
                if let condition = viewModel.selectedCondition {
                    ShowcaseDetailView(
                        condition: condition,
                        title: viewModel.selectedTitle
                    ) {
                        viewModel.clearSelection()
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.showCustomScene) {
                CustomSceneDetailView {
                    viewModel.showCustomScene = false
                }
            }
        }
    }
}

// MARK: - Custom Scene Card

private struct CustomSceneCard: View {
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Fondo con gradiente animado
            LinearGradient(
                colors: [Color(hex: "1a1a3e"), Color(hex: "2d1b69"), Color(hex: "11998e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Icono y texto
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Crear tu escena")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Text("Combiná condiciones y creá tu propio clima")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(height: 88)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Custom Scene Detail View

private struct CustomSceneDetailView: View {
    
    let onClose: () -> Void
    @State private var activeCondition: WeatherCondition = .sunnyDay

    var body: some View {
        ZStack {
            // Escena fullscreen
            ZStack {
                SkyBackgroundView(condition: activeCondition)
                StarsView(condition: activeCondition)
                MoonView(condition: activeCondition)
                SunView(condition: activeCondition)
                RainbowView(condition: activeCondition)
                CloudsView(condition: activeCondition)
                LightningView(condition: activeCondition)
                RainView(condition: activeCondition)
                SnowView(condition: activeCondition)
                HailView(condition: activeCondition)
                WindView(condition: activeCondition)
                FogView(condition: activeCondition)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: activeCondition)

            // Overlay — boton cerrar arriba
            VStack {
                HStack {
                    Spacer()
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 60)
                }
                Spacer()

                // Picker flotante
                ConditionPickerView(activeCondition: $activeCondition)
                    .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Showcase Detail View

private struct ShowcaseDetailView: View {
    
    let condition: WeatherCondition
    let title: String
    let onClose: () -> Void

    var body: some View {
        ZStack {
            ZStack {
                SkyBackgroundView(condition: condition)
                StarsView(condition: condition)
                MoonView(condition: condition)
                SunView(condition: condition)
                RainbowView(condition: condition)
                CloudsView(condition: condition)
                LightningView(condition: condition)
                RainView(condition: condition)
                SnowView(condition: condition)
                HailView(condition: condition)
                WindView(condition: condition)
                FogView(condition: condition)
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 60)
                }
                Spacer()
                Text(title)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 60)
                    .shadow(radius: 8)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WeatherShowcaseView()
}
