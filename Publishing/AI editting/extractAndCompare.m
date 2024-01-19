% 函数功能：提取并对比两个文件中的指定文本。
% Function: Extract and compare specified text in two files.
% 作者(Author): ChatGPT & Sam Zebrado
% 日期(Date): Jan 14, 2024
function extractAndCompare(inputFile1, inputFile2, regexPattern)
    % 提取文本
    % Extract text
    texts1 = extractTexts(inputFile1, regexPattern);
    texts2 = extractTexts(inputFile2, regexPattern);

    % 对比文本
    % Compare text
    comparison = [texts1, texts2, strcmp(texts1, texts2)];

    % 显示结果
    % Display results
    disp(array2table(comparison, 'VariableNames', {'Texts_File1', 'Texts_File2', 'IsEqual'}));
end

function texts = extractTexts(inputFile, regexPattern)
    % 读取文件并提取文本
    % Read the file and extract text
    fid = fopen(inputFile, 'r');
    text = fread(fid, '*char')';
    fclose(fid);
    texts = regexp(text, regexPattern, 'match');
end
