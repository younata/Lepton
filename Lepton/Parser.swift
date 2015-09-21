import Foundation

public class Item: NSObject {
    public var title: String? = nil
    public var summary: String? = nil
    public var xmlURL: String? = nil
    public var query: String? = nil
    public var tags: [String]? = nil

    private func isValidItem() -> Bool {
        return xmlURL != nil || (query != nil && title != nil)
    }

    public func isQueryFeed() -> Bool {
        return query != nil
    }
}

public class Parser: NSOperation, NSXMLParserDelegate {
    var callback: ([Item]) -> Void = {(_) in }
    var onFailure: (NSError) -> Void = {(_) in }

    private var content: String? = nil
    private var xmlParser: NSXMLParser? = nil
    private var items: [Item] = []
    private var isOPML = false

    public func success(onSuccess: ([Item]) -> Void) -> Parser {
        callback = onSuccess
        return self
    }

    public func failure(failed: (NSError) -> Void) -> Parser {
        onFailure = failed
        return self
    }

    public init(text: String) {
        super.init()
        content = text
    }

    public override init() {
        super.init()
    }

    func configureWithText(text: String) {
        content = text
    }

    public override func main() {
        parse()
    }

    public override func cancel() {
        stopParsing()
    }

    private func parse() {
        items = []
        if let text = content {
            xmlParser = NSXMLParser(data: text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            xmlParser?.delegate = self
            xmlParser?.parse()
        }
    }

    private func stopParsing() {
        xmlParser?.abortParsing()
    }

    // MARK: NSXMLParserDelegate

    public func parserDidEndDocument(parser: NSXMLParser) {
        if (isOPML) {
            callback(items)
        }
    }

    public func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        isOPML = false
        onFailure(parseError)
    }

    public func parser(parser: NSXMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?,
        attributes attributeDict: [String: String]) {
            if elementName.lowercaseString == "xml" { return }
            if elementName.lowercaseString == "opml" { isOPML = true }
            if (!isOPML) { return }

            if elementName.lowercaseString.hasPrefix("outline") {
                let item = Item()
                let whitespaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                for (k, value) in attributeDict {
                    let key = k.lowercaseString
                    if value == "" {
                        continue
                    }
                    if key == "xmlurl" {
                        item.xmlURL = value
                    }
                    if key == "tags" {
                        let comps = value.componentsSeparatedByString(",") as [String]
                        item.tags = comps.map({(str: String) in
                            return str.stringByTrimmingCharactersInSet(whitespaceSet)
                        })
                    }
                    if key == "query" {
                        item.query = value
                    }
                    if key == "title" {
                        item.title = value
                    }
                    if key == "summary" || key == "description" {
                        item.summary = value
                    }
                }
                if item.isValidItem() {
                    items.append(item)
                }
            }
    }
}