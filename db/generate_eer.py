from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

OUT = Path('db')
W, H = 2400, 1480
BG = '#f4f7fb'
INK = '#1d2935'
MUTED = '#687887'
TEAL = '#176e65'
LINE = '#64817e'
BORDER = '#d7e1e8'
WHITE = '#ffffff'

try:
    title_font = ImageFont.truetype(r'C:\Windows\Fonts\segoeuib.ttf', 42)
    sub_font = ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf', 20)
    head_font = ImageFont.truetype(r'C:\Windows\Fonts\segoeuib.ttf', 24)
    field_font = ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf', 19)
    small_font = ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf', 17)
    label_font = ImageFont.truetype(r'C:\Windows\Fonts\segoeuib.ttf', 16)
except OSError:
    title_font = head_font = field_font = sub_font = small_font = label_font = ImageFont.load_default()

img = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(img)
d.text((80, 36), 'ModelForge · Entity Relationship Diagram', font=title_font, fill=INK)
d.text((82, 91), 'Eight-table MySQL schema · PK primary key · FK foreign key · UQ unique', font=sub_font, fill=MUTED)

boxes = {
 'users': (80, 150, 470, [('PK','user_id INT'),('','name VARCHAR(80)'),('UQ','email VARCHAR(120)'),('','password_hash VARCHAR(255) NULL'),('','role VARCHAR(20) DEFAULT researcher')]),
 'projects': (660, 150, 470, [('PK','project_id INT'),('FK','owner_id INT → users'),('','title VARCHAR(120)'),('','created_on DATE DEFAULT CURRENT_DATE')]),
 'datasets': (1240, 150, 470, [('PK','dataset_id INT'),('FK','project_id INT → projects'),('','name VARCHAR(120)'),('','size_mb DECIMAL(12,2)'),('','format VARCHAR(20)')]),
 'gpu_nodes': (1820, 150, 470, [('PK','node_id INT'),('UQ','name VARCHAR(60)'),('','vram_gb INT'),('','status VARCHAR(15)')]),
 'experiments': (660, 560, 470, [('PK','experiment_id INT'),('FK','project_id INT → projects'),('FK?','dataset_id INT NULL → datasets'),('','title VARCHAR(140)')]),
 'runs': (1240, 560, 470, [('PK','run_id INT'),('FK','experiment_id INT → experiments'),('FK?','node_id INT NULL → gpu_nodes'),('','status VARCHAR(15)'),('','accuracy DECIMAL(5,4) NULL · 0..1'),('','loss DECIMAL(8,4) NULL'),('','vram_used_gb DECIMAL(6,2)'),('','started_at DATETIME'),('','ended_at DATETIME NULL')]),
 'metrics': (1240, 1110, 470, [('PK','metric_id INT'),('FK','run_id INT → runs'),('','epoch INT'),('','loss DECIMAL(8,4) NULL'),('','accuracy DECIMAL(5,4) NULL · 0..1')]),
 'audit_log': (1820, 1110, 470, [('PK','log_id INT'),('FK','run_id INT → runs'),('','old_status VARCHAR(15)'),('','new_status VARCHAR(15)'),('','changed_at DATETIME')]),
}
heights = {name: 58 + len(fields)*39 + 12 for name, (_,_,_,fields) in boxes.items()}

# Relationship connectors are drawn first so entity cards remain crisp.
def link(points, src_label, dst_label, relationship, src_pos, dst_pos, rel_pos):
    d.line(points, fill=LINE, width=4, joint='curve')
    d.ellipse((points[0][0]-6, points[0][1]-6, points[0][0]+6, points[0][1]+6), fill=TEAL)
    d.ellipse((points[-1][0]-6, points[-1][1]-6, points[-1][0]+6, points[-1][1]+6), fill=TEAL)
    d.text(src_pos, src_label, font=label_font, fill=TEAL)
    d.text(dst_pos, dst_label, font=label_font, fill=TEAL)
    d.text(rel_pos, relationship, font=small_font, fill=MUTED)

# users 1 -> many projects
link([(550,255),(660,255)], '1',( '0..*'), 'owns', (548,226),(664,226),(584,214))
# projects 1 -> many datasets
link([(1130,255),(1240,255)], '1','0..*','contains',(1129,226),(1244,226),(1158,214))
# projects 1 -> many experiments
link([(895,366),(895,560)], '1','0..*','has',(906,372),(906,529),(909,444))
# dataset optional on an experiment; one dataset may be reused by many experiments
link([(1320,399),(1200,470),(1130,585)], '0..*','0..1','supplies',(1310,405),(1080,570),(1160,458))
# experiments 1 -> many runs
link([(1130,690),(1240,690)], '1','0..*','produces',(1129,661),(1244,661),(1150,648))
# GPU node optional on a run; a node serves many runs
link([(1820,280),(1765,280),(1765,690),(1710,690)], '0..*','0..1','executes',(1822,251),(1662,661),(1770,465))
# runs 1 -> many metrics
link([(1475,1016),(1475,1110)], '1','0..*','records',(1482,1018),(1482,1085),(1490,1050))
# runs 1 -> many status audit entries
link([(1710,850),(1765,850),(1765,1190),(1820,1190)], '1','0..*','status history',(1694,821),(1822,1160),(1772,984))

for name, (x,y,w,fields) in boxes.items():
    h = heights[name]
    d.rounded_rectangle((x,y,x+w,y+h), radius=16, fill=WHITE, outline=BORDER, width=2)
    d.rounded_rectangle((x,y,x+w,y+58), radius=16, fill=TEAL)
    d.rectangle((x,y+40,x+w,y+58), fill=TEAL)
    d.text((x+20,y+14),name,font=head_font,fill=WHITE)
    yy=y+70
    for key,field in fields:
        if key:
            chip = key
            chip_color = '#d8eeea' if key.startswith('FK') else '#eaf0fb'
            d.rounded_rectangle((x+16,yy+2,x+72,yy+29),radius=7,fill=chip_color)
            d.text((x+27,yy+4),chip,font=label_font,fill=TEAL if key.startswith('FK') else '#405f91')
            field_x=x+88
        else:
            field_x=x+20
        d.text((field_x,yy+3),field,font=field_font,fill=INK)
        yy+=39

d.rounded_rectangle((80,1370,2290,1432),radius=12,fill='#e7f2f0')
d.text((102,1388),'Cardinality: 1 = exactly one · 0..* = zero or many · 0..1 = optional single reference',font=sub_font,fill=TEAL)

png=OUT/'eer_diagram.png'
pdf=OUT/'eer_diagram.pdf'
img.save(png,optimize=True)
img.save(pdf,'PDF',resolution=160.0)
print(f'Created {png} ({png.stat().st_size} bytes)')
print(f'Created {pdf} ({pdf.stat().st_size} bytes)')
