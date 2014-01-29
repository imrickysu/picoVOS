set myProject "picoVOS.ise"
set myScript "build_project.tcl"



   ## put out a 'heartbeat' - so we know something's happening.
   puts "\n$myScript: building ($myProject)...\n"

   if { [ file exists $myProject ] } { 
      puts "$myScript: Removing existing project file."
      file delete $myProject
   }

   puts "$myScript: building project $myProject"
   
   ## create a new project
   project new $myProject
   
   ## open project
   project open $myProject
   
   ## set project properities
   puts "$myScript: Setting project properties..."

   project set family "Spartan3A and Spartan3AN"
   project set device "xc3s700an"
   project set package "fgg484"
   project set speed "-4"
   project set top_level_module_type "HDL"
   project set synthesis_tool "XST (VHDL/Verilog)"
   project set simulator "Modelsim-XE Verilog"
   project set "Preferred Language" "Verilog"
   project set "Enable Message Filtering" "true"
   project set "Display Incremental Messages" "false"
   
   ## add source files
   puts "$myScript: Adding sources to project..."

   xfile add "VOS.V"
   xfile add "audio.v"
   xfile add "audio_counter.v"
   xfile add "bbfifo_16x8.v"
   xfile add "dcm1.v"
   xfile add "freq_rom.xco"
   xfile add "kbd.v"
   xfile add "kbd_f0filter.v"
   xfile add "kbd_fifo.xco"
   xfile add "kbd_receive.v"
   xfile add "kcpsm3.v"
   xfile add "kcuart_tx.v"
   xfile add "logo_ram.xco"
   xfile add "music.xco"
   xfile add "musicbox.v"
   xfile add "score_ram.xco"
   xfile add "synchro.v"
   xfile add "top.ucf"
   xfile add "top.v"
   xfile add "uart_tx.v"
   xfile add "vga_ctrl.v"
   xfile add "vga_ram.xco"
   xfile add "vgatime.v"

   # Set the Top Module as well...
   project set top "top"

   puts "$myScript: project sources reloaded."
   

   puts "$myScript: project rebuild completed."
   
   puts "Running 'Implement Design'"
   if { ! [ process run "Implement Design" ] } {
      puts "$myScript: Implementation run failed, check run output for details."
      project close
      return
   }
   puts "Running 'Generate Programming File'"
   if { ! [ process run "Generate Programming File" ] } {
      puts "$myScript: Generate Programming File run failed, check run output for details."
      project close
      return
   }

  
   project close

