Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27117 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758468Ab0DWSEr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 14:04:47 -0400
Message-ID: <4BD1E12A.5060704@oracle.com>
Date: Fri, 23 Apr 2010 14:04:26 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Jan Engelhardt <jengelh@medozas.de>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs4 hangs when rpcbind is not reachable
References: <alpine.LSU.2.01.1004231717180.2242@obet.zrqbmnf.qr> <4BD1BD72.2030709@oracle.com> <alpine.LSU.2.01.1004231750380.20942@obet.zrqbmnf.qr> <4BD1C4EC.8050404@oracle.com> <alpine.LSU.2.01.1004231818250.21405@obet.zrqbmnf.qr> <4BD1D21E.7080506@oracle.com> <alpine.LSU.2.01.1004231905300.23157@obet.zrqbmnf.qr>
In-Reply-To: <alpine.LSU.2.01.1004231905300.23157@obet.zrqbmnf.qr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/23/2010 01:39 PM, Jan Engelhardt wrote:
>
> On Friday 2010-04-23 19:00, Chuck Lever wrote:
>>
>>> Well yeah, to use NFS as a root, -o nolock is commonly used.
>>
>> NFSv4 is known not to work for NFSROOT [...] One problem is that idmapper has
>> to be running to prevent NFSv4 deadlocks.
>
> Man who says cannot be done should not interrupt man doing it :-)

NFSROOT is not the same as a user space NFS mount, which is what you are 
doing here.  NFSROOT is an implementation of NFS mounting glued into the 
kernel's IPv4 autoconfiguration logic.  See fs/nfs/nfsroot.c.

In fact, true NFSROOT is known not to support NFSv4 at all.  And using 
NFSv4 as your root file system is not supported, even though you may get 
some usage out of it, because of the potential deadlock issue I mentioned.

That's not the same as saying "you can't possibly do this."

>> (although you are using mount.nfs4 from an initramfs, not NFSROOT).
>
> Well, pivot-rooting into an nfsv4 essentially makes it an nfsroot. For added
> fun, there's also AUFS in the game.

Strictly speaking, NFSROOT is not the same as pivoting to NFS from an 
initramfs.  I'm not arguing for the fun of it... I don't want others who 
may be watching the list to get the wrong impression about what is and 
is not supported at this time.

>> I'm just a little surprised because I was not aware that anyone was doing user
>> space NFS mounts in an environment with no lo configured.
>>
>> If you have an initramfs mounted as root, the ramfs's init scripts probably
>> could get lo going before doing the mount, in this case.
>
> They do, now.

Does that mean you now have a workaround for this?  You're not stuck?

>> However, this work was planned for a time when lo is replaced with lo6 in a
>> large number of cases, which should be some time in the future. Your report is
>> accelerating this use case!  :-)
>
> lo6?
> - the kernel only allows one loopback device
>    (it does have multiple ones already, one per namespace, so makes me wonder
>    why there can't be multiple ones. Solaris has lo0 too, right? Basically
>    lo would just be a veth-like device where one end is both ends.)
> - lo6 as in.. IPv6? lo already has ::1/128 assigned.

Yes, when lo is no longer assigned an IPv4 address, we will need to make 
the kernel and user space communicate without assuming the loopback 
address is 127.0.0.1.

>> I'd like to see the full log captured during your test, with time stamps. 110
>> is ETIMEDOUT, which suggests the network layer is not reporting that the
>> loopback interface is not up, but simply that the SYN is timing out.
>>
>> And if you could, "^-s trans^-s trans xprt clnt sched bind".
>
> It does not know about clnt. That btw, the manpage for rpcbind is also
> incomplete - does not list xprt, sched, bind.

Use "rpcdebug -vh" to see a full list of supported flags.  For some 
reason, clnt is "call", and I always forget that.

A few more notes below.

> [nfs-utils-1.1.3]
>
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 2.6.33.2-jen97-default (geeko@buildhost) (gcc version 4.4.1 [gcc-4_4-branch revision 150839] (SUSE Linux) ) #1 SMP 2010-04-02 16:56:15 +0200
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
> [    0.000000]  BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000e2000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 000000007f7b0000 (usable)
> [    0.000000]  BIOS-e820: 000000007f7b0000 - 000000007f7be000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000007f7be000 - 000000007f7f0000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 000000007f7f0000 - 000000007f800000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
> [    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
> [    0.000000] DMI present.
> [    0.000000] AMI BIOS detected: BIOS may corrupt low RAM, working around it.
> [    0.000000] last_pfn = 0x7f7b0 max_arch_pfn = 0x100000
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
> [    0.000000] Scanning 0 areas for low memory corruption
> [    0.000000] modified physical RAM map:
> [    0.000000]  modified: 0000000000000000 - 0000000000010000 (reserved)
> [    0.000000]  modified: 0000000000010000 - 000000000009f400 (usable)
> [    0.000000]  modified: 000000000009f400 - 00000000000a0000 (reserved)
> [    0.000000]  modified: 00000000000e2000 - 0000000000100000 (reserved)
> [    0.000000]  modified: 0000000000100000 - 000000007f7b0000 (usable)
> [    0.000000]  modified: 000000007f7b0000 - 000000007f7be000 (ACPI data)
> [    0.000000]  modified: 000000007f7be000 - 000000007f7f0000 (ACPI NVS)
> [    0.000000]  modified: 000000007f7f0000 - 000000007f800000 (reserved)
> [    0.000000]  modified: 00000000fee00000 - 00000000fee01000 (reserved)
> [    0.000000]  modified: 00000000fff80000 - 0000000100000000 (reserved)
> [    0.000000] found SMP MP-table at [b00ff780] ff780
> [    0.000000] init_memory_mapping: 0000000000000000-00000000473fe000
> [    0.000000] RAMDISK: 7f1de000 - 7f78f9b4
> [    0.000000] Allocated new RAMDISK: 007b9000 - 00d6a9b4
> [    0.000000] Move RAMDISK from 000000007f1de000 - 000000007f78f9b3 to 007b9000 - 00d6a9b3
> [    0.000000] ACPI: RSDP 000f9b30 00014 (v00 HPQOEM)
> [    0.000000] ACPI: RSDT 7f7b0000 00038 (v01 070808 RSDT1330 20080708 MSFT 00000097)
> [    0.000000] ACPI: FACP 7f7b0200 00084 (v02 070808 FACP1330 20080708 MSFT 00000097)
> [    0.000000] ACPI: DSDT 7f7b0440 04D9B (v01  Intel          00000000 INTL 20051117)
> [    0.000000] ACPI: FACS 7f7be000 00040
> [    0.000000] ACPI: APIC 7f7b0390 0006C (v01 070808 APIC1330 20080708 MSFT 00000097)
> [    0.000000] ACPI: MCFG 7f7b0400 0003C (v01 070808 SLIC-CPC 20080708 MSFT 00000097)
> [    0.000000] ACPI: OEMB 7f7be040 00061 (v01 070808 OEMB1330 20080708 MSFT 00000097)
> [    0.000000] ACPI: HPET 7f7b51e0 00038 (v01 070808 SLIC-CPC 20080708 MSFT 00000097)
> [    0.000000] 899MB HIGHMEM available.
> [    0.000000] 1139MB LOWMEM available.
> [    0.000000]   mapped low ram: 0 - 473fe000
> [    0.000000]   low ram: 0 - 473fe000
> [    0.000000]   node 0 low ram: 00000000 - 473fe000
> [    0.000000]   node 0 bootmap 00017000 - 0001fe80
> [    0.000000] (14 early reservations) ==>  bootmem [0000000000 - 00473fe000]
> [    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==>  [0000000000 - 0000001000]
> [    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==>  [0000001000 - 0000002000]
> [    0.000000]   #2 [0000200000 - 00007b4150]    TEXT DATA BSS ==>  [0000200000 - 00007b4150]
> [    0.000000]   #3 [00007b5000 - 00007b812f]              BRK ==>  [00007b5000 - 00007b812f]
> [    0.000000]   #4 [00000ff790 - 0000100000]    BIOS reserved ==>  [00000ff790 - 0000100000]
> [    0.000000]   #5 [00000ff780 - 00000ff790]     MP-table mpf ==>  [00000ff780 - 00000ff790]
> [    0.000000]   #6 [000009f000 - 00000fd190]    BIOS reserved ==>  [000009f000 - 00000fd190]
> [    0.000000]   #7 [00000fd2b8 - 00000ff780]    BIOS reserved ==>  [00000fd2b8 - 00000ff780]
> [    0.000000]   #8 [00000fd190 - 00000fd2b8]     MP-table mpc ==>  [00000fd190 - 00000fd2b8]
> [    0.000000]   #9 [0000010000 - 0000011000]       TRAMPOLINE ==>  [0000010000 - 0000011000]
> [    0.000000]   #10 [0000011000 - 0000015000]      ACPI WAKEUP ==>  [0000011000 - 0000015000]
> [    0.000000]   #11 [0000015000 - 0000017000]          PGTABLE ==>  [0000015000 - 0000017000]
> [    0.000000]   #12 [00007b9000 - 0000d6a9b4]      NEW RAMDISK ==>  [00007b9000 - 0000d6a9b4]
> [    0.000000]   #13 [0000017000 - 0000020000]          BOOTMAP ==>  [0000017000 - 0000020000]
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00000010 ->  0x00001000
> [    0.000000]   Normal   0x00001000 ->  0x000473fe
> [    0.000000]   HighMem  0x000473fe ->  0x0007f7b0
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[2] active PFN ranges
> [    0.000000]     0: 0x00000010 ->  0x0000009f
> [    0.000000]     0: 0x00000100 ->  0x0007f7b0
> [    0.000000] Using APIC driver default
> [    0.000000] ACPI: PM-Timer IO Port: 0x808
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
> [    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
> [    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
> [    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
> [    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e2000
> [    0.000000] PM: Registered nosave memory: 00000000000e2000 - 0000000000100000
> [    0.000000] Allocating PCI resources starting at 7f800000 (gap: 7f800000:7f600000)
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:4 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 13 pages/cpu @b2000000 s28696 r0 d24552 u1048576
> [    0.000000] pcpu-alloc: s28696 r0 d24552 u1048576 alloc=1*4194304
> [    0.000000] pcpu-alloc: [0] 0 1 2 3
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 517967
> [    0.000000] Kernel command line: initrd=suse-11.2/initrd root=aufs://?nfs4@134.76.82.235:/@/.STATIC@rr,nolock&tmpfs@/.DYNAMIC@rw i915.modeset=0 console=tty0 console=ttyS0,115200 BOOT_IMAGE=suse-11.2/live
> [    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
> [    0.000000] Dentry cache hash table entries: 262144 (order: 8, 1048576 bytes)
> [    0.000000] Inode-cache hash table entries: 131072 (order: 7, 524288 bytes)
> [    0.000000] Enabling fast FPU save and restore... done.
> [    0.000000] Enabling unmasked SIMD FPU exception support... done.
> [    0.000000] Initializing CPU#0
> [    0.000000] Initializing HighMem for node 0 (000473fe:0007f7b0)
> [    0.000000] Memory: 2057204k/2088640k available (2622k kernel code, 29856k reserved, 2431k data, 392k init, 921288k highmem)
> [    0.000000] virtual kernel memory layout:
> [    0.000000]     fixmap  : 0xffd55000 - 0xfffff000   (2728 kB)
> [    0.000000]     pkmap   : 0xff400000 - 0xff800000   (4096 kB)
> [    0.000000]     vmalloc : 0xf7bfe000 - 0xff3fe000   ( 120 MB)
> [    0.000000]     lowmem  : 0xb0000000 - 0xf73fe000   (1139 MB)
> [    0.000000]       .init : 0xb06f0000 - 0xb0752000   ( 392 kB)
> [    0.000000]       .data : 0xb048f993 - 0xb06ef670   (2431 kB)
> [    0.000000]       .text : 0xb0200000 - 0xb048f993   (2622 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] NR_IRQS:2304 nr_irqs:440
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] console [ttyS0] enabled
> [    0.000000] Fast TSC calibration using PIT
> [    0.000000] Detected 1595.980 MHz processor.
> [    0.008008] Calibrating delay loop (skipped), value calculated using timer frequency.. 3191.96 BogoMIPS (lpj=6383920)
> [    0.016092] Security Framework initialized
> [    0.020020] AppArmor: AppArmor initialized
> [    0.024046] Mount-cache hash table entries: 512
> [    0.028216] Initializing cgroup subsys ns
> [    0.032011] Initializing cgroup subsys cpuacct
> [    0.036011] Initializing cgroup subsys memory
> [    0.040016] Initializing cgroup subsys devices
> [    0.044006] Initializing cgroup subsys freezer
> [    0.048006] Initializing cgroup subsys net_cls
> [    0.052006] Initializing cgroup subsys blkio
> [    0.056061] CPU: Physical Processor ID: 0
> [    0.060006] CPU: Processor Core ID: 0
> [    0.064008] mce: CPU supports 5 MCE banks
> [    0.068016] CPU0: Thermal monitoring enabled (TM2)
> [    0.072008] using mwait in idle threads.
> [    0.076015] Performance Events: Atom events, Intel PMU driver.
> [    0.084010] ... version:                3
> [    0.088005] ... bit width:              40
> [    0.092005] ... generic registers:      2
> [    0.096006] ... value mask:             000000ffffffffff
> [    0.100005] ... max period:             000000007fffffff
> [    0.104005] ... fixed-purpose events:   3
> [    0.108005] ... event mask:             0000000700000003
> [    0.112011] Checking 'hlt' instruction... OK.
> [    0.133875] ACPI: Core revision 20091214
> [    0.150225] Enabling APIC mode:  Flat.  Using 1 I/O APICs
> [    0.152339] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.197790] CPU0: Intel(R) Atom(TM) CPU  230   @ 1.60GHz stepping 02
> [    0.208000] Booting Node   0, Processors  #1
> [    0.012000] Initializing CPU#1
> [    0.300042] Brought up 2 CPUs
> [    0.304006] Total of 2 processors activated (6383.90 BogoMIPS).
> [    0.308387] devtmpfs: initialized
> [    0.312223] regulator: core version 0.5
> [    0.316037] Time: 13:32:55  Date: 04/23/10
> [    0.320103] NET: Registered protocol family 16
> [    0.324237] ACPI: bus type pci registered
> [    0.328120] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xe0000000-0xe3ffffff] (base 0xe0000000)
> [    0.336004] PCI: Intel Corporation 945G/GZ/P/PL Express Memory Controller Hub with MMCONFIG support
> [    0.348007] PCI: not using MMCONFIG
> [    0.352236] PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=2
> [    0.356004] PCI: Using configuration type 1 for base access
> [    0.365262] bio: create slab<bio-0>  at 0
> [    0.380353] ACPI: Executed 1 blocks of module-level executable AML code
> [    0.399412] ACPI: Interpreter enabled
> [    0.400008] ACPI: (supports S0 S3 S4 S5)
> [    0.405249] ACPI: Using IOAPIC for interrupt routing
> [    0.430262] ACPI Warning: Incorrect checksum in table [OEMB] - 3C, should be 3B (20091214/tbutils-314)
> [    0.440133] ACPI: No dock devices found.
> [    0.444293] ACPI: PCI Root Bridge [PCI0] (0000:00)
> [    0.448067] pci_root PNP0A08:00: ignoring host bridge windows from ACPI; boot with "pci=use_crs" to use them
> [    0.460573] pci 0000:00:1f.0: quirk: [io  0x0800-0x087f] claimed by ICH6 ACPI/GPIO/TCO
> [    0.468008] pci 0000:00:1f.0: quirk: [io  0x0480-0x04bf] claimed by ICH6 GPIO
> [    0.472007] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0a00 (mask 00ff)
> [    0.480480] pci 0000:01:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
> [    0.492049] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
> [    0.496073] pci 0000:00:1e.0: PCI bridge to [bus 02-02] (subtractive decode)
> [    0.526939] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 11 12 14 15)
> [    0.534562] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
> [    0.543558] ACPI: PCI Interrupt Link [LNKC] (IRQs *3 4 5 6 7 10 11 12 14 15)
> [    0.551194] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 *11 12 14 15)
> [    0.558971] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
> [    0.568139] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
> [    0.577445] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
> [    0.586459] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 7 10 11 12 14 15)
> [    0.594260] SCSI subsystem initialized
> [    0.596156] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
> [    0.608018] vgaarb: loaded
> [    0.610788] PCI: Using ACPI for IRQ routing
> [    0.616263] NetLabel: Initializing
> [    0.619698] NetLabel:  domain hash size = 128
> [    0.624003] NetLabel:  protocols = UNLABELED CIPSOv4
> [    0.628026] NetLabel:  unlabeled traffic allowed by default
> [    0.632012] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
> [    0.640008] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
> [    0.645024] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
> [    0.656021] Switching to clocksource tsc
> [    0.660156] AppArmor: AppArmor Filesystem Enabled
> [    0.664916] pnp: PnP ACPI init
> [    0.668025] ACPI: bus type pnp registered
> [    0.679607] pnp: PnP ACPI: found 16 devices
> [    0.683839] ACPI: ACPI bus type pnp unregistered
> [    0.688496] PnPBIOS: Disabled by ACPI PNP
> [    0.692563] system 00:01: [mem 0xfed13000-0xfed19fff] has been reserved
> [    0.699232] system 00:08: [io  0x0a00-0x0adf] has been reserved
> [    0.705195] system 00:08: [io  0x0ae0-0x0aef] has been reserved
> [    0.711166] system 00:09: [io  0x04d0-0x04d1] has been reserved
> [    0.717130] system 00:09: [io  0x0800-0x087f] has been reserved
> [    0.723092] system 00:09: [io  0x0480-0x04bf] has been reserved
> [    0.729059] system 00:09: [mem 0xfed1c000-0xfed1ffff] has been reserved
> [    0.735717] system 00:09: [mem 0xfed20000-0xfed8ffff] has been reserved
> [    0.742380] system 00:0c: [mem 0xffc00000-0xfff7ffff] has been reserved
> [    0.749046] system 00:0d: [mem 0xfec00000-0xfec00fff] could not be reserved
> [    0.756049] system 00:0d: [mem 0xfee00000-0xfee00fff] has been reserved
> [    0.762714] system 00:0e: [mem 0xe0000000-0xe3ffffff] has been reserved
> [    0.769377] system 00:0f: [mem 0x00000000-0x0009ffff] could not be reserved
> [    0.776383] system 00:0f: [mem 0x000c0000-0x000cffff] could not be reserved
> [    0.783383] system 00:0f: [mem 0x000e0000-0x000fffff] could not be reserved
> [    0.790390] system 00:0f: [mem 0x00100000-0x7f7fffff] could not be reserved
> [    0.832529] pci 0000:00:1c.0: BAR 15: assigned [mem 0x80000000-0x801fffff 64bit pref]
> [    0.840418] pci 0000:00:1c.0: BAR 13: assigned [io  0x1000-0x1fff]
> [    0.846640] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
> [    0.851906] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
> [    0.858042] pci 0000:00:1c.0:   bridge window [mem 0xfeb00000-0xfebfffff]
> [    0.864872] pci 0000:00:1c.0:   bridge window [mem 0x80000000-0x801fffff 64bit pref]
> [    0.872672] pci 0000:00:1e.0: PCI bridge to [bus 02-02]
> [    0.877934] pci 0000:00:1e.0:   bridge window [io  disabled]
> [    0.883638] pci 0000:00:1e.0:   bridge window [mem disabled]
> [    0.889337] pci 0000:00:1e.0:   bridge window [mem pref disabled]
> [    0.895482] pci 0000:00:1c.0: enabling device (0106 ->  0107)
> [    0.901204] pci 0000:00:1c.0: PCI INT A ->  GSI 16 (level, low) ->  IRQ 16
> [    0.908122] NET: Registered protocol family 2
> [    0.912674] IP route cache hash table entries: 65536 (order: 6, 262144 bytes)
> [    0.920642] TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
> [    0.930044] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
> [    0.937150] TCP: Hash tables configured (established 262144 bind 65536)
> [    0.943826] TCP reno registered
> [    0.947014] UDP hash table entries: 1024 (order: 3, 32768 bytes)
> [    0.953090] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
> [    0.959878] NET: Registered protocol family 1
> [    0.964555] Unpacking initramfs...
> [    1.274274] Freeing initrd memory: 5830k freed
> [    1.284933] Scanning for low memory corruption every 60 seconds
> [    1.291240] audit: initializing netlink socket (disabled)
> [    1.296709] type=2000 audit(1272029574.296:1): initialized
> [    1.317288] highmem bounce pool size: 64 pages
> [    1.321801] HugeTLB registered 4 MB page size, pre-allocated 0 pages
> [    1.328594] VFS: Disk quotas dquot_6.5.2
> [    1.332625] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
> [    1.339345] msgmni has been set to 2232
> [    1.343602] alg: No test for stdrng (krng)
> [    1.347822] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
> [    1.355283] io scheduler noop registered
> [    1.359282] io scheduler cfq registered (default)
> [    1.364468] pci-stub: invalid id string ""
> [    1.368766] isapnp: Scanning for PnP cards...
> [    1.726179] isapnp: No Plug&  Play device found
> [    1.733885] rpldhk 2.40, by Jan Engelhardt, 2004 - 2009
> [    1.739583] Serial: 8250/16550 driver, 16 ports, IRQ sharing disabled
> [    1.746221] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> [    1.753404] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> [    1.759482] Fixed MDIO Bus: probed
> [    1.763034] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
> [    1.769255] PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
> [    1.779109] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    1.784210] rtc_cmos 00:03: RTC can wake from S4
> [    1.788993] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
> [    1.795174] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
> [    1.802049] cpuidle: using governor ladder
> [    1.806200] cpuidle: using governor menu
> [    1.810755] TCP hybla registered
> [    1.814152] NET: Registered protocol family 10
> [    1.819402] lo: Disabled Privacy Extensions
> [    1.823865] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
> [    1.824318] Using IPI No-Shortcut mode
> [    1.824572] registered taskstats version 1
> [    1.825006]   Magic number: 6:571:534
> [    1.825016] tty ttyS14: hash matches
> [    1.847742] rtc_cmos 00:03: setting system clock to 2010-04-23 13:32:56 UTC (1272029576)
> [    1.856000] Freeing unused kernel memory: 392k freed
> [    1.861318] Write protecting the kernel text: 2624k
> [    1.866316] Write protecting the kernel read-only data: 2216k
> doing fast boot
> [    1.945918] aufs 2-standalone.tree-33-20100412
> [    2.009182] RPC: Registered udp transport module.
> [    2.013954] RPC: Registered tcp transport module.
> [    2.018699] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [    2.049976] Slow work thread pool: Starting up
> [    2.054582] Slow work thread pool: Ready
> [    2.058622] FS-Cache: Loaded
> [    2.113264] FS-Cache: Netfs 'nfs' registered for caching
> [    2.133025] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
> [    2.138999] e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
> [    2.175097] via-rhine.c:v1.10-LK1.4.3 2007-03-06 Written by Donald Becker
> [    2.190410] Atheros(R) L2 Ethernet Driver - version 2.2.3
> [    2.195866] Copyright (c) 2007 Atheros Corporation.
> [    2.200840] atl2 0000:01:00.0: PCI INT A ->  GSI 16 (level, low) ->  IRQ 16
> Creating device nodes with udev
> udevd[83]: specified group 'tty' unknown
>
> ude[    2.345592] udev: starting version 146
> vd[83]: specified group 'dialout' unknown
>
> udevd[83]: specified group 'kmem' unknown
>
> udevd[83]: specified group 'video' unknown
>
> udevd[83]: specified group 'lp' unknown
>
> udevd[83]: specified group 'disk' unknown
>
> udevd[83]: specified group 'floppy' unknown
>
> udevd[83]: specified group 'cdrom' unknown
>
> udevd[83]: specified group 'tape' unknown
>
> [    2.599450] usbcore: registered new interface driver usbfs
> [    2.605181] usbcore: registered new interface driver hub
> [    2.610707] usbcore: registered new device driver usb
> [    2.623243] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    2.629942] ehci_hcd 0000:00:1d.7: PCI INT A ->  GSI 23 (level, low) ->  IRQ 23
> [    2.637211] ehci_hcd 0000:00:1d.7: EHCI Host Controller
> [    2.642554] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
> [    2.650052] ehci_hcd 0000:00:1d.7: using broken periodic workaround
> [    2.656379] ehci_hcd 0000:00:1d.7: debug port 1
> [    2.664872] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfea37c00
> [    2.684531] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
> [    2.690406] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
> [    2.697239] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    2.704511] usb usb1: Product: EHCI Host Controller
> [    2.709427] usb usb1: Manufacturer: Linux 2.6.33.2-jen97-default ehci_hcd
> [    2.716256] usb usb1: SerialNumber: 0000:00:1d.7
> [    2.721200] hub 1-0:1.0: USB hub found
> [    2.725015] hub 1-0:1.0: 8 ports detected
> [    2.746206] uhci_hcd: USB Universal Host Controller Interface driver
> [    2.752712] uhci_hcd 0000:00:1d.0: PCI INT A ->  GSI 23 (level, low) ->  IRQ 23
> [    2.759912] uhci_hcd 0000:00:1d.0: UHCI Host Controller
> [    2.765201] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
> [    2.772683] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e880
> [    2.778555] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
> [    2.785448] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    2.792757] usb usb2: Product: UHCI Host Controller
> [    2.797698] usb usb2: Manufacturer: Linux 2.6.33.2-jen97-default uhci_hcd
> [    2.804528] usb usb2: SerialNumber: 0000:00:1d.0
> [    2.809497] hub 2-0:1.0: USB hub found
> [    2.813312] hub 2-0:1.0: 2 ports detected
> [    2.817500] uhci_hcd 0000:00:1d.1: PCI INT B ->  GSI 19 (level, low) ->  IRQ 19
> [    2.824694] uhci_hcd 0000:00:1d.1: UHCI Host Controller
> [    2.829980] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
> [    2.837484] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e800
> [    2.843351] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
> [    2.850184] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    2.857461] usb usb3: Product: UHCI Host Controller
> [    2.862382] usb usb3: Manufacturer: Linux 2.6.33.2-jen97-default uhci_hcd
> [    2.869215] usb usb3: SerialNumber: 0000:00:1d.1
> [    2.874157] hub 3-0:1.0: USB hub found
> [    2.877967] hub 3-0:1.0: 2 ports detected
> [    2.882163] uhci_hcd 0000:00:1d.2: PCI INT C ->  GSI 18 (level, low) ->  IRQ 18
> [    2.889367] uhci_hcd 0000:00:1d.2: UHCI Host Controller
> [    2.894657] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
> [    2.902156] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e480
> [    2.908031] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
> [    2.914862] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    2.922135] usb usb4: Product: UHCI Host Controller
> [    2.927057] usb usb4: Manufacturer: Linux 2.6.33.2-jen97-default uhci_hcd
> [    2.933892] usb usb4: SerialNumber: 0000:00:1d.2
> [    2.938838] hub 4-0:1.0: USB hub found
> [    2.942650] hub 4-0:1.0: 2 ports detected
> [    2.946821] uhci_hcd 0000:00:1d.3: PCI INT D ->  GSI 16 (level, low) ->  IRQ 16
> [    2.954020] uhci_hcd 0000:00:1d.3: UHCI Host Controller
> [    2.959303] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
> [    2.969046] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000e400
> [    2.974907] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
> [    2.981741] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> [    2.989023] usb usb5: Product: UHCI Host Controller
> [    2.993945] usb usb5: Manufacturer: Linux 2.6.33.2-jen97-default uhci_hcd
> [    3.000782] usb usb5: SerialNumber: 0000:00:1d.3
> [    3.005718] hub 5-0:1.0: USB hub found
> [    3.009532] hub 5-0:1.0: 2 ports detected
> Boot logging started on /dev/char/../ttyS0(/dev/console) at Fri Apr 23 15:32:57 2010
> [    3.209997] NET: Registered protocol family 17
> running dhcpcd o[    3.236794] ADDRCONF(NETDEV_UP): eth0: link is not ready
> n interface eth0
> [    3.774552] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
> [    3.780788] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 134.76.82.235:/ (nfs4) ->  /.STATIC (rr,nolock)

Odd... I wouldn't think nolock is required for NFSv4, since it doesn't 
use statd (and thus does not need a writeable /var/lib/nfs/statd .

> starting shell before attempting this mount
> sh: cannot set terminal process group (-1): Inappropriate ioctl for device
> sh: no job control in this shell
> sh-4.0# ip l s dev lo down
> sh-4.0# rpcdebug -m rpc -s trans xprt clnt sched bind
> rpcdebug: unknown module or flag rpc/clnt
> sh-4.0# rpcdebug -m rpc -s trans xprt sched bind
> rpc        xprt bind sched trans
> sh-4.0# mount -tnfs4 134.76.82.235:/ /.STATIC -o nolock&
> [1] 300
> [   95.008417] RPC:       set up xprt to 134.76.82.235 (port 2049) via tcp
> sh-4.0# [   95.015936] RPC:       created transport f67f8000 with 16 slots
> [   95.022592] RPC:       new task initialized, procpid 301
> [   95.027946] RPC:       allocated task f6552ec0
> [   95.032431] RPC:     1 __rpc_execute flags=0x680
> [   95.037089] RPC:     1 reserved req f65dc000 xid e0d63066
> [   95.042532] RPC:     1 allocated buffer of size 92 at f6637800
> [   95.048404] RPC:     1 xprt_connect xprt f67f8000 is not connected
> [   95.054630] RPC:     1 sleep_on(queue "xprt_pending" time 4294916059)
> [   95.061111] RPC:     1 added to queue f67f81f4 "xprt_pending"
> [   95.066899] RPC:     1 setting alarm for 60000 ms
> [   95.071644] RPC:       xs_connect scheduled xprt f67f8000
> [   95.077090] RPC:     1 sync task going to sleep
> [   95.081720] RPC:       xs_bind4 0.0.0.0:869: ok (0)
> [   95.086655] RPC:       worker connecting xprt f67f8000 via tcp to 134.76.82.235 (port 2049)
> [   95.095108] RPC:       f67f8000 connect status 115 connected 0 sock state 2
> [   95.102983] RPC:       xs_tcp_state_change client f67f8000...
> [   95.106949] RPC:       state 1 conn 0 dead 0 zapped 1
> [   95.106949] RPC:     1 __rpc_wake_up_task (now 4294916072)
> [   95.106949] RPC:     1 disabling timer
> [   95.106949] RPC:     1 removed from queue f67f81f4 "xprt_pending"
> [   95.106949] RPC:       __rpc_wake_up_task done
> [   95.106949] RPC:     1 sync task resuming
> [   95.137856] RPC:     1 xprt_connect_status: retrying
> [   95.142863] RPC:     1 xprt_prepare_transmit
> [   95.147174] RPC:     1 xprt_transmit(44)
> [   95.151157] RPC:       xs_tcp_send_request(44) = 44
> [   95.156098] RPC:       xs_tcp_data_ready...
> [   95.160329] RPC:       xs_tcp_data_recv started
> [   95.164904] RPC:       reading TCP record fragment of length 24
> [   95.170864] RPC:       reading XID (4 bytes)
> [   95.175174] RPC:       reading request with XID e0d63066
> [   95.180527] RPC:       reading CALL/REPLY flag (4 bytes)
> [   95.185879] RPC:       reading reply for CALL/REPLY flag 01000000
> [   95.192012] RPC:       read reply XID e0d63066
> [   95.196495] RPC:       XID e0d63066 read 16 bytes
> [   95.201239] RPC:       xprt = f67f8000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
> [   95.209468] RPC:     1 xid e0d63066 complete (24 bytes received)
> [   95.215516] RPC:       xs_tcp_data_recv done
> [   95.219831] RPC:     1 xmit complete
> [   95.223450] RPC:       wake_up_next(f67f8184 "xprt_resend")
> [   95.229062] RPC:       wake_up_next(f67f8114 "xprt_sending")
> [   95.234764] RPC:     1 return 0, status 0
> [   95.238815] RPC:     1 release task
> [   95.242347] RPC:       freeing buffer of size 92 at f6637800
> [   95.248048] RPC:     1 release request f65dc000
> [   95.252617] RPC:       wake_up_next(f67f8264 "xprt_backlog")
> [   95.258317] RPC:     1 freeing task
> [   95.261958] RPC:       set up xprt to 127.0.0.1 (port 111) via tcp
> [   95.268189] RPC:       created transport f66ea800 with 16 slots
> [   95.274156] RPC:       new task initialized, procpid 301
> [   95.279508] RPC:       allocated task f6552ec0
> [   95.283990] RPC:     2 __rpc_execute flags=0x680

Without "call" we can't see what request this is.  I'll guess that this 
is an RPCB_UNSET.

Do you have upstream commit 49697ee7 applied to this kernel?  That would 
prevent the NFSv4 client from attempting to do local rpcbind operations 
altogether.

> [   95.288665] RPC:     2 reserved req f66e7000 xid 597eb9aa
> [   95.294111] RPC:     2 allocated buffer of size 92 at f6637800
> [   95.299985] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [   95.306208] RPC:     2 sleep_on(queue "xprt_pending" time 4294916122)
> [   95.312689] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [   95.318478] RPC:     2 setting alarm for 60000 ms
> [   95.323223] RPC:       xs_connect scheduled xprt f66ea800
> [   95.328670] RPC:     2 sync task going to sleep
> [   95.333278] RPC:       xs_bind4 0.0.0.0:732: ok (0)
> [   95.338200] RPC:       worker connecting xprt f66ea800 via tcp to 127.0.0.1 (port 111)
> [   95.346213] RPC:       f66ea800 connect status 115 connected 0 sock state 2

So we did the kernel_connect() call here, and it returned EINPROGRESS, 
as expected.

> [  116.344016] RPC:       xs_error_report client f66ea800...
> [  116.344020] RPC:       error 110

21 seconds later, we get ETIMEDOUT from the network layer.  Will pursue 
this with the networking folks.

> [  116.352723] RPC:     2 __rpc_wake_up_task (now 4294921384)
> [  116.358246] RPC:     2 disabling timer
> [  116.362032] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  116.368166] RPC:       __rpc_wake_up_task done
> [  116.372653] RPC:       xs_tcp_state_change client f66ea800...
> [  116.378439] RPC:       state 7 conn 0 dead 0 zapped 1
> [  116.383527] RPC:       disconnected transport f66ea800
> [  116.388716] RPC:     2 sync task resuming
> [  116.392775] RPC:     2 xprt_connect_status: retrying
> [  116.397784] RPC:     2 xprt_prepare_transmit
> [  116.402099] RPC:     2 xprt_transmit(44)
> [  116.406067] RPC:       xs_tcp_send_request(44) = -110
> [  116.411159] RPC:       sendmsg returned unrecognized error 110
> [  116.417034] RPC:       xs_tcp_state_change client f66ea800...
> [  116.422822] RPC:       state 7 conn 0 dead 0 zapped 1
> [  116.427917] RPC:       disconnected transport f66ea800
> [  116.433097] RPC:       wake_up_next(f66ea984 "xprt_resend")
> [  116.438714] RPC:       wake_up_next(f66ea914 "xprt_sending")
> [  116.444418] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  116.450639] RPC:     2 sleep_on(queue "xprt_pending" time 4294921408)
> [  116.457121] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  116.462908] RPC:     2 setting alarm for 60000 ms
> [  116.467656] RPC:       xs_connect scheduled xprt f66ea800
> [  116.473103] RPC:     2 sync task going to sleep
> [  116.477682] RPC:       disconnecting xprt f66ea800 to reuse port
> [  116.483737] RPC:       xs_error_report client f66ea800...
> [  116.483740] RPC:       error 0
> [  116.492258] RPC:     2 __rpc_wake_up_task (now 4294921419)
> [  116.497782] RPC:     2 disabling timer
> [  116.501574] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  116.507710] RPC:       __rpc_wake_up_task done
> [  116.508519] RPC:     2 sync task resuming
> [  116.508523] RPC:     2 xprt_connect_status: retrying
> [  116.508528] RPC:     2 xprt_prepare_transmit
> [  116.508533] RPC:     2 xprt_transmit(44)
> [  116.529501] RPC:       disconnected transport f66ea800
> [  116.529507] RPC:       xs_tcp_send_request(44) = -32
> [  116.529512] RPC:       xs_tcp_state_change client f66ea800...
> [  116.529518] RPC:       state 7 conn 0 dead 0 zapped 1
> [  116.529523] RPC:       disconnected transport f66ea800
> [  116.529529] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  116.529536] RPC:     2 sleep_on(queue "xprt_pending" time 4294921428)
> [  116.529542] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  116.529546] RPC:     2 setting alarm for 60000 ms
> [  116.529552] RPC:     2 sync task going to sleep
> [  116.583446] RPC:     2 __rpc_wake_up_task (now 4294921441)
> [  116.588971] RPC:     2 disabling timer
> [  116.592761] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  116.598899] RPC:       __rpc_wake_up_task done
> [  116.598904] RPC:     2 sync task resuming
> [  116.598908] RPC:     2 xprt_connect_status: retrying
> [  116.598913] RPC:     2 xprt_prepare_transmit
> [  116.616734] RPC:       worker connecting xprt f66ea800 via tcp to 127.0.0.1 (port 111)
> [  116.616740] RPC:     2 xprt_transmit(44)
> [  116.616747] RPC:       xs_tcp_send_request(44) = -32
> [  116.616752] RPC:       xs_tcp_state_change client f66ea800...
> [  116.616758] RPC:       state 7 conn 0 dead 0 zapped 1
> [  116.616762] RPC:       disconnected transport f66ea800
> [  116.616769] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  116.616775] RPC:     2 sleep_on(queue "xprt_pending" time 4294921450)
> [  116.616781] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  116.616786] RPC:     2 setting alarm for 60000 ms
> [  116.616791] RPC:     2 sync task going to sleep
> [  116.677448] RPC:       f66ea800 connect status 115 connected 0 sock state 2
> [  137.676014] RPC:       xs_error_report client f66ea800...
> [  137.676018] RPC:       error 110
> [  137.684724] RPC:     2 __rpc_wake_up_task (now 4294926717)
> [  137.690250] RPC:     2 disabling timer
> [  137.694040] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  137.700176] RPC:       __rpc_wake_up_task done
> [  137.700183] RPC:     2 sync task resuming
> [  137.700188] RPC:     2 xprt_connect_status: retrying
> [  137.700193] RPC:     2 xprt_prepare_transmit
> [  137.700199] RPC:     2 xprt_transmit(44)
> [  137.721944] RPC:       xs_tcp_state_change client f66ea800...
> [  137.727730] RPC:       state 7 conn 0 dead 0 zapped 1
> [  137.732822] RPC:       disconnected transport f66ea800
> [  137.738014] RPC:       xs_tcp_send_request(44) = -110
> [  137.743107] RPC:       sendmsg returned unrecognized error 110
> [  137.748981] RPC:       xs_tcp_state_change client f66ea800...
> [  137.754766] RPC:       state 7 conn 0 dead 0 zapped 1
> [  137.759858] RPC:       disconnected transport f66ea800
> [  137.765038] RPC:       wake_up_next(f66ea984 "xprt_resend")
> [  137.770651] RPC:       wake_up_next(f66ea914 "xprt_sending")
> [  137.776353] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  137.782575] RPC:     2 sleep_on(queue "xprt_pending" time 4294926741)
> [  137.789056] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  137.794839] RPC:     2 setting alarm for 60000 ms
> [  137.799587] RPC:       xs_connect scheduled xprt f66ea800
> [  137.805037] RPC:     2 sync task going to sleep
> [  137.809633] RPC:       disconnecting xprt f66ea800 to reuse port
> [  137.815686] RPC:       xs_error_report client f66ea800...
> [  137.815689] RPC:       error 0
> [  137.824208] RPC:     2 __rpc_wake_up_task (now 4294926752)
> [  137.829732] RPC:     2 disabling timer
> [  137.833523] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  137.841910] RPC:       __rpc_wake_up_task done
> [  137.844020] RPC:     2 sync task resuming
> [  137.844024] RPC:     2 xprt_connect_status: retrying
> [  137.844029] RPC:     2 xprt_prepare_transmit
> [  137.844034] RPC:     2 xprt_transmit(44)
> [  137.863680] RPC:       disconnected transport f66ea800
> [  137.863686] RPC:       xs_tcp_send_request(44) = -32
> [  137.863691] RPC:       xs_tcp_state_change client f66ea800...
> [  137.863697] RPC:       state 7 conn 0 dead 0 zapped 1
> [  137.863701] RPC:       disconnected transport f66ea800
> [  137.863708] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  137.863714] RPC:     2 sleep_on(queue "xprt_pending" time 4294926761)
> [  137.863720] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  137.863725] RPC:     2 setting alarm for 60000 ms
> [  137.863730] RPC:     2 sync task going to sleep
> [  137.917622] RPC:     2 __rpc_wake_up_task (now 4294926775)
> [  137.923147] RPC:     2 disabling timer
> [  137.926939] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  137.933078] RPC:       __rpc_wake_up_task done
> [  137.933083] RPC:     2 sync task resuming
> [  137.933087] RPC:     2 xprt_connect_status: retrying
> [  137.933092] RPC:     2 xprt_prepare_transmit
> [  137.950903] RPC:       worker connecting xprt f66ea800 via tcp to 127.0.0.1 (port 111)
> [  137.950906] RPC:     2 xprt_transmit(44)
> [  137.950914] RPC:       xs_tcp_send_request(44) = -32
> [  137.950919] RPC:       xs_tcp_state_change client f66ea800...
> [  137.950925] RPC:       state 7 conn 0 dead 0 zapped 1
> [  137.950930] RPC:       disconnected transport f66ea800
> [  137.950936] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  137.950942] RPC:     2 sleep_on(queue "xprt_pending" time 4294926783)
> [  137.950948] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  137.950953] RPC:     2 setting alarm for 60000 ms
> [  137.950959] RPC:     2 sync task going to sleep
> [  138.011614] RPC:       f66ea800 connect status 115 connected 0 sock state 2
> [  159.008018] RPC:       xs_error_report client f66ea800...
> [  159.008023] RPC:       error 110
> [  159.016728] RPC:     2 __rpc_wake_up_task (now 4294932050)
> [  159.022250] RPC:     2 disabling timer
> [  159.026039] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  159.032177] RPC:       __rpc_wake_up_task done
> [  159.032184] RPC:     2 sync task resuming
> [  159.032188] RPC:     2 xprt_connect_status: retrying
> [  159.032193] RPC:     2 xprt_prepare_transmit
> [  159.032200] RPC:     2 xprt_transmit(44)
> [  159.053959] RPC:       xs_tcp_state_change client f66ea800...
> [  159.059747] RPC:       state 7 conn 0 dead 0 zapped 1
> [  159.064840] RPC:       disconnected transport f66ea800
> [  159.070027] RPC:       xs_tcp_send_request(44) = -110
> [  159.075122] RPC:       sendmsg returned unrecognized error 110
> [  159.080996] RPC:       xs_tcp_state_change client f66ea800...
> [  159.086781] RPC:       state 7 conn 0 dead 0 zapped 1
> [  159.091874] RPC:       disconnected transport f66ea800
> [  159.097051] RPC:       wake_up_next(f66ea984 "xprt_resend")
> [  159.102663] RPC:       wake_up_next(f66ea914 "xprt_sending")
> [  159.108366] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  159.114586] RPC:     2 sleep_on(queue "xprt_pending" time 4294932074)
> [  159.121068] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  159.126851] RPC:     2 setting alarm for 60000 ms
> [  159.131595] RPC:       xs_connect scheduled xprt f66ea800
> [  159.137041] RPC:     2 sync task going to sleep
> [  159.141632] RPC:       disconnecting xprt f66ea800 to reuse port
> [  159.147689] RPC:       xs_error_report client f66ea800...
> [  159.147692] RPC:       error 0
> [  159.156212] RPC:     2 __rpc_wake_up_task (now 4294932085)
> [  159.161739] RPC:     2 disabling timer
> [  159.165533] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  159.171670] RPC:       __rpc_wake_up_task done
> [  159.171712] RPC:     2 sync task resuming
> [  159.171716] RPC:     2 xprt_connect_status: retrying
> [  159.171721] RPC:     2 xprt_prepare_transmit
> [  159.171726] RPC:     2 xprt_transmit(44)
> [  159.193456] RPC:       disconnected transport f66ea800
> [  159.193462] RPC:       xs_tcp_send_request(44) = -32
> [  159.193467] RPC:       xs_tcp_state_change client f66ea800...
> [  159.193473] RPC:       state 7 conn 0 dead 0 zapped 1
> [  159.193477] RPC:       disconnected transport f66ea800
> [  159.193484] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  159.193490] RPC:     2 sleep_on(queue "xprt_pending" time 4294932094)
> [  159.193496] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  159.193501] RPC:     2 setting alarm for 60000 ms
> [  159.193506] RPC:     2 sync task going to sleep
> [  159.247406] RPC:     2 __rpc_wake_up_task (now 4294932107)
> [  159.252930] RPC:     2 disabling timer
> [  159.256722] RPC:     2 removed from queue f66ea9f4 "xprt_pending"
> [  159.262860] RPC:       __rpc_wake_up_task done
> [  159.262866] RPC:     2 sync task resuming
> [  159.262870] RPC:     2 xprt_connect_status: retrying
> [  159.262874] RPC:     2 xprt_prepare_transmit
> [  159.280690] RPC:       worker connecting xprt f66ea800 via tcp to 127.0.0.1 (port 111)
> [  159.280695] RPC:     2 xprt_transmit(44)
> [  159.280704] RPC:       xs_tcp_send_request(44) = -32
> [  159.280709] RPC:       xs_tcp_state_change client f66ea800...
> [  159.280714] RPC:       state 7 conn 0 dead 0 zapped 1
> [  159.280719] RPC:       disconnected transport f66ea800
> [  159.280727] RPC:     2 xprt_connect xprt f66ea800 is not connected
> [  159.280733] RPC:     2 sleep_on(queue "xprt_pending" time 4294932116)
> [  159.280739] RPC:     2 added to queue f66ea9f4 "xprt_pending"
> [  159.280744] RPC:     2 setting alarm for 60000 ms
> [  159.280749] RPC:     2 sync task going to sleep
> [  159.341399] RPC:       f66ea800 connect status 115 connected 0 sock state 2

-- 
chuck[dot]lever[at]oracle[dot]com
