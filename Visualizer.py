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

def save_new_img(width, height, dec, out):
    im = Image.new('L', (width, height))
    im.putdata(dec)
    im.save(out)

def show_output_images(img_names):

    bnw_img = mpimg.imread(img_names[0])
    sharp_img = mpimg.imread(img_names[1])
    oversharp_img = mpimg.imread(img_names[2])

    plot_image = np.concatenate((bnw_img, sharp_img, oversharp_img), axis=1)

    plt.set_cmap('gray')

    plt.imshow(plot_image)

    plt.show()

    
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

def set_out_names(og_name):
    og_name_splt = og_name.split('.')
    out_names = og_name_splt[0] + "bnw." + og_name_splt[1]
    sharp_name = og_name_splt[0] + "sharpen." + og_name_splt[1]
    oversharp_name = og_name_splt[0] + "oversharpen." + og_name_splt[1]
    return out_names, sharp_name, oversharp_name  

def run_filters():
    img_to_proc = input("Escriba el nombre y formato de la imagen: ")
    width = int(input("Inserte el ancho de imagen: "))
    height = int(input("Inserte el largo de imagen: "))

    os.system("rm -f sharpened.txt oversharpened.txt")

    out_names = set_out_names(img_to_proc)

    to_bnw(img_to_proc, out_names[0])

    Path('sharpened.txt').touch()
    Path('oversharpened.txt').touch()
    Path('unfiltered_img.txt').touch()

    write_x86_file(format_for_x86(pad(convert_to_1channel(img_to_bmp(out_names[0])))))

    print("\n -------- Corriendo script de ensamblador -------- \n")

    os.system("nasm -f elf64 sharp.asm -o sharp.o")
    os.system("ld sharp.o -o sharp")

    os.system("nasm -f elf64 oversharpen.asm -o over.o")
    os.system("ld over.o -o over")

    os.system("./input")
    os.system("./over")

    sharp = build_new_image("sharpened.txt")
    oversharp_img = build_new_image("oversharpened.txt")

    save_new_img(width, height, sharp, out_names[1])
    save_new_img(width, height, oversharp_img, out_names[2])

    show_output_images(out_names)

run_filters()