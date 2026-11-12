#!/usr/bin/env python
"""把 PDF 逐页渲染成 PNG，便于检查排版是否正常。

依赖：pip install pymupdf

用法：
    python pdf-preview.py 输入.pdf [输出目录] [--dpi 110]

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
    out_dir = None
    rest = argv[1:]
    i = 0
    while i < len(rest):
        arg = rest[i]
        if arg == "--dpi" and i + 1 < len(rest):
            dpi = int(rest[i + 1])
            i += 2
            continue
        if arg.startswith("--"):
            i += 1
            continue
        out_dir = Path(arg)
        i += 1

    doc = pymupdf.open(pdf_path)
    out_dir = out_dir or Path(tempfile.gettempdir())
    out_dir.mkdir(parents=True, exist_ok=True)

    for index, page in enumerate(doc, start=1):
        target = out_dir / f"{pdf_path.stem}-p{index}.png"
        page.get_pixmap(dpi=dpi).save(target)
        print(f"page {index}/{doc.page_count} -> {target}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
