function demo_create_dummy_folders()
% 创建一个用于测试 summary_viewer_gui_bilingual 的示例文件夹结构
% Create a folder structure for testing summary_viewer_gui_bilingual

basePath = fullfile(pwd, 'DemoData');
tokenNames = {'user','session','task','rep'};

users = {'u001','u002'};
sessions = {'Morning','Evening'};
tasks = {'task1','task2'};
reps = {'r1','r2'};

% 创建子文件夹并放入占位图像
for i = 1:length(users)
    for j = 1:length(sessions)
        for k = 1:length(tasks)
            for m = 1:length(reps)
                folderName = sprintf('%s_%s_%s_%s', ...
                    users{i}, sessions{j}, tasks{k}, reps{m});
                folderPath = fullfile(basePath, folderName);
                mkdir(folderPath);

                % 写入一个小图像文件
                img = uint8(rand(100,100,3)*255);
                imwrite(img, fullfile(folderPath, 'image1.png'));
            end
        end
    end
end

disp(['Demo folders created under ', basePath]);
end
