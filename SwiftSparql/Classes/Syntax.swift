// https://www.w3.org/TR/sparql11-query/#grammar

typealias QueryUnit = Query

public struct Query {
    public var prologues: [Prologue]
    public var query: Query
    public enum Query {
        case select(SelectQuery)
        case construct(ConstructQuery)
        case describe(DescribeQuery)
        case ask(AskQuery)
    }
    public var valuesClause: ValuesClause

    // public memberwise init
    public init(
        prologues: [Prologue],
        query: Query,
        valuesClause: ValuesClause) {
        self.prologues = prologues
        self.query = query
        self.valuesClause = valuesClause
    }
}

public enum Prologue {
    case base(IRIRef) // BaseDecl      ::=      'BASE' IRIREF
    case prefix(PNameNS, IRIRef) // PrefixDecl      ::=      'PREFIX' PNAME_NS IRIREF
}

/// IRIREF      ::=      '<' ([^<>"{}|^`\]-[#x00-#x20])* '>'
public struct IRIRef {
    public var value: String

    // public memberwise init
    public init(value: String) { self.value = value }
}

/// PNAME_NS      ::=      PN_PREFIX? ':'
/// PN_PREFIX      ::=      PN_CHARS_BASE ((PN_CHARS|'.')* PN_CHARS)?
/// PN_CHARS_BASE      ::=      [A-Z] | [a-z] | [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF] | [#x0370-#x037D] | [#x037F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
/// PN_CHARS      ::=      PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
/// PN_CHARS_U      ::=      PN_CHARS_BASE | '_'
public struct PNameNS {
    public var value: String?

    // public memberwise init
    public init(value: String?) { self.value = value}
}

/// SelectQuery      ::=      SelectClause DatasetClause* WhereClause SolutionModifier
public struct SelectQuery {
    public var selectClause: SelectClause
    public var datasetClause: [DatasetClause]
    public var whereClause: WhereClause
    public var solutionModifier: SolutionModifier

    // public memberwise init
    public init(
        selectClause: SelectClause,
        datasetClause: [DatasetClause],
        whereClause: WhereClause,
        solutionModifier: SolutionModifier) {
        self.selectClause = selectClause
        self.datasetClause = datasetClause
        self.whereClause = whereClause
        self.solutionModifier = solutionModifier
    }
}

/// DatasetClause      ::=      'FROM' ( DefaultGraphClause | NamedGraphClause )
public enum DatasetClause {
    case `default`(DefaultGraphClause)
    case named(NamedGraphClause)
}

/// DefaultGraphClause      ::=      SourceSelector
/// NamedGraphClause      ::=      'NAMED' SourceSelector
/// SourceSelector      ::=      iri
public typealias DefaultGraphClause = SourceSelector
public typealias NamedGraphClause = SourceSelector
public typealias SourceSelector = IRI

/// SubSelect      ::=      SelectClause WhereClause SolutionModifier ValuesClause
public struct SubSelect {
    public var selectClause: SelectClause
    public var whereClause: WhereClause
    public var solutionModifier: SolutionModifier
    public var valuesClause: ValuesClause

    // public memberwise init
    public init(
        selectClause: SelectClause,
        whereClause: WhereClause,
        solutionModifier: SolutionModifier,
        valuesClause: ValuesClause) {
        self.selectClause = selectClause
        self.whereClause = whereClause
        self.solutionModifier = solutionModifier
        self.valuesClause = valuesClause
    }
}

/// SelectClause      ::=      'SELECT' ( 'DISTINCT' | 'REDUCED' )? ( ( Var | ( '(' Expression 'AS' Var ')' ) )+ | '*' )
public struct SelectClause {
    public var option: Option?
    public enum Option {
        case distinct
        case reduced
    }

    public var capture: Capture
    public enum Capture {
        /// ( Var | ( '(' Expression 'AS' Var ')' ) )+
        case expressions([(Var, Expression?)])
        /// '*'
        case all
    }

    // public memberwise init
    public init(option: Option?, capture: Capture) {
        self.option = option
        self.capture = capture
    }
}

/// Expression      ::=      ConditionalOrExpression
/// ConditionalOrExpression      ::=      ConditionalAndExpression ( '||' ConditionalAndExpression )*
/// ConditionalAndExpression      ::=      ValueLogical ( '&&' ValueLogical )*
/// ValueLogical      ::=      RelationalExpression
/// RelationalExpression      ::=      NumericExpression ( '=' NumericExpression | '!=' NumericExpression | '<' NumericExpression | '>' NumericExpression | '<=' NumericExpression | '>=' NumericExpression | 'IN' ExpressionList | 'NOT' 'IN' ExpressionList )?
/// NumericExpression      ::=      AdditiveExpression
/// AdditiveExpression      ::=      MultiplicativeExpression ( '+' MultiplicativeExpression | '-' MultiplicativeExpression | ( NumericLiteralPositive | NumericLiteralNegative ) ( ( '*' UnaryExpression ) | ( '/' UnaryExpression ) )* )*
/// MultiplicativeExpression      ::=      UnaryExpression ( '*' UnaryExpression | '/' UnaryExpression )*
/// UnaryExpression      ::=        '!' PrimaryExpression |    '+' PrimaryExpression |    '-' PrimaryExpression |    PrimaryExpression
/// PrimaryExpression      ::=      BrackettedExpression | BuiltInCall | iriOrFunction | RDFLiteral | NumericLiteral | BooleanLiteral | Var
/// BrackettedExpression      ::=      '(' Expression ')'
/// ExpressionList      ::=      NIL | '(' Expression ( ',' Expression )* ')'
public typealias Expression = ConditionalOrExpression

public struct ConditionalOrExpression {
    public var ands: [ConditionalAndExpression]
}

public struct ConditionalAndExpression {
    public var valueLogicals: [ValueLogical]
}

public enum ValueLogical {
    case numeric(NumericExpression)
    case eq(NumericExpression, NumericExpression)
    case neq(NumericExpression, NumericExpression)
    case lt(NumericExpression, NumericExpression)
    case gt(NumericExpression, NumericExpression)
    case lte(NumericExpression, NumericExpression)
    case gte(NumericExpression, NumericExpression)
    case `in`(NumericExpression, [Expression])
    case notin(NumericExpression, [Expression])
}

/// NumericExpression      ::=      AdditiveExpression
/// AdditiveExpression      ::=      MultiplicativeExpression ( '+' MultiplicativeExpression | '-' MultiplicativeExpression | ( NumericLiteralPositive | NumericLiteralNegative ) ( ( '*' UnaryExpression ) | ( '/' UnaryExpression ) )* )*
/// MultiplicativeExpression      ::=      UnaryExpression ( '*' UnaryExpression | '/' UnaryExpression )*
/// UnaryExpression      ::=        '!' PrimaryExpression |    '+' PrimaryExpression |    '-' PrimaryExpression |    PrimaryExpression
/// PrimaryExpression      ::=      BrackettedExpression | BuiltInCall | iriOrFunction | RDFLiteral | NumericLiteral | BooleanLiteral | Var
public typealias NumericExpression = AdditiveExpression
public enum AdditiveExpression {
    case single(MultiplicativeExpression)
    case plus(MultiplicativeExpression, MultiplicativeExpression)
    case minus(MultiplicativeExpression, MultiplicativeExpression)
    case multiple(MultiplicativeExpression, NumericLiteral, [Multiplier])
    public enum Multiplier {
        case multiple(UnaryExpression)
        case divide(UnaryExpression)
    }
}
public typealias MultiplicativeExpression = (UnaryExpression, [AdditiveExpression.Multiplier])
public enum UnaryExpression {
    case negate(PrimaryExpression)
    case plus(PrimaryExpression)
    case minus(PrimaryExpression)
    case simple(PrimaryExpression)
}

public enum PrimaryExpression {
    case brackettedExpression(Expression)
    case builtInCall(BuiltInCall)
    case iriOrFunction(IRIOrFunction)
    case rdfLiteral(RDFLiteral)
    case numericLiteral(NumericLiteral)
    case booleanLiteral(Bool)
    case `var`(Var)
}

/// NumericLiteral      ::=      NumericLiteralUnsigned | NumericLiteralPositive | NumericLiteralNegative
/// NumericLiteralUnsigned      ::=      INTEGER |    DECIMAL |    DOUBLE
/// NumericLiteralPositive      ::=      INTEGER_POSITIVE |    DECIMAL_POSITIVE |    DOUBLE_POSITIVE
/// NumericLiteralNegative      ::=      INTEGER_NEGATIVE |    DECIMAL_NEGATIVE |    DOUBLE_NEGATIVE
public enum NumericLiteral {
    case integer(Int)
    case decimal(Int)
    case double(Double)
}

/// iriOrFunction      ::=      iri ArgList?
public struct IRIOrFunction {
    public var iri: IRI
    public var argList: ArgList?
}

/// iri      ::=      IRIREF |    PrefixedName
public enum IRI {
    case ref(IRIRef)
    case prefixedName(PrefixedName)
}

/// ArgList      ::=      NIL | '(' 'DISTINCT'? Expression ( ',' Expression )* ')'
public struct ArgList {
    public var distinct: Bool
    public var expressions: [Expression]
}

/// PrefixedName      ::=      PNAME_LN | PNAME_NS
public enum PrefixedName {
    case ln(PNameLN)
    case ns(PNameNS)
}

/// PNAME_LN      ::=      PNAME_NS PN_LOCAL
/// PN_LOCAL      ::=      (PN_CHARS_U | ':' | [0-9] | PLX ) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX) )?
public typealias PNameLN = (PNameNS, String)

/// RDFLiteral      ::=      String ( LANGTAG | ( '^^' iri ) )?
public struct RDFLiteral {
    public var string: String
}

/// Var      ::=      VAR1 | VAR2
/// VAR1      ::=      '?' VARNAME
/// VAR2      ::=      '$' VARNAME
/// VARNAME      ::=      ( PN_CHARS_U | [0-9] ) ( PN_CHARS_U | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040] )*
public typealias Var = String

/// WhereClause      ::=      'WHERE'? GroupGraphPattern
public struct WhereClause {
    public var pattern: GroupGraphPattern

    // public memberwise init
    public init(pattern: GroupGraphPattern) { self.pattern = pattern }
}

/// SolutionModifier      ::=      GroupClause? HavingClause? OrderClause? LimitOffsetClauses?
public struct SolutionModifier {
    public var group: GroupClause?
    public var having: HavingClause?
    public var order: OrderClause?
    public var limit: LimitOffsetClauses?

    // public memberwise init
    public init(
        group: GroupClause?,
        having: HavingClause?,
        order: OrderClause?,
        limit: LimitOffsetClauses?) {
        self.group = group
        self.having = having
        self.order = order
        self.limit = limit
    }
}

/// GroupClause      ::=      'GROUP' 'BY' GroupCondition+
public typealias GroupClause = [GroupCondition]
/// GroupCondition      ::=      BuiltInCall | FunctionCall | '(' Expression ( 'AS' Var )? ')' | Var
public enum GroupCondition {
    case builtInCall(BuiltInCall)
    case functionCall(FunctionCall)
    case expression(Expression, Var?)
    case `var`(Var)
}

/// HavingClause      ::=      'HAVING' HavingCondition+
/// HavingCondition      ::=      Constraint
/// Constraint      ::=      BrackettedExpression | BuiltInCall | FunctionCall
public typealias HavingClause = [HavingCondition]
public typealias HavingCondition = Constraint
public enum Constraint {
    case brackettedExpression(Expression)
    case builtInCall(BuiltInCall)
    case functionCall(FunctionCall)
}

/// OrderClause      ::=      'ORDER' 'BY' OrderCondition+
/// OrderCondition      ::=      ( ( 'ASC' | 'DESC' ) BrackettedExpression ) | ( Constraint | Var )
public typealias OrderClause = [OrderCondition]
public enum OrderCondition {
    case asc(Expression)
    case desc(Expression)
    case constraint(Constraint)
    case `var`(Var)
}

/// LimitOffsetClauses      ::=      LimitClause OffsetClause? | OffsetClause LimitClause?
/// LimitClause      ::=      'LIMIT' INTEGER
/// OffsetClause      ::=      'OFFSET' INTEGER
public enum LimitOffsetClauses {
    case limit(Int, offset: Int?)
    case offset(Int, limit: Int?)
    public static func limit(_ limit: Int) -> LimitOffsetClauses { return .limit(limit, offset: nil) }
}

/// ConstructQuery      ::=      'CONSTRUCT' ( ConstructTemplate DatasetClause* WhereClause SolutionModifier | DatasetClause* 'WHERE' '{' TriplesTemplate? '}' SolutionModifier )
public struct ConstructQuery {
    // TODO: pending
}

/// DescribeQuery      ::=      'DESCRIBE' ( VarOrIri+ | '*' ) DatasetClause* WhereClause? SolutionModifier
public struct DescribeQuery {
    // TODO: pending
}

/// AskQuery      ::=      'ASK' DatasetClause* WhereClause SolutionModifier
public struct AskQuery {
    // TODO: pending
}

public struct ValuesClause {
    // TODO: pending

    // public memberwise init
    public init() {}
}


public enum BuiltInCall {
    // case aggregate(Aggregate)
    /// Aggregate      ::=        'COUNT' '(' 'DISTINCT'? ( '*' | Expression ) ')'
    /// | 'SUM' '(' 'DISTINCT'? Expression ')'
    /// | 'MIN' '(' 'DISTINCT'? Expression ')'
    /// | 'MAX' '(' 'DISTINCT'? Expression ')'
    /// | 'AVG' '(' 'DISTINCT'? Expression ')'
    /// | 'SAMPLE' '(' 'DISTINCT'? Expression ')'
    /// | 'GROUP_CONCAT' '(' 'DISTINCT'? Expression ( ';' 'SEPARATOR' '=' String )? ')'
    case count(distinct: Bool, expression: Expression?) // NOTE: count(*) is represented by count(distinct: false, expression: nil)
    case sum(distinct: Bool, expression: Expression)
    case min(distinct: Bool, expression: Expression)
    case max(distinct: Bool, expression: Expression)
    case average(distinct: Bool, expression: Expression)
    case sample(distinct: Bool, expression: Expression)
    case groupConcat(distinct: Bool, expression: Expression, separator: String?)
    case STR(Expression)
    case LANG(Expression)
    case LANGMATCHES(Expression, Expression)
    case DATATYPE(Expression)
    case BOUND(Var)
    case IRI(Expression)
    case URI(Expression)
    case BNODE(Expression?)
    case RAND
    case ABS(Expression)
    case CEIL(Expression)
    case FLOOR(Expression)
    case ROUND(Expression)
    case CONCAT([Expression])
    case substr(Expression, Expression, Expression?)
    case STRLEN(Expression)
    case replace(Expression, Expression, Expression, Expression?)
    case UCASE(Expression)
    case LCASE(Expression)
    case ENCODE_FOR_URI(Expression)
    case CONTAINS(Expression, Expression)
    case STRSTARTS(Expression, Expression)
    case STRENDS(Expression, Expression)
    case STRBEFORE(Expression, Expression)
    case STRAFTER(Expression, Expression)
    case YEAR(Expression)
    case MONTH(Expression)
    case DAY(Expression)
    case HOURS(Expression)
    case MINUTES(Expression)
    case SECONDS(Expression)
    case TIMEZONE(Expression)
    case TZ(Expression)
    case NOW
    case UUID
    case STRUUID
    case MD5(Expression)
    case SHA1(Expression)
    case SHA256(Expression)
    case SHA384(Expression)
    case SHA512(Expression)
    case COALESCE([Expression])
    case IF(Expression, Expression, Expression)
    case STRLANG(Expression, Expression)
    case STRDT(Expression, Expression)
    case sameTerm(Expression, Expression)
    case isIRI(Expression)
    case isURI(Expression)
    case isBLANK(Expression)
    case isLITERAL(Expression)
    case isNUMERIC(Expression)
    case regex(Expression, Expression, Expression?)
    case exists(GroupGraphPattern)
    case notExists(GroupGraphPattern)
}

/// FunctionCall      ::=      iri ArgList
public struct FunctionCall {
    public var iri: IRI
    public var argList: ArgList
}

/// GroupGraphPattern      ::=      '{' ( SubSelect | GroupGraphPatternSub ) '}'
public indirect enum GroupGraphPattern {
    case subSelect(SubSelect)
    case groupGraphPatternSub(GroupGraphPatternSub)
}

/// GroupGraphPatternSub      ::=      TriplesBlock? ( GraphPatternNotTriples '.'? TriplesBlock? )*
/// TriplesBlock      ::=      TriplesSameSubjectPath ( '.' TriplesBlock? )?
/// TriplesSameSubjectPath      ::=      VarOrTerm PropertyListPathNotEmpty |    TriplesNodePath PropertyListPath
/// VarOrTerm      ::=      Var | GraphTerm
/// GraphTerm      ::=      iri |    RDFLiteral |    NumericLiteral |    BooleanLiteral |    BlankNode |    NIL
public struct GroupGraphPatternSub {
    public var first: TriplesBlock?
    public var successors: [(GraphPatternNotTriples, TriplesBlock?)]

    // public memberwise init
    public init(
        first: TriplesBlock?,
        successors: [(GraphPatternNotTriples, TriplesBlock?)]) {
        self.first = first
        self.successors = successors
    }
}

/// workaround for recursive-structure
public class Indirect<V> {
    public var value: V
    public init(_ value: V) {
        self.value = value
    }
}

public struct TriplesBlock {
    public var triplesSameSubjectPath: TriplesSameSubjectPath
    public var triplesBlock: Indirect<TriplesBlock?>
}

public enum TriplesSameSubjectPath {
    case varOrTerm(VarOrTerm, PropertyListPathNotEmpty)
    case triplesNodePath(TriplesNodePath, PropertyListPath)
}

/// GraphPatternNotTriples      ::=      GroupOrUnionGraphPattern | OptionalGraphPattern | MinusGraphPattern | GraphGraphPattern | ServiceGraphPattern | Filter | Bind | InlineData
/// GroupOrUnionGraphPattern      ::=      GroupGraphPattern ( 'UNION' GroupGraphPattern )*
/// OptionalGraphPattern      ::=      'OPTIONAL' GroupGraphPattern
/// MinusGraphPattern      ::=      'MINUS' GroupGraphPattern
/// GraphGraphPattern      ::=      'GRAPH' VarOrIri GroupGraphPattern
/// ServiceGraphPattern      ::=      'SERVICE' 'SILENT'? VarOrIri GroupGraphPattern
/// Filter      ::=      'FILTER' Constraint
/// Bind      ::=      'BIND' '(' Expression 'AS' Var ')'
/// InlineData      ::=      'VALUES' DataBlock
public enum GraphPatternNotTriples {
    case GroupOrUnionGraphPattern([GroupGraphPattern])
    case OptionalGraphPattern(GroupGraphPattern)
    case MinusGraphPattern(GroupGraphPattern)
    case GraphGraphPattern(VarOrIRI, GroupGraphPattern)
    case ServiceGraphPattern(silent: Bool, VarOrIRI, GroupGraphPattern)
    case Filter(Constraint)
    case Bind(Expression, Var)
    case InlineData(DataBlock)
}

/// VarOrTerm      ::=      Var | GraphTerm
public enum VarOrTerm {
    case `var`(Var)
    case term(GraphTerm)
}

/// VarOrIri      ::=      Var | iri
public enum VarOrIRI {
    case `var`(Var)
    case iri(IRI)
}

/// DataBlock      ::=      InlineDataOneVar | InlineDataFull
/// InlineDataOneVar      ::=      Var '{' DataBlockValue* '}'
/// DataBlockValue      ::=      iri |    RDFLiteral |    NumericLiteral |    BooleanLiteral |    'UNDEF'
/// InlineDataFull      ::=      ( NIL | '(' Var* ')' ) '{' ( '(' DataBlockValue* ')' | NIL )* '}'
public enum DataBlock {
    case one(InlineDataOneVar)
    case full(InlineDataFull)
}
public struct InlineDataOneVar {
    public var `var`: Var
    public var dataBlockValue: [DataBlockValue]
}
public enum DataBlockValue {
    case iri(IRI)
    case rdf(RDFLiteral)
    case numeric(NumericLiteral)
    case boolean(Bool)
    case undef
}

public struct InlineDataFull {
    public var vars: [Var]
    public var values: [DataBlockValue]
}


/// GraphTerm      ::=      iri |    RDFLiteral |    NumericLiteral |    BooleanLiteral |    BlankNode |    NIL
/// BlankNode      ::=      BLANK_NODE_LABEL |    ANON
/// BLANK_NODE_LABEL      ::=      '_:' ( PN_CHARS_U | [0-9] ) ((PN_CHARS|'.')* PN_CHARS)?
/// ANON      ::=      '[' WS* ']'
/// WS      ::=      #x20 | #x9 | #xD | #xA
public enum GraphTerm {
    case iri(IRI)
    case rdf(RDFLiteral)
    case numeric(NumericLiteral)
    case boolean(Bool)
    case blank(BlankNode)
    case `nil`
}
public enum BlankNode {
    case label(String)
    case anon
}

/// PropertyListPath      ::=      PropertyListPathNotEmpty?
/// PropertyListPathNotEmpty      ::=      ( VerbPath | VerbSimple ) ObjectListPath ( ';' ( ( VerbPath | VerbSimple ) ObjectList )? )*
public typealias PropertyListPath = PropertyListPathNotEmpty?
public struct PropertyListPathNotEmpty {
    public var verb: Verb
    public enum Verb {
        case path(VerbPath)
        case simple(VerbSimple)
    }

    public var objectListPath: ObjectListPath
    public var successors: [(Verb, ObjectList)]

    // public memberwise init
    public init(
        verb: Verb,
        objectListPath: ObjectListPath,
        successors: [(Verb, ObjectList)]) {
        self.verb = verb
        self.objectListPath = objectListPath
        self.successors = successors
    }
}

/// VerbPath      ::=      Path
/// VerbSimple      ::=      Var
/// ObjectListPath      ::=      ObjectPath ( ',' ObjectPath )*
/// ObjectPath      ::=      GraphNodePath
/// Path      ::=      PathAlternative
/// PathAlternative      ::=      PathSequence ( '|' PathSequence )*
/// PathSequence      ::=      PathEltOrInverse ( '/' PathEltOrInverse )*
/// PathElt      ::=      PathPrimary PathMod?
/// PathEltOrInverse      ::=      PathElt | '^' PathElt
public typealias VerbPath = Path
public typealias VerbSimple = Var
public typealias ObjectListPath = [ObjectPath]
public typealias ObjectPath = GraphNodePath
public typealias Path = PathAlternative
public typealias PathAlternative = [PathSequence]
public typealias PathSequence = [PathEltOrInverse]

public struct PathElt {
    public var primary: PathPrimary
    public var mod: PathMod?

    // public memberwise init
    public init(primary: PathPrimary, mod: PathMod?) {
        self.primary = primary
        self.mod = mod
    }
}

public enum PathEltOrInverse {
    case elt(PathElt)
    case hat_elt(PathElt)
}

/// PathPrimary      ::=      iri | 'a' | '!' PathNegatedPropertySet | '(' Path ')'
public enum PathPrimary {
    case iri(IRI)
    case a
    case pathNegatedPropertySet(PathNegatedPropertySet)
    case path(Path)
}

/// PathNegatedPropertySet      ::=      PathOneInPropertySet | '(' ( PathOneInPropertySet ( '|' PathOneInPropertySet )* )? ')'
/// PathOneInPropertySet      ::=      iri | 'a' | '^' ( iri | 'a' )
public typealias PathNegatedPropertySet = [PathOneInPropertySet]
public enum PathOneInPropertySet {
    case iri(IRI)
    case a
    case hat_iri(IRI)
    case hat_a
}

/// PathMod      ::=      '?' | '*' | '+'
public enum PathMod: String {
    case question = "?"
    case asterisk = "*"
    case plus = "+"
}

/// TriplesNodePath      ::=      CollectionPath |    BlankNodePropertyListPath
/// CollectionPath      ::=      '(' GraphNodePath+ ')'
/// BlankNodePropertyListPath      ::=      '[' PropertyListPathNotEmpty ']'
public enum TriplesNodePath {
    case collection(CollectionPath)
    case blank(BlankNodePropertyListPath)
}
public struct CollectionPath {
    public var paths: [GraphNodePath]
}
public typealias BlankNodePropertyListPath = PropertyListPathNotEmpty

/// GraphNode      ::=      VarOrTerm |    TriplesNode
/// GraphNodePath      ::=      VarOrTerm |    TriplesNodePath
public enum GraphNode {
    case varOrTerm(VarOrTerm)
    case triplesNode(TriplesNode)
}
public enum GraphNodePath {
    case varOrTerm(VarOrTerm)
    case triplesNodePath(TriplesNodePath)
}
/// TriplesNode      ::=      Collection |    BlankNodePropertyList
/// Collection      ::=      '(' GraphNode+ ')'
/// BlankNodePropertyList      ::=      '[' PropertyListNotEmpty ']'
public enum TriplesNode {
    case collection(Collection)
    case blankNode(BlankNodePropertyList)
}
public typealias Collection = [GraphNode]
public typealias BlankNodePropertyList = PropertyListNotEmpty

/// PropertyListNotEmpty      ::=      Verb ObjectList ( ';' ( Verb ObjectList )? )*
/// ObjectList      ::=      Object ( ',' Object )*
/// Object      ::=      GraphNode
public struct PropertyListNotEmpty {
    public var list: [(Verb, ObjectList)]
}
public typealias ObjectList = [Object]
public typealias Object = GraphNode

/// Verb      ::=      VarOrIri | 'a'
/// VarOrIri      ::=      Var | iri
public enum Verb {
    case `var`(Var)
    case iri(IRI)
    case a
}
