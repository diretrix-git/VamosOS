# Vamos OS

Vamos OS is an educational 32-bit x86 kernel in C and NASM assembly, developed as a university team project. It combines a Multiboot entry path, hardware interrupts, physical-page allocation, a scheduler and a kernel-space shell. It is a learning implementation, with unresolved correctness questions, rather than a complete general-purpose operating system.

The academic-team context is supplied project attribution. This documentation review does not establish individual line-level authorship or each contributor's responsibilities. Bitmap allocation, round-robin scheduling, descriptor tables and Multiboot are standard techniques; the project demonstrates their integration, not invention of new algorithms.

## Implemented source scope

| Component | Source behavior |
|---|---|
| Boot and descriptors | Multiboot header and entry, kernel GDT, IDT/ISR dispatch, PIC remapping |
| Timer and scheduling | PIT configured for 100 Hz; IRQ0 calls the round-robin scheduler |
| Physical memory | Bitmap allocator for 4 KB frames, with a tracking ceiling of 256 MB |
| Tasks | Pool of 64 PCBs, including the idle task; separately allocated kernel stacks |
| Threads and mutexes | Kernel-thread creation API, shared kernel address space, XCHG-based mutex code |
| I/O | VGA text console, PS/2 scancode translation and COM1 debug output |
| Shell | Built-in commands for task inspection, memory information and demo task creation |

These are source-backed capabilities, not fresh boot or reliability results. See the [source-backed claim ledger](docs/source-backed-claims.md) for pinned evidence and qualifications.

## Requirements

The Makefile targets a freestanding i686 ELF kernel with `i686-linux-gnu-gcc`, `i686-linux-gnu-ld` and NASM. The existing host workflow is Linux/WSL on Windows. Other hosts have not been validated by this review.

On Debian/Ubuntu or a matching WSL distribution, the documented packages are:

```bash
sudo apt update
sudo apt install -y make gcc-i686-linux-gnu binutils-i686-linux-gnu \
                   nasm qemu-system-x86 grub-pc-bin xorriso
```

A compatible GDB is an additional requirement for interactive debugging. Package availability and a successful build have not been checked in Phase 2.

## Build and run

Run from the repository root:

```bash
make        # Build kernel.bin
make run    # QEMU, serial output in this terminal
make debug  # QEMU paused, GDB stub on port 1234
make iso    # Create sora.iso, the current Makefile artifact name
make clean  # Remove generated build artifacts
```

For debugging, run `make debug` in one terminal, then use a compatible debugger in another:

```text
i686-linux-gnu-gdb kernel.bin
(gdb) target remote localhost:1234
(gdb) break kernel_main
(gdb) continue
```

`kernel.bin` is the linked ELF despite its suffix. The Makefile still uses the historical `sora.iso` filename; the project name in this documentation is Vamos OS. [Build instructions](BUILD_INSTRUCTIONS.md) describe the current targets and a proposed manual check sequence.

## Source map

| Path | Purpose |
|---|---|
| `src/boot.asm`, `linker.ld` | Multiboot entry, initial stack, kernel placement at 1 MB |
| `src/kernel_main.c` | Initialization sequence and shell entry |
| `src/gdt.c`, `src/idt.c`, `src/isr.asm` | Descriptor tables and interrupt entry/return |
| `src/pic.c`, `src/pit.c` | Interrupt controller and timer |
| `src/pmm.c` | Physical frame bitmap |
| `src/scheduler.c`, `src/context_switch.asm` | Run queue and stack-pointer switching |
| `src/thread.c`, `src/mutex.c` | Thread and mutex APIs |
| `src/keyboard.c`, `src/vga.c`, `src/serial.c` | Keyboard, console and serial drivers |
| `src/shell.c` | Built-in command implementations and command table |
| `include/`, `iso/boot/grub/` | Headers and GRUB ISO configuration |

## Shell commands

| Command | Purpose |
|---|---|
| `help`, `clear`, `echo <text>` | Help and console output |
| `ls`, `ps`, `threads` | Inspect tasks; `ls` lists tasks, not files |
| `time`, `meminfo` | Uptime and physical-memory information |
| `newprocess`, `killprocess <pid>` | Create or remove a demo process |
| `reboot`, `exit` | Request reboot or emulator shutdown |
| `about`, `banner` | Project text and banner |

The current command table does not register `thread` or `killthread`. Thread creation/deletion exists as C APIs; the `threads` command inspects threads.

## Limits and open correctness questions

There is no paging or virtual memory, ring-3 user mode or user-process isolation, filesystem, executable loader, dynamic heap allocator, or network stack. Tasks share kernel privileges and memory. Display and keyboard support are limited to VGA text mode and PS/2. These are scope limits, not claims about hardware impossibility.

Static review identified the following questions. None was reproduced as a runtime failure in Phase 2, and this documentation makes no fix claim:

- **Switch frame and C ABI:** `context_switch.asm` saves/loads ESP and returns. The ISR path saves general registers, but cooperative calls also reach `schedule()` through mutex waiting. Callee-saved register preservation and initial task frames need checks across both paths.
- **Stack lifetime:** `process_exit()` marks the executing task's stack page free before switching to idle. Reclamation safety needs investigation on a different active stack.
- **Reserved frames:** `pmm_free_page()` checks alignment, range and the used bit, but does not distinguish reserved kernel frames from owned allocations. The allocation loop also omits a final partial bitmap word when the page count is not divisible by 32.

No automated test harness was found in the inspected revision. Phase 2 performed source and documentation review only: no dependency installation, build, QEMU/GDB session or tests. Boot/interrupt smoke checks, register-sentinel switching checks, allocation exhaustion/reservation tests, stack-reuse checks and mutex-contention checks remain proposed verification work.

## Sharing

This repository is public. Use the pinned references in the claim ledger when discussing implementation. Do not infer sole authorship, complete OS functionality or demonstrated reliability from a subsystem list. This documentation review does not establish reuse rights beyond existing project permissions.
