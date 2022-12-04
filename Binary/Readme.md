Customized binary programs.
Built from sources found in Code directory.

FMT3.COM		Format/Verify floppy's, RAM disk, WD drive.
MAKEMOVE.COM	Tool to create MOVCPM.COM from your CP/M images.
SYSGEN5.COM		Transfer OS to/from disk drives.

Createing your custom MOVCPM.COM
1. Assemble from source the following four files you created as needed.
   a. CPM22-20.HEX		CP/M 2.2 with MEM EQU 20
   b. CPM22-24.HEX		CP/M 2.2 with MEM EQU 24
   c. BIOS-20.HEX		BIOS 5.1 with MSIZE EQU 20
   d. BIOS-24.HEX		BIOS 5.1 with MSIZE EQU 24

2. Use DDT.COM to create two binary files.
  Note: '-' is the prompt from DDT, you don't type it in.
		SYSGEN expects the following order of CP/M modules.
		0900H: BOOT
		0980H: CCP
		1180H: BDOS
		1F80H: BIOS

  A:>DDT
   -F100,5000,0
   -ICPM22-20.HEX
   -RD580
   -IBIOS-20.HEX
   -RD580
   -G0 (zero)
  A:>SAVE 34 CPM20.COM
  A:>DDT
   -F100,5000,0
   -ICPM22-24.HEX
   -RC580
   -IBIOS-24.HEX
   -RC580
   -G0 (zero)
  A:>SAVE 34 CPM24.COM
  A:>MAKEMOV CPM20 CPM24
  (Just press RETURN key for all prompts)
     Enter line 1:
	 Enter line 2:


     BMOVCPM.COM Created

  A:>REN MOVCPM.COM=BMOVCPM.COM
  A:>MOVCPM 32 <= Replace 32 with size of image desired: 20k to 64k
  
  Constructing 32K CP/M 2.2
  
  Ready for "SYSGEN" or
  "SAVE 34 CPM32.COM"
  
  A:>
