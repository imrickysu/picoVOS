:: This bat will do these jobs:
:: 1. copy the source files to the temporary work directory
:: 2. generate the cores by xco files and coe files
:: 3. use build_project.tcl to create an ISE project, implement it and get a final bit file
:: 4. configure FPGA


cd ..
xcopy /I source work
copy "implementation\build_project.tcl" work
cd work

coregen -b freq_rom.xco
coregen -b kbd_fifo.xco
coregen -b logo_ram.xco
coregen -b score_ram.xco
coregen -b vga_ram.xco
coregen -b music.xco

xtclsh build_project.tcl

cd ..
impact -batch implementation/download.cmd
