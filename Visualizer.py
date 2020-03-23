import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from PIL import Image
import sys
from scipy import signal
import os
import random
from pathlib import Path


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
    val_for_neg = 429
    with open(out_file, encoding="utf-8", errors='replace') as read_data:
        contents = read_data.read()
        grouped = [contents[i:i+3] for i in range(0, len(contents), 3)]
        fixed = [number for number in grouped if number != '\n\x00\x00']
        deb = [i.replace('\x00', '') for i in fixed]
        deb = [i.replace('\n', '') for i in deb]
        int_arr = [int(i) for i in deb]

        for i in range(0, len(int_arr)):
            if int_arr[i] == val_for_neg:
                int_arr[i] = gen_neg()

        return int_arr
        
def gen_neg():
    return random.randrange(-500, -1)

        
def run_filters():
    img_to_proc = input("Escriba el nombre y formato de la imagen: ")
    width = int(input("Inserte el ancho de imagen: "))
    height = int(input("Inserte el largo de imagen: "))

    Path('sharpened.txt').touch()
    Path('oversharpened.txt').touch()
    Path('unfiltered_img.txt').touch()

    write_x86_file(format_for_x86(pad(convert_to_1channel(img_to_bmp(img_to_proc)))))

    print("\n -------- Corriendo script de ensamblador -------- \n")

    os.system("nasm -f elf64 Input.asm -o input.o")
    os.system("ld input.o -o input")
    os.system("./input")

    print("\n -------- Procesando imágen --------  \n")

    arr = build_new_image("sharpened.txt")
    show_filtered_img(width, height, arr)

run_filters()
