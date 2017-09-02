#!/usr/bin/env python2
import sys
import os
from PIL import Image
import serial
import time
from subprocess import call


SERIAL_BUFFER_SIZE = 32
SERIAL_PORT = '/dev/ttyACM0'
SERIAL_BAUD = 9600
TIMEOUT = 2000
MARQUEES_PATH = '/emulators/mame/scripts/marquees'


def millis():
    return int(round(time.time() * 1000))


def main(romname):
    filename = os.path.join(MARQUEES_PATH, romname + '.png')
    if not os.path.exists(filename):
        sys.exit(1)

    im = Image.open(filename)

    pixels = list(im.getdata())

    if len(pixels) != 256:
        print("Image is of the wrong size, must be 32x8 pixel PNG file")
        sys.exit(1)

    image = []

    for pixel in pixels:
        image.append(pixel[0])
        image.append(pixel[1])
        image.append(pixel[2])

    call([
        "stty", "-F", SERIAL_PORT, str(SERIAL_BAUD), "time", "0", "-hupcl", "-brkint", "-icrnl", "-imaxbel", "-opost", "-isig",
        "-icanon", "-iexten", "-echo", "-echoe", "-echok", "-echoctl", "-echoke"
    ])

    ser = serial.Serial(SERIAL_PORT, SERIAL_BAUD)
    time.sleep(2)
    ser.write('mode_data_1\n')

    in_buffer = ""

    try:
        start = millis()
        while in_buffer[-5:] != "READY":
            in_buffer += ser.read(ser.inWaiting())
            if millis() - start > TIMEOUT:
                print('Buffer: %s' % in_buffer)
                raise Exception('Handshake timeout')

        for position in range(0, len(image), SERIAL_BUFFER_SIZE):
            ser.write(image[position:position + SERIAL_BUFFER_SIZE])
            in_buffer = ""
            start = millis()
            while in_buffer[-5:] != "BLOCK" and in_buffer[-6:] != "FINISH":
                if millis() - start > TIMEOUT:
                    print("Exception hit: '" + in_buffer + "'")
                    raise Exception('Transfer timeout')
                in_buffer += ser.read(ser.inWaiting())
            print("Written %d bytes" % SERIAL_BUFFER_SIZE)
        print("Image sent")
    except Exception as error:
        print(error)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("No romname specified")
        sys.exit(1)

    main(sys.argv[1])
