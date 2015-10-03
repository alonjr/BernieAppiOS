import UIKit
import Quick
import Nimble
import berniesanders


class PrivacyPolicyFakeURLProvider : FakeURLProvider {
    override func privacyPolicyURL() -> NSURL! {
        return NSURL(string: "http://example.com/privates")
    }
}

class PrivacyPolicyControllerSpec : QuickSpec {
    var subject : PrivacyPolicyController!
    var analyticsService: FakeAnalyticsService!

    override func spec() {
        describe("PrivacyPolicyController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()
                self.subject = PrivacyPolicyController(urlProvider: PrivacyPolicyFakeURLProvider(), analyticsService: self.analyticsService)
            }
            
            it("has the correct title") {
                expect(self.subject.title).to(equal("Privacy Policy"))
            }
            
            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("tracks taps on the back button with the analytics service") {
                    self.subject.didMoveToParentViewController(nil)
                    
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on Privacy Policy"))
                }
                
                it("should add the webview as a subview") {
                    var subviews = self.subject.view.subviews as! [UIView]
                    
                    expect(contains(subviews, self.subject.webView)).to(beTrue())
                }
                
                it("should load the iubenda privacy policy page into a webview") {
                    expect(self.subject.webView.request!.URL).to(equal(NSURL(string: "http://example.com/privates")))
                }
            }
        }
    }
}
