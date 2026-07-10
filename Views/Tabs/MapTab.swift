import SwiftUI
import MapKit

struct MapTab: View {
    @StateObject private var vm = StatsVM()
    @ObservedObject private var locationService = LocationService.shared

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedID: UUID?
    @State private var sheetSession: GameSession?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                if vm.sessionsWithLocation.isEmpty {
                    emptyState
                } else {
                    Map(position: $cameraPosition, selection: $selectedID) {
                        ForEach(vm.sessionsWithLocation) { session in
                            if let coordinate = session.coordinate {
                                Marker(session.mode.displayName, systemImage: session.mode.systemImage, coordinate: coordinate)
                                    .tint(session.mode.colors.first ?? .blue)
                                    .tag(session.id)
                            }
                        }
                    }
                    .mapStyle(.standard)
                    .ignoresSafeArea(edges: .bottom)
                }

                topBar
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            vm.refresh()
            locationService.requestPermission()
        }
        .onChange(of: selectedID) { _, newValue in
            sheetSession = vm.sessionsWithLocation.first { $0.id == newValue }
        }
        .sheet(item: $sheetSession) { session in
            sessionDetailSheet(session)
                .presentationDetents([.height(200)])
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Map")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("\(vm.sessionsWithLocation.count) games played here")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "map")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.4))
            Text("No games on the map yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Allow location access and play a round — every completed game drops a pin here.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.13), Color(red: 0.1, green: 0.05, blue: 0.2)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private func sessionDetailSheet(_ session: GameSession) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: session.mode.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 46, height: 46)
                    Image(systemName: session.mode.systemImage)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.mode.displayName)
                        .font(.headline)
                    Text(session.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(session.score)")
                    .font(.title.bold())
            }
            Spacer()
        }
        .padding(20)
        .padding(.top, 12)
    }
}

#Preview {
    MapTab()
}