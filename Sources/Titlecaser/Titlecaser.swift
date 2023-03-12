import Foundation

extension String {
    public func toTitleCase() -> Self {
        var capitalized = self
        let wordSeparators = CharacterSet(charactersIn: " :–—-‑")
        
        let componentRanges = componentRanges(with: wordSeparators)
        let isAllCaps = isUppercase

        for range in componentRanges {
            let component = self[range]
            
            guard !component.hasNonstandardCapitals || isAllCaps,
                  !component.isEmailAddress,
                  !component.isFilename else { continue }
            
            let shouldLowercase = range.lowerBound != startIndex
                                && range.upperBound != endIndex
                                && range.tag != .beginsSubtitle
                                && range.tag != .beginsHyphenation
                                && (component.isProtocol || component.isSmallWord)
            
            if shouldLowercase {
                capitalized.replaceSubrange(range, with: component.lowercased())
            } else {
                capitalized.replaceSubrange(range, with: component.naivelyCapitalized())
            }
        }
        
        return capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func componentRanges(with separators: CharacterSet) -> [TaggedRange<Index>] {
        var ranges = [TaggedRange<Index>]()
        var position = startIndex
        
        var subtitleMayStart = false
        var hyphenationMayEnd = false
        
        while let range = rangeOfCharacter(from: separators, range: position..<endIndex) {
            // Most components
            if range.lowerBound != position {
                let newRange = position..<range.lowerBound
                var tag: TaggedRange<Index>.Tag?
                
                if subtitleMayStart {
                    tag = .beginsSubtitle
                    subtitleMayStart = false
                }
                
                ranges.append(TaggedRange(range: newRange, tag: tag))
            }
            
            // Most separator characters
            switch self[range] {
            case ":":
                guard let previousRange = ranges.last,
                      !self[previousRange].isProtocol else { break }
                
                subtitleMayStart = true
                
            case "-":
                if var modifiedLast = ranges.last {
                    if hyphenationMayEnd {
                        modifiedLast.tag = .hyphenationComponent
                        hyphenationMayEnd = false
                    } else {
                        modifiedLast.tag = .beginsHyphenation
                        hyphenationMayEnd = true
                    }
                    
                    ranges.removeLast()
                    ranges.append(modifiedLast)
                }
                
            default: break
            }
            
            ranges.append(TaggedRange(range: range))
            position = range.upperBound
        }
        
        // Last word
        if position != endIndex {
            ranges.append(TaggedRange(range: position..<endIndex))
        }
        
        return ranges
    }
    
    subscript(_ i: Int) -> String? {
        guard !isEmpty,
              let range = index(startIndex,
                                offsetBy: i,
                                limitedBy: index(before: endIndex)) else { return nil }
        
        return String(self[range])
    }
    
    var isUppercase: Bool {
        allSatisfy { !$0.isLowercase }
    }
}

extension Substring {
    var hasNonstandardCapitals: Bool {
        // Skip first letter
        let start = index(after: startIndex)
        
        return self[start..<endIndex].contains { character in
            return character.isUppercase
        }
    }
    
    var isEmailAddress: Bool {
        contains("@")
    }
    
    var isFilename: Bool {
        var nonPeriodPunctuation = CharacterSet.punctuationCharacters
        nonPeriodPunctuation.remove(charactersIn: "._-")
        
        return contains(".")
               && rangeOfCharacter(from: nonPeriodPunctuation) == nil
               && last != "."
               || first == "/"
    }
    
    var isProtocol: Bool {
        let protocols = ["http", "https", "ftp"]
        return protocols.contains(where: { lowercased() == $0 })
    }
    
    var isSmallWord: Bool {
        let smallWords = ["a","an","and","as","at","but","by","en","for","if","in","nor",
                          "of","on","or","per","the","to","v","vs","v.","vs.","via"]
        
        return smallWords.contains(where: { lowercased() == $0 })
    }
    
    func naivelyCapitalized() -> Self {
        var recomposed = self
        
        // Split and recurse for non-path slash usage
        if contains("/") {
            guard count > 1 else { return self }
            
            for word in split(separator: "/") {
                recomposed.replaceSubrange(word.startIndex..<word.endIndex,
                                           with: word.naivelyCapitalized())
            }
            
            return recomposed
        }
        
        let alphanumericPattern = #/([A-Za-z0-9\u{00C0}-\u{00FF}])/#.ignoresCase()
        
        let matches = ranges(of: alphanumericPattern)
        
        for match in matches {
            if match == matches.first {
                recomposed.replaceSubrange(match, with: self[match].uppercased())
            } else {
                recomposed.replaceSubrange(match, with: self[match].lowercased())
            }
        }
        
        return recomposed
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}

struct TaggedRange<Bound>: RangeExpression where Bound : Comparable {
    var range: Range<Bound>
    var tag: Tag? = nil
    
    var lowerBound: Bound { range.lowerBound }
    var upperBound: Bound { range.upperBound }
    
    func relative<C>(to collection: C) -> Range<Bound> where C : Collection, Bound == C.Index {
        range.relative(to: collection)
    }
    
    func contains(_ element: Bound) -> Bool {
        range.contains(element)
    }
    
    enum Tag {
        case beginsHyphenation
        case hyphenationComponent
        case endsTitle
        case beginsSubtitle
    }
}
