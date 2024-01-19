% 函数功能：将Markdown文本转换为HTML，并对数字和特定模式的文字进行颜色标记。
% Function: Convert Markdown text to HTML and color-code numbers and specific patterns of text.
% 作者(Author): ChatGPT & Sam Zebrado
% 日期(Date): Jan 14, 2024
function htmlText = markdownToHtmlWithColor(inputFile, color)
    % 读取Markdown文件
    % Read the Markdown file
    fid = fopen(inputFile, 'r');
    markdownText = fread(fid, '*char')';
    fclose(fid);

    % 简单的Markdown到HTML转换（仅添加<p>标签）
    % Simple Markdown to HTML conversion (just adding <p> tags)
    htmlText = ['<p>' strrep(markdownText, newline, '<br>') '</p>'];

    % 使用正则表达式标记数字和特定模式的文字
    % Use regex to color-code numbers and specific patterns
    htmlText = regexprep(htmlText, '(\d+\.\d+)', ['<span style="color:' color ';">$1</span>']);
    % Add more regex rules as needed
end
