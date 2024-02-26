# Serial communication on the DE10-Lite FPGA board
This project implements a Universal Asynchronous Receiver - Transmitter system on the Terasic DE10-Lite FPGA board with an adapter for RS-232. The system has two main tasks: to copy and return any incoming character and to send a predeterminded character on a button press(KEY0). The user can manually toggle parity checks with the SWO switch and then chose wheter the parity check is even or odd with SW1. Whilst recieving data a led will blink on the board. Any recieved character will in addition be shown in hex format on the inbuilt 7-segment dislplay on the board. 

# Modules
To give the system more structure it has been compartmentalised into six modules. There is two Clock Divider-modules, a CTRL-module which controls the flow of data, an RX-module that recieves data, a TX-module for sending data and a Top-module to tie it all together to one system. Ideally if you want to implement this system for yourself you should only need to edit the baudrate and databits in the Top Module. Here is an overview of the modules and their connections. If I were to remake this system I would probably try to reduce the amount of interconnections for a cleaner system, but I do not have the mental energy to deal with any of that redesign
![Screenshot 2024-02-26 115031](https://github.com/Jawny-E/FPGA_UART/assets/94108006/26b0affa-a25a-41db-9770-1843536b429f)

Full list of Ports and Signals in the system

|Name|I/O|Type|Function|
|----|---|----|--------|
|clk|
|rst_n|
|button_n|
|PARITET|
|PARITET_OP|
|rx_input|
|led_indicator|
|hex0|
|hex1|
|tx_output|
|tx_busy|
|tx_init|
|tx_data_to_send|
|recived_flag|
|recived_byte|

## Top level


## Ctrl Module

## TX Module

## RX Module 
