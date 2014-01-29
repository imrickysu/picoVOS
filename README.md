picoVOS
=======

This is a reference design that implements the VOS game on Spartan3A FPGA. It utilizes the PicoBlaze as a microcontroller to drive the VGA and audio peripherals.

This design was published to Xilinx.com in 2009. After the Xilinx webpage restructure, it can not be found on the webpage. So I now publish it to github.



### Quick Demo ###

Double Click demo/quick_demo.bat. It will use impact to download bit file.



### Project Rebuild ###
1. PicoBlaze source code isn't included in this package. Users need to
   download it manually.
   Visit www.xilinx.com/picoblaze, register and download PicoBlaze source code 
   for Spartan3. 
   Copy kcpsm3.v, uart_tx.v and kcuart_tx.v, bbfifo_16x8.v to source directory.

2. For Windows users:
   Double click run.bat in implementation directory, it will generate the ISE
   Project and the final bit file automatically in the work directory.

   For Linux users:
   Source the settings.sh(csh) file in the shell and add the executable 
   attribute to run.sh in implementation directory:
      source <ISE_INSTALL_DIR>/settings.sh
      chmod +x run.sh	
      ./run.sh



### Archive structure ###
/source			.v .xco .coe and .ucf source files for the project  
/implementation  
++picoVOS.bit		pre-build bit file  
++run.bat		For windows users, double click it will copy source files
			to work directory, generate the cores and the ISE roject  
++run.sh		For Linux users. Function is the same as the windows one  
++build_project.tcl	ISE project generation script

