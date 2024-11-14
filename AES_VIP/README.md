# verif_uvc_aes
A simple UVM environment for all AES protocol-based IPs.

## Methods
**verif_uvc_aes** uses SV/[UVM](https://en.wikipedia.org/wiki/Universal_Verification_Methodology). 

## Features
According to the specification, this ATB VIP supports ATB protocol features below:
  - 128-bit plaintext and ciphertext data.
  - 128-bit encryption keys.
  - Cipher and decipher operation.

It is composed of :
- VIP (agent, interface, sequence, coverage)
  - top-level environment
    - testbench
    - env (scoreboard, VIP, coverage)
    - virtual sequence
    - VHDL DUT
    - C model DPI
- run script

:file_folder: Folders architecture and details :

    |--doc                                 // Contains AES VIP verification plan
    |--verif_uvc_aes/                      // Contains AES UVM agent files
        |--c_model/                        // Contains AES C reference model files
        |--dut/                            // Contains AES VHDL IP files
        |--sequences/                      // Contains AES UVM sequences files
        |--tb/                             // Contains testbench files
            |--tb_sv/                      // Contains top AES UVM environment files
                |--test/                   // Contains AES UVM test files
            |--xcelium/                    // Contains script files to run the simulation
                |--output/                 // Contains simulations results files

## Usage
TOOL REQUIRED: Cadence Incisive
### Run a simulation

#### run script
With `run` you can run a test by giving arguments in the command line.
1.	To run a test: 
    - Go to `verif_uvc_aes/tb/xcelium/` directory.
    - Use `./run`, by default `aes_test` will be simulated. If needed, use help panel with `./run -help` command to see options.


## TODO
  - Make test & sequence
  - Assertions
  - Add more comments to describe functions/tasks
  - Clean code


## Credits 
The UVM skeleton code was based from [UVM Code Gen](https://github.com/antoinemadec/uvm_code_gen)
