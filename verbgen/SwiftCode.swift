enum SwiftCode {
    static func gen(_ v: IRIBaseProvider) -> String {
        return """
        fileprivate enum \(v.typeName): IRIBaseProvider {
            static var base: IRIRef {return IRIRef(value: "\(v.iri.value)")}
        }
        """
    }

    static func gen(_ v: RDFTypeConvertible) -> String {
        return """
        public struct \(v.type.id): RDFTypeConvertible {
            public static var rdfType: IRIRef {return \(v.schema.typeName).rdfType("\(v.local)")}
        }

        extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
            public func rdfTypeIs\(v.type.id)() -> TripleBuilder<TripleBuilderStateRDFTypeBound<\(v.type.id)>> {return rdfType(is: \(v.type.id).self)}
        }
        """
    }

    static func gen(_ v: TripleBuilderStateRDFTypeBoundType) -> String {
        let verbFuncs = v.verbs.map { v -> String in
            let docComment = [v.label, v.comment].compactMap {$0}.joined(separator: ": ")
                .components(separatedBy: .newlines)
                .map {"/// " + $0}
                .joined(separator: "\n")
            let funcName = CamelIdentifier(raw: v.prefix + CamelIdentifier(raw: v.local).id).firstLoweredID
            return """
            \(docComment)
            func \(funcName)(is v: GraphTerm) -> TripleBuilder<State> {
                return appended(verb: \(v.schema).verb("\(v.local)"), value: [.varOrTerm(.term(v))])
            }

            \(docComment)
            func \(funcName)(is v: Var) -> TripleBuilder<State> {
                return appended(verb: \(v.schema).verb("\(v.local)"), value: [.var(v)])
            }
            """
        }

        return """
        public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == \(v.type.id) {
        \(verbFuncs.joined(separator: "\n\n")
        .components(separatedBy: .newlines)
        .map {"    " + $0}
        .joined(separator: "\n"))
        }
        """
    }
}
