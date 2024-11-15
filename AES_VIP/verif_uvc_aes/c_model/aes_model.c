#include "aes_model.h"

///////////////////////////////////////////////////////
// AES functions declaration
///////////////////////////////////////////////////////

// Applies the SubBytes transformation, substituting each byte in matrix_in with a corresponding value from sbox
void subbytes_f(uint8_t matrix_in[4][4]);

// Applies the ShiftRows transformation, shifting rows of matrix_in
void shiftrows_f(uint8_t matrix_in[4][4]);

// Applies the MixColumns transformation, mixing columns of matrix_in
void mixcolumns_f(uint8_t matrix_in[4][4]);

// Adds the round key to the state matrix by performing an XOR operation between the matrix_in and key_w
void addroundkey_f(uint8_t matrix_in[4][4], uint8_t key_w[4][4]);

// Generates round keys from the initial key
void key_expansion_f(int key_in[4], uint8_t w[11][4][4]);

// Applies the InvShiftRows transformation, shifting rows of matrix_in
void invshiftrows_f(uint8_t matrix_in[4][4]);

// Applies the InvSubBytes transformation, substituting each byte in matrix_in with a corresponding value from inv_sbox
void invsubbytes_f(uint8_t matrix_in[4][4]);

// Applies the InvMixColumns transformation, mixing columns of matrix_in
void invmixcolumns_f(uint8_t matrix_in[4][4]);



///////////////////////////////////////////////////////
// AES sub-functions declaration
///////////////////////////////////////////////////////

// Rotates 24 bits to the left and 8 bits to the right
void rotword(uint32_t *word);

// Applies byte substitution using the sbox
void subword(uint32_t *word);

// Function to multiply by 0x2 in GF(2^8)
uint8_t gf_mult(uint8_t a);

// Function to multiply by 0x9 in GF(2^8)
uint8_t gf_mult_09(uint8_t a);

// Function to multiply by 0xB in GF(2^8)
uint8_t gf_mult_0b(uint8_t a);

// Function to multiply by 0xD in GF(2^8)
uint8_t gf_mult_0d(uint8_t a);

// Function to multiply by 0xE in GF(2^8)
uint8_t gf_mult_0e(uint8_t a);


///////////////////////////////////////////////////////
// Test & utils functions declaration
///////////////////////////////////////////////////////

// Exported function to UVM
// Contains AES encryption and decryption
int compare_to_c_model(int data_in[3], int keu_in[3], int data_out[3], int cipher_phase);

// Changes din data format
void matrix_correction(int data_in[3], uint8_t matrix_in[4][4]);

// Compare matrix from the dut to the expected matrix from the C model
int compare_matrix(uint8_t matrix_dut[4][4], uint8_t matrix_expected[4][4]);

// Print a given 4x4 matrix with a message
void print_matrix(uint8_t matrix_in[4][4], char* message);

// Main
int main()
{
    return 0;
}

///////////////////////////////////////////////////////
// Functions 
///////////////////////////////////////////////////////

int compare_to_c_model(int data_in[3], int key_in[3], int data_out[3], int cipher_phase)
{
  ///////////////////////////////////////////////////////
  // Variable
  ///////////////////////////////////////////////////////

  // VHDL DUT variables
  uint8_t data_out_matrix[4][4];
  bool cipher_status;

  // C model variables
  uint8_t golden_matrix[4][4];
  uint8_t w[11][4][4];
  int matrix_compare = 0;

  ///////////////////////////////////////////////////////
  // Initilization
  ///////////////////////////////////////////////////////

  if(cipher_phase == 1){
    cipher_status = true;
  }
  else {
    cipher_status = false;
  }

  matrix_correction(data_in, golden_matrix);
  matrix_correction(data_out, data_out_matrix);
  /*
  for(int i = 0; i<4; i++){
    printf("key[%d]: %x\n", i, key_in[i]);
  }
  */
  key_expansion_f(key_in, w);
  /*
  print_matrix(golden_matrix, "Data_in after initialization");
  for(int i = 0; i<11; i++){
    printf("w[%d]\n",i);
    print_matrix(w[i], "");
  }
  */

  ///////////////////////////////////////////////////////
  // Cipher or Decipher 
  // If cipher_phase == 1 -> cipher_status = true -> Encryption
  // If cipher_phase == 0 -> cipher_status = false -> Decryption
  ///////////////////////////////////////////////////////

  // Encryption (cipher)
  if(cipher_status == true) {
    ///////////////////////////////////////////////////////
    // Round 0
    ///////////////////////////////////////////////////////

    addroundkey_f(golden_matrix, w[0]);
    //printf("\n\n------------------------------------------------\n\nRound 0\n");
    //print_matrix(golden_matrix, "Data_in after addroundkey");

    ///////////////////////////////////////////////////////
    // Round 1 to Nr -1
    ///////////////////////////////////////////////////////

    for(int round = 1; round < Nr; round++){
      //printf("\nRound %d\n", round);
      subbytes_f(golden_matrix);
      //print_matrix(golden_matrix, "Data_in after subbytes");

      shiftrows_f(golden_matrix);
      //print_matrix(golden_matrix, "Data_in after shitfrows");

      mixcolumns_f(golden_matrix);
      //print_matrix(golden_matrix, "Data_in after mixcolumns");

      addroundkey_f(golden_matrix, w[round]);
      //print_matrix(golden_matrix, "Data_in after addroundkey");
    }

    ///////////////////////////////////////////////////////
    // Round Nr
    ///////////////////////////////////////////////////////

    //printf("Round %d\n", Nr);
    subbytes_f(golden_matrix);
    //print_matrix(golden_matrix, "Data_in after subbytes");

    shiftrows_f(golden_matrix);
    //print_matrix(golden_matrix, "Data_in after shitfrows");

    addroundkey_f(golden_matrix, w[Nr]);
    //print_matrix(golden_matrix, "Data_in after addroundkey");
  }

  // Decryption (decipher)
  else {
    ///////////////////////////////////////////////////////
    // Round 0
    ///////////////////////////////////////////////////////
    //printf("Decipher\n");
    addroundkey_f(golden_matrix, w[Nr]);
    //printf("\n\n------------------------------------------------\n\nRound 0\n");
    //print_matrix(golden_matrix, "Data_in after addroundkey");

    ///////////////////////////////////////////////////////
    // Round 1 to Nr -1
    ///////////////////////////////////////////////////////

    for(int round = 1; round < Nr; round++){
      //printf("\nRound %d\n", round);
      invshiftrows_f(golden_matrix);
      //print_matrix(golden_matrix, "Data_in after invshiftrows_f");

      invsubbytes_f(golden_matrix);
      //print_matrix(golden_matrix, "Data_in after invsubbytes_f");

      addroundkey_f(golden_matrix, w[Nr-round]);
      //print_matrix(golden_matrix, "Data_in after addroundkey_f");

      invmixcolumns_f(golden_matrix);
      //print_matrix(golden_matrix, "Data_in after invmixcolumns_f");
    }

    ///////////////////////////////////////////////////////
    // Round Nr
    ///////////////////////////////////////////////////////

    //printf("Round %d\n", Nr);
    invshiftrows_f(golden_matrix);
    //print_matrix(golden_matrix, "Data_in after invshiftrows_f");

    invsubbytes_f(golden_matrix);
    //print_matrix(golden_matrix, "Data_in after invsubbytes_f");

    addroundkey_f(golden_matrix, w[0]);
    //print_matrix(golden_matrix, "Data_in after addroundkey_f");
  }
  ///////////////////////////////////////////////////////
  // Compare expected and reference
  ///////////////////////////////////////////////////////

  matrix_compare = compare_matrix(data_out_matrix, golden_matrix);
  return matrix_compare;    
}


// AES functions 
void key_expansion_f(int key_in[4], uint8_t w[11][4][4]){
   uint32_t temp;
   uint32_t expanded_keys[44];

    // Copy the original key into the first 4 words of the expanded key
    for (int i = 0; i < 4; i++) {
      expanded_keys[i] = key_in[3-i];
    }

    // Generate the remaining words
    for (int i = 4; i < 44; i++) {
        temp = expanded_keys[i - 1];

        if (i % 4 == 0) {
            rotword(&temp);
            subword(&temp);
            temp = temp ^ Rcon[i/4-1];
        }

        expanded_keys[i] = expanded_keys[i-4] ^ temp;
    }
    for(int i = 0; i < 11; i++){
      for(int j = 0; j <4; j++){
        //printf("\nexpendandkey[%d]:%x\n",(i*4)+j, expanded_keys[(i*4)+j]);
        for(int k = 0; k <4; k++){
          w[i][k][j] = expanded_keys[(i*4)+j] >> (24-(8*k)); 
          //printf("\nw[%d][%d][%d]: %x", i,j,k,w[i][k][j]);
        }
      }
    }
}


void subbytes_f(uint8_t matrix_in[4][4]){
  uint8_t x, y;
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      y = (matrix_in[i][j]) & 0xf;
      x = (matrix_in[i][j] >> 4) & 0xf;
      matrix_in[i][j] = sbox[x][y];
    }
  }
}

void shiftrows_f(uint8_t matrix_in[4][4]){
  uint8_t tmp1, tmp2, tmp3;
  tmp1 = matrix_in[1][0];
  matrix_in[1][0] = matrix_in[1][1];
  matrix_in[1][1] = matrix_in[1][2];
  matrix_in[1][2] = matrix_in[1][3];
  matrix_in[1][3] = tmp1;

  tmp1 = matrix_in[2][0];
  tmp2 = matrix_in[2][1];
  matrix_in[2][0] = matrix_in[2][2];
  matrix_in[2][1] = matrix_in[2][3];
  matrix_in[2][2] = tmp1;
  matrix_in[2][3] = tmp2;

  tmp1 = matrix_in[3][0];
  tmp2 = matrix_in[3][1];
  tmp3 = matrix_in[3][2];
  matrix_in[3][0] = matrix_in[3][3];
  matrix_in[3][1] = tmp1;
  matrix_in[3][2] = tmp2;
  matrix_in[3][3] = tmp3;

}

void mixcolumns_f(uint8_t matrix_in[4][4]){
  uint8_t matrix_tmp[4][4];
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      matrix_tmp[i][j] = matrix_in[i][j];
    }
  }

  for (int j = 0; j < 4; j++) {
    matrix_in[0][j] = gf_mult(matrix_tmp[0][j]) ^ (gf_mult(matrix_tmp[1][j]) ^ matrix_tmp[1][j]) ^ matrix_tmp[2][j] ^ matrix_tmp[3][j];
    matrix_in[1][j] = matrix_tmp[0][j] ^ gf_mult(matrix_tmp[1][j]) ^ (gf_mult(matrix_tmp[2][j]) ^ matrix_tmp[2][j]) ^ matrix_tmp[3][j];
    matrix_in[2][j] = matrix_tmp[0][j] ^ matrix_tmp[1][j] ^ gf_mult(matrix_tmp[2][j]) ^ (gf_mult(matrix_tmp[3][j]) ^ matrix_tmp[3][j]);
    matrix_in[3][j] = (gf_mult(matrix_tmp[0][j]) ^ matrix_tmp[0][j]) ^ matrix_tmp[1][j] ^ matrix_tmp[2][j] ^ gf_mult(matrix_tmp[3][j]);
  }
}

void addroundkey_f(uint8_t matrix_in[4][4], uint8_t key_w[4][4]){
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      matrix_in[i][j] = matrix_in[i][j] ^ key_w[i][j];
    }
  }
}


void invshiftrows_f(uint8_t matrix_in[4][4]){
  uint8_t tmp1, tmp2, tmp3;
  tmp1 = matrix_in[1][0];
  tmp2 = matrix_in[1][1];
  tmp3 = matrix_in[1][2];
  matrix_in[1][0] = matrix_in[1][3];
  matrix_in[1][1] = tmp1;
  matrix_in[1][2] = tmp2;
  matrix_in[1][3] = tmp3;

  tmp1 = matrix_in[2][0];
  tmp2 = matrix_in[2][1];
  matrix_in[2][0] = matrix_in[2][2];
  matrix_in[2][1] = matrix_in[2][3];
  matrix_in[2][2] = tmp1;
  matrix_in[2][3] = tmp2;

  tmp1 = matrix_in[3][0];
  matrix_in[3][0] = matrix_in[3][1];
  matrix_in[3][1] = matrix_in[3][2];
  matrix_in[3][2] = matrix_in[3][3];
  matrix_in[3][3] = tmp1;
}

void invsubbytes_f(uint8_t matrix_in[4][4]){
  uint8_t x, y;
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      y = (matrix_in[i][j]) & 0xf;
      x = (matrix_in[i][j] >> 4) & 0xf;
      matrix_in[i][j] = inv_sbox[x][y];
    }
  }
}

void invmixcolumns_f(uint8_t matrix_in[4][4]){
  uint8_t matrix_tmp[4][4];
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      matrix_tmp[i][j] = matrix_in[i][j];
    }
  }

  for (int j = 0; j < 4; j++) {
    matrix_in[0][j] = gf_mult_0e(matrix_tmp[0][j]) ^ gf_mult_0b(matrix_tmp[1][j]) ^ gf_mult_0d(matrix_tmp[2][j]) ^ gf_mult_09(matrix_tmp[3][j]);
    matrix_in[1][j] = gf_mult_09(matrix_tmp[0][j]) ^ gf_mult_0e(matrix_tmp[1][j]) ^ gf_mult_0b(matrix_tmp[2][j]) ^ gf_mult_0d(matrix_tmp[3][j]);
    matrix_in[2][j] = gf_mult_0d(matrix_tmp[0][j]) ^ gf_mult_09(matrix_tmp[1][j]) ^ gf_mult_0e(matrix_tmp[2][j]) ^ gf_mult_0b(matrix_tmp[3][j]);
    matrix_in[3][j] = gf_mult_0b(matrix_tmp[0][j]) ^ gf_mult_0d(matrix_tmp[1][j]) ^ gf_mult_09(matrix_tmp[2][j]) ^ gf_mult_0e(matrix_tmp[3][j]);
  }
}

// Subfunctions

uint8_t gf_mult(uint8_t a) {
  if (a & 0x80) { // Check if MSB is 1
      return (a << 1) ^ 0x1b;
  } else {
      return a << 1;
  }
}

uint8_t gf_mult_09(uint8_t a) {
  a = gf_mult(gf_mult(gf_mult(a))) ^ a; // a*8 + a
  return a;
}

uint8_t gf_mult_0b(uint8_t a) {
  a = ((gf_mult(gf_mult(gf_mult(a)))) ^ gf_mult(a)) ^ a; // a*8 + a*2 + a
  return a; 
}

uint8_t gf_mult_0d(uint8_t a) {
  a = ((gf_mult(gf_mult(gf_mult(a)))) ^ (gf_mult(gf_mult(a)))) ^ a; // a*8 + a*4 + a
  return a;
}

uint8_t gf_mult_0e(uint8_t a) {
  a = ((gf_mult(gf_mult(gf_mult(a)))) ^ (gf_mult(gf_mult(a)))) ^ (gf_mult(a)); // a*8 + a*4 + a*2
  return a;
}

void rotword(uint32_t *word) {
  uint32_t temp = (*word << 8) | (*word >> 24);
  *word = temp;
}

void subword(uint32_t *word) {
  uint8_t x,y, wordbyte;
  uint32_t result = 0;
    for (int i = 0; i < 4; i++) {
        wordbyte = (*word >> (24 - 8 * i)) & 0xFF;
        x = (wordbyte >> 4) & 0x0F;
        y = wordbyte & 0x0F;
        result |= sbox[x][y] << (24 - 8 * i);
    }
  *word = result;
}

// Test & utils

void matrix_correction(int data_in[3], uint8_t matrix_in[4][4]){
  matrix_in[0][0] = (data_in[3] >> 24) & 0xff;
  matrix_in[1][0] = (data_in[3] >> 16) & 0xff;
  matrix_in[2][0] = (data_in[3] >> 8) & 0xff;
  matrix_in[3][0] = data_in[3] & 0xff;

  matrix_in[0][1] = (data_in[2] >> 24) & 0xff;
  matrix_in[1][1] = (data_in[2] >> 16) & 0xff;
  matrix_in[2][1] = (data_in[2] >> 8) & 0xff;
  matrix_in[3][1] = data_in[2] & 0xff;

  matrix_in[0][2] = (data_in[1] >> 24) & 0xff;
  matrix_in[1][2] = (data_in[1] >> 16) & 0xff;
  matrix_in[2][2] = (data_in[1] >> 8) & 0xff;
  matrix_in[3][2] = data_in[1] & 0xff;

  matrix_in[0][3] = (data_in[0] >> 24) & 0xff;
  matrix_in[1][3] = (data_in[0] >> 16) & 0xff;
  matrix_in[2][3] = (data_in[0] >> 8) & 0xff;
  matrix_in[3][3] = data_in[0] & 0xff;
}

void print_matrix(uint8_t matrix_in[4][4], char* message){
  printf("Printing %s:\n",message);
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      printf("%02x ",matrix_in[i][j]);
    }
      printf("\n");
  }
}

int compare_matrix(uint8_t matrix_dut[4][4], uint8_t matrix_expected[4][4]){
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < 4; j++) {
      if(matrix_dut[i][j] != matrix_expected[i][j]){
        printf("\nError: in compare_matrix");
        print_matrix(matrix_dut, "DUT output");
        print_matrix(matrix_expected, "C model reference");
        return 0;
      }
    }
  }
  //printf("\nOk compare");
  return 1;
}


