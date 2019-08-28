import Quick
import Nimble
import Lepton

class ParserSpec: QuickSpec {
    override func spec() {
        let bundle = Bundle(for: ParserSpec.self)
        let str = try! String(contentsOfFile: bundle.path(forResource: "test", ofType: "opml")!, encoding: String.Encoding.utf8)
        
        
        describe("Parsing a string") {
            var parser: Parser! = nil

            beforeEach {
                parser = Parser(text: str)
            }
            
            it("pulls out regular feeds") {
                _ = parser.success {(items) in
                    expect(items.count).to(equal(3))
                    if let feed = items.first {
                        expect(feed.title).to(equal("nil"))
                        expect(feed.summary).to(beNil())
                        expect(feed.xmlURL).to(equal("http://example.com/feedWithTag"))
                        expect(feed.tags).to(equal(["a tag"]))
                    }
                    if let feed = items.last {
                        expect(feed.title).to(equal("Feed With Title"))
                        expect(feed.summary).to(beNil())
                        expect(feed.xmlURL).to(equal("http://example.com/feedWithTitle"))
                        expect(feed.tags) == []
                    }
                }
                parser.main()
            }
        }
    }
}
