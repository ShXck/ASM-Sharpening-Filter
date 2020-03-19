import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from PIL import Image
import sys
from scipy import signal
from scipy import misc


def img_to_bmp(path_to_img):
    img = mpimg.imread(path_to_img)
    return img

def to_bnw(input, output):
    color_image = Image.open(input)
    bw = color_image.convert('L')
    bw.save(output)

def bmparr_to_img(bmp):
    img = Image.fromarray(bmp, 'RGB')
    img.save('sharp.png')
    img.show()

def pad(flattened_bmp):
    return np.pad(flattened_bmp, (1, 1), 'constant', constant_values=(0, 0))


def convert_to_1channel(bitmap):
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
        for pixel in row:
            x86_lst.append("{0:0=3d}".format(pixel))

    return x86_lst

def format_for_bmp(width, height, decoded_lst):
    out = np.empty((height, width, 3), dtype=int)

    dec_index = 0

    try:
        for row in out:
            for pixel in row:
                pixel[pixel == 0] = decoded_lst[dec_index]
                dec_index += 1
    except IndexError:
        return out
    return out
    


def write_x86_file(pixel_lst):
    file = open("unfiltered_img.txt", "w")
    file.write(''.join(map(str, pixel_lst)))
    file.close()


def show_img(bitmap):
    plt.imshow(bitmap)
    plt.show()

def get_image_size():
    width = int(input("Inserte el ancho de imagen: "))
    height = int(input("Inserte el largo de imagen: "))

def decode(file):
    dec_lst = []
    index = 0

    with open(file, 'rb') as f:
        contents = f.read()
        for i in contents:
            if index % 3 == 0:
                dec_lst.append(i)
            index += 1
        return dec_lst

def test_func(x86_lst, test_pnt):
    ctr = 1
    for i in x86_lst:
        print(i)
        if ctr == test_pnt:
            return i
        else: ctr += 1

#padded = pad(convert_to_1channel(img_to_bmp('bnw.jpeg')))
#print(padded)
bmp = img_to_bmp('bnw.jpeg')
#dec = decode('new_file.txt')
width = 259
height = 194

kernel = np.array([[0, 1, 0], [1, -4, 1], [0, 1, 0]])
conv = signal.convolve2d(convert_to_1channel(bmp), kernel, boundary='symm', mode='same')
print(conv)
fix = fix_rgb(conv)
bmparr_to_img(fix)

#x86_lst = format_for_x86(pad(convert_to_1channel(img_to_bmp('bnw.jpeg'))))