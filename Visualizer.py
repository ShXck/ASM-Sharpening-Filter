import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from PIL import Image
import sys
from scipy import signal
import os


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

def show_img(bitmap):
    plt.imshow(bitmap)
    plt.show()

def show_filtered_img(width, height, dec):
    im = Image.new('L', (width, height))
    im.putdata(dec)
    im.show()

def decode(file):
    dec_lst = []

    with open(file, 'rb') as f:
        contents = f.read()
        tmp_lst = []
        for i in contents:
            tmp_lst.append(hex(i))
            if len(tmp_lst) == 4:
                new_number = append_hex(int(tmp_lst[1], 16), int(tmp_lst[0], 16))
                if(new_number > 990):
                    dec_lst.append(255)
                else:
                    dec_lst.append(new_number)   #" ".join([str(i) for i in tmp_lst[::-1][2:]])
                tmp_lst.clear()
        return np.asarray(dec_lst)

def append_hex(hex_a, hex_b):
    sizeof_b = 0
    while((hex_b >> sizeof_b) > 0):
        sizeof_b += 1
    sizeof_b += sizeof_b % 4
    return (hex_a << sizeof_b) | hex_b

def str_to_hex(str_hex):
    return int(str_hex, 16)


def run_filters():
    width = int(input("Inserte el ancho de imagen: "))
    height = int(input("Inserte el largo de imagen: "))

    os.system("nasm -f elf64 Input.asm -o input.o")
    os.system("ld input.o -o input")
    os.system("./input")

#run_filters()

img = img_to_bmp('bnw.jpeg')

adj = convert_to_1channel(img)

dec = decode('new_file.txt')

#adjusted = convert_to_1channel(img)

width = 259
height = 194

#exp = [[1,2,3], [4,5,6], [7,8,9]]
kernel = [[0,-1,0], [-1,5,-1], [0,-1,0]]

out = signal.convolve2d(adj, kernel, boundary='fill', mode='same')

print("REAL: ", out.flatten()[:100])
print("OWN: ", dec[:100])

show_filtered_img(width, height, dec)


#new_bmp = format_for_bmp(width, height, dec)
#print(len(new_bmp[0]))
#bmparr_to_img(new_bmp)
#bmparr_to_img(fix_rgb(out))

#to_bnw('jbuilding.jpeg', 'bnw1.jpeg')
#write_x86_file(format_for_x86(pad(convert_to_1channel(img_to_bmp('bnw.jpeg')))))