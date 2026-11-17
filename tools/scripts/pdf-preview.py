#!/usr/bin/env python
"""把 PDF 渲染成 PNG：既可逐页预览排版，也可单页导出成一张图片。

依赖：pip install pymupdf

用法：
    python pdf-preview.py 输入.pdf [输出目录] [--dpi 110]        # 逐页导出
    python pdf-preview.py 输入.pdf --page 1 --dpi 200 --out 图片.png  # 单页导出为指定文件

输出目录默认为系统临时目录，文件名形如 输入-p1.png、输入-p2.png。
"""
import sys
import tempfile
from pathlib import Path

import pymupdf


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 1

    pdf_path = Path(argv[0])
    dpi = 110
    page_no = None
    out_file = None
    out_dir = None

    rest = argv[1:]
    i = 0
    while i < len(rest):
        arg = rest[i]
        if arg == "--dpi" and i + 1 < len(rest):
            dpi = int(rest[i + 1])
            i += 2
            continue
        if arg == "--page" and i + 1 < len(rest):
            page_no = int(rest[i + 1])
            i += 2
            continue
        if arg == "--out" and i + 1 < len(rest):
            out_file = Path(rest[i + 1])
            i += 2
            continue
        if arg.startswith("--"):
            i += 1
            continue
        out_dir = Path(arg)
        i += 1

    doc = pymupdf.open(pdf_path)

    def render(index: int, target: Path) -> None:
        target.parent.mkdir(parents=True, exist_ok=True)
        doc[index - 1].get_pixmap(dpi=dpi).save(target)
        print(f"page {index}/{doc.page_count} -> {target}")

    # 单页导出到指定文件
    if out_file is not None:
        render(page_no or 1, out_file)
        return 0

    out_dir = out_dir or Path(tempfile.gettempdir())
    out_dir.mkdir(parents=True, exist_ok=True)

    pages = [page_no] if page_no else range(1, doc.page_count + 1)
    for index in pages:
        render(index, out_dir / f"{pdf_path.stem}-p{index}.png")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
