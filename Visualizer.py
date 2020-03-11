import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg


def img_to_bmp(path_to_img):
    img = mpimg.imread(path_to_img)
    return img


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



write_x86_file(format_for_x86(flatten_rgb(img_to_bmp('bnw.jpeg'))))