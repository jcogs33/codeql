# read from file
linesList = []
newLineStr = ""
file = open("codex-generated.model.yml.txt", "r")
for line in file:
    #print(newLineStr)
    if line.startswith("  - ["):
        newLineStr = line.strip()
    else:
        newLineStr += " " + line.strip()

    if line.endswith("]\n"):
        linesList.append(newLineStr)
        # newLineStr = ""
file.close()
# for item in linesList:
#     print(item)

# write to file
fout = open('codexYmlformatted.txt', 'w')
for item in linesList:
    fout.write(item + "\n")
fout.close()
