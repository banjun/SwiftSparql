// generated by verbgen

fileprivate enum PrismSchema: IRIBaseProvider {
    static var base: IRIRef {return IRIRef(value: "https://prismdb.takanakahiko.me/prism-schema.ttl#")}
}

fileprivate enum RdfSchema: IRIBaseProvider {
    static var base: IRIRef {return IRIRef(value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#")}
}

fileprivate enum RdfsSchema: IRIBaseProvider {
    static var base: IRIRef {return IRIRef(value: "http://www.w3.org/2000/01/rdf-schema#")}
}

public struct PrismCharacter: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Character")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismCharacter() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismCharacter>> {return rdfType(is: PrismCharacter.self)}
}

public struct PrismSong: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Song")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismSong() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismSong>> {return rdfType(is: PrismSong.self)}
}

public struct PrismEpisode: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Episode")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismEpisode() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismEpisode>> {return rdfType(is: PrismEpisode.self)}
}

public struct PrismLive: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Live")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismLive() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismLive>> {return rdfType(is: PrismLive.self)}
}

public struct PrismSeries: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Series")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismSeries() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismSeries>> {return rdfType(is: PrismSeries.self)}
}

public struct PrismItem: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Item")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismItem() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismItem>> {return rdfType(is: PrismItem.self)}
}

public struct PrismShop: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Shop")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismShop() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismShop>> {return rdfType(is: PrismShop.self)}
}

public struct PrismTeam: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Team")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismTeam() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismTeam>> {return rdfType(is: PrismTeam.self)}
}

public struct PrismBrand: RDFTypeConvertible {
    public static var rdfType: IRIRef {return PrismSchema.rdfType("Brand")}
}

extension TripleBuilder where State: TripleBuilderStateIncompleteSubjectType {
    public func rdfTypeIsPrismBrand() -> TripleBuilder<TripleBuilderStateRDFTypeBound<PrismBrand>> {return rdfType(is: PrismBrand.self)}
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismCharacter {
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
    
    /// 誕生日: 誕生日
    func prismBirthday(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("birthday"), value: [.varOrTerm(.term(v))])
    }
    
    /// 誕生日: 誕生日
    func prismBirthday(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("birthday"), value: [.var(v)])
    }
    
    /// 血液型: 血液型
    func prismBlood_type(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("blood_type"), value: [.varOrTerm(.term(v))])
    }
    
    /// 血液型: 血液型
    func prismBlood_type(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("blood_type"), value: [.var(v)])
    }
    
    /// チャーム: チャーム
    func prismCharm(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("charm"), value: [.varOrTerm(.term(v))])
    }
    
    /// チャーム: チャーム
    func prismCharm(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("charm"), value: [.var(v)])
    }
    
    /// 声優: 声優
    func prismCv(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("cv"), value: [.varOrTerm(.term(v))])
    }
    
    /// 声優: 声優
    func prismCv(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("cv"), value: [.var(v)])
    }
    
    /// 好きなブランド: 好きなブランド
    func prismFavorite_brand(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("favorite_brand"), value: [.varOrTerm(.term(v))])
    }
    
    /// 好きなブランド: 好きなブランド
    func prismFavorite_brand(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("favorite_brand"), value: [.var(v)])
    }
    
    /// 好きな食べ物: 好きな食べ物
    func prismFavorite_food(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("favorite_food"), value: [.varOrTerm(.term(v))])
    }
    
    /// 好きな食べ物: 好きな食べ物
    func prismFavorite_food(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("favorite_food"), value: [.var(v)])
    }
    
    /// 身長(ch): 身長(ch)
    func prismHeight(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("height"), value: [.varOrTerm(.term(v))])
    }
    
    /// 身長(ch): 身長(ch)
    func prismHeight(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("height"), value: [.var(v)])
    }
    
    /// チームのメンバー: チームのメンバー
    func prismMemberOf(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("memberOf"), value: [.varOrTerm(.term(v))])
    }
    
    /// チームのメンバー: チームのメンバー
    func prismMemberOf(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("memberOf"), value: [.var(v)])
    }
    
    /// 名前: 名前
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前: 名前
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.var(v)])
    }
    
    /// 演者をしたライブ: 演者をしたライブ
    func prismPerformerIn(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performerIn"), value: [.varOrTerm(.term(v))])
    }
    
    /// 演者をしたライブ: 演者をしたライブ
    func prismPerformerIn(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performerIn"), value: [.var(v)])
    }
    
    /// タイプ: タイプ
    func prismType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// タイプ: タイプ
    func prismType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismSong {
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
    
    /// 名前: 名前
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前: 名前
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.var(v)])
    }
    
    /// performedInLive: performedInLive
    func prismPerformedInLive(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performedInLive"), value: [.varOrTerm(.term(v))])
    }
    
    /// performedInLive: performedInLive
    func prismPerformedInLive(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performedInLive"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismEpisode {
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
    
    /// シリーズ内のエピソード: シリーズ内のエピソード
    func prismEpisodeOfSeries(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("episodeOfSeries"), value: [.varOrTerm(.term(v))])
    }
    
    /// シリーズ内のエピソード: シリーズ内のエピソード
    func prismEpisodeOfSeries(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("episodeOfSeries"), value: [.var(v)])
    }
    
    /// livePerformed: livePerformed
    func prismLivePerformed(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("livePerformed"), value: [.varOrTerm(.term(v))])
    }
    
    /// livePerformed: livePerformed
    func prismLivePerformed(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("livePerformed"), value: [.var(v)])
    }
    
    /// あにてれ: あにてれ
    func prismあにてれ(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("あにてれ"), value: [.varOrTerm(.term(v))])
    }
    
    /// あにてれ: あにてれ
    func prismあにてれ(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("あにてれ"), value: [.var(v)])
    }
    
    /// アニメーション演出: アニメーション演出
    func prismアニメーション演出(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("アニメーション演出"), value: [.varOrTerm(.term(v))])
    }
    
    /// アニメーション演出: アニメーション演出
    func prismアニメーション演出(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("アニメーション演出"), value: [.var(v)])
    }
    
    /// サブタイトル: サブタイトル
    func prismサブタイトル(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("サブタイトル"), value: [.varOrTerm(.term(v))])
    }
    
    /// サブタイトル: サブタイトル
    func prismサブタイトル(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("サブタイトル"), value: [.var(v)])
    }
    
    /// ストーリーボード: ストーリーボード
    func prismストーリーボード(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("ストーリーボード"), value: [.varOrTerm(.term(v))])
    }
    
    /// ストーリーボード: ストーリーボード
    func prismストーリーボード(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("ストーリーボード"), value: [.var(v)])
    }
    
    /// 作画監修: 作画監修
    func prism作画監修(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("作画監修"), value: [.varOrTerm(.term(v))])
    }
    
    /// 作画監修: 作画監修
    func prism作画監修(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("作画監修"), value: [.var(v)])
    }
    
    /// 放送日(TXN): 放送日(TXN)
    func prism放送日TXN(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("放送日(TXN)"), value: [.varOrTerm(.term(v))])
    }
    
    /// 放送日(TXN): 放送日(TXN)
    func prism放送日TXN(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("放送日(TXN)"), value: [.var(v)])
    }
    
    /// 演出: 演出
    func prism演出(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("演出"), value: [.varOrTerm(.term(v))])
    }
    
    /// 演出: 演出
    func prism演出(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("演出"), value: [.var(v)])
    }
    
    /// 絵コンテ: 絵コンテ
    func prism絵コンテ(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("絵コンテ"), value: [.varOrTerm(.term(v))])
    }
    
    /// 絵コンテ: 絵コンテ
    func prism絵コンテ(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("絵コンテ"), value: [.var(v)])
    }
    
    /// 脚本: 脚本
    func prism脚本(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("脚本"), value: [.varOrTerm(.term(v))])
    }
    
    /// 脚本: 脚本
    func prism脚本(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("脚本"), value: [.var(v)])
    }
    
    /// 話数: 話数
    func prism話数(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("話数"), value: [.varOrTerm(.term(v))])
    }
    
    /// 話数: 話数
    func prism話数(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("話数"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismLive {
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
    
    /// 終了: 終了
    func prismEnd(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("end"), value: [.varOrTerm(.term(v))])
    }
    
    /// 終了: 終了
    func prismEnd(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("end"), value: [.var(v)])
    }
    
    /// エピソード内のライブ: エピソード内のライブ
    func prismLiveOfEpisode(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("liveOfEpisode"), value: [.varOrTerm(.term(v))])
    }
    
    /// エピソード内のライブ: エピソード内のライブ
    func prismLiveOfEpisode(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("liveOfEpisode"), value: [.var(v)])
    }
    
    /// 演者: 演者
    func prismPerformer(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performer"), value: [.varOrTerm(.term(v))])
    }
    
    /// 演者: 演者
    func prismPerformer(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performer"), value: [.var(v)])
    }
    
    /// ライブ内の曲: ライブ内の曲
    func prismSongPerformed(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("songPerformed"), value: [.varOrTerm(.term(v))])
    }
    
    /// ライブ内の曲: ライブ内の曲
    func prismSongPerformed(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("songPerformed"), value: [.var(v)])
    }
    
    /// 開始: 開始
    func prismStart(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("start"), value: [.varOrTerm(.term(v))])
    }
    
    /// 開始: 開始
    func prismStart(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("start"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismSeries {
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
    
    /// シリーズ内のエピソード: シリーズ内のエピソード
    func prismHasEpisode(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("hasEpisode"), value: [.varOrTerm(.term(v))])
    }
    
    /// シリーズ内のエピソード: シリーズ内のエピソード
    func prismHasEpisode(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("hasEpisode"), value: [.var(v)])
    }
    
    /// タイトル: タイトル
    func prismタイトル(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("タイトル"), value: [.varOrTerm(.term(v))])
    }
    
    /// タイトル: タイトル
    func prismタイトル(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("タイトル"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismItem {
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
    
    /// カテゴリー: カテゴリー
    func prismCategory(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("category"), value: [.varOrTerm(.term(v))])
    }
    
    /// カテゴリー: カテゴリー
    func prismCategory(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("category"), value: [.var(v)])
    }
    
    /// 色: 色
    func prismColor(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("color"), value: [.varOrTerm(.term(v))])
    }
    
    /// 色: 色
    func prismColor(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("color"), value: [.var(v)])
    }
    
    /// image_num: image_num
    func prismImage_num(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("image_num"), value: [.varOrTerm(.term(v))])
    }
    
    /// image_num: image_num
    func prismImage_num(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("image_num"), value: [.var(v)])
    }
    
    /// アイテムID: アイテムID
    func prismItem_id(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("item_id"), value: [.varOrTerm(.term(v))])
    }
    
    /// アイテムID: アイテムID
    func prismItem_id(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("item_id"), value: [.var(v)])
    }
    
    /// アイテムのブランド
    func prismItem_of(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("item_of"), value: [.varOrTerm(.term(v))])
    }
    
    /// アイテムのブランド
    func prismItem_of(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("item_of"), value: [.var(v)])
    }
    
    /// いいね: いいね
    func prismLike(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("like"), value: [.varOrTerm(.term(v))])
    }
    
    /// いいね: いいね
    func prismLike(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("like"), value: [.var(v)])
    }
    
    /// 名前: 名前
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前: 名前
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// outfit_id: outfit_id
    func prismOutfit_id(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("outfit_id"), value: [.varOrTerm(.term(v))])
    }
    
    /// outfit_id: outfit_id
    func prismOutfit_id(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("outfit_id"), value: [.var(v)])
    }
    
    /// レアリティ: レアリティ
    func prismRarity(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("rarity"), value: [.varOrTerm(.term(v))])
    }
    
    /// レアリティ: レアリティ
    func prismRarity(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("rarity"), value: [.var(v)])
    }
    
    /// シリーズ名: シリーズ名
    func prismSeries_name(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("series_name"), value: [.varOrTerm(.term(v))])
    }
    
    /// シリーズ名: シリーズ名
    func prismSeries_name(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("series_name"), value: [.var(v)])
    }
    
    /// 終了日: 終了日
    func prismTerm_end(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("term_end"), value: [.varOrTerm(.term(v))])
    }
    
    /// 終了日: 終了日
    func prismTerm_end(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("term_end"), value: [.var(v)])
    }
    
    /// 開始日: 開始日
    func prismTerm_start(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("term_start"), value: [.varOrTerm(.term(v))])
    }
    
    /// 開始日: 開始日
    func prismTerm_start(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("term_start"), value: [.var(v)])
    }
    
    /// タイプ: タイプ
    func prismType(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.varOrTerm(.term(v))])
    }
    
    /// タイプ: タイプ
    func prismType(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("type"), value: [.var(v)])
    }
    
    /// volume: volume
    func prismVolume(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("volume"), value: [.varOrTerm(.term(v))])
    }
    
    /// volume: volume
    func prismVolume(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("volume"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismShop {
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
    
    /// 住所: 住所
    func prismAddress(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("address"), value: [.varOrTerm(.term(v))])
    }
    
    /// 住所: 住所
    func prismAddress(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("address"), value: [.var(v)])
    }
    
    /// グループ: グループ
    func prismGroup(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("group"), value: [.varOrTerm(.term(v))])
    }
    
    /// グループ: グループ
    func prismGroup(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("group"), value: [.var(v)])
    }
    
    /// 緯度: 緯度
    func prismLatitude(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("latitude"), value: [.varOrTerm(.term(v))])
    }
    
    /// 緯度: 緯度
    func prismLatitude(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("latitude"), value: [.var(v)])
    }
    
    /// 経度: 経度
    func prismLongitude(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("longitude"), value: [.varOrTerm(.term(v))])
    }
    
    /// 経度: 経度
    func prismLongitude(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("longitude"), value: [.var(v)])
    }
    
    /// 名前: 名前
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前: 名前
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 都道府県: 都道府県
    func prismPrefecture(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("prefecture"), value: [.varOrTerm(.term(v))])
    }
    
    /// 都道府県: 都道府県
    func prismPrefecture(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("prefecture"), value: [.var(v)])
    }
    
    /// シリーズ: シリーズ
    func prismSeries(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("series"), value: [.varOrTerm(.term(v))])
    }
    
    /// シリーズ: シリーズ
    func prismSeries(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("series"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismTeam {
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
    
    /// メンバー: メンバー
    func prismMember(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("member"), value: [.varOrTerm(.term(v))])
    }
    
    /// メンバー: メンバー
    func prismMember(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("member"), value: [.var(v)])
    }
    
    /// 名前: 名前
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前: 名前
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.var(v)])
    }
    
    /// 演者をしたライブ: 演者をしたライブ
    func prismPerformerIn(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performerIn"), value: [.varOrTerm(.term(v))])
    }
    
    /// 演者をしたライブ: 演者をしたライブ
    func prismPerformerIn(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("performerIn"), value: [.var(v)])
    }
}

public extension TripleBuilder where State: TripleBuilderStateRDFTypeBoundType, State.RDFType == PrismBrand {
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
    
    /// ブランドのアイテム
    func prismBrand_item(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("brand_item"), value: [.varOrTerm(.term(v))])
    }
    
    /// ブランドのアイテム
    func prismBrand_item(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("brand_item"), value: [.var(v)])
    }
    
    /// 名前: 名前
    func prismName(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前: 名前
    func prismName(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name"), value: [.var(v)])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前(かな): 名前(かな)
    func prismName_kana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_kana"), value: [.var(v)])
    }
    
    /// 名前(カタカナ): 名前(カタカナ)
    func prismName_katakana(is v: GraphTerm) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_katakana"), value: [.varOrTerm(.term(v))])
    }
    
    /// 名前(カタカナ): 名前(カタカナ)
    func prismName_katakana(is v: Var) -> TripleBuilder<State> {
        return appended(verb: PrismSchema.verb("name_katakana"), value: [.var(v)])
    }
}