# FPGA_2048_Game
2048 Game created via Verilog, loaded on an FPGA board and VGA monitor.

CONTRIBUTORS: Bradley Schulz, Brian Kwon
 
INTRODUCTION:

We implemented the popular game “2048” using an FPGA board and VGA display. 2048 is a game that has a 4x4 grid, in which each tile either has a numerical value or is empty. The player is able to move up, down, left, or right and that each movement causes all non-empty tiles on the grid to shift to that direction, filling in the empty spaces and combining adjacent tiles of the same value. Two tiles of the same value can be combined to result in one tile, where the new value becomes the sum of the two values. Another big aspect about the game is that all values are powers of 2 starting with the value 2.
 
Whenever the game is reset, the board randomly gives a tile a starting value of either 2 or 4 with a higher probability of adding a 2. Also, whenever the player makes a move, an empty tile after the move is randomly picked and the value of 2 or 4 is placed there. The game is over when there are no more possible moves, meaning that there are no empty tiles left on the board and no two adjacent tiles are of equivalent value. At this point, the player can choose to reset the board and start over to try to get a higher score. The score is calculated as the sum of all values on the board at that time. The user’s goal is to make this score as high as possible before there are no more possible moves by repeatedly combining equivalent tiles to create tiles of higher and higher value.
 

DESIGN:

We decomposed our design into the following modules:
Buttons to debounce and process the button inputs
Movement module to move the tile values based on the button input
Random number generator to randomly fill an empty tile with a 2 or 4
Gamestate calculator to calculate the score and determine if the game is over
VGA display driver composed of individual tiles and digits within those tiles
Seven-segment display driver to show the score on the 7-segment display
 
The overall architecture is shown in the figure below, and more detailed descriptions of each module follow.

![Module Block Diagram](/Images/Image1.png)

The button module takes the noisy button input and outputs three 1 clock pulses after the button has been high for a specified period of time. Three clock pulses are generated to trigger 3 moves, as three single movements on the board corresponds to one complete update in the game (described in more detail later). Decouncing—waiting for the button to be high for a sufficient amount of time—is necessary because of imperfections in the electrical contacts within the button which can cause the unprocessed button output to oscillate before stabilizing. This creates multiple positive edges, which could trigger unnecessary updates several times on accident.
 
The tile values are represented as a 64-bit vector, with groups of 4 bits corresponding to one tile. Since each tile’s value is always a power or 2, the value of each tile can be stored as that power of 2. The final tilevals vector is all the tile’s exponents concatenated together in a 64-bit vector with the rows ordered from left to right, top to bottom. This means that the lowest four bits are the top left and the highest 4 bits are the bottom right.
The movement module takes the button inputs and updates the current board according to what button was pressed. For example, if the up button was pressed, the movement module would take the current board, apply the up movement, and output the updated board. The movement module takes the 64-bit input vector and converts it into a 2-dimensional array with 4 rows and 4 columns to make it easier to process in a for-loop. First, if the reset button is pressed, the module sets every array element to 0 and passes this as the updated board output. Second, if the up, down, left, or right button is pressed, the module performs a similar for-loop to all of them. This for-loop generates identical logic for each column for the up and down movements, and each row for the left and right movements. Within the body of the for loops, there is an if-else statement that first checks if the top tile, for the up movement, is empty. If so, then all the tiles below it are shifted up by one. If not, it checks if the top and the adjacent tile below are of equivalent value. If this is the case, then the combination happens, and the tiles below are also shifted up. If neither of these are true, then the module moves on to the tile below the top one, which checks for the same conditions and does the same shifting as above if the conditions are met. This same logic is also applied to the second tile below the top if both conditions were false for the second tile. In the end, the updated board has a one space shift according to the button that was pressed. In the original 2048 game, a move results in not just one shift, but a maximum shift until all empty tiles are on the other side and all combinations have happened. To replicate this, we simply made one button press equivalent to three presses, which causes 3 updates whose net result is an updated board identical to what would be produced by the original 2048 game.
 
The random number generator module pseudo-randomly selects an empty cell and fills it with a 2 or a 4 every time a button is pressed. The inputs to this module are a clock, the button inputs, a reset signal, and the current values of the tiles. The outputs are the updated tile values with the randomly added number and a signal that is high while the random number generation is in progress. This module generates a new random number with every third pulse of any of the button inputs, since this corresponds to one press of a button by the user. Every time a new random number is to be generated, this module generates the location of the new number in the grid and the value of the new number. To make this happen, this module uses an internal counter that increments at every positive clock edge. The lower 4 bits of this counter are used to determine the value of the new tile. If the value of the lower 4 bits is less than 11 then the value is 2; otherwise, the new value is 4. This makes the new value a 2 11/16 or 68.75% of the time. Picking the index of the new value is more complex, since only empty tiles can have values added to them. An internal state variable, updated every time a new number is requested, selects which bits within the internal counter to use as the index in the grid. When a new number is requested, the module checks to see if that index is empty; if it is, it places the new value there. But if the tile already has a nonzero value, then the module waits until the “random” index updates at the next clock cycle so it can check a different tile in the grid. Since finding a valid random number may take several clock cycles, the module keeps the “waiting” output high until it finds a valid tile in the grid to update. 
 
A designated gamestate module calculates the score and determines if the game is over. These tasks are handled individually within this module, and each corresponds to a specific output. The score is calculated by summing all the individual tile values. Since the values are represented as a power of 2, the value “1” must be left-shifted by the value of each tile before summing them. To determine if the game is over, the module uses combinational logic to check if all the tiles are full and that now row or column has adjacent tiles with the same value.
 
The four digit seven-segment display on the Nexys3 board shows the user’s current score. There is a dedicated module to drive the seven-segment display given a master clock, multiplexing clock, and four 4-bit numbers to display. The seven-segment displays are multiplexed, as all their cathodes are connected and each one is turned on by providing power to the proper anode. Therefore, only one seven-segment can be activated at any given point in time and the activated cathodes must switch when the active anode updates. The “segdisplay” module performs this multiplexing, switching the activated display at each positive edge of the multiplexing clock. It uses an internal function to convert the input 4-bit numbers to the corresponding cathode activations.
 
Driving the VGA is a fairly complicated task, as the output is driven pixel by pixel on the final display. To break it down into more manageable pieces, the grid was broken down into individual tiles, with each tile containing 4 digits. The tiles are parameterized modules, where the parameters are the x and y indices in the grid (x and y range from 0 to 3 since it is a 4x4 grid). The overall display module instantiates all 16 tiles and sets the final output driving the display equal to the output from each tile based on what pixel is currently being driven. It also sets the screen to be gray in areas not corresponding to any tiles.
 
![Tile Pixels](/Images/Image2.png)
 
Each tile takes its current value as an input and is responsible for giving the tile its correct background color and displaying the numerical value of the tile on the screen in up to 4 digits. It creates these digits using another module responsible for displaying a digit. This digit module is modeled after a seven-segment display and sets the output to white when the current pixel location corresponds to a segment that should be turned on, and black otherwise. The tile module combines the outputs of all 4 digits, adds the background color in pixels that are not being driven by any of the digits, and then sends the pixel values back to the main display module.
 
![Digits Pixels](/Images/Image3.png)

All these tile and digit modules are parameterized, so they can be reused but correspond to different locations on the screen.
 
 
SIMULATION DOCUMENTATION:

Since the display output is very messy and changes with each successive pixel, verifying the operation of the display modules in simulation was not worth the effort. Instead, we wrote a top module (display_top.v)  that just displays a range of hard-coded values on the grid to verify that all the colors and numbers display properly. Testing each version of the code took longer than simply simulating it because of the need to compile all the modules, but the overall debugging time was less than if we had to write a testbench and analyze waveforms to verify that each of the 300,000+ pixels were being driven correctly. During this testing, we ran into a few issues with correctly indexing the location on the screen and getting the padding correct between tiles and digits, but all the issues were manageable and we were able to get the display working with just under 2 hours of testing.
 
We tested the random number generator with its own designated testbench. This testbench creates a sample set of board values, and then uses a verilog task to simulate three button pulses (since that is the output for the button modules for one user button press) to cause the module to generate a new random value. Then, this task waits until the “waiting” output goes low before exiting the task. The testbench calls this task several times before exiting to ensure that the generator always fills in empty grid tiles.
 
Through testing, we found issues with indexing to the correct cell, the generator not being able to reliably find an empty cell and getting stuck, and new values overwriting old ones. We fixed all these issues by ensuring the module correctly indexes into the input values to make sure it correctly examines each cell.

![Waveform 1](/Images/Image4.png)
 
The screenshot above shows simulation generation of pseudo-random numbers. After three button pulses, the “gen_active” signal goes high until a new value is generated and “out_vals” changes. This waveform also demonstrates that new values are only added where the value was previously “0” and that new values are only “1” or “2”. Note that each hexadecimal digit in the bottom two signals is the power of 2 of a single tile.
 
The gamestate calculation module was also tested with its own dedicated testbench. This testbench simulates setting the board to different configurations and verifying that the gamestate calculator outputs the correct values for each configuration. This involves verifying two things:
 1. The score is correctly calculated as the sum of all the tiles on the board
 2. If there are no available moves, it sets its “game_over” output high

![Waveform 2](/Images/Image5.png) 

The waveforms above demonstrate both requirements working properly. The “test_vals” register represents the state of the tiles, where each hexadecimal digit is the the power of 2 of the tile’s value and each group of 4 consecutive values corresponds to one row. The “game_over” signal goes high once there are no more available moves, which is the case with the tile values set at 240ns and 320ns into simulation. The testbench checks the score of the game by calculating the correct score independent from the gamestate module so it can be compared to the output from the gamestate module. 
 
Finally, the movement module was also tested using example board and tile values. A button value was pulsed and the output board was checked manually to make sure that the values all ended up in the correct spot after the update.
 
Lastly, below is a screenshot of our design summary report:
![Design Summary Report](/Images/Image6.png)


CONCLUSION:

Our project implements the game “2048” with 5 button inputs, the game displayed on a 640x480 VGA display, and the score shown on a 4 digit seven-segment display. We modularized the display by creating individual tiles in the board and then four digits within those tiles to display the value of the tile. To register movements, there is a module to register the button presses and update the display accordingly. Then, a pseudo-random number generator adds a new value to an empty tile in the board. The game is over when all the tiles are full and no moves remain.
 
We encountered difficulties in driving the VGA display, since all the computations happen very fast and there is a lot of detail that must be displayed in the final image. Translating the button inputs to board updates was also difficult because there are a lot of possible movements and numerous different cases to consider. Finding an efficient and effective way to register all the movements proved quite challenging.
 
One of the biggest challenges we faced was in the movement module. The first movement module we came up with used an algorithm that would directly replicate the 2048 game by max shifting per one button press. This first gave us a problem that we have exceeded the max number of LUTs and did not meet the timing requirements of the FPGA. We found out that the issue with the LUTs was because we were doing a few nested for-loops which synthesized to very complex logic. When this LUT error was debugged and fixed, we ran into a timing constraint error. This timing constraint error indicated that the logic in the movement module was too heavy and complex for us to continue. To respond to this, we had to think of a simpler way to approach the problem. We did this by simplifying the movement and making the updated board a result of one shift in the requested direction, instead of the max shift. Then, we simply mapped one button press to generate three button press pulses, which would be equivalent to doing the max shift.
