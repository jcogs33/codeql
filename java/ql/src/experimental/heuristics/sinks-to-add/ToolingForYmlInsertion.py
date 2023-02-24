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
from ruamel.yaml.scalarstring import DoubleQuotedScalarString as dq_str
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
# yaml = ruamel.yaml.YAML()

# # settings:
# yaml.preserve_quotes = True # to keep the double-quotes
# yaml.indent(mapping=2, sequence=4, offset=2) # indentation stays the same
# yaml.width = 4096 # yml rows stay on one line (hopefully 4096 is always long enough, can adjust if run into a case where not)
# yaml.boolean_representation = ['False', 'True'] # preserve uppercase for booleans
# yaml.default_flow_style = None # force added rows to be single-line format
# #yaml.default_style='"' # doesn't work with booleans... and seems to break default_flow_style..., and wraps too much in quotes

# # read in existing yml file
# with open("java/ql/lib/ext/org.apache.http.model.yml", "r") as f:
#     data = yaml.load(f.read())

# # Insert new models into `data`:
# # * code['name']['given'] = 'Bob'
# # * data['abc'].append('b')
# # * data.insert(1, 'last name', 'Vandelay', comment="new key")
# print(data['extensions'][0]['data']) # this is a LIST that can `append`, `insert`, `extend`, etc.
# given_list = ["org.apache.http", "HttpHost", True, "HttpHost", "(HttpHost)", "", "Argument[0]", "%-url", "manual"]
# #given_list_csv = "[\"org.apache.http\", \"HttpHost\", True, \"HttpHost\", \"(HttpHost)\", \"\", \"Argument[0]\", \"%-url\", \"manual\"]"
# # test_list = []
# # for i in given_list:
# #     if i not in [True, False]:
# #         test_list.append(dq_str(i))
# #     else:
# #         test_list.append(i)
# # print(test_list)
# data['extensions'][0]['data'].insert(0, given_list) # insert row with and without comment
# data['extensions'][0]['data'].yaml_add_eol_comment('NEW COMMENT', 0) # add eol_comment to added row
# data['extensions'][0]['data'].sort() # seems to work for maintaining alphabetical ordering of models

# # write out `data` to new file with same formatting
# with open("java/ql/src/experimental/heuristics/sinks-to-add/test.yml", "w") as f2:
#     yaml.dump(data, f2) # ! can't use sort_keys=True or default_flow_style=False with this it seems

# DONE: yml rows stay on one line: https://stackoverflow.com/questions/42170709/prevent-long-lines-getting-wrapped-in-ruamel-yaml,
# DONE: indentation stays the same: https://yaml.readthedocs.io/en/latest/detail.html?highlight=indent#indentation-of-block-sequences
# DONE: write back same looking file (achieved with `org.apache.http.model.yml` after fixing indentation and line wrap issue)
# DONE: preserve uppercase for booleans: https://stackoverflow.com/questions/46001328/ruamel-yaml-dump-doesnt-preserve-boolean-value-case
# DONE: confirm that comments outside blocks and empty lines in file sem to be preserved.
# DONE: insert row with and without comment: https://yaml.readthedocs.io/en/latest/detail.html?highlight=indent#adding-replacing-comments
#       https://stackoverflow.com/questions/70562866/python-how-to-add-nested-fields-to-yaml-file
#       https://stackoverflow.com/questions/49352692/flexible-appending-new-data-to-yaml-files
# DONE: maintain alphabetical ordering of models: https://stackoverflow.com/questions/39307956/insert-a-key-using-ruamel
# DONE: force added rows to be single-line format: https://stackoverflow.com/questions/62058034/how-to-define-a-style-of-new-dictionary-in-ruamel-yaml, https://stackoverflow.com/questions/56937691/making-yaml-ruamel-yaml-always-dump-lists-inline
# DONE: add eol_comment to added row: https://yaml.readthedocs.io/en/latest/detail.html?highlight=comment#adding-replacing-comments
# TODO: maintain double-quotes on *inserted* rows: https://stackoverflow.com/questions/39262556/preserve-quotes-and-also-add-data-with-quotes-in-ruamel, https://stackoverflow.com/questions/38784766/adding-quotes-using-ruamel-yaml
#       - weirdly hard to do this while maintaining the `yaml.default_flow_style = None`..., maybe worth abandoning double-quotes in all yml files due to this?
#       - commentmap might work: https://stackoverflow.com/questions/70852345/force-string-quoting-while-saving-flow-style



# *** MAIN CODE ***
from csv import DictReader
import ruamel.yaml
import os.path

# yml setup
yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True # to keep the double-quotes
yaml.indent(mapping=2, sequence=4, offset=2) # indentation stays the same
yaml.width = 4096 # yml rows stay on one line (hopefully 4096 is always long enough, can adjust if run into a case where not)
yaml.boolean_representation = ['False', 'True'] # preserve uppercase for booleans
yaml.default_flow_style = None # force added rows to be single-line format # TODO: only apply to new_model, so rest are block when new `addsTo`, etc. are inserted

# TODO: refactor all of below into functions, etc.
# TODO: error-handling with try/except blocks, etc.
# Read csv into List of Dicts (where each dict is a model)
with open("java/ql/src/experimental/heuristics/sinks-to-add/TestToolingMaDHeuristics.csv", "r") as f:
    dict_reader = DictReader(f)
    list_of_dict = list(dict_reader)

# read existing yml into data structure so can insert into it
# TODO: move reading of yml to after get `package_name` and `yml_filename` below
# TODO: handle insertion of `extensions`, etc. in new file if yml_file does not exist
# below from test case generator may help (but it's just inserting as a string block it seems as if a txt file, might be okay for new file or appending)...:
'''
if len(supportModelRows) != 0:
    # Make a test extension file
    with open(resultYml, "w") as f:
        models = "\n".join('      - [%s]' %
                          modelSpecRow[0].strip() for modelSpecRow in supportModelRows)
        dataextensions = f"""extensions:
  - addsTo:
      pack: codeql/java-tests
      extensible: summaryModel
    data:
{models}
"""
        f.write(dataextensions)
'''
# with open("java/ql/lib/ext/org.apache.http.model.yml", "r") as f:
#     yml_data = yaml.load(f.read())

# get package name from model (to find appropriate yml file) - skip any models that are not "sink", "source", "step", "neutral", "sinkOrStep" - only add definite models with this script for now
# and get corresponding yml filename
files_modified_set = set()
package_name = ""
yml_filename = ""
for model in list_of_dict:

    # get model type
    model_type = model["ModelType"]
    #print(model_type[0:4])

    # TP models insertion:
    if model_type in ["sink", "source", "summary", "neutral", "sinkOrStep"]:

        # get notes for comments
        comment = model["Notes"]

        # get and format new model row
        new_model_str = model["Proposed Sink"]
        new_model = new_model_str.strip("][").split(", ") # convert model string to list
        new_model = [item.strip('"') for item in new_model] # strip quotes from strings
        new_model[2] = eval(new_model[2]) # eval to get boolean value of string True/False
        #print(new_model)
        #sys.exit(0)

        # get package name
        package_name = new_model_str.split(",")[0][2:-1]

        # get yml filename from package name
        yml_filename = "java/ql/lib/ext/{}.model.yml".format(package_name) # TODO: don't hardcode path this much?

        # track what files are modified, # TODO: adjust how this is done, so not continually attempting to add duplicates to set
        files_modified_set.add(yml_filename)

        # TODO: make work for ANY yml files
        # DONE: check if yml file exists for package
        # if yml_filename exists
        if os.path.exists(yml_filename): #if yml_filename == "java/ql/lib/ext/org.apache.http.model.yml":

            # read existing yml into yml_data structure so can insert into it
            with open(yml_filename, "r") as f:
                yml_data = yaml.load(f.read())

            # determine if model_type NOT exist in yml_filename
            model_type_in_yml_file = False
            for ext in yml_data['extensions']:
                print(ext['addsTo']['extensible'][0:4], model_type)
                if model_type[0:4] == ext['addsTo']['extensible'][0:4]: # ? TODO: change drop-down labels to match `summaryModel`, etc. (but then still have issue with "sinkOrStep")
                    model_type_in_yml_file = True
                    break

            # If model_type NOT exist in yml_filename
            if not model_type_in_yml_file:
                # get extension type that needs to be added and its insertion location
                # TODO: simplify this
                extension_type = ""
                ext_insertion_location = -1
                if model_type[0:4] == "sour":
                    extension_type = "sourceModel"
                    ext_insertion_location = 0
                elif model_type[0:4] == "sink":
                    extension_type = "sinkModel"
                    ext_insertion_location = 1
                elif model_type[0:4] == "summ":
                    extension_type = "summaryModel"
                    ext_insertion_location = 2
                elif model_type[0:4] == "neut":
                    extension_type = "neutralModel"
                    ext_insertion_location = 3
                else: print("SOMETHING WENT WRONG WITH extension_type or location!")

                # insert new extension type with new_model #TODO: (see above about block-formatting the addsTo dict)
                yml_data['extensions'].insert(ext_insertion_location, {'addsTo': {'pack': 'codeql/java-all', 'extensible': extension_type}, 'data': [new_model]})
                with open(yml_filename, "w") as f0:
                        yaml.dump(yml_data, f0)
                sys.exit(0)


            # insert model(s) into yml data structure
            # TODO: check for duplicates with existing models and don't insert if so
            # TODO: only add "Notes" comments `if model["Notes"] not in ["", " "]:`
            # ? TODO: maybe remove ModelType if not sinkOrStep?
            # DONE: add comment about modeltype (esp for sinkOrStep ones)
            # DONE: condense all `model["ModelType"]`, etc. into variables
            # DONE: find if sink, source, step, neutral, sinkOrStep and insert in proper data['extensions'][n]['addsTo']['extensible']
            # DONE: assuming source_loc=0, sink_loc=1, and summary_loc=2, neutral_loc=4 in yml file ordering, change below to not assume this, but to actually determine from yml_data (esp since some files might not have all)
            # TODO: handle insertion of `extensions`, etc. if that model-type doesn't exist in the current file

            # determine location of block for each model type in the given file
            source_loc = -1
            sink_loc = -1
            summary_loc = -1
            neutral_loc = -1
            for i, ext in enumerate(yml_data['extensions']):
                if ext['addsTo']['extensible'] == 'sourceModel':
                    source_loc = i
                elif ext['addsTo']['extensible'] == 'sinkModel':
                    sink_loc = i
                elif ext['addsTo']['extensible'] == 'summaryModel':
                    summary_loc = i
                elif ext['addsTo']['extensible'] == 'neutralModel':
                    neutral_loc = i
                else:
                    print("FAILURE IN YML DATA LOCATION/TYPE DETERMINATION!")

            # insert model in correct location in correct block
            if model_type == "sink" or model_type == "sinkOrStep":
                yml_data['extensions'][sink_loc]['data'].insert(0, new_model) # insert row at top
                yml_data['extensions'][sink_loc]['data'].yaml_add_eol_comment('! ModelType: ' + model_type + ', Notes: ' + comment, 0) # add eol_comment to added row
                yml_data['extensions'][sink_loc]['data'].sort() # seems to work for maintaining alphabetical ordering of models
                # write modified yml back to same file (separate file during testing)
                with open(yml_filename, "w") as f2:
                    yaml.dump(yml_data, f2)
            elif model_type == "source":
                yml_data['extensions'][source_loc]['data'].insert(0, new_model) # insert row at top
                yml_data['extensions'][source_loc]['data'].yaml_add_eol_comment('! ModelType: ' + model_type + ', Notes: ' + comment, 0) # add eol_comment to added row
                yml_data['extensions'][source_loc]['data'].sort() # seems to work for maintaining alphabetical ordering of models
                # write modified yml back to same file (separate file during testing)
                with open(yml_filename, "w") as f3:
                    yaml.dump(yml_data, f3)
            elif model_type == "step": # aka summary
                yml_data['extensions'][summary_loc]['data'].insert(0, new_model) # insert row at top
                yml_data['extensions'][summary_loc]['data'].yaml_add_eol_comment('! ModelType: ' + model_type + ', Notes: ' + comment, 0) # add eol_comment to added row
                yml_data['extensions'][summary_loc]['data'].sort() # seems to work for maintaining alphabetical ordering of models
                # write modified yml back to same file (separate file during testing)
                with open(yml_filename, "w") as f4:
                    yaml.dump(yml_data, f4)
            elif model_type == "neutral":
                yml_data['extensions'][neutral_loc]['data'].insert(0, new_model) # insert row at top
                yml_data['extensions'][neutral_loc]['data'].yaml_add_eol_comment('! ModelType: ' + model_type + ', Notes: ' + comment, 0) # add eol_comment to added row
                yml_data['extensions'][neutral_loc]['data'].sort() # seems to work for maintaining alphabetical ordering of models
                # write modified yml back to same file (separate file during testing)
                with open(yml_filename, "w") as f5:
                    yaml.dump(yml_data, f5)
            else:
                print("ModelType, " + model_type + ", not correct.") # TODO: make this and all error messages better

        # yml file does not exist
        else:
            print("CREATING NEW YML FILE...")
            # create file and write initial yml data and first model as string into file
            with open(yml_filename, "w") as f:
                models = "\n".join('      - [%s]' %
                                new_model)
                dataextensions = f"""extensions:
        - addsTo:
            pack: codeql/java-tests
            extensible: summaryModel
            data:
        {models}
        """
                f.write(dataextensions)


# # write modified yml back to same file (separate file during testing)
# with open("java/ql/src/experimental/heuristics/sinks-to-add/test.yml", "w") as f2:
#     yaml.dump(yml_data, f2)

# TODO: fix double-quotes issue either with commentMap as mentioned above, OR by grepping over file (uglier)

# tell user what files modified, print any errors, etc.
print("FILES MODIFIED:")
for item in files_modified_set:
    print("  " + item)
