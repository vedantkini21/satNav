import urllib, urllib.request
import subprocess
import sys
import os
import gzip
import shutil

cwd = os.path.dirname(os.path.abspath(__file__))

import ssl

def download_file(url, filename):
    try:
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        response = urllib.request.urlopen(url, context=ctx)
        if response.status == 200:
            with open(os.path.join(cwd, filename), 'wb') as f:
                f.write(response.read())
            print(f'|- Downloaded {filename} successfully.')
            return True
        else:
            print(f'|-? Error: HTTP {response.status} - {response.reason}')
            return False
    except urllib.error.HTTPError as e:
        print(f'|-? HTTP Error: {e.code} - {e.reason}')
        return False
    except urllib.error.URLError as e:
        print(f'|-? URL Error: {e.reason}')
        return False
    except Exception as e:
        print(f'|-? Error Downloading file: {e}')
        return False



filenames = [];
fn = input("|- Enter the FileNames to download\n| [Enter file names as space(' ') or comma(',') separated, and\n|  Enter -1 to terminate the list.]:\n|-> ")
# filenames.append(fn)
flag = False
while True:
    fnls = fn.split(' ')
    # print(fnls)
    for f in fnls:
        fnls1 = f.split(',')
        for f1 in fnls1:
            if f1 == '-1':
                flag = True
                continue
            if len(f1):
                filenames.append(f1)

    if flag:
        break
    fn = input('|-> ')


# print('filenames:', filenames)

allowed_const = ['C', 'E', 'G', 'I', 'J', 'R', 'S', 'M']
const_name = {
    'C': 'Beidu (C)',
    'E': 'Galileo (E)',
    'G': 'GPS (G)',
    'I': 'IRNSS (I)',
    'J': 'QZSS (J)',
    'R': 'GLONASS (R)',
    'S': 'SBAS (S)',
    'M': 'Mixed'
}

for filename in filenames:
    extracted_filename = filename[0:-3];
    extracted_filepath = os.path.join(cwd, filename[0:-3]);
    if os.path.exists(extracted_filepath):
        print(f'\n-> RINEX file {extracted_filename} already exists.')
        continue
    filename_split = filename.split('_')
    year = filename_split[2][0:4]
    week = filename_split[2][4:7]
    const = filename_split[-1][0]

    if const not in allowed_const:
        print(f"|-? Please provide a valid file name to download: '{const}' constellation does not exist!")
        sys.exit()

    M_filename = filename.replace(f'{const}N', 'MN')
    extracted_M_filename = M_filename[0:-3]
    M_filepath = os.path.join(cwd, M_filename)
    extracted_M_filepath = os.path.join(cwd, extracted_M_filename)

    if not os.path.exists(M_filepath) and not os.path.exists(extracted_M_filepath):
        print('    [Downloading Files....]')
        url = f'https://igs.bkg.bund.de/root_ftp/IGS/BRDC/{year}/{week}/{M_filename}'
        success = download_file(url, M_filename)
        if not success:
            continue

    if not os.path.exists(extracted_M_filepath):
        #zip extraction
        # subprocess.run([os.path.join(cwd, 'bin/gunzip.exe'), '-d', os.path.join(cwd, M_filename)], text=True)
        with gzip.open(M_filepath, 'rb') as f_in:
            with open(extracted_M_filepath, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        
        os.remove(M_filepath)
        print('|- extracted Filename: ' + extracted_M_filename)

    if const == 'M':
        sys.exit()

    #RINEX conversion
    subprocess.run([os.path.join(cwd, 'bin/gfzrnx.exe'), '-finp', os.path.join(cwd, extracted_M_filename), '-fout', os.path.join(cwd, filename[0:-3]), '-satsys', const, '-f', '-q'], text=True)
    print(f"\n-> RINEX file for '{const_name[const]}' has been generated: {extracted_filename}")