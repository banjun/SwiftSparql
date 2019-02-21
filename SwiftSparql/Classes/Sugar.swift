public enum GroupGraphPatternSubType {
    case triple(VarOrTerm, PropertyListPathNotEmpty.Verb, ObjectListPath)
    case notTriple(GraphPatternNotTriples)
}

public extension WhereClause {
    public init(patterns: [GroupGraphPatternSubType]) {
        self.init(pattern: .groupGraphPatternSub(.init(patterns: patterns)))
    }
}

public extension GroupGraphPatternSub {
    init(patterns: [GroupGraphPatternSubType]) {
        var intermediates: [(GraphPatternNotTriples?, [TriplesSameSubjectPath])] = []

        patterns.forEach { e in
            switch e {
            case .triple(let t):
                let tssp = TriplesSameSubjectPath.varOrTerm(t.0, .init(verb: t.1, objectListPath: t.2, successors: []))
                var x = intermediates.popLast() ?? (nil, [])
                x.1.append(tssp)
                intermediates.append(x)
            case .notTriple(let nt):
                intermediates.append((nt, []))
            }
        }

        if let first = intermediates.first {
            self.init(
                first: first.0 == nil ? TriplesBlock(first.1) : nil,
                successors: intermediates.dropFirst().compactMap { nt, ts in
                    nt.map {($0, TriplesBlock(ts))}
            })
        } else {
            self.init(first: nil, successors: [])
        }
    }
}

extension TriplesBlock {
    init?(_ groups: [TriplesSameSubjectPath]) {
        guard let head = groups.first else { return nil }
        let tail = Array(groups.dropFirst())
        self.init(triplesSameSubjectPath: head, triplesBlock: .init(TriplesBlock(tail)))
    }
}

// MARK: - Triples Builder

public protocol TripleBuilderStateType {}
public protocol TripleBuilderStateIncompleteSubjectType: TripleBuilderStateType {}
public struct TripleBuilderStateIncompleteSubject: TripleBuilderStateIncompleteSubjectType {}
public protocol TripleBuilderStateRDFTypeBoundType: TripleBuilderStateType {
    associatedtype RDFType
}
public struct TripleBuilderStateRDFTypeBound<T: RDFTypeConvertible>: TripleBuilderStateRDFTypeBoundType {
    public typealias RDFType = T
}

public protocol IRIBaseProvider {
    static var base: IRIRef { get }
}

public extension IRIBaseProvider {
    static func rdfType(_ local: String) -> IRIRef {return IRIRef(value: base.value + local)}
    static func verb(_ local: String) -> IRIRef {return IRIRef(value: base.value + local)}
    static func verb(_ local: String) -> PropertyListPathNotEmpty.Verb {
        return .init(IRIRef(value: base.value + local))
    }
}

public protocol RDFTypeConvertible {
    associatedtype Schema: IRIBaseProvider
    static var rdfType: IRIRef { get }
}

public struct TripleBuilder<State: TripleBuilderStateType> {
    public var subject: Var
    public var triples: [GroupGraphPatternSubType]

    public init(subject: Var, triples: [GroupGraphPatternSubType]) {
        self.subject = subject
        self.triples = triples
    }

    static func subject(_ v: Var) -> TripleBuilder<TripleBuilderStateIncompleteSubject> {
        return .init(subject: v, triples: [])
    }

    public init(base: TripleBuilder<State>, appendingVerb verb: PropertyListPathNotEmpty.Verb, value: ObjectListPath) {
        self.init(subject: base.subject, triples: base.triples + [.triple(.var(base.subject), verb, value)])
    }

    func appended(verb: PropertyListPathNotEmpty.Verb, value: ObjectListPath) -> TripleBuilder<State> {
        return .init(base: self, appendingVerb: verb, value: value)
    }
}

public func subject(_ v: Var) -> TripleBuilder<TripleBuilderStateIncompleteSubject> {
    return .subject(v)
}

public enum RDFSyntaxNSSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfType<T: RDFTypeConvertible>(is type: T.Type) -> TripleBuilder<TripleBuilderStateRDFTypeBound<T>> {
        let new = appended(verb: RDFSyntaxNSSchema.verb("type"), value: [.iriRef(type.rdfType)])
        return .init(subject: subject, triples: new.triples)
    }
}

// MARK: - imas:Idol

public enum ImasSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl#")}
}

public struct ImasIdol: RDFTypeConvertible {
    public typealias Schema = ImasSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Idol")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsImasIdol() -> TripleBuilder<TripleBuilderStateRDFTypeBound<ImasIdol>> {return rdfType(is: ImasIdol.self)}
}

extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == ImasIdol {
    // MARK: generated functions in form of imas:_

    /// 名前よみがな: 名前のよみがなを表すプロパティ
    public func nameKana(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: State.RDFType.Schema.verb("nameKana"), value: [.literal(v)])
    }
    /// 名前よみがな: 名前のよみがなを表すプロパティ
    public func nameKana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: State.RDFType.Schema.verb("nameKana"), value: [.var(v)])
    }

    ///
    public func title(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: State.RDFType.Schema.verb("Title"), value: [.literal(v)])
    }
    ///
    public func title(is v: Var) -> TripleBuilder<State> {
        return appended(verb: State.RDFType.Schema.verb("Title"), value: [.var(v)])
    }

    ///
    public func color(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: State.RDFType.Schema.verb("Color"), value: [.literal(v)])
    }
    ///
    public func color(is v: Var) -> TripleBuilder<State> {
        return appended(verb: State.RDFType.Schema.verb("Color"), value: [.var(v)])
    }

    // MARK: generated functions in form of schema:_

    public func schemaName(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaOrg.verb("name"), value: [.literal(v)])
    }

    public func schemaName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaOrg.verb("name"), value: [.var(v)])
    }

    public func schemaHeight(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaOrg.verb("height"), value: [.var(v)])
    }
}

// MARK: - imas:Unit

public struct ImasUnit: RDFTypeConvertible {
    public typealias Schema = ImasSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Unit")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsImasUnit() -> TripleBuilder<TripleBuilderStateRDFTypeBound<ImasUnit>> {return rdfType(is: ImasUnit.self)}
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == ImasUnit {
    // MARK: generated functions in form of schema:_
    
    /// member: A member of an Organization or a ProgramMembership. Organizations can be members of organizations; ProgramMembership is typically for individuals.
    func schemaMember(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaOrg.verb("member"), value: [.literal(v)])
    }
}

// MARK: - schema.org

public enum SchemaOrg: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://schema.org/")}
}
