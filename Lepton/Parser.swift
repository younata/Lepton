import Foundation

public struct Item {
    public var title: String?
    public var summary: String?
    public var xmlURL: String?
    public var query: String?
    public var tags: [String]

    fileprivate func isValidItem() -> Bool {
        return xmlURL != nil || (query != nil && title != nil)
    }

    public func isQueryFeed() -> Bool {
        return query != nil
    }

    public init(title: String?, summary: String?, xmlURL: String?, query: String?, tags: [String]) {
        self.title = title
        self.summary = summary
        self.xmlURL = xmlURL
        self.query = query
        self.tags = tags
    }
}

public final class Parser: Operation, XMLParserDelegate {
    var callback: ([Item]) -> Void = {(_) in }
    var onFailure: (NSError) -> Void = {(_) in }

    private var content: String? = nil
    private var xmlParser: XMLParser? = nil
    private var items: [Item] = []
    private var isOPML = false

    public func success(_ onSuccess: @escaping ([Item]) -> Void) -> Parser {
        callback = onSuccess
        return self
    }

    public func failure(_ failed: @escaping (NSError) -> Void) -> Parser {
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

    func configureWithText(_ text: String) {
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
            xmlParser = XMLParser(data: text.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            xmlParser?.delegate = self
            xmlParser?.parse()
        }
    }

    private func stopParsing() {
        xmlParser?.abortParsing()
    }

    // MARK: NSXMLParserDelegate

    public func parserDidEndDocument(_ parser: XMLParser) {
        if (isOPML) {
            callback(items)
        }
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        isOPML = false
        onFailure(parseError as NSError)
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?,
        attributes attributeDict: [String: String]) {
            if elementName.lowercased() == "xml" { return }
            if elementName.lowercased() == "opml" { isOPML = true }
            if (!isOPML) { return }

            if elementName.lowercased().hasPrefix("outline") {
                var item = Item(title: nil, summary: nil, xmlURL: nil, query: nil, tags: [])
                let whitespaceSet = CharacterSet.whitespacesAndNewlines
                for (k, value) in attributeDict {
                    let key = k.lowercased()
                    if value == "" {
                        continue
                    }
                    if key == "xmlurl" {
                        item.xmlURL = value
                    }
                    if key == "tags" {
                        let comps = value.components(separatedBy: ",") as [String]
                        item.tags = comps.map({(str: String) in
                            return str.trimmingCharacters(in: whitespaceSet)
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
