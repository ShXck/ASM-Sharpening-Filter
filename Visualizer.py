import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from PIL import Image
import sys
from scipy import signal
import os
import random


def img_to_bmp(path_to_img):
    img = mpimg.imread(path_to_img)
    return img

def to_bnw(input, output):
    color_image = Image.open(input)
    bw = color_image.convert('L')
    bw.save(output)

def pad(flattened_bmp):
    return np.pad(flattened_bmp, (1, 1), 'constant', constant_values=(0, 0))


def convert_to_1channel(bitmap):
    if len(bitmap.shape) > 2:
        flattened_bmp = []
        for row in bitmap:
            new_row = []
            for pixel in row:
                pixel_val = pixel[0]
                new_row.append(pixel_val)
            flattened_bmp.append(new_row)
        nparr = np.asarray(flattened_bmp)
        return nparr
    else:
        return bitmap


def fix_rgb(flattened_bmp):
    fixed_bmp = []
    for row in flattened_bmp:
        pixel_map = []
        for pixel in row:
            pixel_lst = [pixel, pixel, pixel]
            pixel_map.append(pixel_lst)
        fixed_bmp.append(pixel_map)
    nparr = np.asarray(fixed_bmp)
    return nparr

def format_for_x86(flattened_rgb):
    x86_lst = []

    for row in flattened_rgb:
        for pixel in row:
            x86_lst.append("{0:0=3d}".format(pixel))

    return x86_lst
    
def write_x86_file(pixel_lst):
    file = open("unfiltered_img.txt", "w")
    file.write(''.join(map(str, pixel_lst)))
    file.close()

def show_filtered_img(width, height, dec):
    im = Image.new('L', (width, height))
    im.putdata(dec)
    im.show()

def build_new_image(out_file):
    with open(out_file, encoding="utf-8", errors='replace') as read_data:
        contents = read_data.read()[2:]
        grouped = [contents[i:i+3] for i in range(0, len(contents), 3)]
        fixed = [number for number in grouped if number != '\n\x00\x00']
        deb = [i.replace('\x00', '') for i in fixed]
        int_arr = [int(i) for i in deb]
        return int_arr
        
def gen_neg():
    return random.randrange(-500, -1)

        
def run_filters():
    width = int(input("Inserte el ancho de imagen: "))
    height = int(input("Inserte el largo de imagen: "))

    os.system("nasm -f elf64 Input.asm -o input.o")
    os.system("ld input.o -o input")
    os.system("./input")

def test_func(x86_lst, test_pnt):
    size = 0
    ctr = 1
    for i in x86_lst:
        size += len(i)
        if ctr == test_pnt:
            return i, (size - 3)
        else: ctr += 1

#lst = format_for_x86(pad(convert_to_1channel(img_to_bmp('bnw.jpeg'))))
#print(test_func(lst, 524))
#run_filters()

#img = img_to_bmp('bnw.jpeg')
#adj = convert_to_1channel(img)


width = 259
height = 194

arr = build_new_image("new_file.txt")
show_filtered_img(1024, 768, arr)

#exp = [[1,2,3], [4,5,6], [7,8,9]]
kernel = [[0,-1,0], [-1,5,-1], [0,-1,0]]


#out = signal.convolve2d(adj, kernel, boundary='fill', mode='same')
#print(out.flatten())

#print("REAL: ", out.flatten()[:50], len(out.flatten()))

#new_bmp = format_for_bmp(width, height, dec)
#print(len(new_bmp[0]))
#bmparr_to_img(new_bmp)
#bmparr_to_img(fix_rgb(out))

#write_x86_file(format_for_x86(pad(convert_to_1channel(img_to_bmp('landbnw.jpg')))))