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
                    |--regression_logs/    // Contains regression script logs

## Usage
TOOL REQUIRED: Cadence Incisive, GCC
### Run a simulation

#### run script
With `run` you can run a test by giving arguments in the command line.

`run` file will firstly compile AES C model code with GCC and then AES SV/UVM code with Xcelium.

-	To run a test: 
    - Go to `verif_uvc_aes/tb/xcelium/` directory.
    - Make sure `run` file has right execution privileges by using `chmod u+x run`
    - Use `./run` and give test name in argument.

#### Executions example:
- Run the test aes_test_cipher:
```sh
cd tb/xcelium
chmod u+x run
./run +UVM_TESTNAME=aes_test_cipher
```

### Run a regression
#### run_regression script
The purpose of  `run_regression` is to run all tests, check if they have passed or failed and then report results to the user in the console and in a log file.
- To run a regression: 
    -	Go to `verif_uvc_aes/tb/xcelium/` directory.
    - Make sure `run_regression` file has right execution privileges by using `chmod u+x run_regression`
    -	Use `./run_regression`.

#### Executions example:
-	Run a regression:
```sh
cd tb/xcelium
chmod u+x run_regression
./run_regression input/regression_config.txt
```
Logs are stored in `verif_uvc_aes/tb/xcelium/output/regression_log/` directory.



## TODO
  - Assertions
  - Add more comments to describe functions/tasks
  - Clean code


## Credits 
The UVM skeleton code was based from [UVM Code Gen](https://github.com/antoinemadec/uvm_code_gen)
