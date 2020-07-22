import Foundation
import OSLog

public struct TurtleDoc {
    public enum Token: Equatable {
        // Turtle terminaters
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
        // not-in Turtle terminaters
        case KEYWORD(String)
        case OTHER(String)
    }

    public var statements: [Statement]

    public enum Statement {
        case directive(Directive)
        case triple(Triple)
    }

    // [3]    directive    ::=    prefixID | base | sparqlPrefix | sparqlBase
    public enum Directive {
        case prefixID(PNameNS, IRIRef)
        case base(IRIRef)
        case sparqlPrefix(PNameNS, IRIRef)
        case sparqlBase(IRIRef)
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
        case .KEYWORD(let s): return s
        case .OTHER(let s): return s
        }
    }
}

extension TurtleDoc {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc> {
        return self.init <^> oneOrMore(Statement.parser)
    }

    public init(_ docString: String) throws {
        let docString = docString.hasPrefix("\u{feff}") ? String(docString.dropFirst()) : docString

        // Look-ahead with same class terminator
        func oneOrMoreTerminated <T,A> (_ repeatedParser: Parser<T,A>, terminationParser: Parser<T, A>) -> Parser<T,[A]> {
            return Parser { input in
                var (termination, terminatedRemainder) = try terminationParser.parse(input)
                var result = [termination]
                var remainder = input
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
        let IRIREF = char("<") *> ({$0.joined()} <^> zeroOrMore(
            String.init <^> char(CharacterSet(charactersIn: "\u{00}"..."\u{20}").union(CharacterSet(charactersIn: ">\"{}|^`\\")).inverted, name: "[^#x00-#x20<>\"{}|^`\\]")
                <|> UCHAR)) <* char(">")

        // [163s]    PN_CHARS_BASE    ::=    [A-Z] | [a-z] | [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF] | [#x0370-#x037D] | [#x037F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
        let PN_CHARS_BASE_charset = [
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
        let PN_CHARS_BASE = char(PN_CHARS_BASE_charset, name: "PN_CHARS_BASE")

        // [164s]    PN_CHARS_U    ::=    PN_CHARS_BASE | '_'
        let PN_CHARS_U_charset = PN_CHARS_BASE_charset.union(CharacterSet(charactersIn: "_"))
        let PN_CHARS_U = char(PN_CHARS_U_charset, name: "PN_CHARS_U")

        // [166s]    PN_CHARS    ::=    PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
        let PN_CHARS_charset = [
            PN_CHARS_U_charset,
            CharacterSet(charactersIn: "-"),
            CharacterSet(charactersIn: "0"..."9"),
            CharacterSet(charactersIn: "\u{00B7}"),
            CharacterSet(charactersIn: "\u{0300}"..."\u{036F}"),
            CharacterSet(charactersIn: "\u{203F}"..."\u{2040}"),
            ].reduce(into: CharacterSet()) {$0.formUnion($1)}
        let PN_CHARS = char(PN_CHARS_charset, name: "PN_CHARS")

        // [167s]    PN_PREFIX    ::=    PN_CHARS_BASE ((PN_CHARS | '.')* PN_CHARS)?
        let PN_PREFIX = extend <^> PN_CHARS_BASE <*> optional({String($0)} <^> zeroOrMoreTerminated(PN_CHARS <|> char("."), terminationParser: PN_CHARS), otherwise: "")

        // [139s]    PNAME_NS    ::=    PN_PREFIX? ':'
        let PNAME_NS = optional(PN_PREFIX, otherwise: "") <* char(":")

        // [170s]    PERCENT    ::=    '%' HEX HEX
        let PERCENT = extend <^> char("%") <*> (extend <^> HEX <*> (String.init <^> HEX))

        // [172s]    PN_LOCAL_ESC    ::=    '\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%')
        let PN_LOCAL_ESC = extend <^> char("\\") <*> (String.init <^> oneOf("_~.-!$&'()*+,;=/?#@%"))

        // [169s]    PLX    ::=    PERCENT | PN_LOCAL_ESC
        let PLX = PERCENT <|> PN_LOCAL_ESC

        // [168s]    PN_LOCAL    ::=    (PN_CHARS_U | ':' | [0-9] | PLX) ((PN_CHARS | '.' | ':' | PLX)* (PN_CHARS | ':' | PLX))?
        let PN_LOCAL = extend <^> (String.init <^> char(PN_CHARS_U_charset.union(CharacterSet(charactersIn: ":0123456789")), name: "PN_LOCAL_1")
            <|> PLX)
            <*> optional({$0.joined()} <^> zeroOrMoreTerminated(
                String.init <^> char(PN_CHARS_charset.union(CharacterSet(charactersIn: ".:")), name: "PN_LOCAL_2")
                    <|> PLX,
                terminationParser: (String.init <^> char(PN_CHARS_charset.union(CharacterSet(charactersIn: ":")), name: "PN_LOCAL_3")
                    <|> PLX)),
                         otherwise: "")

        // [140s]    PNAME_LN    ::=    PNAME_NS PN_LOCAL
        let PNAME_LN = extend <^> PNAME_NS <*> PN_LOCAL

        // [141s]    BLANK_NODE_LABEL    ::=    '_:' (PN_CHARS_U | [0-9]) ((PN_CHARS | '.')* PN_CHARS)?
        let BLANK_NODE_LABEL = extend <^> string("_:") <*> (extend <^> (PN_CHARS_U <|> digit) <*> optional({String($0)} <^> zeroOrMoreTerminated(PN_CHARS <|> char("."), terminationParser: PN_CHARS), otherwise: ""))

        // [144s]    LANGTAG    ::=    '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*
        let LANGTAG = extend <^> string("@")
            <*> (extend
                <^> oneOrMore(char(CharacterSet(charactersIn: "A"..."Z"), name: "[A-Z]")
                    <|> char(CharacterSet(charactersIn: "a"..."z"), name: "[a-z]"))
                <*> zeroOrMore(char(CharacterSet(charactersIn: "A"..."Z"), name: "[A-Z]")
                    <|> char(CharacterSet(charactersIn: "a"..."z"), name: "[a-z]")
                    <|> char(CharacterSet(charactersIn: "0"..."9"), name: "[0-9]")
                    <|> char("-")))

        // [19]    INTEGER    ::=    [+-]? [0-9]+
        let sign = optional(String.init <^> oneOf("+-"), otherwise: "")
        let INTEGER = extend <^> sign <*> oneOrMore(digit)

        // [20]    DECIMAL    ::=    [+-]? [0-9]* '.' [0-9]+
        let DECIMAL = (extend <^> sign
            <*> (extend
                <^> zeroOrMore(digit)
                <*> (extend
                    <^> char(".")
                    <*> oneOrMore(digit))))
        // [154s]    EXPONENT    ::=    [eE] [+-]? [0-9]+
        let EXPONENT = extend <^> oneOf("eE") <*> (extend <^> sign <*> oneOrMore(digit))

        // [21]    DOUBLE    ::=    [+-]? ([0-9]+ '.' [0-9]* EXPONENT | '.' [0-9]+ EXPONENT | [0-9]+ EXPONENT)
        let doubleP1 = extend <^> oneOrMore(digit) <*> (extend <^> char(".") <*> (extend <^> zeroOrMore(digit) <*> EXPONENT))
        let doubleP2 = extend <^> char(".") <*> (extend <^> oneOrMore(digit) <*> EXPONENT)
        let doubleP3 = extend <^> oneOrMore(digit) <*> EXPONENT
        let DOUBLE = (extend <^> sign <*> (doubleP1 <|> doubleP2 <|> doubleP3))

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

        let KEYWORD = (string("^^") <|> string("@prefix") <|> string("@base") <|> string("PREFIX") <|> string("BASE") <|> string("true") <|> string("false") <|> string("a")) <* WS

        let OTHER: Parser<Character, String> = String.init <^> oneOf(";,.[]()")
        
        let spaces: Parser<Character, Token?> = {_ in nil} <^> oneOrMore(char(.whitespacesAndNewlines, name: "spaces"))
        let stringLiteral: Parser<Character, Token> =
            Token.STRING_LITERAL_LONG_QUOTE <^> STRING_LITERAL_LONG_QUOTE
                <|> Token.STRING_LITERAL_LONG_SINGLE_QUOTE <^> STRING_LITERAL_LONG_SINGLE_QUOTE
                <|> Token.STRING_LITERAL_QUOTE <^> STRING_LITERAL_QUOTE
                <|> Token.STRING_LITERAL_SINGLE_QUOTE <^> STRING_LITERAL_SINGLE_QUOTE
        let comment: Parser<Character, Token?> = {_ in nil} <^> (char("#") *> zeroOrMore(noneOf("\n\r\r\n")) <* ({_ in} <^> oneOf("\n\r\r\n") <|> eof()))
        let token: Parser<Character, Token> =
            Token.IRIREF <^> IRIREF
                <|> Token.KEYWORD <^> KEYWORD
                <|> Token.PNAME_NS <^> PNAME_NS
                <|> Token.PN_LOCAL <^> PN_LOCAL
                <|> Token.PN_PREFIX <^> PN_PREFIX
                <|> Token.PNAME_LN <^> PNAME_LN
                <|> Token.PLX <^> PLX
                <|> Token.PERCENT <^> PERCENT
                <|> Token.BLANK_NODE_LABEL <^> BLANK_NODE_LABEL
                <|> Token.LANGTAG <^> LANGTAG
                <|> Token.INTEGER <^> INTEGER
                <|> Token.DECIMAL <^> DECIMAL
                <|> Token.DOUBLE <^> DOUBLE
                <|> Token.EXPONENT <^> EXPONENT
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
        {$0} <^> stringLiteral
            <|> {$0} <^> comment
            <|> {$0} <^> token
            <|> {$0} <^> spaces

        // step-by-step tokenize for debug
        var tokens: [Token] = []
        func partial(_ docString: String) throws {
            var remainder = docString
            while !remainder.isEmpty {
                do {
                    let result = try tokenParser.parse(AnyCollection(remainder))
                    if let token = result.output {
                        if #available(OSX 10.12, *) { os_log("read token (%d): %@", type: .debug, remainder.count, String(describing: token)) }
                        else { NSLog("read token (\(remainder.count)): \(token)") }
                        tokens.append(token)
                    } else {
                        if #available(OSX 10.12, *) { os_log("skipped characters: %d", type: .debug, remainder.count - result.remainder.count) }
                        else { NSLog("skipped characters: \(remainder.count - result.remainder.count)") }
                    }
                    remainder = String(result.remainder)
                } catch {
                    NSLog("%@", String(describing: error))
                    throw error
                }
            }
        }
        // FootlessParser is slow when parsing large string.
        // dirty workaround for speed
        try docString.components(separatedBy: " .\n\n").map {$0 + " ."}.forEach {
            try partial($0)
        }
        tokens.removeLast()
        if #available(OSX 10.12, *) { os_log("%d tokens parsed", type: .debug, tokens.count) }


//        let tokens = try parse(oneOrMore(tokenParser), docString).compactMap {$0}
//        let tokens = try oneOrMore(tokenParser).parse(docString).output
        self = try parse(TurtleDoc.parser, tokens)
    }
}


enum TokenParsers {
    static func IRIREF() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "IRIREF") {
            switch $0 {
            case .IRIREF: return true
            default: return false
            }
        }
    }
    static func PNAME_LN() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "PNAME_LN") {
            switch $0 {
            case .PNAME_LN: return true
            default: return false
            }
        }
    }

    static func PNAME_NS() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "PNAME_NS") {
            switch $0 {
            case .PNAME_NS: return true
            default: return false
            }
        }
    }

    static func PN_LOCAL() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "PN_LOCAL") {
            switch $0 {
            case .PN_LOCAL: return true
            default: return false
            }
        }
    }

    static func STRING() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "STRING") {
            switch $0 {
            case .STRING_LITERAL_QUOTE: return true
            case .STRING_LITERAL_SINGLE_QUOTE: return true
            case .STRING_LITERAL_LONG_QUOTE: return true
            case .STRING_LITERAL_LONG_SINGLE_QUOTE: return true
            default: return false
            }
        }
    }

    static func INTEGER() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "INTEGER") {
            switch $0 {
            case .INTEGER: return true
            default: return false
            }
        }
    }

    static func DECIMAL() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "DECIMAL") {
            switch $0 {
            case .DECIMAL: return true
            default: return false
            }
        }
    }

    static func DOUBLE() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "DOUBLE") {
            switch $0 {
            case .DOUBLE: return true
            default: return false
            }
        }
    }

    static func LANGTAG() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "LANGTAG") {
            switch $0 {
            case .LANGTAG: return true
            default: return false
            }
        }
    }

    static func BLANK_NODE_LABEL() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "BLANK_NODE_LABEL") {
            switch $0 {
            case .BLANK_NODE_LABEL: return true
            default: return false
            }
        }
    }

    static func ANON() -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return satisfy(expect: "ANON") {
            switch $0 {
            case .ANON: return true
            default: return false
            }
        }
    }

    static func OTHER(_ s: String) -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return token(.OTHER(s))
    }

    static func KEYWORD(_ s: String) -> Parser<TurtleDoc.Token, TurtleDoc.Token> {
        return token(.KEYWORD(s))
    }
}

extension TurtleDoc.Statement {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Statement> {
        return self.directive <^> TurtleDoc.Directive.parser
            <|> self.triple <^> TurtleDoc.Triple.parser <* TokenParsers.OTHER(".")
    }
}

extension TurtleDoc.Directive {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Directive> {
        // [4]    prefixID    ::=    '@prefix' PNAME_NS IRIREF '.'
        // [5]    base    ::=    '@base' IRIREF '.'
        // [5s]    sparqlBase    ::=    "BASE" IRIREF
        // [6s]    sparqlPrefix    ::=    "PREFIX" PNAME_NS IRIREF
        return self.prefixID <^> (TokenParsers.KEYWORD("@prefix") *> (tuple <^> PNameNS.parser <*> IRIRef.parser) <* TokenParsers.OTHER("."))
            <|> self.base <^> (TokenParsers.KEYWORD("@base") *> IRIRef.parser <* TokenParsers.OTHER("."))
            <|> self.sparqlBase <^> (TokenParsers.KEYWORD("BASE") *> IRIRef.parser)
            <|> self.sparqlPrefix <^> (TokenParsers.KEYWORD("PREFIX") *> (tuple <^> PNameNS.parser <*> IRIRef.parser))
    }
}

extension TurtleDoc.Triple {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Triple> {
        return self.subject <^> (tuple <^> TurtleDoc.Subject.parser <*> TurtleDoc.PredicateObjectList.parser)
        <|> self.blank <^> (tuple <^> TurtleDoc.BlankNodePropertyList.parser <*> optional(TurtleDoc.PredicateObjectList.parser))
    }
}

extension TurtleDoc.Subject {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Subject> {
        return self.iri <^> IRI.parser
            <|> self.blank <^> BlankNode.parser
            <|> self.collection <^> [TurtleDoc.Object].parser
    }
}

extension TurtleDoc.PredicateObjectList {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.PredicateObjectList> {
        let po = tuple <^> TurtleDoc.Verb.parser <*> TurtleDoc.ObjectList.parser
        return TurtleDoc.PredicateObjectList.init <^> (tuple <^> po <*> ({$0.compactMap {$0}} <^> zeroOrMore(TokenParsers.OTHER(";") *> optional(po))))
    }
}

extension TurtleDoc.ObjectList {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.ObjectList> {
        let p = TurtleDoc.Object.parser
        return TurtleDoc.ObjectList.init <^> (tuple <^> p <*> zeroOrMore(TokenParsers.OTHER(",") *> p))
    }
}

extension TurtleDoc.Verb {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Verb> {
        return {self.iri($0)} <^> IRI.parser
            <|> {_ in self.a} <^> TokenParsers.KEYWORD("a")
    }
}

extension TurtleDoc.Object {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Object> {
        return lazy(TurtleDoc.Object.iri <^> IRI.parser
            <|> TurtleDoc.Object.blankNode <^> BlankNode.parser
            <|> TurtleDoc.Object.collection <^> TurtleDoc.Collection.parser
            <|> TurtleDoc.Object.blankNodePropertyList <^> TurtleDoc.BlankNodePropertyList.parser
            <|> TurtleDoc.Object.literal <^> TurtleDoc.Literal.parser)
    }
}

extension BlankNode {
    static var parser: Parser<TurtleDoc.Token, BlankNode> {
        return {self.label($0.string)} <^> TokenParsers.BLANK_NODE_LABEL()
            <|> {_ in self.anon} <^> TokenParsers.ANON()
    }
}

extension TurtleDoc.BlankNodePropertyList {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.BlankNodePropertyList> {
        // [14]    blankNodePropertyList    ::=    '[' predicateObjectList ']'
        return self.init <^> (TokenParsers.OTHER("[") *> TurtleDoc.PredicateObjectList.parser <* TokenParsers.OTHER("]"))
    }
}

extension TurtleDoc.Literal {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Literal> {
        return self.rdf <^> RDFLiteral.parser
            <|> self.numeric <^> NumericLiteral.parser
            <|> self.boolean <^> ({_ in true} <^> TokenParsers.OTHER("true") <|> {_ in false} <^> TokenParsers.OTHER("false"))
    }
}

extension RDFLiteral {
    static var parser: Parser<TurtleDoc.Token, RDFLiteral> {
        let sp = {$0.string} <^> TokenParsers.STRING()
        let lp = {$0.string} <^> TokenParsers.LANGTAG()
        return self.init <^> (tuple <^> sp <*> (optional(lp)
            <|> {_ in String?.none} <^> (TokenParsers.OTHER("^^") *> IRI.parser)) // TODO: RDFLiteral.iri
        )
    }
}

extension NumericLiteral {
    static var parser: Parser<TurtleDoc.Token, NumericLiteral> {
        let integer = TokenParsers.INTEGER()
            >>- {Int($0.string).map {pure($0)} ?? fail(.Mismatch(AnyCollection([]), "Int", "not an integer: \($0)"))}
        let decimal = TokenParsers.DECIMAL()
            >>- {Decimal(string: $0.string).map {pure($0)} ?? fail(.Mismatch(AnyCollection([]), "Decimal", "not a decimal: \($0)"))}
        let double = TokenParsers.DOUBLE()
            >>- {Double($0.string).map {pure($0)} ?? fail(.Mismatch(AnyCollection([]), "Double", "not a double: \($0)"))}
        return NumericLiteral.integer <^> integer
            <|> NumericLiteral.decimal <^> decimal
            <|> NumericLiteral.double <^> double
    }
}

// extension TurtleDoc.Collection { // Xcode 10.2+
extension Array where Element == TurtleDoc.Object {
    static var parser: Parser<TurtleDoc.Token, TurtleDoc.Collection> {
        return TokenParsers.OTHER("(") *> zeroOrMore(TurtleDoc.Object.parser) <* TokenParsers.OTHER(")")
    }
}

extension IRI {
    static var parser: Parser<TurtleDoc.Token, IRI> {
        return IRI.ref <^> IRIRef.parser
            <|> {IRI.prefixedName(.ln(($0, $1.string)))} <^> (tuple <^> PNameNS.parser <*> TokenParsers.PN_LOCAL())
            <|> {IRI.prefixedName(.ns($0))} <^> PNameNS.parser
    }
}
extension IRIRef {
    static var parser: Parser<TurtleDoc.Token, IRIRef> {
        return {IRIRef(value: $0.string)} <^> TokenParsers.IRIREF()
    }
}

extension PNameNS {
    static var parser: Parser<TurtleDoc.Token, PNameNS> {
        return {PNameNS(value: $0.string)} <^> TokenParsers.PNAME_NS()
    }
}

// MARK: - convenience methods

extension TurtleDoc {
    public var triples: [Triple] {
        return statements.compactMap {
            switch $0 {
            case .triple(let t): return t
            case .directive: return nil
            }
        }
    }
    public var directives: [Directive] {
        return statements.compactMap {
            switch $0 {
            case .triple: return nil
            case .directive(let d): return d
            }
        }
    }
}

extension TurtleDoc.Object {
    init(_ object: TurtleDoc.Object, directives: [TurtleDoc.Directive]) {
        switch object {
        case .iri(let iri): self = .iri(IRI(iri: iri, basePrefixedBy: directives) ?? iri)
        case .blankNode: self = object
        case .collection(let c): self = .collection(c.map {.init($0, directives: directives)})
        case .blankNodePropertyList: self = object
        case .literal: self = object
        }
    }
}

extension IRI {
    init?(iri: IRI, basePrefixedBy directives: [TurtleDoc.Directive]) {
        guard let ref: IRIRef = (directives.lazy.compactMap {
            switch $0 {
            case .base(let ref), .sparqlBase(let ref): return ref
            case .prefixID(let prefix, let ref), .sparqlPrefix(let prefix, let ref): return (prefix.value?.isEmpty ?? true) ? ref : nil
            }
        }.first) else { return nil }

        switch iri {
        case .prefixedName(.ln((let ns, let local))) where (ns.value?.isEmpty ?? true): self = .ref(.init(value: ref.value + local))
        case .prefixedName: self = iri
        case .ref: self = iri
        }
    }
}

public struct SubjectDescription {
    public var subject: TurtleDoc.Subject
    public var a: [IRI] = []
    public var label: String?
    public var comment: String?

    public init?(_ t: TurtleDoc.Triple, directives: [TurtleDoc.Directive]) {
        switch t {
        case .subject(let s, let po):
            self.subject = {
                switch s {
                case .iri(let iri): return .iri(IRI(iri: iri, basePrefixedBy: directives) ?? iri)
                case .collection(let c): return .collection(c.map {.init($0, directives: directives)})
                case .blank(let b): return .blank(b)
                }
            }()
            for (verb, objects) in (po.list.map {($0.0, $0.1.list)}) {
                switch verb {
                case .iri(IRI.prefixedName(.ln((PNameNS(value: "rdfs"), "label")))),
                     .iri(.ref(IRIRef(value: "http://www.w3.org/2000/01/rdf-schema#label"))):
                    for case .literal(.rdf(let l)) in objects {
                        self.label = l.string
                    }
                case .iri(IRI.prefixedName(.ln((PNameNS(value: "rdfs"), "comment")))),
                     .iri(.ref(IRIRef(value: "http://www.w3.org/2000/01/rdf-schema#comment"))):
                    for case .literal(.rdf(let l)) in objects {
                        self.comment = l.string
                    }
                case .iri: break
                case .a:
                    for case .iri(let iri) in objects {
                        self.a.append(iri)
                    }
                }
            }
        case .blank: return nil
        }
    }

    public var swiftCode: String {
        let subjectName: String
        switch subject {
        case .iri(let i): subjectName = Serializer.serialize(i)
        case .blank(let n): subjectName = Serializer.serialize(n)
        case .collection: subjectName = "_"
        }
        let type: String = "_"

        func id(_ s: String) -> String {
            return s.replacingOccurrences(of: ":", with: "_")
        }

        func docComment(_ s: String) -> String {
            return s.components(separatedBy: .newlines)
                .map {"/// " + $0}
                .joined(separator: "\n")
        }

        return [
            docComment([label, comment].compactMap {$0}.joined(separator: ": ")),
            "public var \(id(subjectName)): \(type)",
            ].joined(separator: "\n")
    }
}
