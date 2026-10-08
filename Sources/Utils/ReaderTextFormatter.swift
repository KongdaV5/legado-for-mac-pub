import Foundation

/// 将书源正文转换成适合阅读器显示的纯文本。
///
/// 一些网页会用不换行空格代替段落间的 HTML 换行。SwiftSoup 的 `text()`
/// 会保留这些空格，直接交给 SwiftUI 的 `Text` 后就会出现截图中的横向空白。
/// 这里只整理空白，不改动正文字符或用户配置的替换规则。
enum ReaderTextFormatter {
    static func normalize(_ raw: String) -> String {
        guard !raw.isEmpty else { return raw }

        let normalized = raw
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{2007}", with: " ")
            .replacingOccurrences(of: "\u{202F}", with: " ")
            .replacingOccurrences(of: "\u{3000}", with: " ")
            .replacingOccurrences(of: "\u{200B}", with: "")

        var result = String()
        result.reserveCapacity(normalized.count)

        var whitespaceCount = 0
        var newlineCount = 0
        func appendPendingWhitespace() {
            guard whitespaceCount > 0 else {
                whitespaceCount = 0
                newlineCount = 0
                return
            }

            if result.isEmpty {
                whitespaceCount = 0
                newlineCount = 0
                return
            }

            if newlineCount > 0 {
                result.append(contentsOf: newlineCount > 1 ? "\n\n" : "\n")
            } else if whitespaceCount > 1 {
                // 源站常用多个空格/NBSP 表示段落边界。
                result.append(contentsOf: "\n\n")
            } else {
                // 单个空格保留，避免破坏章节标题、英文词组和 URL。
                result.append(contentsOf: " ")
            }

            whitespaceCount = 0
            newlineCount = 0
        }

        for scalar in normalized.unicodeScalars {
            if CharacterSet.whitespacesAndNewlines.contains(scalar) {
                whitespaceCount += 1
                if scalar == "\n" {
                    newlineCount += 1
                }
                continue
            }

            appendPendingWhitespace()
            result.unicodeScalars.append(scalar)
        }

        // 末尾空白不属于正文内容。
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        result = result.replacingOccurrences(
            of: "\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )
        return result
    }
}
