import glob
import os

directory = r'C:\tmp\obfmodels'
file_pattern = os.path.join(directory, '*_custom_parameters.csv')

files = glob.glob(file_pattern)

for file in files:
    try:
        with open(file, 'r') as f:
            model_pattern = file.split('_custom_')[0]+'*.mdl'
            model_pattern = os.path.join(directory, model_pattern)
            model_files = glob.glob(model_pattern)
            if len(model_files) < 2:
                continue
            if len(model_files[0]) < len(model_files[1]):
                orim, obfm = model_files[0], model_files[1]
            else:
                obfm, orim = model_files[0], model_files[1]
            
            was_printed = False
            custom_lines = [line.rstrip('\n') for line in set(f.readlines())]
            ori_content = open(orim, 'r').read()
            obf_content = open(obfm, 'r').read()
            for cl in custom_lines:
                ori_count = ori_content.count(cl)
                obf_count = obf_content.count(cl)
                if ori_count == 1 and obf_count > 0:
                    for line in ori_content.splitlines():
                        if cl in line:
                            if "SourceBlock" in line:
                                continue
                            else:
                                if not was_printed:
                                    print(f"Processed {orim}, {obfm} and {file}")
                                    was_printed = True
                                print(f"'{cl}' still occurs in '{line}'")
                            
        
        print("\n\n\n")
    except IOError as e:
        print(f"Error opening file {file}: {e}")

print("Finished processing all files.")
