import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    @State private var position: MapCameraPosition = .automatic
    @State private var showVenueDetail = false
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(viewModel.venues) { venue in
                    Marker(venue.name, coordinate: venue.coordinate)
                        .tint(.red)
                        .tag(venue.id)
                }
            }
            .onAppear {
                position = .region(viewModel.region)
            }
            
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search venues", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                    
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            viewModel.loadVenuesNearby()
                        }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding()
                
                Spacer()
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding()
                }
                
                // Venue Detail Card
                if let selected = viewModel.selectedVenue {
                    VenueDetailCard(venue: selected)
                        .padding()
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationTitle("Map")
        .onAppear {
            viewModel.loadVenuesNearby()
        }
    }
}

struct VenueDetailCard: View {
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(venue.name)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(venue.rating, specifier: "%.1f")")
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(venue.currentOccupancy) here")
                        .font(.caption)
                    
                    if let capacity = venue.capacity {
                        ProgressView(
                            value: Double(venue.currentOccupancy) / Double(capacity)
                        )
                        .frame(width: 80)
                    }
                }
            }
            
            Text(venue.address)
                .font(.caption)
                .foregroundColor(.gray)
            
            if let hours = venue.openingHours {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(hours)
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "heart")
                        Text("Like")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "paperplane")
                        Text("Share")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    MapView(viewModel: MapViewModel())
}
