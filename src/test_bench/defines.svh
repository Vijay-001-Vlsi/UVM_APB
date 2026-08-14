`timescale 1ns/100ps
`define DATA_WIDTH 32
`define  ADDR_WIDTH 9
`define MEM_DEPTH 256
`define num_transaction 100
typedef enum bit[1:0]{idle,setup,access}states;

