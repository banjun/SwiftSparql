import Foundation

public enum Serializer {
    public static func serialize(_ v: Query) -> String {
        return [
            v.prologues.map(serialize),
            [serialize(v.query)],
            [serialize(v.valuesClause)]
            ].flatMap {$0}.joined(separator: "\n")
    }

    public static func serialize(_ v: Prologue) -> String {
        switch v {
        case .base(let iri): return ["BASE", serialize(iri)].joined(separator: " ")
        case .prefix(let ns, let iri): return ["PREFIX", serialize(ns), serialize(iri)].joined(separator: " ")
        }
    }

    public static func serialize(_ v: Query.Query) -> String {
        switch v {
        case .select(let c): return serialize(c)
        case .construct(let c): return serialize(c)
        case .describe(let c): return serialize(c)
        case .ask(let c): return serialize(c)
        }
    }

    public static func serialize(_ v: SelectQuery) -> String {
        return [
            [serialize(v.selectClause)],
            v.datasetClause.map(serialize),
            [serialize(v.whereClause)],
            [serialize(v.solutionModifier)]
            ].flatMap {$0}.joined(separator: "\n")
    }

    public static func serialize(_ v: SelectClause) -> String {
        return [
            "SELECT",
            v.option.map(serialize),
            serialize(v.capture)
            ].compactMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: SelectClause.Option) -> String {
        switch v {
        case .distinct: return "DISTINCT"
        case .reduced: return "REDUCED"
        }
    }

    public static func serialize(_ v: SelectClause.Capture) -> String {
        switch v {
        case .all: return "*"
        case .expressions(let varAsExpressions): return varAsExpressions.map { (v: Var, e: Expression?) in
            e.map {"(\(serialize($0) + " AS " + serialize(v)))"} ?? serialize(v)}
            .joined(separator: " ")
        }
    }

    public static func serialize(_ v: DatasetClause) -> String {
        switch v {
        case .default(let c): return ["FROM", serialize(c)].joined(separator: " ")
        case .named(let c): return ["FROM", serialize(c)].joined(separator: " ")
        }
    }

    public static func serialize(_ v: WhereClause) -> String {
        return ["WHERE", serialize(v.pattern)].joined(separator: " ")
    }

    public static func serialize(_ v: ConditionalOrExpression) -> String {
        return v.ands.map(serialize).joined(separator: " || ")
    }

    public static func serialize(_ v: ConditionalAndExpression) -> String {
        return v.valueLogicals.map(serialize).joined(separator: " && ")
    }

    public static func serialize(_ v: ValueLogical) -> String {
        switch v {
        case .numeric(let n): return serialize(n)
        case .eq(let l, let r): return [serialize(l), "=", serialize(r)].joined(separator: " ")
        case .neq(let l, let r): return [serialize(l), "!=", serialize(r)].joined(separator: " ")
        case .lt(let l, let r): return [serialize(l), "<", serialize(r)].joined(separator: " ")
        case .gt(let l, let r): return [serialize(l), ">", serialize(r)].joined(separator: " ")
        case .lte(let l, let r): return [serialize(l), "<=", serialize(r)].joined(separator: " ")
        case .gte(let l, let r): return [serialize(l), ">=", serialize(r)].joined(separator: " ")
        case .in(let l, let rs): return [serialize(l), "IN", "(" + rs.map(serialize).joined(separator: ", ") + ")"].joined(separator: " ")
        case .notin(let l, let rs): return [serialize(l), "NOT IN", "(" + rs.map(serialize).joined(separator: ", ") + ")"].joined(separator: " ")
        }
    }

    public static func serialize(_ v: AdditiveExpression) -> String {
        switch v {
        case .single(let e): return serialize(e)
        case .plus(let l, let r): return [serialize(l), "+", serialize(r)].joined(separator: " ")
        case .minus(let l, let r): return [serialize(l), "-", serialize(r)].joined(separator: " ")
        case .multiple(let e, let n, let ms): return [[serialize(e)], [serialize(n)], ms.map(serialize)].flatMap {$0}.joined(separator: " ")
        }
    }

    public static func serialize(_ v: MultiplicativeExpression) -> String {
        return [[serialize(v.0)], v.1.map(serialize)].flatMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: AdditiveExpression.Multiplier) -> String {
        switch v {
        case .multiple(let e): return ["*", serialize(e)].joined(separator: " ")
        case .divide(let e): return ["/", serialize(e)].joined(separator: " ")
        }
    }

    public static func serialize(_ v: UnaryExpression) -> String {
        switch v {
        case .negate(let e): return ["!", serialize(e)].joined(separator: " ")
        case .plus(let e): return ["+", serialize(e)].joined(separator: " ")
        case .minus(let e): return ["-", serialize(e)].joined(separator: " ")
        case .simple(let e): return serialize(e)
        }
    }

    public static func serialize(_ v: PrimaryExpression) -> String {
        switch v {
        case .brackettedExpression(let e): return "(" + serialize(e) + ")"
        case .builtInCall(let c): return serialize(c)
        case .iriOrFunction(let v): return serialize(v)
        case .rdfLiteral(let v): return serialize(v)
        case .numericLiteral(let v): return serialize(v)
        case .booleanLiteral(let v): return serialize(v)
        case .var(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: NumericLiteral) -> String {
        switch v {
        case .integer(let v): return serialize(v)
        case .decimal(let v): return serialize(v)
        case .double(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: RDFLiteral) -> String {
        return "\"\(v.string)\""
    }

    public static func serialize(_ v: Int) -> String {
        return String(v)
    }

    public static func serialize(_ v: Double) -> String {
        return String(v)
    }

    public static func serialize(_ v: Bool) -> String {
        return v ? "true" : "false"
    }

    public static func serialize(_ v: IRIOrFunction) -> String {
        return [serialize(v.iri), v.argList.map(serialize)].compactMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: Var) -> String {
        return v
    }

    public static func serialize(_ v: SolutionModifier) -> String {
        return [
            v.group.map(serialize),
            v.having.map(serialize),
            v.order.map(serialize),
            v.limit.map(serialize),
            ].compactMap {$0}.joined(separator: "\n")
    }

    public static func serialize(_ v: GroupClause) -> String {
        return [["GROUP BY"], v.map(serialize)].flatMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: HavingClause) -> String {
        return [["HAVING"], v.map(serialize)].flatMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: OrderClause) -> String {
        return [["ORDER BY"], v.map(serialize)].flatMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: Constraint) -> String {
        switch v {
        case .brackettedExpression(let e): return "(" + serialize(e) + ")"
        case .builtInCall(let c): return serialize(c)
        case .functionCall(let c): return serialize(c)
        }
    }

    public static func serialize(_ v: OrderCondition) -> String {
        switch v {
        case .asc(let e): return "ASC(\(serialize(e)))"
        case .desc(let e): return "DESC(\(serialize(e)))"
        case .constraint(let c): return serialize(c)
        case .var(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: LimitOffsetClauses) -> String {
        switch v {
        case .limit(let limit, offset: let offset): return "LIMIT \(limit)" + (offset.map {"OFFSET \($0)"} ?? "")
        case .offset(let offset, limit: let limit): return "OFFSET \(offset)" + (limit.map {"LIMIT \($0)"} ?? "")
        }
    }

    public static func serialize(_ v: GroupCondition) -> String {
        switch v {
        case .builtInCall(let c): return serialize(c)
        case .functionCall(let c): return serialize(c)
        case .expression(let e, let v): return "(" + serialize(e) + (v.map {" AS \(serialize($0))"} ?? "") + ")"
        case .var(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: ConstructQuery) -> String {
        return "(TODO)" // TODO: pending
    }

    public static func serialize(_ v: DescribeQuery) -> String {
        return "(TODO)" // TODO: pending
    }

    public static func serialize(_ v: AskQuery) -> String {
        return "(TODO)" // TODO: pending
    }

    public static func serialize(_ v: ValuesClause) -> String {
        return "" // TODO: pending
    }

    public static func serialize(_ v: IRI) -> String {
        switch v {
        case .ref(let r): return serialize(r)
        case .prefixedName(let n): return serialize(n)
        }
    }

    public static func serialize(_ v: IRIRef) -> String {
        return "<" + v.value + ">"
    }

    public static func serialize(_ v: PrefixedName) -> String {
        switch  v {
        case .ln(let n): return serialize(n)
        case .ns(let n): return serialize(n)
        }
    }

    public static func serialize(_ v: PNameLN) -> String {
        return [
            serialize(v.0),
            serialize(v.1),
        ].joined(separator: "")
    }

    public static func serialize(_ v: PNameNS) -> String {
        return (v.value ?? "") + ":"
    }

    public static func serialize(_ v: FunctionCall) -> String {
        return [
            serialize(v.iri),
            serialize(v.argList),
            ].joined(separator: " ")
    }

    public static func serialize(_ v: ArgList) -> String {
        return [
            v.distinct ? ["DISTINCT"] : [],
            v.expressions.map(serialize)
            ].flatMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: BuiltInCall) -> String {
        switch v {
        case .count(let distinct, let expression): return "COUNT(\(distinct ? "DISTINCT " : "")\(expression.map(serialize) ?? "*"))"
        case .sum(let distinct, let expression): return "SUM(\(distinct ? "DISTINCT " : "")\(serialize(expression)))"
        case .min(let distinct, let expression): return "MIN(\(distinct ? "DISTINCT " : "")\(serialize(expression)))"
        case .max(let distinct, let expression): return "MAX(\(distinct ? "DISTINCT " : "")\(serialize(expression)))"
        case .average(let distinct, let expression): return "AVERAGE(\(distinct ? "DISTINCT " : "")\(serialize(expression)))"
        case .sample(let distinct, let expression): return "SAMPLE(\(distinct ? "DISTINCT " : "")\(serialize(expression)))"
        case .groupConcat(let distinct, let expression, let separator): return "GROUP_CONCAT(\(distinct ? "DISTINCT " : "")\(serialize(expression))\(separator.map {"; SEPARATOR = \"\($0)\""} ?? ""))"
        case .STR(let e): return "STR(\(serialize(e)))"
        case .LANG(let e): return "LANG(\(serialize(e)))"
        case .LANGMATCHES(let e1, let e2): return "LANGMATCHES(\(serialize(e1)), \(serialize(e2))"
        case .DATATYPE(let e): return "DATATYPE(\(serialize(e)))"
        case .BOUND(let v): return "BOUND(\(serialize(v)))"
        case .IRI(let e): return "IRI(\(serialize(e)))"
        case .URI(let e): return "URI(\(serialize(e)))"
        case .BNODE(let e): return "BNODE" + (e.map {"(\(serialize($0)))"} ?? "")
        case .RAND: return "RAND()"
        case .ABS(let e): return "ABS(\(serialize(e))))"
        case .CEIL(let e): return "CEIL(\(serialize(e))))"
        case .FLOOR(let e): return "FLOOR(\(serialize(e))))"
        case .ROUND(let e): return "ROUND(\(serialize(e))))"
        case .CONCAT(let el): return "CONCAT(\(el.map(serialize).joined(separator: ", "))))"
        case .substr(let e1, let e2, let e3): return "SUBSTR(\([serialize(e1), serialize(e2), e3.map(serialize)].compactMap {$0}.joined(separator: ", ")))"
        case .STRLEN(let e): return "STRLEN(\(serialize(e))))"
        case .replace(let e1, let e2, let e3, let e4): return "REPLACE(\([serialize(e1), serialize(e2), serialize(e3), e4.map(serialize)].compactMap {$0}.joined(separator: ", ")))"
        case .UCASE(let e): return "UCASE(\(serialize(e))))"
        case .LCASE(let e): return "LCASE(\(serialize(e))))"
        case .ENCODE_FOR_URI(let e): return "ENCODE_FOR_URI(\(serialize(e))))"
        case .CONTAINS(let e1, let e2): return "CONTAINS(\(serialize(e1)), \(serialize(e2)))"
        case .STRSTARTS(let e1, let e2): return "STRSTARTS(\(serialize(e1)), \(serialize(e2)))"
        case .STRENDS(let e1, let e2): return "STRENDS(\(serialize(e1)), \(serialize(e2)))"
        case .STRBEFORE(let e1, let e2): return "STRBEFORE(\(serialize(e1)), \(serialize(e2)))"
        case .STRAFTER(let e1, let e2): return "STRAFTER(\(serialize(e1)), \(serialize(e2)))"
        case .YEAR(let e): return "YEAR(\(serialize(e))))"
        case .MONTH(let e): return "MONTH(\(serialize(e))))"
        case .DAY(let e): return "DAY(\(serialize(e))))"
        case .HOURS(let e): return "HOURS(\(serialize(e))))"
        case .MINUTES(let e): return "MINUTES(\(serialize(e))))"
        case .SECONDS(let e): return "SECONDS(\(serialize(e))))"
        case .TIMEZONE(let e): return "TIMEZONE(\(serialize(e))))"
        case .TZ(let e): return "TZ(\(serialize(e))))"
        case .NOW: return "NOW()"
        case .UUID: return "UUID()"
        case .STRUUID: return "STRUUID()"
        case .MD5(let e): return "MD5(\(serialize(e))))"
        case .SHA1(let e): return "SHA1(\(serialize(e))))"
        case .SHA256(let e): return "SHA256(\(serialize(e))))"
        case .SHA384(let e): return "SHA384(\(serialize(e))))"
        case .SHA512(let e): return "SHA512(\(serialize(e))))"
        case .COALESCE(let el): return "COALESCE(\(el.map(serialize).joined(separator: ", "))))"
        case .IF(let e1, let e2, let e3): return "IF(\([serialize(e1), serialize(e2), serialize(e3)].joined(separator: ", ")))"
        case .STRLANG(let e1,let e2): return "STRLANG(\(serialize(e1)), \(serialize(e2)))"
        case .STRDT(let e1,let e2): return "STRDT(\(serialize(e1)), \(serialize(e2)))"
        case .sameTerm(let e1,let e2): return "sameTerm(\(serialize(e1)), \(serialize(e2)))"
        case .isIRI(let e): return "isIRI(\(serialize(e))))"
        case .isURI(let e): return "isURI(\(serialize(e))))"
        case .isBLANK(let e): return "isBLANK(\(serialize(e))))"
        case .isLITERAL(let e): return "isLITERAL(\(serialize(e))))"
        case .isNUMERIC(let e): return "isNUMERIC(\(serialize(e))))"
        case .regex(let e1, let e2, let e3): return "REGEX(\([serialize(e1), serialize(e2), e3.map(serialize)].compactMap {$0}.joined(separator: ", ")))"
        case .exists(let p): return "EXISTS" + serialize(p)
        case .notExists(let p): return "NOT EXISTS" + serialize(p)
        }
    }

    public static func serialize(_ v: GroupGraphPattern) -> String {
        let body: String
        switch v {
        case .subSelect(let v): body = serialize(v)
        case .groupGraphPatternSub(let v): body = serialize(v)
        }
        return "{\n" + body.components(separatedBy: .newlines).map {"    " + $0}.joined(separator: "\n") + "\n}"
    }

    public static func serialize(_ v: SubSelect) -> String {
        return [
            serialize(v.selectClause),
            serialize(v.whereClause),
            serialize(v.solutionModifier),
            serialize(v.valuesClause),
        ].joined(separator: "\n")
    }

    public static func serialize(_ v: GroupGraphPatternSub) -> String {
        return [
            v.first.map {[serialize($0)]} ?? [],
            v.successors.map {[serialize($0), ".\n", $1.map(serialize)].compactMap {$0}.joined(separator: " ")}
            ].flatMap {$0}.joined(separator: " ")
    }


    public static func serialize(_ v: GraphPatternNotTriples) -> String {
        switch v {
        case .GroupOrUnionGraphPattern(let ps): return ps.map(serialize).joined(separator: " UNION ")
        case .OptionalGraphPattern(let p): return ["OPTIONAL", serialize(p)].joined(separator: " ")
        case .MinusGraphPattern(let p): return ["MINUS", serialize(p)].joined(separator: " ")
        case .GraphGraphPattern(let v, let p): return ["GRAPH", serialize(v), serialize(p)].joined(separator: " ")
        case .ServiceGraphPattern(let silent, let v, let p): return ["SERVICE", silent ? "SILENT": "", serialize(v), serialize(p)].joined(separator: " ")
        case .Filter(let c): return ["FILTER", serialize(c)].joined(separator: " ")
        case .Bind(let e, let v): return ["BIND", serialize(e), "AS", serialize(v)].joined(separator: " ")
        case .InlineData(let v): return ["VALUES", serialize(v)].joined(separator: " ")
        }
    }

    public static func serialize(_ v: TriplesBlock) -> String {
        return [
            serialize(v.triplesSameSubjectPath),
            v.triplesBlock.value.map(serialize)
            ].compactMap {$0}.joined(separator: "\n")
    }

    public static func serialize(_ v: TriplesSameSubjectPath) -> String {
        switch v {
        case .varOrTerm(let vt, let p): return [serialize(vt), serialize(p)].joined(separator: " ")
        case .triplesNodePath(let tp, let p): return [serialize(tp), p.map(serialize)].compactMap {$0}.joined(separator: " ")
        }
    }

    public static func serialize(_ v: VarOrTerm) -> String {
        switch v {
        case .var(let v): return serialize(v)
        case .term(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: TriplesNodePath) -> String {
        switch v {
        case .collection(let v): return serialize(v)
        case .blank(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: GraphTerm) -> String {
        switch v {
        case .iri(let v): return serialize(v)
        case .rdf(let v): return serialize(v)
        case .numeric(let v): return serialize(v)
        case .boolean(let v): return serialize(v)
        case .blank(let v): return serialize(v)
        case .nil: return "()"
        }
    }

    public static func serialize(_ v: BlankNode) -> String {
        switch v {
        case .label(let v): return "_:" + v
        case .anon: return "[]"
        }
    }

    public static func serialize(_ v: CollectionPath) -> String {
        return "(" + v.paths.map(serialize).joined(separator: " ") + ")"
    }

    public static func serialize(_ v: ObjectListPath) -> String {
        return v.map(serialize).joined(separator: ", ")
    }

    public static func serialize(_ v: GraphNodePath) -> String {
        switch v {
        case .varOrTerm(let v): return serialize(v)
        case .triplesNodePath(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: PropertyListPathNotEmpty) -> String {
        return [
            [serialize(v.verb)],
            [serialize(v.objectListPath)],
            v.successors.map {[";\n    ", serialize($0), serialize($1)].joined(separator: " ")},
            [".\n"]
            ].flatMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: PropertyListPathNotEmpty.Verb) -> String {
        switch v {
        case .simple(let v): return serialize(v)
        case .path(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: ObjectList) -> String {
        return v.map(serialize).joined(separator: ", ")
    }

    public static func serialize(_ v: GraphNode) -> String {
        switch v {
        case .varOrTerm(let v): return serialize(v)
        case .triplesNode(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: TriplesNode) -> String {
        switch v {
        case .collection(let v): return serialize(v)
        case .blankNode(let v): return "[" + serialize(v) + "]"
        }
    }

    public static func serialize(_ v: PropertyListNotEmpty) -> String {
        return v.list.map {[serialize($0), serialize($1)].joined(separator: " ")}.joined(separator: "; ")
    }

    public static func serialize(_ v: Verb) -> String {
        switch v {
        case .a: return "a"
        case .iri(let v): return serialize(v)
        case .var(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: VerbPath) -> String {
        return v.map(serialize).joined(separator: "|")
    }


    public static func serialize(_ v: PathSequence) -> String {
        return v.map(serialize).joined(separator: " / ")
    }

    public static func serialize(_ v: PathEltOrInverse) -> String {
        switch v {
        case .elt(let e): return serialize(e)
        case .hat_elt(let e): return "^" + serialize(e)
        }
    }

    public static func serialize(_ v: PathElt) -> String {
        return [
            serialize(v.primary),
            v.mod.map(serialize)
            ].compactMap {$0}.joined(separator: " ")
    }

    public static func serialize(_ v: PathPrimary) -> String {
        switch v {
        case .iri(let v): return serialize(v)
        case .a: return "a"
        case .pathNegatedPropertySet(let s): return "!" + serialize(s)
        case .path(let p): return "(" + serialize(p) + ")"
        }
    }

    public static func serialize(_ v: PathNegatedPropertySet) -> String {
        return "(" + v.map(serialize).joined(separator: " | ") + ")"
    }

    public static func serialize(_ v: PathOneInPropertySet) -> String {
        switch v {
        case .iri(let v): return serialize(v)
        case .a: return "a"
        case .hat_iri(let v): return "^" + serialize(v)
        case .hat_a: return "^a"
        }
    }

    public static func serialize(_ v: PathMod) -> String {
        return v.rawValue
    }

    public static func serialize(_ v: VarOrIRI) -> String {
        switch v {
        case .var(let v): return serialize(v)
        case .iri(let v): return serialize(v)
        }
    }

    public static func serialize(_ v: DataBlock) -> String {
        return "(TODO)" // TODO: pending
    }
}
