# Data Transport and Integrity Checks

## Design of an End-to-end checker

An end-to-end checker is also known as `formal_scoreboard`. This scoreboard will use `symbolic variables` to exhaustively explore the design space of the design to verify the following type of properties:

- Data integrity.
- Overflow (for max pending data symbols).
- Underflow (for max pending data symbols).
- Latency (symbols at input are seen at output in less than or equal an amount of time defined by a parameter).

The scoreboard will run `Data integrity` checks of type:

- In order.
- Out of order.
- Counter (latency).

The interface of the formal scoreboard is as follows:

 <img src="https://github.com/dh73/Prop-eller/blob/main/data_integrity_checker/img/dchk.png" width="800">

**Parameters:**

| **Parameter Name** | **Information** |
| --- | --- |
| CLOCK_CONFIG | This parameter will define if both input and output data are updated with a single clock (0) or input and ouput data have different clocks for each interface (1). |
| DATA_SIZE | This parameter defines the width of the datain port. |
| DATA_ORDERING | This parameter will be used to define if data flow is in order (INORDER) or out-of-order (OUT\_OF\_ORDER). |
| LATENCY_CHECKS | If enabled (1), the checker will enable latency checks. |
| MAX_LATENCY | For latency checks. A symbolic variable should be seen at output in a T <= MAX_LATENCY. |

**Interface**

|     |     |     |
| --- | --- | --- |
| **Interface Port** | **Description** | **More info** |
| in_clk | A 1 bit port used as dynamic reference input for the symbol. | If *CLOCK_CONFIG* is configured as single clock (0), this will be the master clock for both input/output data checks. |
| valid_in | A 1 bit port that will define when the formal scoreboard will sample the data (symbol) at the input port. | When *valid_in* is asserted, the value at *data_in* will be choosen as the symbol for the data transport checks. |
| data_in | A DATA\_SIZE bit port that is used to get the symbol upon assertion of valid\_datain for the end-to-end checks. | Symbol for the data transport checks. |
| out_clk | A 1 bit port used as dynamic reference output for the symbol. | If *CLOCK_CONFIG* is configured as dual clock (1), in\_clk will be used for data\_in logic, and out\_clk is connected to data\_out logic. |
| valid_out | A 1 bit port used to instruct the formal scoreboard to use the data_out information to verify the checks, when asserted. | When valid\_out is asserted, the information at data\_out will be used to compare with the symbol stored in the scoreboard, and run the checks. |
| data_out | A DATA_SIZE bit port that is used to compare the formal scoreboard symbol with. | The data_out port will be used to compare with the symbol stored in the scoreboard. |
