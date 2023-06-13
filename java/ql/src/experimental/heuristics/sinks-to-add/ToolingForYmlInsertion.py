# Read csv into List of Dicts (where each dict is a model); need "Proposed Sink", "Notes", and "ModelType" as only keys in Dicts (strip package out now or later?)
# find what yml file it needs to go in based on package name

# https://www.geeksforgeeks.org/load-csv-data-into-list-and-dictionary-using-python/
# from csv import DictReader

# # open file in read mode
# with open("java/ql/src/experimental/heuristics/sinks-to-add/TestToolingMaDHeuristics.csv", "r") as f:

#     dict_reader = DictReader(f)

#     list_of_dict = list(dict_reader)


# files_modified_set = set()
#  # ! sort `list_of_dict` based on ModelType here?
# for model in list_of_dict:

#     # TP models insertion:
#     if model["ModelType"] in ["sink", "step", "neutral", "sinkOrStep"]:
#         # get package name
#         package_name = model["Proposed Sink"].split(",")[0][2:-1]
#         yml_filename = "java/ql/lib/ext/{}.model.yml".format(package_name)
#         files_modified_set.add(yml_filename)
#         with open(yml_filename, "a") as yml_file:
#             if model["Notes"] not in ["", " "]:
#                 yml_file.write(model["Proposed Sink"] + " # ModelType: " + model["ModelType"] + ", Notes: " + model["Notes"] + "\n")
#             else:
#                 yml_file.write(model["Proposed Sink"] + " # ModelType: " + model["ModelType"] + "\n")

#     # https://www.educative.io/answers/how-to-implement-wildcards-in-python
#     # below might not be necessary since will have notes on these in the csv file anyways and can more easily sort there?
#     # FP and unsure% insertion:
#     elif model["ModelType"] in ["FP", "unsure", "unsurePrblySink", "unsurePrblyStep", "unsurePrblyFP", "unsurePrblyNeutral"]:
#         files_modified_set.add("java/ql/src/experimental/heuristics/sinks-to-add/FP.unsure.model.yml.txt")
#         with open("java/ql/src/experimental/heuristics/sinks-to-add/FP.unsure.model.yml.txt", "a") as txt_file:
#             if model["Notes"] not in ["", " "]:
#                 txt_file.write(model["Proposed Sink"] + " # ModelType: " + model["ModelType"] + ", Notes: " + model["Notes"] + "\n")
#             else:
#                 txt_file.write(model["Proposed Sink"] + " # ModelType: " + model["ModelType"] + "\n")
#     else:
#         print("!!! " + model["Proposed Sink"] + " not inserted!!!")

# print("FILES MODIFIED:")
# for item in files_modified_set:
#     print("  " + item)

    # TODO: sort by ModelType in files (if don't sort, then put FP and unsures in different files?)
    # TODO: add space (and comment?) before appended models
    # TODO: tell user what files appended, what files created
    # TODO: tell user what models not placed if any?



# - sinks, steps, and neutrals insert into proper place in yml files
# - sinkOrStep insert as commented-out *sink* (for easy finding for later conversion) # ! sinkOrStep: [model]
# - FPs insert into FP.model.yml.txt file (or similar, for potential use in heuristic adjustment)
# - unsure% insert into unsure.model.yml.txt (or similar, for further triage)
# - include "Notes" as a comment *after* the model (on same line) # ! [notes here]

# for each package name: find if yml file exists
#    if not exists: create new dict for yml
#    if exists: read existing yml file into dict

# ! problem with comments in existing yaml not maintained by this?
# ! maybe best for now to just append to end of file as a start and fix manually
# TODO: look into preserving comments in yml: https://stackoverflow.com/questions/7255885/save-dump-a-yaml-file-with-comments-in-pyyaml
# TODO: and https://pypi.org/project/ruamel.yaml/, https://github.com/yaml/pyyaml/issues/90, https://web.archive.org/web/20160812090911/https://pyyaml.org/ticket/114
# TODO: https://yaml.readthedocs.io/en/latest/detail.html?highlight=comment#adding-replacing-comments
# TODO: https://stackoverflow.com/questions/47542343/how-to-print-a-value-with-double-quotes-and-spaces-in-yaml
# TODO: https://yaml.readthedocs.io/en/latest/example.html?highlight=dump#examples
#       supports insertion of a key into a particular position, while optionally adding a comment: `data.insert(1, 'last name', 'Vandelay', comment="new key")`
#       You can change this default indentation by e.g. using yaml.indent(): `yaml.indent(mapping=4, sequence=6, offset=3)`
# ! but still hard to put back in original-looking format... so just append to end of files for now and then copy in...

# https://stackoverflow.com/questions/1773805/how-can-i-parse-a-yaml-file-in-python
# * need: `pip3 install pyyaml` for `import yaml`
import yaml
import ruamel.yaml
import io
import sys

# * my original
# data = dict()
# with open("/Users/jcogs33/Documents/CodeQL/semmle-code/ql/java/ql/lib/ext/org.apache.http.model.yml", "r") as stream:
#     try:
#         data = yaml.safe_load(stream)
#         print(data)
#     except yaml.YAMLError as exc:
#         print(exc)

# with io.open('/Users/jcogs33/Documents/CodeQL/semmle-code/ql/java/ql/src/experimental/heuristics/sinks-to-add/data.yml', 'w', encoding='utf8') as outfile:
#     yaml.dump(data, outfile, default_flow_style=True, allow_unicode=True)

# * experimenting with Joe's
# with open("java/ql/lib/ext/org.apache.http.model.yml", "r") as f:
#     doc = yaml.load(f.read(), yaml.Loader)

# specs = []
# for ext in doc['extensions']:
#     if ext['addsTo']['extensible'] == 'summaryModel':
#         for row in ext['data']:
#             print("row[0]: ", row[0])
#             print("row[1]: ", row[1])
#             print("row[2]: ", row[2])
#             # if isinstance(row[2], bool): # oh, he's just converting the True/False to a lowercase string, does that matter for Python or something? (prbly easier for test generator since original csv would have been string)
#             #     row[2] = str(row[2]).lower()
#             print(row)
#             specs.append(row)
# # for i in specs:
# #     print(i)

# * with ruamel.yaml
yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True # to keep the double-quotes
with open("java/ql/lib/ext/org.apache.http.model.yml", "r") as f:
    data = yaml.load(f.read())
print(data)
for ext in data['extensions']:
    for row in ext['data']:
        print(row)
with open("java/ql/src/experimental/heuristics/sinks-to-add/test.yml", "w") as f2:
    yaml.indent(mapping=2, sequence=4, offset=2) # indentation stays the same
    yaml.width = 4096 # yml rows stay on one line
    yaml.dump(data, f2) # ! can't use sort_keys=True or default_flow_style=False with this it seems
# DONE: yml rows stay on one line: https://stackoverflow.com/questions/42170709/prevent-long-lines-getting-wrapped-in-ruamel-yaml,
# DONE: indentation stays the same: https://yaml.readthedocs.io/en/latest/detail.html?highlight=indent#indentation-of-block-sequences
# DONE: write back same looking file (achieved with `org.apache.http.model.yml` after fixing indentation and line wrap issue)
# TODO: insert row with and without comment: https://yaml.readthedocs.io/en/latest/detail.html?highlight=indent#adding-replacing-comments
