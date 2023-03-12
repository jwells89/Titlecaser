//
//  TaggedRange.swift
//  
//
//  Created by John Wells on 3/11/23.
//

import Foundation

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
        case beginsSubtitle
    }
}
