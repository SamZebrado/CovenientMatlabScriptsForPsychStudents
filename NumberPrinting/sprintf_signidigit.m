function formatted_str = sprintf_signidigit(number, signi_digit)
    % sprintf_signidigit - A function that formats a number with a specified number of significant digits.
    % sprintf_signidigit - 一个根据指定有效数字位数来格式化数字的函数。
    %
    % Syntax: formatted_str = sprintf_signidigit(number, signi_digit)
    % 用法: formatted_str = sprintf_signidigit(number, signi_digit)
    %
    % Inputs:
    %   number - The number to be formatted.
    %   number - 要格式化的数字。
    %   signi_digit - The number of significant digits to display.
    %   signi_digit - 显示的有效数字位数。
    %
    % Outputs:
    %   formatted_str - The formatted number as a string.
    %   formatted_str - 格式化后的数字作为字符串返回。

    % by Sam Zebrado with the help from ChatGPT

    % 检查是否提供了signi_digit
    if nargin < 2
        error('signi_digit is required'); % 抛出错误提示需要提供signi_digit
    end

    % 小数部分
    fractional_part = abs(number - floor(number));

    % 找到小数部分中第一个非零数字的位置
    if fractional_part == 0
        decimal_places = 0;
    else
        decimal_places = -floor(log10(fractional_part)) + (signi_digit - 1);
    end

    % 创建格式字符串
    format_str = sprintf('%%.%df', decimal_places);

    % 使用sprintf返回格式化后的字符串
    formatted_str = sprintf(format_str, number);
end
