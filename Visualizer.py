import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from PIL import Image
import sys


def img_to_bmp(path_to_img):
    img = mpimg.imread(path_to_img)
    return img

def to_bnw(input, output):
    color_image = Image.open(input)
    bw = color_image.convert('L')
    bw.save(output)

def pad(flattened_bmp):
    return np.pad(flattened_bmp, (1, 1), 'constant', constant_values=(0, 0))


def flatten_rgb(bitmap):
    flattened_bmp = []
    for row in bitmap:
        new_row = []
        for pixel in row:
            pixel_val = pixel[0]
            new_row.append(pixel_val)
        flattened_bmp.append(new_row)
    nparr = np.asarray(flattened_bmp)
    return nparr


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
        print(len(row))
        for pixel in row:
            x86_lst.append(hex(pixel))

    return x86_lst


def write_x86_file(pixel_lst):
    file = open("unfiltered_img.txt", "w")
    file.write('\n'.join(map(str, pixel_lst)))
    file.close()


def show_img(bitmap):
    plt.imshow(bitmap)
    plt.show()


def get_image_size():
    width = int(input("Inserte el ancho de imagen: "))
    height = int(input("Inserte el largo de imagen: "))

def decode(file):
    out_image_bin = open(file, 'r') 
    lines = out_image_bin.readlines()
    result = [] 

    for line in lines:
        result.append(int.from_bytes(line.encode('utf-8'), byteorder=sys.byteorder))


format_for_x86(pad(flatten_rgb(img_to_bmp('bnw.jpeg'))))