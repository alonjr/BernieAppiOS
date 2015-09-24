import Foundation
import CoreLocation

public class ConcreteEventRepository : EventRepository {
    let geocoder: CLGeocoder!
    let urlProvider: URLProvider!
    let jsonClient: JSONClient!
    let eventDeserializer: EventDeserializer!
    let operationQueue: NSOperationQueue!
    
    public init(
        geocoder: CLGeocoder,
        urlProvider: URLProvider,
        jsonClient: JSONClient,
        eventDeserializer: EventDeserializer,
        operationQueue: NSOperationQueue) {
            self.geocoder = geocoder
            self.urlProvider = urlProvider
            self.jsonClient = jsonClient
            self.eventDeserializer = eventDeserializer
            self.operationQueue = operationQueue
    }

    
    public func fetchEventsWithZipCode(zipCode: String, radiusMiles: Float, completion: (Array<Event>) -> Void, error: (NSError) -> Void) {
        self.geocoder.geocodeAddressString(zipCode, completionHandler: { (placemarks, geocodingError) -> Void in
            if(geocodingError != nil) {
                error(geocodingError)
                return
            }
            
            let placemark = placemarks.first as! CLPlacemark
            let location = placemark.location!

            let url = self.urlProvider.eventsURL()


            let HTTPBodyDictionary = self.HTTPBodyDictionaryWithLatitude(
                location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radiusMiles: radiusMiles)
            
            let eventsPromise = self.jsonClient.JSONPromiseWithURL(url, method: "POST", bodyDictionary: HTTPBodyDictionary)
            
            eventsPromise.then({ (jsonDictionary) -> AnyObject! in
                var parsedEvents = self.eventDeserializer.deserializeEvents(jsonDictionary as! NSDictionary)
                
                self.operationQueue.addOperationWithBlock({ () -> Void in
                    completion(parsedEvents)
                })
                
                return parsedEvents
                }, error: { (receivedError) -> AnyObject! in
                    self.operationQueue.addOperationWithBlock({ () -> Void in
                        error(receivedError)
                    })
                    return receivedError
            })
        })
    }
    
    // MARK: Private
    
    func HTTPBodyDictionaryWithLatitude(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radiusMiles: Float) -> NSDictionary {
        let filterConditions : Array = [
            [
                "geo_distance": [
                    "distance": "\(radiusMiles)mi",
                    "location": [
                        "lat": latitude,
                        "lon": longitude
                    ]
                ]
            ],
            [
                "range": [
                    "start_time": [
                        "lte": "now+6M/d",
                        "gte": "now"
                    ]
                ]
            ]
        ]
        
        
        return [
            "query": [
                "filtered": [
                    "query": [
                        "match_all": [
                            
                        ]
                    ],
                    "filter": [
                        "bool": [
                            "must": filterConditions
                        ]
                    ]
                ]
            ]
        ]
    }
}