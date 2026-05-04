import os
import re

base_path = r"D:\code\projects\github\wuw111.github.io"

files_to_fix = {
    "version.html": {
        "add_after": '<div class="version-info">',
        "insert": '<div class="home-nav">\n    <a href="index.html" class="home-link">← 返回主页</a>\n    <a href="version_en.html" class="home-link" style="margin-left:10px;">🌐 English</a>\n</div>\n\n    ',
        "replace": []
    },
    "version_en.html": {
        "add_after": '<div class="version-info">',
        "insert": '<div class="home-nav">\n    <a href="index_en.html" class="home-link">← Back to Home</a>\n    <a href="version.html" class="home-link" style="margin-left:10px;">🌐 简体中文</a>\n</div>\n\n    ',
        "replace": []
    },
    "about.html": {
        "add_after": None,
        "insert": None,
        "replace": [
            [
                '<div class="home-nav">\n        <a href="index.html" class="home-link">← 返回主页</a>\n    </div>',
                '<div class="home-nav">\n        <a href="index.html" class="home-link">← 返回主页</a>\n        <a href="about_en.html" class="home-link" style="margin-left:10px;">🌐 English</a>\n    </div>'
            ]
        ]
    },
    "about_en.html": {
        "add_after": None,
        "insert": None,
        "replace": [
            [
                '<div class="home-nav">\n        <a href="index_en.html" class="home-link">← Back to Home</a>\n    </div>',
                '<div class="home-nav">\n        <a href="index_en.html" class="home-link">← Back to Home</a>\n        <a href="about.html" class="home-link" style="margin-left:10px;">🌐 简体中文</a>\n    </div>'
            ]
        ]
    },
    "join.html": {
        "add_after": '<body class="join-page">',
        "insert": '\n<div style="text-align:center;padding:20px 0 0;">\n    <a href="index.html" style="display:inline-block;padding:8px 20px;background-color:#f0f7ff;color:#4a90e2;text-decoration:none;border-radius:20px;font-weight:500;border:1px solid #d0e3ff;margin-right:10px;">← 返回主页</a>\n    <a href="join_en.html" style="display:inline-block;padding:8px 20px;background-color:#f0f7ff;color:#4a90e2;text-decoration:none;border-radius:20px;font-weight:500;border:1px solid #d0e3ff;">🌐 English</a>\n</div>\n',
        "replace": []
    },
    "join_en.html": {
        "add_after": '<body class="join-page">',
        "insert": '\n<div style="text-align:center;padding:20px 0 0;">\n    <a href="index_en.html" style="display:inline-block;padding:8px 20px;background-color:#f0f7ff;color:#4a90e2;text-decoration:none;border-radius:20px;font-weight:500;border:1px solid #d0e3ff;margin-right:10px;">← Back to Home</a>\n    <a href="join.html" style="display:inline-block;padding:8px 20px;background-color:#f0f7ff;color:#4a90e2;text-decoration:none;border-radius:20px;font-weight:500;border:1px solid #d0e3ff;">🌐 简体中文</a>\n</div>\n',
        "replace": []
    },
    "announces.html": {
        "add_after": None,
        "insert": None,
        "replace": [
            [
                '<a href="index.html" class="back-link">返回首页</a>',
                '<a href="index.html" class="back-link">返回首页</a>\n            <a href="announces_en.html" class="back-link">🌐 English</a>'
            ]
        ]
    },
    "announces_en.html": {
        "add_after": None,
        "insert": None,
        "replace": [
            [
                '<a href="index_en.html" class="back-link">Back to Home</a>',
                '<a href="index_en.html" class="back-link">Back to Home</a>\n            <a href="announces.html" class="back-link">🌐 简体中文</a>'
            ]
        ]
    },
}

for filename, config in files_to_fix.items():
    filepath = os.path.join(base_path, filename)
    if not os.path.exists(filepath):
        print(f"Not found: {filename}")
        continue

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    if config["add_after"] and config["insert"]:
        content = content.replace(config["add_after"], config["add_after"] + config["insert"], 1)

    for old, new in config["replace"]:
        content = content.replace(old, new)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filename}")
    else:
        print(f"Skipped: {filename} (no change)")

print("\nAll language switches added!")