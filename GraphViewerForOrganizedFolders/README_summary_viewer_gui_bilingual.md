# 📊 summary_viewer_gui_bilingual

> 多条件筛选图像浏览工具（中英双语 GUI）  
> A bilingual MATLAB GUI for viewing images with condition-based filtering

---

## ✨ 简介 | Introduction

`summary_viewer_gui_bilingual` 是一个用于批量查看实验图像的交互式 GUI 工具，支持按多种条件（如参与者 ID、环境类型、任务编号等）进行筛选和切换。  
`summary_viewer_gui_bilingual` is an interactive GUI tool for batch browsing of experimental images with customizable filters like participant ID, environment, task index, etc.

它支持分页浏览、多配置并行显示、配置保存与加载、自定义 Token 格式等功能，适合用于行为实验、计算机视觉、心理物理等图像数据管理与展示任务。  
It supports paginated layout, side-by-side comparisons, saving/loading configurations, and custom token formats — ideal for behavioral experiments, computer vision, and psychophysics.


---

## 💼 使用场景举例 / Example Use Case

适用于具有统一命名规则的图像数据，例如以下结构：  
Suitable for data organized with consistent naming conventions like:

```
/Data/
├── S01_Day_Morning_g1/
│   ├── img1.png
│   ├── img2.png
├── S01_Night_Morning_g1/
│   ├── img1.png
│   ├── img2.png
├── S02_Day_Evening_g2/
│   ├── img1.png
│   ├── img2.png
```

你可以设置如下字段名和正则表达式：  
You may set token names and regex like:

```matlab
Token Names: {'subject','phase','time','gain'}
Regex:       ^(S\d+)_(\w+)_(\w+)_g(\d+)$
```

程序将识别所有符合规则的子文件夹，并允许你选择任意字段组合查看 `img1.png`。  
The GUI will detect all valid folders and let you view `img1.png` across matching token values.

配置文件支持将字段选择和文件名保存为 `.json`，方便后续加载和复现配置。  
Configurations including token selections and filenames can be saved to `.json` and later restored.

## 📌 注意事项 / Notes

- 图像需放在子文件夹中，子文件夹名需符合设定的正则表达式。
- 图片默认支持 `.png` 格式，可在代码中扩展为 `.jpg`、`.bmp` 等。
- 保存的默认 Token 设置保存在 `token_config.mat` 中。

---
## 🧪 示例结构 | Demo Structure

你可以运行以下脚本自动创建一个测试用的文件夹结构：  
You can run the following script to generate a demo folder structure for testing:

```matlab
demo_create_dummy_folders
```

它将在当前目录下创建一个名为 `DemoData/` 的文件夹，其中包含若干个符合命名规则的子文件夹及测试图像。  
It will create a folder named `DemoData/` containing several subfolders with test images that match the expected naming format.

---

## 🚀 使用方法 | How to Use

```matlab
summary_viewer_gui_bilingual
```

1. 启动函数  
   Run the function:

   ```matlab
   summary_viewer_gui_bilingual
   ```

2. 输入根目录路径  
   Enter your root folder path in the path field.

3. 点击 `Apply Path`  
   解析文件夹名并更新下拉菜单与图像文件。

4. 在下拉菜单中选择字段  
   Select token values from dropdowns.

5. 在右侧选择图像文件  
   Choose a file from the right file list.

6. 点击 `显示图像 / Show`  
   View the selected image.

7. 可使用 `复制配置 / Copy` 添加右侧新控件，进行配置对比。  
   Use `Copy` to create a duplicated control block to compare settings.

8. 点击顶部 `保存配置 / Save` 可保存当前所有控件状态为 JSON。  
   Save all panel settings using the `Save` button.

9. 点击 `加载配置 / Load` 可从 JSON 恢复先前设置。  
   Load previously saved settings using the `Load` button.

10. 使用 `设置 Tokens / Token Settings` 设定正则表达式与字段名，并可设为默认。  
   Customize and persist regex + token settings using `Token Settings`.
---

## 🧩 功能列表 | Feature Highlights

- ✅ 多组图像配置并列显示  
  Display multiple image panels side-by-side
- ✅ 支持 Token 自定义与保存默认  
  Customizable token names and patterns with default persistence
- ✅ 分页浏览所有控件组  
  Paginated layout for browsing many controls
- ✅ JSON 配置导入导出  
  Save and load configuration as JSON
- ✅ 显示图像并高亮当前路径  
  Image display with annotation of full path
- ✅ 一键复制控件配置并右移  
  Duplicate control block and shift others right

---

## 📌 技术要求 | Requirements

- MATLAB R2018b 或以上  
  MATLAB R2018b or later
- 建议使用 1080p 或更高分辨率显示器  
  Recommended: 1080p or higher resolution

---

## 📁 文件说明 | File List

| 文件名 | 功能 |
|--------|------|
| `summary_viewer_gui_bilingual.m` | 主程序（图像浏览 GUI）<br>Main GUI script |
| `demo_create_dummy_folders.m` | 示例生成脚本（可选）<br>Demo folder creator (optional) |

---

## 👤 作者 | Author

Captain Sam

---

## 📝 许可协议 | License

MIT License. 欢迎自由使用与修改。  
MIT License. Free to use and modify.
