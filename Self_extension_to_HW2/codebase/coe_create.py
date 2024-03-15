from PIL import Image

# Load the PNG image
image = Image.open("tulip.png")
if image.mode != "RGB":
    image = image.convert("RGB")

# Open a .coe file for writing
with open("output.coe", "w") as coe_file:
    # Write the .coe file header
    coe_file.write("memory_initialization_radix=16;\n")
    coe_file.write("memory_initialization_vector=\n")

    # Get the image dimensions
    width, height = image.size

    # Iterate over the pixels and write their RGB values to the .coe file
    for y in range(height):
        for x in range(width):
            # Get the RGB values of the pixel
            rgb_tuple = image.getpixel((x, y))

            # Separate the values into r, g, and b
            r = rgb_tuple[0]
            g = rgb_tuple[1]
            b = rgb_tuple[2]

            # Convert the RGB values to hexadecimal and write to the .coe file
            pixel_hex = f"{r:02X}{g:02X}{b:02X}"
            coe_file.write(pixel_hex)

            # Add a comma and a newline, except for the last pixel
            if x < width - 1 or y < height - 1:
                coe_file.write(",\n")

# Close the .coe file
coe_file.close()
