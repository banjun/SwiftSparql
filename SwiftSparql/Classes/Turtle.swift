import Foundation

public struct TurtleDoc {
    public enum Token: Equatable {
        //終端記号の生成規則
        case IRIREF(String)
        case PNAME_NS(String)
        case PNAME_LN(String)
        case BLANK_NODE_LABEL(String)
        case LANGTAG(String)
        case INTEGER(String)
        case DECIMAL(String)
        case DOUBLE(String)
        case EXPONENT(String)
        case STRING_LITERAL_QUOTE(String)
        case STRING_LITERAL_SINGLE_QUOTE(String)
        case STRING_LITERAL_LONG_SINGLE_QUOTE(String)
        case STRING_LITERAL_LONG_QUOTE(String)
        case UCHAR(String)
        case ECHAR(String)
        case WS(String)
        case ANON(String)
        case PN_CHARS_BASE(String)
        case PN_CHARS_U(String)
        case PN_CHARS(String)
        case PN_PREFIX(String)
        case PN_LOCAL(String)
        case PLX(String)
        case PERCENT(String)
        case HEX(String)
        case PN_LOCAL_ESC(String)
        // not-in Turtle Grammer
        case OTHER(String)
    }

    public var statements: [Statement]

    public enum Statement {
        case directive(Directive)
        case triple(Triple)
    }

    public struct Directive {
        // TODO
    }

    // [6]    triples    ::=    subject predicateObjectList | blankNodePropertyList predicateObjectList?
    public enum Triple {
        case subject(Subject, PredicateObjectList)
        case blank(BlankNodePropertyList, PredicateObjectList?)
    }

    // [7]    predicateObjectList    ::=    verb objectList (';' (verb objectList)?)*
    public struct PredicateObjectList {
        public var head: (Verb, ObjectList)
        public var tail: [(Verb, ObjectList)]
        public var list: [(Verb, ObjectList)] {return [head] + tail}
    }

    // subject    ::=    iri | BlankNode | collection
    public enum Subject {
        case iri(IRI)
        case blank(BlankNode)
        case collection(Collection)
    }

    public enum Verb {
        case iri(IRI)
        case a
    }

    public struct BlankNodePropertyList {
        public var predicateObjectList: PredicateObjectList
    }

    // [8]    objectList    ::=    object (',' object)*
    public struct ObjectList {
        public var head: Object
        public var tail: [Object]
        public var list: [Object] {return [head] + tail}
    }
    // [15]    collection    ::=    '(' object* ')'
    public typealias Collection = [Object]

    // [12]    object    ::=    iri | BlankNode | collection | blankNodePropertyList | literal
    public indirect enum Object {
        case iri(IRI)
        case blankNode(BlankNode)
        case collection(Collection)
        case blankNodePropertyList(BlankNodePropertyList)
        case literal(Literal)
    }

    // [13]    literal    ::=    RDFLiteral | NumericLiteral | BooleanLiteral
    public enum Literal {
        case rdf(RDFLiteral)
        case numeric(NumericLiteral)
        case boolean(Bool)
    }
}

import FootlessParser

extension TurtleDoc.Token {
    public var string: String {
        switch self {
        case .IRIREF(let s): return s
        case .PNAME_NS(let s): return s
        case .PNAME_LN(let s): return s
        case .BLANK_NODE_LABEL(let s): return s
        case .LANGTAG(let s): return s
        case .INTEGER(let s): return s
        case .DECIMAL(let s): return s
        case .DOUBLE(let s): return s
        case .EXPONENT(let s): return s
        case .STRING_LITERAL_QUOTE(let s): return s
        case .STRING_LITERAL_SINGLE_QUOTE(let s): return s
        case .STRING_LITERAL_LONG_SINGLE_QUOTE(let s): return s
        case .STRING_LITERAL_LONG_QUOTE(let s): return s
        case .UCHAR(let s): return s
        case .ECHAR(let s): return s
        case .WS(let s): return s
        case .ANON(let s): return s
        case .PN_CHARS_BASE(let s): return s
        case .PN_CHARS_U(let s): return s
        case .PN_CHARS(let s): return s
        case .PN_PREFIX(let s): return s
        case .PN_LOCAL(let s): return s
        case .PLX(let s): return s
        case .PERCENT(let s): return s
        case .HEX(let s): return s
        case .PN_LOCAL_ESC(let s): return s
        case .OTHER(let s): return s
        }
    }
}

extension TurtleDoc {
    static var parser: Parser<String, TurtleDoc> {
        return self.init <^> oneOrMore(Statement.parser)
    }

    public init(_ docString: String) throws {
        // Look-ahead with same class terminator
        func oneOrMoreTerminated <T,A> (_ repeatedParser: Parser<T,A>, terminationParser: Parser<T, A>) -> Parser<T,[A]> {
            return Parser { input in
                var (first, remainder) = try repeatedParser.parse(input)
                var (firstTermination, terminatedRemainder) = try terminationParser.parse(remainder)
                var result = [first, firstTermination]
                while true {
                    do {
                        let next = try repeatedParser.parse(remainder)
                        let termination = try terminationParser.parse(next.remainder)
                        result.removeLast()
                        result.append(next.output)
                        result.append(termination.output)
                        remainder = next.remainder
                        terminatedRemainder = termination.remainder
                    } catch {
                        return (result, terminatedRemainder)
                    }
                }
            }
        }

        func zeroOrMoreTerminated <T,A> (_ p: Parser<T,A>, terminationParser tp: Parser<T, A>) -> Parser<T,[A]> {
            return optional( oneOrMoreTerminated(p, terminationParser: tp), otherwise: [] )
        }

        // 終端記号の生成規則

        // [171s]    HEX    ::=    [0-9] | [A-F] | [a-f]
        let HEX = char(CharacterSet(charactersIn: "0"..."9").union(CharacterSet(charactersIn: "A"..."F").union(CharacterSet(charactersIn: "a"..."f"))), name: "HEX")

        // [26]    UCHAR    ::=    '\u' HEX HEX HEX HEX | '\U' HEX HEX HEX HEX HEX HEX HEX HEX
        let UCHAR = string("\\u") *> count(4, HEX)
            <|> string("\\U") *> count(8, HEX)

        // [18]    IRIREF    ::=    '<' ([^#x00-#x20<>"{}|^`\] | UCHAR)* '>' /* #x00=NULL #01-#x1F=control codes #x20=space */
        let IRIREF = extend <^> char("<") <*> (extend <^> ({$0.joined()} <^> zeroOrMore(
            String.init <^> char(CharacterSet(charactersIn: "\u{00}"..."\u{20}").union(CharacterSet(charactersIn: ">\"{}|^`\\")).inverted, name: "[^#x00-#x20<>\"{}|^`\\]")
                <|> UCHAR)) <*> (String.init <^> char(">")))

        // [163s]    PN_CHARS_BASE    ::=    [A-Z] | [a-z] | [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF] | [#x0370-#x037D] | [#x037F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
        let PN_CHARS_BASE = char(CharacterSet(charactersIn: "A"..."Z"), name: "[A-Z]")
                <|> char(CharacterSet(charactersIn: "a"..."z"), name: "[a-z]")
                <|> char(CharacterSet(charactersIn: "\u{00C0}"..."\u{00D6}"), name: "[#x00C0-#x00D6]")
                <|> char(CharacterSet(charactersIn: "\u{00D8}"..."\u{00F6}"), name: "[#x00D8-#x00F6]")
                <|> char(CharacterSet(charactersIn: "\u{00F8}"..."\u{02FF}"), name: "[#x00F8-#x02FF]")
                <|> char(CharacterSet(charactersIn: "\u{0370}"..."\u{037D}"), name: "[#x0370-#x037D]")
                <|> char(CharacterSet(charactersIn: "\u{037F}"..."\u{1FFF}"), name: "[#x037F-#x1FFF]")
                <|> char(CharacterSet(charactersIn: "\u{200C}"..."\u{200D}"), name: "[#x200C-#x200D]")
                <|> char(CharacterSet(charactersIn: "\u{2070}"..."\u{218F}"), name: "[#x2070-#x218F]")
                <|> char(CharacterSet(charactersIn: "\u{2C00}"..."\u{2FEF}"), name: "[#x2C00-#x2FEF]")
                <|> char(CharacterSet(charactersIn: "\u{3001}"..."\u{D7FF}"), name: "[#x3001-#xD7FF]")
                <|> char(CharacterSet(charactersIn: "\u{F900}"..."\u{FDCF}"), name: "[#xF900-#xFDCF]")
                <|> char(CharacterSet(charactersIn: "\u{FDF0}"..."\u{FFFD}"), name: "[#xFDF0-#xFFFD]")
                <|> char(CharacterSet(charactersIn: "\u{10000}"..."\u{EFFFF}"), name: "[#x10000-#xEFFFF]")

        // [164s]    PN_CHARS_U    ::=    PN_CHARS_BASE | '_'
        let PN_CHARS_U = PN_CHARS_BASE <|> char("_")

        // [166s]    PN_CHARS    ::=    PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
        let PN_CHARS = PN_CHARS_U
            <|> char("-")
            <|> char(CharacterSet(charactersIn: "0"..."9"), name: "[0-9]")
            <|> char("\u{00B7}")
            <|> char(CharacterSet(charactersIn: "\u{0300}"..."\u{036F}"), name: "[#x0300-#x036F]")
            <|> char(CharacterSet(charactersIn: "\u{203F}"..."\u{2040}"), name: "[#x203F-#x2040]")

        // [167s]    PN_PREFIX    ::=    PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)?
        let PN_PREFIX = extend <^> PN_CHARS_BASE <*> optional({String($0)} <^> zeroOrMoreTerminated(PN_CHARS <|> char("."), terminationParser: PN_CHARS), otherwise: "")

        // [139s]    PNAME_NS    ::=    PN_PREFIX? ':'
        let PNAME_NS = extend <^> optional(PN_PREFIX, otherwise: "") <*> char(":")

        // [170s]    PERCENT    ::=    '%' HEX HEX
        let PERCENT = extend <^> char("%") <*> (extend <^> HEX <*> (String.init <^> HEX))

        // [172s]    PN_LOCAL_ESC    ::=    '\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%')
        let PN_LOCAL_ESC = extend <^> char("\\") <*> (String.init <^> oneOf("_~.-!$&'()*+,;=/?#@%"))

        // [169s]    PLX    ::=    PERCENT | PN_LOCAL_ESC
        let PLX = PERCENT <|> PN_LOCAL_ESC

        // [168s]    PN_LOCAL    ::=    (PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))?
        let PN_LOCAL = extend <^> (String.init <^> PN_CHARS_U
            <|> String.init <^> char(":")
            <|> String.init <^> char(CharacterSet(charactersIn: "0"..."9"), name: "[0-9]")
            <|> PLX)
            <*> optional({$0.joined()} <^> zeroOrMoreTerminated(
                String.init <^> PN_CHARS
                    <|> String.init <^> char(".")
                    <|> String.init <^> char(":")
                    <|> PLX,
                terminationParser: (String.init <^> PN_CHARS
                    <|> String.init <^> char(":")
                    <|> PLX)),
                         otherwise: "")

        // [140s]    PNAME_LN    ::=    PNAME_NS PN_LOCAL
        let PNAME_LN = extend <^> PNAME_NS <*> PN_LOCAL

        // [141s]    BLANK_NODE_LABEL    ::=    '_:' (PN_CHARS_U | [0-9]) ((PN_CHARS | '.')* PN_CHARS)?
        // [144s]    LANGTAG    ::=    '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*
        // [19]    INTEGER    ::=    [+-]? [0-9]+
        // [20]    DECIMAL    ::=    [+-]? [0-9]* '.' [0-9]+
        // [21]    DOUBLE    ::=    [+-]? ([0-9]+ '.' [0-9]* EXPONENT | '.' [0-9]+ EXPONENT | [0-9]+ EXPONENT)
        // [154s]    EXPONENT    ::=    [eE] [+-]? [0-9]+

        // [159s]    ECHAR    ::=    '\' [tbnrf"'\]
        let ECHAR = extend <^> string("\\") <*> oneOf("tbnrf\"'\\")

        // [22]    STRING_LITERAL_QUOTE    ::=    '"' ([^#x22#x5C#xA#xD] | ECHAR | UCHAR)* '"' /* #x22=" #x5C=\ #xA=new line #xD=carriage return */
        let STRING_LITERAL_QUOTE = {$0.joined()} <^> (char("\"") *> zeroOrMore((String.init <^> noneOf("\u{22}\u{5C}\u{A}\u{D}")) <|> ECHAR <|> UCHAR) <* char("\""))

        // [23]    STRING_LITERAL_SINGLE_QUOTE    ::=    "'" ([^#x27#x5C#xA#xD] | ECHAR | UCHAR)* "'" /* #x27=' #x5C=\ #xA=new line #xD=carriage return */
        let STRING_LITERAL_SINGLE_QUOTE = {$0.joined()} <^> (char("'") *> zeroOrMore((String.init <^> noneOf("\u{27}\u{5C}\u{A}\u{D}")) <|> ECHAR <|> UCHAR) <* char("'"))

        // [24]    STRING_LITERAL_LONG_SINGLE_QUOTE    ::=    "'''" (("'" | "''")? ([^'\] | ECHAR | UCHAR))* "'''"
        let STRING_LITERAL_LONG_SINGLE_QUOTE = {$0.joined()} <^> (string("'''")
            *> zeroOrMore(extend
                <^> ({$0 ?? ""} <^> optional(string("'") <|> string("''")))
                <*> ((String.init <^> noneOf("'\\")) <|> ECHAR <|> UCHAR))
            <* string("'''"))

        // [25]    STRING_LITERAL_LONG_QUOTE    ::=    '"""' (('"' | '""')? ([^"\] | ECHAR | UCHAR))* '"""'
        let STRING_LITERAL_LONG_QUOTE = {$0.joined()} <^> (string("\"\"\"")
            *> zeroOrMore(extend
                <^> ({$0 ?? ""} <^> optional(string("\"") <|> string("\"\"")))
                <*> ((String.init <^> noneOf("\"\\")) <|> ECHAR <|> UCHAR))
            <* string("\"\"\""))

        // [161s]    WS    ::=    #x20 | #x9 | #xD | #xA /* #x20=space #x9=character tabulation #xD=carriage return #xA=new line */
        let WS = oneOf("\u{20}\u{9}\u{A}\u{D}")

        // [162s]    ANON    ::=    '[' WS* ']'
        let ANON = extend <^> char("[") <*> (extend <^> zeroOrMore(WS) <*> char("]"))

        let OTHER: Parser<Character, String> = string("^^") <|> string("@prefix") <|> string("@base") <|> string("PREFIX") <|> string("BASE") <|> string("true") <|> string("false") <|> String.init <^> oneOf(";a.[]()")

        let spaces: Parser<Character, Token?> = {_ in nil} <^> oneOrMore(char(.whitespacesAndNewlines, name: "spaces"))
        let string: Parser<Character, Token> =
            Token.STRING_LITERAL_QUOTE <^> STRING_LITERAL_QUOTE
            <|> Token.STRING_LITERAL_SINGLE_QUOTE <^> STRING_LITERAL_SINGLE_QUOTE
            <|> Token.STRING_LITERAL_LONG_QUOTE <^> STRING_LITERAL_LONG_QUOTE
            <|> Token.STRING_LITERAL_LONG_SINGLE_QUOTE <^> STRING_LITERAL_LONG_SINGLE_QUOTE
        let comment: Parser<Character, Token?> = {_ in nil} <^> (char("#") *> zeroOrMore(noneOf("\n\r\r\n")) <* oneOf("\n\r\r\n"))
        let token: Parser<Character, Token> =
            Token.IRIREF <^> IRIREF
                <|> Token.PNAME_LN <^> PNAME_LN
                <|> Token.PNAME_NS <^> PNAME_NS
                <|> Token.PN_PREFIX <^> PN_PREFIX
                <|> Token.PN_LOCAL <^> PN_LOCAL
                <|> Token.PLX <^> PLX
                <|> Token.PERCENT <^> PERCENT
//                <|> Token.BLANK_NODE_LABEL <^> BLANK_NODE_LABEL
//                <|> Token.LANGTAG <^> LANGTAG
//                <|> Token.INTEGER <^> INTEGER
//                <|> Token.DECIMAL <^> DECIMAL
//                <|> Token.DOUBLE <^> DOUBLE
//                <|> Token.EXPONENT <^> EXPONENT
                <|> Token.PN_CHARS_U <^> (String.init <^> PN_CHARS_U)
                <|> Token.PN_CHARS <^> (String.init <^> PN_CHARS)
                <|> Token.PN_CHARS_BASE <^> (String.init <^> PN_CHARS_BASE)
                <|> Token.UCHAR <^> UCHAR
                <|> Token.ECHAR <^> ECHAR
                <|> Token.HEX <^> (String.init <^> HEX)
//                <|> Token.WS <^> (String.init <^> WS) // WS is only effective in ANON. otherwise should be skipped
                <|> Token.ANON <^> ANON
                <|> Token.PN_LOCAL_ESC <^> PN_LOCAL_ESC
                <|> Token.OTHER <^> OTHER
        let tokenParser: Parser<Character, Token?> =
        {$0} <^> string
            <|> {$0} <^> comment
            <|> {$0} <^> token
            <|> {$0} <^> spaces

        var remainder = docString
        var tokens: [Token] = []
        while !remainder.isEmpty {
            do {
                let result = try tokenParser.parse(AnyCollection(remainder))
                if let token = result.output {
                    NSLog("%@", "read token: \(token)")
                    tokens.append(token)
                } else {
                    NSLog("%@", "skipped characters: \(remainder.count - result.remainder.count)")
                }
                remainder = String(result.remainder)
            } catch {
                NSLog("%@", error.localizedDescription)
                fatalError()
            }
        }

        let tokenStrings: [String] = tokens.map {$0.string}
        self = try parse(TurtleDoc.parser, tokenStrings)
    }
}

extension TurtleDoc.Statement {
    static var parser: Parser<String, TurtleDoc.Statement> {
        return self.triple <^> TurtleDoc.Triple.parser
    }
}

extension TurtleDoc.Triple {
    static var parser: Parser<String, TurtleDoc.Triple> {
        return self.subject <^> (tuple <^> TurtleDoc.Subject.parser <*> TurtleDoc.PredicateObjectList.parser)
        <|> self.blank <^> (tuple <^> TurtleDoc.BlankNodePropertyList.parser <*> optional(TurtleDoc.PredicateObjectList.parser))
    }
}

extension TurtleDoc.Subject {
    static var parser: Parser<String, TurtleDoc.Subject> {
        return self.iri <^> IRI.parser
            <|> self.blank <^> BlankNode.parser
            <|> self.collection <^> TurtleDoc.Collection.parser
    }
}

extension TurtleDoc.PredicateObjectList {
    static var parser: Parser<String, TurtleDoc.PredicateObjectList> {
        let po = tuple <^> TurtleDoc.Verb.parser <*> TurtleDoc.ObjectList.parser
        return TurtleDoc.PredicateObjectList.init <^> (tuple <^> po <*> ({$0.compactMap {$0}} <^> zeroOrMore(char(";") *> optional(po))))
    }
}

extension TurtleDoc.ObjectList {
    static var parser: Parser<String, TurtleDoc.ObjectList> {
        let p = TurtleDoc.Object.parser
        return TurtleDoc.ObjectList.init <^> (tuple <^> p <*> zeroOrMore(char(",") *> p))
    }
}

extension TurtleDoc.Verb {
    static var parser: Parser<String, TurtleDoc.Verb> {
        return {TurtleDoc.Verb.iri($0)} <^> IRI.parser
    }
}

extension TurtleDoc.Object {
    static var parser: Parser<String, TurtleDoc.Object> {
        return lazy(TurtleDoc.Object.iri <^> IRI.parser
            <|> TurtleDoc.Object.blankNode <^> BlankNode.parser
            <|> TurtleDoc.Object.collection <^> TurtleDoc.Collection.parser
            <|> TurtleDoc.Object.blankNodePropertyList <^> TurtleDoc.BlankNodePropertyList.parser
            <|> TurtleDoc.Object.literal <^> TurtleDoc.Literal.parser)
    }
}

extension BlankNode {
    static var parser: Parser<String, BlankNode> {
        let baseCharSet: CharacterSet = [
            CharacterSet(charactersIn: "A"..."Z"),
            CharacterSet(charactersIn: "a"..."z"),
            CharacterSet(charactersIn: "\u{00C0}"..."\u{00D6}"),
            CharacterSet(charactersIn: "\u{00D8}"..."\u{00F6}"),
            CharacterSet(charactersIn: "\u{00F8}"..."\u{02FF}"),
            CharacterSet(charactersIn: "\u{0370}"..."\u{037D}"),
            CharacterSet(charactersIn: "\u{037F}"..."\u{1FFF}"),
            CharacterSet(charactersIn: "\u{200C}"..."\u{200D}"),
            CharacterSet(charactersIn: "\u{2070}"..."\u{218F}"),
            CharacterSet(charactersIn: "\u{2C00}"..."\u{2FEF}"),
            CharacterSet(charactersIn: "\u{3001}"..."\u{D7FF}"),
            CharacterSet(charactersIn: "\u{F900}"..."\u{FDCF}"),
            CharacterSet(charactersIn: "\u{FDF0}"..."\u{FFFD}"),
            CharacterSet(charactersIn: "\u{10000}"..."\u{EFFFF}"),
            ].reduce(into: CharacterSet()) {$0.formUnion($1)}
        let PN_CHARS_BASE = char(baseCharSet, name: "PN_CHARS_BASE")
        let PN_CHARS_U = PN_CHARS_BASE <|> char("_")
        let PN_CHARS = PN_CHARS_U <|> char("-") <|> digit <|> char("\u{00B7}") <|> char(CharacterSet(charactersIn: "\u{0300}"..."\u{036F}"), name: "") <|> char(CharacterSet(charactersIn: "\u{203F}"..."\u{2040}"), name: "")

        // [137s]    BlankNode    ::=    BLANK_NODE_LABEL | ANON
        // [141s]    BLANK_NODE_LABEL    ::=    '_:' (PN_CHARS_U | [0-9]) ((PN_CHARS | '.')* PN_CHARS)?
        return string("_:") *> (BlankNode.label <^> (extend <^> (String.init <^> (PN_CHARS_U <|> digit))
            <*> (extend <^> zeroOrMore((PN_CHARS <|> char("."))) <*> PN_CHARS)))
    }
}

extension TurtleDoc.BlankNodePropertyList {
    static var parser: Parser<String, TurtleDoc.BlankNodePropertyList> {
        // [14]    blankNodePropertyList    ::=    '[' predicateObjectList ']'
        return self.init <^> (char("[") *> TurtleDoc.PredicateObjectList.parser <* char("]"))
    }
}

extension TurtleDoc.Literal {
    static var parser: Parser<String, TurtleDoc.Literal> {
        return self.rdf <^> RDFLiteral.parser
            <|> self.numeric <^> NumericLiteral.parser
            <|> self.boolean <^> ({_ in true} <^> string("true") <|> {_ in false} <^> string("false"))
    }
}

extension RDFLiteral {
    static var parser: Parser<String, RDFLiteral> {
        // [128s]    RDFLiteral    ::=    String (LANGTAG | '^^' iri)?
        // [17]    String    ::=    STRING_LITERAL_QUOTE | STRING_LITERAL_SINGLE_QUOTE | STRING_LITERAL_LONG_SINGLE_QUOTE | STRING_LITERAL_LONG_QUOTE
        // [22]    STRING_LITERAL_QUOTE    ::=    '"' ([^#x22#x5C#xA#xD] | ECHAR | UCHAR)* '"' /* #x22=" #x5C=\ #xA=new line #xD=carriage return */
        // [23]    STRING_LITERAL_SINGLE_QUOTE    ::=    "'" ([^#x27#x5C#xA#xD] | ECHAR | UCHAR)* "'" /* #x27=' #x5C=\ #xA=new line #xD=carriage return */
        // [24]    STRING_LITERAL_LONG_SINGLE_QUOTE    ::=    "'''" (("'" | "''")? ([^'\] | ECHAR | UCHAR))* "'''"
        // [25]    STRING_LITERAL_LONG_QUOTE    ::=    '"""' (('"' | '""')? ([^"\] | ECHAR | UCHAR))* '"""'
        // [26]    UCHAR    ::=    '\u' HEX HEX HEX HEX | '\U' HEX HEX HEX HEX HEX HEX HEX HEX
        // [171s]    HEX    ::=    [0-9] | [A-F] | [a-f]
        // [159s]    ECHAR    ::=    '\' [tbnrf"'\]
        // [144s]    LANGTAG    ::=    '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*
        let azAZ = char(CharacterSet(charactersIn: "a"..."z").union(CharacterSet(charactersIn: "A"..."Z")), name: "[a-zA-Z]")
        let azAZ09 = azAZ <|> char(CharacterSet(charactersIn: "0"..."9"), name: "[0-9]")
        let ECHAR = extend <^> FootlessParser.string("\\") <*> oneOf("tbnrf\"'\\")
        let HEX = char(CharacterSet(charactersIn: "0"..."9").union(CharacterSet(charactersIn: "A"..."F").union(CharacterSet(charactersIn: "a"..."f"))), name: "HEX")
        let UCHAR = FootlessParser.string("\\u") *> count(4, HEX)
            <|> FootlessParser.string("\\U") *> count(8, HEX)
        let STRING_LITERAL_QUOTE = {$0.joined()} <^> (char("\"") *> zeroOrMore((String.init <^> noneOf("\u{22}\u{5C}\u{A}\u{D}")) <|> ECHAR <|> UCHAR) <* char("\""))
        let STRING_LITERAL_SINGLE_QUOTE = {$0.joined()} <^> (char("'") *> zeroOrMore((String.init <^> noneOf("\u{27}\u{5C}\u{A}\u{D}")) <|> ECHAR <|> UCHAR) <* char("'"))
        let STRING_LITERAL_LONG_SINGLE_QUOTE = {$0.joined()} <^> (FootlessParser.string("'''")
            *> zeroOrMore(extend
                <^> ({$0 ?? ""} <^> optional(FootlessParser.string("'") <|> FootlessParser.string("''")))
                <*> ((String.init <^> noneOf("'\\")) <|> ECHAR <|> UCHAR))
            <* FootlessParser.string("'''"))
        let STRING_LITERAL_LONG_QUOTE = {$0.joined()} <^> (FootlessParser.string("\"\"\"")
            *> zeroOrMore(extend
                <^> ({$0 ?? ""} <^> optional(FootlessParser.string("\"") <|> FootlessParser.string("\"\"")))
                <*> ((String.init <^> noneOf("\"\\")) <|> ECHAR <|> UCHAR))
            <* FootlessParser.string("\"\"\""))
        let sp = STRING_LITERAL_QUOTE <|> STRING_LITERAL_SINGLE_QUOTE <|> STRING_LITERAL_LONG_SINGLE_QUOTE <|> STRING_LITERAL_LONG_QUOTE
        let lp = char("@") *> (extend <^> oneOrMore(azAZ) <*> ({$0.flatMap {$0}} <^> zeroOrMore(char("-") *> oneOrMore(azAZ09))))
        return self.init <^> (tuple <^> sp <*> (optional(lp)
            <|> {_ in String?.none} <^> (FootlessParser.string("^^") *> IRI.parser)) // TODO: RDFLiteral.iri
        )
    }
}

extension NumericLiteral {
    static var parser: Parser<String, NumericLiteral> {
        // [16]    NumericLiteral    ::=    INTEGER | DECIMAL | DOUBLE
        // [19]    INTEGER    ::=    [+-]? [0-9]+
        // [20]    DECIMAL    ::=    [+-]? [0-9]* '.' [0-9]+
        // [21]    DOUBLE    ::=    [+-]? ([0-9]+ '.' [0-9]* EXPONENT | '.' [0-9]+ EXPONENT | [0-9]+ EXPONENT)
        // [154s]    EXPONENT    ::=    [eE] [+-]? [0-9]+
        let sign = optional(oneOf("+-"), otherwise: Character(""))
        let integer = extend <^> sign <*> oneOrMore(digit)
            >>- {Int($0).map {pure($0)} ?? fail(.Mismatch(AnyCollection([]), "Int", "not an integer: \($0)"))}
        let decimal = (extend <^> sign
            <*> (extend
                <^> zeroOrMore(digit)
                <*> (extend
                    <^> char(".")
                    <*> oneOrMore(digit))))
            >>- {Decimal(string: $0).map {pure($0)} ?? fail(.Mismatch(AnyCollection([]), "Decimal", "not a decimal: \($0)"))}
        let exponent = extend <^> oneOf("eE") <*> (extend <^> sign <*> oneOrMore(digit))
        let doubleP1 = extend <^> oneOrMore(digit) <*> (extend <^> char(".") <*> (extend <^> zeroOrMore(digit) <*> exponent))
        let doubleP2 = extend <^> char(".") <*> (extend <^> oneOrMore(digit) <*> exponent)
        let doubleP3 = extend <^> oneOrMore(digit) <*> exponent
        let double = (extend <^> sign
            <*> (doubleP1 <|> doubleP2 <|> doubleP3))
            >>- {Double($0).map {pure($0)} ?? fail(.Mismatch(AnyCollection([]), "Double", "not a double: \($0)"))}
        return NumericLiteral.integer <^> integer
            <|> NumericLiteral.decimal <^> decimal
            <|> NumericLiteral.double <^> double
    }
}

extension TurtleDoc.Collection {
    static var parser: Parser<String, TurtleDoc.Collection> {
        return char("(") *> zeroOrMore(TurtleDoc.Object.parser) <* char(")")
    }
}

extension IRI {
    static var parser: Parser<TurtleDoc.Token, IRI> {
        let iriRefParser: Parser<Character, String> = oneOrMore(noneOf("{}|^`\\\""))
        let refParser = char("<") *> iriRefParser <* char(">")
        let prefixedParser = (tuple <^> iriRefParser) <*> (char(":") *> iriRefParser)
        return {IRI.ref(IRIRef(value: $0))} <^> refParser
            <|> {IRI.prefixedName(.ln((PNameNS(value: $0), $1)))} <^> prefixedParser
    }
}
