#!/usr/bin/env python3
from PIL import Image
import os, sys

base = os.path.dirname(os.path.abspath(__file__))

for fname in ['title_icon.png', 'gameover_icon.png']:
    path = os.path.join(base, 'Assets', 'Sprites', 'UI', fname)
    if os.path.exists(path):
        img = Image.open(path)
        has_alpha = img.mode in ('RGBA', 'LA') or ('transparency' in img.info)
        print(f'{fname}: mode={img.mode}, size={img.size}, transparent={has_alpha}')
    else:
        print(f'{fname}: NOT FOUND')

print()
print('=== Flower Sprites ===')
flowers_dir = os.path.join(base, 'Assets', 'Sprites', 'Flowers')
for f in sorted(os.listdir(flowers_dir)):
    if f.endswith('.png'):
        path = os.path.join(flowers_dir, f)
        img = Image.open(path)
        print(f'{f}: mode={img.mode}, size={img.size}')
