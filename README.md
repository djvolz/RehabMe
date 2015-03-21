This page contains information pertaining to FX3 firmware development.  See http://www.nuand.com/fx3 for available images and a brief summary of each image.

= Current Architecture =

The FX3 is the main connection between the host PC and the bladeRF device itself.  This connection handles:

* Configuring the FPGA
* Shuffling samples for RF TX/RX
* Firmware updates to the on-board SPI flash
* Control of the RF and other components through the FPGA via a UART link

This is handled by using alternate interface settings in the FX3 firmware.  Each alternate setting handles a specific operating condition.  Since the operating conditions are somewhat orthogonal, it can be seen that the device gets put into these different modes for long periods of time and doesn't cycle through them randomly.
{| class="wikitable"
!Alt. Interface Setting
!Name 
!Description
|-
|0                      
|NULL 
|No real operation here.  The device is mostly sitting idle and is just in a known state which doesn't really have any functional purpose.
|-
|1
|RF Link 
|Bulk endpoint interfaces for transmit and receive samples to go over the bus.  A separate set of bulk interfaces are used for communication with the peripherals hanging off the FPGA over the UART.  These peripherals include the trim DAC for the VCTCXO, Si5338 clock generator and LMS6002D FPRF transceiver. 
|-
|2
|SPI flash
|Used for updating and writing the firmware of the device. 
|-
|3
|FPGA Config
|Used for sending down an FPGA RBF file and loading the FPGA.
|}

= SPI Flash Layout =
The FX3 is booted from a 32 Mbit [http://www.macronix.com/en-us/Product/Pages/ProductDetail.aspx?PartNo=MX25U3235E MX25U3235EM2I] 1.8V SPI flash, with 64KiB and 32KiB blocks, 4KiB sectors, and 256 byte pages. This flash also stores the device's serial number, calibration, and (optionally) an FPGA bitstream. 

Below is a map of SPI flash layout.

{| class="wikitable"
!Offset (bytes) 
!Offset (page)
!Offset (64KiB EB)
!Length (bytes)
!Description
|-
|0x00000000
|0
|0
|0x30000
|FX3 Firmware
|-
|0x00030000
|768
|3
|0x100
|Calibration Data
|-
|0x00030100
|769
|3
|0xFF00
|Reserved for future calibration data
|-
|0x00040000
|1024
|4
|0x100
|FPGA autoload metadata
|-
|0x00040100
|1025
|4
|0x36FF00
|FPGA bitstream data region
|-
|0x003B0000 
|14848
|59
|0x5000
|Reserved
|}

== (To do) Calibration Data layout ==

== (To do) Flash autoload metadata layout ==

== OTP Section layout ==
An additional 4KiB one-time programmable (OTP) section is provided by the device. This is used to store the device's serial number/unique ID.

= Verifying USB Functionality =
* [http://www.usb.org/developers/ssusb/ssusbtools/ SuperSpeed USB Hardware/Software tools]

= Open tasks =
There are several issues in the FX3 firmware that should be resolved. 
* UART errors are not detected (framing/overflow)
* SPI errors are not detected (underflow/overflow)
* Once UART errors are detected, no way to report counters.  Need to develop diagnostic data interface.
* It would be really nice to have logging support in the FX3 firmware.
* Fatal errors in the FX3 firmware result in lockup.  Better to some how report to host problem occurred.
* Implement suspend/resume (low priority)
* Order of shutting down EPs and DMAs.  Should halt EP then DMA, or DMA then EP.  Or either works?
* Unclear if endpoint halt feature is implemented correctly.