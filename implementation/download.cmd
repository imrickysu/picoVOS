setMode -bscan
setCable -p usb21
identify
assignfile -p 1 -file work/top.bit
program -p 1 -onlyFpga
quit
