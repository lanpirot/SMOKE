import glob
import os
import re
from collections import Counter

#adapt next line to where your model collection is
directory = r'C:\tmp\obfmodels'
#models must be in .mdl format!
#comment out lines 24+25 if you don't have the obfuscated models of our scripts but your own



file_pattern = os.path.join(directory, '*.mdl')
files = glob.glob(file_pattern)

pattern = r'<P Name="(.*?)".*>(.*?)</P>'
btpattern = r'<Block BlockType="(.*?)" Name=".*" SID=".*">'

total_matches = dict()
btmatches = set()

print("This computation might take a while...")

for file in files:
    if "_obf" in file:
        continue
    with open(file, 'r', encoding='utf-8', errors='replace') as mdl_file:
        content = mdl_file.read()
        matches = re.findall(pattern, content)
        btmatches = btmatches.union(set(re.findall(btpattern, content)))
        for m in matches:
            if m[0] not in total_matches:
                total_matches[m[0]] = [m[1]]
            else:
                total_matches[m[0]] += [m[1]]
                            

potential_param = 0

for rm in total_matches:
    counts = Counter(total_matches[rm])
    counts = [c for c in counts if counts[c] == 1]
    if len(counts) > 10:
        potential_param += 1
        print(f"{rm}:   {sorted(counts, key=len)[-3:]}")

print(f"We found {len(total_matches)} unique Parameters overall. {potential_param} of them are candidates that could hold custom useful information.")
print(f"We found {len(btmatches)} unique BlockTypes.")

