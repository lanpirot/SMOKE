import glob
import os
import re
from collections import Counter

directory = r'C:\tmp\obfmodels'
file_pattern = os.path.join(directory, '*.mdl')
files = glob.glob(file_pattern)

pattern = r'        <P Name="(.*?)".*>(.*?)</P>'

total_matches = dict()

print("This computation might take a while...")

for file in files:
    if "_obf" not in file:
        continue
    with open(file, 'r', encoding='utf-8', errors='replace') as mdl_file:
        content = mdl_file.read()
        matches = re.findall(pattern, content)
        for m in matches:
            if m[0] not in total_matches:
                total_matches[m[0]] = [m[1]]
            else:
                total_matches[m[0]] += [m[1]]
                            

potential_param = 0

for rm in total_matches:
    counts = Counter(total_matches[rm])
    counts = [c for c in counts if counts[c] == 1]
    if len(counts) > 1:
        potential_param += 1
        print(f"{rm}:   {sorted(counts, key=len)[-3:]}")

print(f"We found {len(total_matches)} unique Parameters overall. {potential_param} of them are candidates that could hold custom useful information.")

