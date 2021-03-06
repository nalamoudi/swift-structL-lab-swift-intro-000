import Foundation

public func containElementSatisfying<S: Sequence, T>(_ predicate: @escaping ((T) -> Bool), _ predicateDescription: String = "") -> NonNilMatcherFunc<S> where S.Iterator.Element == T {

    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil

        if predicateDescription == "" {
            failureMessage.postfixMessage = "find object in collection that satisfies predicate"
        } else {
            failureMessage.postfixMessage = "find object in collection \(predicateDescription)"
        }

        if let sequence = try actualExpression.evaluate() {
            for object in sequence {
                if predicate(object) {
                    return true
                }
            }

            return false
        }

        return false
    }
}

#if _runtime(_ObjC)
    extension NMBObjCMatcher {
        public class func containElementSatisfyingMatcher(_ predicate: @escaping ((NSObject) -> Bool)) -> NMBObjCMatcher {
            return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
                let value = try! actualExpression.evaluate()
                guard let enumeration = value as? NSFastEnumeration else {
                    failureMessage.postfixMessage = "containElementSatisfying must be provided an NSFastEnumeration object"
                    failureMessage.actualValue = nil
                    failureMessage.expected = ""
                    failureMessage.to = ""
                    return false
                }

                var iterator = NSFastEnumerationIterator(enumeration)
                while let item = iterator.next() {
                    guard let object = item as? NSObject else {
                        continue
                    }

                    if predicate(object) {
                        return true
                    }
                }

                failureMessage.actualValue = nil
                failureMessage.postfixMessage = ""
                failureMessage.to = "to find object in collection that satisfies predicate"
                return false
            }
        }
    }
#endif
