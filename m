Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:58178 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab0I2Q52 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 12:57:28 -0400
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 8EADADD7
	for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 18:57:26 +0200 (MEST)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 62E3DDD3
	for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 18:57:26 +0200 (MEST)
Message-ID: <4CA36FDD.1020102@desy.de>
Date: Wed, 29 Sep 2010 18:57:01 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA34F05.3020809@desy.de> <4CA35A59.9020303@panasas.com>
In-Reply-To: <4CA35A59.9020303@panasas.com>
Content-Type: multipart/mixed;
 boundary="------------060801040104090606050908"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------060801040104090606050908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


> Tigran, do you have a new trace maybe?
> I cross referenced the dump you sent to the
> disassembled code and it seems like it hit NULL dereference on
> size = fl->stripe_unit;
>
> I'm going to commit this patch anyway but I want to
> understand what else I missed...
>
> Benny
>

The stack attached.  Shall I compile the kernel with some debug options 
for better debugging?

Tigran.
>>> git diff --stat -p -M
>>>    fs/nfs/nfs4filelayout.c |    2 ++
>>>    1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>> index 75e07c8..8fbb0db 100644
>>> --- a/fs/nfs/nfs4filelayout.c
>>> +++ b/fs/nfs/nfs4filelayout.c
>>> @@ -636,6 +636,8 @@ filelayout_get_stripesize(struct pnfs_layout_hdr *lo)
>>>
>>>    	/* Horrible hack...ideally upper layer would send lseg */
>>>    	lseg = pnfs_has_layout(lo,&range);
>>> +	if (!lseg)
>>> +		return 0;
>>>    	fl = container_of(lseg, struct nfs4_filelayout_segment, generic_hdr);
>>>    	size = fl->stripe_unit;
>>>    	put_lseg_locked(lseg);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--------------060801040104090606050908
Content-Type: text/plain;
 name="crash"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="crash"

[    0.000000] Linux version 2.6.36-rc6.pnfs.1 (root@slinux) (gcc version 4.1.2 20080704 (Red Hat 4.1.2-48)) #1 SMP Wed Sep 29 15:13:40 CEST 2010
[    0.000000] Command line: ro root=/dev/sda1
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003fff0000 (usable)
[    0.000000]  BIOS-e820: 000000003fff0000 - 0000000040000000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000fffc0000 - 0000000100000000 (reserved)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.5 present.
[    0.000000] e820 update range: 0000000000000000 - 0000000000001000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x3fff0 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR variable ranges disabled:
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] CPU MTRRs all blank - virtualized system.
[    0.000000] e820 update range: 0000000000001000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] modified physical RAM map:
[    0.000000]  modified: 0000000000000000 - 0000000000010000 (reserved)
[    0.000000]  modified: 0000000000010000 - 000000000009fc00 (usable)
[    0.000000]  modified: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  modified: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  modified: 0000000000100000 - 000000003fff0000 (usable)
[    0.000000]  modified: 000000003fff0000 - 0000000040000000 (ACPI data)
[    0.000000]  modified: 00000000fffc0000 - 0000000100000000 (reserved)
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] init_memory_mapping: 0000000000000000-000000003fff0000
[    0.000000]  0000000000 - 003fe00000 page 2M
[    0.000000]  003fe00000 - 003fff0000 page 4k
[    0.000000] kernel direct mapping tables up to 3fff0000 @ 16000-19000
[    0.000000] RAMDISK: 37db7000 - 37ff0000
[    0.000000] ACPI: RSDP 00000000000e0000 00024 (v02 VBOX  )
[    0.000000] ACPI: XSDT 000000003fff0030 0003C (v01 VBOX   VBOXXSDT 00000001 ASL  00000061)
[    0.000000] ACPI: FACP 000000003fff00f0 000F4 (v04 VBOX   VBOXFACP 00000001 ASL  00000061)
[    0.000000] ACPI: DSDT 000000003fff0460 018FF (v01 VBOX   VBOXBIOS 00000002 INTL 20081031)
[    0.000000] ACPI: FACS 000000003fff0200 00040
[    0.000000] ACPI: APIC 000000003fff0240 0004A (v02 VBOX   VBOXAPIC 00000001 ASL  00000061)
[    0.000000] ACPI: SSDT 000000003fff0290 001CC (v01 VBOX   VBOXCPUT 00000002 INTL 20081031)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-000000003fff0000
[    0.000000] Initmem setup node 0 0000000000000000-000000003fff0000
[    0.000000]   NODE_DATA [000000000174b080 - 000000000175f07f]
[    0.000000]  [ffffea0000000000-ffffea0000dfffff] PMD -> [ffff880002000000-ffff880002dfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   empty
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003fff0
[    0.000000] On node 0 totalpages: 262015
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3927 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 3528 pages used for memmap
[    0.000000]   DMA32 zone: 254504 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x4008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 40000000:bffc0000)
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:1 nr_node_ids:1
[    0.000000] early_res array is doubled to 64 at [17000 - 177ff]
[    0.000000] PERCPU: Embedded 26 pages/cpu @ffff880001800000 s77440 r8192 d20864 u2097152
[    0.000000] pcpu-alloc: s77440 r8192 d20864 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 258431
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: ro root=/dev/sda1
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Subtract (37 early reservations)
[    0.000000]   #1 [0001000000 - 000174aad0]   TEXT DATA BSS
[    0.000000]   #2 [0037db7000 - 0037ff0000]         RAMDISK
[    0.000000]   #3 [000009fc00 - 0000100000]   BIOS reserved
[    0.000000]   #4 [000174b000 - 000174b071]             BRK
[    0.000000]   #5 [0000010000 - 0000012000]      TRAMPOLINE
[    0.000000]   #6 [0000012000 - 0000016000]     ACPI WAKEUP
[    0.000000]   #7 [0000016000 - 0000017000]         PGTABLE
[    0.000000]   #8 [000174b080 - 000175f080]       NODE_DATA
[    0.000000]   #9 [000175f080 - 0001760080]         BOOTMEM
[    0.000000]   #10 [000174ab00 - 000174abc0]         BOOTMEM
[    0.000000]   #11 [0001f61000 - 0001f62000]         BOOTMEM
[    0.000000]   #12 [0001f62000 - 0001f63000]         BOOTMEM
[    0.000000]   #13 [0002000000 - 0002e00000]        MEMMAP 0
[    0.000000]   #14 [000174abc0 - 000174ad40]         BOOTMEM
[    0.000000]   #15 [0001760080 - 0001766080]         BOOTMEM
[    0.000000]   #16 [0001767000 - 0001768000]         BOOTMEM
[    0.000000]   #17 [000174ad40 - 000174ad83]         BOOTMEM
[    0.000000]   #18 [000174adc0 - 000174af48]         BOOTMEM
[    0.000000]   #19 [000174af80 - 000174afe8]         BOOTMEM
[    0.000000]   #20 [0001766080 - 00017660e8]         BOOTMEM
[    0.000000]   #21 [0001766100 - 0001766168]         BOOTMEM
[    0.000000]   #22 [0001766180 - 00017661e8]         BOOTMEM
[    0.000000]   #23 [0001766200 - 0001766268]         BOOTMEM
[    0.000000]   #24 [0001766280 - 00017662e8]         BOOTMEM
[    0.000000]   #25 [0001766300 - 0001766320]         BOOTMEM
[    0.000000]   #26 [0001766340 - 0001766352]         BOOTMEM
[    0.000000]   #27 [0001766380 - 0001766392]         BOOTMEM
[    0.000000]   #28 [0001800000 - 000181a000]         BOOTMEM
[    0.000000]   #29 [00017663c0 - 00017663c8]         BOOTMEM
[    0.000000]   #30 [0001766400 - 0001766408]         BOOTMEM
[    0.000000]   #31 [0001766440 - 0001766444]         BOOTMEM
[    0.000000]   #32 [0001766480 - 0001766488]         BOOTMEM
[    0.000000]   #33 [00017664c0 - 0001766610]         BOOTMEM
[    0.000000]   #34 [0001766640 - 00017666c0]         BOOTMEM
[    0.000000]   #35 [00017666c0 - 0001766740]         BOOTMEM
[    0.000000]   #36 [0001768000 - 0001770000]         BOOTMEM
[    0.000000] Memory: 1023692k/1048512k available (3608k kernel code, 452k absent, 24368k reserved, 1767k data, 1424k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU-based detection of stalled CPUs is disabled.
[    0.000000] 	Verbose stalled-CPUs detection is disabled.
[    0.000000] NR_IRQS:4352 nr_irqs:256
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Fast TSC calibration failed
[    0.000000] TSC: Unable to calibrate against PIT
[    0.000000] TSC: using PMTIMER reference calibration
[    0.000000] Detected 2967.716 MHz processor.
[    0.060004] Calibrating delay loop (skipped), value calculated using timer frequency.. 5935.43 BogoMIPS (lpj=29677160)
[    0.061727] pid_max: default: 32768 minimum: 301
[    0.062580] Security Framework initialized
[    0.063365] SELinux:  Disabled at boot.
[    0.064218] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.065693] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.066796] Mount-cache hash table entries: 256
[    0.067795] mce: CPU supports 0 MCE banks
[    0.068608] using mwait in idle threads.
[    0.070008] Performance Events: unsupported p6 CPU model 23 no PMU driver, software events only.
[    0.071920] SMP alternatives: switching to UP code
[    0.249921] Freeing SMP alternatives: 16k freed
[    0.250036] ACPI: Core revision 20100702
[    0.251628] Setting APIC routing to flat
[    0.260466] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.367454] CPU0: Intel(R) Core(TM)2 Duo CPU     E8400  @ 3.00GHz stepping 0a
[    0.370891] Brought up 1 CPUs
[    0.371642] Total of 1 processors activated (5935.43 BogoMIPS).
[    0.373027] devtmpfs: initialized
[    0.374377] Time: 14:33:56  Date: 09/29/10
[    0.375266] NET: Registered protocol family 16
[    0.376135] ACPI: bus type pci registered
[    0.376984] PCI: Using configuration type 1 for base access
[    0.381469] bio: create slab <bio-0> at 0
[    0.382668] ACPI: EC: Look up EC in DSDT
[    0.385540] ACPI: Interpreter enabled
[    0.386292] ACPI: (supports S0 S5)
[    0.387245] ACPI: Using IOAPIC for interrupt routing
[    0.390488] ACPI: No dock devices found.
[    0.391253] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.392820] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.393815] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.393817] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.393819] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.393821] pci_root PNP0A03:00: host bridge window [mem 0x40000000-0xffdfffff] (ignored)
[    0.396556] pci 0000:00:02.0: reg 10: [mem 0xe0000000-0xe0ffffff pref]
[    0.408169] pci 0000:00:03.0: reg 10: [mem 0xf0000000-0xf001ffff]
[    0.411246] pci 0000:00:03.0: reg 18: [io  0xd000-0xd007]
[    0.417059] pci 0000:00:04.0: reg 10: [io  0xd020-0xd03f]
[    0.417929] pci 0000:00:04.0: reg 14: [mem 0xf0400000-0xf07fffff]
[    0.418686] pci 0000:00:04.0: reg 18: [mem 0xf0800000-0xf0803fff pref]
[    0.422034] pci 0000:00:05.0: reg 10: [io  0xd100-0xd1ff]
[    0.422118] pci 0000:00:05.0: reg 14: [io  0xd200-0xd23f]
[    0.423395] pci 0000:00:06.0: reg 10: [mem 0xf0804000-0xf0804fff]
[    0.430238] pci 0000:00:0b.0: reg 10: [mem 0xf0805000-0xf0805fff]
[    0.436912] pci 0000:00:0d.0: reg 10: [io  0xd240-0xd247]
[    0.438749] pci 0000:00:0d.0: reg 18: [io  0xd250-0xd257]
[    0.440306] pci 0000:00:0d.0: reg 20: [io  0xd260-0xd26f]
[    0.441817] pci 0000:00:0d.0: reg 24: [mem 0xf0806000-0xf0807fff]
[    0.443377] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.446525] ACPI: PCI Interrupt Link [LNKA] (IRQs *5 9 10 11)
[    0.450069] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 9 10 *11)
[    0.451700] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 9 *10 11)
[    0.453291] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 *9 10 11)
[    0.455297] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.456744] vgaarb: loaded
[    0.457724] SCSI subsystem initialized
[    0.460110] libata version 3.00 loaded.
[    0.460226] usbcore: registered new interface driver usbfs
[    0.461110] usbcore: registered new interface driver hub
[    0.462009] usbcore: registered new device driver usb
[    0.462957] PCI: Using ACPI for IRQ routing
[    0.463741] PCI: pci_cache_line_size set to 64 bytes
[    0.463963] reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
[    0.463969] reserve RAM buffer: 000000003fff0000 - 000000003fffffff 
[    0.464238] Switching to clocksource tsc
[    0.465211] pnp: PnP ACPI init
[    0.465950] ACPI: bus type pnp registered
[    0.467526] pnp: PnP ACPI: found 5 devices
[    0.468302] ACPI: ACPI bus type pnp unregistered
[    0.470080] pci_bus 0000:00: resource 0 [io  0x0000-0xffff]
[    0.470083] pci_bus 0000:00: resource 1 [mem 0x00000000-0xffffffffffffffff]
[    0.470151] NET: Registered protocol family 2
[    0.471161] IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.473159] TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
[    0.476163] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.477569] TCP: Hash tables configured (established 131072 bind 65536)
[    0.478514] TCP reno registered
[    0.479258] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.480245] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.481305] NET: Registered protocol family 1
[    0.482121] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.483029] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.483941] pci 0000:00:02.0: Boot video device
[    0.484107] PCI: CLS 64 bytes, default 64
[    0.484197] Unpacking initramfs...
[    0.521689] Freeing initrd memory: 2276k freed
[    0.523224] platform rtc_cmos: registered platform RTC device (no PNP device found)
[    0.524853] Scanning for low memory corruption every 60 seconds
[    0.525929] audit: initializing netlink socket (disabled)
[    0.526806] type=2000 audit(1285770835.520:1): initialized
[    0.530414] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.531606] msgmni has been set to 2003
[    0.532444] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.533855] io scheduler noop registered
[    0.534610] io scheduler deadline registered
[    0.540873] io scheduler cfq registered (default)
[    0.541762] pci-stub: invalid id string ""
[    0.542743] Non-volatile memory driver v1.3
[    0.543521] Linux agpgart interface v0.103
[    0.544310] Serial: 8250/16550 driver, 8 ports, IRQ sharing disabled
[    0.545579] ahci 0000:00:0d.0: version 3.0
[    0.545600]   alloc irq_desc for 21 on node -1
[    0.545602]   alloc kstat_irqs on node -1
[    0.545633] ahci 0000:00:0d.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
[    0.546677] ahci: SSS flag set, parallel bus scan disabled
[    0.547674] ahci 0000:00:0d.0: AHCI 0001.0100 32 slots 1 ports 3 Gbps 0x1 impl SATA mode
[    0.549112] ahci 0000:00:0d.0: flags: 64bit ncq stag only ccc 
[    0.550340] scsi0 : ahci
[    0.551080] ata1: SATA max UDMA/133 abar m8192@0xf0806000 port 0xf0806100 irq 21
[    0.552528] Fixed MDIO Bus: probed
[    0.553275] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.554206]   alloc irq_desc for 19 on node -1
[    0.554207]   alloc kstat_irqs on node -1
[    0.554233] ehci_hcd 0000:00:0b.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    0.555235] ehci_hcd 0000:00:0b.0: EHCI Host Controller
[    0.556101] ehci_hcd 0000:00:0b.0: new USB bus registered, assigned bus number 1
[    0.557749] ehci_hcd 0000:00:0b.0: irq 19, io mem 0xf0805000
[    0.575743] ehci_hcd 0000:00:0b.0: USB 2.0 started, EHCI 1.00
[    0.576807] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.577807] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.579198] usb usb1: Product: EHCI Host Controller
[    0.581031] usb usb1: Manufacturer: Linux 2.6.36-rc6.pnfs.1 ehci_hcd
[    0.581984] usb usb1: SerialNumber: 0000:00:0b.0
[    0.583257] hub 1-0:1.0: USB hub found
[    0.586446] hub 1-0:1.0: 8 ports detected
[    0.587771] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.590158]   alloc irq_desc for 22 on node -1
[    0.590161]   alloc kstat_irqs on node -1
[    0.590202] ohci_hcd 0000:00:06.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    0.591598] ohci_hcd 0000:00:06.0: OHCI Host Controller
[    0.592525] ohci_hcd 0000:00:06.0: new USB bus registered, assigned bus number 2
[    0.594096] ohci_hcd 0000:00:06.0: irq 22, io mem 0xf0804000
[    0.656033] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    0.656944] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.658322] usb usb2: Product: OHCI Host Controller
[    0.659144] usb usb2: Manufacturer: Linux 2.6.36-rc6.pnfs.1 ohci_hcd
[    0.660156] usb usb2: SerialNumber: 0000:00:06.0
[    0.661060] hub 2-0:1.0: USB hub found
[    0.661836] hub 2-0:1.0: 8 ports detected
[    0.662854] uhci_hcd: USB Universal Host Controller Interface driver
[    0.663792] Initializing USB Mass Storage driver...
[    0.664637] usbcore: registered new interface driver usb-storage
[    0.665538] USB Mass Storage support registered.
[    0.666356] usbcore: registered new interface driver libusual
[    0.667228] usbcore: registered new interface driver ums-alauda
[    0.668113] usbcore: registered new interface driver ums-cypress
[    0.669001] usbcore: registered new interface driver ums-datafab
[    0.669967] usbcore: registered new interface driver ums-freecom
[    0.671485] usbcore: registered new interface driver ums-isd200
[    0.672379] usbcore: registered new interface driver ums-jumpshot
[    0.673282] usbcore: registered new interface driver ums-karma
[    0.674169] usbcore: registered new interface driver ums-onetouch
[    0.675076] usbcore: registered new interface driver ums-sddr09
[    0.675964] usbcore: registered new interface driver ums-sddr55
[    0.676852] usbcore: registered new interface driver ums-usbat
[    0.677787] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
[    0.680009] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.680854] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.681745] mice: PS/2 mouse device common for all mice
[    0.682889] input: AT Translated Set 2 keyboard as /class/input/input0
[    0.684218] rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
[    0.685239] rtc0: alarms up to one day, 114 bytes nvram
[    0.686104] cpuidle: using governor ladder
[    0.686876] cpuidle: using governor menu
[    0.691220] input: ImExPS/2 Generic Explorer Mouse as /class/input/input1
[    0.692358] usbcore: registered new interface driver hiddev
[    0.693251] usbcore: registered new interface driver usbhid
[    0.694189] usbhid: USB HID core driver
[    0.695102] TCP cubic registered
[    0.695828] lib80211: common routines for IEEE802.11 drivers
[    0.696680] lib80211_crypt: registered algorithm 'NULL'
[    0.696682] Registering the dns_resolver key type
[    0.697576] PM: Resume from disk failed.
[    0.697798]   Magic number: 10:711:587
[    0.698619] rtc_cmos rtc_cmos: setting system clock to 2010-09-29 14:33:56 UTC (1285770836)
[    0.904997] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    0.906547] ata1.00: ATA-6: VBOX HARDDISK, 1.0, max UDMA/133
[    0.907856] ata1.00: 35072000 sectors, multi 128: LBA48 NCQ (depth 31/32)
[    0.909418] ata1.00: configured for UDMA/133
[    0.910959] scsi 0:0:0:0: Direct-Access     ATA      VBOX HARDDISK    1.0  PQ: 0 ANSI: 5
[    0.913642] sd 0:0:0:0: [sda] 35072000 512-byte logical blocks: (17.9 GB/16.7 GiB)
[    0.915094] sd 0:0:0:0: [sda] Write Protect is off
[    0.915977] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    0.915993] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    0.918990]  sda: sda1
[    0.920179] sd 0:0:0:0: [sda] Attached SCSI disk
[    0.921217] Freeing unused kernel memory: 1424k freed
[    0.933849] nash-hotplug (28): /proc/28/oom_adj is deprecated, please use /proc/28/oom_score_adj instead.
[    1.212557] device-mapper: uevent: version 1.0.3
[    1.225904] device-mapper: ioctl: 4.18.0-ioctl (2010-06-29) initialised: dm-devel@redhat.com
[    1.299442] EXT3-fs: barriers not enabled
[    1.305176] kjournald starting.  Commit interval 5 seconds
[    1.306079] EXT3-fs (sda1): mounted filesystem with ordered data mode
[    5.361737] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k6-NAPI
[    5.361739] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    5.361798] e1000 0000:00:03.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    6.453116] parport_pc 00:04: reported by Plug and Play ACPI
[    6.918441] input: Power Button as /class/input/input2
[    6.918446] ACPI: Power Button [PWRF]
[    6.918533] input: Sleep Button as /class/input/input3
[    6.918535] ACPI: Sleep Button [SLPF]
[    6.924632] ACPI: acpi_idle registered with cpuidle
[    7.056580] usbcore: registered new interface driver usbserial
[    7.056587] USB Serial support registered for generic
[    7.056594] usbcore: registered new interface driver usbserial_generic
[    7.056595] usbserial: USB Serial Driver core
[    7.152849] USB Serial support registered for GSM modem (1-port)
[    7.152878] usbcore: registered new interface driver option
[    7.152879] option: v0.7.2:USB Driver for GSM modems
[    7.820006] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    8.062790] ACPI: AC Adapter [AC] (on-line)
[    8.137617] e1000 0000:00:03.0: eth0: (PCI:33MHz:32-bit) 08:00:27:16:5f:ab
[    8.137627] e1000 0000:00:03.0: eth0: Intel(R) PRO/1000 Network Connection
[    8.139680] piix4_smbus 0000:00:07.0: SMBus base address uninitialized - upgrade BIOS or use force_addr=0xaddr
[   12.310109] floppy0: no floppy controllers found
[   12.367203] lp: driver loaded but no devices found
[   12.864837] md: Autodetecting RAID arrays.
[   12.864840] md: Scanned 0 and added 0 devices.
[   12.864841] md: autorun ...
[   12.864842] md: ... autorun DONE.
[   13.024121] device-mapper: multipath: version 1.1.1 loaded
[   13.714358] EXT3-fs (sda1): using internal journal
[   16.129801] warning: process `kudzu' used the deprecated sysctl system call with 1.23.
[   19.783286] NET: Registered protocol family 17
[   20.870518] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   23.415744] warning: `dbus-daemon' uses 32-bit capabilities (legacy support in use)
[   35.644116] NET: Registered protocol family 10
[   35.644422] lo: Disabled Privacy Extensions
[   38.704565] mtrr: your processor doesn't support write-combining
[   38.704661] mtrr: your processor doesn't support write-combining
[   45.740034] eth0: no IPv6 routers present
[  109.872865] RPC: Registered udp transport module.
[  109.872867] RPC: Registered tcp transport module.
[  109.872868] RPC: Registered tcp NFSv4.1 backchannel transport module.
[  109.928622] FS-Cache: Loaded
[  109.980197] FS-Cache: Netfs 'nfs' registered for caching
[  110.036272] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[  147.032840] BUG: unable to handle kernel NULL pointer dereference at 0000000000000040
[  147.032846] IP: [<ffffffffa006d416>] filelayout_get_stripesize+0x26/0x40 [nfs_layout_nfsv41_files]
[  147.032857] PGD 225af067 PUD 225ae067 PMD 0 
[  147.032861] Oops: 0000 [#1] SMP 
[  147.032864] last sysfs file: /sys/block/sda/sda1/stat
[  147.032865] CPU 0 
[  147.032867] Modules linked in: nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output sbs sbshc pci_slot fan container battery lp ac sg option usb_wwan usbserial thermal button thermal_sys serio_raw parport_pc parport tpm_tis tpm tpm_bios i2c_piix4 e1000 pata_mpiix dm_region_hash dm_log dm_mod [last unloaded: mperf]
[  147.032892] 
[  147.032894] Pid: 2158, comm: visualvm Not tainted 2.6.36-rc6.pnfs.1 #1 /VirtualBox
[  147.032897] RIP: 0010:[<ffffffffa006d416>]  [<ffffffffa006d416>] filelayout_get_stripesize+0x26/0x40 [nfs_layout_nfsv41_files]
[  147.032902] RSP: 0018:ffff880022d2dcd8  EFLAGS: 00010292
[  147.032904] RAX: 0000000000000000 RBX: ffffffffa006fa00 RCX: 7fffffffffffffff
[  147.032906] RDX: 0000000000002b2a RSI: ffff880022d2dcd8 RDI: ffff880022cb4540
[  147.032909] RBP: ffff8800228542f0 R08: 00007fff84f8fc70 R09: ffff880022854408
[  147.032911] R10: 0000000000000001 R11: ffffffffa0228570 R12: ffff88002285439c
[  147.032913] R13: ffff880022d2dd60 R14: ffff880022854408 R15: ffff880022854110
[  147.032920] FS:  00007ff84d97b6e0(0000) GS:ffff880001800000(0000) knlGS:0000000000000000
[  147.032922] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  147.032924] CR2: 0000000000000040 CR3: 0000000022de6000 CR4: 00000000000006f0
[  147.032931] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  147.032934] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  147.032936] Process visualvm (pid: 2158, threadinfo ffff880022d2c000, task ffff88003f2c4c70)
[  147.032938] Stack:
[  147.032939]  ffff880000000001 0000000000000000 ffffffffffffffff 0000000000000000
[  147.032942] <0> ffffffffa006fa00 ffffffffa024a28e ffff880022d2dd88 ffff8800228542f0
[  147.032946] <0> ffff880022ccfc00 ffffffffa024b638 ffff880022d2de60 ffff8800228542f0
[  147.032950] Call Trace:
[  147.032982]  [<ffffffffa024a28e>] ? pnfs_getboundary+0x6e/0x80 [nfs]
[  147.032992]  [<ffffffffa024b638>] ? pnfs_pageio_init_write+0x78/0xa0 [nfs]
[  147.033001]  [<ffffffffa022725f>] ? nfs_pageio_init_write+0x3f/0x90 [nfs]
[  147.033010]  [<ffffffffa02285f0>] ? nfs_writepages+0x80/0x130 [nfs]
[  147.033015]  [<ffffffff810adb37>] ? handle_mm_fault+0x1b7/0x900
[  147.033019]  [<ffffffff810949d4>] ? __filemap_fdatawrite_range+0x54/0x60
[  147.033023]  [<ffffffff81094c35>] ? filemap_write_and_wait+0x35/0x50
[  147.033030]  [<ffffffffa021b904>] ? nfs_getattr+0xf4/0x100 [nfs]
[  147.033033]  [<ffffffff810d2897>] ? vfs_fstat+0x37/0x60
[  147.033036]  [<ffffffff810d28df>] ? sys_newfstat+0x1f/0x50
[  147.033039]  [<ffffffff81383c5f>] ? page_fault+0x1f/0x30
[  147.033043]  [<ffffffff81002c6b>] ? system_call_fastpath+0x16/0x1b
[  147.033044] Code: 80 00 00 00 00 53 48 83 ec 20 48 89 e6 c7 04 24 01 00 00 00 48 c7 44 24 08 00 00 00 00 48 c7 44 24 10 ff ff ff ff e8 9a d2 1d 00 <8b> 58 40 48 89 c7 e8 0f d6 1d 00 48 83 c4 20 48 89 d8 5b c3 66 
[  147.033069] RIP  [<ffffffffa006d416>] filelayout_get_stripesize+0x26/0x40 [nfs_layout_nfsv41_files]
[  147.033074]  RSP <ffff880022d2dcd8>
[  147.033075] CR2: 0000000000000040
[  147.033078] ---[ end trace 05c1332f3cd1e048 ]---

--------------060801040104090606050908--
