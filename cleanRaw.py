import os

input_file = input("|- Enter the absolute of the log file to be cleaned:\n|-> ").strip(r'"')
input_file_splt = input_file.split("\\")
output_file = os.path.join("\\".join(input_file_splt[0:-1]), "cleaned_" + input_file_splt[-1])

#constellations numbers: 0- Unknown, 1- GPS, 2- SBAS, 3- GLONASS,
#4- QZSS, 5- Beidou, 6- Gallileo, 7- IRNSS

#1256 - Bridge_Static_2PM

VALID_CONST = {'1', '5', '6'}

def is_valid_raw(parts):
    try:
        cn0 = float(parts[16])
        const = parts[28]

        if const not in VALID_CONST:
            return False

        if cn0 < 20:
            print(cn0, parts[28])
            return False

        return True
    except:
        return False
    
with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
    for line in fin:
        if line.startswith("Raw"):
            parts = line.strip().split(',')
            if is_valid_raw(parts):
                fout.write(line)
        else:
            fout.write(line)

print("Cleaned file saved:", output_file)