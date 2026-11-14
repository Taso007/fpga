"""Create the printable report from REPORT.md and real captured evidence."""
from pathlib import Path
from html import escape
import re
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table, Flowable,
                               TableStyle, Image, KeepTogether, PageBreak)
from PIL import Image as PILImage

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/pdf/CLU_Technical_Report.pdf"
WIDTH = A4[0] - 86
STYLES = getSampleStyleSheet()
STYLES.add(ParagraphStyle("ReportTitle", fontName="Helvetica-Bold", fontSize=23,
                         leading=28, textColor=colors.HexColor("#17364e"), spaceAfter=18))
STYLES.add(ParagraphStyle("ReportBody", fontName="Helvetica", fontSize=9.6,
                         leading=14, spaceAfter=7))
STYLES.add(ParagraphStyle("ReportH2", fontName="Helvetica-Bold", fontSize=14,
                         leading=18, spaceBefore=15, spaceAfter=9, keepWithNext=True,
                         textColor=colors.HexColor("#17364e")))
STYLES.add(ParagraphStyle("ReportH3", parent=STYLES["ReportH2"], fontSize=11,
                         leading=15, spaceBefore=10))
STYLES.add(ParagraphStyle("ReportCell", parent=STYLES["ReportBody"], fontSize=8,
                         leading=11, spaceAfter=0))
STYLES.add(ParagraphStyle("ReportCaption", parent=STYLES["ReportBody"], fontSize=8,
                         leading=11, textColor=colors.HexColor("#52637a"), spaceAfter=11))
STYLES.add(ParagraphStyle("ReportNotice", parent=STYLES["ReportBody"], backColor=colors.HexColor("#fff2d0"),
                         borderPadding=9, spaceBefore=5, spaceAfter=13))


def inline(text):
    text = escape(text)
    text = re.sub(r"`([^`]+)`", r'<font name="Courier">\1</font>', text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<i>\1</i>", text)
    text = re.sub(r"\[([^]]+)\]\(([^)]+)\)", r"\1", text)
    return text


class RotatedImage(Flowable):
    def __init__(self, source, width, height):
        super().__init__()
        self.source = str(source)
        self.width = width
        self.height = height
        self.hAlign = "CENTER"

    def draw(self):
        self.canv.saveState()
        self.canv.translate(self.width, 0)
        self.canv.rotate(90)
        self.canv.drawImage(self.source, 0, 0, width=self.height, height=self.width)
        self.canv.restoreState()


def figure(source, alt):
    source = (ROOT / "docs" / source).resolve()
    if source.suffix.lower() == ".svg":
        # Keep the SVG for the editable HTML, use the equivalent code-drawn PNG in PDF.
        source = source.with_suffix(".png")
    with PILImage.open(source) as im:
        w, h = im.size
    rotate = source.name == "B.jpg" and h > w
    if rotate:
        w, h = h, w
    display_width = min(WIDTH, w * 0.75)
    display_height = display_width * h / w
    max_height = 210 if source.name in {"A.jpg", "B.jpg", "OP.jpg"} else 455
    if display_height > max_height:
        display_width *= max_height / display_height
        display_height = max_height
    picture = (RotatedImage(source, display_width, display_height) if rotate
               else Image(str(source), width=display_width, height=display_height))
    return KeepTogether([Spacer(1, 5), picture,
                         Paragraph(inline(alt), STYLES["ReportCaption"])])


def table(lines):
    rows = [[x.strip() for x in line.strip().strip("|").split("|")]
            for line in lines if not re.match(r"^\|\s*:?-+", line)]
    count = len(rows[0])
    if count == 4 and rows[0][0] == "OP":
        widths = [32, 95, 255, WIDTH - 382]
    elif count == 2:
        widths = [WIDTH * 0.40, WIDTH * 0.60]
    elif count == 3:
        widths = [WIDTH * 0.27, WIDTH * 0.43, WIDTH * 0.30]
    else:
        widths = [WIDTH / count] * count
    data = [[Paragraph(inline(cell), STYLES["ReportCell"]) for cell in row] for row in rows]
    result = Table(data, colWidths=widths, repeatRows=1, hAlign="LEFT", splitByRow=0)
    result.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e5edf6")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#ccd8e5")),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#f6f8fb")])]))
    return [Spacer(1, 6), result, Spacer(1, 9)]


def footer(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#60718a"))
    canvas.drawString(43, 27, "C5G Combinational Logic Unit")
    canvas.drawRightString(A4[0] - 43, 27, str(doc.page))
    canvas.restoreState()


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    report_text = (ROOT / "docs/REPORT.md").read_text(encoding="utf-8")
    lines = report_text.splitlines()
    student = re.search(r"^\*\*Student:\*\*\s*(.+)$", report_text, re.M)
    story = []
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        if line == "<!-- pagebreak -->":
            story.append(PageBreak())
        elif line.startswith("# "):
            story.append(Paragraph(inline(line[2:]), STYLES["ReportTitle"]))
        elif line.startswith("## "):
            story.append(Paragraph(inline(line[3:]), STYLES["ReportH2"]))
        elif line.startswith("### "):
            story.append(Paragraph(inline(line[4:]), STYLES["ReportH3"]))
        elif line.startswith("|"):
            block = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                block.append(lines[i].strip())
                i += 1
            story.extend(table(block))
            continue
        elif re.match(r"!\[([^]]+)\]\(([^)]+)\)", line):
            alt, path = re.match(r"!\[([^]]+)\]\(([^)]+)\)", line).groups()
            story.append(figure(path, alt))
        elif line.startswith(">"):
            block = []
            while i < len(lines) and lines[i].strip().startswith(">"):
                block.append(lines[i].strip()[1:].strip())
                i += 1
            story.append(Paragraph(inline(" ".join(block)), STYLES["ReportNotice"]))
            continue
        elif line.startswith("- "):
            story.append(Paragraph("&#8226; " + inline(line[2:]), STYLES["ReportBody"]))
        elif re.match(r"^\d+\. ", line):
            block = [line]
            while i + 1 < len(lines) and lines[i + 1].strip() and not re.match(
                r"^(#|\||!\[|>|- |\d+\. |<!--)", lines[i + 1].strip()):
                i += 1
                block.append(lines[i].strip())
            story.append(Paragraph(inline(" ".join(block)), STYLES["ReportBody"]))
        else:
            block = [line]
            while i + 1 < len(lines) and lines[i + 1].strip() and not re.match(
                r"^(#|\||!\[|>|- |\d+\. |<!--)", lines[i + 1].strip()):
                if lines[i].endswith("  "):
                    break
                i += 1
                block.append(lines[i].strip())
            story.append(Paragraph(inline(" ".join(block)), STYLES["ReportBody"]))
        i += 1
    doc = SimpleDocTemplate(str(OUT), pagesize=A4, rightMargin=43, leftMargin=43,
                            topMargin=39, bottomMargin=43,
                            title="Design and Verification of an Eight Bit Combinational Logic Unit",
                            author=student.group(1).strip() if student else "")
    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    print(OUT)


if __name__ == "__main__":
    main()
