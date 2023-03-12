//
//  Substring+Titlecaser.swift
//  
//
//  Created by John Wells on 3/11/23.
//

import Foundation

extension Substring {
    var hasNonstandardCapitals: Bool {
        /// Skip first letter
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
        
        /// Split and recurse for non-path slash usage
        if contains("/") {
            guard count > 1 else { return self }
            
            for word in split(separator: "/") {
                recomposed.replaceSubrange(word.startIndex..<word.endIndex,
                                           with: word.naivelyCapitalized())
            }
            
            return recomposed
        }
        
        var position: Substring.Index?
        
        while let range = rangeOfCharacter(from: .alphanumerics, range: (position ?? startIndex)..<endIndex) {
            /// Capitalize first letter in the substring
            if position == nil {
                recomposed.replaceSubrange(range, with: self[range].uppercased())
            } else {
                recomposed.replaceSubrange(range, with: self[range].lowercased())
            }
            
            position = range.upperBound
        }
        
        return recomposed
    }
}
