
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

public extension TriplesBlock {
    public init(
        triplesSameSubjectPath: TriplesSameSubjectPath,
        triplesBlock: TriplesBlock?) {
        self.init(
            triplesSameSubjectPath: triplesSameSubjectPath,
            triplesBlock: Indirect(triplesBlock))
    }
}
