import Foundation
import berniesanders
import CoreLocation

class FakeURLProvider : berniesanders.URLProvider {
    func issuesFeedURL() -> NSURL! {
        fatalError("override me in spec!")
    }
    
    func newsFeedURL() -> NSURL! {
        fatalError("override me in spec!")
    }
    
    func bernieCrowdURL() -> NSURL! {
        fatalError("override me in spec!")
    }
    
    func privacyPolicyURL() -> NSURL! {
        fatalError("override me in spec!")        
    }
    
    func eventsURL() -> NSURL! {
        fatalError("override me in spec!")        
    }
}
