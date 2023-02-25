
# TODO: make "references" section at the bottom (or top) for any of the below links that you ended up actually using info from.
# *** NOTES ***
# * https://www.geeksforgeeks.org/load-csv-data-into-list-and-dictionary-using-python/

# * https://stackoverflow.com/questions/1773805/how-can-i-parse-a-yaml-file-in-python

# * preserving comments in yml: https://stackoverflow.com/questions/7255885/save-dump-a-yaml-file-with-comments-in-pyyaml
# *  and https://pypi.org/project/ruamel.yaml/, https://github.com/yaml/pyyaml/issues/90, https://web.archive.org/web/20160812090911/https://pyyaml.org/ticket/114
# *  https://yaml.readthedocs.io/en/latest/detail.html?highlight=comment#adding-replacing-comments
# *  https://stackoverflow.com/questions/47542343/how-to-print-a-value-with-double-quotes-and-spaces-in-yaml
# *  https://yaml.readthedocs.io/en/latest/example.html?highlight=dump#examples
# *      supports insertion of a key into a particular position, while optionally adding a comment: `data.insert(1, 'last name', 'Vandelay', comment="new key")`
# *      You can change this default indentation by e.g. using yaml.indent(): `yaml.indent(mapping=4, sequence=6, offset=3)`

# * with ruamel.yaml
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
# DONE: maintain double-quotes on *inserted* rows: https://stackoverflow.com/questions/39262556/preserve-quotes-and-also-add-data-with-quotes-in-ruamel, https://stackoverflow.com/questions/38784766/adding-quotes-using-ruamel-yaml
#       - weirdly hard to do this while maintaining the `yaml.default_flow_style = None`..., maybe worth abandoning double-quotes in all yml files due to this?
#       - commentmap might work: https://stackoverflow.com/questions/70852345/force-string-quoting-while-saving-flow-style


from csv import DictReader
import ruamel.yaml # need to pip3 install
from ruamel.yaml.scalarstring import DoubleQuotedScalarString as dq_str
from ruamel.yaml.comments import CommentedSeq
import os.path
import sys

# yml setup
yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True # to keep the double-quotes
yaml.indent(mapping=2, sequence=4, offset=2) # indentation stays the same
yaml.width = 4096 # yml rows stay on one line (hopefully 4096 is always long enough, can adjust if run into a case where not)
yaml.boolean_representation = ['False', 'True'] # preserve uppercase for booleans

# TODO: error-handling with try/except blocks, etc., make all error messages better
# TODO: python comments on all functions, etc. -- make better (https://peps.python.org/pep-0008/#documentation-strings, https://peps.python.org/pep-0257/)
# TODO: related to error-handling: tell user what models not placed if any?
# TODO: change drop-downs to match extensible names to simplify anywhere I have `model_type[0:4]` (problematic with "sinkOrStep")
# TODO: user instructions, dependencies (see imports), warnings, etc.
# * NOTE: anything that's not a sink still needs its model adjusted manually (since current query output is sinks), either before or after this script is run

def read_csv(filename):
    """
    Read csv data from the file specified by `filename`.
    Returns the csv data as a list of dictionaries.
    """
    try:
        with open(filename, "r") as file:
            dict_reader = DictReader(file)
            list_of_dicts = list(dict_reader)
    except Exception as e:
        print("Failed to read csv:", filename)
        print(e)
        sys.exit(1)
    return list_of_dicts

# read existing yml into data structure so can insert into it
def read_yml(filename):
    """
    Read yml data from the file specified by `filename`.
    Returns the yml data.
    """
    try:
        with open(filename, "r") as file:
            yml_data = yaml.load(file.read())
    except Exception as e:
        print("Failed to read yml file:", filename)
        print(e)
        sys.exit(1)
    return yml_data

def write_yml(filename, yml_data):
    """Write the given `yml_data` into the file specified by `filename`."""
    try:
        with open(filename, "w") as file:
            yaml.dump(yml_data, file)
    except Exception as e:
        print("Failed to write to yml file:", filename)
        print(e)
        sys.exit(1)

def create_yml_file(filename, model_str, model_type, extensible_type, comment):
    """
    Creates a new yml file for the given `filename`,
    and inserts a model as a string into the file.
    """
    try:
        print("CREATING NEW YML FILE for", filename)
        with open(filename, "w") as file:
            model = "      - " + model_str + " # ! ModelType: " + model_type + ", Notes: " + comment
            data_extensions = f"""extensions:
  - addsTo:
      pack: codeql/java-tests
      extensible: {extensible_type}
    data:
{model}
"""
            file.write(data_extensions)
    except Exception as e:
        print("Failed to create yml file:", filename)
        print(e)
        sys.exit(1)

def insert_model_in_yml(yml_data, yml_filename, model, location, model_type, comment):
    # ! TODO: check for duplicates with existing models and don't insert if so
    # TODO: only add "Notes" comments `if model["Notes"] not in ["", " "]:`?
    # TODO: maybe remove ModelType comment if not sinkOrStep?
    yml_data['extensions'][location]['data'].insert(0, model) # insert row at top (maybe change to append to end instead, but need index for adding comment below)
    yml_data['extensions'][location]['data'].yaml_add_eol_comment('! ModelType: ' + model_type + ', Notes: ' + comment, 0) # add eol_comment to added row
    yml_data['extensions'][location]['data'].sort() # maintain alphabetical ordering of models
    # write modified yml back to same file (separate file during testing)
    write_yml(yml_filename, yml_data)

# holds if the extensible type for the given model_type DOES exist in the given yml_data
# returns a boolean AND the index of that extensible if it exists
# returns -1 as the extensible index if it doesn't exist
def extensible_type_exists(yml_data, model_type):
    # determine if model_type does NOT exist in yml_filename yet
    model_type_in_yml_file = False
    extensible_location = -1
    for i, ext in enumerate(yml_data['extensions']):
        if model_type[0:4] == ext['addsTo']['extensible'][0:4]:
            model_type_in_yml_file = True
            extensible_location = i
            break
    return model_type_in_yml_file, extensible_location

# get location to insert a *new* extensible in the given yml_data
# trying to maintain order of source,sink,summary,neutral in the yml file versus just appending new extensible to the end
def get_extensible_insertion_location(yml_data, model_type):
    # determine which extensible types already exist in the given yml_data
    # based on those types, know where need to insert new extensible
    current_extensible_types = []
    for ext in yml_data['extensions']:
        current_extensible_types.append(ext['addsTo']['extensible'])
    if model_type[0:4] == "sour":
        return 0 # source will always need to go at position 0, which should always exist in this scenario
    elif model_type[0:4] == "sink":
        # options:
            # 1: sour, (sink at 1)
            # 1: (sink at 0), summ
            # 1: (sink at 0), neut

            # 2: sour, (sink at 1), summ
            # 2: sour, (sink at 1), neut
            # 2: (sink at 0), summ, neut

            # 3: sour, (sink at 1), summ, neut
        if len(current_extensible_types) == 3: return 1
        elif len(current_extensible_types) == 2 or len(current_extensible_types) == 1:
            if "sourceModel" in current_extensible_types: return 1
            else: return 0
        else: print("Incorrect number of extensibles in existing yml file. Failed when trying to insert new sinkModel.")
    elif model_type[0:4] == "summ":
        # options:
            # 1: sour, (summ at 1)
            # 1: sink, (summ at 1)
            # 1:(summ at 0), neut

            # 2: sour, sink, (summ at 2)
            # 2: sour, (summ at 1), neut
            # 2: sink, (summ at 1), neut

            # 3: sour, sink, (summ at 2), neut
        if len(current_extensible_types) == 3: return 2
        elif len(current_extensible_types) == 2:
            if "neutralModel" in current_extensible_types: return 1
            else: return 2
        elif len(current_extensible_types) == 1:
            if "neutralModel" in current_extensible_types: return 0
            else: return 1
        else: print("Incorrect number of extensibles in existing yml file. Failed when trying to insert new summaryModel.")
    elif model_type[0:4] == "neut":
        return len(current_extensible_types) # neutral will always need to go at the end, which should always be possible in this situation
    else:
         print("Error in get_extensible_insertion_location!")

# get extensible type for the given model type
# TODO: combine with `extensible_type_exists`? (or if change csv data to have model_type==extensible_type already)
def get_extensible_type(model_type):
    if model_type[0:4] == "sour":
        return "sourceModel"
    elif model_type[0:4] == "sink":
        return "sinkModel"
    elif model_type[0:4] == "summ":
        return "summaryModel"
    elif model_type[0:4] == "neut":
        return "neutralModel"
    else:
        print("SOMETHING WENT WRONG WITH WHEN GETTING extensible_type! Returned extensible_type='None'.")

def extract_relevant_info(csv_row):
    """
    Extracts information necessary for model insertion from the given `csv_row`.
    Returns
        - the name of the yml file where the model needs to be inserted
        - the model as a string and as a formatted list
        - any comments associated with the model
    """
    # get notes for comments
    comment = csv_row["Notes"]

    # get and format new model row
    new_model_str = csv_row["Proposed Sink"]
    new_model_list = new_model_str.strip("][").split(", ") # convert model string to list
    new_model_list = [item.strip('"') for item in new_model_list] # strip quotes from strings
    # TODO: make below more robust against potential future re-ordering of where boolean is placed (e.g. check type of eval in condition instead of hardcoding index number as 2)
    new_model_list = [dq_str(item) if new_model_list.index(item) != 2 else eval(item) for item in new_model_list ] # make all strings double-quoted strings, and boolean at index 2 a boolean with eval(...)

    # format model list with CommentedSeq for single-line output
    cs_model_list = CommentedSeq(new_model_list) # need this after adding dq_str to allow for single-line instead of block-style
    cs_model_list.fa.set_flow_style()  # forces single-line instead of block-style for new model row, removes need for global `yaml.default_flow_style = None``

    # extract package name
    package_name = new_model_str.split(",")[0][2:-1]

    # get yml filename from package name
    # ! TODO: don't hardcode path this much? use os.path instead? (don't need to worry about unless making usable by anyone)
    yml_filename = "java/ql/lib/ext/{}.model.yml".format(package_name)

    return yml_filename, new_model_str, cs_model_list, comment


# *** MAIN PROGRAM ***
# TODO: wrap into main function?: https://stackoverflow.com/questions/4041238/why-use-def-main, "will be possible to run tests against that code."

# check that user entered correct number of args, abort if not
if len(sys.argv) != 2:
    print("Incorrect number of args received.")
    print("Usage: YmlInsertion.py models.csv")
    print("models.csv should contain models to add as data extension rows.")
    sys.exit(1)

files_modified_set = set()
# iterate over all proposed model data
for csv_row in read_csv(sys.argv[1]): # test file = "java/ql/src/experimental/heuristics/sinks-to-add/TestToolingMaDHeuristics.csv"

    # TODO: could technically wrap ALL of the below into an `add_new_model` function... (it might be more readable to NOT do this though...)
    # get model type
    model_type = csv_row["ModelType"]

    # only add definite models with this script for now
    if model_type in ["sink", "source", "summary", "neutral", "sinkOrStep"]:

        # extract relevant info from csv row
        yml_filename, new_model_str, new_model_list, comment = extract_relevant_info(csv_row)

        # get extensible type for the model
        extensible_type = get_extensible_type(model_type)

        # track what files are modified
        # TODO: adjust how this is done, so not continually attempting to add duplicates to set?
        # TODO: add only when file-write was successful? (e.g. call this right after call `insert_model_in_yml` and `create_yml_file` (or call at the end of these functions?))
        files_modified_set.add(yml_filename)

        # if yml file exists already
        # TODO: could prbly wrap this if/else into insert_model_in_yml or similar function...
        if os.path.exists(yml_filename):

            # read existing yml into yml_data structure so can modify it
            yml_data = read_yml(yml_filename)

            # check if the extensible type for the model_type already exists in the yml_data
            #   and get its location/index if it exists
            model_type_in_yml_file, extensible_location = extensible_type_exists(yml_data, model_type)

            # TODO: could prbly wrap the below if/else into insert_model_in_yml
            # If extensible type for the model_type does NOT already exist in the yml_data
            if not model_type_in_yml_file:
                # get proper insertion location/index for the extensible type
                ext_insertion_location = get_extensible_insertion_location(yml_data, model_type)

                # insert new extensible type (addsTo: pack, extensible...) along with the new_model
                yml_data['extensions'].insert(ext_insertion_location, {'addsTo': {'pack': 'codeql/java-all', 'extensible': extensible_type}, 'data': CommentedSeq([new_model_list])})
                yml_data['extensions'][ext_insertion_location]['data'].yaml_add_eol_comment('! ModelType: ' + model_type + ', Notes: ' + comment, 0) # add eol_comment to added row
                write_yml(yml_filename, yml_data)

            # If model_type DOES exist in yml_filename
            else:
                # insert new_model into yml data structure
                insert_model_in_yml(yml_data, yml_filename, new_model_list, extensible_location, model_type, comment)

        # if yml file does not exist
        else:
            # create file and write initial yml data and first model as string into file
            create_yml_file(yml_filename, new_model_str, model_type, extensible_type, comment)

# tell user what files modified, print any errors, etc.
print("FILES MODIFIED:")
for item in files_modified_set:
    print("  " + item)
