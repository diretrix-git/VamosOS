REBUILD INSTRUCTIONS AFTER FIXES
=================================

The following fixes have been applied:

1. kernel/switch.asm - CRITICAL FIX for context switching hang
   - Fixed corrupted register access after stack pointer change
   - Caches eip and ds values before popping registers

2. kernel/pmm.c - DEBUG OUTPUT for PMM initialization hang
   - Added serial port debug output to trace where hang occurs

3. src/shell.c - Fixed shell multitasking and commands
   - Replaced `spawn` with `newprocess` that yields correctly (so the shell remains responsive)
   - Added `killprocess` for safe process termination
   - Fixed string overflow bugs and made process loops safe

BUILD STEPS (using MSYS2 terminal):
==================================

1. Open MSYS2 terminal (C:\msys64\ucrt64.exe or similar)

2. Navigate to project:
   cd path/to/your/project/OSollama

3. Clean and rebuild:
   make clean
   make

4. Run in QEMU:
   make run

EXPECTED OUTPUT CHANGES:
========================

After the fix, you should see:
- Serial output showing PMM debug messages: [PMM] Initializing, [PMM] Total frames, etc.
- If it still hangs, the serial output will show exactly where the hang is
- In the OS shell, you can now run `newprocess` to create a demo background process and `killprocess <pid>` to safely end it without blocking the shell.

If building fails with errors, check:
- NASM is available: /c/msys64/ucrt64/bin/nasm.exe
- GCC is available: gcc.exe
- LD is available: ld.exe
- Working directory has Makefile

TROUBLESHOOTING:
===============

If you still see "PMM init..." hanging:
- The serial debug output will tell you exactly where
- It could be in: bitmap clearing, frame marking, or somewhere else
- Once you see which step hangs, we can debug further

The switch.asm fix addresses the earlier hang at "Enabling interrupts..."
The pmm.c changes add tracing to find the new hang point.
