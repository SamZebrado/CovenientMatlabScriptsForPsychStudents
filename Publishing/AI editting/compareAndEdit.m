% 函数功能：将两个文本文件的内容并排显示在同一个网页上。
% Function: Display the contents of two text files side by side on the same webpage.
% 作者(Author): ChatGPT & Sam Zebrado
% 日期(Date): Jan 14, 2024
function compareAndEdit(inputFile1, inputFile2, color1, color2)
    % 使用指定内容标记函数处理两个文件
    % Process both files using the specified content marking function
    markedText1 = markdownToHtmlWithColor(inputFile1, color1);
    markedText2 = markdownToHtmlWithColor(inputFile2, color2);

    % 创建一个新的HTML文件，用于并排显示这两个文本
    % Create a new HTML file to display these two texts side by side
    htmlContent = strcat('<html><body><table><tr><td>', markedText1, '</td><td>', markedText2, '</td></tr></table></body></html>');

    % 写入到一个新的HTML文件
    % Write to a new HTML file
    outputFile = 'comparison.html';
    fid = fopen(outputFile, 'w');
    fwrite(fid, htmlContent);
    fclose(fid);

    % 在Matlab内置的web浏览器中显示结果
    % Display the result in Matlab's built-in web browser
    web(['file://' pwd '/' outputFile], '-new');
end
