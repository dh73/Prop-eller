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
| SINGLE_CLOCK | This parameter will define if both input and output data are updated with a single clock (0) or input and output data have different clocks for each interface (1). |
| DATA_SIZE | This parameter defines the width of the datain port. |
| MAX\_TXN\_PENDING | A parameter to define the number of max transactions that the checker can store. |
| DATA_ORDERING | This parameter will be used to define if data flow is in order (INORDER) or out-of-order (OUT\_OF\_ORDER). |
| LATENCY_CHECKS | If enabled (1), the checker will enable latency checks. |
| MAX_LATENCY | For latency checks. A symbolic variable should be seen at output in a T <= MAX_LATENCY. |

**Interface**

|     |     |     |
| --- | --- | --- |
| **Interface Port** | **Description** | **More info** |
| in_clk | A 1 bit port used as dynamic reference input for the symbol. | If *SINGLE_CLOCK* is configured as single clock (1), this will be the master clock for both input/output data checks. |
| valid_in | A 1 bit port that will define when the formal scoreboard will sample the data (symbol) at the input port. | When *valid_in* is asserted, the value at *data_in* will be chosen as the symbol for the data transport checks. |
| data_in | A DATA\_SIZE bit port that is used to get the symbol upon assertion of valid\_datain for the end-to-end checks. | Symbol for the data transport checks. |
| out_clk | A 1 bit port used as dynamic reference output for the symbol. | If *SINGLE_CLOCK* is configured as dual clock (0), in\_clk will be used for data\_in logic, and out\_clk is connected to data\_out logic. |
| valid_out | A 1 bit port used to instruct the formal scoreboard to use the data_out information to verify the checks, when asserted. | When valid\_out is asserted, the information at data\_out will be used to compare with the symbol stored in the scoreboard, and run the checks. |
| data_out | A DATA_SIZE bit port that is used to compare the formal scoreboard symbol with. | The data_out port will be used to compare with the symbol stored in the scoreboard. |

* * *

# Implementation

## Overflow and Underflow Checks
For both overflow and underflow checks, a counter based approach is used to track the number of input/output packet request (valid_in/valid_out counts). Since the `formal_scoreboard` supports both `single clock` and `dual clock` options, the transaction counter will have two modes as well:
* With single clock `SINGLE_CLOCK = 1`: Both read and write (valid_in/valid_out) are updated with `in_clk` dynamic reference.
* With dual clock `SINGLE_CLOCK = 0`: Write port (valid_in) is updated with `in_clk` dynamic reference, whereas read port (valid_out) is updated with `out_clock`.

## Architectural View
The overflow and underflow check is very simple: On each `valid_in` valid data entering to the checker, the `pending_txn` counter is incremented. If a `valid_out` valid data is exiting the checker, the `pending_txn` counter is decremented.

For `SINGLE_CLOCK = 1`, the logic follow above statement as is. That is not the case when `SINGLE_CLOCK = 0`, because of the differences that a system with two clocks may imply. In this case, two status flags are used to track the overflow (write) and underflow (read) conditions: `wr_status` and `rd_status`.

The functionality of the transaction counter with different clocks for read and write is as follows:
* **Write side**: Updated by `in_clk`, on each `valid_in` request, the write counter `wr_count` is incremented. The `pending_txn` is then the difference between the number of writes (valid_in) minus the number of reads (valid_out). If the number of writes equals to the `MAX_TXN_PENDING` parameter, the `wr_status` is flipped to denote an overflow. The `pending_txn` is calculated using this scenario as reference, by adding the value of `MAX_TNX_PENDING` to the relative difference of writes and reads.

* **Read side**: Updated by `out_clk`, on each `valid_out` request, the read counter `rd_count` is incremented. The `pending_txn` is then the difference between the number of writes (valid_in) minus the number of reads (valid_out). If the number of reads equals to the `MAX_TXN_PENDING` parameter, the `rd_status` is flipped to denote an underflow. The `pending_txn` is calculated using this scenario as reference, by adding the value of `MAX_TNX_PENDING` to the relative difference of writes and reads.

__TODO: Add some wave forms.__

The checker then uses the `pending_txn` counter to define the following properties for overflow and underflow checks:
Let $overflow = (pending\_txn < MAX\_TXN\_PENDING)$ and $underflow = (pending\_txn > 0)$, the rules for overflow and underflow checking are shown below:
* Overflow property: $G(valid\_in \rightarrow \neg overflow)$
* Underflow property: $G(valid\_out \rightarrow \neg underflow)$

__TODO: Asses completeness.__
