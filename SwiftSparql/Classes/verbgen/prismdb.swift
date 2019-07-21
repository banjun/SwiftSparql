// generated by verbgen

public enum PrismSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "https://prismdb.takanakahiko.me/prism-schema.ttl#")}
}

public enum RdfSchema: IRIBaseProvider {
    public static var base: IRIRef {return IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")}
}

public struct PrismCharacter: RDFTypeConvertible {
    public typealias Schema = PrismSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Character")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismCharacter() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismCharacter>> {return rdfType(is: PrismCharacter.self)}
}

public struct PrismSong: RDFTypeConvertible {
    public typealias Schema = PrismSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Song")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismSong() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismSong>> {return rdfType(is: PrismSong.self)}
}

public struct PrismEpisode: RDFTypeConvertible {
    public typealias Schema = PrismSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Episode")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismEpisode() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismEpisode>> {return rdfType(is: PrismEpisode.self)}
}

public struct PrismLive: RDFTypeConvertible {
    public typealias Schema = PrismSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Live")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismLive() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismLive>> {return rdfType(is: PrismLive.self)}
}

public struct PrismSeries: RDFTypeConvertible {
    public typealias Schema = PrismSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Series")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismSeries() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismSeries>> {return rdfType(is: PrismSeries.self)}
}

public struct PrismItem: RDFTypeConvertible {
    public typealias Schema = PrismSchema
    public static var rdfType: IRIRef {return Schema.rdfType("Item")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismItem() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismItem>> {return rdfType(is: PrismItem.self)}
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismCharacter {
    /// 
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// 
    func prismBirthday(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("birthday"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismBirthday(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("birthday"), value: [.var(v)])
    }
    
    /// 
    func prismBlood_type(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("blood_type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismBlood_type(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("blood_type"), value: [.var(v)])
    }
    
    /// 
    func prismBrand(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("brand"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismBrand(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("brand"), value: [.var(v)])
    }
    
    /// 
    func prismCharm(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("charm"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismCharm(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("charm"), value: [.var(v)])
    }
    
    /// 
    func prismCv(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("cv"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismCv(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("cv"), value: [.var(v)])
    }
    
    /// 
    func prismFavorite_food(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("favorite_food"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismFavorite_food(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("favorite_food"), value: [.var(v)])
    }
    
    /// 
    func prismHeight(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("height"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismHeight(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("height"), value: [.var(v)])
    }
    
    /// 
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 
    func prismName_kana(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismName_kana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.var(v)])
    }
    
    /// 
    func prismType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismSong {
    /// 
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// 
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 
    func prismPerformedInLive(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performedInLive"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismPerformedInLive(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performedInLive"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismEpisode {
    /// 
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// 
    func prismEpisodeOfSeries(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("episodeOfSeries"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismEpisodeOfSeries(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("episodeOfSeries"), value: [.var(v)])
    }
    
    /// 
    func prismLivePerformed(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("livePerformed"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismLivePerformed(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("livePerformed"), value: [.var(v)])
    }
    
    /// 
    func prismあにてれ(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("あにてれ"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismあにてれ(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("あにてれ"), value: [.var(v)])
    }
    
    /// 
    func prismアニメーション演出(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("アニメーション演出"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismアニメーション演出(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("アニメーション演出"), value: [.var(v)])
    }
    
    /// 
    func prismサブタイトル(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("サブタイトル"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismサブタイトル(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("サブタイトル"), value: [.var(v)])
    }
    
    /// 
    func prismストーリーボード(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("ストーリーボード"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismストーリーボード(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("ストーリーボード"), value: [.var(v)])
    }
    
    /// 
    func prism作画監修(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("作画監修"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prism作画監修(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("作画監修"), value: [.var(v)])
    }
    
    /// 
    func prism放送日TXN(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("放送日(TXN)"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prism放送日TXN(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("放送日(TXN)"), value: [.var(v)])
    }
    
    /// 
    func prism演出(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("演出"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prism演出(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("演出"), value: [.var(v)])
    }
    
    /// 
    func prism絵コンテ(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("絵コンテ"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prism絵コンテ(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("絵コンテ"), value: [.var(v)])
    }
    
    /// 
    func prism脚本(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("脚本"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prism脚本(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("脚本"), value: [.var(v)])
    }
    
    /// 
    func prism話数(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("話数"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prism話数(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("話数"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismLive {
    /// 
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// 
    func prismLiveOfEpisode(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("liveOfEpisode"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismLiveOfEpisode(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("liveOfEpisode"), value: [.var(v)])
    }
    
    /// 
    func prismEnd(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("end"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismEnd(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("end"), value: [.var(v)])
    }
    
    /// 
    func prismPerformer(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performer"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismPerformer(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performer"), value: [.var(v)])
    }
    
    /// 
    func prismSongPerformed(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("songPerformed"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismSongPerformed(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("songPerformed"), value: [.var(v)])
    }
    
    /// 
    func prismStart(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("start"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismStart(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("start"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismSeries {
    /// 
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// 
    func prismHasEpisode(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("hasEpisode"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismHasEpisode(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("hasEpisode"), value: [.var(v)])
    }
    
    /// 
    func prismタイトル(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("タイトル"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismタイトル(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("タイトル"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismItem {
    /// 
    func rdfType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func rdfType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: RdfSchema.verb("type"), value: [.var(v)])
    }
    
    /// 
    func prismBrand(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("brand"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismBrand(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("brand"), value: [.var(v)])
    }
    
    /// 
    func prismCategory(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("category"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismCategory(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("category"), value: [.var(v)])
    }
    
    /// 
    func prismCollection_term(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("collection_term"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismCollection_term(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("collection_term"), value: [.var(v)])
    }
    
    /// 
    func prismColor(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("color"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismColor(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("color"), value: [.var(v)])
    }
    
    /// 
    func prismImage_num(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("image_num"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismImage_num(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("image_num"), value: [.var(v)])
    }
    
    /// 
    func prismItem_id(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("item_id"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismItem_id(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("item_id"), value: [.var(v)])
    }
    
    /// 
    func prismLike(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("like"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismLike(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("like"), value: [.var(v)])
    }
    
    /// 
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 
    func prismOutfit_id(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("outfit_id"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismOutfit_id(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("outfit_id"), value: [.var(v)])
    }
    
    /// 
    func prismRarity(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("rarity"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismRarity(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("rarity"), value: [.var(v)])
    }
    
    /// 
    func prismSeries_name(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("series_name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismSeries_name(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("series_name"), value: [.var(v)])
    }
    
    /// 
    func prismType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 
    func prismType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.var(v)])
    }
}