# SEMIAUTOMATIC INJECTION
Faut injection is a library written in verilog that allows to inject faults on variables (fault injection) and operators (mutant injection).

## USAGE
Import the library into the module you want
```verilog
`import “fault_injection.v”
```

Generate the functions you want to use. There are 4 different functions available:
* `GENERATE_FAULT_INJECTION_FUNCTION(func_name, width)
  * Generate a function named *func_name* to inject failures to variables of *width* length
* `GENERATE_MUTANT_INJECTION_FUNCTION(func_name, width)
  * Generate a function named *func_name* to inject failures to arithmetic operators with *width* length variables
* `GENERATE_MUTANT_INJECTION_LOGIC_FUNCTION(func_name, width)
  * Generate a function named *func_name* to inject failures to logic operators with *width* length variables
* `GENERATE_MUTANT_INJECTION_RELATIONAL_FUNCTION(func_name, width)
  * Generate a function named *func_name* to inject failures to relational operators with *width* length variables
It is shown below an example of generation of a function:
```verilog
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj8, 8)
`GENERATE_MUTANT_INJECTION_FUNCTION(mutant_inj8, 8)
```

Use the created functions. An instance of the fault injection is shown below:
```verilog
fault_inj8(var, toggle_start, toggle_end)
```
Where *var* is the variable on which to inject the fault, *toggle_start* and *toggle_end* define me the interval in which the simulation will inject the fault.

Regarding mutant injection function instances:
Use the created functions. An instance of the fault injection is shown below:
```verilog
mutant_inj8(var1, var2, toggle_start, toggle_end, operator)
```
Where *var1* and *var2* are the operands, *toggle_start* and *toggle_end* define me the interval in which the fault will be injected, while *operator* defines the original operator, the mapping (integer) -> (operator) is shown below: 
* For arithmetic operators (0) --> (+), (1) --> (-), (2) --> (*), (3) --> (/)
* For logic operators (0) --> (AND), (1) --> (OR), (2) --> (NOT)
* For relational operators (0) --> (>), (1) --> (>=), (2) --> (<), (3) --> (<=), (4) --> (==), (3) --> (!=)

Now all that remains is to run the script (a possible implementation is provided) so as to relaunch the simulation more than once to inject faults on a different bit each time.


