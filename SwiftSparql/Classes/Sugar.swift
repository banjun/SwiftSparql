public enum GroupGraphPatternSubType {
    case triple(VarOrTerm, PropertyListPathNotEmpty.Verb, ObjectListPath)
    case notTriple(GraphPatternNotTriples)
}

public extension GroupGraphPatternSubType {
    static func filter(_ c: Constraint) -> GroupGraphPatternSubType {
        return .notTriple(.Filter(c))
    }
    static func filter(_ c: BuiltInCall) -> GroupGraphPatternSubType {
        return .filter(.builtInCall(c))
    }
}

public extension BuiltInCall {
    static func CONTAINS(v: Var, sub: String) -> BuiltInCall {
        return .CONTAINS(Expression(.STR(v: v)), Expression(stringLiteral: sub))
    }
    static func regex(v: Var, pattern: String) -> BuiltInCall {
        return .regex(Expression(.STR(v: v)), Expression(stringLiteral: pattern), nil)
    }
    static func STR(v: Var) -> BuiltInCall {
        return .STR(Expression(v))
    }
}

public extension OrderCondition {
    static func asc(v: Var) -> OrderCondition {
        return .asc(Expression(v))
    }
    static func desc(v: Var) -> OrderCondition {
        return .desc(Expression(v))
    }
    static func by(_ v: Var) -> OrderCondition {
        return .var(v)
    }
    static func by(_ c: BuiltInCall) -> OrderCondition {
        return .constraint(.builtInCall(c))
    }
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

extension TripleBuilder {
    public func optional(block: (TripleBuilder<State>) -> TripleBuilder<State>) -> TripleBuilder<State> {
        let optionalTriples = block(.init(subject: subject, triples: [])).triples
        return .init(subject: subject, triples: triples + [.notTriple( .OptionalGraphPattern(.groupGraphPatternSub(.init(patterns: optionalTriples))))])
    }

    private func verbPathAlternatives(_ triples: [GroupGraphPatternSubType]) -> PropertyListPathNotEmpty.Verb {
        return triples.compactMap {
            switch $0 {
            case .triple(_, let lv, _): return lv
            default: fatalError("not yet implemented")
            }
        }.reduce(.path([]), |)
    }

    public func alternative(_ block: (TripleBuilder<State>) -> [(RDFLiteral) -> TripleBuilder<State>], is v: RDFLiteral) -> TripleBuilder<State> {
        let alternatives = block(.init(subject: subject, triples: []))
        let pathAlternative = verbPathAlternatives(Array(alternatives.map {$0(v).triples}.joined()))
        return .init(subject: self.subject, triples: self.triples + [.triple(.var(self.subject), pathAlternative, [.literal(v)])])
    }

    public func alternative(_ block: (TripleBuilder<State>) -> [(Var) -> TripleBuilder<State>], is v: Var) -> TripleBuilder<State> {
        let alternatives = block(.init(subject: subject, triples: []))
        let pathAlternative = verbPathAlternatives(Array(alternatives.map {$0(v).triples}.joined()))
        return .init(subject: self.subject, triples: self.triples + [.triple(.var(self.subject), pathAlternative, [.var(v)])])
    }

    // NOTE: filter does not use the subject and thus this may not be right place. (actually independent to TripleBuilder)
    public func filter(_ c: BuiltInCall) -> TripleBuilder<State> {
        return .init(subject: subject, triples: triples + [.filter(c)])
    }

    public func filter(_ c: Constraint) -> TripleBuilder<State> {
        return .init(subject: subject, triples: triples + [.filter(c)])
    }
}


public func | (lhs: PropertyListPathNotEmpty.Verb, rhs: PropertyListPathNotEmpty.Verb) -> PropertyListPathNotEmpty.Verb {
    switch (lhs, rhs) {
    case (.path(let l), .path(let r)): return .path(l | r)
    default: fatalError("not yet implemented")
    }
}

// MARK: - imas:Idol

public enum BiboSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/ontology/bibo/")}
}

public enum CalSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2002/12/cal/icaltzd#")}
}

public enum CcSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://creativecommons.org/ns#")}
}

public enum DcSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/dc/elements/1.1/")}
}

public enum DctSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/dc/terms/")}
}

public enum DctermsSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/dc/terms/")}
}

public enum FoafSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://xmlns.com/foaf/0.1/")}
}

public enum GeoSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2003/01/geo/wgs84_pos#")}
}

public enum GeorssSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.georss.org/georss")}
}

public enum GrSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/goodrelations/v1#")}
}

public enum IcSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://imi.ipa.go.jp/ns/core/rdf#")}
}

public enum JrrkSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/jrrk#")}
}

public enum OwlSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2002/07/owl#")}
}

public enum PcSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/procurement/public-contracts#")}
}

public enum QbSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/linked-data/cube#")}
}

public enum RdfSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")}
}

public enum RdfsSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2000/01/rdf-schema#")}
}

public enum SacSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://statdb.nstac.go.jp/lod/sac/C")}
}

public enum SacsSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://statdb.nstac.go.jp/lod/terms/sacs#")}
}

public enum SchemaSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://schema.org/")}
}

public enum SdmxConceptSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/linked-data/sdmx/2009/concept#")}
}

public enum SdmxDimensionSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/linked-data/sdmx/2009/dimension#")}
}

public enum SdmxMeasureSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/linked-data/sdmx/2009/measure#")}
}

public enum SkosSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2004/02/skos/core#")}
}

public enum XsdSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2001/XMLSchema#")}
}

public enum RegSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://purl.org/metainfo/terms/registry#")}
}

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

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == ImasIdol {
    ///
    func schemaOwns(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("owns"), value: [.literal(v)])
    }

    ///
    func schemaOwns(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("owns"), value: [.var(v)])
    }

    ///
    func schemaMemberOf(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("memberOf"), value: [.literal(v)])
    }

    ///
    func schemaMemberOf(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("memberOf"), value: [.var(v)])
    }

    ///
    func schemaFamilyName(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("familyName"), value: [.literal(v)])
    }

    ///
    func schemaFamilyName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("familyName"), value: [.var(v)])
    }

    /// 所属コンテンツ: 所属コンテンツを表すプロパティ
    func imasTitle(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Title"), value: [.literal(v)])
    }

    /// 所属コンテンツ: 所属コンテンツを表すプロパティ
    func imasTitle(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Title"), value: [.var(v)])
    }

    /// 姓よみがな: 姓のよみがなを表すプロパティ
    func imasFamilyNameKana(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("familyNameKana"), value: [.literal(v)])
    }

    /// 姓よみがな: 姓のよみがなを表すプロパティ
    func imasFamilyNameKana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("familyNameKana"), value: [.var(v)])
    }

    /// タイプ: タイプ(Cu,Co,Pa)を表すプロパティ
    func imasType(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Type"), value: [.literal(v)])
    }

    /// タイプ: タイプ(Cu,Co,Pa)を表すプロパティ
    func imasType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Type"), value: [.var(v)])
    }

    /// 趣味: 趣味を表すプロパティ
    func imasHobby(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Hobby"), value: [.literal(v)])
    }

    /// 趣味: 趣味を表すプロパティ
    func imasHobby(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Hobby"), value: [.var(v)])
    }

    /// 担当声優: 担当声優を表すプロパティ
    func imasCv(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("cv"), value: [.literal(v)])
    }

    /// 担当声優: 担当声優を表すプロパティ
    func imasCv(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("cv"), value: [.var(v)])
    }

    /// 胸囲: 胸囲を表すプロパティ
    func imasBust(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Bust"), value: [.literal(v)])
    }

    /// 胸囲: 胸囲を表すプロパティ
    func imasBust(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Bust"), value: [.var(v)])
    }

    /// 臀囲: 臀囲(尻囲)を表すプロパティ
    func imasHip(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Hip"), value: [.literal(v)])
    }

    /// 臀囲: 臀囲(尻囲)を表すプロパティ
    func imasHip(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Hip"), value: [.var(v)])
    }

    ///
    func schemaBirthDate(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("birthDate"), value: [.literal(v)])
    }

    ///
    func schemaBirthDate(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("birthDate"), value: [.var(v)])
    }

    ///
    func schemaHeight(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("height"), value: [.literal(v)])
    }

    ///
    func schemaHeight(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("height"), value: [.var(v)])
    }

    ///
    func foafAge(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: FoafSchema.verb("age"), value: [.literal(v)])
    }

    ///
    func foafAge(is v: Var) -> TripleBuilder<State> {
        return appended(verb: FoafSchema.verb("age"), value: [.var(v)])
    }

    /// イメージカラー: イメージカラーを表すプロパティ
    func imasColor(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Color"), value: [.literal(v)])
    }

    /// イメージカラー: イメージカラーを表すプロパティ
    func imasColor(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Color"), value: [.var(v)])
    }

    /// 血液型: 血液型を表すプロパティ
    func imasBloodType(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("BloodType"), value: [.literal(v)])
    }

    /// 血液型: 血液型を表すプロパティ
    func imasBloodType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("BloodType"), value: [.var(v)])
    }

    /// 腹囲: 腹囲を表すプロパティ
    func imasWaist(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Waist"), value: [.literal(v)])
    }

    /// 腹囲: 腹囲を表すプロパティ
    func imasWaist(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Waist"), value: [.var(v)])
    }

    /// 聞き手: 聞き手を表すプロパティ
    func imasHandedness(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Handedness"), value: [.literal(v)])
    }

    /// 聞き手: 聞き手を表すプロパティ
    func imasHandedness(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Handedness"), value: [.var(v)])
    }

    ///
    func schemaBirthPlace(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("birthPlace"), value: [.literal(v)])
    }

    ///
    func schemaBirthPlace(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("birthPlace"), value: [.var(v)])
    }

    ///
    func schemaGivenName(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("givenName"), value: [.literal(v)])
    }

    ///
    func schemaGivenName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("givenName"), value: [.var(v)])
    }

    /// 星座: 星座を表すプロパティ
    func imasConstellation(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Constellation"), value: [.literal(v)])
    }

    /// 星座: 星座を表すプロパティ
    func imasConstellation(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Constellation"), value: [.var(v)])
    }

    ///
    func rdfType(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.literal(v)])
    }

    ///
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }

    ///
    func schemaWeight(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("weight"), value: [.literal(v)])
    }

    ///
    func schemaWeight(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("weight"), value: [.var(v)])
    }

    /// 名前よみがな: 名前のよみがなを表すプロパティ
    func imasNameKana(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("nameKana"), value: [.literal(v)])
    }

    /// 名前よみがな: 名前のよみがなを表すプロパティ
    func imasNameKana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("nameKana"), value: [.var(v)])
    }

    ///
    func schemaName(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("name"), value: [.literal(v)])
    }

    ///
    func schemaName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("name"), value: [.var(v)])
    }

    ///
    func schemaGender(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("gender"), value: [.literal(v)])
    }

    ///
    func schemaGender(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("gender"), value: [.var(v)])
    }

    /// 名よみがな: 名のよみがなを表すプロパティ
    func imasGivenNameKana(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("givenNameKana"), value: [.literal(v)])
    }

    /// 名よみがな: 名のよみがなを表すプロパティ
    func imasGivenNameKana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("givenNameKana"), value: [.var(v)])
    }

    /// 属性: 属性(Vo,Da,Vi)を表すプロパティ
    func imasAttribute(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Attribute"), value: [.literal(v)])
    }

    /// 属性: 属性(Vo,Da,Vi)を表すプロパティ
    func imasAttribute(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Attribute"), value: [.var(v)])
    }

    /// 特技: 特技を表すプロパティ
    func imasTalent(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Talent"), value: [.literal(v)])
    }

    /// 特技: 特技を表すプロパティ
    func imasTalent(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Talent"), value: [.var(v)])
    }

    /// 好きなもの: 好きなものを表すプロパティ
    func imasFavorite(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Favorite"), value: [.literal(v)])
    }

    /// 好きなもの: 好きなものを表すプロパティ
    func imasFavorite(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Favorite"), value: [.var(v)])
    }

    /// 区分: 区分(Princess・Fairy・Angel)を表すプロパティ
    func imasDivision(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Division"), value: [.literal(v)])
    }

    /// 区分: 区分(Princess・Fairy・Angel)を表すプロパティ
    func imasDivision(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Division"), value: [.var(v)])
    }

    ///
    func schemaDescription(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("description"), value: [.literal(v)])
    }

    ///
    func schemaDescription(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("description"), value: [.var(v)])
    }

    /// カテゴリ: カテゴリ(メンタル・フィジカル・インテリ)を表すプロパティ
    func imasCategory(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Category"), value: [.literal(v)])
    }

    /// カテゴリ: カテゴリ(メンタル・フィジカル・インテリ)を表すプロパティ
    func imasCategory(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("Category"), value: [.var(v)])
    }

    /// 靴のサイズ: 靴のサイズを表すプロパティ
    func imasShoeSize(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("ShoeSize"), value: [.literal(v)])
    }

    /// 靴のサイズ: 靴のサイズを表すプロパティ
    func imasShoeSize(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("ShoeSize"), value: [.var(v)])
    }

    /// 通称よみがな: 通称のよみがなを表すプロパティ
    func imasAlternateNameKana(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("alternateNameKana"), value: [.literal(v)])
    }

    /// 通称よみがな: 通称のよみがなを表すプロパティ
    func imasAlternateNameKana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: ImasSchema.verb("alternateNameKana"), value: [.var(v)])
    }

    ///
    func schemaAlternateName(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("alternateName"), value: [.literal(v)])
    }

    ///
    func schemaAlternateName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaSchema.verb("alternateName"), value: [.var(v)])
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

    /// member: A member of an Organization or a ProgramMembership. Organizations can be members of organizations; ProgramMembership is typically for individuals.
    func schemaMember(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaOrg.verb("member"), value: [.var(v)])
    }

    func schemaName(is v: RDFLiteral) -> TripleBuilder<State> {
        return appended(verb: SchemaOrg.verb("name"), value: [.literal(v)])
    }

    func schemaName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: SchemaOrg.verb("name"), value: [.var(v)])
    }
}

// MARK: - schema.org

public enum SchemaOrg: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://schema.org/")}
}
