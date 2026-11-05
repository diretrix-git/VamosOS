# Build and inspect Vamos OS

These steps describe the Makefile at source revision `53e774f6615fd5e9a5d8fdf69f1398aa4f93b05b`. Phase 2 did not install tools, build the kernel or run QEMU/GDB. Earlier notes about fixed hangs and absent `kernel/switch.asm` or `kernel/pmm.c` paths do not establish correctness of the current `src/` implementation.

## Toolchain and targets

Use a Linux/WSL environment with `make`, `i686-linux-gnu-gcc`, `i686-linux-gnu-ld`, NASM and `qemu-system-i386`. For ISO creation, also install GRUB tooling and xorriso. See the [README package example](README.md#requirements). A compatible GDB is needed for debugging.

From the repository root:

```bash
make clean
make
make run
```

`make` links `kernel.bin` as an ELF32 kernel. `make run` uses `qemu-system-i386 -kernel kernel.bin -serial stdio`. For an ISO, use `make iso`; the current output filename is `sora.iso`.

For a paused debugging session:

```bash
make debug
```

In another terminal, if the cross-debugger is installed:

```text
i686-linux-gnu-gdb kernel.bin
(gdb) target remote localhost:1234
(gdb) break kernel_main
(gdb) continue
```

## Proposed manual checks, not executed results

1. Record host, compiler, NASM and QEMU versions and the checked-out commit.
2. Capture build output and QEMU serial output. The initialization source contains messages such as `IDT ok`, `PMM ok`, `Scheduler ok` and `Interrupts enabled`; seeing them is a checkpoint, not proof of scheduler correctness.
3. Inspect `help`, `meminfo`, `ps` and `newprocess` in the shell. Capture behavior rather than assuming each command completes safely.
4. Investigate callee-saved register preservation across timer and cooperative switches, process-exit stack reclamation, and reserved-frame frees under GDB before claiming those concerns fixed.

No automated harness exists in this revision. See [the evidence ledger](docs/source-backed-claims.md) for exact implementation references and remaining limits. Do not treat this manual sequence as a completed test run.
