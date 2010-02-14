From: Jesper Krogh <jesper@krogh.cc>
Subject: ixgbe_clean_tx_irq: tx hang 1 detected, resetting adapter (2.6.32.8)
Date: Sun, 14 Feb 2010 17:29:37 +0100
Message-ID: <4B7824F1.6000202@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi List.

I have tried to get a dual bond of 2 x 10G NICs using the
Intel Corporation 82598EB 10-Gigabit AT2 Server Adapter (rev 01)
going. As first it looked like it "just worked" but when tried to fill
the links with data one of the NIC's (eth7) hang and did a reset of
itself, so all data was pushed through the other NIC in the bond (eth8)

Full dmesg below, but I think the important part is this:

[ 2162.745354] ixgbe: eth7: ixgbe_check_tx_hang: Detected Tx Unit Hang
[ 2162.745356]   Tx Queue             <4>
[ 2162.745356]   TDH, TDT             <e1>, <cc>
[ 2162.745357]   next_to_use          <cc>
[ 2162.745358]   next_to_clean        <e1>
[ 2162.745359] tx_buffer_info[next_to_clean]
[ 2162.745359]   time_stamp           <1000713d3>
[ 2162.745360]   jiffies              <10007152e>
[ 2163.162478] ixgbe: eth7: ixgbe_clean_tx_irq: tx hang 1 detected,
resetting adapter
[ 2163.357333] bonding: bond0: link status definitely down for interface
eth7, disabling it
[ 2168.670342] ixgbe: eth7 NIC Link is Up 10 Gbps, Flow Control: None


Full dmesg:

[    0.000000] Linux version 2.6.32.8 (jk@ko) (gcc version 4.2.4 (Ubuntu
4.2.4-1ubuntu4)) #3 SMP Thu Feb 11 19:27:44 CET 2010
[    0.000000] Command line:
root=UUID=52012ca3-9b77-4a86-a1cf-9bbed1bbf53f ro console=ttyS0,9600
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009bc00 (usable)
[    0.000000]  BIOS-e820: 000000000009bc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000dfff0000 (usable)
[    0.000000]  BIOS-e820: 00000000dfff0000 - 00000000dfffe000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000dfffe000 - 00000000e0000000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff700000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000002000000000 (usable)
[    0.000000] DMI 2.3 present.
[    0.000000] AMI BIOS detected: BIOS may corrupt low RAM, working
around it.
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000
(usable) ==> (reserved)
[    0.000000] last_pfn = 0x2000000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0000000000 mask E000000000 write-back
[    0.000000]   1 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] TOM2: 0000002000000000 aka 131072M
[    0.000000] e820 update range: 00000000e0000000 - 0000000100000000
(usable) ==> (reserved)
[    0.000000] last_pfn = 0xdfff0 max_arch_pfn = 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] init_memory_mapping: 0000000000000000-00000000dfff0000
[    0.000000]  0000000000 - 00dfe00000 page 2M
[    0.000000]  00dfe00000 - 00dfff0000 page 4k
[    0.000000] kernel direct mapping tables up to dfff0000 @ 10000-16000
[    0.000000] init_memory_mapping: 0000000100000000-0000002000000000
[    0.000000]  0100000000 - 2000000000 page 2M
[    0.000000] kernel direct mapping tables up to 2000000000 @ 14000-95000
[    0.000000] RAMDISK: 3787b000 - 37fef291
[    0.000000] ACPI: RSDP 00000000000f92d0 00024 (v02 SUN   )
[    0.000000] ACPI: XSDT 00000000dfff0100 0006C (v01 SUN    X4600 M2
00000050 MSFT 00000097)
[    0.000000] ACPI: FACP 00000000dfff0290 000F4 (v03 SUN    X4600 M2
00000050 MSFT 00000097)
[    0.000000] ACPI: DSDT 00000000dfff04d0 07176 (v01 SUN    X4600 M2
00000050 INTL 20050624)
[    0.000000] ACPI: FACS 00000000dfffe000 00040
[    0.000000] ACPI: APIC 00000000dfff0390 000E6 (v01 SUN    X4600 M2
00000050 MSFT 00000097)
[    0.000000] ACPI: SPCR 00000000dfff0480 00050 (v01 SUN    X4600 M2
00000050 MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000dfffe040 00063 (v01 SUN    X4600 M2
00000050 MSFT 00000097)
[    0.000000] ACPI: SRAT 00000000dfff7650 002C0 (v01 SUN    X4600 M2
00000050 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000dfff7910 00038 (v01 SUN    OEMHPET0
00000050 MSFT 00000097)
[    0.000000] ACPI: IPET 00000000dfff7950 00038 (v01 SUN    OEMHPET1
00000050 MSFT 00000097)
[    0.000000] ACPI: SRAT 00000000dfff7990 002C0 (v01 AMD    HAMMER
00000001 AMD  00000001)
[    0.000000] ACPI: SSDT 00000000dfff7c50 01384 (v01 A M I  POWERNOW
00000001 AMD  00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] SRAT: PXM 0 -> APIC 0 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 1 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 2 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 3 -> Node 1
[    0.000000] SRAT: PXM 2 -> APIC 4 -> Node 2
[    0.000000] SRAT: PXM 2 -> APIC 5 -> Node 2
[    0.000000] SRAT: PXM 3 -> APIC 6 -> Node 3
[    0.000000] SRAT: PXM 3 -> APIC 7 -> Node 3
[    0.000000] SRAT: PXM 4 -> APIC 8 -> Node 4
[    0.000000] SRAT: PXM 4 -> APIC 9 -> Node 4
[    0.000000] SRAT: PXM 5 -> APIC 10 -> Node 5
[    0.000000] SRAT: PXM 5 -> APIC 11 -> Node 5
[    0.000000] SRAT: PXM 6 -> APIC 12 -> Node 6
[    0.000000] SRAT: PXM 6 -> APIC 13 -> Node 6
[    0.000000] SRAT: PXM 7 -> APIC 14 -> Node 7
[    0.000000] SRAT: PXM 7 -> APIC 15 -> Node 7
[    0.000000] SRAT: Node 0 PXM 0 100000-e0000000
[    0.000000] SRAT: Node 1 PXM 1 500000000-a00000000
[    0.000000] SRAT: Node 2 PXM 2 a00000000-f00000000
[    0.000000] SRAT: Node 3 PXM 3 f00000000-1400000000
[    0.000000] SRAT: Node 4 PXM 4 1400000000-1700000000
[    0.000000] SRAT: Node 5 PXM 5 1700000000-1a00000000
[    0.000000] SRAT: Node 6 PXM 6 1a00000000-1d00000000
[    0.000000] SRAT: Node 7 PXM 7 1d00000000-2000000000
[    0.000000] SRAT: Node 0 PXM 0 100000000-500000000
[    0.000000] SRAT: Node 0 PXM 0 0-9bc00
[    0.000000] SRAT: PXMs only cover 114174MB of your 130559MB e820 RAM.
Not used.
[    0.000000] SRAT: SRAT not used.
[    0.000000] Scanning NUMA topology in Northbridge 24
[    0.000000] Number of nodes 8
[    0.000000] Node 0 MemBase 0000000000000000 Limit 0000000500000000
[    0.000000] Node 1 MemBase 0000000500000000 Limit 0000000a00000000
[    0.000000] Node 2 MemBase 0000000a00000000 Limit 0000000f00000000
[    0.000000] Node 3 MemBase 0000000f00000000 Limit 0000001400000000
[    0.000000] Node 4 MemBase 0000001400000000 Limit 0000001700000000
[    0.000000] Node 5 MemBase 0000001700000000 Limit 0000001a00000000
[    0.000000] Node 6 MemBase 0000001a00000000 Limit 0000001d00000000
[    0.000000] Node 7 MemBase 0000001d00000000 Limit 0000002000000000
[    0.000000] NUMA: Using 32 for the hash shift.
[    0.000000] Using node hash shift of 32
[    0.000000] found SMP MP-table at [ffff8800000ff780] ff780
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Bootmem setup node 0 0000000000000000-0000000500000000
[    0.000000]   NODE_DATA [0000000000090000 - 0000000000094fff]
[    0.000000]   bootmap [0000000000100000 -  000000000019ffff] pages a0
[    0.000000] (8 early reservations) ==> bootmem [0000000000 - 0500000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==>
[0000000000 - 0000001000]
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==>
[0000006000 - 0000008000]
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS ==>
[0001000000 - 000164ec44]
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK ==>
[003787b000 - 0037fef291]
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved ==>
[000009bc00 - 0000100000]
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK ==>
[000164f000 - 000164f2bc]
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE ==>
[0000010000 - 0000014000]
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE ==>
[0000014000 - 0000090000]
[    0.000000] Bootmem setup node 1 0000000500000000-0000000a00000000
[    0.000000]   NODE_DATA [0000000500000000 - 0000000500004fff]
[    0.000000]   bootmap [0000000500005000 -  00000005000a4fff] pages a0
[    0.000000] (8 early reservations) ==> bootmem [0500000000 - 0a00000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE
[    0.000000] Bootmem setup node 2 0000000a00000000-0000000f00000000
[    0.000000]   NODE_DATA [0000000a00000000 - 0000000a00004fff]
[    0.000000]   bootmap [0000000a00005000 -  0000000a000a4fff] pages a0
[    0.000000] (8 early reservations) ==> bootmem [0a00000000 - 0f00000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE
[    0.000000] Bootmem setup node 3 0000000f00000000-0000001400000000
[    0.000000]   NODE_DATA [0000000f00000000 - 0000000f00004fff]
[    0.000000]   bootmap [0000000f00005000 -  0000000f000a4fff] pages a0
[    0.000000] (8 early reservations) ==> bootmem [0f00000000 - 1400000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE
[    0.000000] Bootmem setup node 4 0000001400000000-0000001700000000
[    0.000000]   NODE_DATA [0000001400000000 - 0000001400004fff]
[    0.000000]   bootmap [0000001400005000 -  0000001400064fff] pages 60
[    0.000000] (8 early reservations) ==> bootmem [1400000000 - 1700000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE
[    0.000000] Bootmem setup node 5 0000001700000000-0000001a00000000
[    0.000000]   NODE_DATA [0000001700000000 - 0000001700004fff]
[    0.000000]   bootmap [0000001700005000 -  0000001700064fff] pages 60
[    0.000000] (8 early reservations) ==> bootmem [1700000000 - 1a00000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE
[    0.000000] Bootmem setup node 6 0000001a00000000-0000001d00000000
[    0.000000]   NODE_DATA [0000001a00000000 - 0000001a00004fff]
[    0.000000]   bootmap [0000001a00005000 -  0000001a00064fff] pages 60
[    0.000000] (8 early reservations) ==> bootmem [1a00000000 - 1d00000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE
[    0.000000] Bootmem setup node 7 0000001d00000000-0000002000000000
[    0.000000]   NODE_DATA [0000001d00000000 - 0000001d00004fff]
[    0.000000]   bootmap [0000001d00005000 -  0000001d00064fff] pages 60
[    0.000000] (8 early reservations) ==> bootmem [1d00000000 - 2000000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE
[    0.000000]   #2 [0001000000 - 000164ec44]    TEXT DATA BSS
[    0.000000]   #3 [003787b000 - 0037fef291]          RAMDISK
[    0.000000]   #4 [000009bc00 - 0000100000]    BIOS reserved
[    0.000000]   #5 [000164f000 - 000164f2bc]              BRK
[    0.000000]   #6 [0000010000 - 0000014000]          PGTABLE
[    0.000000]   #7 [0000014000 - 0000090000]          PGTABLE
[    0.000000] found SMP MP-table at [ffff8800000ff780] ff780
[    0.000000]  [ffffea0000000000-ffffea000f7fffff] PMD ->
[ffff880028600000-ffff8800377fffff] on node 0
[    0.000000]  [ffffea000f800000-ffffea00117fffff] PMD ->
[ffff880038000000-ffff880039ffffff] on node 0
[    0.000000]  [ffffea0011800000-ffffea0022ffffff] PMD ->
[ffff880500200000-ffff8805119fffff] on node 1
[    0.000000]  [ffffea0023000000-ffffea00347fffff] PMD ->
[ffff880a00200000-ffff880a119fffff] on node 2
[    0.000000]  [ffffea0034800000-ffffea003fffffff] PMD ->
[ffff880f00200000-ffff880f0b9fffff] on node 3
[    0.000000]  [ffffea0040000000-ffffea0045ffffff] PMD ->
[ffff880f0bc00000-ffff880f11bfffff] on node 3
[    0.000000]  [ffffea0046000000-ffffea00507fffff] PMD ->
[ffff881400200000-ffff88140a9fffff] on node 4
[    0.000000]  [ffffea0050800000-ffffea005affffff] PMD ->
[ffff881700200000-ffff88170a9fffff] on node 5
[    0.000000]  [ffffea005b000000-ffffea00657fffff] PMD ->
[ffff881a00200000-ffff881a0a9fffff] on node 6
[    0.000000]  [ffffea0065800000-ffffea006fffffff] PMD ->
[ffff881d00200000-ffff881d0a9fffff] on node 7
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x02000000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[10] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009b
[    0.000000]     0: 0x00000100 -> 0x000dfff0
[    0.000000]     0: 0x00100000 -> 0x00500000
[    0.000000]     1: 0x00500000 -> 0x00a00000
[    0.000000]     2: 0x00a00000 -> 0x00f00000
[    0.000000]     3: 0x00f00000 -> 0x01400000
[    0.000000]     4: 0x01400000 -> 0x01700000
[    0.000000]     5: 0x01700000 -> 0x01a00000
[    0.000000]     6: 0x01a00000 -> 0x01d00000
[    0.000000]     7: 0x01d00000 -> 0x02000000
[    0.000000] On node 0 totalpages: 5111675
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 231 pages reserved
[    0.000000]   DMA zone: 3692 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 899112 pages, LIFO batch:31
[    0.000000]   Normal zone: 57344 pages used for memmap
[    0.000000]   Normal zone: 4136960 pages, LIFO batch:31
[    0.000000] On node 1 totalpages: 5242880
[    0.000000]   Normal zone: 71680 pages used for memmap
[    0.000000]   Normal zone: 5171200 pages, LIFO batch:31
[    0.000000] On node 2 totalpages: 5242880
[    0.000000]   Normal zone: 71680 pages used for memmap
[    0.000000]   Normal zone: 5171200 pages, LIFO batch:31
[    0.000000] On node 3 totalpages: 5242880
[    0.000000]   Normal zone: 71680 pages used for memmap
[    0.000000]   Normal zone: 5171200 pages, LIFO batch:31
[    0.000000] On node 4 totalpages: 3145728
[    0.000000]   Normal zone: 43008 pages used for memmap
[    0.000000]   Normal zone: 3102720 pages, LIFO batch:31
[    0.000000] On node 5 totalpages: 3145728
[    0.000000]   Normal zone: 43008 pages used for memmap
[    0.000000]   Normal zone: 3102720 pages, LIFO batch:31
[    0.000000] On node 6 totalpages: 3145728
[    0.000000]   Normal zone: 43008 pages used for memmap
[    0.000000]   Normal zone: 3102720 pages, LIFO batch:31
[    0.000000] On node 7 totalpages: 3145728
[    0.000000]   Normal zone: 43008 pages used for memmap
[    0.000000]   Normal zone: 3102720 pages, LIFO batch:31
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] ACPI: PM-Timer IO Port: 0x4008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x08] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x09] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x0a] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x0b] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x0c] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x0d] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x0e] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x0f] enabled)
[    0.000000] ACPI: IOAPIC (id[0x0f] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 15, version 17, address 0xfec00000,
GSI 0-23
[    0.000000] ACPI: IOAPIC (id[0x10] address[0xfe5fd000] gsi_base[48])
[    0.000000] IOAPIC[1]: apic_id 16, version 17, address 0xfe5fd000,
GSI 48-54
[    0.000000] ACPI: IOAPIC (id[0x11] address[0xfe5fc000] gsi_base[56])
[    0.000000] IOAPIC[2]: apic_id 17, version 17, address 0xfe5fc000,
GSI 56-62
[    0.000000] ACPI: IOAPIC (id[0x0e] address[0xfeaff000] gsi_base[24])
[    0.000000] IOAPIC[3]: apic_id 14, version 17, address 0xfeaff000,
GSI 24-47
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x0 base: 0xfed00000
[    0.000000] SMP: Allowing 16 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 63
[    0.000000] Allocating PCI resources starting at e0000000 (gap:
e0000000:1ec00000)
[    0.000000] NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:16 nr_node_ids:8
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff880028200000 s81432
r8192 d20968 u1048576
[    0.000000] pcpu-alloc: s81432 r8192 d20968 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 01 [1] 02 03 [2] 04 05 [3] 06 07
[    0.000000] pcpu-alloc: [4] 08 09 [5] 10 11 [6] 12 13 [7] 14 15
[    0.000000] Built 8 zonelists in Zone order, mobility grouping on.
Total pages: 32964244
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line:
root=UUID=52012ca3-9b77-4a86-a1cf-9bbed1bbf53f ro console=ttyS0,9600
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ fbf4000000 size 32 MB
[    0.000000] Aperture beyond 4GB. Ignoring.
[    0.000000] Your BIOS doesn't leave a aperture memory hole
[    0.000000] Please enable the IOMMU option in the BIOS setup
[    0.000000] This costs you 64 MB of RAM
[    0.000000] Mapping aperture over 65536 KB of RAM @ 20000000
[    0.000000] Memory: 131780964k/134217728k available (3014k kernel
code, 524820k absent, 1911944k reserved, 2105k data, 496k init)
[    0.000000] SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0,
CPUs=16, Nodes=8
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:1280
[    0.000000] Extended CMOS year: 2000
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] HPET: 3 timers in total, 0 timers will be used for
per-cpu timer
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2799.820 MHz processor.
[    0.012013] Calibrating delay loop (skipped), value calculated using
timer frequency.. 5599.64 BogoMIPS (lpj=11199280)
[    0.020072] Security Framework initialized
[    0.024008] SELinux:  Disabled at boot.
[    0.039043] Dentry cache hash table entries: 16777216 (order: 15,
134217728 bytes)
[    0.161631] Inode-cache hash table entries: 8388608 (order: 14,
67108864 bytes)
[    0.222389] Mount-cache hash table entries: 256
[    0.224296] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.228002] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.232002] CPU 0/0x0 -> Node 0
[    0.236002] tseg: 0000000000
[    0.236020] CPU: Physical Processor ID: 0
[    0.240001] CPU: Processor Core ID: 0
[    0.244004] mce: CPU supports 5 MCE banks
[    0.248012] using C1E aware idle routine
[    0.252002] Performance Events: AMD PMU driver.
[    0.260003] ... version:                0
[    0.264001] ... bit width:              48
[    0.268001] ... generic registers:      4
[    0.272001] ... value mask:             0000ffffffffffff
[    0.276001] ... max period:             00007fffffffffff
[    0.280001] ... fixed-purpose events:   0
[    0.284001] ... event mask:             000000000000000f
[    0.288017] ACPI: Core revision 20090903
[    0.307823] Setting APIC routing to physical flat
[    0.308663] ..TIMER: vector=0x30 apic1=0 pin1=0 apic2=-1 pin2=-1
[    0.352124] CPU0: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    0.368000] Booting processor 1 APIC 0x1 ip 0x6000
[    0.016000] Initializing CPU#1
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 1/0x1 -> Node 0
[    0.016000] CPU: Physical Processor ID: 0
[    0.016000] CPU: Processor Core ID: 1
[    0.460092] CPU1: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    0.476012] Booting processor 2 APIC 0x2 ip 0x6000
[    0.016000] Initializing CPU#2
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 2/0x2 -> Node 1
[    0.016000] CPU: Physical Processor ID: 1
[    0.016000] CPU: Processor Core ID: 0
[    0.572049] CPU2: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    0.584087] Booting processor 3 APIC 0x3 ip 0x6000
[    0.016000] Initializing CPU#3
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 3/0x3 -> Node 1
[    0.016000] CPU: Physical Processor ID: 1
[    0.016000] CPU: Processor Core ID: 1
[    0.680099] CPU3: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    0.696025] Booting processor 4 APIC 0x4 ip 0x6000
[    0.016000] Initializing CPU#4
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 4/0x4 -> Node 2
[    0.016000] CPU: Physical Processor ID: 2
[    0.016000] CPU: Processor Core ID: 0
[    0.792052] CPU4: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    0.804077] Booting processor 5 APIC 0x5 ip 0x6000
[    0.016000] Initializing CPU#5
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 5/0x5 -> Node 2
[    0.016000] CPU: Physical Processor ID: 2
[    0.016000] CPU: Processor Core ID: 1
[    0.900107] CPU5: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    0.916030] Booting processor 6 APIC 0x6 ip 0x6000
[    0.016000] Initializing CPU#6
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 6/0x6 -> Node 3
[    0.016000] CPU: Physical Processor ID: 3
[    0.016000] CPU: Processor Core ID: 0
[    1.012055] CPU6: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.024081] Booting processor 7 APIC 0x7 ip 0x6000
[    0.016000] Initializing CPU#7
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 7/0x7 -> Node 3
[    0.016000] CPU: Physical Processor ID: 3
[    0.016000] CPU: Processor Core ID: 1
[    1.120113] CPU7: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.132092] Booting processor 8 APIC 0x8 ip 0x6000
[    0.016000] Initializing CPU#8
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 8/0x8 -> Node 4
[    0.016000] CPU: Physical Processor ID: 4
[    0.016000] CPU: Processor Core ID: 0
[    1.228066] CPU8: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.240074] Booting processor 9 APIC 0x9 ip 0x6000
[    0.016000] Initializing CPU#9
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 9/0x9 -> Node 4
[    0.016000] CPU: Physical Processor ID: 4
[    0.016000] CPU: Processor Core ID: 1
[    1.336112] CPU9: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.352032] Booting processor 10 APIC 0xa ip 0x6000
[    0.016000] Initializing CPU#10
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 10/0xa -> Node 5
[    0.016000] CPU: Physical Processor ID: 5
[    0.016000] CPU: Processor Core ID: 0
[    1.448078] CPU10: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.460078] Booting processor 11 APIC 0xb ip 0x6000
[    0.016000] Initializing CPU#11
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 11/0xb -> Node 5
[    0.016000] CPU: Physical Processor ID: 5
[    0.016000] CPU: Processor Core ID: 1
[    1.556101] CPU11: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.568083] Booting processor 12 APIC 0xc ip 0x6000
[    0.016000] Initializing CPU#12
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 12/0xc -> Node 6
[    0.016000] CPU: Physical Processor ID: 6
[    0.016000] CPU: Processor Core ID: 0
[    1.664122] CPU12: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.676073] Booting processor 13 APIC 0xd ip 0x6000
[    0.016000] Initializing CPU#13
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 13/0xd -> Node 6
[    0.016000] CPU: Physical Processor ID: 6
[    0.016000] CPU: Processor Core ID: 1
[    1.772042] CPU13: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.784090] Booting processor 14 APIC 0xe ip 0x6000
[    0.016000] Initializing CPU#14
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 14/0xe -> Node 7
[    0.016000] CPU: Physical Processor ID: 7
[    0.016000] CPU: Processor Core ID: 0
[    1.880059] CPU14: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    1.892087] Booting processor 15 APIC 0xf ip 0x6000
[    0.016000] Initializing CPU#15
[    0.016000] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64
bytes/line)
[    0.016000] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.016000] CPU 15/0xf -> Node 7
[    0.016000] CPU: Physical Processor ID: 7
[    0.016000] CPU: Processor Core ID: 1
[    1.988092] CPU15: Dual-Core AMD Opteron(tm) Processor 8220 stepping 03
[    2.000017] Brought up 16 CPUs
[    2.004004] Total of 16 processors activated (89600.39 BogoMIPS).
[    2.009879] CPU0 attaching sched-domain:
[    2.009882]  domain 0: span 0-1 level MC
[    2.009883]   groups: 0 1
[    2.009886]   domain 1: span 0-15 level NODE
[    2.009888]    groups: 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048)
4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048)
10-11 (cpu_power = 2048) 12-13 (cpu_power = 2048) 14-15 (cpu_power = 2048)
[    2.009899] CPU1 attaching sched-domain:
[    2.009901]  domain 0: span 0-1 level MC
[    2.009902]   groups: 1 0
[    2.009904]   domain 1: span 0-15 level NODE
[    2.009906]    groups: 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048)
4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048)
10-11 (cpu_power = 2048) 12-13 (cpu_power = 2048) 14-15 (cpu_power = 2048)
[    2.009916] CPU2 attaching sched-domain:
[    2.009917]  domain 0: span 2-3 level MC
[    2.009918]   groups: 2 3
[    2.009921]   domain 1: span 0-15 level NODE
[    2.009922]    groups: 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048)
6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048)
12-13 (cpu_power = 2048) 14-15 (cpu_power = 2048) 0-1 (cpu_power = 2048)
[    2.009932] CPU3 attaching sched-domain:
[    2.009933]  domain 0: span 2-3 level MC
[    2.009935]   groups: 3 2
[    2.009937]   domain 1: span 0-15 level NODE
[    2.009939]    groups: 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048)
6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048)
12-13 (cpu_power = 2048) 14-15 (cpu_power = 2048) 0-1 (cpu_power = 2048)
[    2.009949] CPU4 attaching sched-domain:
[    2.009950]  domain 0: span 4-5 level MC
[    2.009951]   groups: 4 5
[    2.009954]   domain 1: span 0-15 level NODE
[    2.009955]    groups: 4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048)
8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048) 12-13 (cpu_power = 2048)
14-15 (cpu_power = 2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048)
[    2.009965] CPU5 attaching sched-domain:
[    2.009966]  domain 0: span 4-5 level MC
[    2.009968]   groups: 5 4
[    2.009970]   domain 1: span 0-15 level NODE
[    2.009971]    groups: 4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048)
8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048) 12-13 (cpu_power = 2048)
14-15 (cpu_power = 2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048)
[    2.009981] CPU6 attaching sched-domain:
[    2.009983]  domain 0: span 6-7 level MC
[    2.009984]   groups: 6 7
[    2.009986]   domain 1: span 0-15 level NODE
[    2.009988]    groups: 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048)
10-11 (cpu_power = 2048) 12-13 (cpu_power = 2048) 14-15 (cpu_power =
2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048)
[    2.009998] CPU7 attaching sched-domain:
[    2.009999]  domain 0: span 6-7 level MC
[    2.010000]   groups: 7 6
[    2.010003]   domain 1: span 0-15 level NODE
[    2.010004]    groups: 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048)
10-11 (cpu_power = 2048) 12-13 (cpu_power = 2048) 14-15 (cpu_power =
2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048)
[    2.010014] CPU8 attaching sched-domain:
[    2.010015]  domain 0: span 8-9 level MC
[    2.010017]   groups: 8 9
[    2.010019]   domain 1: span 0-15 level NODE
[    2.010020]    groups: 8-9 (cpu_power = 2048) 10-11 (cpu_power =
2048) 12-13 (cpu_power = 2048) 14-15 (cpu_power = 2048) 0-1 (cpu_power =
2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048)
[    2.010031] CPU9 attaching sched-domain:
[    2.010032]  domain 0: span 8-9 level MC
[    2.010033]   groups: 9 8
[    2.010036]   domain 1: span 0-15 level NODE
[    2.010037]    groups: 8-9 (cpu_power = 2048) 10-11 (cpu_power =
2048) 12-13 (cpu_power = 2048) 14-15 (cpu_power = 2048) 0-1 (cpu_power =
2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048)
[    2.010047] CPU10 attaching sched-domain:
[    2.010048]  domain 0: span 10-11 level MC
[    2.010050]   groups: 10 11
[    2.010052]   domain 1: span 0-15 level NODE
[    2.010054]    groups: 10-11 (cpu_power = 2048) 12-13 (cpu_power =
2048) 14-15 (cpu_power = 2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power =
2048) 4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048)
[    2.010063] CPU11 attaching sched-domain:
[    2.010065]  domain 0: span 10-11 level MC
[    2.010066]   groups: 11 10
[    2.010069]   domain 1: span 0-15 level NODE
[    2.010070]    groups: 10-11 (cpu_power = 2048) 12-13 (cpu_power =
2048) 14-15 (cpu_power = 2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power =
2048) 4-5 (cpu_power = 2048) 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048)
[    2.010080] CPU12 attaching sched-domain:
[    2.010081]  domain 0: span 12-13 level MC
[    2.010083]   groups: 12 13
[    2.010085]   domain 1: span 0-15 level NODE
[    2.010086]    groups: 12-13 (cpu_power = 2048) 14-15 (cpu_power =
2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power =
2048) 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048)
[    2.010096] CPU13 attaching sched-domain:
[    2.010098]  domain 0: span 12-13 level MC
[    2.010099]   groups: 13 12
[    2.010102]   domain 1: span 0-15 level NODE
[    2.010103]    groups: 12-13 (cpu_power = 2048) 14-15 (cpu_power =
2048) 0-1 (cpu_power = 2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power =
2048) 6-7 (cpu_power = 2048) 8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048)
[    2.010113] CPU14 attaching sched-domain:
[    2.010114]  domain 0: span 14-15 level MC
[    2.010116]   groups: 14 15
[    2.010118]   domain 1: span 0-15 level NODE
[    2.010119]    groups: 14-15 (cpu_power = 2048) 0-1 (cpu_power =
2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048) 6-7 (cpu_power =
2048) 8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048) 12-13 (cpu_power =
2048)
[    2.010129] CPU15 attaching sched-domain:
[    2.010131]  domain 0: span 14-15 level MC
[    2.010132]   groups: 15 14
[    2.010135]   domain 1: span 0-15 level NODE
[    2.010136]    groups: 14-15 (cpu_power = 2048) 0-1 (cpu_power =
2048) 2-3 (cpu_power = 2048) 4-5 (cpu_power = 2048) 6-7 (cpu_power =
2048) 8-9 (cpu_power = 2048) 10-11 (cpu_power = 2048) 12-13 (cpu_power =
2048)
[    2.011492] NET: Registered protocol family 16
[    2.012421] node 0 link 2: io port [9000, cfff]
[    2.012424] node 7 link 2: io port [d000, ffff]
[    2.012426] node 7 link 2: io port [5000, 5fff]
[    2.012428] TOM: 00000000e0000000 aka 3584M
[    2.016004] node 0 link 2: mmio [fbd00000, fe6fffff]
[    2.016006] node 7 link 2: mmio [fe700000, febfffff]
[    2.016008] node 7 link 2: mmio [fed10000, fed1ffff]
[    2.016010] node 7 link 2: mmio [e8000000, ebffffff]
[    2.016012] node 0 link 2: mmio [a0000, bffff]
[    2.016014] node 0 link 2: mmio [e0000000, e3ffffff]
[    2.016016] TOM2: 0000002000000000 aka 131072M
[    2.020003] bus: [00,07] on node 0 link 2
[    2.020005] bus: 00 index 0 io port: [6000, cfff]
[    2.020006] bus: 00 index 1 io port: [0, 4fff]
[    2.020008] bus: 00 index 2 mmio: [ec000000, fe6fffff]
[    2.020010] bus: 00 index 3 mmio: [a0000, bffff]
[    2.020011] bus: 00 index 4 mmio: [e0000000, e7ffffff]
[    2.020013] bus: 00 index 5 mmio: [fec00000, fed0ffff]
[    2.020014] bus: 00 index 6 mmio: [fed20000, ffffffff]
[    2.020016] bus: 00 index 7 mmio: [2000000000, fcffffffff]
[    2.020017] bus: [80,84] on node 7 link 2
[    2.020019] bus: 80 index 0 io port: [d000, ffff]
[    2.020021] bus: 80 index 1 io port: [5000, 5fff]
[    2.020022] bus: 80 index 2 mmio: [fe700000, febfffff]
[    2.020024] bus: 80 index 3 mmio: [fed10000, fed1ffff]
[    2.020025] bus: 80 index 4 mmio: [e8000000, ebffffff]
[    2.020032] ACPI: bus type pci registered
[    2.024104] PCI: Using configuration type 1 for base access
[    2.033213] bio: create slab <bio-0> at 0
[    2.037003] ACPI: EC: Look up EC in DSDT
[    2.044551] ACPI: Executed 1 blocks of module-level executable AML code
[    2.071807] ACPI: Interpreter enabled
[    2.072007] ACPI: (supports S0 S1 S5)
[    2.087120] ACPI: Using IOAPIC for interrupt routing
[    2.107662] ACPI Warning: Incorrect checksum in table [OEMB] - 33,
should be 32 (20090903/tbutils-314)
[    2.116370] ACPI: No dock devices found.
[    2.131791] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    2.132168] pci 0000:00:01.1: reg 10 io port: [0x2800-0x281f]
[    2.132176] pci 0000:00:01.1: reg 20 io port: [0xff00-0xff3f]
[    2.132180] pci 0000:00:01.1: reg 24 io port: [0xff40-0xff7f]
[    2.132191] pci 0000:00:01.1: PME# supported from D3hot D3cold
[    2.136003] pci 0000:00:01.1: PME# disabled
[    2.140021] pci 0000:00:02.0: reg 10 32bit mmio: [0xfe5ff000-0xfe5fffff]
[    2.140040] pci 0000:00:02.0: supports D1 D2
[    2.140041] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.144002] pci 0000:00:02.0: PME# disabled
[    2.148020] pci 0000:00:02.1: reg 10 32bit mmio: [0xfe5fec00-0xfe5fecff]
[    2.148042] pci 0000:00:02.1: supports D1 D2
[    2.148043] pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
[    2.152003] pci 0000:00:02.1: PME# disabled
[    2.156031] pci 0000:00:06.0: reg 20 io port: [0x2000-0x200f]
[    2.156094] pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.160002] pci 0000:00:0b.0: PME# disabled
[    2.164036] pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.168003] pci 0000:00:0c.0: PME# disabled
[    2.172036] pci 0000:00:0d.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.176002] pci 0000:00:0d.0: PME# disabled
[    2.180035] pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.184003] pci 0000:00:0e.0: PME# disabled
[    2.188032] pci 0000:00:10.0: Enabling HT MSI Mapping
[    2.192023] pci 0000:00:10.1: reg 10 64bit mmio: [0xfe5fd000-0xfe5fdfff]
[    2.192066] pci 0000:00:11.0: Enabling HT MSI Mapping
[    2.196024] pci 0000:00:11.1: reg 10 64bit mmio: [0xfe5fc000-0xfe5fcfff]
[    2.200257] PCI: peer root bus 00 res updated from pci conf
[    2.200290] pci 0000:01:06.0: reg 10 32bit mmio: [0xfc000000-0xfcffffff]
[    2.200295] pci 0000:01:06.0: reg 14 io port: [0x9800-0x98ff]
[    2.200300] pci 0000:01:06.0: reg 18 32bit mmio: [0xfddff000-0xfddfffff]
[    2.200315] pci 0000:01:06.0: reg 30 32bit mmio pref:
[0xfddc0000-0xfdddffff]
[    2.200328] pci 0000:01:06.0: supports D1 D2
[    2.200353] pci 0000:00:09.0: transparent bridge
[    2.204003] pci 0000:00:09.0: bridge io port: [0x9000-0x9fff]
[    2.204006] pci 0000:00:09.0: bridge 32bit mmio: [0xfbd00000-0xfddfffff]
[    2.204099] pci 0000:04:00.0: reg 10 io port: [0xa800-0xa8ff]
[    2.204108] pci 0000:04:00.0: reg 14 64bit mmio: [0xfdefc000-0xfdefffff]
[    2.204125] pci 0000:04:00.0: reg 30 32bit mmio pref:
[0xfde80000-0xfdebffff]
[    2.204187] pci 0000:00:0d.0: bridge io port: [0xa000-0xafff]
[    2.204189] pci 0000:00:0d.0: bridge 32bit mmio: [0xfde00000-0xfdefffff]
[    2.204246] pci 0000:06:01.0: reg 10 64bit mmio: [0xfdfe0000-0xfdffffff]
[    2.204252] pci 0000:06:01.0: reg 20 io port: [0xbc00-0xbc3f]
[    2.204266] pci 0000:06:01.0: PME# supported from D0 D3hot
[    2.208002] pci 0000:06:01.0: PME# disabled
[    2.212023] pci 0000:06:01.1: reg 10 64bit mmio: [0xfdfc0000-0xfdfdffff]
[    2.212029] pci 0000:06:01.1: reg 20 io port: [0xb800-0xb83f]
[    2.212043] pci 0000:06:01.1: PME# supported from D0 D3hot
[    2.216002] pci 0000:06:01.1: PME# disabled
[    2.220026] pci 0000:06:02.0: reg 10 64bit mmio: [0xfdfa0000-0xfdfbffff]
[    2.220033] pci 0000:06:02.0: reg 20 io port: [0xb400-0xb43f]
[    2.220046] pci 0000:06:02.0: PME# supported from D0 D3hot
[    2.224002] pci 0000:06:02.0: PME# disabled
[    2.228023] pci 0000:06:02.1: reg 10 64bit mmio: [0xfdf80000-0xfdf9ffff]
[    2.228030] pci 0000:06:02.1: reg 20 io port: [0xb000-0xb03f]
[    2.228043] pci 0000:06:02.1: PME# supported from D0 D3hot
[    2.232003] pci 0000:06:02.1: PME# disabled
[    2.236023] pci 0000:00:10.0: bridge io port: [0xb000-0xbfff]
[    2.236025] pci 0000:00:10.0: bridge 32bit mmio: [0xfdf00000-0xfdffffff]
[    2.236054] pci 0000:07:04.0: reg 10 io port: [0xc800-0xc8ff]
[    2.236060] pci 0000:07:04.0: reg 14 64bit mmio: [0xfe4fc000-0xfe4fffff]
[    2.236066] pci 0000:07:04.0: reg 1c 64bit mmio: [0xfe4e0000-0xfe4effff]
[    2.236071] pci 0000:07:04.0: reg 30 32bit mmio pref:
[0xfe200000-0xfe3fffff]
[    2.236085] pci 0000:07:04.0: supports D1 D2
[    2.236106] pci 0000:00:11.0: bridge io port: [0xc000-0xcfff]
[    2.236109] pci 0000:00:11.0: bridge 32bit mmio: [0xfe000000-0xfe4fffff]
[    2.236128] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    2.236316] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.POGA._PRT]
[    2.236374] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.POGB._PRT]
[    2.236476] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    2.236526] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
[    2.236592] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
[    2.236655] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P5._PRT]
[    2.264418] ACPI: PCI Root Bridge [PCIB] (0000:80)
[    2.268124] pci 0000:80:01.0: reg 14 32bit mmio: [0xfeaff000-0xfeafffff]
[    2.268174] pci 0000:80:0b.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.272003] pci 0000:80:0b.0: PME# disabled
[    2.276032] pci 0000:80:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.280002] pci 0000:80:0c.0: PME# disabled
[    2.284031] pci 0000:80:0d.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.288003] pci 0000:80:0d.0: PME# disabled
[    2.292031] pci 0000:80:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.296002] pci 0000:80:0e.0: PME# disabled
[    2.300017] PCI: peer root bus 80 res updated from pci conf
[    2.300075] pci 0000:82:00.0: reg 10 32bit mmio: [0xfe7e0000-0xfe7fffff]
[    2.300080] pci 0000:82:00.0: reg 14 32bit mmio: [0xfe780000-0xfe7bffff]
[    2.300085] pci 0000:82:00.0: reg 18 io port: [0xdc00-0xdc1f]
[    2.300090] pci 0000:82:00.0: reg 1c 32bit mmio: [0xfe7dc000-0xfe7dffff]
[    2.300124] pci 0000:82:00.0: PME# supported from D0 D3hot
[    2.304003] pci 0000:82:00.0: PME# disabled
[    2.308032] pci 0000:80:0c.0: bridge io port: [0xd000-0xdfff]
[    2.308034] pci 0000:80:0c.0: bridge 32bit mmio: [0xfe700000-0xfe7fffff]
[    2.308062] pci 0000:83:00.0: reg 10 32bit mmio: [0xfe8e0000-0xfe8fffff]
[    2.308066] pci 0000:83:00.0: reg 14 32bit mmio: [0xfe880000-0xfe8bffff]
[    2.308071] pci 0000:83:00.0: reg 18 io port: [0xec00-0xec1f]
[    2.308076] pci 0000:83:00.0: reg 1c 32bit mmio: [0xfe8dc000-0xfe8dffff]
[    2.308104] pci 0000:83:00.0: PME# supported from D0 D3hot
[    2.312003] pci 0000:83:00.0: PME# disabled
[    2.316031] pci 0000:80:0d.0: bridge io port: [0xe000-0xefff]
[    2.316033] pci 0000:80:0d.0: bridge 32bit mmio: [0xfe800000-0xfe8fffff]
[    2.316060] pci 0000:84:00.0: reg 10 32bit mmio: [0xfe9e0000-0xfe9fffff]
[    2.316065] pci 0000:84:00.0: reg 14 32bit mmio: [0xfe980000-0xfe9bffff]
[    2.316070] pci 0000:84:00.0: reg 18 io port: [0xfc00-0xfc1f]
[    2.316074] pci 0000:84:00.0: reg 1c 32bit mmio: [0xfe9dc000-0xfe9dffff]
[    2.316102] pci 0000:84:00.0: PME# supported from D0 D3hot
[    2.320003] pci 0000:84:00.0: PME# disabled
[    2.324031] pci 0000:80:0e.0: bridge io port: [0xf000-0xffff]
[    2.324033] pci 0000:80:0e.0: bridge 32bit mmio: [0xfe900000-0xfe9fffff]
[    2.324044] ACPI: PCI Interrupt Routing Table [\_SB_.PCIB._PRT]
[    2.324188] ACPI: PCI Interrupt Routing Table [\_SB_.PCIB.BR8C._PRT]
[    2.324252] ACPI: PCI Interrupt Routing Table [\_SB_.PCIB.BR8D._PRT]
[    2.324313] ACPI: PCI Interrupt Routing Table [\_SB_.PCIB.BR8E._PRT]
[    2.325779] ACPI: PCI Interrupt Link [LNKA] (IRQs 16 17 18 19) *10
[    2.348205] ACPI: PCI Interrupt Link [LNKB] (IRQs 16 17 18 19) *7
[    2.372201] ACPI: PCI Interrupt Link [LNKC] (IRQs 16 17 18 19) *5
[    2.398278] ACPI: PCI Interrupt Link [LNKD] (IRQs 16 17 18 19) *15
[    2.420196] ACPI: PCI Interrupt Link [LNKE] (IRQs 16 17 18 19) *0,
disabled.
[    2.448197] ACPI: PCI Interrupt Link [LUS0] (IRQs 20 21 22) *11
[    2.472144] ACPI: PCI Interrupt Link [LUS1] (IRQs 20 21 22) *0, disabled.
[    2.496196] ACPI: PCI Interrupt Link [LUS2] (IRQs 20 21 22) *5
[    2.518282] ACPI: PCI Interrupt Link [LKLN] (IRQs 20 21 22) *0, disabled.
[    2.540197] ACPI: PCI Interrupt Link [LAUI] (IRQs 20 21 22) *0, disabled.
[    2.568197] ACPI: PCI Interrupt Link [LKMO] (IRQs 20 21 22) *0, disabled.
[    2.590278] ACPI: PCI Interrupt Link [LKSM] (IRQs 20 21 22) *0, disabled.
[    2.612196] ACPI: PCI Interrupt Link [LTID] (IRQs 20 21 22) *0, disabled.
[    2.638283] ACPI: PCI Interrupt Link [LTIE] (IRQs 20 21 22) *0, disabled.
[    2.658323] ACPI: PCI Interrupt Link [LATA] (IRQs 20 21 22) *14
[    2.678297] ACPI: PCI Interrupt Link [LN2A] (IRQs 40 41 42 43) *10
[    2.700210] ACPI: PCI Interrupt Link [LN2B] (IRQs 40 41 42 43) *7
[    2.724208] ACPI: PCI Interrupt Link [LN2C] (IRQs 40 41 42 43) *5
[    2.746289] ACPI: PCI Interrupt Link [LN2D] (IRQs 40 41 42 43) *15
[    2.768209] ACPI: PCI Interrupt Link [LN4A] (IRQs 40 41 42 43) *15
[    2.794290] ACPI: PCI Interrupt Link [LN4B] (IRQs 40 41 42 43) *15
[    2.816208] ACPI: PCI Interrupt Link [LN4C] (IRQs 40 41 42 43) *15
[    2.842287] ACPI: PCI Interrupt Link [LN4D] (IRQs 40 41 42 43) *15
[    2.864208] ACPI: PCI Interrupt Link [LN6A] (IRQs 40 41 42 43) *15
[    2.890289] ACPI: PCI Interrupt Link [LN6B] (IRQs 40 41 42 43) *15
[    2.912207] ACPI: PCI Interrupt Link [LN6C] (IRQs 40 41 42 43) *15
[    2.938290] ACPI: PCI Interrupt Link [LN6D] (IRQs 40 41 42 43) *15
[    2.960208] ACPI: PCI Interrupt Link [LK2N] (IRQs 44 45 46 47) *0,
disabled.
[    2.986294] ACPI: PCI Interrupt Link [LK4N] (IRQs 44 45 46 47) *15
[    3.008209] ACPI: PCI Interrupt Link [LK6N] (IRQs 44 45 46 47) *15
[    3.034291] ACPI: PCI Interrupt Link [LT3D] (IRQs 44 45 46 47) *0,
disabled.
[    3.058301] ACPI: PCI Interrupt Link [LT2E] (IRQs 44 45 46 47) *0,
disabled.
[    3.082341] vgaarb: device added:
PCI:0000:01:06.0,decodes=io+mem,owns=io+mem,locks=none
[    3.084012] vgaarb: loaded
[    3.088215] PCI: Using ACPI for IRQ routing
[    3.092014] pci 0000:00:01.1: BAR 4: no parent found for of device
[0xff00-0xff3f]
[    3.096002] pci 0000:00:01.1: BAR 4: can't allocate resource
[    3.100002] pci 0000:00:01.1: BAR 5: no parent found for of device
[0xff40-0xff7f]
[    3.104001] pci 0000:00:01.1: BAR 5: can't allocate resource
[    3.108302] NET: Registered protocol family 8
[    3.112002] NET: Registered protocol family 20
[    3.116094] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 31
[    3.132001] hpet0: 3 comparators, 32-bit 25.000000 MHz counter
[    3.188305] Switching to clocksource hpet
[    3.194723] pnp: PnP ACPI init
[    3.231007] ACPI: bus type pnp registered
[    3.292594] pnp 00:06: io resource (0x10-0x1f) overlaps 0000:00:01.1
BAR 4 (0x0-0x3f), disabling
[    3.397650] pnp 00:06: io resource (0x22-0x3f) overlaps 0000:00:01.1
BAR 4 (0x0-0x3f), disabling
[    3.502707] pnp 00:06: io resource (0x10-0x1f) overlaps 0000:00:01.1
BAR 5 (0x0-0x3f), disabling
[    3.607767] pnp 00:06: io resource (0x22-0x3f) overlaps 0000:00:01.1
BAR 5 (0x0-0x3f), disabling
[    3.725288] pnp: PnP ACPI: found 14 devices
[    3.775222] ACPI: ACPI bus type pnp unregistered
[    3.830372] system 00:06: ioport range 0x190-0x193 has been reserved
[    3.906308] system 00:06: ioport range 0x4d0-0x4d1 has been reserved
[    3.982242] system 00:06: iomem range 0xffb80000-0xfffffffe has been
reserved
[    4.067539] system 00:09: ioport range 0xcf8-0xcff could not be reserved
[    4.147632] system 00:09: ioport range 0xca0-0xcaf has been reserved
[    4.223568] system 00:09: iomem range 0xfec00000-0xfec00fff could not
be reserved
[    4.313019] system 00:09: iomem range 0xfee00000-0xfeefffff could not
be reserved
[    4.402473] system 00:09: iomem range 0xfefff000-0xfeffffff has been
reserved
[    4.487768] system 00:0a: ioport range 0x680-0x6ff has been reserved
[    4.563708] system 00:0b: iomem range 0xe0000000-0xefffffff could not
be reserved
[    4.653165] system 00:0c: iomem range 0x0-0x9ffff could not be reserved
[    4.732219] system 00:0c: iomem range 0xc0000-0xdffff has been reserved
[    4.811269] system 00:0c: iomem range 0xe0000-0xfffff could not be
reserved
[    4.894483] system 00:0c: iomem range 0x100000-0xdfffffff could not
be reserved
[    4.987128] pci 0000:01:06.0: BAR 6: address space collision on of
device [0xfddc0000-0xfdddffff]
[    5.093295] pci 0000:00:09.0: PCI bridge, secondary bus 0000:01
[    5.164033] pci 0000:00:09.0:   IO window: 0x9000-0x9fff
[    5.227486] pci 0000:00:09.0:   MEM window: 0xfbd00000-0xfddfffff
[    5.300300] pci 0000:00:09.0:   PREFETCH window: 0xec000000-0xec0fffff
[    5.378315] pci 0000:00:0b.0: PCI bridge, secondary bus 0000:02
[    5.449048] pci 0000:00:0b.0:   IO window: disabled
[    5.507304] pci 0000:00:0b.0:   MEM window: disabled
[    5.566596] pci 0000:00:0b.0:   PREFETCH window: disabled
[    5.631090] pci 0000:00:0c.0: PCI bridge, secondary bus 0000:03
[    5.701823] pci 0000:00:0c.0:   IO window: disabled
[    5.760075] pci 0000:00:0c.0:   MEM window: disabled
[    5.819368] pci 0000:00:0c.0:   PREFETCH window: disabled
[    5.883863] pci 0000:00:0d.0: PCI bridge, secondary bus 0000:04
[    5.954594] pci 0000:00:0d.0:   IO window: 0xa000-0xafff
[    6.018050] pci 0000:00:0d.0:   MEM window: 0xfde00000-0xfdefffff
[    6.090861] pci 0000:00:0d.0:   PREFETCH window: disabled
[    6.155354] pci 0000:00:0e.0: PCI bridge, secondary bus 0000:05
[    6.226085] pci 0000:00:0e.0:   IO window: disabled
[    6.284341] pci 0000:00:0e.0:   MEM window: disabled
[    6.343632] pci 0000:00:0e.0:   PREFETCH window: disabled
[    6.408126] pci 0000:00:10.0: PCI bridge, secondary bus 0000:06
[    6.478859] pci 0000:00:10.0:   IO window: 0xb000-0xbfff
[    6.542314] pci 0000:00:10.0:   MEM window: 0xfdf00000-0xfdffffff
[    6.615124] pci 0000:00:10.0:   PREFETCH window: disabled
[    6.679619] pci 0000:00:11.0: PCI bridge, secondary bus 0000:07
[    6.750350] pci 0000:00:11.0:   IO window: 0xc000-0xcfff
[    6.813806] pci 0000:00:11.0:   MEM window: 0xfe000000-0xfe4fffff
[    6.886622] pci 0000:00:11.0:   PREFETCH window: disabled
[    6.951127] pci 0000:00:09.0: setting latency timer to 64
[    6.951135] pci 0000:00:0b.0: setting latency timer to 64
[    6.951141] pci 0000:00:0c.0: setting latency timer to 64
[    6.951147] pci 0000:00:0d.0: setting latency timer to 64
[    6.951153] pci 0000:00:0e.0: setting latency timer to 64
[    6.951161] pci 0000:80:0b.0: PCI bridge, secondary bus 0000:81
[    7.021894] pci 0000:80:0b.0:   IO window: disabled
[    7.080147] pci 0000:80:0b.0:   MEM window: disabled
[    7.139440] pci 0000:80:0b.0:   PREFETCH window: disabled
[    7.203933] pci 0000:80:0c.0: PCI bridge, secondary bus 0000:82
[    7.274667] pci 0000:80:0c.0:   IO window: 0xd000-0xdfff
[    7.338121] pci 0000:80:0c.0:   MEM window: 0xfe700000-0xfe7fffff
[    7.410932] pci 0000:80:0c.0:   PREFETCH window: disabled
[    7.475425] pci 0000:80:0d.0: PCI bridge, secondary bus 0000:83
[    7.546203] pci 0000:80:0d.0:   IO window: 0xe000-0xefff
[    7.609659] pci 0000:80:0d.0:   MEM window: 0xfe800000-0xfe8fffff
[    7.682468] pci 0000:80:0d.0:   PREFETCH window: disabled
[    7.746963] pci 0000:80:0e.0: PCI bridge, secondary bus 0000:84
[    7.817695] pci 0000:80:0e.0:   IO window: 0xf000-0xffff
[    7.881150] pci 0000:80:0e.0:   MEM window: 0xfe900000-0xfe9fffff
[    7.953961] pci 0000:80:0e.0:   PREFETCH window: disabled
[    8.018458] pci 0000:80:0b.0: setting latency timer to 64
[    8.018462] pci 0000:80:0c.0: setting latency timer to 64
[    8.018466] pci 0000:80:0d.0: setting latency timer to 64
[    8.018470] pci 0000:80:0e.0: setting latency timer to 64
[    8.018473] pci_bus 0000:00: resource 0 io:  [0x6000-0xcfff]
[    8.018475] pci_bus 0000:00: resource 1 io:  [0x00-0x4fff]
[    8.018477] pci_bus 0000:00: resource 2 mem: [0xec000000-0xfe6fffff]
[    8.018479] pci_bus 0000:00: resource 3 mem: [0x0a0000-0x0bffff]
[    8.018481] pci_bus 0000:00: resource 4 mem: [0xe0000000-0xe7ffffff]
[    8.018482] pci_bus 0000:00: resource 5 mem: [0xfec00000-0xfed0ffff]
[    8.018484] pci_bus 0000:00: resource 6 mem: [0xfed20000-0xffffffff]
[    8.018486] pci_bus 0000:00: resource 7 mem: [0x2000000000-0xfcffffffff]
[    8.018488] pci_bus 0000:01: resource 0 io:  [0x9000-0x9fff]
[    8.018490] pci_bus 0000:01: resource 1 mem: [0xfbd00000-0xfddfffff]
[    8.018492] pci_bus 0000:01: resource 2 pref mem [0xec000000-0xec0fffff]
[    8.018494] pci_bus 0000:01: resource 3 io:  [0x6000-0xcfff]
[    8.018495] pci_bus 0000:01: resource 4 io:  [0x00-0x4fff]
[    8.018497] pci_bus 0000:01: resource 5 mem: [0xec000000-0xfe6fffff]
[    8.018499] pci_bus 0000:01: resource 6 mem: [0x0a0000-0x0bffff]
[    8.018501] pci_bus 0000:01: resource 7 mem: [0xe0000000-0xe7ffffff]
[    8.018503] pci_bus 0000:01: resource 8 mem: [0xfec00000-0xfed0ffff]
[    8.018504] pci_bus 0000:01: resource 9 mem: [0xfed20000-0xffffffff]
[    8.018506] pci_bus 0000:01: resource 10 mem: [0x2000000000-0xfcffffffff]
[    8.018509] pci_bus 0000:04: resource 0 io:  [0xa000-0xafff]
[    8.018510] pci_bus 0000:04: resource 1 mem: [0xfde00000-0xfdefffff]
[    8.018512] pci_bus 0000:06: resource 0 io:  [0xb000-0xbfff]
[    8.018514] pci_bus 0000:06: resource 1 mem: [0xfdf00000-0xfdffffff]
[    8.018516] pci_bus 0000:07: resource 0 io:  [0xc000-0xcfff]
[    8.018518] pci_bus 0000:07: resource 1 mem: [0xfe000000-0xfe4fffff]
[    8.018521] pci_bus 0000:80: resource 0 io:  [0xd000-0xffff]
[    8.018523] pci_bus 0000:80: resource 1 io:  [0x5000-0x5fff]
[    8.018524] pci_bus 0000:80: resource 2 mem: [0xfe700000-0xfebfffff]
[    8.018526] pci_bus 0000:80: resource 3 mem: [0xfed10000-0xfed1ffff]
[    8.018528] pci_bus 0000:80: resource 4 mem: [0xe8000000-0xebffffff]
[    8.018530] pci_bus 0000:82: resource 0 io:  [0xd000-0xdfff]
[    8.018532] pci_bus 0000:82: resource 1 mem: [0xfe700000-0xfe7fffff]
[    8.018534] pci_bus 0000:83: resource 0 io:  [0xe000-0xefff]
[    8.018536] pci_bus 0000:83: resource 1 mem: [0xfe800000-0xfe8fffff]
[    8.018538] pci_bus 0000:84: resource 0 io:  [0xf000-0xffff]
[    8.018540] pci_bus 0000:84: resource 1 mem: [0xfe900000-0xfe9fffff]
[    8.018635] NET: Registered protocol family 2
[    8.071259] IP route cache hash table entries: 524288 (order: 10,
4194304 bytes)
[    8.164046] TCP established hash table entries: 524288 (order: 11,
8388608 bytes)
[    8.260592] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    8.341515] TCP: Hash tables configured (established 524288 bind 65536)
[    8.420591] TCP reno registered
[    8.458357] NET: Registered protocol family 1
[    8.535816] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    8.601354] pci 0000:00:0b.0: Found disabled HT MSI Mapping
[    8.667933] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    8.733509] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    8.799043] pci 0000:00:0c.0: Found disabled HT MSI Mapping
[    8.865624] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    8.931203] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    8.996742] pci 0000:00:0d.0: Found disabled HT MSI Mapping
[    9.063322] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    9.128905] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    9.194446] pci 0000:00:0e.0: Found disabled HT MSI Mapping
[    9.261027] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    9.326644] pci 0000:01:06.0: Boot video device
[    9.326688] pci 0000:80:00.0: Found enabled HT MSI Mapping
[    9.392225] pci 0000:80:0b.0: Found disabled HT MSI Mapping
[    9.458799] pci 0000:80:00.0: Found enabled HT MSI Mapping
[    9.524357] pci 0000:80:00.0: Found enabled HT MSI Mapping
[    9.589889] pci 0000:80:0c.0: Found disabled HT MSI Mapping
[    9.656464] pci 0000:80:00.0: Found enabled HT MSI Mapping
[    9.722016] pci 0000:80:00.0: Found enabled HT MSI Mapping
[    9.787550] pci 0000:80:0d.0: Found disabled HT MSI Mapping
[    9.854128] pci 0000:80:00.0: Found enabled HT MSI Mapping
[    9.919684] pci 0000:80:00.0: Found enabled HT MSI Mapping
[    9.985220] pci 0000:80:0e.0: Found disabled HT MSI Mapping
[   10.051795] pci 0000:80:00.0: Found enabled HT MSI Mapping
[   10.117334] pci 0000:83:00.0: Disabling L0s
[   10.167374] Trying to unpack rootfs image as initramfs...
[   10.382688] Freeing initrd memory: 7632k freed
[   10.443904] PCI-DMA: Disabling AGP.
[   10.486132] PCI-DMA: aperture base @ 20000000 size 65536 KB
[   10.552711] PCI-DMA: using GART IOMMU.
[   10.597454] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[   10.680640] audit: initializing netlink socket (disabled)
[   10.745162] type=2000 audit(1266153688.743:1): initialized
[   10.824680] VFS: Disk quotas dquot_6.5.2
[   10.871627] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   10.948665] msgmni has been set to 32768
[   10.996142] alg: No test for stdrng (krng)
[   11.045049] io scheduler noop registered
[   11.091862] io scheduler anticipatory registered
[   11.146995] io scheduler deadline registered
[   11.198062] io scheduler cfq registered (default)
[   11.254540] pcieport 0000:00:0b.0: irq 63 for MSI/MSI-X
[   11.254546] pcieport 0000:00:0b.0: setting latency timer to 64
[   11.254690] pcieport 0000:00:0c.0: irq 64 for MSI/MSI-X
[   11.254694] pcieport 0000:00:0c.0: setting latency timer to 64
[   11.254826] pcieport 0000:00:0d.0: irq 65 for MSI/MSI-X
[   11.254830] pcieport 0000:00:0d.0: setting latency timer to 64
[   11.254963] pcieport 0000:00:0e.0: irq 66 for MSI/MSI-X
[   11.254967] pcieport 0000:00:0e.0: setting latency timer to 64
[   11.255212] pcieport 0000:80:0b.0: irq 67 for MSI/MSI-X
[   11.255219] pcieport 0000:80:0b.0: setting latency timer to 64
[   11.255374] pcieport 0000:80:0c.0: irq 68 for MSI/MSI-X
[   11.255378] pcieport 0000:80:0c.0: setting latency timer to 64
[   11.255498] pcieport 0000:80:0d.0: irq 69 for MSI/MSI-X
[   11.255502] pcieport 0000:80:0d.0: setting latency timer to 64
[   11.255629] pcieport 0000:80:0e.0: irq 70 for MSI/MSI-X
[   11.255632] pcieport 0000:80:0e.0: setting latency timer to 64
[   11.292622] hpet_acpi_add: no address or irqs in _CRS
[   11.353097] Linux agpgart interface v0.103
[   11.401992] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   11.477065] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   11.549536] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   11.618787] brd: module loaded
[   11.655296] input: Macintosh mouse button emulation as
/class/input/input0
[   11.737518] Uniform Multi-Platform E-IDE driver
[   11.791786] ide-gd driver 1.18
[   11.828457] PNP: No PS/2 controller found. Probing ports directly.
[   11.905417] serio: i8042 KBD port at 0x60,0x64 irq 1
[   11.964718] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.025439] mice: PS/2 mouse device common for all mice
[   12.087918] cpuidle: using governor ladder
[   12.137240] TCP cubic registered
[   12.176796] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[   12.251762] Freeing unused kernel memory: 496k freed
[   12.472672] fuse init (API version 7.13)
[   12.550508] device-mapper: ioctl: 4.15.0-ioctl (2009-04-01)
initialised: dm-devel@redhat.com
[   13.433996] usbcore: registered new interface driver usbfs
[   13.434613] amd74xx 0000:00:06.0: UDMA133 controller
[   13.434618] amd74xx 0000:00:06.0: IDE controller (0x10de:0x0053 rev 0xf2)
[   13.434644] amd74xx 0000:00:06.0: IDE port disabled
[   13.434671] amd74xx 0000:00:06.0: not 100% native mode: will probe
irqs later
[   13.434677]     ide0: BM-DMA at 0x2000-0x2007
[   13.434691] Probing IDE interface ide0...
[   13.450419] SCSI subsystem initialized
[   13.452559] Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAPI
[   13.452563] Copyright (c) 1999-2006 Intel Corporation.
[   13.455604] e1000 0000:06:01.0: PCI INT A -> GSI 48 (level, low) ->
IRQ 48
[   13.462685] QLogic Fibre Channel HBA Driver: 8.03.01-k6
[   13.465445] Fusion MPT base driver 3.04.12
[   13.465448] Copyright (c) 1999-2008 LSI Corporation
[   13.472151] Fusion MPT SAS Host driver 3.04.12
[   14.323405] usbcore: registered new interface driver hub
[   14.323786] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 19
[   14.323794] qla2xxx 0000:04:00.0: PCI INT A -> Link[LNKD] -> GSI 19
(level, low) -> IRQ 19
[   14.554310] qla2xxx 0000:04:00.0: Found an ISP2432, irq 19, iobase
0xffffc9000cdc6000
[   14.647997] mptsas 0000:07:04.0: PCI INT A -> GSI 56 (level, low) ->
IRQ 56
[   14.731362] usbcore: registered new device driver usb
[   14.731410] mptbase: ioc0: Initiating bringup
[   14.731806] qla2xxx 0000:04:00.0: irq 71 for MSI/MSI-X
[   14.731851] qla2xxx 0000:04:00.0: Configuring PCI space...
[   14.731856] qla2xxx 0000:04:00.0: setting latency timer to 64
[   14.910829] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   14.912632] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   14.989839] e1000: 0000:06:01.0: e1000_probe: (PCI-X:133MHz:64-bit)
00:14:4f:a8:42:10
[   15.015826] qla2xxx 0000:04:00.0: Configure NVRAM parameters...
[   15.048894] qla2xxx 0000:04:00.0: Verifying loaded RISC code...
[   15.068718] qla2xxx 0000:04:00.0: firmware: requesting ql2400_fw.bin
[   15.069024] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network
Connection
[   15.069112] e1000 0000:06:01.1: PCI INT B -> GSI 49 (level, low) ->
IRQ 49
[   15.538106] qla2xxx 0000:04:00.0: Firmware image unavailable.
[   15.623413] qla2xxx 0000:04:00.0: Firmware images can be retrieved
from: ftp://ftp.qlogic.com/outgoing/linux/firmware/.
[   15.769006] qla2xxx 0000:04:00.0: FW: Loading from flash (20000)...
[   16.290091] e1000: 0000:06:01.1: e1000_probe: (PCI-X:133MHz:64-bit)
00:14:4f:a8:42:11
[   16.607395] hda: MATSHITACD-RW CW-8124, ATAPI CD/DVD-ROM drive
[   16.731297] ioc0: LSISAS1064 A3: Capabilities={Initiator}
[   16.872650] e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network
Connection
[   16.971308] e1000 0000:06:02.0: PCI INT A -> GSI 50 (level, low) ->
IRQ 50
[   17.398067] e1000: 0000:06:02.0: e1000_probe: (PCI-X:133MHz:64-bit)
00:14:4f:a8:42:12
[   17.528599] e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network
Connection
[   17.610818] e1000 0000:06:02.1: PCI INT B -> GSI 51 (level, low) ->
IRQ 51
[   17.703302] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[   17.703448] hda: UDMA/33 mode selected
[   17.748364] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   17.805110] ACPI: PCI Interrupt Link [LUS2] enabled at IRQ 22
[   17.873777] ehci_hcd 0000:00:02.1: PCI INT B -> Link[LUS2] -> GSI 22
(level, low) -> IRQ 22
[   18.216429] e1000: 0000:06:02.1: e1000_probe: (PCI-X:133MHz:64-bit)
00:14:4f:a8:42:13
[   18.310182] ehci_hcd 0000:00:02.1: setting latency timer to 64
[   18.310185] ehci_hcd 0000:00:02.1: EHCI Host Controller
[   18.372676] ehci_hcd 0000:00:02.1: new USB bus registered, assigned
bus number 1
[   18.461137] ehci_hcd 0000:00:02.1: debug port 1
[   18.515232] ehci_hcd 0000:00:02.1: cache line size of 64 is not supported
[   18.515307] qla2xxx 0000:04:00.0: Allocated (64 KB) for EFT...
[   18.585006] ehci_hcd 0000:00:02.1: irq 22, io mem 0xfe5fec00
[   18.652703] qla2xxx 0000:04:00.0: Allocated (1285 KB) for firmware
dump...
[   18.744229] e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network
Connection
[   18.826743] libata version 3.00 loaded.
[   18.835254] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00
[   18.903960] scsi0 : qla2xxx
[   18.937485] qla2xxx 0000:04:00.0:
[   18.937486]  QLogic Fibre Channel HBA Driver: 8.03.01-k6
[   18.937486]   QLogic QLE2460 - SG-(X)PCIE1FC-QF4, Sun StorageTek 4 Gb
FC Enterprise PCI-Express Single Channel
[   18.937487]   ISP2432: PCIe (2.5GT/s x4) @ 0000:04:00.0 hdma+,
host#=0, fw=4.00.26 (2)
[   19.255792] qla2xxx 0000:04:00.0: LIP reset occurred (f8f7).
[   19.323602] usb usb1: configuration #1 chosen from 1 choice
[   19.390202] hub 1-0:1.0: USB hub found
[   19.434942] hub 1-0:1.0: 7 ports detected
[   19.483236] ACPI: PCI Interrupt Link [LUS0] enabled at IRQ 21
[   19.551902] ohci_hcd 0000:00:02.0: PCI INT A -> Link[LUS0] -> GSI 21
(level, low) -> IRQ 21
[   19.651804] ohci_hcd 0000:00:02.0: setting latency timer to 64
[   19.651807] ohci_hcd 0000:00:02.0: OHCI Host Controller
[   19.714229] ohci_hcd 0000:00:02.0: new USB bus registered, assigned
bus number 2
[   19.802661] ohci_hcd 0000:00:02.0: irq 21, io mem 0xfe5ff000
[   19.925267] usb usb2: configuration #1 chosen from 1 choice
[   19.991877] hub 2-0:1.0: USB hub found
[   20.036619] hub 2-0:1.0: 7 ports detected
[   20.096052] ide-cd driver 5.00
[   20.132966] ide-cd: hda: ATAPI 24X DVD-ROM CD-R/RW drive, 2048kB Cache
[   20.211045] Uniform CD-ROM driver Revision: 3.20
[   20.743216] usb 1-6: new high speed USB device using ehci_hcd and
address 5
[   20.956149] usb 1-6: configuration #1 chosen from 1 choice
[   21.021791] hub 1-6:1.0: USB hub found
[   21.066633] hub 1-6:1.0: 4 ports detected
[   21.240568] qla2xxx 0000:04:00.0: LIP occurred (f7f7).
[   21.301951] qla2xxx 0000:04:00.0: LIP reset occurred (f7f7).
[   21.369585] qla2xxx 0000:04:00.0: LOOP UP detected (4 Gbps).
[   21.486269] scsi 0:0:0:0: Direct-Access     NEXSAN   SATABeast2
 Nf66 PQ: 1 ANSI: 5
[   21.559221] usb 2-3: new full speed USB device using ohci_hcd and
address 2
[   21.667777] scsi 0:0:0:4: Direct-Access     NEXSAN   SATABeast2
 Nf66 PQ: 0 ANSI: 5
[   21.677411] scsi 0:0:0:0: Attached scsi generic sg0 type 0
[   21.771303] usb 2-3: configuration #1 chosen from 1 choice
[   21.789196] usbcore: registered new interface driver hiddev
[   21.794563] input: American Megatrends Inc. Virtual Keyboard and
Mouse as /class/input/input1
[   21.794578] generic-usb 0003:046B:FF10.0001: input: USB HID v1.10
Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on
usb-0000:00:02.0-3/input0
[   21.800424] input: American Megatrends Inc. Virtual Keyboard and
Mouse as /class/input/input2
[   21.800462] generic-usb 0003:046B:FF10.0002: input: USB HID v1.10
Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on
usb-0000:00:02.0-3/input1
[   21.800494] usbcore: registered new interface driver usbhid
[   21.800497] usbhid: v2.6:USB HID core driver
[   22.083190] usb 2-4: new full speed USB device using ohci_hcd and
address 3
[   22.295298] usb 2-4: configuration #1 chosen from 1 choice
[   22.308341] usbcore: registered new interface driver libusual
[   22.313809] Initializing USB Mass Storage driver...
[   22.313934] scsi1 : SCSI emulation for USB Mass Storage devices
[   22.314028] usb-storage: device found at 3
[   22.314030] usb-storage: waiting for device to settle before scanning
[   22.314038] usbcore: registered new interface driver usb-storage
[   22.314041] USB Mass Storage support registered.
[   22.603177] usb 2-5: new full speed USB device using ohci_hcd and
address 4
[   22.815290] usb 2-5: configuration #1 chosen from 1 choice
[   22.821300] scsi2 : SCSI emulation for USB Mass Storage devices
[   22.821409] usb-storage: device found at 4
[   22.821410] usb-storage: waiting for device to settle before scanning
[   23.310317] sd 0:0:0:4: Attached scsi generic sg1 type 0
[   23.311252] sd 0:0:0:4: [sda] 1953126400 512-byte logical blocks:
(1.00 TB/931 GiB)
[   23.312406] sd 0:0:0:4: [sda] Write Protect is off
[   23.312408] sd 0:0:0:4: [sda] Mode Sense: 97 00 00 08
[   23.312920] sd 0:0:0:4: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[   23.315312]  sda: unknown partition table
[   23.679159] scsi 0:0:0:5: Direct-Access     NEXSAN   SATABeast2
 Nf66 PQ: 0 ANSI: 5
[   23.681046] sd 0:0:0:4: [sda] Attached SCSI disk
[   23.831121] sd 0:0:0:5: Attached scsi generic sg2 type 0
[   23.832081] sd 0:0:0:5: [sdb] 15625000960 512-byte logical blocks:
(8.00 TB/7.27 TiB)
[   23.833236] sd 0:0:0:5: [sdb] Write Protect is off
[   23.833238] sd 0:0:0:5: [sdb] Mode Sense: 97 00 00 08
[   23.833753] sd 0:0:0:5: [sdb] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[   23.836151]  sdb: unknown partition table
[   24.202024] scsi 0:0:0:6: Direct-Access     NEXSAN   SATABeast2
 Nf66 PQ: 0 ANSI: 5
[   24.203921] sd 0:0:0:5: [sdb] Attached SCSI disk
[   24.353990] sd 0:0:0:6: Attached scsi generic sg3 type 0
[   24.354946] sd 0:0:0:6: [sdc] 15625000960 512-byte logical blocks:
(8.00 TB/7.27 TiB)
[   24.356107] sd 0:0:0:6: [sdc] Write Protect is off
[   24.356108] sd 0:0:0:6: [sdc] Mode Sense: 97 00 00 08
[   24.356626] sd 0:0:0:6: [sdc] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[   24.359012]  sdc: unknown partition table
[   24.724892] scsi 0:0:0:7: Direct-Access     NEXSAN   SATABeast2
 Nf66 PQ: 0 ANSI: 5
[   24.726783] sd 0:0:0:6: [sdc] Attached SCSI disk
[   24.876872] sd 0:0:0:7: Attached scsi generic sg4 type 0
[   24.877827] sd 0:0:0:7: [sdd] 3911623680 512-byte logical blocks:
(2.00 TB/1.82 TiB)
[   24.878985] sd 0:0:0:7: [sdd] Write Protect is off
[   24.878987] sd 0:0:0:7: [sdd] Mode Sense: 97 00 00 08
[   24.879504] sd 0:0:0:7: [sdd] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[   24.881895]  sdd: unknown partition table
[   25.248713] sd 0:0:0:7: [sdd] Attached SCSI disk
[   27.364259] usb-storage: device scan complete
[   27.371257] scsi 1:0:0:0: CD-ROM            AMI      Virtual CDROM
 1.00 PQ: 0 ANSI: 0 CCS
[   27.472544] scsi 1:0:0:0: Attached scsi generic sg5 type 5
[   27.586244] sr0: scsi-1 drive
[   27.621764] sr 1:0:0:0: Attached scsi CD-ROM sr0
[   27.808482] scsi3 : ioc0: LSISAS1064 A3, FwRev=01102800h, Ports=1,
MaxQ=511, IRQ=56
[   27.925397] mptsas: ioc0: attaching ssp device: fw_channel 0, fw_id
4, phy 0, sas_addr 0x5000cca000146e99
[   28.041314] scsi 3:0:0:0: Direct-Access     HITACHI  H101414SCSUN146G
SA23 PQ: 0 ANSI: 5
[   28.141216] scsi 3:0:0:0: Attached scsi generic sg6 type 0
[   28.209102] mptsas: ioc0: attaching ssp device: fw_channel 0, fw_id
1, phy 1, sas_addr 0x5000cca000150b49
[   28.324930] scsi 3:0:1:0: Direct-Access     HITACHI  H101414SCSUN146G
SA23 PQ: 0 ANSI: 5
[   28.424397] scsi 3:0:1:0: Attached scsi generic sg7 type 0
[   28.492157] mptsas: ioc0: attaching raid volume, channel 1, id 0
[   28.565120] scsi 3:1:0:0: Direct-Access     LSILOGIC Logical Volume
 3000 PQ: 0 ANSI: 2
[   28.670730] sd 3:1:0:0: Attached scsi generic sg8 type 0
[   28.734497] sd 3:1:0:0: [sde] 285155328 512-byte logical blocks: (145
GB/135 GiB)
[   28.824241] sd 3:1:0:0: [sde] Write Protect is off
[   28.881460] sd 3:1:0:0: [sde] Mode Sense: 03 00 00 08
[   28.881963] sd 3:1:0:0: [sde] Write cache: disabled, read cache:
enabled, doesn't support DPO or FUA
[   28.992459]  sde: sde1 sde2
[   29.047216] sd 3:1:0:0: [sde] Attached SCSI disk
[   29.179075] usb-storage: device scan complete
[   29.204253] scsi 2:0:0:0: Direct-Access     AMI      Virtual Floppy
 1.00 PQ: 0 ANSI: 0 CCS
[   29.305544] sd 2:0:0:0: Attached scsi generic sg9 type 0
[   29.492250] sd 2:0:0:0: [sdf] Attached SCSI removable disk
[   29.767210] kjournald starting.  Commit interval 5 seconds
[   29.767212] EXT3-fs: mounted filesystem with writeback data mode.
[   31.856893] input: Power Button as /class/input/input3
[   31.860539] processor LNXCPU:00: registered as cooling_device0
[   31.861100] processor LNXCPU:01: registered as cooling_device1
[   31.861600] processor LNXCPU:02: registered as cooling_device2
[   31.862105] processor LNXCPU:03: registered as cooling_device3
[   31.862612] processor LNXCPU:04: registered as cooling_device4
[   31.863135] processor LNXCPU:05: registered as cooling_device5
[   31.863654] processor LNXCPU:06: registered as cooling_device6
[   31.864160] processor LNXCPU:07: registered as cooling_device7
[   31.864657] processor LNXCPU:08: registered as cooling_device8
[   31.865167] processor LNXCPU:09: registered as cooling_device9
[   31.865678] processor LNXCPU:0a: registered as cooling_device10
[   31.866180] processor LNXCPU:0b: registered as cooling_device11
[   31.866695] processor LNXCPU:0c: registered as cooling_device12
[   31.867221] processor LNXCPU:0d: registered as cooling_device13
[   31.867732] processor LNXCPU:0e: registered as cooling_device14
[   31.868240] processor LNXCPU:0f: registered as cooling_device15
[   32.070000] input: PC Speaker as /class/input/input4
[   33.099000] ACPI: Power Button [PWRB]
[   33.142798] input: Power Button as /class/input/input5
[   33.158542] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   33.161090] shpchp 0000:00:10.0: HPC vendor_id 1022 device_id 7458
ss_vid 0 ss_did 0
[   33.161095] shpchp 0000:00:10.0: Cannot reserve MMIO region
[   33.161141] shpchp 0000:00:11.0: HPC vendor_id 1022 device_id 7458
ss_vid 0 ss_did 0
[   33.161143] shpchp 0000:00:11.0: Cannot reserve MMIO region
[   33.161192] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   33.166357] k8temp 0000:00:18.3: Temperature readouts might be wrong
- check erratum #141
[   33.166552] k8temp 0000:00:19.3: Temperature readouts might be wrong
- check erratum #141
[   33.167024] k8temp 0000:00:1a.3: Temperature readouts might be wrong
- check erratum #141
[   33.167322] k8temp 0000:00:1b.3: Temperature readouts might be wrong
- check erratum #141
[   33.167449] k8temp 0000:00:1c.3: Temperature readouts might be wrong
- check erratum #141
[   33.167574] k8temp 0000:00:1d.3: Temperature readouts might be wrong
- check erratum #141
[   34.255733] k8temp 0000:00:1e.3: Temperature readouts might be wrong
- check erratum #141
[   34.258963] ACPI: Power Button [PWRF]
[   34.280290] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
version 2.0.44-k2
[   34.280293] ixgbe: Copyright (c) 1999-2009 Intel Corporation.
[   34.281645] ACPI: PCI Interrupt Link [LN2A] enabled at IRQ 43
[   34.281676] ixgbe 0000:82:00.0: PCI INT A -> Link[LN2A] -> GSI 43
(level, low) -> IRQ 43
[   34.281692] ixgbe 0000:82:00.0: setting latency timer to 64
[   34.725294] k8temp 0000:00:1f.3: Temperature readouts might be wrong
- check erratum #141
[   34.823358] i2c i2c-0: nForce2 SMBus adapter at 0x6000
[   34.885019] i2c i2c-1: nForce2 SMBus adapter at 0x6040
[   34.996671] ixgbe 0000:82:00.0: irq 72 for MSI/MSI-X
[   34.996674] ixgbe 0000:82:00.0: irq 73 for MSI/MSI-X
[   34.996676] ixgbe 0000:82:00.0: irq 74 for MSI/MSI-X
[   34.996679] ixgbe 0000:82:00.0: irq 75 for MSI/MSI-X
[   34.996681] ixgbe 0000:82:00.0: irq 76 for MSI/MSI-X
[   34.996683] ixgbe 0000:82:00.0: irq 77 for MSI/MSI-X
[   34.996686] ixgbe 0000:82:00.0: irq 78 for MSI/MSI-X
[   34.996688] ixgbe 0000:82:00.0: irq 79 for MSI/MSI-X
[   34.996690] ixgbe 0000:82:00.0: irq 80 for MSI/MSI-X
[   34.996692] ixgbe 0000:82:00.0: irq 81 for MSI/MSI-X
[   34.996694] ixgbe 0000:82:00.0: irq 82 for MSI/MSI-X
[   34.996697] ixgbe 0000:82:00.0: irq 83 for MSI/MSI-X
[   34.996699] ixgbe 0000:82:00.0: irq 84 for MSI/MSI-X
[   34.996701] ixgbe 0000:82:00.0: irq 85 for MSI/MSI-X
[   34.996703] ixgbe 0000:82:00.0: irq 86 for MSI/MSI-X
[   34.996706] ixgbe 0000:82:00.0: irq 87 for MSI/MSI-X
[   34.996708] ixgbe 0000:82:00.0: irq 88 for MSI/MSI-X
[   34.996710] ixgbe 0000:82:00.0: irq 89 for MSI/MSI-X
[   34.996738] ixgbe: 0000:82:00.0: ixgbe_init_interrupt_scheme:
Multiqueue Enabled: Rx Queue count = 16, Tx Queue count = 16
[   35.128844] ixgbe 0000:82:00.0: (PCI Express:2.5Gb/s:Width x4)
00:1b:21:4b:c8:9b
[   35.217332] ixgbe 0000:82:00.0: MAC: 1, PHY: 1, PBA No: e73052-002
[   35.291183] ixgbe 0000:82:00.0: PCI-Express bandwidth available for
this card is not sufficient for optimal performance.
[   35.421196] ixgbe 0000:82:00.0: For optimal performance a x8
PCI-Express slot is required.
[   35.520611] ixgbe 0000:82:00.0: Intel(R) 10 Gigabit Network Connection
[   35.599018] ACPI: PCI Interrupt Link [LN2D] enabled at IRQ 42
[   35.667675] ixgbe 0000:83:00.0: PCI INT A -> Link[LN2D] -> GSI 42
(level, low) -> IRQ 42
[   35.764412] ixgbe 0000:83:00.0: setting latency timer to 64
[   35.832194] ixgbe 0000:83:00.0: irq 90 for MSI/MSI-X
[   35.832197] ixgbe 0000:83:00.0: irq 91 for MSI/MSI-X
[   35.832199] ixgbe 0000:83:00.0: irq 92 for MSI/MSI-X
[   35.832201] ixgbe 0000:83:00.0: irq 93 for MSI/MSI-X
[   35.832204] ixgbe 0000:83:00.0: irq 94 for MSI/MSI-X
[   35.832206] ixgbe 0000:83:00.0: irq 95 for MSI/MSI-X
[   35.832208] ixgbe 0000:83:00.0: irq 96 for MSI/MSI-X
[   35.832210] ixgbe 0000:83:00.0: irq 97 for MSI/MSI-X
[   35.832213] ixgbe 0000:83:00.0: irq 98 for MSI/MSI-X
[   35.832215] ixgbe 0000:83:00.0: irq 99 for MSI/MSI-X
[   35.832217] ixgbe 0000:83:00.0: irq 100 for MSI/MSI-X
[   35.832219] ixgbe 0000:83:00.0: irq 101 for MSI/MSI-X
[   35.832222] ixgbe 0000:83:00.0: irq 102 for MSI/MSI-X
[   35.832224] ixgbe 0000:83:00.0: irq 103 for MSI/MSI-X
[   35.832226] ixgbe 0000:83:00.0: irq 104 for MSI/MSI-X
[   35.832229] ixgbe 0000:83:00.0: irq 105 for MSI/MSI-X
[   35.832231] ixgbe 0000:83:00.0: irq 106 for MSI/MSI-X
[   35.832233] ixgbe 0000:83:00.0: irq 107 for MSI/MSI-X
[   35.832254] ixgbe: 0000:83:00.0: ixgbe_init_interrupt_scheme:
Multiqueue Enabled: Rx Queue count = 16, Tx Queue count = 16
[   35.964352] ixgbe 0000:83:00.0: (PCI Express:2.5Gb/s:Width x8)
00:1b:21:34:ee:9a
[   36.052838] ixgbe 0000:83:00.0: MAC: 1, PHY: 3, PBA No: e18269-001
[   36.127154] ixgbe 0000:83:00.0: Intel(R) 10 Gigabit Network Connection
[   36.128555] udev: renamed network interface eth5 to eth6
[   36.268962] ACPI: PCI Interrupt Link [LN2C] enabled at IRQ 41
[   36.337623] ixgbe 0000:84:00.0: PCI INT A -> Link[LN2C] -> GSI 41
(level, low) -> IRQ 41
[   36.434373] ixgbe 0000:84:00.0: setting latency timer to 64
[   36.500394] ixgbe 0000:84:00.0: irq 108 for MSI/MSI-X
[   36.500396] ixgbe 0000:84:00.0: irq 109 for MSI/MSI-X
[   36.500398] ixgbe 0000:84:00.0: irq 110 for MSI/MSI-X
[   36.500401] ixgbe 0000:84:00.0: irq 111 for MSI/MSI-X
[   36.500403] ixgbe 0000:84:00.0: irq 112 for MSI/MSI-X
[   36.500405] ixgbe 0000:84:00.0: irq 113 for MSI/MSI-X
[   36.500407] ixgbe 0000:84:00.0: irq 114 for MSI/MSI-X
[   36.500409] ixgbe 0000:84:00.0: irq 115 for MSI/MSI-X
[   36.500412] ixgbe 0000:84:00.0: irq 116 for MSI/MSI-X
[   36.500414] ixgbe 0000:84:00.0: irq 117 for MSI/MSI-X
[   36.500416] ixgbe 0000:84:00.0: irq 118 for MSI/MSI-X
[   36.500418] ixgbe 0000:84:00.0: irq 119 for MSI/MSI-X
[   36.500420] ixgbe 0000:84:00.0: irq 120 for MSI/MSI-X
[   36.500423] ixgbe 0000:84:00.0: irq 121 for MSI/MSI-X
[   36.500425] ixgbe 0000:84:00.0: irq 122 for MSI/MSI-X
[   36.500427] ixgbe 0000:84:00.0: irq 123 for MSI/MSI-X
[   36.500429] ixgbe 0000:84:00.0: irq 124 for MSI/MSI-X
[   36.500431] ixgbe 0000:84:00.0: irq 125 for MSI/MSI-X
[   36.500454] ixgbe: 0000:84:00.0: ixgbe_init_interrupt_scheme:
Multiqueue Enabled: Rx Queue count = 16, Tx Queue count = 16
[   36.632551] ixgbe 0000:84:00.0: (PCI Express:2.5Gb/s:Width x8)
00:1b:21:4b:c8:b1
[   36.721033] ixgbe 0000:84:00.0: MAC: 1, PHY: 1, PBA No: e73052-002
[   36.795405] ixgbe 0000:84:00.0: Intel(R) 10 Gigabit Network Connection
[   36.796641] udev: renamed network interface eth5 to eth8
[   36.939270] udev: renamed network interface eth4 to eth7
[   37.156916] loop: module loaded
[   37.223422] lp: driver loaded but no devices found
[   37.536852] Adding 31246416k swap on /dev/sde1.  Priority:-1
extents:1 across:31246416k
[   37.774048] EXT3 FS on sde2, internal journal
[   37.866485] Loading iSCSI transport class v2.0-870.
[   37.890303] iscsi: registered transport (tcp)
[   37.941049] NET: Registered protocol family 10
[   37.941868] lo: Disabled Privacy Extensions
[   37.991415] iscsi: registered transport (iser)
[   39.154043] EXT4-fs (sdb): mounted filesystem with ordered data mode
[   39.621853] EXT4-fs (sdc): warning: mounting fs with errors, running
e2fsck is recommended
[   39.843059] EXT4-fs (sdc): mounted filesystem with ordered data mode
[   39.965493] kjournald starting.  Commit interval 5 seconds
[   39.966733] EXT3 FS on sdd, internal journal
[   39.966739] EXT3-fs: mounted filesystem with writeback data mode.
[   44.189320] ip_tables: (C) 2000-2006 Netfilter Core Team
[   44.248301] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
[   44.248310] bonding: MII link monitoring set to 100 ms
[   44.253133] ADDRCONF(NETDEV_UP): bond0: link is not ready
[   44.670362] bonding: bond0: enslaving eth7 as a backup interface with
a down link.
[   45.082294] bonding: bond0: enslaving eth8 as a backup interface with
a down link.
[   49.586682] ixgbe: eth8 NIC Link is Up 10 Gbps, Flow Control: None
[   49.646677] bonding: bond0: link status definitely up for interface eth8.
[   49.650146] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[   53.325580] RPC: Registered udp transport module.
[   53.325583] RPC: Registered tcp transport module.
[   53.325585] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   53.469713] ixgbe: eth7 NIC Link is Up 10 Gbps, Flow Control: None
[   53.546605] bonding: bond0: link status definitely up for interface eth7.
[   55.836193] warning: `named' uses 32-bit capabilities (legacy support
in use)
[   57.840835] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   57.881306] svc: failed to register lockdv1 RPC service (errno 97).
[   57.882023] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state
recovery directory
[   57.889030] NFSD: starting 90-second grace period
[   59.236421] ipmi message handler version 39.2
[   60.602473] bond0: no IPv6 routers present
[ 1778.485939] nfs: server hest not responding, still trying
[ 1779.281922] nfs: server hest not responding, still trying
[ 1786.901829] nfs: server hest not responding, still trying
[ 1788.805807] nfs: server hest not responding, still trying
[ 1819.605443] nfs: server hest not responding, still trying
[ 1819.617434] nfs: server hest not responding, still trying
[ 1819.617450] nfs: server hest not responding, still trying
[ 1819.617458] nfs: server hest not responding, still trying
[ 1820.249427] nfs: server hest not responding, still trying
[ 1823.569386] nfs: server hest not responding, still trying
[ 1825.213365] nfs: server hest not responding, still trying
[ 1833.779042] nfs: server hest OK
[ 1833.779146] nfs: server hest OK
[ 1833.779196] nfs: server hest OK
[ 1833.780481] nfs: server hest OK
[ 1833.780588] nfs: server hest OK
[ 1833.783157] nfs: server hest OK
[ 2056.538398] INFO: task nfsd:6779 blocked for more than 120 seconds.
[ 2056.613319] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 2056.706960] nfsd          D ffff880f11e0df08     0  6779      2
0x00000000
[ 2056.706964]  ffff8804fe482a70 0000000000000046 0000000000000000
ffffffff8106688d
[ 2056.706967]  ffff8804fbd5bfd8 ffff8804fbd68000 0000000000004000
000000000000df08
[ 2056.706970]  00000000000135c0 ffff8804fbd5bfd8 ffff8804fbd5bfd8
00000000000135c0
[ 2056.706973] Call Trace:
[ 2056.706983]  [<ffffffff8106688d>] ? set_groups+0x1d/0x1c0
[ 2056.706990]  [<ffffffff812ea212>] ? __mutex_lock_slowpath+0xc2/0x140
[ 2056.707020]  [<ffffffffa0490360>] ? svc_recvfrom+0x60/0xa0 [sunrpc]
[ 2056.707023]  [<ffffffff812ea0a3>] ? mutex_lock+0x23/0x50
[ 2056.707042]  [<ffffffffa056a76c>] ? nfsd_unlink+0x13c/0x2f0 [nfsd]
[ 2056.707049]  [<ffffffffa057394f>] ? nfsd3_proc_remove+0x7f/0x100 [nfsd]
[ 2056.707055]  [<ffffffffa0566331>] ? nfsd_dispatch+0xb1/0x240 [nfsd]
[ 2056.707063]  [<ffffffffa048eef3>] ? svc_process+0x493/0x7f0 [sunrpc]
[ 2056.707068]  [<ffffffff8103b470>] ? default_wake_function+0x0/0x10
[ 2056.707072]  [<ffffffff812eaf92>] ? __down_read+0x12/0xad
[ 2056.707076]  [<ffffffffa05667e0>] ? nfsd+0x0/0x140 [nfsd]
[ 2056.707081]  [<ffffffffa056688f>] ? nfsd+0xaf/0x140 [nfsd]
[ 2056.707085]  [<ffffffff81060626>] ? kthread+0x96/0xa0
[ 2056.707088]  [<ffffffff8100cc5a>] ? child_rip+0xa/0x20
[ 2056.707093]  [<ffffffff81025230>] ? physflat_send_IPI_mask+0x0/0x10
[ 2056.707095]  [<ffffffff81060590>] ? kthread+0x0/0xa0
[ 2056.707097]  [<ffffffff8100cc50>] ? child_rip+0x0/0x20
[ 2056.707101] INFO: task nfsd:6790 blocked for more than 120 seconds.
[ 2056.782013] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 2056.875650] nfsd          D ffff880f11f0df08     0  6790      2
0x00000000
[ 2056.875653]  ffff8804fe4842b0 0000000000000046 0000000000000000
ffffffff8106688d
[ 2056.875656]  ffff8804fbd81fd8 ffff8804fbd6c2b0 0000000000004000
000000000000df08
[ 2056.875658]  00000000000135c0 ffff8804fbd81fd8 ffff8804fbd81fd8
00000000000135c0
[ 2056.875661] Call Trace:
[ 2056.875663]  [<ffffffff8106688d>] ? set_groups+0x1d/0x1c0
[ 2056.875666]  [<ffffffff812ea212>] ? __mutex_lock_slowpath+0xc2/0x140
[ 2056.875674]  [<ffffffffa0490360>] ? svc_recvfrom+0x60/0xa0 [sunrpc]
[ 2056.875677]  [<ffffffff812ea0a3>] ? mutex_lock+0x23/0x50
[ 2056.875682]  [<ffffffffa056a76c>] ? nfsd_unlink+0x13c/0x2f0 [nfsd]
[ 2056.875688]  [<ffffffffa057394f>] ? nfsd3_proc_remove+0x7f/0x100 [nfsd]
[ 2056.875693]  [<ffffffffa0566331>] ? nfsd_dispatch+0xb1/0x240 [nfsd]
[ 2056.875701]  [<ffffffffa048eef3>] ? svc_process+0x493/0x7f0 [sunrpc]
[ 2056.875704]  [<ffffffff8103b470>] ? default_wake_function+0x0/0x10
[ 2056.875706]  [<ffffffff812eaf92>] ? __down_read+0x12/0xad
[ 2056.875711]  [<ffffffffa05667e0>] ? nfsd+0x0/0x140 [nfsd]
[ 2056.875715]  [<ffffffffa056688f>] ? nfsd+0xaf/0x140 [nfsd]
[ 2056.875718]  [<ffffffff81060626>] ? kthread+0x96/0xa0
[ 2056.875720]  [<ffffffff8100cc5a>] ? child_rip+0xa/0x20
[ 2056.875722]  [<ffffffff81025230>] ? physflat_send_IPI_mask+0x0/0x10
[ 2056.875725]  [<ffffffff81060590>] ? kthread+0x0/0xa0
[ 2056.875727]  [<ffffffff8100cc50>] ? child_rip+0x0/0x20
[ 2162.745354] ixgbe: eth7: ixgbe_check_tx_hang: Detected Tx Unit Hang
[ 2162.745356]   Tx Queue             <4>
[ 2162.745356]   TDH, TDT             <e1>, <cc>
[ 2162.745357]   next_to_use          <cc>
[ 2162.745358]   next_to_clean        <e1>
[ 2162.745359] tx_buffer_info[next_to_clean]
[ 2162.745359]   time_stamp           <1000713d3>
[ 2162.745360]   jiffies              <10007152e>
[ 2163.162478] ixgbe: eth7: ixgbe_clean_tx_irq: tx hang 1 detected,
resetting adapter
[ 2163.357333] bonding: bond0: link status definitely down for interface
eth7, disabling it
[ 2168.670342] ixgbe: eth7 NIC Link is Up 10 Gbps, Flow Control: None
[ 2168.757248] bonding: bond0: link status definitely up for interface eth7.
