import Foundation

/// 还原番茄小说网页使用的 PUA 字体字符。
///
/// 番茄正文中的部分汉字会被替换为 Unicode 私有区字符，网页依靠
/// SourceHanSansSC 的子集字体显示真实字形；纯文本提取后则会变成方框。
/// 这两组字符集来自该网页字体的公开映射，未知字符会原样保留。
enum FanqieTextDecoder {
    private static let primaryCharset = Array(
        "D在主特家军然表场4要只v和?6别还g现儿岁??此象月3出战工相o男直失世F都平文什VO将真T那当?会立些u是十张学气大爱两命全后东性通被1它乐接而感车山公了常以何可话先pi叫轻M士w着变尔快l个说少色里安花远7难师放t报认面道S?克地度I好机U民写把万同水新没书电吃像斯5为y白几日教看但第加候作上拉住有法r事应位利你声身国问马女他Y比父xAHNsX边美对所金活回意到z从j知又内因点Q三定8Rb正或夫向德听更?得告并本q过记L让打f人就者去原满体做经K走如孩cG给使物?最笑部?员等受k行一条果动光门头见往自解成处天能于名其发总母的死手入路进心来h时力多开已许d至由很界n小与Z想代么分生口再妈望次西风种带J?实情才这?E我神格长觉间年眼无不亲关结0友信下却重己老2音字m呢明之前高PB目太e9起稜她也W用方子英每理便四数期中C外样a海们任"
    )

    private static let secondaryCharset = Array(
        "s?作口在他能并B士4U克才正们字声高全尔活者动其主报多望放hw次年?中3特于十入要男同G面分方K什再教本己结1等世N?说gu期Z外美M行给9文将两许张友0英应向像此白安少何打气常定间花见孩它直风数使道第水已女山解dP的通关性叫儿L妈问回神来S四望前国些OvlA心平自无军光代是好却c得种就意先立z子过Yj表么所接了名金受J满眼没部那m每车度可R斯经现门明V如走命y6E战很上f月西7长夫想话变海机x到W一成生信笑但父开内东马日小而后带以三几为认X死员目位之学远人音呢我q乐象重对个被别F也书稜D写还因家发时i或住德当ol比觉然吃去公a老亲情体太b万C电理?失力更拉物着原她工实色感记看出相路大你候2和?与p样新只便最不进Tr做格母总爱身师轻知往加从?天eH?听场由快边让把任8条头事至起点真手这难都界用法n处下又Q告地5kt岁有会果利民"
    )

    static func decode(_ text: String) -> String {
        var result = String()
        result.reserveCapacity(text.count)

        for scalar in text.unicodeScalars {
            let codePoint = Int(scalar.value)
            if let decoded = decodedCharacter(for: codePoint) {
                result.append(decoded)
            } else {
                result.unicodeScalars.append(scalar)
            }
        }

        return result
    }

    private static func decodedCharacter(for codePoint: Int) -> Character? {
        let primaryStart = 58_344
        if primaryStart <= codePoint {
            let index = codePoint - primaryStart
            if index >= 0 && index < primaryCharset.count,
               primaryCharset[index] != "?" {
                return primaryCharset[index]
            }
        }

        let secondaryStart = 58_345
        if secondaryStart <= codePoint {
            let index = codePoint - secondaryStart
            if index >= 0 && index < secondaryCharset.count,
               secondaryCharset[index] != "?" {
                return secondaryCharset[index]
            }
        }

        return nil
    }
}
