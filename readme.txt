##############################################################################
## Copyright (c) 2007 Xilinx, Inc.
## This design is confidential and proprietary of Xilinx, All Rights Reserved.
##############################################################################
##   ____  ____
##  /   /\/   /
## /___/  \  /   Vendor:        Xilinx
## \   \   \/    Version:       2.0
##  \   \        Filenames:     picoVOS.bit
##  /   /        
## /___/   /\    Date Created:  July 4, 2008
## \   \  /  \   Last Modified: July 4, 2008
##  \___\/\___\
##
## Devices:   Spartan-3A FPGA
## Purpose:   Spartan-3A Starter Kit picoVOS Demo
## Contact:   ricky.su@xilinx.com
## Reference: None
##
## Revision History:
##   Rev 1.0.0 - (crabill) Created April 1, 2007
##
##############################################################################
##
## LIMITED WARRANTY AND DISCLAIMER. These designs are provided to you "as is".
## Xilinx Technical Support doesn't provide support of this project. 
## Xilinx and its licensors make and you receive no warranties or conditions,
## express, implied, statutory or otherwise, and Xilinx specifically disclaims
## any implied warranties of merchantability, non-infringement, or fitness for
## a particular purpose. Xilinx does not warrant that the functions contained
## in these designs will meet your requirements, or that the operation of
## these designs will be uninterrupted or error free, or that defects in the
## designs will be corrected. Furthermore, Xilinx does not warrant or make any
## representations regarding use or the results of the use of the designs in
## terms of correctness, accuracy, reliability, or otherwise.
##
## LIMITATION OF LIABILITY. In no event will Xilinx or its licensors be liable
## for any loss of data, lost profits, cost or procurement of substitute goods
## or services, or for any special, incidental, consequential, or indirect
## damages arising from the use or operation of the designs or accompanying
## documentation, however caused and on any theory of liability. This
## limitation will apply even if Xilinx has been advised of the possibility
## of such damage. This limitation shall apply not-withstanding the failure
## of the essential purpose of any limited remedies herein.
##
##############################################################################
## Copyright (c) 2007 Xilinx, Inc.
## This design is confidential and proprietary of Xilinx, All Rights Reserved.
##############################################################################

############
# Quick Demo
############
Double Click demo/quick_demo.bat. It will use impact to download bit file.


#################
# Project Rebuild
#################
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



#####################
# Archieve structure:
#####################
/source			.v .xco .coe and .ucf source files for the project
/implementation
++picoVOS.bit		pre-build bit file
++run.bat		For windows users, double click it will copy source files
			to work directory, generate the cores and the ISE roject
++run.sh		For Linux users. Function is the same as the windows one
++build_project.tcl	ISE project generation script



