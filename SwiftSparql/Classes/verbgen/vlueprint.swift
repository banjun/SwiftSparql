// generated by verbgen

fileprivate enum VlueprintSchema: IRIBaseProvider {
    static var base: IRIRef {return IRIRef(value: "https://vlueprint.org/schema/")}
}

fileprivate enum RdfSchema: IRIBaseProvider {
    static var base: IRIRef {return IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")}
}

fileprivate enum RdfsSchema: IRIBaseProvider {
    static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2000/01/rdf-schema#")}
}

public struct VlueprintVirtualBeing: RDFTypeConvertible {
    public static var rdfType: IRIRef {return VlueprintSchema.rdfType("VirtualBeing")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsVlueprintVirtualBeing() -> TripleBuilder<TripleBuilderStateRDFTypeBound<VlueprintVirtualBeing>> {return rdfType(is: VlueprintVirtualBeing.self)}
}

public struct VlueprintOrganization: RDFTypeConvertible {
    public static var rdfType: IRIRef {return VlueprintSchema.rdfType("Organization")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsVlueprintOrganization() -> TripleBuilder<TripleBuilderStateRDFTypeBound<VlueprintOrganization>> {return rdfType(is: VlueprintOrganization.self)}
}

public struct VlueprintPerformingGroup: RDFTypeConvertible {
    public static var rdfType: IRIRef {return VlueprintSchema.rdfType("PerformingGroup")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsVlueprintPerformingGroup() -> TripleBuilder<TripleBuilderStateRDFTypeBound<VlueprintPerformingGroup>> {return rdfType(is: VlueprintPerformingGroup.self)}
}

public struct VlueprintCompany: RDFTypeConvertible {
    public static var rdfType: IRIRef {return VlueprintSchema.rdfType("Company")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsVlueprintCompany() -> TripleBuilder<TripleBuilderStateRDFTypeBound<VlueprintCompany>> {return rdfType(is: VlueprintCompany.self)}
}

public struct VlueprintKeyword: RDFTypeConvertible {
    public static var rdfType: IRIRef {return VlueprintSchema.rdfType("Keyword")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsVlueprintKeyword() -> TripleBuilder<TripleBuilderStateRDFTypeBound<VlueprintKeyword>> {return rdfType(is: VlueprintKeyword.self)}
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == VlueprintVirtualBeing {
    /// type: The subject is an instance of a class.
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// type: The subject is an instance of a class.
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// comment: A description of the subject resource.
    func rdfsComment(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("comment"), value: [.varOrTerm(.term(v))])
    }
    
    /// comment: A description of the subject resource.
    func rdfsComment(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("comment"), value: [.var(v)])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.varOrTerm(.term(v))])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.var(v)])
    }
    
    /// 所属
    func vlueprintBelongTo(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("belongTo"), value: [.varOrTerm(.term(v))])
    }
    
    /// 所属
    func vlueprintBelongTo(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("belongTo"), value: [.var(v)])
    }
    
    /// Twitterアカウント
    func vlueprintTwitterAccount(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("twitterAccount"), value: [.varOrTerm(.term(v))])
    }
    
    /// Twitterアカウント
    func vlueprintTwitterAccount(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("twitterAccount"), value: [.var(v)])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.varOrTerm(.term(v))])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.var(v)])
    }
    
    /// YoutubeチャンネルID: チャンネルURLに関しては省略します
    func vlueprintYoutubeChannelId(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelId"), value: [.varOrTerm(.term(v))])
    }
    
    /// YoutubeチャンネルID: チャンネルURLに関しては省略します
    func vlueprintYoutubeChannelId(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelId"), value: [.var(v)])
    }
    
    /// Youtubeチャンネル名
    func vlueprintYoutubeChannelName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelName"), value: [.varOrTerm(.term(v))])
    }
    
    /// Youtubeチャンネル名
    func vlueprintYoutubeChannelName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelName"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == VlueprintOrganization {
    /// type: The subject is an instance of a class.
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// type: The subject is an instance of a class.
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// comment: A description of the subject resource.
    func rdfsComment(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("comment"), value: [.varOrTerm(.term(v))])
    }
    
    /// comment: A description of the subject resource.
    func rdfsComment(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("comment"), value: [.var(v)])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.varOrTerm(.term(v))])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.var(v)])
    }
    
    /// 所属
    func vlueprintBelongTo(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("belongTo"), value: [.varOrTerm(.term(v))])
    }
    
    /// 所属
    func vlueprintBelongTo(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("belongTo"), value: [.var(v)])
    }
    
    /// Twitterアカウント
    func vlueprintTwitterAccount(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("twitterAccount"), value: [.varOrTerm(.term(v))])
    }
    
    /// Twitterアカウント
    func vlueprintTwitterAccount(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("twitterAccount"), value: [.var(v)])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.varOrTerm(.term(v))])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.var(v)])
    }
    
    /// YoutubeチャンネルID: チャンネルURLに関しては省略します
    func vlueprintYoutubeChannelId(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelId"), value: [.varOrTerm(.term(v))])
    }
    
    /// YoutubeチャンネルID: チャンネルURLに関しては省略します
    func vlueprintYoutubeChannelId(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelId"), value: [.var(v)])
    }
    
    /// Youtubeチャンネル名
    func vlueprintYoutubeChannelName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelName"), value: [.varOrTerm(.term(v))])
    }
    
    /// Youtubeチャンネル名
    func vlueprintYoutubeChannelName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelName"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == VlueprintPerformingGroup {
    /// type: The subject is an instance of a class.
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// type: The subject is an instance of a class.
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// comment: A description of the subject resource.
    func rdfsComment(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("comment"), value: [.varOrTerm(.term(v))])
    }
    
    /// comment: A description of the subject resource.
    func rdfsComment(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("comment"), value: [.var(v)])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.varOrTerm(.term(v))])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.var(v)])
    }
    
    /// 所属
    func vlueprintBelongTo(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("belongTo"), value: [.varOrTerm(.term(v))])
    }
    
    /// 所属
    func vlueprintBelongTo(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("belongTo"), value: [.var(v)])
    }
    
    /// Twitterアカウント
    func vlueprintTwitterAccount(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("twitterAccount"), value: [.varOrTerm(.term(v))])
    }
    
    /// Twitterアカウント
    func vlueprintTwitterAccount(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("twitterAccount"), value: [.var(v)])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.varOrTerm(.term(v))])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.var(v)])
    }
    
    /// YoutubeチャンネルID: チャンネルURLに関しては省略します
    func vlueprintYoutubeChannelId(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelId"), value: [.varOrTerm(.term(v))])
    }
    
    /// YoutubeチャンネルID: チャンネルURLに関しては省略します
    func vlueprintYoutubeChannelId(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelId"), value: [.var(v)])
    }
    
    /// Youtubeチャンネル名
    func vlueprintYoutubeChannelName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelName"), value: [.varOrTerm(.term(v))])
    }
    
    /// Youtubeチャンネル名
    func vlueprintYoutubeChannelName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("youtubeChannelName"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == VlueprintCompany {
    /// type: The subject is an instance of a class.
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// type: The subject is an instance of a class.
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.varOrTerm(.term(v))])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.var(v)])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.varOrTerm(.term(v))])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == VlueprintKeyword {
    /// type: The subject is an instance of a class.
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// type: The subject is an instance of a class.
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.varOrTerm(.term(v))])
    }
    
    /// label: A human-readable name for the subject.
    func rdfsLabel(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfsSchema.verb("label"), value: [.var(v)])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.varOrTerm(.term(v))])
    }
    
    /// よみ(IME)
    func vlueprintYomi(is v: Var) -> TripleBuilder<State> {
        return appended(verb: VlueprintSchema.verb("yomi"), value: [.var(v)])
    }
}