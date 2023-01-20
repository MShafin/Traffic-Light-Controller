module traffic_light_controller
(
	input clk_27, debug, reset,
	input left_turn_request, walk_request_NS, walk_request_EW,

	output northbound_red, northbound_amber, northbound_green,
	output southbound_red, southbound_amber, southbound_green,
	output eastbound_red, eastbound_amber, eastbound_green,
	output westbound_red, westbound_amber, westbound_green,
	
	output [1:0] southbound_left_turn,
	output [1:0] westbound_left_turn,
	output [5:0] northbound_walk_light, southbound_walk_light, eastbound_walk_light, westbound_walk_light
);

///////////////////////////////////////////////////////////////////////////////
/* States */
wire left_turn_request_d; // internal check
wire walk_request; // internal check
reg state_1, state_1_d, entering_state_1, staying_in_state_1, exiting_state_1;
reg state_1a, state_1a_d, entering_state_1a, staying_in_state_1a, exiting_state_1a;
reg state_1w, state_1w_d, entering_state_1w, staying_in_state_1w, exiting_state_1w;
reg state_1fd, state_1fd_d, entering_state_1fd, staying_in_state_1fd, exiting_state_1fd;
reg state_1d, state_1d_d, entering_state_1d, staying_in_state_1d, exiting_state_1d;
reg state_2, state_2_d, entering_state_2, staying_in_state_2, exiting_state_2;
reg state_3, state_3_d, entering_state_3, staying_in_state_3, exiting_state_3;
reg state_4, state_4_d, entering_state_4, staying_in_state_4, exiting_state_4;
reg state_4a, state_4a_d, entering_state_4a, staying_in_state_4a, exiting_state_4a;
reg state_4w, state_4w_d, entering_state_4w, staying_in_state_4w, exiting_state_4w;
reg state_4fd, state_4fd_d, entering_state_4fd, staying_in_state_4fd, exiting_state_4fd;
reg state_4d, state_4d_d, entering_state_4d, staying_in_state_4d, exiting_state_4d;
reg state_5, state_5_d, entering_state_5, staying_in_state_5, exiting_state_5;
reg state_6, state_6_d, entering_state_6, staying_in_state_6, exiting_state_6;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* Clock Speed*/
wire clk;
reg [23:0] clock_divider_counter, clock_divider_constant;

always @ (*)
	if (debug == 1'd1)
		clock_divider_constant <= 24'd1350000; // 10Hz
		//clock_divider_constant <= 24'd1; //uncomment to make 13.5MHz clk
	else
		clock_divider_constant <= 24'd13500000; // 1Hz

always @ (posedge clk_27)
	if (reset == 1'd0)
		clock_divider_counter <= 24'd1;
	else if (clock_divider_counter == 24'd1)
		clock_divider_counter <= clock_divider_constant;
	else
		clock_divider_counter <= clock_divider_counter - 24'd1;

always @ (posedge clk_27)
	if (clock_divider_counter == 24'd1)
		clk <= ~clk;
	else
		clk <= clk;	
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* Timer */
reg [5:0] timer;
always @ (posedge clk or negedge reset)
	if (reset == 1'b0)
		timer <= 6'd60; // timer for state 1
	else if (entering_state_1a == 1'b1)
		timer <= 6'd60; // timer for state 1a
	else if (entering_state_1 == 1'b1)
		timer <= 6'd60; // timer for state 1
	else if (entering_state_1w == 1'b1)
		timer <= 6'd10; // time for state 1w
	else if (entering_state_1fd == 1'b1)
		timer <= 6'd20; // time for state 1fd
	else if (entering_state_1d == 1'b1)
		timer <= 6'd30; // time for state 1d
	else if (entering_state_2 == 1'b1)
		timer <= 6'd6; // timer for state 2
	else if (entering_state_3 == 1'b1)
		timer <= 6'd2; // timer for state 3
	else if (entering_state_4 == 1'b1)
		timer <= 6'd60; // timer for state 4
	else if (entering_state_4a == 1'b1)
		timer <= 6'd20; // timer for state 4a
	else if (entering_state_4w == 1'b1)
		timer <= 6'd10; // time for state 4w
	else if (entering_state_4fd == 1'b1)
		timer <= 6'd20; // time for state 4fd
	else if (entering_state_4d == 1'b1)
		timer <= 6'd30; // time for state 4d
	else if (entering_state_5 == 1'b1)
		timer <= 6'd6; // timer for state 5
	else if (entering_state_6 == 1'b1)
		timer <= 6'd2; // timer for state 6
	else if (timer == 6'd1)
		timer <= timer; // never decrement below 1
	else
		timer <= timer - 6'd1;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 1*/
always @ (posedge clk or negedge reset)    // State 1 flip flop
	if (reset == 1'b0)
		state_1 <= 1'b1;
	else
		state_1 <= state_1_d;

always @ (*)    // Entering state 1
	if (state_6 == 1'b1 && timer == 6'd1 && walk_request == 1'b0 && left_turn_request_d == 1'd0)
		entering_state_1 <= 1'b1;
	else if(((state_1a) == 1'b1) && (timer == 6'd1) && (walk_request == 1'b0) && (left_turn_request_d == 1'd0))
		entering_state_1 <= 1'b1;
	else
		entering_state_1 <= 1'b0;

always @ (*)    // Staying in state 1
	if ((state_1 == 1'b1) && (timer != 6'd1))
		staying_in_state_1 <= 1'b1;
	else
		staying_in_state_1 <= 1'b0;

always @ (*)    // d_input for state 1 flip flop
	if (entering_state_1 == 1'b1)
		state_1_d <= 1'b1; 		// enter state 1 on next posedge clk
	else if (staying_in_state_1 == 1'b1)
		state_1_d <= 1'b1; 		// stay in state 1 on next posedge clk
	else
		state_1_d <= 1'b0; 		// not in state 1 on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 1a*/
always @ (posedge clk or negedge reset)    // State 1a flip flop
	if (reset == 1'b0)
		state_1a <= 1'b0;
	else
		state_1a <= state_1a_d;

always @ (*)    // Entering state 1a
	if (state_6 == 1'b1 && timer == 6'd1 && left_turn_request_d == 1'b1)
		entering_state_1a <= 1'b1;
	else
		entering_state_1a <= 1'b0;

always @ (*)    // Staying in state 1a
	if ((state_1a == 1'b1) && (timer != 6'd1))
		staying_in_state_1a <= 1'b1;
	else
		staying_in_state_1a <= 1'b0;

always @ (*)    // d_input for state 1a flip flop
	if (entering_state_1a == 1'b1)
		state_1a_d <= 1'b1; 		// enter state 1a on next posedge clk
	else if (staying_in_state_1a == 1'b1)
		state_1a_d <= 1'b1; 		// stay in state 1a on next posedge clk
	else
		state_1a_d <= 1'b0; 		// not in state 1a on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 1w*/
always @ (posedge clk or negedge reset)    // State 1w flip flop
	if (reset == 1'b0)
		state_1w <= 1'b0;
	else
		state_1w <= state_1w_d;

always @ (*)    // Entering state 1w
	if (state_6 == 1'b1 && timer == 6'd1 && left_turn_request_d == 1'b0 && walk_request == 1'b1)
		entering_state_1w <= 1'b1;
	else if (state_1a == 1'b1 && timer == 6'd1 && left_turn_request_d == 1'b0 && walk_request == 1'b1)
		entering_state_1w <= 1'b1;
	else
		entering_state_1w <= 1'b0;

always @ (*)    // Staying in state 1w
	if ((state_1w == 1'b1) && (timer != 6'd1))
		staying_in_state_1w <= 1'b1;
	else
		staying_in_state_1w <= 1'b0;

always @ (*)    // d_input for state 1w flip flop
	if (entering_state_1w == 1'b1)
		state_1w_d <= 1'b1; 		// enter state 1w on next posedge clk
	else if (staying_in_state_1w == 1'b1)
		state_1w_d <= 1'b1; 		// stay in state 1w on next posedge clk
	else
		state_1w_d <= 1'b0; 		// not in state 1w on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 1fd*/
always @ (posedge clk or negedge reset)    // State 1fd flip flop
	if (reset == 1'b0)
		state_1fd <= 1'b0;
	else
		state_1fd <= state_1fd_d;

always @ (*)    // Entering state 1fd
	if (state_1w == 1'b1 && timer == 6'd1)
		entering_state_1fd <= 1'b1;
	else
		entering_state_1fd <= 1'b0;

always @ (*)    // Staying in state 1fd
	if ((state_1fd == 1'b1) && (timer != 6'd1))
		staying_in_state_1fd <= 1'b1;
	else
		staying_in_state_1fd <= 1'b0;

always @ (*)    // d_input for state 1fd flip flop
	if (entering_state_1fd == 1'b1)
		state_1fd_d <= 1'b1; 		// enter state 1fd on next posedge clk
	else if (staying_in_state_1fd == 1'b1)
		state_1fd_d <= 1'b1; 		// stay in state 1fd on next posedge clk
	else
		state_1fd_d <= 1'b0; 		// not in state 1fd on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 1d*/
always @ (posedge clk or negedge reset)    // State 1d flip flop
	if (reset == 1'b0)
		state_1d <= 1'b0;
	else
		state_1d <= state_1d_d;

always @ (*)    // Entering state 1d
	if (state_1fd == 1'b1 && timer == 6'd1)
		entering_state_1d <= 1'b1;
	else
		entering_state_1d <= 1'b0;

always @ (*)    // Staying in state 1d
	if ((state_1d == 1'b1) && (timer != 6'd1))
		staying_in_state_1d <= 1'b1;
	else
		staying_in_state_1d <= 1'b0;

always @ (*)    // d_input for state 1d flip flop
	if (entering_state_1d == 1'b1)
		state_1d_d <= 1'b1; 		// enter state 1d on next posedge clk
	else if (staying_in_state_1d == 1'b1)
		state_1d_d <= 1'b1; 		// stay in state 1d on next posedge clk
	else
		state_1d_d <= 1'b0; 		// not in state 1d on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 2*/
always @ (posedge clk or negedge reset)    // State 2 flip flop
	if (reset == 1'b0)
		state_2 <= 1'b0;
	else
		state_2 <= state_2_d;

always @ (*)    // Entering state 2
	if ((state_1 == 1'b1 && timer == 6'd1) || (state_1d == 1'b1 && timer == 6'd1))
		entering_state_2 <= 1'b1;
	else
		entering_state_2 <= 1'b0;

always @ (*)    // Staying in state 2
	if ((state_2 == 1'b1) && (timer != 6'd1))
		staying_in_state_2 <= 1'b1;
	else
		staying_in_state_2 <= 1'b0;

always @ (*)    // d_input for state 2 flip flop
	if (entering_state_2 == 1'b1)
		state_2_d <= 1'b1; 		// enter state 2 on next posedge clk
	else if (staying_in_state_2 == 1'b1)
		state_2_d <= 1'b1; 		// stay in state 2 on next posedge clk
	else
		state_2_d <= 1'b0; 		// not in state 2 on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 3*/
always @ (posedge clk or negedge reset)    // State 3 flip flop
	if (reset == 1'b0)
		state_3 <= 1'b0;
	else
		state_3 <= state_3_d;

always @ (*)    // Entering state 3
	if (state_2 == 1'b1 && timer == 6'd1)
		entering_state_3 <= 1'b1;
	else
		entering_state_3 <= 1'b0;

always @ (*)    // Staying in state 3
	if ((state_3 == 1'b1) && (timer != 6'd1))
		staying_in_state_3 <= 1'b1;
	else
		staying_in_state_3 <= 1'b0;

always @ (*)    // d_input for state 3 flip flop
	if (entering_state_3 == 1'b1)
		state_3_d <= 1'b1; 		// enter state 3 on next posedge clk
	else if (staying_in_state_3 == 1'b1)
		state_3_d <= 1'b1; 		// stay in state 3 on next posedge clk
	else
		state_3_d <= 1'b0; 		// not in state 3 on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 4*/
always @ (posedge clk or negedge reset)    // State 4 flip flop
	if (reset == 1'b0)
		state_4 <= 1'b0;
	else
		state_4 <= state_4_d;

always @ (*)    // Entering state 4
	if (state_3 == 1'b1 && timer == 6'd1 && walk_request == 1'b0 && left_turn_request_d == 1'b0)
		entering_state_4 <= 1'b1;
    else if (state_4a == 1'b1 && timer == 6'd1 && walk_request == 1'b0 && left_turn_request_d == 1'b0) // state_4aa means 0. low logic ???
        entering_state_4 <= 1'b1;
	else
		entering_state_4 <= 1'b0;

always @ (*)    // Staying in state 4
	if ((state_4 == 1'b1) && (timer != 6'd1))
		staying_in_state_4 <= 1'b1;
	else
		staying_in_state_4 <= 1'b0;

always @ (*)    // d_input for state 4 flip flop
	if (entering_state_4 == 1'b1)
		state_4_d <= 1'b1; 		// enter state 4 on next posedge clk
	else if (staying_in_state_4 == 1'b1)
		state_4_d <= 1'b1; 		// stay in state 4 on next posedge clk
	else
		state_4_d <= 1'b0; 		// not in state 4 on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 4a*/
always @ (posedge clk or negedge reset)    // State 4a flip flop
	if (reset == 1'b0)
		state_4a <= 1'b0;
	else
		state_4a <= state_4a_d;

always @ (*)    // Entering state 4a
	if (state_3 == 1'b1 && timer == 6'd1 && left_turn_request_d == 1'b1)
		entering_state_4a <= 1'b1;
	else
		entering_state_4a <= 1'b0;

always @ (*)    // Staying in state 4a
	if ((state_4a == 1'b1) && (timer != 6'd1))
		staying_in_state_4a <= 1'b1;
	else
		staying_in_state_4a <= 1'b0;

always @ (*)    // d_input for state 4a flip flop
	if (entering_state_4a == 1'b1)
		state_4a_d <= 1'b1; 		// enter state 4a on next posedge clk
	else if (staying_in_state_4a == 1'b1)
		state_4a_d <= 1'b1; 		// stay in state 4a on next posedge clk
	else
		state_4a_d <= 1'b0; 		// not in state 4a on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 4w*/
always @ (posedge clk or negedge reset)    // State 4w flip flop
	if (reset == 1'b0)
		state_4w <= 1'b0;
	else
		state_4w <= state_4w_d;

always @ (*)    // Entering state 4w
	if (state_3 == 1'b1 && timer == 6'd1 && left_turn_request_d == 1'b0 && walk_request == 1'b1)
		entering_state_4w <= 1'b1;
    else if (state_4a == 1'b1 && timer == 6'd1 && left_turn_request_d == 1'b0 && walk_request == 1'b1)
        entering_state_4w <= 1'b1;
	else
		entering_state_4w <= 1'b0;

always @ (*)    // Staying in state 4w
	if ((state_4w == 1'b1) && (timer != 6'd1))
		staying_in_state_4w <= 1'b1;
	else
		staying_in_state_4w <= 1'b0;

always @ (*)    // d_input for state 4w flip flop
	if (entering_state_4w == 1'b1)
		state_4w_d <= 1'b1; 		// enter state 4w on next posedge clk
	else if (staying_in_state_4w == 1'b1)
		state_4w_d <= 1'b1; 		// stay in state 4w on next posedge clk
	else
		state_4w_d <= 1'b0; 		// not in state 4w on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 4fd*/
always @ (posedge clk or negedge reset)    // State 4fd flip flop
	if (reset == 1'b0)
		state_4fd <= 1'b0;
	else
		state_4fd <= state_4fd_d;

always @ (*)    // Entering state 4fd
	if (state_4w == 1'b1 && timer == 6'd1)
		entering_state_4fd <= 1'b1;
	else
		entering_state_4fd <= 1'b0;

always @ (*)    // Staying in state 4fd
	if ((state_4fd == 1'b1) && (timer != 6'd1))
		staying_in_state_4fd <= 1'b1;
	else
		staying_in_state_4fd <= 1'b0;

always @ (*)    // d_input for state 4fd flip flop
	if (entering_state_4fd == 1'b1)
		state_4fd_d <= 1'b1; 		// enter state 4fd on next posedge clk
	else if (staying_in_state_4fd == 1'b1)
		state_4fd_d <= 1'b1; 		// stay in state 4fd on next posedge clk
	else
		state_4fd_d <= 1'b0; 		// not in state 4fd on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 4d*/
always @ (posedge clk or negedge reset)    // State 4d flip flop
	if (reset == 1'b0)
		state_4d <= 1'b0;
	else
		state_4d <= state_4d_d;

always @ (*)    // Entering state 4d
	if (state_4fd == 1'b1 && timer == 6'd1)
		entering_state_4d <= 1'b1;
	else
		entering_state_4d <= 1'b0;

always @ (*)    // Staying in state 4d
	if ((state_4d == 1'b1) && (timer != 6'd1))
		staying_in_state_4d <= 1'b1;
	else
		staying_in_state_4d <= 1'b0;

always @ (*)    // d_input for state 4d flip flop
	if (entering_state_4d == 1'b1)
		state_4d_d <= 1'b1; 		// enter state 4d on next posedge clk
	else if (staying_in_state_4d == 1'b1)
		state_4d_d <= 1'b1; 		// stay in state 4d on next posedge clk
	else
		state_4d_d <= 1'b0; 		// not in state 4d on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 5*/
always @ (posedge clk or negedge reset)    // State 5 flip flop
	if (reset == 1'b0)
		state_5 <= 1'b0;
	else
		state_5 <= state_5_d;

always @ (*)    // Entering state 5
	if ((state_4 == 1'b1 && timer == 6'd1) || (state_4d == 1'b1 && timer == 6'd1))
		entering_state_5 <= 1'b1;
	else
		entering_state_5 <= 1'b0;

always @ (*)    // Staying in state 5
	if ((state_5 == 1'b1) && (timer != 6'd1))
		staying_in_state_5 <= 1'b1;
	else
		staying_in_state_5 <= 1'b0;

always @ (*)    // d_input for state 5 flip flop
	if (entering_state_5 == 1'b1)
		state_5_d <= 1'b1; 		// enter state 5 on next posedge clk
	else if (staying_in_state_5 == 1'b1)
		state_5_d <= 1'b1; 		// stay in state 5 on next posedge clk
	else
		state_5_d <= 1'b0; 		// not in state 5 on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* State 6*/
always @ (posedge clk or negedge reset)    // State 6 flip flop
	if (reset == 1'b0)
		state_6 <= 1'b0;
	else
		state_6 <= state_6_d;

always @ (*)    // Entering state 6
	if (state_5 == 1'b1 && timer == 6'd1)
		entering_state_6 <= 1'b1;
	else
		entering_state_6 <= 1'b0;

always @ (*)    // Staying in state 6
	if ((state_6 == 1'b1) && (timer != 6'd1))
		staying_in_state_6 <= 1'b1;
	else
		staying_in_state_6 <= 1'b0;

always @ (*)    // d_input for state 6 flip flop
	if (entering_state_6 == 1'b1)
		state_6_d <= 1'b1; 		// enter state 6 on next posedge clk
	else if (staying_in_state_6 == 1'b1)
		state_6_d <= 1'b1; 		// stay in state 6 on next posedge clk
	else
		state_6_d <= 1'b0; 		// not in state 6 on the next posedge clk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* Left Turn Request*/
always @(posedge clk or posedge state_4a or negedge left_turn_request or posedge state_1a)
//		left_turn_request_d <= 1'b0;
	if (state_4a) 
		left_turn_request_d <= 1'b0;
	else if (state_1a)
		left_turn_request_d <= 1'b0;
	else if (left_turn_request == 1'b0)
		left_turn_request_d <= 1'b1;
	else 
		left_turn_request_d <= 1'b0;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* Northbound Traffic Ligths */
always @ (*)
    if ((state_1a | state_1 | state_1w | state_1fd | state_1d | state_2 | state_3 | state_6 | state_4a) == 1'b1)
		northbound_red <= 1'b0;
	else
		northbound_red <= 1'b1;

always @ (*)
	if ((state_5) == 1'b1)
		northbound_amber <= 1'b0;
	else	northbound_amber <= 1'b1;

always @ (*)
	if ((state_4 | state_4w | state_4fd | state_4d ) == 1'b1 )
		northbound_green <= 1'b0;
	else    northbound_green <= 1'b1;

/* Southbound Traffic Lights */
always @ (*)
	if ((state_1a | state_1 | state_1w | state_1fd | state_1d | state_2 | state_3 | state_6) == 1'b1)
		southbound_red <= 1'b0;
	else    southbound_red <= 1'b1;

always @ (*)
	if ((state_5 | state_4a) == 1'b1)
		southbound_amber <= 1'b0;
	else    southbound_amber <= 1'b1;

always @ (*)
	if ((state_4  | state_4w | state_4fd | state_4d) == 1'b1)
		southbound_green <= 1'b0;
	else    southbound_green <= 1'b1;

always @ (*)
	if ( state_4a == 1'b1 )
        southbound_left_turn <= 2'b00;
	else    southbound_left_turn <= 2'b11;

/* Eastbound Traffic Ligths */
always @ (*)
	if ((state_1a | state_3 | state_4 | state_4a | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1)
		eastbound_red <= 1'b0;
	else    eastbound_red <= 1'b1;

always @ (*)
	if ((state_2) == 1'b1)
		eastbound_amber <= 1'b0;
	else    eastbound_amber <= 1'b1;

always @ (*)
	if ((state_1 | state_1w | state_1fd | state_1d) == 1'b1)
		eastbound_green <= 1'b0;
	else    eastbound_green <= 1'b1;

/* Westbound Traffic Ligths */
always @ (*)
	if ((state_3 | state_4 | state_4a | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1)
		westbound_red <= 1'b0;
	else    westbound_red <= 1'b1;

always @ (*)
	if ((state_2 | | state_1a) == 1'b1)
		westbound_amber <= 1'b0;
	else    westbound_amber <= 1'b1;

always @ (*)
	if ((state_1 | state_1w | state_1fd | state_1d) == 1'b1)
		westbound_green <= 1'b0;
	else    westbound_green <= 1'b1;
	
always @ (*)
	if ( state_1a == 1'b1 )
        westbound_left_turn <= 2'b00;
	else    westbound_left_turn <= 2'b11;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* Walk Request*/
always @ (posedge clk)
	if (reset == 1'b0) // keys are active low
		walk_request <= 1'b0;
	else if ( walk_request_EW == 1'b0 || walk_request_NS == 1'b0 ) //Pressed
		//walk_request <= (walk_request_EW | walk_request_NS);
		walk_request <= 1'b1;	
	else if ((state_1w == 1'b1 && (timer == 6'd10)) || (state_4w == 1'b1 && timer == 6'd10))
		walk_request <= 1'b0;
	else 
		walk_request <= walk_request;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
/* Walk Request Northbound Lights*/
always @ (*)
	if ((state_1a | state_1 | state_1w | state_1fd | state_1d | state_2 | state_3 | state_4 | state_4a | state_4d | state_5 | state_6) == 1'b1)
		northbound_walk_light[4:0] <= 5'b0;
    else if ((state_4fd == 1'b1) && (clk == 1'b1))
		northbound_walk_light[4:0] <= 5'b0;
	else    northbound_walk_light[4:0] <= 5'b11111;

always @ (*)
	if ((state_4w) == 1'b1)
        northbound_walk_light[5] <= 1'b0;
	else    northbound_walk_light[5] <= 1'b1;

/* Walk Request Southbound Lights*/
always @ (*)
	if ((state_1a | state_1 | state_1w | state_1fd | state_1d | state_2 | state_3 | state_4 | state_4a | state_4d | state_5 | state_6) == 1'b1)
		southbound_walk_light[4:0] <= 5'b0;
    else if ((state_4fd == 1'b1) && (clk == 1'b1))
		southbound_walk_light[4:0] <= 5'b0;
	else    southbound_walk_light[4:0] <= 5'b11111;

always @ (*)
	if ((state_4w) == 1'b1)
        southbound_walk_light[5] <= 1'b0;
	else    southbound_walk_light[5] <= 1'b1;

/* Walk Request Eastbound Lights*/
always @ (*)
	if (( state_1a | state_1 | state_1d | state_2 | state_3 | state_4 | state_4a | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1)
		eastbound_walk_light[4:0] <= 5'b0;
    else if ((state_1fd == 1'b1) && (clk == 1'b1))
		eastbound_walk_light[4:0] <= 5'b0;
	else    eastbound_walk_light[4:0] <= 5'b11111;

always @ (*)
	if ((state_1w) == 1'b1)
        eastbound_walk_light[5] <= 1'b0;
	else    eastbound_walk_light[5] <= 1'b1;

/* Walk Request Westbound Lights*/
always @ (*)
	if ((state_1a | state_1 | state_1d | state_2 | state_3 | state_4 | state_4a | state_4w | state_4fd | state_4d | state_5 | state_6) == 1'b1)
		westbound_walk_light[4:0] <= 5'b0;
    else if ((state_1fd == 1'b1) && (clk == 1'b1))
		westbound_walk_light[4:0] <= 5'b0;
	else    westbound_walk_light[4:0] <= 5'b11111;

always @ (*)
	if ((state_1w) == 1'b1)
        westbound_walk_light[5] <= 1'b0;
	else    westbound_walk_light[5] <= 1'b1;
///////////////////////////////////////////////////////////////////////////////

endmodule
