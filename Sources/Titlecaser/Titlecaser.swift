import Foundation

extension String {
    func toTitleCase() -> Self {
        let smallWords = #/^(a|an|and|as|at|but|by|en|for|if|in|nor|of|on|or|per|the|to|v.?|vs.?|via)$/#.ignoresCase()
        let caps = #/[A-Z]/#
        let wordSeparators = CharacterSet(charactersIn: " :–—-‑")
        var nonPeriodPunctuation = CharacterSet.punctuationCharacters
        nonPeriodPunctuation.remove(charactersIn: "._-")
        
        let words = greedySplit(with: wordSeparators)
        let recapitalized = words.enumerated().map { (index, current) in
            if current == current.uppercased(), current.rangeOfCharacter(from: CharacterSet(charactersIn: "&")) == nil {
                return String(current).naivelyCapitalized()
            }
            
            if !current.ranges(of: smallWords).isEmpty,
               index != 0,
               index != words.count - 1,
               words[safe: index - 2] != ":"
            {
                return current.lowercased()
            }
            
            // Preserve intentional capitalization
            let includedRange = current.index(current.startIndex, offsetBy: 1)..<current.endIndex
            let capitalRanges = current[includedRange].ranges(of: caps)
            if !capitalRanges.isEmpty {
                return String(current)
            }
            
            if current.contains("@") {
                return String(current)
            }
            
            // Ignore filenames and paths.
            // When looking for periods, only include cases without other punctuation (e.g. quote marks).
            if (current.range(of: ".") != nil && current.rangeOfCharacter(from: nonPeriodPunctuation) == nil)
                || current.first == "/" {
                return String(current)
            }
            
            // Ignore URLs
            if words[safe: index + 1] == ":",
               words[safe: index + 2]?.hasPrefix("//") == true {
                return String(current)
            }
            
            return String(current).naivelyCapitalized()
        }
        
        return recapitalized.joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func greedySplit(with separators: CharacterSet) -> [Substring] {
        var components = [Substring]()
        var position = startIndex
        
        while let range = rangeOfCharacter(from: separators, range: position..<endIndex) {
            if range.lowerBound != position {
                components.append(self[position..<range.lowerBound])
            }
            
            components.append(self[range])
            position = range.upperBound
        }
        
        if position != endIndex {
            components.append(self[position..<endIndex])
        }
        
        return components
    }
    
    subscript(_ i: Int) -> String? {
        guard !isEmpty,
              let range = index(startIndex,
                                offsetBy: i,
                                limitedBy: index(before: endIndex)) else { return nil }
        
        return String(self[range])
    }
    
    func naivelyCapitalized() -> Self {
        if contains("/") {
            guard count > 1 else { return self }
            
            return greedySplit(with: CharacterSet(charactersIn: "/")).map {
                String($0).naivelyCapitalized()
            }.joined()
        }
        
        let alphanumericPattern = #/([A-Za-z0-9\u{00C0}-\u{00FF}])/#.ignoresCase()
        
        let matches = ranges(of: alphanumericPattern)
        var recomposed = self
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
