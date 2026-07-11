import SwiftUI
import MapKit


struct MapTab: View {


    @StateObject private var vm = StatsVM()


    @ObservedObject private var locationService =
    LocationService.shared



    @State private var cameraPosition:
    MapCameraPosition = .automatic



    @State private var selectedID: UUID?



    @State private var sheetSession:
    GameSession?


    var body: some View {


        NavigationStack {


            ZStack(alignment:.top) {

                Map(
                    position:$cameraPosition,
                    selection:$selectedID
                ) {



                    ForEach(vm.sessionsWithLocation) { session in



                        if let coordinate =
                            session.coordinate {



                            Marker(
                                session.mode.displayName,
                                systemImage:
                                    session.mode.systemImage,
                                coordinate:
                                    coordinate
                            )
                            .tint(
                                session.mode.colors.first ?? .blue
                            )
                            .tag(session.id)



                        }



                    }



                    if let userLocation =
                        locationService.currentLocation {



                        Annotation(
                            "You",
                            coordinate:userLocation
                        ) {


                            Image(systemName:"person.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)


                        }



                    }


                }

                .mapStyle(.standard)

                .ignoresSafeArea()


                topBar




            }


        }



        .onAppear {


            vm.refresh()


            locationService.requestPermission()



        }

       .onChange(
            of: locationService.currentLocation?.latitude ?? 0
        ) {



            moveToUserLocation()


        }
   
        .onChange(
            of: vm.sessionsWithLocation.count
        ) {



            showGamePins()


        }



    }


    private func moveToUserLocation() {


        guard let location =
                locationService.currentLocation

        else {

            return

        }



        print(
            "MOVING MAP:",
            location.latitude,
            location.longitude
        )



        cameraPosition =
        .region(

            MKCoordinateRegion(

                center:location,


                span:

                MKCoordinateSpan(

                    latitudeDelta:0.02,

                    longitudeDelta:0.02

                )

            )

        )


    }


    private func showGamePins() {


        guard let first =
                vm.sessionsWithLocation.first?.coordinate

        else {

            return

        }



        cameraPosition =
        .region(

            MKCoordinateRegion(

                center:first,

                span:

                MKCoordinateSpan(

                    latitudeDelta:0.05,

                    longitudeDelta:0.05

                )

            )

        )


    }


    private var topBar: some View {


        HStack {


            VStack(alignment:.leading) {


                Text("Map")
                    .font(.title.bold())



                Text(
                    "\(vm.sessionsWithLocation.count) games"
                )
                .font(.caption)



            }


            Spacer()



        }

        .padding()

        .background(
            .ultraThinMaterial
        )


    }



}
