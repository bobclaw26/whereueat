import SwiftUI
import MapKit
import Combine

@MainActor
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var venues: [Venue] = []
    @Published var selectedVenue: Venue?
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchRadius: Double = 5.0 // km
    
    private let foursquareService = FoursquareService()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        setupLocationTracking()
    }
    
    private func setupLocationTracking() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func loadVenuesNearby() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let venues = try await foursquareService.searchVenues(
                    latitude: region.center.latitude,
                    longitude: region.center.longitude,
                    category: "nightlife",
                    radiusKm: searchRadius
                )
                self.venues = venues
            } catch {
                self.error = "Failed to load venues: \(error.localizedDescription)"
                print("Error loading venues: \(error)")
            }
            isLoading = false
        }
    }
    
    func updateRegion(center: CLLocationCoordinate2D) {
        region.center = center
        loadVenuesNearby()
    }
    
    func selectVenue(_ venue: Venue) {
        selectedVenue = venue
    }
    
    func deselectVenue() {
        selectedVenue = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.updateRegion(center: location.coordinate)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
}
