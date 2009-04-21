From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: 2.6.29.1: Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
Date: Tue, 21 Apr 2009 12:09:55 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0904211202590.10241@p34.internal.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755141AbZDUQKV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

This has been happening with 2.6.28.(x) and now 2.6.29.(x), can anyone 
suggest the possible root cause of this problem, re: the nfsd page allocation
failures:

[1204250.777983] nfsd: page allocation failure. order:0, mode:0x20
[1204250.777986] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.777988] Call Trace:

Memory:
Mem:   8100728k total,  7562480k used,   538248k free,      600k buffers
Swap: 16787768k total,    29040k used, 16758728k free,  6089356k cached

Platform: x86_64
Distro: Debian Testing
Kernel: 2.6.29.1
Kernel config URL below:
http://home.comcast.net/~jpiszcz/20090421/linux-2.6.29.1-config.txt

Full dmesg:

[    0.000000] Linux version 2.6.29.1 (root@p34.internal.lan) (gcc version 4.3.3 (Debian 4.3.3-3) ) #4 SMP Tue Apr 7 12:55:54 EDT 2009
[    0.000000] Command line: auto BOOT_IMAGE=2.6.29.1-4 ro root=902
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000008f000 (usable)
[    0.000000]  BIOS-e820: 000000000008f000 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cf58f000 (usable)
[    0.000000]  BIOS-e820: 00000000cf58f000 - 00000000cf59c000 (reserved)
[    0.000000]  BIOS-e820: 00000000cf59c000 - 00000000cf639000 (usable)
[    0.000000]  BIOS-e820: 00000000cf639000 - 00000000cf694000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000cf694000 - 00000000cf697000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cf697000 - 00000000cf6ef000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000cf6ef000 - 00000000cf6f1000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cf6f1000 - 00000000cf6f2000 (usable)
[    0.000000]  BIOS-e820: 00000000cf6f2000 - 00000000cf6ff000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cf6ff000 - 00000000cf700000 (usable)
[    0.000000]  BIOS-e820: 00000000cf700000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f8000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 000000022c000000 (usable)
[    0.000000] DMI 2.4 present.
[    0.000000] last_pfn = 0x22c000 max_arch_pfn = 0x100000000
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] last_pfn = 0xcf700 max_arch_pfn = 0x100000000
[    0.000000] init_memory_mapping: 0000000000000000-00000000cf700000
[    0.000000]  0000000000 - 00cf600000 page 2M
[    0.000000]  00cf600000 - 00cf700000 page 4k
[    0.000000] kernel direct mapping tables up to cf700000 @ 8000-e000
[    0.000000] last_map_addr: cf700000 end: cf700000
[    0.000000] init_memory_mapping: 0000000100000000-000000022c000000
[    0.000000]  0100000000 - 022c000000 page 2M
[    0.000000] kernel direct mapping tables up to 22c000000 @ c000-16000
[    0.000000] last_map_addr: 22c000000 end: 22c000000
[    0.000000] ACPI: RSDP 000FE020, 0014 (r0 INTEL )
[    0.000000] ACPI: RSDT CF6FD038, 0050 (r1 INTEL  DG965WH       6DA       1000013)
[    0.000000] ACPI: FACP CF6FC000, 0074 (r1 INTEL  DG965WH       6DA MSFT  1000013)
[    0.000000] FADT: X_PM1a_EVT_BLK.bit_width (16) does not match PM1_EVT_LEN (4)
[    0.000000] ACPI: DSDT CF6F7000, 41E6 (r1 INTEL  DG965WH       6DA MSFT  1000013)
[    0.000000] ACPI: FACS CF697000, 0040
[    0.000000] ACPI: APIC CF6F6000, 0078 (r1 INTEL  DG965WH       6DA MSFT  1000013)
[    0.000000] ACPI: WDDT CF6F5000, 0040 (r1 INTEL  DG965WH       6DA MSFT  1000013)
[    0.000000] ACPI: MCFG CF6F4000, 003C (r1 INTEL  DG965WH       6DA MSFT  1000013)
[    0.000000] ACPI: ASF! CF6F3000, 00A6 (r32 INTEL  DG965WH       6DA MSFT  1000013)
[    0.000000] ACPI: HPET CF6F2000, 0038 (r1 INTEL  DG965WH       6DA MSFT  1000013)
[    0.000000] ACPI: SSDT CF6F0000, 020C (r1 INTEL     CpuPm      6DA MSFT  1000013)
[    0.000000] ACPI: SSDT CF6EF000, 0175 (r1 INTEL   Cpu0Ist      6DA MSFT  1000013)
[    0.000000] ACPI: SSDT CF696000, 0175 (r1 INTEL   Cpu1Ist      6DA MSFT  1000013)
[    0.000000] ACPI: SSDT CF695000, 0175 (r1 INTEL   Cpu2Ist      6DA MSFT  1000013)
[    0.000000] ACPI: SSDT CF694000, 0175 (r1 INTEL   Cpu3Ist      6DA MSFT  1000013)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 022c000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
[    0.000000]   #2 [0000200000 - 000085fe2c]    TEXT DATA BSS ==> [0000200000 - 000085fe2c]
[    0.000000]   #3 [000009d800 - 0000100000]    BIOS reserved ==> [000009d800 - 0000100000]
[    0.000000]   #4 [0000008000 - 000000c000]          PGTABLE ==> [0000008000 - 000000c000]
[    0.000000]   #5 [000000c000 - 0000011000]          PGTABLE ==> [000000c000 - 0000011000]
[    0.000000]  [ffffe20000000000-ffffe20007bfffff] PMD -> [ffff880028200000-ffff88002fdfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x0022c000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000008f
[    0.000000]     0: 0x00000100 -> 0x000cf58f
[    0.000000]     0: 0x000cf59c -> 0x000cf639
[    0.000000]     0: 0x000cf6f1 -> 0x000cf6f2
[    0.000000]     0: 0x000cf6ff -> 0x000cf700
[    0.000000]     0: 0x00100000 -> 0x0022c000
[    0.000000] On node 0 totalpages: 2078141
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 1741 pages reserved
[    0.000000]   DMA zone: 2186 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 831078 pages, LIFO batch:31
[    0.000000]   Normal zone: 16800 pages used for memmap
[    0.000000]   Normal zone: 1212000 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] Allocating PCI resources starting at d2000000 (gap: d0000000:20000000)
[    0.000000] NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Allocating 40960 bytes of per cpu data
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2045264
[    0.000000] Kernel command line: auto BOOT_IMAGE=2.6.29.1-4 ro root=902
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2397.455 MHz processor.
[    0.000999] Console: colour dummy device 80x25
[    0.000999] console [tty0] enabled
[    0.000999] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.000999] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000999] Checking aperture...
[    0.000999] No AGP bridge found
[    0.000999] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.000999] Placing 64MB software IO TLB between ffff880020000000 - ffff880024000000
[    0.000999] software IO TLB at phys 0x20000000 - 0x24000000
[    0.000999] Memory: 8099460k/9109504k available (4301k kernel code, 796940k absent, 212216k reserved, 1381k data, 344k init)
[    0.000999] hpet clockevent registered
[    0.000999] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.000999] Calibrating delay loop (skipped), value calculated using timer frequency.. 4794.91 BogoMIPS (lpj=2397455)
[    0.000999] Mount-cache hash table entries: 256
[    0.000999] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.000999] CPU: L2 cache: 4096K
[    0.000999] [ds] using Core 2/Atom configuration
[    0.000999] CPU: Physical Processor ID: 0
[    0.000999] CPU: Processor Core ID: 0
[    0.000999] CPU0: Thermal monitoring enabled (TM2)
[    0.000999] using mwait in idle threads.
[    0.000999] Freeing SMP alternatives: 33k freed
[    0.000999] ACPI: Core revision 20081204
[    0.006041] Setting APIC routing to flat
[    0.007245] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.017256] CPU0: Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz stepping 07
[    0.017999] Booting processor 1 APIC 0x2 ip 0x6000
[    0.000999] Initializing CPU#1
[    0.000999] Calibrating delay using timer specific routine.. 4986.78 BogoMIPS (lpj=2493390)
[    0.000999] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.000999] CPU: L2 cache: 4096K
[    0.000999] [ds] using Core 2/Atom configuration
[    0.000999] CPU: Physical Processor ID: 0
[    0.000999] CPU: Processor Core ID: 2
[    0.000999] CPU1: Thermal monitoring enabled (TM2)
[    0.000999] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
[    0.089165] CPU1: Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz stepping 07
[    0.089196] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[    0.090085] Booting processor 2 APIC 0x1 ip 0x6000
[    0.000999] Initializing CPU#2
[    0.000999] Calibrating delay using timer specific routine.. 4794.99 BogoMIPS (lpj=2397499)
[    0.000999] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.000999] CPU: L2 cache: 4096K
[    0.000999] [ds] using Core 2/Atom configuration
[    0.000999] CPU: Physical Processor ID: 0
[    0.000999] CPU: Processor Core ID: 1
[    0.000999] CPU2: Thermal monitoring enabled (TM2)
[    0.000999] x86 PAT enabled: cpu 2, old 0x7040600070406, new 0x7010600070106
[    0.162226] CPU2: Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz stepping 07
[    0.162257] checking TSC synchronization [CPU#0 -> CPU#2]: passed.
[    0.163106] Booting processor 3 APIC 0x3 ip 0x6000
[    0.000999] Initializing CPU#3
[    0.000999] Calibrating delay using timer specific routine.. 4794.97 BogoMIPS (lpj=2397485)
[    0.000999] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.000999] CPU: L2 cache: 4096K
[    0.000999] [ds] using Core 2/Atom configuration
[    0.000999] CPU: Physical Processor ID: 0
[    0.000999] CPU: Processor Core ID: 3
[    0.000999] CPU3: Thermal monitoring enabled (TM2)
[    0.000999] x86 PAT enabled: cpu 3, old 0x7040600070406, new 0x7010600070106
[    0.235210] CPU3: Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz stepping 07
[    0.235240] checking TSC synchronization [CPU#0 -> CPU#3]: passed.
[    0.236017] Brought up 4 CPUs
[    0.236021] Total of 4 processors activated (19371.65 BogoMIPS).
[    0.236508] net_namespace: 944 bytes
[    0.236671] NET: Registered protocol family 16
[    0.237286] ACPI: bus type pci registered
[    0.237314] PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 127
[    0.237319] PCI: MCFG area at f0000000 reserved in E820
[    0.242116] PCI: Using MMCONFIG at f0000000 - f7ffffff
[    0.242119] PCI: Using configuration type 1 for base access
[    0.246550] bio: create slab <bio-0> at 0
[    0.247183] ACPI: EC: Look up EC in DSDT
[    0.249981] ACPI: Interpreter enabled
[    0.249984] ACPI: (supports S0 S5)
[    0.250004] ACPI: Using IOAPIC for interrupt routing
[    0.254470] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.254601] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.254605] pci 0000:00:01.0: PME# disabled
[    0.254624] pci 0000:00:02.0: reg 10 32bit mmio: [0xe2200000-0xe22fffff]
[    0.254631] pci 0000:00:02.0: reg 18 64bit mmio: [0xd0000000-0xdfffffff]
[    0.254634] pci 0000:00:02.0: reg 20 io port: [0x4410-0x4417]
[    0.254678] pci 0000:00:03.0: reg 10 64bit mmio: [0xe2426100-0xe242610f]
[    0.254710] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.254713] pci 0000:00:03.0: PME# disabled
[    0.254762] pci 0000:00:19.0: reg 10 32bit mmio: [0xe2400000-0xe241ffff]
[    0.254766] pci 0000:00:19.0: reg 14 32bit mmio: [0xe2424000-0xe2424fff]
[    0.254771] pci 0000:00:19.0: reg 18 io port: [0x40e0-0x40ff]
[    0.254800] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
[    0.254804] pci 0000:00:19.0: PME# disabled
[    0.254837] pci 0000:00:1a.0: reg 20 io port: [0x40c0-0x40df]
[    0.254876] pci 0000:00:1a.1: reg 20 io port: [0x40a0-0x40bf]
[    0.254942] pci 0000:00:1a.7: reg 10 32bit mmio: [0xe2425c00-0xe2425fff]
[    0.254985] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    0.254989] pci 0000:00:1a.7: PME# disabled
[    0.254999] pci 0000:00:1b.0: reg 10 64bit mmio: [0xe2420000-0xe2423fff]
[    0.255017] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.255021] pci 0000:00:1b.0: PME# disabled
[    0.255069] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.255073] pci 0000:00:1c.0: PME# disabled
[    0.255120] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.255124] pci 0000:00:1c.1: PME# disabled
[    0.255173] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.255177] pci 0000:00:1c.2: PME# disabled
[    0.255225] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.255228] pci 0000:00:1c.3: PME# disabled
[    0.255277] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.255281] pci 0000:00:1c.4: PME# disabled
[    0.255318] pci 0000:00:1d.0: reg 20 io port: [0x4080-0x409f]
[    0.255358] pci 0000:00:1d.1: reg 20 io port: [0x4060-0x407f]
[    0.255397] pci 0000:00:1d.2: reg 20 io port: [0x4040-0x405f]
[    0.255441] pci 0000:00:1d.7: reg 10 32bit mmio: [0xe2425800-0xe2425bff]
[    0.255484] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.255489] pci 0000:00:1d.7: PME# disabled
[    0.255593] pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6 ACPI/GPIO/TCO
[    0.255598] pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH6 GPIO
[    0.255602] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0680 (mask 007f)
[    0.255653] pci 0000:00:1f.2: reg 10 io port: [0x4408-0x440f]
[    0.255658] pci 0000:00:1f.2: reg 14 io port: [0x441c-0x441f]
[    0.255662] pci 0000:00:1f.2: reg 18 io port: [0x4400-0x4407]
[    0.255677] pci 0000:00:1f.2: reg 1c io port: [0x4418-0x441b]
[    0.255681] pci 0000:00:1f.2: reg 20 io port: [0x4020-0x403f]
[    0.255686] pci 0000:00:1f.2: reg 24 32bit mmio: [0xe2425000-0xe24257ff]
[    0.255719] pci 0000:00:1f.2: PME# supported from D3hot
[    0.255723] pci 0000:00:1f.2: PME# disabled
[    0.255742] pci 0000:00:1f.3: reg 10 32bit mmio: [0xe2426000-0xe24260ff]
[    0.255756] pci 0000:00:1f.3: reg 20 io port: [0x4000-0x401f]
[    0.255795] pci 0000:01:00.0: reg 10 64bit mmio: [0xe0000000-0xe1ffffff]
[    0.255802] pci 0000:01:00.0: reg 18 64bit mmio: [0xe2300000-0xe2300fff]
[    0.255806] pci 0000:01:00.0: reg 20 io port: [0x3000-0x30ff]
[    0.255813] pci 0000:01:00.0: reg 30 32bit mmio: [0xfffe0000-0xffffffff]
[    0.255829] pci 0000:01:00.0: supports D1 D2
[    0.255860] pci 0000:00:01.0: bridge io port: [0x3000-0x3fff]
[    0.255863] pci 0000:00:01.0: bridge 32bit mmio: [0xe2300000-0xe23fffff]
[    0.255866] pci 0000:00:01.0: bridge 64bit mmio pref: [0xe0000000-0xe1ffffff]
[    0.255959] pci 0000:03:00.0: reg 10 io port: [0x2018-0x201f]
[    0.255966] pci 0000:03:00.0: reg 14 io port: [0x2024-0x2027]
[    0.255972] pci 0000:03:00.0: reg 18 io port: [0x2010-0x2017]
[    0.255979] pci 0000:03:00.0: reg 1c io port: [0x2020-0x2023]
[    0.255986] pci 0000:03:00.0: reg 20 io port: [0x2000-0x200f]
[    0.255993] pci 0000:03:00.0: reg 24 32bit mmio: [0xe2100000-0xe21001ff]
[    0.256031] pci 0000:03:00.0: supports D1
[    0.256032] pci 0000:03:00.0: PME# supported from D0 D1 D3hot
[    0.256038] pci 0000:03:00.0: PME# disabled
[    0.256076] pci 0000:00:1c.1: bridge io port: [0x2000-0x2fff]
[    0.256079] pci 0000:00:1c.1: bridge 32bit mmio: [0xe2100000-0xe21fffff]
[    0.256223] pci 0000:07:00.0: reg 10 32bit mmio: [0xe2060000-0xe207ffff]
[    0.256229] pci 0000:07:00.0: reg 14 32bit mmio: [0xe2040000-0xe205ffff]
[    0.256234] pci 0000:07:00.0: reg 18 io port: [0x1040-0x107f]
[    0.256253] pci 0000:07:00.0: reg 30 32bit mmio: [0xfffe0000-0xffffffff]
[    0.256275] pci 0000:07:00.0: PME# supported from D0 D3hot D3cold
[    0.256279] pci 0000:07:00.0: PME# disabled
[    0.256324] pci 0000:07:01.0: reg 10 32bit mmio: [0xe2020000-0xe203ffff]
[    0.256330] pci 0000:07:01.0: reg 14 32bit mmio: [0xe2000000-0xe201ffff]
[    0.256336] pci 0000:07:01.0: reg 18 io port: [0x1000-0x103f]
[    0.256354] pci 0000:07:01.0: reg 30 32bit mmio: [0xfffe0000-0xffffffff]
[    0.256376] pci 0000:07:01.0: PME# supported from D0 D3hot D3cold
[    0.256381] pci 0000:07:01.0: PME# disabled
[    0.256423] pci 0000:00:1e.0: transparent bridge
[    0.256427] pci 0000:00:1e.0: bridge io port: [0x1000-0x1fff]
[    0.256429] pci 0000:00:1e.0: bridge 32bit mmio: [0xe2000000-0xe20fffff]
[    0.256455] pci_bus 0000:00: on NUMA node 0
[    0.256459] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.256625] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P32_._PRT]
[    0.256760] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
[    0.256810] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
[    0.256859] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
[    0.256908] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
[    0.256967] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
[    0.262218] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 10 *11 12)
[    0.262356] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 *10 11 12)
[    0.262456] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11 12)
[    0.262546] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 *11 12)
[    0.262636] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 *9 10 11 12)
[    0.262724] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 *10 11 12)
[    0.262813] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 *9 10 11 12)
[    0.262901] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 9 10 *11 12)
[    0.263447] SCSI subsystem initialized
[    0.263542] libata version 3.00 loaded.
[    0.263689] usbcore: registered new interface driver usbfs
[    0.263724] usbcore: registered new interface driver hub
[    0.263818] usbcore: registered new device driver usb
[    0.263999] PCI: Using ACPI for IRQ routing
[    0.269034] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.269041] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.275046] pnp: PnP ACPI init
[    0.275056] ACPI: bus type pnp registered
[    0.277582] pnp: PnP ACPI: found 10 devices
[    0.277586] ACPI: ACPI bus type pnp unregistered
[    0.277597] system 00:01: iomem range 0xf0000000-0xf7ffffff has been reserved
[    0.277612] system 00:01: iomem range 0xfed13000-0xfed13fff has been reserved
[    0.277615] system 00:01: iomem range 0xfed14000-0xfed17fff has been reserved
[    0.277618] system 00:01: iomem range 0xfed18000-0xfed18fff has been reserved
[    0.277621] system 00:01: iomem range 0xfed19000-0xfed19fff has been reserved
[    0.277624] system 00:01: iomem range 0xfed1c000-0xfed1ffff has been reserved
[    0.277627] system 00:01: iomem range 0xfed20000-0xfed3ffff has been reserved
[    0.277630] system 00:01: iomem range 0xfed45000-0xfed99fff has been reserved
[    0.277633] system 00:01: iomem range 0xc0000-0xdffff has been reserved
[    0.277636] system 00:01: iomem range 0xe0000-0xfffff could not be reserved
[    0.277642] system 00:06: ioport range 0x500-0x53f has been reserved
[    0.277645] system 00:06: ioport range 0x400-0x47f has been reserved
[    0.277647] system 00:06: ioport range 0x360-0x361 has been reserved
[    0.277650] system 00:06: ioport range 0x680-0x6ff has been reserved
[    0.282633] pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
[    0.282636] pci 0000:00:01.0:   IO window: 0x3000-0x3fff
[    0.282640] pci 0000:00:01.0:   MEM window: 0xe2300000-0xe23fffff
[    0.282644] pci 0000:00:01.0:   PREFETCH window: 0x000000e0000000-0x000000e1ffffff
[    0.282649] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
[    0.282651] pci 0000:00:1c.0:   IO window: disabled
[    0.282655] pci 0000:00:1c.0:   MEM window: disabled
[    0.282659] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.282664] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
[    0.282668] pci 0000:00:1c.1:   IO window: 0x2000-0x2fff
[    0.282672] pci 0000:00:1c.1:   MEM window: 0xe2100000-0xe21fffff
[    0.282676] pci 0000:00:1c.1:   PREFETCH window: disabled
[    0.282681] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:04
[    0.282684] pci 0000:00:1c.2:   IO window: disabled
[    0.282688] pci 0000:00:1c.2:   MEM window: disabled
[    0.282691] pci 0000:00:1c.2:   PREFETCH window: disabled
[    0.282697] pci 0000:00:1c.3: PCI bridge, secondary bus 0000:05
[    0.282699] pci 0000:00:1c.3:   IO window: disabled
[    0.282703] pci 0000:00:1c.3:   MEM window: disabled
[    0.282707] pci 0000:00:1c.3:   PREFETCH window: disabled
[    0.282712] pci 0000:00:1c.4: PCI bridge, secondary bus 0000:06
[    0.282714] pci 0000:00:1c.4:   IO window: disabled
[    0.282719] pci 0000:00:1c.4:   MEM window: disabled
[    0.282722] pci 0000:00:1c.4:   PREFETCH window: disabled
[    0.282738] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:07
[    0.282741] pci 0000:00:1e.0:   IO window: 0x1000-0x1fff
[    0.282755] pci 0000:00:1e.0:   MEM window: 0xe2000000-0xe20fffff
[    0.282759] pci 0000:00:1e.0:   PREFETCH window: 0x000000e2500000-0x000000e25fffff
[    0.282771] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.282775] pci 0000:00:01.0: setting latency timer to 64
[    0.282781] pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.282785] pci 0000:00:1c.0: setting latency timer to 64
[    0.282790] pci 0000:00:1c.1: PCI INT B -> GSI 16 (level, low) -> IRQ 16
[    0.282794] pci 0000:00:1c.1: setting latency timer to 64
[    0.282800] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.282804] pci 0000:00:1c.2: setting latency timer to 64
[    0.282810] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    0.282814] pci 0000:00:1c.3: setting latency timer to 64
[    0.282819] pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.282823] pci 0000:00:1c.4: setting latency timer to 64
[    0.282828] pci 0000:00:1e.0: setting latency timer to 64
[    0.282831] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.282832] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
[    0.282834] pci_bus 0000:01: resource 0 io:  [0x3000-0x3fff]
[    0.282835] pci_bus 0000:01: resource 1 mem: [0xe2300000-0xe23fffff]
[    0.282837] pci_bus 0000:01: resource 2 mem: [0xe0000000-0xe1ffffff]
[    0.282838] pci_bus 0000:01: resource 3 mem: [0x0-0x0]
[    0.282839] pci_bus 0000:02: resource 0 mem: [0x0-0x0]
[    0.282841] pci_bus 0000:02: resource 1 mem: [0x0-0x0]
[    0.282842] pci_bus 0000:02: resource 2 mem: [0x0-0x0]
[    0.282843] pci_bus 0000:02: resource 3 mem: [0x0-0x0]
[    0.282845] pci_bus 0000:03: resource 0 io:  [0x2000-0x2fff]
[    0.282846] pci_bus 0000:03: resource 1 mem: [0xe2100000-0xe21fffff]
[    0.282847] pci_bus 0000:03: resource 2 mem: [0x0-0x0]
[    0.282849] pci_bus 0000:03: resource 3 mem: [0x0-0x0]
[    0.282850] pci_bus 0000:04: resource 0 mem: [0x0-0x0]
[    0.282851] pci_bus 0000:04: resource 1 mem: [0x0-0x0]
[    0.282852] pci_bus 0000:04: resource 2 mem: [0x0-0x0]
[    0.282854] pci_bus 0000:04: resource 3 mem: [0x0-0x0]
[    0.282855] pci_bus 0000:05: resource 0 mem: [0x0-0x0]
[    0.282856] pci_bus 0000:05: resource 1 mem: [0x0-0x0]
[    0.282857] pci_bus 0000:05: resource 2 mem: [0x0-0x0]
[    0.282859] pci_bus 0000:05: resource 3 mem: [0x0-0x0]
[    0.282860] pci_bus 0000:06: resource 0 mem: [0x0-0x0]
[    0.282861] pci_bus 0000:06: resource 1 mem: [0x0-0x0]
[    0.282862] pci_bus 0000:06: resource 2 mem: [0x0-0x0]
[    0.282864] pci_bus 0000:06: resource 3 mem: [0x0-0x0]
[    0.282865] pci_bus 0000:07: resource 0 io:  [0x1000-0x1fff]
[    0.282866] pci_bus 0000:07: resource 1 mem: [0xe2000000-0xe20fffff]
[    0.282868] pci_bus 0000:07: resource 2 mem: [0xe2500000-0xe25fffff]
[    0.282869] pci_bus 0000:07: resource 3 io:  [0x00-0xffff]
[    0.282871] pci_bus 0000:07: resource 4 mem: [0x000000-0xffffffffffffffff]
[    0.282947] NET: Registered protocol family 2
[    0.293519] IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.294199] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    0.295714] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.296296] TCP: Hash tables configured (established 262144 bind 65536)
[    0.296299] TCP reno registered
[    0.299647] NET: Registered protocol family 1
[    0.302128] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    0.302354] NTFS driver 2.1.29 [Flags: R/O].
[    0.302440] SGI XFS with security attributes, large block/inode numbers, no debug enabled
[    0.302898] msgmni has been set to 15821
[    0.302932] io scheduler noop registered
[    0.302936] io scheduler deadline registered
[    0.302959] io scheduler cfq registered (default)
[    0.302973] pci 0000:00:02.0: Boot video device
[    0.303466] pcieport-driver 0000:00:01.0: setting latency timer to 64
[    0.303505] pcieport-driver 0000:00:01.0: irq 24 for MSI/MSI-X
[    0.303643] pcieport-driver 0000:00:1c.0: setting latency timer to 64
[    0.303662] pcieport-driver 0000:00:1c.0: irq 25 for MSI/MSI-X
[    0.303859] pcieport-driver 0000:00:1c.1: setting latency timer to 64
[    0.303910] pcieport-driver 0000:00:1c.1: irq 26 for MSI/MSI-X
[    0.304092] pcieport-driver 0000:00:1c.2: setting latency timer to 64
[    0.304134] pcieport-driver 0000:00:1c.2: irq 27 for MSI/MSI-X
[    0.304310] pcieport-driver 0000:00:1c.3: setting latency timer to 64
[    0.304361] pcieport-driver 0000:00:1c.3: irq 28 for MSI/MSI-X
[    0.304518] pcieport-driver 0000:00:1c.4: setting latency timer to 64
[    0.304568] pcieport-driver 0000:00:1c.4: irq 29 for MSI/MSI-X
[    0.305145] vesafb: framebuffer at 0xd0000000, mapped to 0xffffc20008100000, using 2560k, total 7616k
[    0.305151] vesafb: mode is 1280x1024x8, linelength=1280, pages=4
[    0.305155] vesafb: scrolling: redraw
[    0.305158] vesafb: Pseudocolor: size=8:8:8:8, shift=0:0:0:0
[    0.315975] Console: switching to colour frame buffer device 160x64
[    0.326676] fb0: VESA VGA frame buffer device
[    0.326853] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.326960] ACPI: Power Button (FF) [PWRF]
[    0.327093] input: Sleep Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input1
[    0.327213] ACPI: Sleep Button (CM) [SLPB]
[    0.339318] Real Time Clock Driver v1.12b
[    0.339544] Linux agpgart interface v0.103
[    0.339616] agpgart-intel 0000:00:00.0: Intel 965G Chipset
[    0.340794] agpgart-intel 0000:00:00.0: detected 7676K stolen memory
[    0.343737] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    0.343977] [drm] Initialized drm 1.1.0 20060810
[    0.344091] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.344172] pci 0000:00:02.0: setting latency timer to 64
[    0.356276] pci 0000:00:02.0: irq 30 for MSI/MSI-X
[    0.356302] [drm] Initialized i915 1.6.0 20080730 on minor 0
[    0.357233] loop: module loaded
[    0.357277] Intel(R) PRO/1000 Network Driver - version 7.3.21-k3-NAPI
[    0.357367] Copyright (c) 1999-2006 Intel Corporation.
[    0.357463] e1000 0000:07:00.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
[    0.501974] Switched to high resolution mode on CPU 2
[    0.502375] Switched to high resolution mode on CPU 1
[    0.502590] Switched to high resolution mode on CPU 3
[    0.502690] Switched to high resolution mode on CPU 0
[    0.604218] e1000: 0000:07:00.0: e1000_probe: (PCI:33MHz:32-bit) 00:07:e9:29:37:db
[    0.631263] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
[    0.631355] e1000 0000:07:01.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    0.893148] e1000: 0000:07:01.0: e1000_probe: (PCI:33MHz:32-bit) 00:0e:0c:00:cd:b1
[    1.042196] e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
[    1.042344] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k6
[    1.042429] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[    1.042536] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    1.042620] e1000e 0000:00:19.0: setting latency timer to 64
[    1.042677] e1000e 0000:00:19.0: irq 31 for MSI/MSI-X
[    1.230399] 0000:00:19.0: eth2: (PCI Express:2.5GB/s:Width x1) 00:19:d1:6e:9d:43
[    1.230507] 0000:00:19.0: eth2: Intel(R) PRO/1000 Network Connection
[    1.230601] 0000:00:19.0: eth2: MAC: 5, PHY: 6, PBA No: ffffff-0ff
[    1.230739] 3ware 9000 Storage Controller device driver for Linux v2.26.02.011.
[    1.230850] 3w-9xxx 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.230934] 3w-9xxx 0000:01:00.0: setting latency timer to 64
[    1.486027] scsi0 : 3ware 9000 Storage Controller
[    1.486229] 3w-9xxx: scsi0: Found a 3ware 9000 Storage Controller at 0xe2300000, IRQ: 16.
[    1.793025] 3w-9xxx: scsi0: Firmware FE9X 4.06.00.004, BIOS BE9X 4.05.00.015, Ports: 16.
[    1.793432] scsi 0:0:0:0: Direct-Access     AMCC     9650SE-16M DISK  4.06 PQ: 0 ANSI: 5
[    1.800570] Driver 'sd' needs updating - please use bus_type methods
[    1.800869] sd 0:0:0:0: [sda] Very big device. Trying to use READ CAPACITY(16).
[    1.801022] sd 0:0:0:0: [sda] 25390350336 512-byte hardware sectors: (12.9 TB/11.8 TiB)
[    1.801478] sd 0:0:0:0: [sda] Write Protect is off
[    1.801543] sd 0:0:0:0: [sda] Mode Sense: 23 00 00 00
[    1.802160] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.805036] sd 0:0:0:0: [sda] Very big device. Trying to use READ CAPACITY(16).
[    1.807881] sd 0:0:0:0: [sda] 25390350336 512-byte hardware sectors: (12.9 TB/11.8 TiB)
[    1.811043] sd 0:0:0:0: [sda] Write Protect is off
[    1.813887] sd 0:0:0:0: [sda] Mode Sense: 23 00 00 00
[    1.814506] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.817476]  sda: sda1
[    1.851888] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.855000] ahci 0000:00:1f.2: version 3.0
[    1.855018] ahci 0000:00:1f.2: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    1.858094] ahci 0000:00:1f.2: irq 32 for MSI/MSI-X
[    1.858148] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
[    1.861299] ahci 0000:00:1f.2: flags: 64bit ncq sntf led clo pio slum part ems 
[    1.864495] ahci 0000:00:1f.2: setting latency timer to 64
[    1.864763] scsi1 : ahci
[    1.868096] scsi2 : ahci
[    1.871455] scsi3 : ahci
[    1.874798] scsi4 : ahci
[    1.878148] scsi5 : ahci
[    1.881529] scsi6 : ahci
[    1.884875] ata1: SATA max UDMA/133 abar m2048@0xe2425000 port 0xe2425100 irq 32
[    1.888241] ata2: SATA max UDMA/133 abar m2048@0xe2425000 port 0xe2425180 irq 32
[    1.891590] ata3: SATA max UDMA/133 abar m2048@0xe2425000 port 0xe2425200 irq 32
[    1.894930] ata4: SATA max UDMA/133 abar m2048@0xe2425000 port 0xe2425280 irq 32
[    1.898293] ata5: SATA max UDMA/133 abar m2048@0xe2425000 port 0xe2425300 irq 32
[    1.901664] ata6: SATA max UDMA/133 abar m2048@0xe2425000 port 0xe2425380 irq 32
[    2.209429] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.215045] ata1.00: ATA-7: WDC WD1500ADFS-00SLR5, 21.07QR5, max UDMA/133
[    2.218605] ata1.00: 293046768 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    2.224852] ata1.00: configured for UDMA/133
[    2.228418] scsi 1:0:0:0: Direct-Access     ATA      WDC WD1500ADFS-0 21.0 PQ: 0 ANSI: 5
[    2.232118] sd 1:0:0:0: [sdb] 293046768 512-byte hardware sectors: (150 GB/139 GiB)
[    2.235626] sd 1:0:0:0: [sdb] Write Protect is off
[    2.239022] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    2.239038] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.242533] sd 1:0:0:0: [sdb] 293046768 512-byte hardware sectors: (150 GB/139 GiB)
[    2.245984] sd 1:0:0:0: [sdb] Write Protect is off
[    2.249455] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    2.249470] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.252959]  sdb: sdb1 sdb2 sdb3
[    2.266789] sd 1:0:0:0: [sdb] Attached SCSI disk
[    2.993427] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    2.999152] ata2.00: ATA-7: WDC WD1500ADFD-00NLR4, 21.07QR4, max UDMA/133
[    3.002748] ata2.00: 293046768 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    3.009101] ata2.00: configured for UDMA/133
[    3.012706] scsi 2:0:0:0: Direct-Access     ATA      WDC WD1500ADFD-0 21.0 PQ: 0 ANSI: 5
[    3.016494] sd 2:0:0:0: [sdc] 293046768 512-byte hardware sectors: (150 GB/139 GiB)
[    3.020059] sd 2:0:0:0: [sdc] Write Protect is off
[    3.023621] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    3.023636] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.027250] sd 2:0:0:0: [sdc] 293046768 512-byte hardware sectors: (150 GB/139 GiB)
[    3.030833] sd 2:0:0:0: [sdc] Write Protect is off
[    3.034371] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    3.034386] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.037965]  sdc: sdc1 sdc2 sdc3
[    3.051397] sd 2:0:0:0: [sdc] Attached SCSI disk
[    3.359426] ata3: SATA link down (SStatus 0 SControl 300)
[    3.667426] ata4: SATA link down (SStatus 0 SControl 300)
[    4.393427] ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    4.399329] ata5.00: ATA-7: WDC WD1500ADFD-00NLR1, 20.07P20, max UDMA/133
[    4.402822] ata5.00: 293046768 sectors, multi 0: LBA48 NCQ (depth 31/32)
[    4.409453] ata5.00: configured for UDMA/133
[    4.412991] scsi 5:0:0:0: Direct-Access     ATA      WDC WD1500ADFD-0 20.0 PQ: 0 ANSI: 5
[    4.416724] sd 5:0:0:0: [sdd] 293046768 512-byte hardware sectors: (150 GB/139 GiB)
[    4.420231] sd 5:0:0:0: [sdd] Write Protect is off
[    4.423679] sd 5:0:0:0: [sdd] Mode Sense: 00 3a 00 00
[    4.423694] sd 5:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.427213] sd 5:0:0:0: [sdd] 293046768 512-byte hardware sectors: (150 GB/139 GiB)
[    4.430691] sd 5:0:0:0: [sdd] Write Protect is off
[    4.434088] sd 5:0:0:0: [sdd] Mode Sense: 00 3a 00 00
[    4.434103] sd 5:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.437583]  sdd: sdd1 sdd2 sdd3
[    4.447953] sd 5:0:0:0: [sdd] Attached SCSI disk
[    4.756287] ata6: SATA link down (SStatus 0 SControl 300)
[    4.759780] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    4.763223] ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    4.766654] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[    4.766656] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    4.770099] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
[    4.777442] ehci_hcd 0000:00:1a.7: debug port 1
[    4.780751] ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
[    4.780762] ehci_hcd 0000:00:1a.7: irq 18, io mem 0xe2425c00
[    4.794026] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    4.797383] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    4.800706] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.804002] usb usb1: Product: EHCI Host Controller
[    4.807291] usb usb1: Manufacturer: Linux 2.6.29.1 ehci_hcd
[    4.810621] usb usb1: SerialNumber: 0000:00:1a.7
[    4.814053] usb usb1: configuration #1 chosen from 1 choice
[    4.817553] hub 1-0:1.0: USB hub found
[    4.820960] hub 1-0:1.0: 4 ports detected
[    4.824628] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    4.828074] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    4.828076] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    4.831639] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
[    4.839080] ehci_hcd 0000:00:1d.7: debug port 1
[    4.842642] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    4.842652] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xe2425800
[    4.856026] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    4.859691] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    4.863298] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.866895] usb usb2: Product: EHCI Host Controller
[    4.870488] usb usb2: Manufacturer: Linux 2.6.29.1 ehci_hcd
[    4.874037] usb usb2: SerialNumber: 0000:00:1d.7
[    4.877667] usb usb2: configuration #1 chosen from 1 choice
[    4.881260] hub 2-0:1.0: USB hub found
[    4.884759] hub 2-0:1.0: 6 ports detected
[    4.888399] uhci_hcd: USB Universal Host Controller Interface driver
[    4.891922] uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    4.895400] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[    4.895403] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    4.898903] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[    4.902359] uhci_hcd 0000:00:1a.0: irq 16, io base 0x000040c0
[    4.905797] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    4.909229] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.912650] usb usb3: Product: UHCI Host Controller
[    4.916023] usb usb3: Manufacturer: Linux 2.6.29.1 uhci_hcd
[    4.919438] usb usb3: SerialNumber: 0000:00:1a.0
[    4.922849] usb usb3: configuration #1 chosen from 1 choice
[    4.926269] hub 3-0:1.0: USB hub found
[    4.929590] hub 3-0:1.0: 2 ports detected
[    4.932983] uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    4.936299] uhci_hcd 0000:00:1a.1: setting latency timer to 64
[    4.936302] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    4.939626] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
[    4.942912] uhci_hcd 0000:00:1a.1: irq 21, io base 0x000040a0
[    4.946130] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    4.949381] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.952633] usb usb4: Product: UHCI Host Controller
[    4.955899] usb usb4: Manufacturer: Linux 2.6.29.1 uhci_hcd
[    4.959175] usb usb4: SerialNumber: 0000:00:1a.1
[    4.962518] usb usb4: configuration #1 chosen from 1 choice
[    4.965828] hub 4-0:1.0: USB hub found
[    4.969044] hub 4-0:1.0: 2 ports detected
[    4.972368] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    4.975594] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    4.975597] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    4.978809] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
[    4.981999] uhci_hcd 0000:00:1d.0: irq 23, io base 0x00004080
[    4.985138] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    4.988294] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.991441] usb usb5: Product: UHCI Host Controller
[    4.994520] usb usb5: Manufacturer: Linux 2.6.29.1 uhci_hcd
[    4.997609] usb usb5: SerialNumber: 0000:00:1d.0
[    5.000788] usb usb5: configuration #1 chosen from 1 choice
[    5.003918] hub 5-0:1.0: USB hub found
[    5.006960] hub 5-0:1.0: 2 ports detected
[    5.010123] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    5.013224] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    5.013226] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    5.016323] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
[    5.019448] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00004060
[    5.022540] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    5.025620] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.028700] usb usb6: Product: UHCI Host Controller
[    5.031753] usb usb6: Manufacturer: Linux 2.6.29.1 uhci_hcd
[    5.034814] usb usb6: SerialNumber: 0000:00:1d.1
[    5.037947] usb usb6: configuration #1 chosen from 1 choice
[    5.041093] hub 6-0:1.0: USB hub found
[    5.044156] hub 6-0:1.0: 2 ports detected
[    5.047371] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    5.050497] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    5.050499] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    5.053626] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 7
[    5.056744] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00004040
[    5.059835] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    5.062948] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.066082] usb usb7: Product: UHCI Host Controller
[    5.069205] usb usb7: Manufacturer: Linux 2.6.29.1 uhci_hcd
[    5.072311] usb usb7: SerialNumber: 0000:00:1d.2
[    5.075463] usb usb7: configuration #1 chosen from 1 choice
[    5.078632] hub 7-0:1.0: USB hub found
[    5.081722] hub 7-0:1.0: 2 ports detected
[    5.084979] Initializing USB Mass Storage driver...
[    5.088129] usbcore: registered new interface driver usb-storage
[    5.091272] USB Mass Storage support registered.
[    5.094525] PNP: No PS/2 controller found. Probing ports directly.
[    5.100642] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.103743] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.106922] mice: PS/2 mouse device common for all mice
[    5.110168] input: PC Speaker as /devices/platform/pcspkr/input/input2
[    5.117142] coretemp coretemp.0: Using relative temperature scale!
[    5.120389] coretemp coretemp.1: Using relative temperature scale!
[    5.123643] coretemp coretemp.2: Using relative temperature scale!
[    5.126750] coretemp coretemp.3: Using relative temperature scale!
[    5.129854] md: raid1 personality registered for level 1
[    5.132865] cpuidle: using governor ladder
[    5.136648] usbcore: registered new interface driver hiddev
[    5.139718] usbcore: registered new interface driver usbhid
[    5.142683] usbhid: v2.6:USB HID core driver
[    5.145699] Advanced Linux Sound Architecture Driver Version 1.0.18a.
[    5.148930] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    5.152007] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    5.191663] ALSA device list:
[    5.194644]   #0: HDA Intel at 0xe2420000 irq 22
[    5.197631] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    5.201215] ip_tables: (C) 2000-2006 Netfilter Core Team
[    5.204226] TCP cubic registered
[    5.207224] NET: Registered protocol family 17
[    5.210398] RPC: Registered udp transport module.
[    5.213379] RPC: Registered tcp transport module.
[    5.361422] usb 5-1: new low speed USB device using uhci_hcd and address 2
[    5.520034] md: Waiting for all devices to be available before autodetect
[    5.523081] md: If you don't use raid, use raid=noautodetect
[    5.526229] md: Autodetecting RAID arrays.
[    5.593178] usb 5-1: New USB device found, idVendor=051d, idProduct=0002
[    5.596230] usb 5-1: New USB device strings: Mfr=3, Product=1, SerialNumber=2
[    5.599247] usb 5-1: Product: Back-UPS RS 1500 LCD FW:839.H7 .D USB FW:H7 
[    5.602263] usb 5-1: Manufacturer: American Power Conversion
[    5.605273] usb 5-1: SerialNumber: 8B0822R34475 
[    5.608256] md: Scanned 9 and added 9 devices.
[    5.608257] md: autorun ...
[    5.608258] md: considering sdd3 ...
[    5.608265] md:  adding sdd3 ...
[    5.608267] md: sdd2 has different UUID to sdd3
[    5.608269] md: sdd1 has different UUID to sdd3
[    5.608272] md:  adding sdc3 ...
[    5.608274] md: sdc2 has different UUID to sdd3
[    5.608276] md: sdc1 has different UUID to sdd3
[    5.608279] md:  adding sdb3 ...
[    5.608281] md: sdb2 has different UUID to sdd3
[    5.608282] md: sdb1 has different UUID to sdd3
[    5.608411] md: created md2
[    5.608412] md: bind<sdb3>
[    5.608420] md: bind<sdc3>
[    5.608426] md: bind<sdd3>
[    5.608431] md: running: <sdd3><sdc3><sdb3>
[    5.608516] raid1: raid set md2 active with 2 out of 2 mirrors
[    5.608586] md: considering sdd2 ...
[    5.608589] md:  adding sdd2 ...
[    5.608591] md: sdd1 has different UUID to sdd2
[    5.608594] md:  adding sdc2 ...
[    5.608595] md: sdc1 has different UUID to sdd2
[    5.608598] md:  adding sdb2 ...
[    5.608600] md: sdb1 has different UUID to sdd2
[    5.608733] md: created md1
[    5.608734] md: bind<sdb2>
[    5.608740] md: bind<sdc2>
[    5.608745] md: bind<sdd2>
[    5.608751] md: running: <sdd2><sdc2><sdb2>
[    5.608810] raid1: raid set md1 active with 2 out of 2 mirrors
[    5.608878] md: considering sdd1 ...
[    5.608881] md:  adding sdd1 ...
[    5.608883] md:  adding sdc1 ...
[    5.608886] md:  adding sdb1 ...
[    5.608897] md: created md0
[    5.608898] md: bind<sdb1>
[    5.608903] md: bind<sdc1>
[    5.608919] md: bind<sdd1>
[    5.608924] md: running: <sdd1><sdc1><sdb1>
[    5.608981] raid1: raid set md0 active with 2 out of 2 mirrors
[    5.609049] md: ... autorun DONE.
[    5.609129]  md2: unknown partition table
[    5.714304] usb 5-1: configuration #1 chosen from 1 choice
[    5.737157] UDF-fs: No VRS found
[    5.739541] Filesystem "md2": Disabling barriers, trial barrier write failed
[    5.741730] XFS: correcting sb_features alignment problem
[    5.743963] XFS mounting filesystem md2
[    5.912657] Ending clean XFS mount for filesystem: md2
[    5.912701] VFS: Mounted root (xfs filesystem) readonly on device 9:2.
[    5.914952] Freeing unused kernel memory: 344k freed
[    6.888351] generic-usb 0003:051D:0002.0001: hiddev96: USB HID v1.10 Device [American Power Conversion Back-UPS RS 1500 LCD FW:839.H7 .D USB FW:H7 ] on usb-0000:00:1d.0-1/input0
[    7.100031] usb 6-2: new full speed USB device using uhci_hcd and address 2
[    7.262694] usb 6-2: New USB device found, idVendor=413c, idProduct=1002
[    7.265380] usb 6-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.268137] usb 6-2: Product: Dell USB Keyboard Hub
[    7.271024] usb 6-2: Manufacturer: Dell
[    7.273773] usb 6-2: configuration #1 chosen from 1 choice
[    7.283706] hub 6-2:1.0: USB hub found
[    7.286683] hub 6-2:1.0: 3 ports detected
[    7.404211] udev: renamed network interface eth2_rename to eth0
[    7.418243] udev: renamed network interface eth0_rename to eth1
[    7.499169]  md0:<6> md1: unknown partition table
[    7.516762] 
[    7.577708] usb 6-2.1: new full speed USB device using uhci_hcd and address 3
[    7.708714] usb 6-2.1: New USB device found, idVendor=413c, idProduct=2002
[    7.711577] usb 6-2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.714384] usb 6-2.1: Product: Dell USB Keyboard Hub
[    7.717237] usb 6-2.1: Manufacturer: Dell
[    7.720149] usb 6-2.1: configuration #1 chosen from 1 choice
[    7.733035] input: Dell Dell USB Keyboard Hub as /devices/pci0000:00/0000:00:1d.1/usb6/6-2/6-2.1/6-2.1:1.0/input/input3
[    7.740032] generic-usb 0003:413C:2002.0002: input: USB HID v1.10 Keyboard [Dell Dell USB Keyboard Hub] on usb-0000:00:1d.1-2.1/input0
[    7.751779] input: Dell Dell USB Keyboard Hub as /devices/pci0000:00/0000:00:1d.1/usb6/6-2/6-2.1/6-2.1:1.1/input/input4
[    7.759032] generic-usb 0003:413C:2002.0003: input: USB HID v1.10 Device [Dell Dell USB Keyboard Hub] on usb-0000:00:1d.1-2.1/input1
[    7.830723] usb 6-2.2: new low speed USB device using uhci_hcd and address 4
[    7.955044] usb 6-2.2: New USB device found, idVendor=0461, idProduct=4d15
[    7.958664] usb 6-2.2: New USB device strings: Mfr=0, Product=2, SerialNumber=0
[    7.962222] usb 6-2.2: Product: USB Optical Mouse
[    7.965829] usb 6-2.2: configuration #1 chosen from 1 choice
[    7.983982] input: USB Optical Mouse as /devices/pci0000:00/0000:00:1d.1/usb6/6-2/6-2.2/6-2.2:1.0/input/input5
[    7.991064] generic-usb 0003:0461:4D15.0004: input: USB HID v1.11 Mouse [USB Optical Mouse] on usb-0000:00:1d.1-2.2/input0
[    8.314456] Adding 16787768k swap on /dev/md0.  Priority:-1 extents:1 across:16787768k 
[   10.668415] kjournald starting.  Commit interval 5 seconds
[   10.668481] EXT3 FS on md1, internal journal
[   10.668486] EXT3-fs: mounted filesystem with ordered data mode.
[   10.669215] XFS mounting filesystem sda1
[   10.791659] Ending clean XFS mount for filesystem: sda1
[   12.321702] e1000e 0000:00:19.0: irq 31 for MSI/MSI-X
[   12.372451] e1000e 0000:00:19.0: irq 31 for MSI/MSI-X
[   13.359410] e1000: eth1 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
[   13.598417] e1000: eth2 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
[   15.233543] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[63833.445389] e1000e: eth0 NIC Link is Down
[84362.237517] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[155710.511550] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0055): Battery charging started:.
[155711.691636] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0056): Battery charging completed:.
[166717.044303] irssi[2488] general protection ip:41e3fd sp:7fffefcb60e0 error:0 in irssi[400000+cb000]
[284425.420303] md: data-check of RAID array md0
[284425.420309] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[284425.420310] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
[284425.420317] md: using 128k window, over a total of 16787776 blocks.
[284426.384324] md: delaying data-check of md1 until md0 has finished (they share one or more physical units)
[284426.478895] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=1.
[284426.479286] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=0.
[284427.389645] md: delaying data-check of md2 until md1 has finished (they share one or more physical units)
[284802.553599] md: md0: data-check done.
[284802.592278] md: delaying data-check of md1 until md2 has finished (they share one or more physical units)
[284802.592285] md: data-check of RAID array md2
[284802.592290] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[284802.592292] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
[284802.592310] md: using 128k window, over a total of 129596288 blocks.
[288698.423223] md: md2: data-check done.
[288698.481470] md: data-check of RAID array md1
[288698.481476] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[288698.481477] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
[288698.481481] md: using 128k window, over a total of 136448 blocks.
[288701.813662] md: md1: data-check done.
[295333.073434] 3w-9xxx: scsi0: AEN: INFO (0x04:0x002B): Verify completed:unit=1.
[298923.418156] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=0.
[312046.222784] 3w-9xxx: scsi0: AEN: INFO (0x04:0x002B): Verify completed:unit=0.
[686428.473766] lftp[12786] general protection ip:445e32 sp:7fff17d06fd0 error:0 in lftp[400000+118000]
[760620.748114] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0055): Battery charging started:.
[760621.928206] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0056): Battery charging completed:.
[889226.150201] md: data-check of RAID array md0
[889226.150206] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[889226.150207] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
[889226.150211] md: using 128k window, over a total of 16787776 blocks.
[889227.245676] md: delaying data-check of md1 until md0 has finished (they share one or more physical units)
[889228.250639] md: delaying data-check of md2 until md1 has finished (they share one or more physical units)
[889274.717814] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=1.
[889274.718204] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=0.
[889601.073833] md: md0: data-check done.
[889601.119317] md: delaying data-check of md2 until md1 has finished (they share one or more physical units)
[889601.119322] md: delaying data-check of md1 until md2 has finished (they share one or more physical units)
[889601.119330] md: data-check of RAID array md2
[889601.119331] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[889601.119332] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
[889601.119337] md: using 128k window, over a total of 129596288 blocks.
[893519.207057] md: md2: data-check done.
[893519.272195] md: data-check of RAID array md1
[893519.272200] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[893519.272202] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for data-check.
[893519.272207] md: using 128k window, over a total of 136448 blocks.
[893522.242321] md: md1: data-check done.
[900172.860869] 3w-9xxx: scsi0: AEN: INFO (0x04:0x002B): Verify completed:unit=1.
[903771.441769] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0029): Verify started:unit=0.
[923136.283518] 3w-9xxx: scsi0: AEN: INFO (0x04:0x002B): Verify completed:unit=0.
[1204250.524219] nfsd: page allocation failure. order:0, mode:0x20
[1204250.524224] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.524226] Call Trace:
[1204250.524229]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.524239]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.524241]  [<ffffffff802a76db>] __kmalloc+0xdb/0xe0
[1204250.524245]  [<ffffffff8059a98d>] __alloc_skb+0x6d/0x150
[1204250.524247]  [<ffffffff8059b727>] __netdev_alloc_skb+0x17/0x40
[1204250.524251]  [<ffffffff804d8c8b>] e1000_alloc_rx_buffers+0x23b/0x2c0
[1204250.524253]  [<ffffffff804d8fbd>] e1000_clean_rx_irq+0x25d/0x3a0
[1204250.524255]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.524258]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.524261]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.524264]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.524266]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.524268]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.524270]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.524272]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.524278]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.524281]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.524284]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.524287]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.524289]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.524292]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.524296]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.524298]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.524300]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.524303]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.524305]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.524307]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.524309]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.524311]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.524315]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.524318]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.524320]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.524322]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.524323]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.524327]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.524329]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.524331]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.524333]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.524334] Mem-Info:
[1204250.524335] DMA per-cpu:
[1204250.524337] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.524339] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.524340] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.524341] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.524342] DMA32 per-cpu:
[1204250.524344] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.524345] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.524346] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.524348] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.524349] Normal per-cpu:
[1204250.524350] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.524351] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.524353] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.524354] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.524356] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.524357]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.524358]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.524361] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.524363] lowmem_reserve[]: 0 3246 7980 7980
[1204250.524367] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.524369] lowmem_reserve[]: 0 0 4734 4734
[1204250.524373] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.524376] lowmem_reserve[]: 0 0 0 0
[1204250.524376] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.524376] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.524376] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.524376] 990448 total pagecache pages
[1204250.524376] 2010 pages in swap cache
[1204250.524376] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.524376] Free swap  = 16758720kB
[1204250.524376] Total swap = 16787768kB
[1204250.524376] 2277376 pages RAM
[1204250.524376] 252195 pages reserved
[1204250.524376] 729608 pages shared
[1204250.524376] 1336908 pages non-shared
[1204250.562822] nfsd: page allocation failure. order:0, mode:0x20
[1204250.562826] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.562827] Call Trace:
[1204250.562829]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.562837]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.562839]  [<ffffffff802a76db>] __kmalloc+0xdb/0xe0
[1204250.562842]  [<ffffffff8059a98d>] __alloc_skb+0x6d/0x150
[1204250.562845]  [<ffffffff8059b727>] __netdev_alloc_skb+0x17/0x40
[1204250.562848]  [<ffffffff804d8c8b>] e1000_alloc_rx_buffers+0x23b/0x2c0
[1204250.562850]  [<ffffffff804d8fbd>] e1000_clean_rx_irq+0x25d/0x3a0
[1204250.562852]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.562854]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.562857]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.562860]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.562862]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.562864]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.562866]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.562867]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.562873]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.562875]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.562878]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.562880]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.562883]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.562885]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.562888]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.562890]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.562892]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.562894]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.562896]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.562898]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.562901]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.562903]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.562905]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.562908]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.562910]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.562912]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.562913]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.562916]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.562918]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.562920]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.562922]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.562923] Mem-Info:
[1204250.562924] DMA per-cpu:
[1204250.562926] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.562927] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.562929] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.562930] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.562931] DMA32 per-cpu:
[1204250.562932] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.562934] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.562935] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.562936] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.562937] Normal per-cpu:
[1204250.562939] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.562940] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.562941] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.562942] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.562945] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.562946]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.562946]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.562949] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.562951] lowmem_reserve[]: 0 3246 7980 7980
[1204250.562955] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.562958] lowmem_reserve[]: 0 0 4734 4734
[1204250.562962] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.562964] lowmem_reserve[]: 0 0 0 0
[1204250.562967] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.562973] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.562980] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.562986] 990448 total pagecache pages
[1204250.562987] 2010 pages in swap cache
[1204250.562989] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.562990] Free swap  = 16758720kB
[1204250.562991] Total swap = 16787768kB
[1204250.563738] 2277376 pages RAM
[1204250.563738] 252195 pages reserved
[1204250.563738] 729608 pages shared
[1204250.563738] 1336908 pages non-shared
[1204250.593581] nfsd: page allocation failure. order:0, mode:0x20
[1204250.593584] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.593586] Call Trace:
[1204250.593587]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.593595]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.593597]  [<ffffffff802a7085>] kmem_cache_alloc+0x95/0xa0
[1204250.593600]  [<ffffffff8059a969>] __alloc_skb+0x49/0x150
[1204250.593603]  [<ffffffff805dee06>] tcp_send_ack+0x26/0x120
[1204250.593605]  [<ffffffff805dc805>] tcp_rcv_established+0x3d5/0x920
[1204250.593607]  [<ffffffff805e417d>] tcp_v4_do_rcv+0xdd/0x210
[1204250.593609]  [<ffffffff805e4926>] tcp_v4_rcv+0x676/0x710
[1204250.593612]  [<ffffffff805c6a5c>] ip_local_deliver_finish+0x8c/0x160
[1204250.593615]  [<ffffffff805c6551>] ip_rcv_finish+0x191/0x330
[1204250.593617]  [<ffffffff805c6936>] ip_rcv+0x246/0x2e0
[1204250.593620]  [<ffffffff804d8e74>] e1000_clean_rx_irq+0x114/0x3a0
[1204250.593622]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.593624]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.593627]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.593630]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.593632]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.593633]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.593636]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.593637]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.593643]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.593645]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.593648]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.593650]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.593652]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.593655]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.593658]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.593660]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.593662]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.593664]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.593666]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.593668]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.593671]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.593673]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.593675]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.593678]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.593680]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.593682]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.593683]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.593686]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.593688]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.593690]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.593692]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.593693] Mem-Info:
[1204250.593694] DMA per-cpu:
[1204250.593696] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.593697] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.593699] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.593700] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.593701] DMA32 per-cpu:
[1204250.593702] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.593704] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.593705] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.593707] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.593708] Normal per-cpu:
[1204250.593709] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.593710] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.593711] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.593713] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.593715] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.593716]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.593717]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.593720] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.593722] lowmem_reserve[]: 0 3246 7980 7980
[1204250.593726] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.593728] lowmem_reserve[]: 0 0 4734 4734
[1204250.593732] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.593734] lowmem_reserve[]: 0 0 0 0
[1204250.593737] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.593743] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.593750] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.593756] 990448 total pagecache pages
[1204250.593758] 2010 pages in swap cache
[1204250.593759] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.593761] Free swap  = 16758720kB
[1204250.593762] Total swap = 16787768kB
[1204250.594510] 2277376 pages RAM
[1204250.594510] 252195 pages reserved
[1204250.594510] 729608 pages shared
[1204250.594510] 1336908 pages non-shared
[1204250.624335] nfsd: page allocation failure. order:0, mode:0x20
[1204250.624338] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.624339] Call Trace:
[1204250.624340]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.624348]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.624350]  [<ffffffff802a7085>] kmem_cache_alloc+0x95/0xa0
[1204250.624353]  [<ffffffff8059a969>] __alloc_skb+0x49/0x150
[1204250.624356]  [<ffffffff805dee06>] tcp_send_ack+0x26/0x120
[1204250.624358]  [<ffffffff805dcbd2>] tcp_rcv_established+0x7a2/0x920
[1204250.624360]  [<ffffffff805e417d>] tcp_v4_do_rcv+0xdd/0x210
[1204250.624362]  [<ffffffff805e4926>] tcp_v4_rcv+0x676/0x710
[1204250.624365]  [<ffffffff805c6a5c>] ip_local_deliver_finish+0x8c/0x160
[1204250.624367]  [<ffffffff805c6551>] ip_rcv_finish+0x191/0x330
[1204250.624369]  [<ffffffff805c6936>] ip_rcv+0x246/0x2e0
[1204250.624372]  [<ffffffff804d8e74>] e1000_clean_rx_irq+0x114/0x3a0
[1204250.624374]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.624377]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.624380]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.624382]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.624384]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.624386]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.624389]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.624390]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.624395]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.624397]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.624400]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.624403]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.624405]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.624407]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.624410]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.624412]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.624414]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.624417]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.624419]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.624421]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.624423]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.624425]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.624428]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.624430]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.624433]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.624434]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.624436]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.624439]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.624441]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.624443]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.624444]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.624446] Mem-Info:
[1204250.624447] DMA per-cpu:
[1204250.624449] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.624450] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.624451] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.624453] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.624454] DMA32 per-cpu:
[1204250.624455] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.624456] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.624458] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.624459] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.624460] Normal per-cpu:
[1204250.624461] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.624463] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.624464] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.624465] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.624468] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.624468]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.624469]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.624472] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.624474] lowmem_reserve[]: 0 3246 7980 7980
[1204250.624478] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.624481] lowmem_reserve[]: 0 0 4734 4734
[1204250.624485] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.624487] lowmem_reserve[]: 0 0 0 0
[1204250.624490] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.624496] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.624503] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.624509] 990448 total pagecache pages
[1204250.624510] 2010 pages in swap cache
[1204250.624512] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.624513] Free swap  = 16758720kB
[1204250.624514] Total swap = 16787768kB
[1204250.625311] 2277376 pages RAM
[1204250.625311] 252195 pages reserved
[1204250.625311] 729608 pages shared
[1204250.625311] 1336908 pages non-shared
[1204250.655071] nfsd: page allocation failure. order:0, mode:0x20
[1204250.655074] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.655075] Call Trace:
[1204250.655077]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.655084]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.655086]  [<ffffffff802a7085>] kmem_cache_alloc+0x95/0xa0
[1204250.655089]  [<ffffffff8059a969>] __alloc_skb+0x49/0x150
[1204250.655092]  [<ffffffff805dee06>] tcp_send_ack+0x26/0x120
[1204250.655094]  [<ffffffff805dc805>] tcp_rcv_established+0x3d5/0x920
[1204250.655097]  [<ffffffff805e417d>] tcp_v4_do_rcv+0xdd/0x210
[1204250.655099]  [<ffffffff805e4926>] tcp_v4_rcv+0x676/0x710
[1204250.655101]  [<ffffffff805c6a5c>] ip_local_deliver_finish+0x8c/0x160
[1204250.655104]  [<ffffffff805c6551>] ip_rcv_finish+0x191/0x330
[1204250.655106]  [<ffffffff805c6936>] ip_rcv+0x246/0x2e0
[1204250.655109]  [<ffffffff804d8e74>] e1000_clean_rx_irq+0x114/0x3a0
[1204250.655111]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.655113]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.655116]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.655119]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.655121]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.655122]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.655125]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.655126]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.655131]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.655134]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.655136]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.655139]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.655141]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.655143]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.655146]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.655148]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.655150]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.655153]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.655155]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.655157]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.655159]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.655161]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.655164]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.655166]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.655168]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.655170]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.655172]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.655175]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.655176]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.655179]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.655180]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.655182] Mem-Info:
[1204250.655183] DMA per-cpu:
[1204250.655184] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.655186] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.655187] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.655188] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.655189] DMA32 per-cpu:
[1204250.655190] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.655192] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.655193] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.655194] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.655195] Normal per-cpu:
[1204250.655197] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.655198] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.655199] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.655201] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.655203] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.655204]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.655205]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.655208] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.655210] lowmem_reserve[]: 0 3246 7980 7980
[1204250.655214] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.655216] lowmem_reserve[]: 0 0 4734 4734
[1204250.655220] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.655223] lowmem_reserve[]: 0 0 0 0
[1204250.655225] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.655232] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.655238] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.655245] 990448 total pagecache pages
[1204250.655246] 2010 pages in swap cache
[1204250.655247] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.655249] Free swap  = 16758720kB
[1204250.655250] Total swap = 16787768kB
[1204250.656044] 2277376 pages RAM
[1204250.656044] 252195 pages reserved
[1204250.656044] 729608 pages shared
[1204250.656044] 1336908 pages non-shared
[1204250.685806] nfsd: page allocation failure. order:0, mode:0x20
[1204250.685809] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.685810] Call Trace:
[1204250.685812]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.685819]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.685821]  [<ffffffff802a7085>] kmem_cache_alloc+0x95/0xa0
[1204250.685824]  [<ffffffff8059a969>] __alloc_skb+0x49/0x150
[1204250.685827]  [<ffffffff805dee06>] tcp_send_ack+0x26/0x120
[1204250.685829]  [<ffffffff805dcbd2>] tcp_rcv_established+0x7a2/0x920
[1204250.685831]  [<ffffffff805e417d>] tcp_v4_do_rcv+0xdd/0x210
[1204250.685833]  [<ffffffff805e4926>] tcp_v4_rcv+0x676/0x710
[1204250.685836]  [<ffffffff805c6a5c>] ip_local_deliver_finish+0x8c/0x160
[1204250.685838]  [<ffffffff805c6551>] ip_rcv_finish+0x191/0x330
[1204250.685840]  [<ffffffff805c6936>] ip_rcv+0x246/0x2e0
[1204250.685843]  [<ffffffff804d8e74>] e1000_clean_rx_irq+0x114/0x3a0
[1204250.685845]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.685848]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.685851]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.685853]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.685855]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.685857]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.685859]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.685861]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.685866]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.685868]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.685871]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.685873]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.685876]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.685878]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.685881]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.685883]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.685885]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.685887]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.685890]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.685891]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.685894]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.685896]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.685899]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.685901]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.685903]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.685905]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.685907]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.685909]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.685911]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.685913]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.685915]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.685916] Mem-Info:
[1204250.685918] DMA per-cpu:
[1204250.685919] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.685921] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.685922] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.685923] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.685924] DMA32 per-cpu:
[1204250.685925] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.685927] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.685928] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.685929] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.685930] Normal per-cpu:
[1204250.685932] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.685933] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.685934] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.685936] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.685938] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.685939]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.685940]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.685942] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.685945] lowmem_reserve[]: 0 3246 7980 7980
[1204250.685949] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.685951] lowmem_reserve[]: 0 0 4734 4734
[1204250.685955] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.685957] lowmem_reserve[]: 0 0 0 0
[1204250.685960] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.685966] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.685973] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.685979] 990448 total pagecache pages
[1204250.685981] 2010 pages in swap cache
[1204250.685982] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.685984] Free swap  = 16758720kB
[1204250.685985] Total swap = 16787768kB
[1204250.686783] 2277376 pages RAM
[1204250.686783] 252195 pages reserved
[1204250.686783] 729608 pages shared
[1204250.686783] 1336908 pages non-shared
[1204250.716543] nfsd: page allocation failure. order:0, mode:0x20
[1204250.716546] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.716547] Call Trace:
[1204250.716549]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.716557]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.716559]  [<ffffffff802a7085>] kmem_cache_alloc+0x95/0xa0
[1204250.716562]  [<ffffffff8059a969>] __alloc_skb+0x49/0x150
[1204250.716564]  [<ffffffff805dee06>] tcp_send_ack+0x26/0x120
[1204250.716567]  [<ffffffff805dcbd2>] tcp_rcv_established+0x7a2/0x920
[1204250.716569]  [<ffffffff805e417d>] tcp_v4_do_rcv+0xdd/0x210
[1204250.716571]  [<ffffffff805e4926>] tcp_v4_rcv+0x676/0x710
[1204250.716574]  [<ffffffff805c6a5c>] ip_local_deliver_finish+0x8c/0x160
[1204250.716576]  [<ffffffff805c6551>] ip_rcv_finish+0x191/0x330
[1204250.716578]  [<ffffffff805c6936>] ip_rcv+0x246/0x2e0
[1204250.716581]  [<ffffffff804d8e74>] e1000_clean_rx_irq+0x114/0x3a0
[1204250.716583]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.716586]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.716588]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.716591]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.716593]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.716595]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.716597]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.716598]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.716604]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.716606]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.716609]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.716611]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.716614]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.716616]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.716619]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.716621]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.716623]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.716626]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.716628]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.716630]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.716632]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.716634]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.716637]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.716639]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.716641]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.716643]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.716645]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.716648]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.716650]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.716652]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.716654]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.716655] Mem-Info:
[1204250.716656] DMA per-cpu:
[1204250.716658] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.716659] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.716660] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.716662] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.716663] DMA32 per-cpu:
[1204250.716664] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.716665] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.716667] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.716668] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.716669] Normal per-cpu:
[1204250.716670] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.716672] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.716673] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.716674] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.716677] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.716677]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.716678]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.716681] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.716683] lowmem_reserve[]: 0 3246 7980 7980
[1204250.716687] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.716690] lowmem_reserve[]: 0 0 4734 4734
[1204250.716693] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.716696] lowmem_reserve[]: 0 0 0 0
[1204250.716698] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.716705] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.716712] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.716718] 990448 total pagecache pages
[1204250.716719] 2010 pages in swap cache
[1204250.716721] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.716722] Free swap  = 16758720kB
[1204250.716723] Total swap = 16787768kB
[1204250.717519] 2277376 pages RAM
[1204250.717519] 252195 pages reserved
[1204250.717519] 729608 pages shared
[1204250.717519] 1336908 pages non-shared
[1204250.747266] nfsd: page allocation failure. order:0, mode:0x20
[1204250.747269] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.747270] Call Trace:
[1204250.747271]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.747278]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.747281]  [<ffffffff802a7085>] kmem_cache_alloc+0x95/0xa0
[1204250.747284]  [<ffffffff8059a969>] __alloc_skb+0x49/0x150
[1204250.747286]  [<ffffffff8059b727>] __netdev_alloc_skb+0x17/0x40
[1204250.747289]  [<ffffffff804d8c8b>] e1000_alloc_rx_buffers+0x23b/0x2c0
[1204250.747291]  [<ffffffff804d8fbd>] e1000_clean_rx_irq+0x25d/0x3a0
[1204250.747293]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.747296]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.747298]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.747301]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.747303]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.747305]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.747307]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.747308]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.747314]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.747316]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.747319]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.747321]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.747323]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.747326]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.747329]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.747331]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.747333]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.747336]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.747338]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.747340]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.747342]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.747344]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.747347]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.747349]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.747351]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.747353]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.747355]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.747358]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.747360]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.747362]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.747363]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.747365] Mem-Info:
[1204250.747366] DMA per-cpu:
[1204250.747367] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.747369] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.747370] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.747371] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.747372] DMA32 per-cpu:
[1204250.747374] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.747375] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.747376] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.747377] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.747379] Normal per-cpu:
[1204250.747380] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.747381] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.747382] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.747384] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.747386] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.747387]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.747388]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.747390] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.747393] lowmem_reserve[]: 0 3246 7980 7980
[1204250.747397] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.747399] lowmem_reserve[]: 0 0 4734 4734
[1204250.747403] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.747405] lowmem_reserve[]: 0 0 0 0
[1204250.747408] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.747414] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.747421] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.747427] 990448 total pagecache pages
[1204250.747428] 2010 pages in swap cache
[1204250.747430] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.747431] Free swap  = 16758720kB
[1204250.747432] Total swap = 16787768kB
[1204250.748256] 2277376 pages RAM
[1204250.748256] 252195 pages reserved
[1204250.748256] 729608 pages shared
[1204250.748256] 1336908 pages non-shared
[1204250.777983] nfsd: page allocation failure. order:0, mode:0x20
[1204250.777986] Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
[1204250.777988] Call Trace:
[1204250.777989]  <IRQ>  [<ffffffff802850fd>] __alloc_pages_internal+0x3dd/0x4e0
[1204250.777997]  [<ffffffff802a738b>] cache_alloc_refill+0x2fb/0x570
[1204250.777999]  [<ffffffff802a7085>] kmem_cache_alloc+0x95/0xa0
[1204250.778002]  [<ffffffff8059a969>] __alloc_skb+0x49/0x150
[1204250.778005]  [<ffffffff805dee06>] tcp_send_ack+0x26/0x120
[1204250.778007]  [<ffffffff805dc805>] tcp_rcv_established+0x3d5/0x920
[1204250.778010]  [<ffffffff805e417d>] tcp_v4_do_rcv+0xdd/0x210
[1204250.778012]  [<ffffffff805e4926>] tcp_v4_rcv+0x676/0x710
[1204250.778015]  [<ffffffff805c6a5c>] ip_local_deliver_finish+0x8c/0x160
[1204250.778017]  [<ffffffff805c6551>] ip_rcv_finish+0x191/0x330
[1204250.778019]  [<ffffffff805c6936>] ip_rcv+0x246/0x2e0
[1204250.778022]  [<ffffffff804d8e74>] e1000_clean_rx_irq+0x114/0x3a0
[1204250.778024]  [<ffffffff804dad70>] e1000_clean+0x180/0x2d0
[1204250.778027]  [<ffffffff8059f5a7>] net_rx_action+0x87/0x130
[1204250.778029]  [<ffffffff80259cd3>] __do_softirq+0x93/0x160
[1204250.778032]  [<ffffffff8022c9fc>] call_softirq+0x1c/0x30
[1204250.778034]  [<ffffffff8022e455>] do_softirq+0x35/0x80
[1204250.778036]  [<ffffffff8022e523>] do_IRQ+0x83/0x110
[1204250.778038]  [<ffffffff8022c2d3>] ret_from_intr+0x0/0xa
[1204250.778039]  <EOI>  [<ffffffff8063218c>] _spin_lock+0xc/0x20
[1204250.778045]  [<ffffffff802bb2fc>] d_find_alias+0x1c/0x40
[1204250.778047]  [<ffffffff802bd96d>] d_obtain_alias+0x4d/0x140
[1204250.778050]  [<ffffffff8033ffd3>] exportfs_decode_fh+0x63/0x2a0
[1204250.778052]  [<ffffffff80343970>] nfsd_acceptable+0x0/0x110
[1204250.778054]  [<ffffffff8061e74a>] cache_check+0x4a/0x4d0
[1204250.778057]  [<ffffffff80349437>] exp_find_key+0x57/0xe0
[1204250.778060]  [<ffffffff80592a35>] sock_recvmsg+0xd5/0x110
[1204250.778062]  [<ffffffff80349552>] exp_find+0x92/0xa0
[1204250.778064]  [<ffffffff80343e59>] fh_verify+0x369/0x680
[1204250.778066]  [<ffffffff8024a0ff>] activate_task+0x2f/0x50
[1204250.778068]  [<ffffffff803460be>] nfsd_open+0x2e/0x180
[1204250.778070]  [<ffffffff80346574>] nfsd_write+0xc4/0x120
[1204250.778073]  [<ffffffff8034dac0>] nfsd3_proc_write+0xb0/0x150
[1204250.778075]  [<ffffffff8034040a>] nfsd_dispatch+0xba/0x270
[1204250.778077]  [<ffffffff80615a1e>] svc_process+0x49e/0x800
[1204250.778080]  [<ffffffff8024dc80>] default_wake_function+0x0/0x10
[1204250.778082]  [<ffffffff80631fd7>] __down_read+0x17/0xae
[1204250.778084]  [<ffffffff80340b79>] nfsd+0x199/0x2b0
[1204250.778085]  [<ffffffff803409e0>] nfsd+0x0/0x2b0
[1204250.778088]  [<ffffffff802691d7>] kthread+0x47/0x90
[1204250.778090]  [<ffffffff8022c8fa>] child_rip+0xa/0x20
[1204250.778092]  [<ffffffff80269190>] kthread+0x0/0x90
[1204250.778094]  [<ffffffff8022c8f0>] child_rip+0x0/0x20
[1204250.778095] Mem-Info:
[1204250.778097] DMA per-cpu:
[1204250.778098] CPU    0: hi:    0, btch:   1 usd:   0
[1204250.778099] CPU    1: hi:    0, btch:   1 usd:   0
[1204250.778101] CPU    2: hi:    0, btch:   1 usd:   0
[1204250.778102] CPU    3: hi:    0, btch:   1 usd:   0
[1204250.778103] DMA32 per-cpu:
[1204250.778104] CPU    0: hi:  186, btch:  31 usd: 185
[1204250.778106] CPU    1: hi:  186, btch:  31 usd: 167
[1204250.778107] CPU    2: hi:  186, btch:  31 usd: 171
[1204250.778108] CPU    3: hi:  186, btch:  31 usd: 199
[1204250.778109] Normal per-cpu:
[1204250.778110] CPU    0: hi:  186, btch:  31 usd: 175
[1204250.778112] CPU    1: hi:  186, btch:  31 usd: 168
[1204250.778113] CPU    2: hi:  186, btch:  31 usd: 176
[1204250.778114] CPU    3: hi:  186, btch:  31 usd:  30
[1204250.778117] Active_anon:147630 active_file:127260 inactive_anon:33780
[1204250.778118]  inactive_file:861288 unevictable:0 dirty:65947 writeback:0 unstable:0
[1204250.778118]  free:8188 slab:804810 mapped:9548 pagetables:5921 bounce:0
[1204250.778121] DMA free:9736kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8744kB pages_scanned:0 all_unreclaimable? yes
[1204250.778123] lowmem_reserve[]: 0 3246 7980 7980
[1204250.778127] DMA32 free:20612kB min:4648kB low:5808kB high:6972kB active_anon:134148kB inactive_anon:46156kB active_file:182224kB inactive_file:1447292kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[1204250.778130] lowmem_reserve[]: 0 0 4734 4734
[1204250.778134] Normal free:2404kB min:6776kB low:8468kB high:10164kB active_anon:456372kB inactive_anon:88964kB active_file:326816kB inactive_file:1997860kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[1204250.778136] lowmem_reserve[]: 0 0 0 0
[1204250.778139] DMA: 4*4kB 5*8kB 3*16kB 3*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9736kB
[1204250.778145] DMA32: 3134*4kB 3*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 20704kB
[1204250.778152] Normal: 1*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 2620kB
[1204250.778158] 990448 total pagecache pages
[1204250.778159] 2010 pages in swap cache
[1204250.778161] Swap cache stats: add 44114, delete 42104, find 47144/49423
[1204250.778162] Free swap  = 16758720kB
[1204250.778163] Total swap = 16787768kB
[1204250.778958] 2277376 pages RAM
[1204250.778958] 252195 pages reserved
[1204250.778958] 729608 pages shared
[1204250.778958] 1336908 pages non-shared

Any hints?
