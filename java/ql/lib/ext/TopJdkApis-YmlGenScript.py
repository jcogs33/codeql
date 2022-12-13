import csv
import re
import json

"""
Script to auto-format yml rows for top-N JDK APIs
Extract package, type, name, and signature from csv results
Put placeholders for rest of values
"""

# Read top 500 jdk apis from csv results file
apis_list_500 = []
with open('java/ql/lib/ext/TopJdkApis-500.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            line_count += 1
        else:
            apis_list_500.append(row[0])
            line_count += 1
    print(f'Processed {line_count} lines.')

# Read top 100 jdk apis from csv results file
apis_list_orig100 = []
with open('java/ql/lib/ext/TopJdkApis-100-Michael.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            line_count += 1
        else:
            apis_list_orig100.append(row[0])
            line_count += 1
    print(f'Processed {line_count} lines.')

# Format as yml rows
final_yml = ["", "", False, "", "", "", "aaa", "aaa", "aaa", "manual"]
final_ymls_100 = []
final_ymls_500 = []
for api in apis_list_500:
    yml = re.split('\.([A-Z])|#|\(', api)
    final_yml[0] = yml[0]          # package
    final_yml[1] = yml[1] + yml[2] # type
    final_yml[3] = yml[4]          # name
    final_yml[4] = '(' + yml[6]    # signature

    if api in apis_list_orig100:
        final_ymls_100.append(final_yml.copy())
    else:
        final_ymls_500.append(final_yml.copy())

# Print each yml row to the console so can copy into .yml file
# ! Remember to find and replace false to False in the yml file afterwards.

# ! don't sort these ones yet, since only doing next 50-100, etc...
#final_ymls_500_sorted = sorted(final_ymls_500, key=lambda x:x[0])
for i in final_ymls_500:
    print('- ' + json.dumps(i)) # use `json.dumps` to get "" instead of '' around each element of the list

# print the original 100 at the end so can spot-check later
print("****************************** ORIGINAL 100 ******************************")
final_ymls_100_sorted = sorted(final_ymls_100, key=lambda x:x[0])
for j in final_ymls_100_sorted:
    print('- ' + json.dumps(j))
