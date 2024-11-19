# AES128 Design and Verification project
This project includes a VHDL-based AES128 encryption/decryption IP core and its associated SV/UVM verification environment. 

:file_folder: Folders architecture and details :

    |--aes                
        |--AES_IP          // Contains AES128 IP, library and testbench
        |--AES_VIP         // Contains AES128 VIP, SV/UVM testbench and environment

## Getting Started

### Prerequisites
- VHDL simulator for the AES_IP (Vivado, ModelSim, GHDL etc.)
- UVM simulator for the AES_VIP (Run script only supports Xcelium)

### Installation
-  Clone the repository:
```sh
git clone https://github.com/vincentyang35/aes.git
```

### Usage
See AES_IP and AES_VIP README.md
