# Serial communication on the DE10-Lite FPGA board
This project implements a Universal Asynchronous Receiver - Transmitter system on the Terasic DE10-Lite FPGA board with an adapter for RS-232. The system has two main tasks: to copy and return any incoming character and to send a predeterminded character on a button press(KEY0). The user can manually toggle parity checks with the SWO switch and then chose wheter the parity check is even or odd with SW1. Whilst recieving data a led will blink on the board. Any recieved character will in addition be shown in hex format on the inbuilt 7-segment dislplay on the board. 

# Modules
To give the system more structure it has been compartmentalised into six modules. There is two Clock Divider-modules, a CTRL-module which controls the flow of data, an RX-module that recieves data, a TX-module for sending data and a Top-module to tie it all together to one system. Ideally if you want to implement this system for yourself you should only need to edit the baudrate and databits in the Top Module. Here is an overview of the modules and their connections. If we were to remake this system we would probably try to reduce the amount of interconnections for a cleaner system, but none of us do not have the mental energy to deal with any of that redesign right now
![Screenshot 2024-02-26 115031](https://github.com/Jawny-E/FPGA_UART/assets/94108006/26b0affa-a25a-41db-9770-1843536b429f)

Full list of Ports and Signals in the system

|Name|I/O|Type|Function|
|----|---|----|--------|
|clk|Input|std_logic|50MHz clock|
|rst_n|Input|std_logic|Reset system|
|button_n|Input|std_logic|Send a predetermined character|
|PARITET|Input|std_logic|Turn parity on/off|
|PARITET_OP|Input|std_logic|Determine even or odd parity|
|rx_input|Input|std_logic|Recieve serial data|
|led_indicator|Output|std_logic|Blinks when a message has been recieved|
|hex0|Output|std_logic_vector(7...0)|Shows HEX of last recieved character|
|hex1|Output|std_logic_vector(7...0)|Shows HEX of last recieved character|
|tx_output|Output|std_logic|Sends serial message|
|tx_busy|Signal|std_logic|Is high whilst message is sending|
|tx_init|Signal|std_logic|Pulse indicates that a message should be sent|
|tx_data_to_send|Signal|std_logic(7...0)|Data to transfer in binary|
|recived_flag|Signal|std_logic|Pulse indicates recieved message|
|recived_byte|Signal|std_logic|Recieved data|

## Top level


## Ctrl Module

## TX Module

## RX Module 
