//
//  String+Titlecaser.swift
//
//
//  Created by John Wells on 3/5/23.
//

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
    
    var isUppercase: Bool {
        /** We invert `isLowercase` here instead of using `isUppercase`, because
         `isUppercase` returns `false` for puncuation characters because those
         don't have a case. This is true of `isLowercase` as well, but we can
         take advantage of that to ignore non-letter characters when checking if
         the string is comprised solely of capitals. */
        allSatisfy { !$0.isLowercase }
    }
}
