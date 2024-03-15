"""
grayscale image = 2D matrix of 256*256. 
Image should be stored in 1-D array format in block
RAM, that from address 0 (0000(sub)16) in row major format.
A 3x1 filter (shown in red in Figure 3) is used to calculate the gradient of the image.

Output pixel value is summation of element-wise multiplication between filter value
and input image pixel as shown in the given equation. Input image pixel at location
(i,j) is denoted by I(i, j), output pixel as O(i, j).
j < 0  and j > 255 => set it to 0.

final output image => negative clamped to 0 and greater than 255 clamped to 255.

"""
import numpy as np
from PIL import Image

image_path = "polaris.png"
image = Image.open(image_path)
if image.mode != "L":
    image = image.convert("L")
mat = np.asarray(image)

if mat.shape != (256, 256):
    mat = np.resize(mat, (256, 256))


arr = np.zeros((256, 256))

for row in range(256):
    for col in range(256):
        if col == 0:
            k = 1 * mat[row][col + 1] - 2 * mat[row][col] + 1 * 0
        elif col == 255:
            k = 1 * 0 - 2 * mat[row][col] + 1 * mat[row][col - 1]
        else:
            k = 1 * mat[row][col + 1] - 2 * mat[row][col] + 1 * mat[row][col - 1]

        k = max(0, min(255, k))
        arr[row][col] = k


output_image = Image.fromarray(arr)
if output_image.mode != "RGB":
    output_image = output_image.convert("RGB")
output_image.save("output_image_polaris.png")
