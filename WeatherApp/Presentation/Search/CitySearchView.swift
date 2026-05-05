import SwiftUI

struct CitySearchView: View {
    
    let viewModel: MainViewModel
    @State private var searchViewModel = CitySearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                    resultsList
                }
            }
            .navigationTitle("Buscar ciudad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSearchFocused = true
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 16))

            TextField("Madrid, Barcelona...", text: $searchViewModel.query)
                .font(.system(size: 16))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    Task { await searchViewModel.search() }
                }

            if !searchViewModel.query.isEmpty {
                Button {
                    searchViewModel.query = ""
                    searchViewModel.results = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onChange(of: searchViewModel.query) {
            searchViewModel.scheduleSearch()
        }
    }

    // MARK: - Results List

    @ViewBuilder
    private var resultsList: some View {
        if searchViewModel.isLoading {
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            }
        } else if searchViewModel.results.isEmpty && !searchViewModel.query.isEmpty && !searchViewModel.isLoading {
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Sin resultados para \"\(searchViewModel.query)\"")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
        } else {
            List(searchViewModel.results, id: \.name) { location in
                Button {
                    Task {
                        await viewModel.selectLocation(location)
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(location.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.primary)
                            Text(location.country)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground))
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Preview

#Preview {
    CitySearchView(
        viewModel: MainViewModel(
            fetchWeatherUseCase: AppEnvironment.mockFull()
        )
    )
}
