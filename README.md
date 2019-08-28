# Lepton

OPML parser written in swift.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Travis CI](https://travis-ci.org/younata/Lepton.svg)](https://travis-ci.org/younata/Lepton)

## Usage

```swift
import Lepton

let myOPMLFile = String(contentsOfURL: "https://example.com/feeds.opml", encoding: NSUTF8StringEncoding)
let parser = Parser(string: myOPMLFile)

parser.success {
    print("Parsed: \($0)")
}
parser.failure {
    print("Failed to parse: \($0)")
}

parser.main() // or add to an NSOperationQueue
```

Lepton supports standard rss/atom feeds.

Lepton is used with Muon in rNews, but they are independent of each other.

## Installing

### Carthage

Swift 5:

* add `github "younata/Lepton"`

## ChangeLog

### 0.2.0

- Update for swift 5
- Remove support for Query Feeds

### 0.1.0

- Initial release.

## License

[MIT](LICENSE)
