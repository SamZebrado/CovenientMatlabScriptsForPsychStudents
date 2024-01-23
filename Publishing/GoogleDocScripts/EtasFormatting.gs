/**
 * This function formats specific text in a Google Document. 
 * It replaces occurrences of "etas squared" with "ŋ2s", where "ŋ" is in italics, "2" is in superscript, and "s" is in normal text.
 * 
 * References:
 * - Stack Overflow about Superscript: https://stackoverflow.com/questions/32532481/google-apps-script-find-all-occurrences-and-set-style
 * - Google Support about Italics (also including how to use Google App Scripts like this): https://support.google.com/docs/thread/194032686/find-and-replace-with-italics?hl=en
 *
 * Authors: ChatGPT, Sam Zebrado
 *
 * 这个函数用于格式化Google文档中的特定文本。
 * 它将“etas squared”的出现替换为“ŋ2s”，其中“ŋ”为斜体，“2”为上标，“s”为正常文本。
 *
 * 参考资料：
 * - Stack Overflow关于上标: https://stackoverflow.com/questions/32532481/google-apps-script-find-all-occurrences-and-set-style
 * - Google 支持关于斜体（也包含了这种gs脚本的使用方法）: https://support.google.com/docs/thread/194032686/find-and-replace-with-italics?hl=en
 *
 * 作者：ChatGPT, Sam Zebrado
 */
function EtaSFormat() {
  var document = DocumentApp.getActiveDocument();
  var body = document.getBody();
  var searchText = "etas squared"; // 要查找和替换的文本
  var replacementText = "ŋ2s"; // 替换文本

  var foundElement = body.findText(searchText);

  while (foundElement !== null) {
    var foundText = foundElement.getElement();
    var startOffset = foundElement.getStartOffset();
    var endOffset = foundElement.getEndOffsetInclusive();

    // Replace the found text with the replacement text
    foundText.deleteText(startOffset, endOffset);
    foundText.insertText(startOffset, replacementText);

    // Apply italic format to "ŋ"
    foundText.setItalic(startOffset, startOffset, true);

    // Apply superscript to "2"
    foundText.setTextAlignment(startOffset+1, startOffset+1, DocumentApp.TextAlignment.SUPERSCRIPT);
    // The 's' should be in normal text format
    foundText.setItalic(startOffset+2, startOffset+2, false);

    // Find the next occurrence of the search text
    foundElement = body.findText(searchText, foundElement);
  }
}
