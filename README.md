# FPGA Basics

This repo contains a collection of FPGA projects targeting [Papilio Pro](https://papilio.cc/index.php?n=Papilio.PapilioPro) boards, which are based on the [Spartan 6 LX9 FPGA](http://www.xilinx.com/support/documentation/data_sheets/ds160.pdf). The code was written in VHDL using [Xilinx ISE Design Suite 14.7](https://www.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.html) (WebPACK Edition).

These projects are mostly based on [Introducing the Spartan 3E FPGA and VHDL](https://cdn.sparkfun.com/datasheets/Dev/FPGA/IntroToSpartanFPGABook.pdf) from [SparkFun](https://www.sparkfun.com/).

## Flashy Lights

The project under [flashy_lights](./flashy_lights) uses the LEDs on the [LogicStart MegaWing](https://papilio.cc/index.php?n=Papilio.LogicStartMegaWing) to display a sequence of patterns that are read from block RAM (configured as a single port ROM). It uses a simple counter to loop over addresses in the ROM. At each address a pattern of eight bits determines which LEDs are switched on.

The ROM can found in [flashy.coe](./flashy_lights/flashy.coe).

## Segment Counter

The project under [segment_counter](./segment_counter) uses the seven-segment display on the LogicStart MegaWing to display a hexadecimal counter. The segment_counter module uses a 36-bit counter, which is incremented on the rising edge of the clock signal. Bits 35-20 are shown on the seven segment display, with bits 35-28 also mapped onto the LEDs.

Although a video might be more helpful, here is a photo of _Segment Counter_:

[![Photo of Segment Counter](./images/segment_counter_small.jpg)](./images/segment_counter.jpg)

Note that the order of the LEDs is backwards from this perspective. 

## Segment Counter with Input

This project is an extension of _Segment Counter_. [segment_counter_input](./segment_counter_input) changes the behaviour of the counter so that it only changes when the joystick is being pushed left or right. When it is pushed to the left, the counter decrements, and when pushed to the right, the counter increments. The counter can be reset by pressing the joystick button for a moment.

The LEDs have also been changed to indicate which input has been registered.

## Simple VGA

The project under [simple_vga](./simple_vga) uses the VGA port on the LogicStart MegaWing to output a checkboard signal. Probably the most interesting part of this project is that it uses a Clock Divider IP Core to convert the board's 32MHz clock signal to 25.125MHz, which is required to generate a 640x480 VGA signal.

Here is a photo of _Simple VGA_ in action:

[![Photo of Simple VGA in action](./images/simple_vga_small.jpg)](./images/simple_vga.jpg)

## VGA Crosshair

Building on _Simple VGA_, the [vga_crosshair](./vga_crosshair) project displays two intersecting lines. The crosshair, or point of intersection, can be moved using the joystick. Movement is performed on the rising edge of the VSYNC signal, to avoid tearing.

90% of the way towards a playable first-person shooter, right?

[![Photo of VGA Crosshair in action](./images/vga_crosshair_small.jpg)](./images/vga_crosshair.jpg)

## References

* [Free-Range VHDL](http://freerangefactory.org/pdf/df344hdh4h8kjfh3500ft2/free_range_vhdl.pdf) from [Free Range Factory](http://freerangefactory.org)
* [Introducing the Spartan 3E FPGA and VHDL](https://cdn.sparkfun.com/datasheets/Dev/FPGA/IntroToSpartanFPGABook.pdf) from [SparkFun](https://www.sparkfun.com/)
* [ISE In-Depth Tutorial](https://www.xilinx.com/support/documentation/sw_manuals/xilinx13_3/ise_tutorial_ug695.pdf) from Xilinx
