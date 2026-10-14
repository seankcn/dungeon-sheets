import csv


print("from dungeonsheets.spells.spells import Spell\n")

with open("Spells.csv", 'r') as csvfile:
    csvreader = csv.DictReader(csvfile)
    for row in csvreader:
        print(f"class {row['Name'].replace('\'', '').replace('/', ' ').title().replace(' ', '')}(Spell):")
        print(f"    \"\"\"")
        print(f"    {row['Text'].replace("\n\n", "\n").replace("\n", "\n    ")}")
        if len(row['At Higher Levels']) > 0:
            print("    ")
            print(f"    {row['At Higher Levels'].replace("\n\n", "\n")}")
        print(f"    \"\"\"")
        print("    ")
        print(f"    name = \"{row['Name']}\"")
        level = 0 if "Cantrip" in row['Level'] else row['Level'][0]
        print(f"    level = {level}")
        print(f"    casting_range = \"{row['Range']}\"")
        components = "\", \"".join(row['Components'].split(' (')[0].replace(",", "").split(' '))
        print(f"    components = (\"{components}\")")
        mats = row['Components'].split('(')[1].replace(")", "") if "(" in row['Components'] else ""
        print(f"    materials = \"{mats}\"")
        print(f"    duration = \"{row['Duration']}\"")
        ritual = "ritual" in row['School']
        print(f"    ritual = {ritual}")
        school = row['School'].split(" ")[0] if ritual else row['School']
        print(f"    magic_school = \"{school}\"")
        classes = "\", \"".join(row['Classes'].split(' ')[::2])
        print(f"    classes = (\"{classes}\")")
        print()
