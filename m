From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Recursive locking detected in nfsd4 in 2.6.28-todaysgit?
Date: Thu, 8 Jan 2009 13:02:17 -0500
Message-ID: <20090108180217.GA17623@fieldses.org>
References: <49657273.60503@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Petr Vandrovec <petr@vmware.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60262 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094AbZAHSCT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 13:02:19 -0500
In-Reply-To: <49657273.60503@vmware.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 07, 2009 at 07:26:43PM -0800, Petr Vandrovec wrote:
> Hello,
>   should I be worried by these messages?  Both nfs & nfsd seems to work, 
> but on other side messages about nfsd4 being hung in D state for more 
> than 480 seconds look suspicious.

This should be fixed in Linus's tree as of today; if not, let us know.

--b.

>
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.28-64-06887-g85390a8-dirty #4
> ---------------------------------------------
> nfsd4/4336 is trying to acquire lock:
>  (&type->i_mutex_dir_key#2){--..}, at: [<ffffffff8031ca24>]  
> vfs_fsync+0x84/0x100
>
> but task is already holding lock:
>  (&type->i_mutex_dir_key#2){--..}, at: [<ffffffffa102a20d>]  
> nfsd4_sync_rec_dir+0x1d/0x50 [nfsd]
>
> other info that might help us debug this:
> 4 locks held by nfsd4/4336:
>  #0:  (nfsd4){--..}, at: [<ffffffff802628d3>] run_workqueue+0xb3/0x250
>  #1:  ((laundromat_work).work){--..}, at: [<ffffffff802628d3>]  
> run_workqueue+0xb3/0x250
>  #2:  (client_mutex){--..}, at: [<ffffffffa1024d6e>]  
> laundromat_main+0x2e/0x300 [nfsd]
>  #3:  (&type->i_mutex_dir_key#2){--..}, at: [<ffffffffa102a20d>]  
> nfsd4_sync_rec_dir+0x1d/0x50 [nfsd]
>
> ...
>
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>
> 					Thanks,
> 						Petr
>

> Initializing cgroup subsys cpuset
> Linux version 2.6.28-64-06887-g85390a8-dirty (root@petr-dev3) (gcc version 4.3.2 (Debian 4.3.2-1) ) #4 SMP PREEMPT Wed Jan 7 09:59:22 PST 2009
> Command line: auto BOOT_IMAGE=Linux ro root=805 video=atyfb:1600x1200-16@60
> KERNEL supported cpus:
>   Intel GenuineIntel
>   AMD AuthenticAMD
>   Centaur CentaurHauls
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
>  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
>  BIOS-e820: 00000000000e8000 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 00000000cfff0000 (usable)
>  BIOS-e820: 00000000cfff0000 - 00000000cffff000 (ACPI data)
>  BIOS-e820: 00000000cffff000 - 00000000d0000000 (ACPI NVS)
>  BIOS-e820: 00000000ff780000 - 0000000100000000 (reserved)
>  BIOS-e820: 0000000100000000 - 0000000126000000 (usable)
> DMI 2.3 present.
> AMI BIOS detected: BIOS may corrupt low RAM, working it around.
> last_pfn = 0x126000 max_arch_pfn = 0x100000000
> x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
> last_pfn = 0xcfff0 max_arch_pfn = 0x100000000
> Scanning 0 areas for low memory corruption
> modified physical RAM map:
>  modified: 0000000000000000 - 0000000000010000 (reserved)
>  modified: 0000000000010000 - 000000000009fc00 (usable)
>  modified: 000000000009fc00 - 00000000000a0000 (reserved)
>  modified: 00000000000e8000 - 0000000000100000 (reserved)
>  modified: 0000000000100000 - 00000000cfff0000 (usable)
>  modified: 00000000cfff0000 - 00000000cffff000 (ACPI data)
>  modified: 00000000cffff000 - 00000000d0000000 (ACPI NVS)
>  modified: 00000000ff780000 - 0000000100000000 (reserved)
>  modified: 0000000100000000 - 0000000126000000 (usable)
> init_memory_mapping: 0000000000000000-00000000cfff0000
>  0000000000 - 00cfe00000 page 2M
>  00cfe00000 - 00cfff0000 page 4k
> kernel direct mapping tables up to cfff0000 @ 10000-16000
> last_map_addr: cfff0000 end: cfff0000
> init_memory_mapping: 0000000100000000-0000000126000000
>  0100000000 - 0126000000 page 2M
> kernel direct mapping tables up to 126000000 @ 14000-1a000
> last_map_addr: 126000000 end: 126000000
> ACPI: RSDP 000F9870, 0024 (r2 ACPIAM)
> ACPI: XSDT CFFF0100, 0044 (r1 A M I  OEMXSDT   5000622 MSFT       97)
> ACPI: FACP CFFF0281, 00F4 (r3 A M I  OEMFACP   5000622 MSFT       97)
> ACPI: DSDT CFFF0460, 3470 (r1  H8DA8 H8DA8010        0 INTL  2002026)
> ACPI: FACS CFFFF000, 0040
> ACPI: APIC CFFF0380, 0084 (r1 A M I  OEMAPIC   5000622 MSFT       97)
> ACPI: OEMB CFFFF040, 0041 (r1 A M I  OEMBIOS   5000622 MSFT       97)
> ACPI: SRAT CFFF38D0, 0110 (r1 A M I  OEMSRAT   5000622 MSFT       97)
> ACPI: Local APIC address 0xfee00000
> SRAT: PXM 0 -> APIC 0 -> Node 0
> SRAT: PXM 0 -> APIC 1 -> Node 0
> SRAT: PXM 1 -> APIC 2 -> Node 1
> SRAT: PXM 1 -> APIC 3 -> Node 1
> SRAT: Node 0 PXM 0 100000-80000000
> SRAT: Node 1 PXM 1 80000000-d0000000
> SRAT: Node 1 PXM 1 100000000-126000000
> SRAT: Node 0 PXM 0 0-9fc00
> NUMA: Allocated memnodemap from 15000 - 17500
> NUMA: Using 20 for the hash shift.
> Bootmem setup node 0 0000000000000000-0000000080000000
>   NODE_DATA [0000000000017500 - 000000000004b4ff]
>   bootmap [000000000004c000 -  000000000005bfff] pages 10
> (7 early reservations) ==> bootmem [0000000000 - 0080000000]
>   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
>   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
>   #2 [0000200000 - 0001416b38]    TEXT DATA BSS ==> [0000200000 - 0001416b38]
>   #3 [000009f800 - 0000100000]    BIOS reserved ==> [000009f800 - 0000100000]
>   #4 [0000010000 - 0000014000]          PGTABLE ==> [0000010000 - 0000014000]
>   #5 [0000014000 - 0000015000]          PGTABLE ==> [0000014000 - 0000015000]
>   #6 [0000015000 - 0000017500]       MEMNODEMAP ==> [0000015000 - 0000017500]
> Bootmem setup node 1 0000000080000000-0000000126000000
>   NODE_DATA [0000000080000000 - 0000000080033fff]
>   bootmap [0000000080034000 -  0000000080048bff] pages 15
> (7 early reservations) ==> bootmem [0080000000 - 0126000000]
>   #0 [0000000000 - 0000001000]   BIOS data page
>   #1 [0000006000 - 0000008000]       TRAMPOLINE
>   #2 [0000200000 - 0001416b38]    TEXT DATA BSS
>   #3 [000009f800 - 0000100000]    BIOS reserved
>   #4 [0000010000 - 0000014000]          PGTABLE
>   #5 [0000014000 - 0000015000]          PGTABLE
>   #6 [0000015000 - 0000017500]       MEMNODEMAP
> found SMP MP-table at [ffff8800000ff780] 000ff780
>  [ffffe20000000000-ffffe200033fffff] PMD -> [ffff880001600000-ffff8800049fffff] on node 0
>  [ffffe20003400000-ffffe200079fffff] PMD -> [ffff880080200000-ffff8800835fffff] on node 1
> Zone PFN ranges:
>   DMA      0x00000010 -> 0x00001000
>   DMA32    0x00001000 -> 0x00100000
>   Normal   0x00100000 -> 0x00126000
> Movable zone start PFN for each node
> early_node_map[4] active PFN ranges
>     0: 0x00000010 -> 0x0000009f
>     0: 0x00000100 -> 0x00080000
>     1: 0x00080000 -> 0x000cfff0
>     1: 0x00100000 -> 0x00126000
> On node 0 totalpages: 524175
>   DMA zone: 104 pages used for memmap
>   DMA zone: 108 pages reserved
>   DMA zone: 3771 pages, LIFO batch:0
>   DMA32 zone: 13208 pages used for memmap
>   DMA32 zone: 506984 pages, LIFO batch:31
> On node 1 totalpages: 483312
>   DMA32 zone: 13312 pages used for memmap
>   DMA32 zone: 314352 pages, LIFO batch:31
>   Normal zone: 3952 pages used for memmap
>   Normal zone: 151696 pages, LIFO batch:31
> ACPI: PM-Timer IO Port: 0x5008
> ACPI: Local APIC address 0xfee00000
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
> ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
> ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
> ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 4, version 0, address 0xfec00000, GSI 0-23
> ACPI: IOAPIC (id[0x05] address[0xfebfe000] gsi_base[24])
> IOAPIC[1]: apic_id 5, version 0, address 0xfebfe000, GSI 24-27
> ACPI: IOAPIC (id[0x06] address[0xfebff000] gsi_base[28])
> IOAPIC[2]: apic_id 6, version 0, address 0xfebff000, GSI 28-31
> ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> ACPI: IRQ0 used by override.
> ACPI: IRQ2 used by override.
> ACPI: IRQ9 used by override.
> Using ACPI (MADT) for SMP configuration information
> SMP: Allowing 4 CPUs, 0 hotplug CPUs
> Allocating PCI resources starting at d4000000 (gap: d0000000:2f780000)
> NR_CPUS:4096 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:2
> PERCPU: Allocating 1892352 bytes of per cpu data
> Built 2 zonelists in Node order, mobility grouping on.  Total pages: 976803
> Policy zone: Normal
> Kernel command line: auto BOOT_IMAGE=Linux ro root=805 video=atyfb:1600x1200-16@60
> Initializing CPU#0
> Preemptible RCU implementation.
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> Extended CMOS year: 2000
> Fast TSC calibration using PIT
> Detected 1994.552 MHz processor.
> Console: colour VGA+ 80x25
> console [tty0] enabled
> Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> ... MAX_LOCKDEP_SUBCLASSES:  8
> ... MAX_LOCK_DEPTH:          48
> ... MAX_LOCKDEP_KEYS:        8191
> ... CLASSHASH_SIZE:          4096
> ... MAX_LOCKDEP_ENTRIES:     8192
> ... MAX_LOCKDEP_CHAINS:      16384
> ... CHAINHASH_SIZE:          8192
>  memory used by lock dependency info: 4351 kB
>  per task-struct memory footprint: 2688 bytes
> allocated 40632320 bytes of page_cgroup
> please try cgroup_disable=memory option if you don't want
> Checking aperture...
> No AGP bridge found
> Node 0: aperture @ da000000 size 32 MB
> Aperture too small (32 MB) than (64 MB)
> Your BIOS doesn't leave a aperture memory hole
> Please enable the IOMMU option in the BIOS setup
> This costs you 64 MB of RAM
> Mapping aperture over 65536 KB of RAM @ 20000000
> Memory: 3790436k/4816896k available (3843k kernel code, 786948k absent, 239512k reserved, 2813k data, 2428k init)
> SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=2
> Calibrating delay loop (skipped), value calculated using timer frequency.. 3989.10 BogoMIPS (lpj=19945520)
> Security Framework initialized
> SELinux:  Disabled at boot.
> Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
> Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
> Mount-cache hash table entries: 256
> Initializing cgroup subsys debug
> Initializing cgroup subsys ns
> Initializing cgroup subsys cpuacct
> Initializing cgroup subsys memory
> Initializing cgroup subsys devices
> Initializing cgroup subsys freezer
> Initializing cgroup subsys net_cls
> CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> CPU: L2 Cache: 1024K (64 bytes/line)
> CPU 0/0x0 -> Node 0
> tseg: 0000000000
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 0
> ACPI: Core revision 20080926
> Setting APIC routing to flat
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
> ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
> CPU0: Dual Core AMD Opteron(tm) Processor 270 stepping 02
> lockdep: fixing up alternatives.
> Booting processor 1 APIC 0x1 ip 0x6000
> Initializing CPU#1
> Calibrating delay using timer specific routine.. 3988.73 BogoMIPS (lpj=19943673)
> CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> CPU: L2 Cache: 1024K (64 bytes/line)
> CPU 1/0x1 -> Node 0
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 1
> x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
> CPU1: Dual Core AMD Opteron(tm) Processor 270 stepping 02
> lockdep: fixing up alternatives.
> Booting processor 2 APIC 0x2 ip 0x6000
> Initializing CPU#2
> Calibrating delay using timer specific routine.. 3988.74 BogoMIPS (lpj=19943723)
> CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> CPU: L2 Cache: 1024K (64 bytes/line)
> CPU 2/0x2 -> Node 1
> CPU: Physical Processor ID: 1
> CPU: Processor Core ID: 0
> x86 PAT enabled: cpu 2, old 0x7040600070406, new 0x7010600070106
> CPU2: Dual Core AMD Opteron(tm) Processor 270 stepping 02
> lockdep: fixing up alternatives.
> Booting processor 3 APIC 0x3 ip 0x6000
> Initializing CPU#3
> Calibrating delay using timer specific routine.. 3988.74 BogoMIPS (lpj=19943735)
> CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> CPU: L2 Cache: 1024K (64 bytes/line)
> CPU 3/0x3 -> Node 1
> CPU: Physical Processor ID: 1
> CPU: Processor Core ID: 1
> x86 PAT enabled: cpu 3, old 0x7040600070406, new 0x7010600070106
> CPU3: Dual Core AMD Opteron(tm) Processor 270 stepping 02
> Brought up 4 CPUs
> Total of 4 processors activated (15955.33 BogoMIPS).
> CPU0 attaching sched-domain:
>  domain 0: span 0-1 level CPU
>   groups: 0 1
>   domain 1: span 0-3 level NODE
>    groups: 0-1 2-3
> CPU1 attaching sched-domain:
>  domain 0: span 0-1 level CPU
>   groups: 1 0
>   domain 1: span 0-3 level NODE
>    groups: 0-1 2-3
> CPU2 attaching sched-domain:
>  domain 0: span 2-3 level CPU
>   groups: 2 3
>   domain 1: span 0-3 level NODE
>    groups: 2-3 0-1
> CPU3 attaching sched-domain:
>  domain 0: span 2-3 level CPU
>   groups: 3 2
>   domain 1: span 0-3 level NODE
>    groups: 2-3 0-1
> net_namespace: 2160 bytes
> NET: Registered protocol family 16
> node 0 link 2: io port [1000, ffffff]
> TOM: 00000000d0000000 aka 3328M
> node 0 link 2: mmio [a0000, bffff]
> node 0 link 2: mmio [d0000000, ffffffff]
> TOM2: 0000000126000000 aka 4704M
> bus: [00,ff] on node 0 link 2
> bus: 00 index 0 io port: [0, ffff]
> bus: 00 index 1 mmio: [a0000, bffff]
> bus: 00 index 2 mmio: [d0000000, ffffffff]
> bus: 00 index 3 mmio: [126000000, fcffffffff]
> ACPI: bus type pci registered
> PCI: Using configuration type 1 for base access
> bio: create slab <bio-0> at 0
> ACPI: EC: Look up EC in DSDT
> ACPI: Interpreter enabled
> ACPI: (supports S0 S1 S5)
> ACPI: Using IOAPIC for interrupt routing
> ACPI: No dock devices found.
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> pci 0000:00:07.1: reg 20 io port: [0xffa0-0xffaf]
> pci 0000:00:07.2: reg 10 io port: [0xcc00-0xcc1f]
> pci 0000:00:0a.1: reg 10 64bit mmio: [0xfebfe000-0xfebfefff]
> pci 0000:00:0b.1: reg 10 64bit mmio: [0xfebff000-0xfebfffff]
> pci 0000:03:00.0: reg 10 32bit mmio: [0xfeafe000-0xfeafefff]
> pci 0000:03:00.1: reg 10 32bit mmio: [0xfeafd000-0xfeafdfff]
> pci 0000:00:06.0: bridge 32bit mmio: [0xfea00000-0xfeafffff]
> pci 0000:02:01.0: reg 10 64bit mmio: [0xfe8fbc00-0xfe8fbc7f]
> pci 0000:02:01.0: reg 18 64bit mmio: [0xfe8f0000-0xfe8f7fff]
> pci 0000:02:01.0: reg 20 io port: [0xbc00-0xbc0f]
> pci 0000:02:01.0: reg 30 32bit mmio: [0xfe700000-0xfe77ffff]
> pci 0000:02:01.0: supports D1 D2
> pci 0000:02:03.0: reg 10 io port: [0xb800-0xb8ff]
> pci 0000:02:03.0: reg 14 64bit mmio: [0xfe8fe000-0xfe8fffff]
> pci 0000:02:03.0: reg 1c io port: [0xb400-0xb4ff]
> pci 0000:02:03.0: reg 30 32bit mmio: [0xfe800000-0xfe87ffff]
> pci 0000:02:03.1: reg 10 io port: [0xb000-0xb0ff]
> pci 0000:02:03.1: reg 14 64bit mmio: [0xfe8fc000-0xfe8fdfff]
> pci 0000:02:03.1: reg 1c io port: [0xa800-0xa8ff]
> pci 0000:02:03.1: reg 30 32bit mmio: [0xfe780000-0xfe7fffff]
> pci 0000:02:05.0: reg 10 64bit mmio: [0xfe8e0000-0xfe8effff]
> pci 0000:02:05.0: PME# supported from D3hot D3cold
> pci 0000:02:05.0: PME# disabled
> pci 0000:02:05.1: reg 10 64bit mmio: [0xfe8d0000-0xfe8dffff]
> pci 0000:02:05.1: PME# supported from D3hot D3cold
> pci 0000:02:05.1: PME# disabled
> pci 0000:00:0a.0: bridge io port: [0xa000-0xbfff]
> pci 0000:00:0a.0: bridge 32bit mmio: [0xfe600000-0xfe9fffff]
> pci 0000:00:0a.0: bridge 64bit mmio pref: [0xfc300000-0xfc3fffff]
> pci 0000:01:01.0: reg 10 32bit mmio: [0xfd000000-0xfdffffff]
> pci 0000:01:01.0: reg 14 32bit mmio: [0xe0000000-0xefffffff]
> pci 0000:01:01.0: reg 30 32bit mmio: [0xfe5e0000-0xfe5fffff]
> pci 0000:00:0b.0: bridge 32bit mmio: [0xfc500000-0xfe5fffff]
> pci 0000:00:0b.0: bridge 64bit mmio pref: [0xdc300000-0xfc2fffff]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.GOLA._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.GOLB._PRT]
> ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
> ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
> ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
> ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
> ACPI: WMI: Mapper loaded
> SCSI subsystem initialized
> libata version 3.00 loaded.
> PCI: Using ACPI for IRQ routing
> NetLabel: Initializing
> NetLabel:  domain hash size = 128
> NetLabel:  protocols = UNLABELED CIPSOv4
> NetLabel:  unlabeled traffic allowed by default
> PCI-DMA: Disabling AGP.
> PCI-DMA: aperture base @ 20000000 size 65536 KB
> PCI-DMA: using GART IOMMU.
> PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
> pnp: PnP ACPI init
> ACPI: bus type pnp registered
> pnp: PnP ACPI: found 16 devices
> ACPI: ACPI bus type pnp unregistered
> system 00:0b: ioport range 0x680-0x6ff has been reserved
> system 00:0b: ioport range 0x295-0x296 has been reserved
> system 00:0b: ioport range 0xb78-0xb7f has been reserved
> system 00:0b: ioport range 0xf78-0xf7f has been reserved
> system 00:0c: ioport range 0x4d0-0x4d1 has been reserved
> system 00:0c: ioport range 0x5000-0x50bf has been reserved
> system 00:0c: ioport range 0x50e0-0x50ff has been reserved
> system 00:0c: ioport range 0x50c0-0x50df has been reserved
> system 00:0c: ioport range 0xde00-0xde7f has been reserved
> system 00:0c: ioport range 0xde80-0xdeff has been reserved
> system 00:0e: ioport range 0xca2-0xca3 has been reserved
> system 00:0e: iomem range 0xfec00000-0xfec00fff has been reserved
> system 00:0e: iomem range 0xfee00000-0xfee00fff has been reserved
> system 00:0e: iomem range 0xfff80000-0xffffffff has been reserved
> system 00:0e: iomem range 0xff780000-0xff7fffff has been reserved
> system 00:0f: iomem range 0x0-0x9ffff could not be reserved
> system 00:0f: iomem range 0xc0000-0xdffff has been reserved
> system 00:0f: iomem range 0xe0000-0xfffff could not be reserved
> system 00:0f: iomem range 0x100000-0xcfffffff could not be reserved
> pci 0000:00:06.0: PCI bridge, secondary bus 0000:03
> pci 0000:00:06.0:   IO window: disabled
> pci 0000:00:06.0:   MEM window: 0xfea00000-0xfeafffff
> pci 0000:00:06.0:   PREFETCH window: disabled
> pci 0000:00:0a.0: PCI bridge, secondary bus 0000:02
> pci 0000:00:0a.0:   IO window: 0xa000-0xbfff
> pci 0000:00:0a.0:   MEM window: 0xfe600000-0xfe9fffff
> pci 0000:00:0a.0:   PREFETCH window: 0x000000fc300000-0x000000fc3fffff
> pci 0000:00:0b.0: PCI bridge, secondary bus 0000:01
> pci 0000:00:0b.0:   IO window: disabled
> pci 0000:00:0b.0:   MEM window: 0xfc500000-0xfe5fffff
> pci 0000:00:0b.0:   PREFETCH window: 0x000000dc300000-0x000000fc2fffff
> bus: 00 index 0 io port: [0x00-0xffff]
> bus: 00 index 1 mmio: [0x000000-0xffffffffffffffff]
> bus: 03 index 0 mmio: [0x0-0x0]
> bus: 03 index 1 mmio: [0xfea00000-0xfeafffff]
> bus: 03 index 2 mmio: [0x0-0x0]
> bus: 03 index 3 mmio: [0x0-0x0]
> bus: 02 index 0 io port: [0xa000-0xbfff]
> bus: 02 index 1 mmio: [0xfe600000-0xfe9fffff]
> bus: 02 index 2 mmio: [0xfc300000-0xfc3fffff]
> bus: 02 index 3 mmio: [0x0-0x0]
> bus: 01 index 0 mmio: [0x0-0x0]
> bus: 01 index 1 mmio: [0xfc500000-0xfe5fffff]
> bus: 01 index 2 mmio: [0xdc300000-0xfc2fffff]
> bus: 01 index 3 mmio: [0x0-0x0]
> NET: Registered protocol family 2
> Switched to high resolution mode on CPU 0
> Switched to high resolution mode on CPU 1
> Switched to high resolution mode on CPU 3
> Switched to high resolution mode on CPU 2
> IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
> TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
> TCP bind hash table entries: 65536 (order: 10, 4718592 bytes)
> TCP: Hash tables configured (established 524288 bind 65536)
> TCP reno registered
> NET: Registered protocol family 1
> microcode: CPU0: AMD CPU family 0xf not supported
> microcode: CPU1: AMD CPU family 0xf not supported
> microcode: CPU2: AMD CPU family 0xf not supported
> microcode: CPU3: AMD CPU family 0xf not supported
> Microcode Update Driver: v2.00 <tigran-ppwZ4lME3+KI6QP4U9MhSdBc4/FLrbF6@public.gmane.org>, Peter Oruba
> Scanning for low memory corruption every 60 seconds
> Initializing RT-Tester: OK
> audit: initializing netlink socket (disabled)
> type=2000 audit(1231352315.220:1): initialized
> HugeTLB registered 2 MB page size, pre-allocated 0 pages
> Created ptmx node in devpts ino 2
> msgmni has been set to 7403
> alg: No test for stdrng (krng)
> Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
> io scheduler noop registered
> io scheduler anticipatory registered (default)
> io scheduler deadline registered
> io scheduler cfq registered
> boot interrupts on PCI device 0x1022:0x746b already disabled
> pci 0000:00:0a.0: MSI quirk detected; subordinate MSI disabled
> disabled boot interrupts on PCI device 0x1022:0x7450
> pci 0000:00:0b.0: MSI quirk detected; subordinate MSI disabled
> disabled boot interrupts on PCI device 0x1022:0x7450
> pci 0000:01:01.0: nv_msi_ht_cap_quirk didn't locate host bridge
> pci 0000:01:01.0: Boot video device
> vendor=1022 device=7450
>   alloc irq_desc for 28 on cpu 0 node 0
>   alloc kstat_irqs on cpu 0 node 0
>   alloc irq_cfg on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
> nvidiafb 0000:01:01.0: PCI INT A -> GSI 28 (level, low) -> IRQ 28
> nvidiafb: Device ID: 10de0322 
> nvidiafb: CRTC0 analog found
> nvidiafb: CRTC1 analog found
> nvidiafb: EDID found from BUS1
> i2c-adapter i2c-1: unable to read EDID block.
> i2c-adapter i2c-1: unable to read EDID block.
> i2c-adapter i2c-1: unable to read EDID block.
> nvidiafb: CRTC 0 appears to have a CRT attached
> nvidiafb: Using CRT on CRTC 0
> mtrr: type mismatch for e0000000,10000000 old: write-back new: write-combining
> nvidiafb: unable to setup MTRR
> Console: switching to colour frame buffer device 200x75
> nvidiafb: PCI nVidia NV32 framebuffer (64MB @ 0xE0000000)
> input: Power Button (FF) as /class/input/input0
> ACPI: Power Button (FF) [PWRF]
> input: Power Button (CM) as /class/input/input1
> ACPI: Power Button (CM) [PWRB]
> processor ACPI_CPU:00: registered as cooling_device0
> ACPI: Processor [CPU1] (supports 8 throttling states)
> processor ACPI_CPU:01: registered as cooling_device1
> processor ACPI_CPU:02: registered as cooling_device2
> processor ACPI_CPU:03: registered as cooling_device3
> Real Time Clock Driver v1.12ac
> hpet_acpi_add: no address or irqs in _CRS
> Non-volatile memory driver v1.3
> Linux agpgart interface v0.103
> [drm] Initialized drm 1.1.0 20060810
> console [netcon0] enabled
> netconsole: network logging started
> Driver 'sd' needs updating - please use bus_type methods
> pata_amd 0000:00:07.1: version 0.3.10
> scsi0 : pata_amd
> scsi1 : pata_amd
> ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
> ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
> ata1.00: ATA-7: ST3120814A, 3.AAJ, max UDMA/100
> ata1.00: 234441648 sectors, multi 16: LBA48 
> ata1.01: ATA-7: ST3500630A, 3.AAC, max UDMA/100
> ata1.01: 976773168 sectors, multi 16: LBA48 
> ata1.00: configured for UDMA/100
> ata1.01: configured for UDMA/100
> ata2.00: ATAPI: SONY    DVD RW DW-Q120A, PYS2, max UDMA/66
> ata2.00: configured for UDMA/66
> scsi 0:0:0:0: Direct-Access     ATA      ST3120814A       3.AA PQ: 0 ANSI: 5
> sd 0:0:0:0: [sda] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
> sd 0:0:0:0: [sda] Write Protect is off
> sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> sd 0:0:0:0: [sda] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
> sd 0:0:0:0: [sda] Write Protect is off
> sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
>  sda: sda1 sda2 sda3 sda4 < sda5 >
> sd 0:0:0:0: [sda] Attached SCSI disk
> scsi 0:0:1:0: Direct-Access     ATA      ST3500630A       3.AA PQ: 0 ANSI: 5
> sd 0:0:1:0: [sdb] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
> sd 0:0:1:0: [sdb] Write Protect is off
> sd 0:0:1:0: [sdb] Mode Sense: 00 3a 00 00
> sd 0:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> sd 0:0:1:0: [sdb] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
> sd 0:0:1:0: [sdb] Write Protect is off
> sd 0:0:1:0: [sdb] Mode Sense: 00 3a 00 00
> sd 0:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
>  sdb: sdb2
> sd 0:0:1:0: [sdb] Attached SCSI disk
> scsi 1:0:0:0: CD-ROM            SONY     DVD RW DW-Q120A  PYS2 PQ: 0 ANSI: 5
> Fusion MPT base driver 3.04.07
> Copyright (c) 1999-2008 LSI Corporation
> Fusion MPT SPI Host driver 3.04.07
> PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
> serio: i8042 KBD port at 0x60,0x64 irq 1
> serio: i8042 AUX port at 0x60,0x64 irq 12
> mice: PS/2 mouse device common for all mice
> input: PC Speaker as /class/input/input2
> input: AT Translated Set 2 keyboard as /class/input/input3
> cpuidle: using governor ladder
> oprofile: using NMI interrupt.
> TCP cubic registered
> powernow-k8: Found 2 Dual Core AMD Opteron(tm) Processor 270 processors (4 cpu cores) (version 2.20.00)
> powernow-k8:    0 : fid 0xc (2000 MHz), vid 0x8
> powernow-k8:    1 : fid 0xa (1800 MHz), vid 0xa
> powernow-k8:    2 : fid 0x2 (1000 MHz), vid 0x12
> powernow-k8:    0 : fid 0xc (2000 MHz), vid 0x8
> powernow-k8:    1 : fid 0xa (1800 MHz), vid 0xa
> powernow-k8:    2 : fid 0x2 (1000 MHz), vid 0x12
> registered taskstats version 1
> BIOS EDD facility v0.16 2004-Jun-25, 3 devices found
> input: ImExPS/2 Generic Explorer Mouse as /class/input/input4
> EXT3-fs: mounted filesystem with ordered data mode.
> VFS: Mounted root (ext3 filesystem) readonly on device 8:5.
> Freeing unused kernel memory: 2428k freed
> Write protecting the kernel read-only data: 5600k
> kjournald starting.  Commit interval 5 seconds
> input: ImExPS/2 Generic Explorer Mouse as /class/input/input5
> Driver 'sr' needs updating - please use bus_type methods
> sr0: scsi3-mmc drive: 48x/48x writer cd/rw xa/form2 cdda tray
> Uniform CD-ROM driver Revision: 3.20
> sr 1:0:0:0: Attached scsi CD-ROM sr0
> sd 0:0:0:0: Attached scsi generic sg0 type 0
> sd 0:0:1:0: Attached scsi generic sg1 type 0
> sr 1:0:0:0: Attached scsi generic sg2 type 5
> parport_pc 00:0a: reported by Plug and Play ACPI
> parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE,EPP]
> Serial: 8250/16550 driver4 ports, IRQ sharing disabled
> serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> 00:07: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> 00:08: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> shpchp 0000:00:06.0: HPC vendor_id 1022 device_id 7460 ss_vid 0 ss_did 0
> shpchp 0000:00:06.0: Cannot reserve MMIO region
> shpchp 0000:00:0a.0: HPC vendor_id 1022 device_id 7450 ss_vid 0 ss_did 0
> shpchp 0000:00:0a.0: Cannot reserve MMIO region
> shpchp 0000:00:0b.0: HPC vendor_id 1022 device_id 7450 ss_vid 0 ss_did 0
> shpchp 0000:00:0b.0: Cannot reserve MMIO region
> shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> ACPI: I/O resource amd756_smbus [0x50e0-0x50ef] conflicts with ACPI region PMIO [0x5000-0x50fe]
> ACPI: Device needs an ACPI driver
> ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> vendor=1022 device=7460
>   alloc irq_desc for 19 on cpu 0 node 0
>   alloc kstat_irqs on cpu 0 node 0
>   alloc irq_cfg on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
> ohci_hcd 0000:03:00.0: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> ohci_hcd 0000:03:00.0: OHCI Host Controller
> ohci_hcd 0000:03:00.0: new USB bus registered, assigned bus number 1
> ohci_hcd 0000:03:00.0: irq 19, io mem 0xfeafe000
> tg3.c:v3.97 (December 10, 2008)
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 3 ports detected
> usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
> usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb1: Product: OHCI Host Controller
> vendor=1022 device=7450
>   alloc irq_desc for 26 on cpu 0 node 0
>   alloc kstat_irqs on cpu 0 node 0
>   alloc irq_cfg on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
> tg3 0000:02:05.0: PCI INT A -> GSI 26 (level, low) -> IRQ 26
> usb usb1: Manufacturer: Linux 2.6.28-64-06887-g85390a8-dirty ohci_hcd
> usb usb1: SerialNumber: 0000:03:00.0
> vendor=1022 device=7460
> ohci_hcd 0000:03:00.1: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> ohci_hcd 0000:03:00.1: OHCI Host Controller
> ohci_hcd 0000:03:00.1: new USB bus registered, assigned bus number 2
> tg3 0000:02:05.0: PME# disabled
> ohci_hcd 0000:03:00.1: irq 19, io mem 0xfeafd000
> eth0: Tigon3 [partno(BCM95704A6) rev 2100] (PCIX:66MHz:64-bit) MAC address 00:30:48:59:8f:be
> eth0: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1])
> eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[0]
> eth0: dma_rwctrl[769f0000] dma_mask[64-bit]
> sata_sil24 0000:02:01.0: version 1.1
> vendor=1022 device=7450
>   alloc irq_desc for 24 on cpu 0 node 0
>   alloc kstat_irqs on cpu 0 node 0
>   alloc irq_cfg on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
> sata_sil24 0000:02:01.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
> sata_sil24 0000:02:01.0: Applying completion IRQ loss on PCI-X errata fix
> scsi2 : sata_sil24
> scsi3 : sata_sil24
> scsi4 : sata_sil24
> scsi5 : sata_sil24
> ata3: SATA max UDMA/100 host m128@0xfe8fbc00 port 0xfe8f0000 irq 24
> ata4: SATA max UDMA/100 host m128@0xfe8fbc00 port 0xfe8f2000 irq 24
> ata5: SATA max UDMA/100 host m128@0xfe8fbc00 port 0xfe8f4000 irq 24
> ata6: SATA max UDMA/100 host m128@0xfe8fbc00 port 0xfe8f6000 irq 24
> usb usb2: configuration #1 chosen from 1 choice
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 3 ports detected
> usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
> usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb2: Product: OHCI Host Controller
> usb usb2: Manufacturer: Linux 2.6.28-64-06887-g85390a8-dirty ohci_hcd
> usb usb2: SerialNumber: 0000:03:00.1
> Floppy drive(s): fd0 is 1.44M
> FDC 0 is a post-1991 82077
> ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 0)
> ata3.00: ATA-6: Sans Digital V.36.A0B, V.36.A0B, max UDMA/133
> ata3.00: 5860554240 sectors, multi 1: LBA48 
> ata3.00: applying bridge limits
> ata3.00: configured for UDMA/100
> ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 0)
> ata4.15: Port Multiplier 1.1, 0x1095:0x3726 r23, 6 ports, feat 0x1/0x9
> ata4.00: hard resetting link
> ata4.00: SATA link up 3.0 Gbps (SStatus 123 SControl 320)
> ata4.01: hard resetting link
> ata4.01: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> ata4.02: hard resetting link
> ata4.02: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> ata4.03: hard resetting link
> ata4.03: SATA link down (SStatus 0 SControl 320)
> ata4.04: hard resetting link
> ata4.04: SATA link down (SStatus 0 SControl 320)
> ata4.05: hard resetting link
> ata4.05: SATA link up 1.5 Gbps (SStatus 113 SControl 320)
> ata4.00: ATA-7: ST3750640AS, 3.AAE, max UDMA/133
> ata4.00: 1465149168 sectors, multi 0: LBA48 NCQ (depth 31/32)
> ata4.00: configured for UDMA/100
> ata4.01: ATA-7: Hitachi HDS721010KLA330, GKAOA70F, max UDMA/133
> ata4.01: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32)
> ata4.01: configured for UDMA/100
> ata4.02: ATA-7: Hitachi HDS721010KLA330, GKAOA70F, max UDMA/133
> ata4.02: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32)
> ata4.02: configured for UDMA/100
> ata4: EH complete
> ata5: SATA link down (SStatus 0 SControl 0)
> ata6: SATA link down (SStatus 0 SControl 0)
> scsi 2:0:0:0: Direct-Access     ATA      Sans Digital V.3 V.36 PQ: 0 ANSI: 5
> sd 2:0:0:0: [sdc] Very big device. Trying to use READ CAPACITY(16).
> sd 2:0:0:0: [sdc] 5860554240 512-byte hardware sectors: (3.00 TB/2.72 TiB)
> sd 2:0:0:0: [sdc] Write Protect is off
> sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
> sd 2:0:0:0: [sdc] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
> sd 2:0:0:0: [sdc] Very big device. Trying to use READ CAPACITY(16).
> sd 2:0:0:0: [sdc] 5860554240 512-byte hardware sectors: (3.00 TB/2.72 TiB)
> sd 2:0:0:0: [sdc] Write Protect is off
> sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
> sd 2:0:0:0: [sdc] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
>  sdc: sdc1 sdc2
> sd 2:0:0:0: [sdc] Attached SCSI disk
> sd 2:0:0:0: Attached scsi generic sg3 type 0
> scsi 3:0:0:0: Direct-Access     ATA      ST3750640AS      3.AA PQ: 0 ANSI: 5
> sd 3:0:0:0: [sdd] 1465149168 512-byte hardware sectors: (750 GB/698 GiB)
> sd 3:0:0:0: [sdd] Write Protect is off
> sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
> sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> sd 3:0:0:0: [sdd] 1465149168 512-byte hardware sectors: (750 GB/698 GiB)
> sd 3:0:0:0: [sdd] Write Protect is off
> sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
> sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
>  sdd: sdd1
> sd 3:0:0:0: [sdd] Attached SCSI disk
> sd 3:0:0:0: Attached scsi generic sg4 type 0
> scsi 3:1:0:0: Direct-Access     ATA      Hitachi HDS72101 GKAO PQ: 0 ANSI: 5
> sd 3:1:0:0: [sde] 1953525168 512-byte hardware sectors: (1.00 TB/931 GiB)
> sd 3:1:0:0: [sde] Write Protect is off
> sd 3:1:0:0: [sde] Mode Sense: 00 3a 00 00
> sd 3:1:0:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> sd 3:1:0:0: [sde] 1953525168 512-byte hardware sectors: (1.00 TB/931 GiB)
> sd 3:1:0:0: [sde] Write Protect is off
> sd 3:1:0:0: [sde] Mode Sense: 00 3a 00 00
> sd 3:1:0:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
>  sde: sde1
> sd 3:1:0:0: [sde] Attached SCSI disk
> sd 3:1:0:0: Attached scsi generic sg5 type 0
> scsi 3:2:0:0: Direct-Access     ATA      Hitachi HDS72101 GKAO PQ: 0 ANSI: 5
> sd 3:2:0:0: [sdf] 1953525168 512-byte hardware sectors: (1.00 TB/931 GiB)
> sd 3:2:0:0: [sdf] Write Protect is off
> sd 3:2:0:0: [sdf] Mode Sense: 00 3a 00 00
> sd 3:2:0:0: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> sd 3:2:0:0: [sdf] 1953525168 512-byte hardware sectors: (1.00 TB/931 GiB)
> sd 3:2:0:0: [sdf] Write Protect is off
> sd 3:2:0:0: [sdf] Mode Sense: 00 3a 00 00
> sd 3:2:0:0: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
>  sdf: sdf1
> sd 3:2:0:0: [sdf] Attached SCSI disk
> sd 3:2:0:0: Attached scsi generic sg6 type 0
> vendor=1022 device=7450
>   alloc irq_desc for 27 on cpu 0 node 0
>   alloc kstat_irqs on cpu 0 node 0
>   alloc irq_cfg on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
> tg3 0000:02:05.1: PCI INT B -> GSI 27 (level, low) -> IRQ 27
> tg3 0000:02:05.1: PME# disabled
> tg3 0000:02:05.1: firmware: requesting tigon/tg3_tso.bin
> eth1: Tigon3 [partno(BCM95704A6) rev 2100] (PCIX:66MHz:64-bit) MAC address 00:30:48:59:8f:bf
> eth1: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1])
> eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> eth1: dma_rwctrl[769f0000] dma_mask[64-bit]
> vendor=1022 device=7450
> aic79xx 0000:02:03.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
> scsi6 : Adaptec AIC79XX PCI-X SCSI HBA DRIVER, Rev 3.0
>         <Adaptec AIC7902 Ultra320 SCSI adapter>
>         aic7902: Ultra320 Wide Channel A, SCSI Id=7, PCI-X 50-66MHz, 512 SCBs
> vendor=1022 device=7450
>   alloc irq_desc for 25 on cpu 0 node 0
>   alloc kstat_irqs on cpu 0 node 0
>   alloc irq_cfg on cpu 0 node 0
>   alloc irq_2_pin on cpu 0 node 0
> aic79xx 0000:02:03.1: PCI INT B -> GSI 25 (level, low) -> IRQ 25
> scsi 6:0:0:0: Direct-Access     SEAGATE  ST3146707LW      0005 PQ: 0 ANSI: 3
>  target6:0:0: asynchronous
> scsi6:A:0:0: Tagged Queuing enabled.  Depth 32
>  target6:0:0: Beginning Domain Validation
>  target6:0:0: wide asynchronous
>  target6:0:0: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RDSTRM RTI WRFLOW PCOMP (6.25 ns, offset 63)
>  target6:0:0: Ending Domain Validation
> sd 6:0:0:0: [sdg] 286749488 512-byte hardware sectors: (146 GB/136 GiB)
> sd 6:0:0:0: [sdg] Write Protect is off
> sd 6:0:0:0: [sdg] Mode Sense: ab 00 10 08
> sd 6:0:0:0: [sdg] Write cache: enabled, read cache: enabled, supports DPO and FUA
> sd 6:0:0:0: [sdg] 286749488 512-byte hardware sectors: (146 GB/136 GiB)
> sd 6:0:0:0: [sdg] Write Protect is off
> sd 6:0:0:0: [sdg] Mode Sense: ab 00 10 08
> sd 6:0:0:0: [sdg] Write cache: enabled, read cache: enabled, supports DPO and FUA
>  sdg: sdg1
> sd 6:0:0:0: [sdg] Attached SCSI disk
> sd 6:0:0:0: Attached scsi generic sg7 type 0
> scsi7 : Adaptec AIC79XX PCI-X SCSI HBA DRIVER, Rev 3.0
>         <Adaptec AIC7902 Ultra320 SCSI adapter>
>         aic7902: Ultra320 Wide Channel B, SCSI Id=7, PCI-X 50-66MHz, 512 SCBs
> Adding 2040244k swap on /dev/sda2.  Priority:-1 extents:1 across:2040244k 
> EXT3 FS on sda5, internal journal
> i2c-adapter i2c-3: Unrecognized stepping 0x45. Defaulting to ADM1026.
> Shortest wait: 0
> Longest wait: 12
> w83627hf: Found W83627HF chip at 0x290
> WDT driver for the Winbond(TM) W83627HF/THF/HG Super I/O chip initialising.
> w83627hf/thf/hg WDT: initialized. timeout=60 sec (nowayout=0)
> NET: Registered protocol family 10
> lo: Disabled Privacy Extensions
> fuse init (API version 7.11)
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on sda1, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on sdb2, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on sde1, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on sdf1, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> NET: Registered protocol family 15
> alg: No test for cipher_null (cipher_null-generic)
> alg: No test for digest_null (digest_null-generic)
> alg: No test for compress_null (compress_null-generic)
> tg3 0000:02:05.0: PME# disabled
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> tg3: eth0: Link is up at 1000 Mbps, full duplex.
> tg3: eth0: Flow control is on for TX and on for RX.
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> Installing knfsd (copyright (C) 1996 okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org).
> BUG: using smp_processor_id() in preemptible [00000000] code: cpufreq-set/4048
> caller is powernowk8_target+0xc5/0x7a0
> Pid: 4048, comm: cpufreq-set Not tainted 2.6.28-64-06887-g85390a8-dirty #4
> Call Trace:
>  [<ffffffff803e8d3e>] debug_smp_processor_id+0xee/0xf0
>  [<ffffffff8021e7f5>] powernowk8_target+0xc5/0x7a0
>  [<ffffffff80278db0>] ? check_noncircular+0xa0/0x180
>  [<ffffffff804f2b7c>] __cpufreq_driver_target+0x3c/0x40
>  [<ffffffff804f5878>] cpufreq_governor_performance+0x28/0x30
>  [<ffffffff804f2cf1>] __cpufreq_governor+0xd1/0x150
>  [<ffffffff804f3090>] __cpufreq_set_policy+0x170/0x1a0
>  [<ffffffff804f3dd9>] store_scaling_governor+0xc9/0x270
>  [<ffffffff804f4db0>] ? handle_update+0x0/0x10
>  [<ffffffff805b81c2>] ? _spin_unlock_irqrestore+0x42/0x80
>  [<ffffffff804f4c60>] store+0x70/0xb0
>  [<ffffffff803544da>] sysfs_write_file+0xca/0x140
>  [<ffffffff802f9beb>] vfs_write+0xcb/0x190
>  [<ffffffff802f9da0>] sys_write+0x50/0x90
>  [<ffffffff8020c5db>] system_call_fastpath+0x16/0x1b
> BUG: using smp_processor_id() in preemptible [00000000] code: cpufreq-set/4049
> caller is powernowk8_target+0xc5/0x7a0
> Pid: 4049, comm: cpufreq-set Not tainted 2.6.28-64-06887-g85390a8-dirty #4
> Call Trace:
>  [<ffffffff803e8d3e>] debug_smp_processor_id+0xee/0xf0
>  [<ffffffff8021e7f5>] powernowk8_target+0xc5/0x7a0
>  [<ffffffff804f2b7c>] __cpufreq_driver_target+0x3c/0x40
>  [<ffffffff804f5878>] cpufreq_governor_performance+0x28/0x30
>  [<ffffffff804f2cf1>] __cpufreq_governor+0xd1/0x150
>  [<ffffffff804f3090>] __cpufreq_set_policy+0x170/0x1a0
>  [<ffffffff804f3dd9>] store_scaling_governor+0xc9/0x270
>  [<ffffffff805b81e5>] ? _spin_unlock_irqrestore+0x65/0x80
>  [<ffffffff804f4db0>] ? handle_update+0x0/0x10
>  [<ffffffff805b81c2>] ? _spin_unlock_irqrestore+0x42/0x80
>  [<ffffffff804f4c60>] store+0x70/0xb0
>  [<ffffffff803544da>] sysfs_write_file+0xca/0x140
>  [<ffffffff802f9beb>] vfs_write+0xcb/0x190
>  [<ffffffff802f9da0>] sys_write+0x50/0x90
>  [<ffffffff8020c5db>] system_call_fastpath+0x16/0x1b
> BUG: using smp_processor_id() in preemptible [00000000] code: cpufreq-set/4050
> caller is powernowk8_target+0xc5/0x7a0
> Pid: 4050, comm: cpufreq-set Not tainted 2.6.28-64-06887-g85390a8-dirty #4
> Call Trace:
>  [<ffffffff803e8d3e>] debug_smp_processor_id+0xee/0xf0
>  [<ffffffff8021e7f5>] powernowk8_target+0xc5/0x7a0
>  [<ffffffff804f2b7c>] __cpufreq_driver_target+0x3c/0x40
>  [<ffffffff804f5878>] cpufreq_governor_performance+0x28/0x30
>  [<ffffffff804f2cf1>] __cpufreq_governor+0xd1/0x150
>  [<ffffffff804f3090>] __cpufreq_set_policy+0x170/0x1a0
>  [<ffffffff804f3dd9>] store_scaling_governor+0xc9/0x270
>  [<ffffffff805b81e5>] ? _spin_unlock_irqrestore+0x65/0x80
>  [<ffffffff804f4db0>] ? handle_update+0x0/0x10
>  [<ffffffff805b81c2>] ? _spin_unlock_irqrestore+0x42/0x80
>  [<ffffffff804f4c60>] store+0x70/0xb0
>  [<ffffffff803544da>] sysfs_write_file+0xca/0x140
>  [<ffffffff802f9beb>] vfs_write+0xcb/0x190
>  [<ffffffff802f9da0>] sys_write+0x50/0x90
>  [<ffffffff8020c5db>] system_call_fastpath+0x16/0x1b
> BUG: using smp_processor_id() in preemptible [00000000] code: cpufreq-set/4051
> caller is powernowk8_target+0xc5/0x7a0
> Pid: 4051, comm: cpufreq-set Not tainted 2.6.28-64-06887-g85390a8-dirty #4
> Call Trace:
>  [<ffffffff803e8d3e>] debug_smp_processor_id+0xee/0xf0
>  [<ffffffff8021e7f5>] powernowk8_target+0xc5/0x7a0
>  [<ffffffff804f2b7c>] __cpufreq_driver_target+0x3c/0x40
>  [<ffffffff804f5878>] cpufreq_governor_performance+0x28/0x30
>  [<ffffffff804f2cf1>] __cpufreq_governor+0xd1/0x150
>  [<ffffffff804f3090>] __cpufreq_set_policy+0x170/0x1a0
>  [<ffffffff804f3dd9>] store_scaling_governor+0xc9/0x270
>  [<ffffffff805b81e5>] ? _spin_unlock_irqrestore+0x65/0x80
>  [<ffffffff804f4db0>] ? handle_update+0x0/0x10
>  [<ffffffff805b81c2>] ? _spin_unlock_irqrestore+0x42/0x80
>  [<ffffffff804f4c60>] store+0x70/0xb0
>  [<ffffffff803544da>] sysfs_write_file+0xca/0x140
>  [<ffffffff802f9beb>] vfs_write+0xcb/0x190
>  [<ffffffff802f9da0>] sys_write+0x50/0x90
>  [<ffffffff8020c5db>] system_call_fastpath+0x16/0x1b
> lp0: using parport0 (interrupt-driven).
> ppdev: user-space parallel port driver
> NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> NFSD: starting 90-second grace period
> Loading iSCSI transport class v2.0-870.
> iscsi: registered transport (tcp)
> warning: `ntpd' uses 32-bit capabilities (legacy support in use)
> Bluetooth: Core ver 2.14
> NET: Registered protocol family 31
> Bluetooth: HCI device and connection manager initialized
> Bluetooth: HCI socket layer initialized
> Bluetooth: L2CAP ver 2.11
> Bluetooth: L2CAP socket layer initialized
> Bluetooth: RFCOMM socket layer initialized
> Bluetooth: RFCOMM TTY layer initialized
> Bluetooth: RFCOMM ver 1.10
> ip_tables: (C) 2000-2006 Netfilter Core Team
> nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
> nf_conntrack.acct=1 kernel paramater, acct=1 nf_conntrack module option or
> sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.28-64-06887-g85390a8-dirty #4
> ---------------------------------------------
> nfsd4/4336 is trying to acquire lock:
>  (&type->i_mutex_dir_key#2){--..}, at: [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
> 
> but task is already holding lock:
>  (&type->i_mutex_dir_key#2){--..}, at: [<ffffffffa102a20d>] nfsd4_sync_rec_dir+0x1d/0x50 [nfsd]
> 
> other info that might help us debug this:
> 4 locks held by nfsd4/4336:
>  #0:  (nfsd4){--..}, at: [<ffffffff802628d3>] run_workqueue+0xb3/0x250
>  #1:  ((laundromat_work).work){--..}, at: [<ffffffff802628d3>] run_workqueue+0xb3/0x250
>  #2:  (client_mutex){--..}, at: [<ffffffffa1024d6e>] laundromat_main+0x2e/0x300 [nfsd]
>  #3:  (&type->i_mutex_dir_key#2){--..}, at: [<ffffffffa102a20d>] nfsd4_sync_rec_dir+0x1d/0x50 [nfsd]
> 
> stack backtrace:
> Pid: 4336, comm: nfsd4 Not tainted 2.6.28-64-06887-g85390a8-dirty #4
> Call Trace:
>  [<ffffffff8027a4b4>] __lock_acquire+0x10c4/0x1dc0
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff80275d54>] ? get_lock_stats+0x34/0x80
>  [<ffffffff8027b4ab>] ? lock_acquired+0x15b/0x330
>  [<ffffffff8027b206>] lock_acquire+0x56/0x80
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff805b5fcc>] mutex_lock_nested+0xec/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> INFO: task nfsd4:4336 blocked for more than 480 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd4         D ffff880083a38c00     0  4336      2
>  ffff88011e4ddcd0 0000000000000046 ffff88011e474960 ffffffff80212c09
>  ffffffff809e2000 ffffffff80baac00 0000000000000003 ffff88011e474960
>  ffff88007f16a4b0 ffff88011e474ed8 000000038027b8dc 00000000ffffd283
> Call Trace:
>  [<ffffffff80212c09>] ? native_sched_clock+0x39/0xa0
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff805b6115>] ? mutex_lock_nested+0x235/0x390
>  [<ffffffff805b6071>] mutex_lock_nested+0x191/0x390
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] ? vfs_fsync+0x84/0x100
>  [<ffffffff8031ca24>] vfs_fsync+0x84/0x100
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa100ca70>] nfsd_sync_dir+0x10/0x20 [nfsd]
>  [<ffffffffa102a219>] nfsd4_sync_rec_dir+0x29/0x50 [nfsd]
>  [<ffffffffa102a2c5>] nfsd4_recdir_purge_old+0x85/0x90 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d99>] laundromat_main+0x59/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffffa1024d40>] ? laundromat_main+0x0/0x300 [nfsd]
>  [<ffffffff80262925>] run_workqueue+0x105/0x250
>  [<ffffffff802628d3>] ? run_workqueue+0xb3/0x250
>  [<ffffffff805bbf78>] ? sub_preempt_count+0xd8/0x140
>  [<ffffffff80262b17>] worker_thread+0xa7/0x120
>  [<ffffffff802673d0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80262a70>] ? worker_thread+0x0/0x120
>  [<ffffffff80266f09>] kthread+0x49/0x80
>  [<ffffffff8020d6fa>] child_rip+0xa/0x20
>  [<ffffffff80247358>] ? finish_task_switch+0x68/0xe0
>  [<ffffffff805b8156>] ? _spin_unlock_irq+0x36/0x60
>  [<ffffffff8020d0c0>] ? restore_args+0x0/0x30
>  [<ffffffff80266ec0>] ? kthread+0x0/0x80
>  [<ffffffff8020d6f0>] ? child_rip+0x0/0x20
> INFO: lockdep is turned off.
> mtrr: type mismatch for e0000000,10000000 old: write-back new: write-combining

