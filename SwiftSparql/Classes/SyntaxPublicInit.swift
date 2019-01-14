
public extension Query {
    // generic select query
    public init(prologues: [Prologue], select: SelectQuery) {
        self.prologues = prologues
        self.query = .select(select)
        self.valuesClause = ValuesClause()
    }
}

public extension SelectQuery {
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

public extension SelectClause.Capture {
    public static func vars(_ vars: [Var]) -> SelectClause.Capture {
        return .expressions(vars.map {($0, nil)})
    }
}

public extension Expression {
    public init(_ v: Var) {
        self.ands = [ConditionalAndExpression(valueLogicals: [.init(v)])]
    }

    public init(_ pe: PrimaryExpression) {
        self.ands = [ConditionalAndExpression(valueLogicals: [.numeric(.single((.simple(pe), [])))])]
    }

    public init(_ v: BuiltInCall) {
        self.init(.builtInCall(v))
    }
}

public extension ValueLogical {
    public init(_ v: Var) {
        self = .numeric(.init(v))
    }
}

public extension NumericExpression {
    public init(_ v: Var) {
        self = .single((.simple(.var(v)), []))
    }
}

public extension WhereClause {
    public init(first: TriplesBlock?,
                successors: [(GraphPatternNotTriples, TriplesBlock?)]) {
        self.init(pattern: .groupGraphPatternSub(.init(first: first, successors: successors)))
    }
}

public extension TriplesBlock {
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
    public init(_ name: PNameLN) {
        self = .path([[PathEltOrInverse(name: name)]])
    }
}
