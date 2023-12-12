%==========================================================================
% Enhanced File Update Example
% Authors: 米糊炒面 and ChatGPT
% Description: This MATLAB script demonstrates enhanced error handling by
% including separate try-catch blocks for file read/write and computation errors.
%==========================================================================

try
    % 设置文件路径
    progressFilePath = 'progress.txt';
    errorFilePath = 'error_log.txt';

    % 初始化文件读写计数器
    writeCounter = 0;

    % 设置每隔多少次迭代进行一次文件更新
    updateInterval = 1000;

    % 循环示例：假设这里是你的主要计算循环
    for i = 1:5000
        % 在这里执行一些计算任务

        % 假设在运算中可能发生错误
        if rand() < 0.01
            % 生成一个带随机字符后缀的文件名，防止覆盖
            errorFileName = ['error_log_' char(randi([65 90], 1, 1)) '.txt'];

            % 写入错误信息到文本文件
            fidError = fopen(errorFileName, 'w');
            fprintf(fidError, 'Error occurred during computation at iteration %d\n', i);
            fclose(fidError);

            % 显示错误信息
            disp('Computation error occurred. Error details saved to error log.');
            
            % 继续下一次迭代
            continue;
        end

        % 每隔一定迭代次数进行文件更新
        if mod(i, updateInterval) == 0
            try
                % 写入当前进度信息到文本文件
                fidProgress = fopen(progressFilePath, 'w');
                fprintf(fidProgress, 'Current Progress: %d iterations\n', i);
                fclose(fidProgress);

                % 更新文件读写计数器
                writeCounter = writeCounter + 1;
            catch progressException
                % 捕获文件写入异常
                disp('Error occurred during progress file write.');
                disp(progressException.message);
            end
        end
    end

    disp('Code execution completed successfully.');

catch computationException
    % 捕获运算异常
    disp('Error occurred during computation.');
    disp(computationException.message);

    % 转换异常信息为文本并输出到文件
    computationErrorMsg = getReport(computationException, 'extended', 'hyperlinks', 'on');
    fidComputationError = fopen('computation_error_log.txt', 'w');
    fprintf(fidComputationError, computationErrorMsg);
    fclose(fidComputationError);

end
