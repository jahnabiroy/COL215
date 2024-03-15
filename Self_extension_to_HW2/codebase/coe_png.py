from PIL import Image


def coe_to_png(coe_file, png_file):
    # Open the .coe file and read its content
    with open(coe_file, "r") as file:
        content = file.readlines()

    # Initialize variables to store image data and configuration
    image_data = []
    data_started = False
    width = None

    for line in content:
        line = line.strip()
        if line.startswith("memory_initialization_radix="):
            radix = int(line.split("=")[1].rstrip(";"))
        elif line.startswith("memory_initialization_vector="):
            data_started = True
            values = line.split("=")[1].strip().strip(";").split(",")
            for value in values:
                value = value.strip()
                if value:
                    image_data.append(int(value, radix))
            if not width:
                width = len(values)

    # Determine the height of the image
    height = len(image_data) // width

    # Create a new image
    img = Image.new("L", (width, height))

    # Set the pixel values from the image data
    img.putdata(image_data)

    # Save the image as a PNG file
    img.save(png_file)


if __name__ == "__main__":
    coe_file = "lighthouse_bin_64.coe"  # Replace with the path to your .coe file
    png_file = "output.png"  # Replace with the desired output .png file path

    coe_to_png(coe_file, png_file)
    print(f"Conversion complete. Image saved to {png_file}")
