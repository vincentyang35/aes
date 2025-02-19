# aes128
A simple AES128 encryption/decryption IP core

## Methods
**aes128** uses VHDL

## Features
According to the specification, this AES128 IP supports features below:
  - AES-128 encryption and decryption standard as defined by the National Institute of Standards and Technology (NIST).
  - 128-bit plaintext and ciphertext data.
  - 128-bit encryption key.

It is composed of:
  - aes128.vhd - AES128 top module
  - aes128_lib.vhd - AES128 library
  - aes128_tb.vhd  - AES128 testbench

:file_folder: Folders architecture and details :

    |--AES_IP/                      // Contains aes128 IP files
        |--doc/                     // Contains documentation
        |--sim/                     // Contains testbench files
        |--src/                     // Contains source design files


## TODO
  - Add AXI-4 interface
  - Use submodules instead of functions

## Credits 
TODO 