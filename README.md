# INJECTION
Faut injection is a library written in verilog that allows to inject faults on variables (fault injection) and operators (mutant injection).

## USAGE
Import the library into the module you want
```verilog
`import “fault_injection.v”
```

Generate the functions you want to use. There are 4 different functions available:
* `GENERATE_FAULT_INJECTION_FUNCTION(func_name,length)
* `GENERATE_MUTANT_INJECTION_FUNCTION(func_name,length)
* `GENERATE_MUTANT_INJECTION_FUNCTION(func_name,length)
* `GENERATE_MUTANT_INJECTION_FUNCTION(func_name,length)

```verilog
`GENERATE_FAULT_INJECTION_FUNCTION(faultInj1, 1)
```
Use the created functions. An instance of the fault injection and mutant injection function is shown below:
```verilog
faultinj1(enable, 0, 1)
```
