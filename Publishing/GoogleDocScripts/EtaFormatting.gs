/**
 * This function formats specific text in a Google Document. 
 * Specifically, it replaces occurrences of "ŋ2" with "ŋ" in italics and "2" in superscript.
 * 
 * References:
 * - Stack Overflow about Superscript: https://stackoverflow.com/questions/32532481/google-apps-script-find-all-occurrences-and-set-style
 * - Google Support about Italics (also including how to use Google App Scripts like this): https://support.google.com/docs/thread/194032686/find-and-replace-with-italics?hl=en
 *
 * 这个函数用于格式化Google文档中的特定文本。
 * 具体来说，它将“ŋ2”的出现替换为斜体的“ŋ”和上标的“2”。
 *
 * 参考资料：
 * - Stack Overflow关于上标: https://stackoverflow.com/questions/32532481/google-apps-script-find-all-occurrences-and-set-style
 * - Google 支持关于斜体（也包含了这种gs脚本的使用方法）: https://support.google.com/docs/thread/194032686/find-and-replace-with-italics?hl=en
 */
function EtaFormat() {
  // Get the active document
  var document = DocumentApp.getActiveDocument();
  // Get the body of the document
  var body = document.getBody();

  // Text to find and replace
  var searchText = "eta squared"; // 要查找和替换的文本
  var replacementText = "ŋ2"; // 替换文本

  // Find the first occurrence of the search text
  var foundElement = body.findText(searchText);

  while (foundElement !== null) {
    // Get the text element where the search text was found
    var foundText = foundElement.getElement();
    var startOffset = foundElement.getStartOffset();
    var endOffset = foundElement.getEndOffsetInclusive();

    // Replace the found text with the replacement text
    foundText.deleteText(startOffset, endOffset);
    foundText.insertText(startOffset, replacementText);

    // Apply italic format to "ŋ"
    foundText.setItalic(startOffset, startOffset, true);

    // Apply superscript format to "2"
    foundText.setTextAlignment(startOffset+1, startOffset+1, DocumentApp.TextAlignment.SUPERSCRIPT);
   
    // Find the next occurrence of the search text
    foundElement = body.findText(searchText, foundElement);
  }
}
