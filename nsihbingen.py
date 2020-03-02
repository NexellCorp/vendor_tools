# Created by suker@nexell.co.kr
# Description :  nsih txt file converted to binary file
import os
import sys
import binascii

NSIH_TXT_FILE_NAME = "nsih-usbdownload.txt"
NSIH_BIN_FILE_NAME = "nsih-usbdownload.bin"


def nsihgen(txtFileName, binFileName):
    nsihFile = txtFileName 

    genFile = open(binFileName, 'wb')
    temp = []
    with open(nsihFile, 'rt') as data:
        for line in data:
            if len(line) <= 7 or (line[0] == '/' and line[1] == '/'):
                continue
            temp.append((line.split(' '))[0].strip().lower())

    for i in temp:
        if (len(i) != 8):
            print("ERROR")
            break

        temp2 = []
        # i : 01 23 45 67
        temp2.append(i[6])
        temp2.append(i[7])
        temp2.append(i[4])
        temp2.append(i[5])
        temp2.append(i[2])
        temp2.append(i[3])
        temp2.append(i[0])
        temp2.append(i[1])

        # print "".join(temp2)

        genFile.write(binascii.unhexlify("".join(temp2)))

    genFile.close()


def main(nsih_txt_file_name, nsih_bin_file_name):
    nsihgen(nsih_txt_file_name, nsih_bin_file_name)


if __name__ == "__main__":
    try:
        main(sys.argv[1], sys.argv[2])
    finally:
        pass
