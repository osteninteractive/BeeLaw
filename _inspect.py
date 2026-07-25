#!/usr/bin/env python3
with open('Scenes/Assemblee/AssembleeScreen.gd', 'rb') as f:
    lines = f.read().split(b'\n')
print("=== Lines 67-125 (orphan code) ===")
for i in range(66, 125):
    line = lines[i-1] if i <= len(lines) else b''
    tabs = len(line) - len(line.lstrip(b'\t'))
    print(f'L{i:3d} | tabs={tabs} | {line.decode("utf-8", "replace")[:120]}')

print("\n=== Lines 195-213 (_refresh_cards raw) ===")
for i in range(195, 214):
    line = lines[i-1] if i <= len(lines) else b''
    print(f'L{i:3d} | {line!r}')
