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

## 📁 文件夹命名规范 | Folder Naming Convention

默认使用正则表达式解析子文件夹名，例如：  
By default, folder names are parsed using a regex pattern like:

```
u001_Morning_task1_r1/
u001_Morning_task1_r2/
u002_Evening_task2_r1/
...
```

默认提取 4 个 token：  
The default tokens are:

- `user`: 用户 ID，例如 `u001`  
  `user`: User ID (e.g., `u001`)
- `session`: 实验场景，例如 `Morning`  
  `session`: Session label (e.g., `Morning`)
- `task`: 任务编号，例如 `task1`  
  `task`: Task number (e.g., `task1`)
- `rep`: 重复次数，例如 `r1`  
  `rep`: Repetition number (e.g., `r1`)

可在 GUI 内点击 “设置 Tokens” 按钮修改这些规则。  
You can modify these by clicking the "Token Settings" button in the GUI.

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

1. 启动程序后，修改左上角控件的路径为包含子文件夹的主目录。  
   After launching the program, set the path to the main directory containing your image subfolders.
2. 点击 `Apply Path` 自动提取子文件夹名并更新选项。  
   Click `Apply Path` to parse the folder names and update dropdown options.
3. 使用下拉菜单筛选，点击 `显示图像 / Show` 显示对应图像。  
   Use dropdowns to filter, then click `显示图像 / Show` to display the selected image.
4. 点击 `复制配置 / Copy` 可添加一个新的筛选控件并继承当前配置。  
   Click `复制配置 / Copy` to add a new filter block inheriting the current selection.
5. 点击 `设置 Tokens` 自定义 Token 名与解析正则。  
   Click `设置 Tokens` to customize token names and regex parsing rules.
6. 可保存当前配置为 JSON 或下次加载。  
   Save the current config to JSON for future reuse.

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
