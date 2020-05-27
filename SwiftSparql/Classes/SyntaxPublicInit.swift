
extension Query {
    // generic select query
    public init(prologues: [Prologue] = [], select: SelectQuery) {
        self.prologues = prologues
        self.query = .select(select)
        self.valuesClause = ValuesClause()
    }
}

extension SelectQuery {
    public init(
        option: SelectClause.Option? = nil,
        capture: SelectClause.Capture = .all,
        dataset: [DatasetClause] = [],
        where: WhereClause,
        group: GroupClause? = nil,
        having: HavingClause? = nil,
        order: OrderClause? = nil,
        limit: LimitOffsetClauses? = nil) {
        self.init(
            selectClause: SelectClause(option: option, capture: capture),
            datasetClause: dataset,
            whereClause: `where`,
            solutionModifier: SolutionModifier(group: group, having: having, order: order, limit: limit))
    }
}

extension SelectClause.Capture {
    public static func vars(_ vars: [Var]) -> SelectClause.Capture {
        return .expressions(vars.map {($0, nil)})
    }
}

extension Expression: ExpressibleByStringLiteral {
    public init(_ v: Var) {
        self.ands = [ConditionalAndExpression(valueLogicals: [.init(v)])]
    }

    public init(_ v: ValueLogical) {
        self.ands = [ConditionalAndExpression(valueLogicals: [v])]
    }

    public init(_ pe: PrimaryExpression) {
        self.ands = [ConditionalAndExpression(valueLogicals: [.numeric(.single((.simple(pe), [])))])]
    }

    public init(_ v: BuiltInCall) {
        self.init(.builtInCall(v))
    }

    public init(stringLiteral value: String) {
        self.init(PrimaryExpression.rdfLiteral(.init(string: value)))
    }
}

extension ValueLogical {
    public init(_ v: Var) {
        self = .numeric(.init(v))
    }
}

public func == (lhs: NumericExpression, rhs: NumericExpression) -> ValueLogical { return .eq(lhs, rhs) }
public func != (lhs: NumericExpression, rhs: NumericExpression) -> ValueLogical { return .neq(lhs, rhs) }
public func < (lhs: NumericExpression, rhs: NumericExpression) -> ValueLogical { return .lt(lhs, rhs) }
public func > (lhs: NumericExpression, rhs: NumericExpression) -> ValueLogical { return .gt(lhs, rhs) }
public func <= (lhs: NumericExpression, rhs: NumericExpression) -> ValueLogical { return .lte(lhs, rhs) }
public func >= (lhs: NumericExpression, rhs: NumericExpression) -> ValueLogical { return .gte(lhs, rhs) }

public func == (lhs: Var, rhs: NumericExpression) -> ValueLogical { return .eq(NumericExpression(lhs), rhs) }
public func != (lhs: Var, rhs: NumericExpression) -> ValueLogical { return .neq(NumericExpression(lhs), rhs) }
public func < (lhs: Var, rhs: NumericExpression) -> ValueLogical { return .lt(NumericExpression(lhs), rhs) }
public func > (lhs: Var, rhs: NumericExpression) -> ValueLogical { return .gt(NumericExpression(lhs), rhs) }
public func <= (lhs: Var, rhs: NumericExpression) -> ValueLogical { return .lte(NumericExpression(lhs), rhs) }
public func >= (lhs: Var, rhs: NumericExpression) -> ValueLogical { return .gte(NumericExpression(lhs), rhs) }

public func == (lhs: NumericExpression, rhs: Var) -> ValueLogical { return .eq(lhs, NumericExpression(rhs)) }
public func != (lhs: NumericExpression, rhs: Var) -> ValueLogical { return .neq(lhs, NumericExpression(rhs)) }
public func < (lhs: NumericExpression, rhs: Var) -> ValueLogical { return .lt(lhs, NumericExpression(rhs)) }
public func > (lhs: NumericExpression, rhs: Var) -> ValueLogical { return .gt(lhs, NumericExpression(rhs)) }
public func <= (lhs: NumericExpression, rhs: Var) -> ValueLogical { return .lte(lhs, NumericExpression(rhs)) }
public func >= (lhs: NumericExpression, rhs: Var) -> ValueLogical { return .gte(lhs, NumericExpression(rhs)) }

extension Constraint {
    public static func logical(_ v: ValueLogical) -> Constraint {
        return .brackettedExpression(.init(v))
    }
}

extension NumericExpression {
    public init(_ v: Var) {
        self = .single((.simple(.var(v)), []))
    }
}
extension NumericExpression: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .single((.simple(.numericLiteral(.integer(value))), []))
    }
}

extension LimitOffsetClauses: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .limit(value)
    }
}

extension WhereClause {
    public init(first: TriplesBlock?,
                successors: [(GraphPatternNotTriples, TriplesBlock?)]) {
        self.init(pattern: .groupGraphPatternSub(.init(first: first, successors: successors)))
    }
}

extension TriplesBlock {
    public init(
        triplesSameSubjectPath: TriplesSameSubjectPath,
        triplesBlock: TriplesBlock?) {
        self.init(
            triplesSameSubjectPath: triplesSameSubjectPath,
            triplesBlock: Indirect(triplesBlock))
    }
}

public extension PathEltOrInverse {
    init(name: PNameLN) {
        self = .elt(.init(primary: .iri(.prefixedName(.ln(name))), mod: nil))
    }
}

public func | (lhs: PathAlternative, rhs: PathAlternative) -> PathAlternative {
    return lhs + rhs
}

public func | (lhs: PathSequence, rhs: PathSequence) -> PathAlternative {
    return [lhs, rhs]
}

public func | (lhs: PathAlternative, rhs: PathSequence) -> PathAlternative {
    return lhs + [rhs]
}

public func | (lhs: PathSequence, rhs: PathEltOrInverse) -> PathAlternative {
    return lhs | [rhs]
}

public func | (lhs: PathEltOrInverse, rhs: PathEltOrInverse) -> PathAlternative {
    return [lhs] | [rhs]
}

public func | (lhs: PathEltOrInverse, rhs: PNameLN) -> PathAlternative {
    return [lhs] | PathEltOrInverse(name: rhs)
}

public func | (lhs: PNameLN, rhs: PNameLN) -> PathAlternative {
    return PathEltOrInverse(name: lhs) | PathEltOrInverse(name: rhs)
}

public extension PropertyListPathNotEmpty.Verb {
    init(_ name: PNameLN) {
        self = .path([[PathEltOrInverse(name: name)]])
    }

    init(_ ref: IRIRef) {
        self = .path(.init([[.elt(.init(primary: .iri(.ref(ref)), mod: nil))]]))
    }
}

extension RDFLiteral: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)
    }
}

extension GraphNodePath {
    public static func `var`(_ v: Var) -> GraphNodePath {
        return .varOrTerm(.var(v))
    }

    public static func literal(_ v: RDFLiteral) -> GraphNodePath {
        return .varOrTerm(.term(.rdf(v)))
    }

    public static func iriRef(_ r: IRIRef) -> GraphNodePath {
        return .varOrTerm(.term(.iri(.ref(r))))
    }
}

extension GraphNode {
    public static func `var`(_ v: Var) -> GraphNode {
        return .varOrTerm(.var(v))
    }
}

public extension IRIRef {
    init?(_ prefixedName: PrefixedName, on prologues: [Prologue]) {
        let ns: PNameNS
        let local: String?
        switch prefixedName {
        case .ln((let n, let l)): (ns, local) = (n, l)
        case .ns(let n): (ns, local) = (n, nil)
        }

        guard let iri: IRIRef = (prologues.lazy.compactMap {
            switch $0 {
            case .prefix(ns, let iri): return iri
            case .prefix: return nil
            case .base(let iri): return ns.value == nil ? iri : nil
            }
            }.first) else { return nil }
        self.init(value: iri.value + (local ?? ""))
    }
    init?(_ iri: IRI, on prologues: [Prologue]) {
        switch iri {
        case .ref(let iri): self.init(value: iri.value)
        case .prefixedName(let p): self.init(p, on: prologues)
        }
    }
}

extension GraphTerm: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public init(stringLiteral value: String) {
        self = .rdf(RDFLiteral(stringLiteral: value))
    }

    public init(integerLiteral value: Int) {
        self = .numeric(.integer(value))
    }

    public init(floatLiteral value: Float) {
        self = .numeric(.double(Double(value)))
    }
}

public extension GraphTerm {
    static func literal(_ string: String, lang: String?) -> GraphTerm {
        return .rdf(RDFLiteral(string: string, lang: lang))
    }
}
