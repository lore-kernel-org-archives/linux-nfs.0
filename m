From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd deadlock, 2.6.36-rc3
Date: Wed, 1 Sep 2010 12:54:01 -0400
Message-ID: <20100901165400.GB1201@fieldses.org>
References: <4C7E73CB.7030603@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	neilb@suse.de, Trond.Myklebust@netapp.com
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C7E73CB.7030603@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 01, 2010 at 09:39:55AM -0600, Tim Gardner wrote:
> I've been pursuing a simple reproducer for an NFS lockup that shows
> up under stress. There is a bunch of info (some of it extraneous) in
> http://bugs.launchpad.net/bugs/561210. I can reproduce it by writing
> loop mounted NFS exports:
> 
> /etc/fstab: 127.0.0.1:/srv /mnt/srv nfs rw 0 2
> /etc/exports: /srv 127.0.0.1(rw,insecure,no_subtree_check)
> 
> See the attached scripts test_master.sh and test_client.sh. I simply
> repeat './test_master.sh wait' until nfsd locks up, typically within
> 1-3 cycles, e.g.,

Without looking at the dmesg and scripts carefully to confirm, one
possible explanation is a deadlock when the server can't allocate memory
required to service client requests, memory which the client itself
needs to free by writing back dirty pages, but can't because the server
isn't processing its writes.

For that reason we just don't support loopback mounts--they're OK for
light testing, but it would be difficult to make them completely robust
under load.

So, this isn't a good reproducer.

--b.

> 
> cd /mnt/srv
> while true; do ./test_master.sh wait; done
> 
> Note that this test will run indefinitely if invoked from /srv, e.g.,
> 
> cd /srv
> while true; do ./test_master.sh wait; done
> 
> This issue, or something like it, appears to exist as far back as
> I've tested (Ubuntu Lucid 2.6.32.21). For now I'm assuming that,
> since the symptoms are similar, any lockup bug found in -rc3 is the
> likely culprit.
> 
> See attached dmesg and config. Debug options of interest that I've
> enabled are CONFIG_DEBUG_SLAB, CONFIG_DEBUG_SLAB_LEAK,
> CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_MUTEXES.
> 
> dmesg.txt contains the initial 'INFO: task nfsd:1263 blocked for
> more than 120 seconds.' complaints as well as information dumped
> from
> 
> echo d | sudo tee /proc/sysrq-trigger
> echo w | sudo tee /proc/sysrq-trigger
> 
> Anything else I can provide?
> 
> rtg
> -- 
> Tim Gardner tim.gardner@canonical.com



> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 2.6.36-0-server (root@iserv) (gcc version 4.4.5 20100824 (prerelease) (Ubuntu/Linaro 4.4.4-9ubuntu2) ) #1 SMP Wed Sep 1 08:07:33 MDT 2010 (Ubuntu 2.6.36-0.1-server 2.6.36-rc3)
> [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-2.6.36-0-server root=UUID=089b1b8a-4b0d-40fd-84e8-e28e6ea21d75 ro crashkernel=384M-2G:64M,2G-:128M quiet splash
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009b000 (usable)
> [    0.000000]  BIOS-e820: 000000000009b000 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 000000008c091000 (usable)
> [    0.000000]  BIOS-e820: 000000008c091000 - 000000008c164000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 000000008c164000 - 000000008c581000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000008c581000 - 000000008d981000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 000000008d981000 - 000000008f602000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000008f602000 - 000000008f64f000 (reserved)
> [    0.000000]  BIOS-e820: 000000008f64f000 - 000000008f6d5000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000008f6d5000 - 000000008f6df000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 000000008f6df000 - 000000008f6e2000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000008f6e2000 - 000000008f7cf000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 000000008f7cf000 - 000000008f800000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000008f800000 - 0000000090000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000a0000000 - 00000000b0000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fc000000 - 00000000fd000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
> [    0.000000]  BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
> [    0.000000]  BIOS-e820: 0000000100000000 - 0000000670000000 (usable)
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] DMI 2.5 present.
> [    0.000000] e820 update range: 0000000000000000 - 0000000000001000 (usable) ==> (reserved)
> [    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
> [    0.000000] No AGP bridge found
> [    0.000000] last_pfn = 0x670000 max_arch_pfn = 0x400000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-DFFFF uncachable
> [    0.000000]   E0000-FFFFF write-protect
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 0000000000 mask FF80000000 write-back
> [    0.000000]   1 base 0080000000 mask FFF0000000 write-back
> [    0.000000]   2 base 0100000000 mask FF00000000 write-back
> [    0.000000]   3 base 0200000000 mask FE00000000 write-back
> [    0.000000]   4 base 0400000000 mask FE00000000 write-back
> [    0.000000]   5 base 0600000000 mask FFC0000000 write-back
> [    0.000000]   6 base 0640000000 mask FFE0000000 write-back
> [    0.000000]   7 base 0660000000 mask FFF0000000 write-back
> [    0.000000]   8 disabled
> [    0.000000]   9 disabled
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
> [    0.000000] e820 update range: 0000000090000000 - 0000000100000000 (usable) ==> (reserved)
> [    0.000000] last_pfn = 0x8c091 max_arch_pfn = 0x400000000
> [    0.000000] e820 update range: 0000000000001000 - 0000000000010000 (usable) ==> (reserved)
> [    0.000000] Scanning 1 areas for low memory corruption
> [    0.000000] modified physical RAM map:
> [    0.000000]  modified: 0000000000000000 - 0000000000010000 (reserved)
> [    0.000000]  modified: 0000000000010000 - 000000000009b000 (usable)
> [    0.000000]  modified: 000000000009b000 - 00000000000a0000 (reserved)
> [    0.000000]  modified: 00000000000e0000 - 0000000000100000 (reserved)
> [    0.000000]  modified: 0000000000100000 - 000000008c091000 (usable)
> [    0.000000]  modified: 000000008c091000 - 000000008c164000 (ACPI NVS)
> [    0.000000]  modified: 000000008c164000 - 000000008c581000 (ACPI data)
> [    0.000000]  modified: 000000008c581000 - 000000008d981000 (ACPI NVS)
> [    0.000000]  modified: 000000008d981000 - 000000008f602000 (ACPI data)
> [    0.000000]  modified: 000000008f602000 - 000000008f64f000 (reserved)
> [    0.000000]  modified: 000000008f64f000 - 000000008f6d5000 (ACPI data)
> [    0.000000]  modified: 000000008f6d5000 - 000000008f6df000 (ACPI NVS)
> [    0.000000]  modified: 000000008f6df000 - 000000008f6e2000 (ACPI data)
> [    0.000000]  modified: 000000008f6e2000 - 000000008f7cf000 (ACPI NVS)
> [    0.000000]  modified: 000000008f7cf000 - 000000008f800000 (ACPI data)
> [    0.000000]  modified: 000000008f800000 - 0000000090000000 (reserved)
> [    0.000000]  modified: 00000000a0000000 - 00000000b0000000 (reserved)
> [    0.000000]  modified: 00000000fc000000 - 00000000fd000000 (reserved)
> [    0.000000]  modified: 00000000fed1c000 - 00000000fed20000 (reserved)
> [    0.000000]  modified: 00000000ff800000 - 0000000100000000 (reserved)
> [    0.000000]  modified: 0000000100000000 - 0000000670000000 (usable)
> [    0.000000] initial memory mapped : 0 - 20000000
> [    0.000000] found SMP MP-table at [ffff8800000fdb40] fdb40
> [    0.000000] Using GB pages for direct mapping
> [    0.000000] init_memory_mapping: 0000000000000000-000000008c091000
> [    0.000000]  0000000000 - 0080000000 page 1G
> [    0.000000]  0080000000 - 008c000000 page 2M
> [    0.000000]  008c000000 - 008c091000 page 4k
> [    0.000000] kernel direct mapping tables up to 8c091000 @ 16000-19000
> [    0.000000] init_memory_mapping: 0000000100000000-0000000670000000
> [    0.000000]  0100000000 - 0640000000 page 1G
> [    0.000000]  0640000000 - 0670000000 page 2M
> [    0.000000] kernel direct mapping tables up to 670000000 @ 18000-1a000
> [    0.000000] RAMDISK: 374e6000 - 37ff0000
> [    0.000000] Reserving 128MB of memory at 32MB for crashkernel (System RAM: 26368MB)
> [    0.000000] ACPI: RSDP 00000000000f0410 00024 (v02 INTEL )
> [    0.000000] ACPI: XSDT 000000008f7fd120 0009C (v01 INTEL  S5520UT  00000000      01000013)
> [    0.000000] ACPI: FACP 000000008f7fb000 000F4 (v04 INTEL  S5520UT  00000000 MSFT 0100000D)
> [    0.000000] ACPI: DSDT 000000008f7f4000 065E9 (v02 INTEL  S5520UT  00000003 MSFT 0100000D)
> [    0.000000] ACPI: FACS 000000008f6e2000 00040
> [    0.000000] ACPI: APIC 000000008f7f3000 001A8 (v02 INTEL  S5520UT  00000000 MSFT 0100000D)
> [    0.000000] ACPI: MCFG 000000008f7f2000 0003C (v01 INTEL  S5520UT  00000001 MSFT 0100000D)
> [    0.000000] ACPI: HPET 000000008f7f1000 00038 (v01 INTEL  S5520UT  00000001 MSFT 0100000D)
> [    0.000000] ACPI: SLIT 000000008f7f0000 00030 (v01 INTEL  S5520UT  00000001 MSFT 0100000D)
> [    0.000000] ACPI: SRAT 000000008f7ef000 00430 (v02 INTEL  S5520UT  00000001 MSFT 0100000D)
> [    0.000000] ACPI: SPCR 000000008f7ee000 00050 (v01 INTEL  S5520UT  00000000 MSFT 0100000D)
> [    0.000000] ACPI: WDDT 000000008f7ed000 00040 (v01 INTEL  S5520UT  00000000 MSFT 0100000D)
> [    0.000000] ACPI: SSDT 000000008f7d2000 1AFC4 (v02  INTEL SSDT  PM 00004000 INTL 20061109)
> [    0.000000] ACPI: SSDT 000000008f7d1000 001D8 (v02  INTEL IPMI     00004000 INTL 20061109)
> [    0.000000] ACPI: TCPA 000000008f7d0000 00032 (v00                 00000000      00000000)
> [    0.000000] ACPI: HEST 000000008f7cf000 000A8 (v01 INTEL  S5520UT  00000001 INTL 00000001)
> [    0.000000] ACPI: BERT 000000008f6e1000 00030 (v01 INTEL  S5520UT  00000001 INTL 00000001)
> [    0.000000] ACPI: ERST 000000008f6e0000 00230 (v01 INTEL  S5520UT  00000001 INTL 00000001)
> [    0.000000] ACPI: EINJ 000000008f6df000 00130 (v01 INTEL  S5520UT  00000001 INTL 00000001)
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x02 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x22 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x04 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x24 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x10 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x30 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x12 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x32 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x14 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x03 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x23 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x05 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x25 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x11 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x31 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x13 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x33 -> Node 1
> [    0.000000] SRAT: PXM 0 -> APIC 0x15 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 1
> [    0.000000] SRAT: Node 0 PXM 0 0-90000000
> [    0.000000] SRAT: Node 0 PXM 0 100000000-370000000
> [    0.000000] SRAT: Node 1 PXM 1 370000000-670000000
> [    0.000000] SRAT: Node 0 [0,90000000) + [100000000,370000000) -> [0,370000000)
> [    0.000000] NUMA: Allocated memnodemap from 19040 - 19140
> [    0.000000] NUMA: Using 28 for the hash shift.
> [    0.000000] Initmem setup node 0 0000000000000000-0000000370000000
> [    0.000000]   NODE_DATA [0000000100000000 - 0000000100004fff]
> [    0.000000] Initmem setup node 1 0000000370000000-0000000670000000
> [    0.000000]   NODE_DATA [0000000370000000 - 0000000370004fff]
> [    0.000000] [ffffea000c080000-ffffea000c1fffff] potential offnode page_structs
> [    0.000000]  [ffffea0000000000-ffffea000c1fffff] PMD -> [ffff880100200000-ffff88010abfffff] on node 0
> [    0.000000]  [ffffea000c200000-ffffea00169fffff] PMD -> [ffff880370200000-ffff88037a9fffff] on node 1
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00000010 -> 0x00001000
> [    0.000000]   DMA32    0x00001000 -> 0x00100000
> [    0.000000]   Normal   0x00100000 -> 0x00670000
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[4] active PFN ranges
> [    0.000000]     0: 0x00000010 -> 0x0000009b
> [    0.000000]     0: 0x00000100 -> 0x0008c091
> [    0.000000]     0: 0x00100000 -> 0x00370000
> [    0.000000]     1: 0x00370000 -> 0x00670000
> [    0.000000] On node 0 totalpages: 3129372
> [    0.000000]   DMA zone: 56 pages used for memmap
> [    0.000000]   DMA zone: 0 pages reserved
> [    0.000000]   DMA zone: 3923 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 14280 pages used for memmap
> [    0.000000]   DMA32 zone: 555209 pages, LIFO batch:31
> [    0.000000]   Normal zone: 34944 pages used for memmap
> [    0.000000]   Normal zone: 2520960 pages, LIFO batch:31
> [    0.000000] On node 1 totalpages: 3145728
> [    0.000000]   Normal zone: 43008 pages used for memmap
> [    0.000000]   Normal zone: 3102720 pages, LIFO batch:31
> [    0.000000] early_res array is doubled to 64 at [19140 - 1993f]
> [    0.000000] ACPI: PM-Timer IO Port: 0x408
> [    0.000000] ACPI: Local APIC address 0xfee00000
> [    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x20] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x22] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x24] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x10] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x30] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x12] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x32] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x14] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x34] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x01] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x21] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x03] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x23] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x05] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x25] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x11] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x31] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x13] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x33] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x15] enabled)
> [    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x35] enabled)
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x10] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x11] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x12] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x13] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x14] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x15] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x16] high level lint[0x1])
> [    0.000000] ACPI: LAPIC_NMI (acpi_id[0x17] high level lint[0x1])
> [    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
> [    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
> [    0.000000] ACPI: IOAPIC (id[0x09] address[0xfec90000] gsi_base[24])
> [    0.000000] IOAPIC[1]: apic_id 9, version 32, address 0xfec90000, GSI 24-47
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [    0.000000] ACPI: IRQ0 used by override.
> [    0.000000] ACPI: IRQ2 used by override.
> [    0.000000] ACPI: IRQ9 used by override.
> [    0.000000] Using ACPI (MADT) for SMP configuration information
> [    0.000000] ACPI: HPET id: 0x8086a401 base: 0xfed00000
> [    0.000000] SMP: Allowing 24 CPUs, 0 hotplug CPUs
> [    0.000000] nr_irqs_gsi: 64
> [    0.000000] PM: Registered nosave memory: 000000000009b000 - 00000000000a0000
> [    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
> [    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
> [    0.000000] PM: Registered nosave memory: 000000008c091000 - 000000008c164000
> [    0.000000] PM: Registered nosave memory: 000000008c164000 - 000000008c581000
> [    0.000000] PM: Registered nosave memory: 000000008c581000 - 000000008d981000
> [    0.000000] PM: Registered nosave memory: 000000008d981000 - 000000008f602000
> [    0.000000] PM: Registered nosave memory: 000000008f602000 - 000000008f64f000
> [    0.000000] PM: Registered nosave memory: 000000008f64f000 - 000000008f6d5000
> [    0.000000] PM: Registered nosave memory: 000000008f6d5000 - 000000008f6df000
> [    0.000000] PM: Registered nosave memory: 000000008f6df000 - 000000008f6e2000
> [    0.000000] PM: Registered nosave memory: 000000008f6e2000 - 000000008f7cf000
> [    0.000000] PM: Registered nosave memory: 000000008f7cf000 - 000000008f800000
> [    0.000000] PM: Registered nosave memory: 000000008f800000 - 0000000090000000
> [    0.000000] PM: Registered nosave memory: 0000000090000000 - 00000000a0000000
> [    0.000000] PM: Registered nosave memory: 00000000a0000000 - 00000000b0000000
> [    0.000000] PM: Registered nosave memory: 00000000b0000000 - 00000000fc000000
> [    0.000000] PM: Registered nosave memory: 00000000fc000000 - 00000000fd000000
> [    0.000000] PM: Registered nosave memory: 00000000fd000000 - 00000000fed1c000
> [    0.000000] PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
> [    0.000000] PM: Registered nosave memory: 00000000fed20000 - 00000000ff800000
> [    0.000000] PM: Registered nosave memory: 00000000ff800000 - 0000000100000000
> [    0.000000] Allocating PCI resources starting at b0000000 (gap: b0000000:4c000000)
> [    0.000000] Booting paravirtualized kernel on bare hardware
> [    0.000000] early_res array is doubled to 128 at [19940 - 1a93f]
> [    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:24 nr_node_ids:2
> [    0.000000] PERCPU: Embedded 29 pages/cpu @ffff880001e00000 s89024 r8192 d21568 u131072
> [    0.000000] pcpu-alloc: s89024 r8192 d21568 u131072 alloc=1*2097152
> [    0.000000] pcpu-alloc: [0] 00 02 04 06 08 10 12 14 16 18 20 22 -- -- -- -- 
> [    0.000000] pcpu-alloc: [1] 01 03 05 07 09 11 13 15 17 19 21 23 -- -- -- -- 
> [    0.000000] Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 6182812
> [    0.000000] Policy zone: Normal
> [    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-2.6.36-0-server root=UUID=089b1b8a-4b0d-40fd-84e8-e28e6ea21d75 ro crashkernel=384M-2G:64M,2G-:128M quiet splash
> [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> [    0.000000] Checking aperture...
> [    0.000000] No AGP bridge found
> [    0.000000] Calgary: detecting Calgary via BIOS EBDA area
> [    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
> [    0.000000] Subtract (94 early reservations)
> [    0.000000]   #1 [0001000000 - 0001d26f6c]   TEXT DATA BSS
> [    0.000000]   #2 [00374e6000 - 0037ff0000]         RAMDISK
> [    0.000000]   #3 [0001d27000 - 0001d27340]             BRK
> [    0.000000]   #4 [00000fdb50 - 0000100000]   BIOS reserved
> [    0.000000]   #5 [00000fdb40 - 00000fdb50]    MP-table mpf
> [    0.000000]   #6 [000009b000 - 00000efc40]   BIOS reserved
> [    0.000000]   #7 [00000efe4c - 00000fdb40]   BIOS reserved
> [    0.000000]   #8 [00000efc40 - 00000efe4c]    MP-table mpc
> [    0.000000]   #9 [0000010000 - 0000012000]      TRAMPOLINE
> [    0.000000]   #10 [0000012000 - 0000016000]     ACPI WAKEUP
> [    0.000000]   #11 [0000016000 - 0000018000]         PGTABLE
> [    0.000000]   #12 [0000018000 - 0000019000]         PGTABLE
> [    0.000000]   #13 [0002000000 - 000a000000]    CRASH KERNEL
> [    0.000000]   #14 [0000019000 - 0000019030]       ACPI SLIT
> [    0.000000]   #15 [0000019040 - 0000019140]      MEMNODEMAP
> [    0.000000]   #16 [0100000000 - 0100005000]       NODE_DATA
> [    0.000000]   #17 [0370000000 - 0370005000]       NODE_DATA
> [    0.000000]   #18 [0001d27340 - 0001d28340]         BOOTMEM
> [    0.000000]   #19 [0370005000 - 0370006000]         BOOTMEM
> [    0.000000]   #20 [0100005000 - 0100005900]         BOOTMEM
> [    0.000000]   #21 [0370006000 - 0370006900]         BOOTMEM
> [    0.000000]   #22 [0100006000 - 0100007000]         BOOTMEM
> [    0.000000]   #23 [0100007000 - 0100008000]         BOOTMEM
> [    0.000000]   #24 [0100200000 - 010ac00000]        MEMMAP 0
> [    0.000000]   #25 [0370200000 - 037aa00000]        MEMMAP 1
> [    0.000000]   #26 [0001d28340 - 0001d50340]         BOOTMEM
> [    0.000000]   #27 [0001d50340 - 0001d78340]         BOOTMEM
> [    0.000000]   #28 [0001d78340 - 0001da0340]         BOOTMEM
> [    0.000000]   #29 [0370006900 - 037002e900]         BOOTMEM
> [    0.000000]   #30 [0001da1000 - 0001da2000]         BOOTMEM
> [    0.000000]   #31 [0001d26f80 - 0001d26fc1]         BOOTMEM
> [    0.000000]   #32 [0001da0340 - 0001da03c6]         BOOTMEM
> [    0.000000]   #33 [0001da0400 - 0001da0898]         BOOTMEM
> [    0.000000]   #34 [0001da08c0 - 0001da0928]         BOOTMEM
> [    0.000000]   #35 [0001da0940 - 0001da09a8]         BOOTMEM
> [    0.000000]   #36 [0001da09c0 - 0001da0a28]         BOOTMEM
> [    0.000000]   #37 [0001da0a40 - 0001da0aa8]         BOOTMEM
> [    0.000000]   #38 [0001da0ac0 - 0001da0b28]         BOOTMEM
> [    0.000000]   #39 [0001da0b40 - 0001da0ba8]         BOOTMEM
> [    0.000000]   #40 [0001da0bc0 - 0001da0c28]         BOOTMEM
> [    0.000000]   #41 [0001da0c40 - 0001da0ca8]         BOOTMEM
> [    0.000000]   #42 [0001da0cc0 - 0001da0d28]         BOOTMEM
> [    0.000000]   #43 [0001da0d40 - 0001da0da8]         BOOTMEM
> [    0.000000]   #44 [0001da0dc0 - 0001da0e28]         BOOTMEM
> [    0.000000]   #45 [0001da0e40 - 0001da0ea8]         BOOTMEM
> [    0.000000]   #46 [0001da0ec0 - 0001da0f28]         BOOTMEM
> [    0.000000]   #47 [0001da0f40 - 0001da0fa8]         BOOTMEM
> [    0.000000]   #48 [0001da2000 - 0001da2068]         BOOTMEM
> [    0.000000]   #49 [0001da2080 - 0001da20e8]         BOOTMEM
> [    0.000000]   #50 [0001da2100 - 0001da2168]         BOOTMEM
> [    0.000000]   #51 [0001da2180 - 0001da21e8]         BOOTMEM
> [    0.000000]   #52 [0001da2200 - 0001da2268]         BOOTMEM
> [    0.000000]   #53 [0001da2280 - 0001da22e8]         BOOTMEM
> [    0.000000]   #54 [0001da0fc0 - 0001da0fe0]         BOOTMEM
> [    0.000000]   #55 [0001da2300 - 0001da2320]         BOOTMEM
> [    0.000000]   #56 [0001da2340 - 0001da23c9]         BOOTMEM
> [    0.000000]   #57 [0001da2400 - 0001da2489]         BOOTMEM
> [    0.000000]   #58 [0001e00000 - 0001e1d000]         BOOTMEM
> [    0.000000]   #59 [0001e20000 - 0001e3d000]         BOOTMEM
> [    0.000000]   #60 [0001e40000 - 0001e5d000]         BOOTMEM
> [    0.000000]   #61 [0001e60000 - 0001e7d000]         BOOTMEM
> [    0.000000]   #62 [0001e80000 - 0001e9d000]         BOOTMEM
> [    0.000000]   #63 [0001ea0000 - 0001ebd000]         BOOTMEM
> [    0.000000]   #64 [0001ec0000 - 0001edd000]         BOOTMEM
> [    0.000000]   #65 [0001ee0000 - 0001efd000]         BOOTMEM
> [    0.000000]   #66 [0001f00000 - 0001f1d000]         BOOTMEM
> [    0.000000]   #67 [0001f20000 - 0001f3d000]         BOOTMEM
> [    0.000000]   #68 [0001f40000 - 0001f5d000]         BOOTMEM
> [    0.000000]   #69 [0001f60000 - 0001f7d000]         BOOTMEM
> [    0.000000]   #70 [037aa00000 - 037aa1d000]         BOOTMEM
> [    0.000000]   #71 [037aa20000 - 037aa3d000]         BOOTMEM
> [    0.000000]   #72 [037aa40000 - 037aa5d000]         BOOTMEM
> [    0.000000]   #73 [037aa60000 - 037aa7d000]         BOOTMEM
> [    0.000000]   #74 [037aa80000 - 037aa9d000]         BOOTMEM
> [    0.000000]   #75 [037aaa0000 - 037aabd000]         BOOTMEM
> [    0.000000]   #76 [037aac0000 - 037aadd000]         BOOTMEM
> [    0.000000]   #77 [037aae0000 - 037aafd000]         BOOTMEM
> [    0.000000]   #78 [037ab00000 - 037ab1d000]         BOOTMEM
> [    0.000000]   #79 [037ab20000 - 037ab3d000]         BOOTMEM
> [    0.000000]   #80 [037ab40000 - 037ab5d000]         BOOTMEM
> [    0.000000]   #81 [037ab60000 - 037ab7d000]         BOOTMEM
> [    0.000000]   #82 [0001da44c0 - 0001da44d0]         BOOTMEM
> [    0.000000]   #83 [0001da4500 - 0001da4510]         BOOTMEM
> [    0.000000]   #84 [0001da4540 - 0001da45a0]         BOOTMEM
> [    0.000000]   #85 [0001da45c0 - 0001da4680]         BOOTMEM
> [    0.000000]   #86 [0001da4680 - 0001da4790]         BOOTMEM
> [    0.000000]   #87 [0001da47c0 - 0001da4808]         BOOTMEM
> [    0.000000]   #88 [0001da4840 - 0001da4888]         BOOTMEM
> [    0.000000]   #89 [0001da48c0 - 0001dac8c0]         BOOTMEM
> [    0.000000]   #90 [000a000000 - 000e000000]         BOOTMEM
> [    0.000000]   #91 [0001dac8c0 - 0001dcc8c0]         BOOTMEM
> [    0.000000]   #92 [0001f7d000 - 0001fbd000]         BOOTMEM
> [    0.000000]   #93 [000001a940 - 0000022940]         BOOTMEM
> [    0.000000] Memory: 24528912k/27000832k available (5861k kernel code, 1900432k absent, 571488k reserved, 5375k data, 784k init)
> [    0.000000] SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0, CPUs=24, Nodes=2
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
> [    0.000000] 	RCU-based detection of stalled CPUs is disabled.
> [    0.000000] 	Verbose stalled-CPUs detection is disabled.
> [    0.000000] NR_IRQS:4352 nr_irqs:1280
> [    0.000000] Extended CMOS year: 2000
> [    0.000000] Console: colour VGA+ 80x25
> [    0.000000] console [tty0] enabled
> [    0.000000] allocated 251658240 bytes of page_cgroup
> [    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
> [    0.000000] hpet clockevent registered
> [    0.000000] Fast TSC calibration using PIT
> [    0.010000] Detected 2926.377 MHz processor.
> [    0.000008] Calibrating delay loop (skipped), value calculated using timer frequency.. 5852.75 BogoMIPS (lpj=29263770)
> [    0.000011] pid_max: default: 32768 minimum: 301
> [    0.000037] Security Framework initialized
> [    0.000047] AppArmor: AppArmor initialized
> [    0.000049] Yama: becoming mindful.
> [    0.002457] Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
> [    0.008885] Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
> [    0.011481] Mount-cache hash table entries: 256
> [    0.011637] Initializing cgroup subsys ns
> [    0.011640] Initializing cgroup subsys cpuacct
> [    0.011644] Initializing cgroup subsys memory
> [    0.011663] Initializing cgroup subsys devices
> [    0.011665] Initializing cgroup subsys freezer
> [    0.011667] Initializing cgroup subsys net_cls
> [    0.011696] CPU: Physical Processor ID: 0
> [    0.011697] CPU: Processor Core ID: 0
> [    0.011701] mce: CPU supports 9 MCE banks
> [    0.011709] CPU0: Thermal monitoring enabled (TM1)
> [    0.011715] using mwait in idle threads.
> [    0.011716] Performance Events: PEBS fmt1+, Westmere events, Intel PMU driver.
> [    0.011721] ... version:                3
> [    0.011722] ... bit width:              48
> [    0.011723] ... generic registers:      4
> [    0.011724] ... value mask:             0000ffffffffffff
> [    0.011725] ... max period:             000000007fffffff
> [    0.011726] ... fixed-purpose events:   3
> [    0.011728] ... event mask:             000000070000000f
> [    0.012440] ACPI: Core revision 20100702
> [    0.036184] ftrace: converting mcount calls to 0f 1f 44 00 00
> [    0.036188] ftrace: allocating 23404 entries in 92 pages
> [    0.041910] Setting APIC routing to physical flat
> [    0.042343] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> [    0.142087] CPU0: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
> [    0.258509] Booting Node   1, Processors  #1 Ok.
> [    0.437979] Booting Node   0, Processors  #2 Ok.
> [    0.617599] Booting Node   1, Processors  #3 Ok.
> [    0.797073] Booting Node   0, Processors  #4 Ok.
> [    0.976581] Booting Node   1, Processors  #5 Ok.
> [    1.156068] Booting Node   0, Processors  #6 Ok.
> [    1.335680] Booting Node   1, Processors  #7 Ok.
> [    1.515154] Booting Node   0, Processors  #8 Ok.
> [    1.694665] Booting Node   1, Processors  #9 Ok.
> [    1.874144] Booting Node   0, Processors  #10 Ok.
> [    2.053707] Booting Node   1, Processors  #11 Ok.
> [    2.233191] Booting Node   0, Processors  #12 Ok.
> [    2.412810] Booting Node   1, Processors  #13 Ok.
> [    2.592304] Booting Node   0, Processors  #14 Ok.
> [    2.771819] Booting Node   1, Processors  #15 Ok.
> [    2.951299] Booting Node   0, Processors  #16 Ok.
> [    3.130817] Booting Node   1, Processors  #17 Ok.
> [    3.310298] Booting Node   0, Processors  #18 Ok.
> [    3.489852] Booting Node   1, Processors  #19 Ok.
> [    3.669333] Booting Node   0, Processors  #20 Ok.
> [    3.848953] Booting Node   1, Processors  #21 Ok.
> [    4.028440] Booting Node   0, Processors  #22 Ok.
> [    4.207951] Booting Node   1, Processors  #23 Ok.
> [    4.387381] Brought up 24 CPUs
> [    4.387384] Total of 24 processors activated (140463.63 BogoMIPS).
> [    4.404873] devtmpfs: initialized
> [    4.409507] regulator: core version 0.5
> [    4.409529] Time: 14:17:32  Date: 09/01/10
> [    4.409570] NET: Registered protocol family 16
> [    4.409679] Trying to unpack rootfs image as initramfs...
> [    4.409697] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
> [    4.409700] ACPI: bus type pci registered
> [    4.409782] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xa0000000-0xafffffff] (base 0xa0000000)
> [    4.409786] PCI: MMCONFIG at [mem 0xa0000000-0xafffffff] reserved in E820
> [    4.467014] PCI: Using configuration type 1 for base access
> [    4.469247] bio: create slab <bio-0> at 0
> [    4.472207] ACPI: EC: Look up EC in DSDT
> [    4.472401] ACPI Error: Field [CPB3] at 96 exceeds Buffer [NULL] size 64 (bits) (20100702/dsopcode-597)
> [    4.472408] ACPI Error (psparse-0537): Method parse/execution failed [\_SB_._OSC] (Node ffff8803620481b8), AE_AML_BUFFER_LIMIT
> [    4.515677] ACPI: Interpreter enabled
> [    4.515681] ACPI: (supports S0 S1 S5)
> [    4.515697] ACPI: Using IOAPIC for interrupt routing
> [    4.523100] ACPI: No dock devices found.
> [    4.523104] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    4.523580] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fd])
> [    4.524321] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
> [    4.524325] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
> [    4.524328] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
> [    4.524331] pci_root PNP0A08:00: host bridge window [mem 0x000c4000-0x000cbfff]
> [    4.524334] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfedfffff]
> [    4.524337] pci_root PNP0A08:00: host bridge window [mem 0xb0000000-0xfdffffff]
> [    4.524393] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
> [    4.524397] pci 0000:00:00.0: PME# disabled
> [    4.524463] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
> [    4.524467] pci 0000:00:01.0: PME# disabled
> [    4.524531] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
> [    4.524536] pci 0000:00:03.0: PME# disabled
> [    4.524598] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
> [    4.524602] pci 0000:00:05.0: PME# disabled
> [    4.524664] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
> [    4.524668] pci 0000:00:07.0: PME# disabled
> [    4.524731] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
> [    4.524735] pci 0000:00:09.0: PME# disabled
> [    4.524797] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
> [    4.524801] pci 0000:00:0a.0: PME# disabled
> [    4.525053] pci 0000:00:13.0: reg 10: [mem 0xb1b23000-0xb1b23fff]
> [    4.525096] pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
> [    4.525100] pci 0000:00:13.0: PME# disabled
> [    4.525398] pci 0000:00:16.0: reg 10: [mem 0xb1b00000-0xb1b03fff 64bit]
> [    4.525467] pci 0000:00:16.1: reg 10: [mem 0xb1b04000-0xb1b07fff 64bit]
> [    4.525535] pci 0000:00:16.2: reg 10: [mem 0xb1b08000-0xb1b0bfff 64bit]
> [    4.525606] pci 0000:00:16.3: reg 10: [mem 0xb1b0c000-0xb1b0ffff 64bit]
> [    4.525675] pci 0000:00:16.4: reg 10: [mem 0xb1b10000-0xb1b13fff 64bit]
> [    4.525744] pci 0000:00:16.5: reg 10: [mem 0xb1b14000-0xb1b17fff 64bit]
> [    4.525812] pci 0000:00:16.6: reg 10: [mem 0xb1b18000-0xb1b1bfff 64bit]
> [    4.525881] pci 0000:00:16.7: reg 10: [mem 0xb1b1c000-0xb1b1ffff 64bit]
> [    4.525985] pci 0000:00:1a.0: reg 20: [io  0x30c0-0x30df]
> [    4.526070] pci 0000:00:1a.1: reg 20: [io  0x30a0-0x30bf]
> [    4.526154] pci 0000:00:1a.2: reg 20: [io  0x3080-0x309f]
> [    4.526227] pci 0000:00:1a.7: reg 10: [mem 0xb1b21000-0xb1b213ff]
> [    4.526300] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
> [    4.526305] pci 0000:00:1a.7: PME# disabled
> [    4.526379] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
> [    4.526383] pci 0000:00:1c.0: PME# disabled
> [    4.526460] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
> [    4.526464] pci 0000:00:1c.4: PME# disabled
> [    4.526537] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
> [    4.526541] pci 0000:00:1c.5: PME# disabled
> [    4.526607] pci 0000:00:1d.0: reg 20: [io  0x3060-0x307f]
> [    4.526693] pci 0000:00:1d.1: reg 20: [io  0x3040-0x305f]
> [    4.526777] pci 0000:00:1d.2: reg 20: [io  0x3020-0x303f]
> [    4.526850] pci 0000:00:1d.7: reg 10: [mem 0xb1b20000-0xb1b203ff]
> [    4.526923] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
> [    4.526928] pci 0000:00:1d.7: PME# disabled
> [    4.527081] pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by ICH6 ACPI/GPIO/TCO
> [    4.527086] pci 0000:00:1f.0: quirk: [io  0x0500-0x053f] claimed by ICH6 GPIO
> [    4.527090] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0680 (mask 000f)
> [    4.527094] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0ca0 (mask 000f)
> [    4.527099] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0600 (mask 001f)
> [    4.527149] pci 0000:00:1f.2: reg 10: [io  0x3138-0x313f]
> [    4.527157] pci 0000:00:1f.2: reg 14: [io  0x314c-0x314f]
> [    4.527166] pci 0000:00:1f.2: reg 18: [io  0x3130-0x3137]
> [    4.527174] pci 0000:00:1f.2: reg 1c: [io  0x3148-0x314b]
> [    4.527182] pci 0000:00:1f.2: reg 20: [io  0x3110-0x311f]
> [    4.527191] pci 0000:00:1f.2: reg 24: [io  0x3100-0x310f]
> [    4.527242] pci 0000:00:1f.3: reg 10: [mem 0xb1b22000-0xb1b220ff 64bit]
> [    4.527264] pci 0000:00:1f.3: reg 20: [io  0x3000-0x301f]
> [    4.527309] pci 0000:00:1f.5: reg 10: [io  0x3128-0x312f]
> [    4.527318] pci 0000:00:1f.5: reg 14: [io  0x3144-0x3147]
> [    4.527326] pci 0000:00:1f.5: reg 18: [io  0x3120-0x3127]
> [    4.527334] pci 0000:00:1f.5: reg 1c: [io  0x3140-0x3143]
> [    4.527343] pci 0000:00:1f.5: reg 20: [io  0x30f0-0x30ff]
> [    4.527351] pci 0000:00:1f.5: reg 24: [io  0x30e0-0x30ef]
> [    4.527446] pci 0000:01:00.0: reg 10: [mem 0xb1a20000-0xb1a3ffff]
> [    4.527463] pci 0000:01:00.0: reg 18: [io  0x2020-0x203f]
> [    4.527473] pci 0000:01:00.0: reg 1c: [mem 0xb1ac4000-0xb1ac7fff]
> [    4.527529] pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
> [    4.527534] pci 0000:01:00.0: PME# disabled
> [    4.527571] pci 0000:01:00.0: reg 184: [mem 0xb1a40000-0xb1a43fff 64bit]
> [    4.527589] pci 0000:01:00.0: reg 190: [mem 0xb1a60000-0xb1a63fff 64bit]
> [    4.527630] pci 0000:01:00.1: reg 10: [mem 0xb1a00000-0xb1a1ffff]
> [    4.527647] pci 0000:01:00.1: reg 18: [io  0x2000-0x201f]
> [    4.527657] pci 0000:01:00.1: reg 1c: [mem 0xb1ac0000-0xb1ac3fff]
> [    4.527712] pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
> [    4.527717] pci 0000:01:00.1: PME# disabled
> [    4.527749] pci 0000:01:00.1: reg 184: [mem 0xb1a80000-0xb1a83fff 64bit]
> [    4.527768] pci 0000:01:00.1: reg 190: [mem 0xb1aa0000-0xb1aa3fff 64bit]
> [    4.527786] pci 0000:00:01.0: PCI bridge to [bus 01-03]
> [    4.527790] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
> [    4.527794] pci 0000:00:01.0:   bridge window [mem 0xb1a00000-0xb1afffff]
> [    4.527799] pci 0000:00:01.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.527836] pci 0000:00:03.0: PCI bridge to [bus 04-04]
> [    4.527840] pci 0000:00:03.0:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.527844] pci 0000:00:03.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.527850] pci 0000:00:03.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.527954] pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
> [    4.527959] pci 0000:05:00.0: PME# disabled
> [    4.527975] pci 0000:00:05.0: PCI bridge to [bus 05-08]
> [    4.527979] pci 0000:00:05.0:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.527983] pci 0000:00:05.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.527989] pci 0000:00:05.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.528100] pci 0000:06:02.0: PME# supported from D0 D3hot D3cold
> [    4.528105] pci 0000:06:02.0: PME# disabled
> [    4.528196] pci 0000:06:04.0: PME# supported from D0 D3hot D3cold
> [    4.528201] pci 0000:06:04.0: PME# disabled
> [    4.528242] pci 0000:05:00.0: PCI bridge to [bus 06-08]
> [    4.528250] pci 0000:05:00.0:   bridge window [io  0xfffffffffffff000-0x0000] (disabled)
> [    4.528256] pci 0000:05:00.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.528264] pci 0000:05:00.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.528309] pci 0000:06:02.0: PCI bridge to [bus 07-07]
> [    4.528316] pci 0000:06:02.0:   bridge window [io  0xfffffffffffff000-0x0000] (disabled)
> [    4.528322] pci 0000:06:02.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.528330] pci 0000:06:02.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.528376] pci 0000:06:04.0: PCI bridge to [bus 08-08]
> [    4.528384] pci 0000:06:04.0:   bridge window [io  0xfffffffffffff000-0x0000] (disabled)
> [    4.528389] pci 0000:06:04.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.528397] pci 0000:06:04.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.528520] pci 0000:09:00.0: PME# supported from D0 D3hot D3cold
> [    4.528525] pci 0000:09:00.0: PME# disabled
> [    4.528541] pci 0000:00:07.0: PCI bridge to [bus 09-0c]
> [    4.528545] pci 0000:00:07.0:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.528549] pci 0000:00:07.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.528555] pci 0000:00:07.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.528667] pci 0000:0a:02.0: PME# supported from D0 D3hot D3cold
> [    4.528672] pci 0000:0a:02.0: PME# disabled
> [    4.528762] pci 0000:0a:04.0: PME# supported from D0 D3hot D3cold
> [    4.528768] pci 0000:0a:04.0: PME# disabled
> [    4.528809] pci 0000:09:00.0: PCI bridge to [bus 0a-0c]
> [    4.528817] pci 0000:09:00.0:   bridge window [io  0xfffffffffffff000-0x0000] (disabled)
> [    4.528823] pci 0000:09:00.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.528831] pci 0000:09:00.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.528876] pci 0000:0a:02.0: PCI bridge to [bus 0b-0b]
> [    4.528884] pci 0000:0a:02.0:   bridge window [io  0xfffffffffffff000-0x0000] (disabled)
> [    4.528889] pci 0000:0a:02.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.528897] pci 0000:0a:02.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.528943] pci 0000:0a:04.0: PCI bridge to [bus 0c-0c]
> [    4.528951] pci 0000:0a:04.0:   bridge window [io  0xfffffffffffff000-0x0000] (disabled)
> [    4.528956] pci 0000:0a:04.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.528964] pci 0000:0a:04.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.529020] pci 0000:00:09.0: PCI bridge to [bus 0d-0d]
> [    4.529024] pci 0000:00:09.0:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.529028] pci 0000:00:09.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.529034] pci 0000:00:09.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.529070] pci 0000:00:0a.0: PCI bridge to [bus 0e-0e]
> [    4.529074] pci 0000:00:0a.0:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.529078] pci 0000:00:0a.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.529084] pci 0000:00:0a.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.529155] pci 0000:0f:00.0: reg 10: [mem 0xb1940000-0xb1943fff 64bit]
> [    4.529168] pci 0000:0f:00.0: reg 18: [io  0x1000-0x10ff]
> [    4.529185] pci 0000:0f:00.0: reg 1c: [mem 0xb1900000-0xb193ffff 64bit]
> [    4.529207] pci 0000:0f:00.0: reg 30: [mem 0xfff80000-0xffffffff pref]
> [    4.529247] pci 0000:0f:00.0: supports D1
> [    4.529268] pci 0000:0f:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
> [    4.529272] pci 0000:00:1c.0: PCI bridge to [bus 0f-0f]
> [    4.529276] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
> [    4.529281] pci 0000:00:1c.0:   bridge window [mem 0xb1900000-0xb19fffff]
> [    4.529287] pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.529364] pci 0000:10:00.0: reg 10: [mem 0xb0000000-0xb0ffffff pref]
> [    4.529379] pci 0000:10:00.0: reg 14: [mem 0xb1800000-0xb1803fff]
> [    4.529395] pci 0000:10:00.0: reg 18: [mem 0xb1000000-0xb17fffff]
> [    4.529449] pci 0000:10:00.0: reg 30: [mem 0xffff0000-0xffffffff pref]
> [    4.529507] pci 0000:10:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
> [    4.529511] pci 0000:00:1c.4: PCI bridge to [bus 10-10]
> [    4.529515] pci 0000:00:1c.4:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.529520] pci 0000:00:1c.4:   bridge window [mem 0xb1000000-0xb18fffff]
> [    4.529527] pci 0000:00:1c.4:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
> [    4.529573] pci 0000:00:1c.5: PCI bridge to [bus 11-11]
> [    4.529577] pci 0000:00:1c.5:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.529582] pci 0000:00:1c.5:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.529588] pci 0000:00:1c.5:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.529650] pci 0000:00:1e.0: PCI bridge to [bus 12-12] (subtractive decode)
> [    4.529655] pci 0000:00:1e.0:   bridge window [io  0xf000-0x0000] (disabled)
> [    4.529659] pci 0000:00:1e.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
> [    4.529666] pci 0000:00:1e.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
> [    4.529669] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
> [    4.529672] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
> [    4.529675] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
> [    4.529678] pci 0000:00:1e.0:   bridge window [mem 0x000c4000-0x000cbfff] (subtractive decode)
> [    4.529682] pci 0000:00:1e.0:   bridge window [mem 0xfed40000-0xfedfffff] (subtractive decode)
> [    4.529685] pci 0000:00:1e.0:   bridge window [mem 0xb0000000-0xfdffffff] (subtractive decode)
> [    4.529722] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> [    4.530032] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP1._PRT]
> [    4.530095] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP3._PRT]
> [    4.530143] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP5._PRT]
> [    4.530189] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP7._PRT]
> [    4.530234] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRP9._PRT]
> [    4.530301] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.MRPA._PRT]
> [    4.530381] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
> [    4.530433] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
> [    4.547304] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
> [    4.547379] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
> [    4.547457] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
> [    4.547532] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
> [    4.547604] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    4.547680] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
> [    4.547756] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    4.547829] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
> [    4.547910] HEST: HEST table parsing is initialized.
> [    4.548009] vgaarb: device added: PCI:0000:10:00.0,decodes=io+mem,owns=io+mem,locks=none
> [    4.548012] vgaarb: loaded
> [    4.548165] SCSI subsystem initialized
> [    4.548214] libata version 3.00 loaded.
> [    4.548268] usbcore: registered new interface driver usbfs
> [    4.548287] usbcore: registered new interface driver hub
> [    4.548318] usbcore: registered new device driver usb
> [    4.548461] ACPI: WMI: Mapper loaded
> [    4.548463] PCI: Using ACPI for IRQ routing
> [    4.548466] PCI: pci_cache_line_size set to 64 bytes
> [    4.548630] reserve RAM buffer: 000000000009b000 - 000000000009ffff 
> [    4.548633] reserve RAM buffer: 000000008c091000 - 000000008fffffff 
> [    4.548743] NetLabel: Initializing
> [    4.548745] NetLabel:  domain hash size = 128
> [    4.548746] NetLabel:  protocols = UNLABELED CIPSOv4
> [    4.548760] NetLabel:  unlabeled traffic allowed by default
> [    4.548794] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
> [    4.548799] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
> [    4.550830] Switching to clocksource tsc
> [    4.557575] AppArmor: AppArmor Filesystem Enabled
> [    4.557585] pnp: PnP ACPI init
> [    4.557597] ACPI: bus type pnp registered
> [    4.558974] pnp: PnP ACPI: found 12 devices
> [    4.558975] ACPI: ACPI bus type pnp unregistered
> [    4.558984] system 00:07: [io  0x0500-0x057f] could not be reserved
> [    4.558986] system 00:07: [io  0x0400-0x047f] has been reserved
> [    4.558988] system 00:07: [io  0x0800-0x081f] has been reserved
> [    4.558990] system 00:07: [io  0x0ca2-0x0ca3] has been reserved
> [    4.558992] system 00:07: [io  0x0600-0x061f] has been reserved
> [    4.558994] system 00:07: [io  0x0880-0x0883] has been reserved
> [    4.558995] system 00:07: [io  0x0ca4-0x0ca5] has been reserved
> [    4.558998] system 00:07: [mem 0xfed1c000-0xfed3fffe] could not be reserved
> [    4.559000] system 00:07: [mem 0xff000000-0xffffffff] could not be reserved
> [    4.559002] system 00:07: [mem 0xfee00000-0xfeefffff] has been reserved
> [    4.559004] system 00:07: [mem 0xfe900000-0xfe90001f] has been reserved
> [    4.559006] system 00:07: [mem 0xfea00000-0xfea0001f] has been reserved
> [    4.559008] system 00:07: [mem 0xfed1b000-0xfed1bfff] has been reserved
> [    4.564614] pci 0000:0f:00.0: no compatible bridge window for [mem 0xfff80000-0xffffffff pref]
> [    4.564617] pci 0000:10:00.0: no compatible bridge window for [mem 0xffff0000-0xffffffff pref]
> [    4.564724] pci 0000:00:1c.0: BAR 15: assigned [mem 0xb1c00000-0xb1dfffff pref]
> [    4.564726] pci 0000:00:1c.5: BAR 14: assigned [mem 0xb1e00000-0xb1ffffff]
> [    4.564729] pci 0000:00:1c.5: BAR 15: assigned [mem 0xb2000000-0xb21fffff 64bit pref]
> [    4.564731] pci 0000:00:1c.4: BAR 13: assigned [io  0x4000-0x4fff]
> [    4.564733] pci 0000:00:1c.5: BAR 13: assigned [io  0x5000-0x5fff]
> [    4.564736] pci 0000:00:01.0: PCI bridge to [bus 01-03]
> [    4.564738] pci 0000:00:01.0:   bridge window [io  0x2000-0x2fff]
> [    4.564741] pci 0000:00:01.0:   bridge window [mem 0xb1a00000-0xb1afffff]
> [    4.564744] pci 0000:00:01.0:   bridge window [mem pref disabled]
> [    4.564748] pci 0000:00:03.0: PCI bridge to [bus 04-04]
> [    4.564749] pci 0000:00:03.0:   bridge window [io  disabled]
> [    4.564752] pci 0000:00:03.0:   bridge window [mem disabled]
> [    4.564754] pci 0000:00:03.0:   bridge window [mem pref disabled]
> [    4.564759] pci 0000:06:02.0: PCI bridge to [bus 07-07]
> [    4.564760] pci 0000:06:02.0:   bridge window [io  disabled]
> [    4.564765] pci 0000:06:02.0:   bridge window [mem disabled]
> [    4.564769] pci 0000:06:02.0:   bridge window [mem pref disabled]
> [    4.564775] pci 0000:06:04.0: PCI bridge to [bus 08-08]
> [    4.564776] pci 0000:06:04.0:   bridge window [io  disabled]
> [    4.564781] pci 0000:06:04.0:   bridge window [mem disabled]
> [    4.564785] pci 0000:06:04.0:   bridge window [mem pref disabled]
> [    4.564791] pci 0000:05:00.0: PCI bridge to [bus 06-08]
> [    4.564792] pci 0000:05:00.0:   bridge window [io  disabled]
> [    4.564797] pci 0000:05:00.0:   bridge window [mem disabled]
> [    4.564801] pci 0000:05:00.0:   bridge window [mem pref disabled]
> [    4.564807] pci 0000:00:05.0: PCI bridge to [bus 05-08]
> [    4.564809] pci 0000:00:05.0:   bridge window [io  disabled]
> [    4.564812] pci 0000:00:05.0:   bridge window [mem disabled]
> [    4.564814] pci 0000:00:05.0:   bridge window [mem pref disabled]
> [    4.564818] pci 0000:0a:02.0: PCI bridge to [bus 0b-0b]
> [    4.564819] pci 0000:0a:02.0:   bridge window [io  disabled]
> [    4.564824] pci 0000:0a:02.0:   bridge window [mem disabled]
> [    4.564828] pci 0000:0a:02.0:   bridge window [mem pref disabled]
> [    4.564834] pci 0000:0a:04.0: PCI bridge to [bus 0c-0c]
> [    4.564836] pci 0000:0a:04.0:   bridge window [io  disabled]
> [    4.564840] pci 0000:0a:04.0:   bridge window [mem disabled]
> [    4.564844] pci 0000:0a:04.0:   bridge window [mem pref disabled]
> [    4.564850] pci 0000:09:00.0: PCI bridge to [bus 0a-0c]
> [    4.564852] pci 0000:09:00.0:   bridge window [io  disabled]
> [    4.564857] pci 0000:09:00.0:   bridge window [mem disabled]
> [    4.564860] pci 0000:09:00.0:   bridge window [mem pref disabled]
> [    4.564867] pci 0000:00:07.0: PCI bridge to [bus 09-0c]
> [    4.564868] pci 0000:00:07.0:   bridge window [io  disabled]
> [    4.564871] pci 0000:00:07.0:   bridge window [mem disabled]
> [    4.564874] pci 0000:00:07.0:   bridge window [mem pref disabled]
> [    4.564878] pci 0000:00:09.0: PCI bridge to [bus 0d-0d]
> [    4.564879] pci 0000:00:09.0:   bridge window [io  disabled]
> [    4.564882] pci 0000:00:09.0:   bridge window [mem disabled]
> [    4.564884] pci 0000:00:09.0:   bridge window [mem pref disabled]
> [    4.564888] pci 0000:00:0a.0: PCI bridge to [bus 0e-0e]
> [    4.564889] pci 0000:00:0a.0:   bridge window [io  disabled]
> [    4.564893] pci 0000:00:0a.0:   bridge window [mem disabled]
> [    4.564895] pci 0000:00:0a.0:   bridge window [mem pref disabled]
> [    4.564900] pci 0000:0f:00.0: BAR 6: assigned [mem 0xb1c00000-0xb1c7ffff pref]
> [    4.564902] pci 0000:00:1c.0: PCI bridge to [bus 0f-0f]
> [    4.564904] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
> [    4.564908] pci 0000:00:1c.0:   bridge window [mem 0xb1900000-0xb19fffff]
> [    4.564911] pci 0000:00:1c.0:   bridge window [mem 0xb1c00000-0xb1dfffff pref]
> [    4.564916] pci 0000:10:00.0: BAR 6: assigned [mem 0xb1810000-0xb181ffff pref]
> [    4.564918] pci 0000:00:1c.4: PCI bridge to [bus 10-10]
> [    4.564920] pci 0000:00:1c.4:   bridge window [io  0x4000-0x4fff]
> [    4.564924] pci 0000:00:1c.4:   bridge window [mem 0xb1000000-0xb18fffff]
> [    4.564927] pci 0000:00:1c.4:   bridge window [mem 0xb0000000-0xb0ffffff 64bit pref]
> [    4.564932] pci 0000:00:1c.5: PCI bridge to [bus 11-11]
> [    4.564934] pci 0000:00:1c.5:   bridge window [io  0x5000-0x5fff]
> [    4.564937] pci 0000:00:1c.5:   bridge window [mem 0xb1e00000-0xb1ffffff]
> [    4.564941] pci 0000:00:1c.5:   bridge window [mem 0xb2000000-0xb21fffff 64bit pref]
> [    4.564945] pci 0000:00:1e.0: PCI bridge to [bus 12-12]
> [    4.564947] pci 0000:00:1e.0:   bridge window [io  disabled]
> [    4.564950] pci 0000:00:1e.0:   bridge window [mem disabled]
> [    4.564953] pci 0000:00:1e.0:   bridge window [mem pref disabled]
> [    4.564963]   alloc irq_desc for 28 on node -1
> [    4.564968]   alloc kstat_irqs on node -1
> [    4.564973] pci 0000:00:01.0: PCI INT A -> GSI 28 (level, low) -> IRQ 28
> [    4.564976] pci 0000:00:01.0: setting latency timer to 64
> [    4.564981]   alloc irq_desc for 24 on node -1
> [    4.564983]   alloc kstat_irqs on node -1
> [    4.564986] pci 0000:00:03.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
> [    4.564989] pci 0000:00:03.0: setting latency timer to 64
> [    4.564994]   alloc irq_desc for 26 on node -1
> [    4.564995]   alloc kstat_irqs on node -1
> [    4.564999] pci 0000:00:05.0: PCI INT A -> GSI 26 (level, low) -> IRQ 26
> [    4.565002] pci 0000:00:05.0: setting latency timer to 64
> [    4.565011] pci 0000:05:00.0: setting latency timer to 64
> [    4.565020] pci 0000:06:02.0: setting latency timer to 64
> [    4.565030] pci 0000:06:04.0: setting latency timer to 64
> [    4.565036]   alloc irq_desc for 30 on node -1
> [    4.565037]   alloc kstat_irqs on node -1
> [    4.565040] pci 0000:00:07.0: PCI INT A -> GSI 30 (level, low) -> IRQ 30
> [    4.565043] pci 0000:00:07.0: setting latency timer to 64
> [    4.565052] pci 0000:09:00.0: setting latency timer to 64
> [    4.565062] pci 0000:0a:02.0: setting latency timer to 64
> [    4.565071] pci 0000:0a:04.0: setting latency timer to 64
> [    4.565077]   alloc irq_desc for 32 on node -1
> [    4.565078]   alloc kstat_irqs on node -1
> [    4.565082] pci 0000:00:09.0: PCI INT A -> GSI 32 (level, low) -> IRQ 32
> [    4.565084] pci 0000:00:09.0: setting latency timer to 64
> [    4.565090]   alloc irq_desc for 33 on node -1
> [    4.565091]   alloc kstat_irqs on node -1
> [    4.565094] pci 0000:00:0a.0: PCI INT A -> GSI 33 (level, low) -> IRQ 33
> [    4.565097] pci 0000:00:0a.0: setting latency timer to 64
> [    4.565103]   alloc irq_desc for 16 on node -1
> [    4.565104]   alloc kstat_irqs on node -1
> [    4.565107] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    4.565110] pci 0000:00:1c.0: setting latency timer to 64
> [    4.565116] pci 0000:00:1c.4: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    4.565119] pci 0000:00:1c.4: setting latency timer to 64
> [    4.565125]   alloc irq_desc for 17 on node -1
> [    4.565126]   alloc kstat_irqs on node -1
> [    4.565129] pci 0000:00:1c.5: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> [    4.565132] pci 0000:00:1c.5: setting latency timer to 64
> [    4.565137] pci 0000:00:1e.0: setting latency timer to 64
> [    4.565140] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
> [    4.565141] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
> [    4.565143] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
> [    4.565144] pci_bus 0000:00: resource 7 [mem 0x000c4000-0x000cbfff]
> [    4.565146] pci_bus 0000:00: resource 8 [mem 0xfed40000-0xfedfffff]
> [    4.565147] pci_bus 0000:00: resource 9 [mem 0xb0000000-0xfdffffff]
> [    4.565149] pci_bus 0000:01: resource 0 [io  0x2000-0x2fff]
> [    4.565151] pci_bus 0000:01: resource 1 [mem 0xb1a00000-0xb1afffff]
> [    4.565153] pci_bus 0000:0f: resource 0 [io  0x1000-0x1fff]
> [    4.565154] pci_bus 0000:0f: resource 1 [mem 0xb1900000-0xb19fffff]
> [    4.565156] pci_bus 0000:0f: resource 2 [mem 0xb1c00000-0xb1dfffff pref]
> [    4.565158] pci_bus 0000:10: resource 0 [io  0x4000-0x4fff]
> [    4.565159] pci_bus 0000:10: resource 1 [mem 0xb1000000-0xb18fffff]
> [    4.565161] pci_bus 0000:10: resource 2 [mem 0xb0000000-0xb0ffffff 64bit pref]
> [    4.565162] pci_bus 0000:11: resource 0 [io  0x5000-0x5fff]
> [    4.565164] pci_bus 0000:11: resource 1 [mem 0xb1e00000-0xb1ffffff]
> [    4.565166] pci_bus 0000:11: resource 2 [mem 0xb2000000-0xb21fffff 64bit pref]
> [    4.565167] pci_bus 0000:12: resource 4 [io  0x0000-0x0cf7]
> [    4.565169] pci_bus 0000:12: resource 5 [io  0x0d00-0xffff]
> [    4.565170] pci_bus 0000:12: resource 6 [mem 0x000a0000-0x000bffff]
> [    4.565172] pci_bus 0000:12: resource 7 [mem 0x000c4000-0x000cbfff]
> [    4.565173] pci_bus 0000:12: resource 8 [mem 0xfed40000-0xfedfffff]
> [    4.565175] pci_bus 0000:12: resource 9 [mem 0xb0000000-0xfdffffff]
> [    4.565205] NET: Registered protocol family 2
> [    4.565561] IP route cache hash table entries: 524288 (order: 10, 4194304 bytes)
> [    4.566849] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
> [    4.568329] TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
> [    4.568880] TCP: Hash tables configured (established 524288 bind 65536)
> [    4.568882] TCP reno registered
> [    4.568992] UDP hash table entries: 16384 (order: 8, 1572864 bytes)
> [    4.569472] UDP-Lite hash table entries: 16384 (order: 8, 1572864 bytes)
> [    4.570042] NET: Registered protocol family 1
> [    4.570456] pci 0000:10:00.0: Boot video device
> [    4.570460] PCI: CLS 64 bytes, default 64
> [    4.570461] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
> [    4.570463] Placing 64MB software IO TLB between ffff88000a000000 - ffff88000e000000
> [    4.570464] software IO TLB at phys 0xa000000 - 0xe000000
> [    4.571566] Scanning for low memory corruption every 60 seconds
> [    4.571652] audit: initializing netlink socket (disabled)
> [    4.571659] type=2000 audit(1283350651.240:1): initialized
> [    4.583951] HugeTLB registered 2 MB page size, pre-allocated 0 pages
> [    4.585171] VFS: Disk quotas dquot_6.5.2
> [    4.585230] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> [    4.585841] fuse init (API version 7.15)
> [    4.585913] msgmni has been set to 32768
> [    4.586121] alg: No test for stdrng (krng)
> [    4.586168] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
> [    4.586170] io scheduler noop registered
> [    4.586171] io scheduler deadline registered (default)
> [    4.586205] io scheduler cfq registered
> [    4.586327] pcieport 0000:00:01.0: setting latency timer to 64
> [    4.586351]   alloc irq_desc for 64 on node -1
> [    4.586353]   alloc kstat_irqs on node -1
> [    4.586365] pcieport 0000:00:01.0: irq 64 for MSI/MSI-X
> [    4.586420] pcieport 0000:00:03.0: setting latency timer to 64
> [    4.586441]   alloc irq_desc for 65 on node -1
> [    4.586442]   alloc kstat_irqs on node -1
> [    4.586447] pcieport 0000:00:03.0: irq 65 for MSI/MSI-X
> [    4.586497] pcieport 0000:00:05.0: setting latency timer to 64
> [    4.586518]   alloc irq_desc for 66 on node -1
> [    4.586519]   alloc kstat_irqs on node -1
> [    4.586524] pcieport 0000:00:05.0: irq 66 for MSI/MSI-X
> [    4.586573] pcieport 0000:00:07.0: setting latency timer to 64
> [    4.586595]   alloc irq_desc for 67 on node -1
> [    4.586596]   alloc kstat_irqs on node -1
> [    4.586601] pcieport 0000:00:07.0: irq 67 for MSI/MSI-X
> [    4.586652] pcieport 0000:00:09.0: setting latency timer to 64
> [    4.586674]   alloc irq_desc for 68 on node -1
> [    4.586675]   alloc kstat_irqs on node -1
> [    4.586680] pcieport 0000:00:09.0: irq 68 for MSI/MSI-X
> [    4.586731] pcieport 0000:00:0a.0: setting latency timer to 64
> [    4.586753]   alloc irq_desc for 69 on node -1
> [    4.586754]   alloc kstat_irqs on node -1
> [    4.586759] pcieport 0000:00:0a.0: irq 69 for MSI/MSI-X
> [    4.586814] pcieport 0000:00:1c.0: setting latency timer to 64
> [    4.586840]   alloc irq_desc for 70 on node -1
> [    4.586841]   alloc kstat_irqs on node -1
> [    4.586847] pcieport 0000:00:1c.0: irq 70 for MSI/MSI-X
> [    4.586913] pcieport 0000:00:1c.4: setting latency timer to 64
> [    4.586939]   alloc irq_desc for 71 on node -1
> [    4.586940]   alloc kstat_irqs on node -1
> [    4.586945] pcieport 0000:00:1c.4: irq 71 for MSI/MSI-X
> [    4.587008] pcieport 0000:00:1c.5: setting latency timer to 64
> [    4.587035]   alloc irq_desc for 72 on node -1
> [    4.587036]   alloc kstat_irqs on node -1
> [    4.587041] pcieport 0000:00:1c.5: irq 72 for MSI/MSI-X
> [    4.587116] pcieport 0000:05:00.0: setting latency timer to 64
> [    4.587187] pcieport 0000:06:02.0: setting latency timer to 64
> [    4.587228]   alloc irq_desc for 73 on node -1
> [    4.587229]   alloc kstat_irqs on node -1
> [    4.587238] pcieport 0000:06:02.0: irq 73 for MSI/MSI-X
> [    4.587314] pcieport 0000:06:04.0: setting latency timer to 64
> [    4.587355]   alloc irq_desc for 74 on node -1
> [    4.587356]   alloc kstat_irqs on node -1
> [    4.587364] pcieport 0000:06:04.0: irq 74 for MSI/MSI-X
> [    4.587441] pcieport 0000:09:00.0: setting latency timer to 64
> [    4.587512] pcieport 0000:0a:02.0: setting latency timer to 64
> [    4.587553]   alloc irq_desc for 75 on node -1
> [    4.587554]   alloc kstat_irqs on node -1
> [    4.587562] pcieport 0000:0a:02.0: irq 75 for MSI/MSI-X
> [    4.587636] pcieport 0000:0a:04.0: setting latency timer to 64
> [    4.587677]   alloc irq_desc for 76 on node -1
> [    4.587678]   alloc kstat_irqs on node -1
> [    4.587687] pcieport 0000:0a:04.0: irq 76 for MSI/MSI-X
> [    4.587877] aer 0000:00:01.0:pcie02: service driver aer loaded
> [    4.587898] aer 0000:00:03.0:pcie02: service driver aer loaded
> [    4.587931] aer 0000:00:05.0:pcie02: service driver aer loaded
> [    4.587963] aer 0000:00:07.0:pcie02: service driver aer loaded
> [    4.587983] aer 0000:00:09.0:pcie02: service driver aer loaded
> [    4.588009] aer 0000:00:0a.0:pcie02: service driver aer loaded
> [    4.588026] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> [    4.588159] pciehp 0000:00:1c.0:pcie04: HPC vendor_id 8086 device_id 3a40 ss_vid 8086 ss_did 34f8
> [    4.588182] pciehp 0000:00:1c.0:pcie04: service driver pciehp loaded
> [    4.588192] pciehp 0000:00:1c.4:pcie04: HPC vendor_id 8086 device_id 3a48 ss_vid 8086 ss_did 34f8
> [    4.588211] pciehp 0000:00:1c.4:pcie04: service driver pciehp loaded
> [    4.588220] pciehp 0000:00:1c.5:pcie04: HPC vendor_id 8086 device_id 3a4a ss_vid 8086 ss_did 34f8
> [    4.588239] pciehp 0000:00:1c.5:pcie04: service driver pciehp loaded
> [    4.588245] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
> [    4.588309] intel_idle: MWAIT substates: 0x1120
> [    4.588311] intel_idle: v0.4 model 0x2C
> [    4.588312] intel_idle: lapic_timer_reliable_states 0xffffffff
> [    4.588472] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input0
> [    4.588481] ACPI: Sleep Button [SLPB]
> [    4.588515] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> [    4.588518] ACPI: Power Button [PWRF]
> [    4.588723] ACPI: acpi_idle yielding to intel_idle
> [    4.604180] ERST: Error Record Serialization Table (ERST) support is initialized.
> [    4.604364] Linux agpgart interface v0.103
> [    4.604383] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [    4.624906] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> [    4.645424] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> [    4.645462] Freeing initrd memory: 11304k freed
> [    4.666080] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> [    4.686617] 00:09: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> [    4.687644] brd: module loaded
> [    4.688069] loop: module loaded
> [    4.688248] ata_piix 0000:00:1f.2: version 2.13
> [    4.688263]   alloc irq_desc for 18 on node -1
> [    4.688264]   alloc kstat_irqs on node -1
> [    4.688272] ata_piix 0000:00:1f.2: PCI INT B -> GSI 18 (level, low) -> IRQ 18
> [    4.688276] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
> [    4.840369] ata_piix 0000:00:1f.2: setting latency timer to 64
> [    4.840460] scsi0 : ata_piix
> [    4.840542] scsi1 : ata_piix
> [    4.841020] ata1: SATA max UDMA/133 cmd 0x3138 ctl 0x314c bmdma 0x3110 irq 18
> [    4.841025] ata2: SATA max UDMA/133 cmd 0x3130 ctl 0x3148 bmdma 0x3118 irq 18
> [    4.841042]   alloc irq_desc for 21 on node -1
> [    4.841043]   alloc kstat_irqs on node -1
> [    4.841047] ata_piix 0000:00:1f.5: PCI INT D -> GSI 21 (level, low) -> IRQ 21
> [    4.841050] ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
> [    4.999950] ata_piix 0000:00:1f.5: setting latency timer to 64
> [    5.000007] scsi2 : ata_piix
> [    5.000065] scsi3 : ata_piix
> [    5.000516] ata3: SATA max UDMA/133 cmd 0x3128 ctl 0x3144 bmdma 0x30f0 irq 21
> [    5.000519] ata4: SATA max UDMA/133 cmd 0x3120 ctl 0x3140 bmdma 0x30f8 irq 21
> [    5.000749] Fixed MDIO Bus: probed
> [    5.000773] PPP generic driver version 2.4.2
> [    5.000798] tun: Universal TUN/TAP device driver, 1.6
> [    5.000799] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> [    5.000868] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    5.000885]   alloc irq_desc for 19 on node -1
> [    5.000886]   alloc kstat_irqs on node -1
> [    5.000890] ehci_hcd 0000:00:1a.7: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> [    5.000902] ehci_hcd 0000:00:1a.7: setting latency timer to 64
> [    5.000905] ehci_hcd 0000:00:1a.7: EHCI Host Controller
> [    5.000938] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
> [    5.000961] ehci_hcd 0000:00:1a.7: debug port 1
> [    5.004846] ehci_hcd 0000:00:1a.7: cache line size of 64 is not supported
> [    5.004857] ehci_hcd 0000:00:1a.7: irq 19, io mem 0xb1b21000
> [    5.019879] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
> [    5.019989] hub 1-0:1.0: USB hub found
> [    5.019993] hub 1-0:1.0: 6 ports detected
> [    5.020069] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 16 (level, low) -> IRQ 16
> [    5.020080] ehci_hcd 0000:00:1d.7: setting latency timer to 64
> [    5.020083] ehci_hcd 0000:00:1d.7: EHCI Host Controller
> [    5.020109] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
> [    5.020129] ehci_hcd 0000:00:1d.7: debug port 1
> [    5.023990] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
> [    5.024001] ehci_hcd 0000:00:1d.7: irq 16, io mem 0xb1b20000
> [    5.039827] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
> [    5.039919] hub 2-0:1.0: USB hub found
> [    5.039922] hub 2-0:1.0: 6 ports detected
> [    5.039984] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    5.039995] uhci_hcd: USB Universal Host Controller Interface driver
> [    5.040038] uhci_hcd 0000:00:1a.0: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> [    5.040043] uhci_hcd 0000:00:1a.0: setting latency timer to 64
> [    5.040045] uhci_hcd 0000:00:1a.0: UHCI Host Controller
> [    5.040075] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
> [    5.040096] uhci_hcd 0000:00:1a.0: irq 19, io base 0x000030c0
> [    5.040182] hub 3-0:1.0: USB hub found
> [    5.040186] hub 3-0:1.0: 2 ports detected
> [    5.040241] uhci_hcd 0000:00:1a.1: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> [    5.040245] uhci_hcd 0000:00:1a.1: setting latency timer to 64
> [    5.040248] uhci_hcd 0000:00:1a.1: UHCI Host Controller
> [    5.040274] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
> [    5.040294] uhci_hcd 0000:00:1a.1: irq 19, io base 0x000030a0
> [    5.040376] hub 4-0:1.0: USB hub found
> [    5.040379] hub 4-0:1.0: 2 ports detected
> [    5.040431] uhci_hcd 0000:00:1a.2: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> [    5.040435] uhci_hcd 0000:00:1a.2: setting latency timer to 64
> [    5.040437] uhci_hcd 0000:00:1a.2: UHCI Host Controller
> [    5.040464] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
> [    5.040485] uhci_hcd 0000:00:1a.2: irq 19, io base 0x00003080
> [    5.040568] hub 5-0:1.0: USB hub found
> [    5.040570] hub 5-0:1.0: 2 ports detected
> [    5.040624] uhci_hcd 0000:00:1d.0: PCI INT D -> GSI 16 (level, low) -> IRQ 16
> [    5.040633] uhci_hcd 0000:00:1d.0: setting latency timer to 64
> [    5.040636] uhci_hcd 0000:00:1d.0: UHCI Host Controller
> [    5.040666] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
> [    5.040686] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00003060
> [    5.040768] hub 6-0:1.0: USB hub found
> [    5.040771] hub 6-0:1.0: 2 ports detected
> [    5.040824] uhci_hcd 0000:00:1d.1: PCI INT D -> GSI 16 (level, low) -> IRQ 16
> [    5.040828] uhci_hcd 0000:00:1d.1: setting latency timer to 64
> [    5.040831] uhci_hcd 0000:00:1d.1: UHCI Host Controller
> [    5.040855] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
> [    5.040875] uhci_hcd 0000:00:1d.1: irq 16, io base 0x00003040
> [    5.040960] hub 7-0:1.0: USB hub found
> [    5.040963] hub 7-0:1.0: 2 ports detected
> [    5.041015] uhci_hcd 0000:00:1d.2: PCI INT D -> GSI 16 (level, low) -> IRQ 16
> [    5.041020] uhci_hcd 0000:00:1d.2: setting latency timer to 64
> [    5.041022] uhci_hcd 0000:00:1d.2: UHCI Host Controller
> [    5.041049] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
> [    5.041070] uhci_hcd 0000:00:1d.2: irq 16, io base 0x00003020
> [    5.041152] hub 8-0:1.0: USB hub found
> [    5.041155] hub 8-0:1.0: 2 ports detected
> [    5.041247] PNP: No PS/2 controller found. Probing ports directly.
> [    5.042106] i8042.c: No controller found.
> [    5.042144] mice: PS/2 mouse device common for all mice
> [    5.042204] rtc_cmos 00:03: RTC can wake from S4
> [    5.042240] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
> [    5.042264] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
> [    5.042339] device-mapper: uevent: version 1.0.3
> [    5.042435] device-mapper: ioctl: 4.18.0-ioctl (2010-06-29) initialised: dm-devel@redhat.com
> [    5.042499] device-mapper: multipath: version 1.1.1 loaded
> [    5.042502] device-mapper: multipath round-robin: version 1.0.0 loaded
> [    5.043119] cpuidle: using governor ladder
> [    5.043828] cpuidle: using governor menu
> [    5.044106] TCP cubic registered
> [    5.044232] NET: Registered protocol family 10
> [    5.044615] lo: Disabled Privacy Extensions
> [    5.044805] NET: Registered protocol family 17
> [    5.044818] Registering the dns_resolver key type
> [    5.049114] PM: Resume from disk failed.
> [    5.049124] registered taskstats version 1
> [    5.049644]   Magic number: 10:296:282
> [    5.049663] tty tty19: hash matches
> [    5.050614] rtc_cmos 00:03: setting system clock to 2010-09-01 14:17:32 UTC (1283350652)
> [    5.050617] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
> [    5.050618] EDD information not available.
> [    5.359768] ata3: SATA link down (SStatus 4 SControl 300)
> [    5.370495] ata4: SATA link down (SStatus 0 SControl 300)
> [    5.458791] usb 2-1: new high speed USB device using ehci_hcd and address 2
> [    5.549328] ata2.00: SATA link down (SStatus 0 SControl 300)
> [    5.549342] ata2.01: SATA link down (SStatus 0 SControl 300)
> [    5.560046] ata1.00: SATA link down (SStatus 0 SControl 300)
> [    5.560059] ata1.01: SATA link down (SStatus 0 SControl 300)
> [    5.560312] Freeing unused kernel memory: 784k freed
> [    5.560472] Write protecting the kernel read-only data: 10240k
> [    5.564168] Freeing unused kernel memory: 264k freed
> [    5.566067] Freeing unused kernel memory: 1528k freed
> [    5.581124] udev[141]: starting version 162
> [    5.584886] md: linear personality registered for level -1
> [    5.586713] md: multipath personality registered for level -4
> [    5.588178] md: raid0 personality registered for level 0
> [    5.590698] md: raid1 personality registered for level 1
> [    5.592046] async_tx: api initialized (async)
> [    5.604973] dca service started, version 1.12.1
> [    5.612003] Intel(R) Gigabit Ethernet Network Driver - version 2.1.0-k2
> [    5.612005] Copyright (c) 2007-2009 Intel Corporation.
> [    5.612036]   alloc irq_desc for 40 on node -1
> [    5.612037]   alloc kstat_irqs on node -1
> [    5.612044] igb 0000:01:00.0: PCI INT B -> GSI 40 (level, low) -> IRQ 40
> [    5.612056] igb 0000:01:00.0: setting latency timer to 64
> [    5.612322]   alloc irq_desc for 77 on node -1
> [    5.612323]   alloc kstat_irqs on node -1
> [    5.612327] igb 0000:01:00.0: irq 77 for MSI/MSI-X
> [    5.612328]   alloc irq_desc for 78 on node -1
> [    5.612329]   alloc kstat_irqs on node -1
> [    5.612332] igb 0000:01:00.0: irq 78 for MSI/MSI-X
> [    5.612333]   alloc irq_desc for 79 on node -1
> [    5.612334]   alloc kstat_irqs on node -1
> [    5.612336] igb 0000:01:00.0: irq 79 for MSI/MSI-X
> [    5.612338]   alloc irq_desc for 80 on node -1
> [    5.612339]   alloc kstat_irqs on node -1
> [    5.612341] igb 0000:01:00.0: irq 80 for MSI/MSI-X
> [    5.612343]   alloc irq_desc for 81 on node -1
> [    5.612344]   alloc kstat_irqs on node -1
> [    5.612346] igb 0000:01:00.0: irq 81 for MSI/MSI-X
> [    5.612348]   alloc irq_desc for 82 on node -1
> [    5.612349]   alloc kstat_irqs on node -1
> [    5.612351] igb 0000:01:00.0: irq 82 for MSI/MSI-X
> [    5.612352]   alloc irq_desc for 83 on node -1
> [    5.612353]   alloc kstat_irqs on node -1
> [    5.612358] igb 0000:01:00.0: irq 83 for MSI/MSI-X
> [    5.612359]   alloc irq_desc for 84 on node -1
> [    5.612361]   alloc kstat_irqs on node -1
> [    5.612363] igb 0000:01:00.0: irq 84 for MSI/MSI-X
> [    5.612364]   alloc irq_desc for 85 on node -1
> [    5.612365]   alloc kstat_irqs on node -1
> [    5.612367] igb 0000:01:00.0: irq 85 for MSI/MSI-X
> [    5.612408] igb 0000:01:00.0: 0 vfs allocated
> [    5.628786] Fusion MPT base driver 3.04.17
> [    5.628789] Copyright (c) 1999-2008 LSI Corporation
> [    5.640100] Initializing USB Mass Storage driver...
> [    5.640155] Fusion MPT SAS Host driver 3.04.17
> [    5.640188] mptsas 0000:0f:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    5.640254] scsi4 : usb-storage 2-1:1.0
> [    5.640261] mptbase: ioc0: Initiating bringup
> [    5.640318] usbcore: registered new interface driver usb-storage
> [    5.640320] USB Mass Storage support registered.
> [    5.757925] raid6: int64x1   2693 MB/s
> [    5.860597] igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
> [    5.860600] igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:15:17:da:f9:cc
> [    5.860676] igb 0000:01:00.0: eth0: PBA No: 0080ff-0ff
> [    5.860678] igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
> [    5.860692] igb 0000:01:00.1: PCI INT A -> GSI 28 (level, low) -> IRQ 28
> [    5.860701] igb 0000:01:00.1: setting latency timer to 64
> [    5.861798]   alloc irq_desc for 86 on node -1
> [    5.861799]   alloc kstat_irqs on node -1
> [    5.861803] igb 0000:01:00.1: irq 86 for MSI/MSI-X
> [    5.861805]   alloc irq_desc for 87 on node -1
> [    5.861806]   alloc kstat_irqs on node -1
> [    5.861808] igb 0000:01:00.1: irq 87 for MSI/MSI-X
> [    5.861809]   alloc irq_desc for 88 on node -1
> [    5.861811]   alloc kstat_irqs on node -1
> [    5.861813] igb 0000:01:00.1: irq 88 for MSI/MSI-X
> [    5.861814]   alloc irq_desc for 89 on node -1
> [    5.861815]   alloc kstat_irqs on node -1
> [    5.861818] igb 0000:01:00.1: irq 89 for MSI/MSI-X
> [    5.861819]   alloc irq_desc for 90 on node -1
> [    5.861820]   alloc kstat_irqs on node -1
> [    5.861822] igb 0000:01:00.1: irq 90 for MSI/MSI-X
> [    5.861824]   alloc irq_desc for 91 on node -1
> [    5.861825]   alloc kstat_irqs on node -1
> [    5.861827] igb 0000:01:00.1: irq 91 for MSI/MSI-X
> [    5.861828]   alloc irq_desc for 92 on node -1
> [    5.861829]   alloc kstat_irqs on node -1
> [    5.861832] igb 0000:01:00.1: irq 92 for MSI/MSI-X
> [    5.861833]   alloc irq_desc for 93 on node -1
> [    5.861834]   alloc kstat_irqs on node -1
> [    5.861836] igb 0000:01:00.1: irq 93 for MSI/MSI-X
> [    5.861838]   alloc irq_desc for 94 on node -1
> [    5.861839]   alloc kstat_irqs on node -1
> [    5.861841] igb 0000:01:00.1: irq 94 for MSI/MSI-X
> [    5.861878] igb 0000:01:00.1: 0 vfs allocated
> [    5.887672] usb 5-1: new full speed USB device using uhci_hcd and address 2
> [    5.927476] raid6: int64x2   3467 MB/s
> [    6.066479] usbcore: registered new interface driver hiddev
> [    6.069958] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1:1.0/input/input2
> [    6.070020] generic-usb 0003:046B:FF10.0001: input,hidraw0: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input0
> [    6.073910] input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.2/usb5/5-1/5-1:1.1/input/input3
> [    6.073970] generic-usb 0003:046B:FF10.0002: input,hidraw1: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.2-1/input1
> [    6.073981] usbcore: registered new interface driver usbhid
> [    6.073983] usbhid: USB HID core driver
> [    6.097050] raid6: int64x4   2331 MB/s
> [    6.107679] igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
> [    6.107682] igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:15:17:da:f9:cd
> [    6.107757] igb 0000:01:00.1: eth1: PBA No: 0080ff-0ff
> [    6.107759] igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
> [    6.266593] raid6: int64x8   2433 MB/s
> [    6.436136] raid6: sse2x1    7237 MB/s
> [    6.605687] raid6: sse2x2    8458 MB/s
> [    6.638140] scsi 4:0:0:0: CD-ROM            TEAC     DV-W28S-V        1.0A PQ: 0 ANSI: 0
> [    6.651538] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
> [    6.651542] cdrom: Uniform CD-ROM driver Revision: 3.20
> [    6.651669] sr 4:0:0:0: Attached scsi CD-ROM sr0
> [    6.651724] sr 4:0:0:0: Attached scsi generic sg0 type 5
> [    6.775244] raid6: sse2x4    9368 MB/s
> [    6.775246] raid6: using algorithm sse2x4 (9368 MB/s)
> [    6.776274] xor: automatically using best checksumming function: generic_sse
> [    6.825107]    generic_sse: 11078.400 MB/sec
> [    6.825109] xor: using function: generic_sse (11078.400 MB/sec)
> [    6.829141] md: raid6 personality registered for level 6
> [    6.829143] md: raid5 personality registered for level 5
> [    6.829144] md: raid4 personality registered for level 4
> [    6.834056] md: raid10 personality registered for level 10
> [    7.054612] ioc0: LSISAS1078 C2: Capabilities={Initiator}
> [    7.054633] mptsas 0000:0f:00.0: setting latency timer to 64
> [   18.785072] scsi5 : ioc0: LSISAS1078 C2, FwRev=011b0000h, Ports=1, MaxQ=276, IRQ=16
> [   18.788724] mptsas: ioc0: attaching sata device: fw_channel 0, fw_id 0, phy 0, sas_addr 0x1221000000000000
> [   18.791646] scsi 5:0:0:0: Direct-Access     ATA      ST9500530NS      SN04 PQ: 0 ANSI: 5
> [   18.792204] sd 5:0:0:0: Attached scsi generic sg1 type 0
> [   18.792783] sd 5:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
> [   18.792796] mptsas: ioc0: attaching sata device: fw_channel 0, fw_id 2, phy 2, sas_addr 0x1221000002000000
> [   18.795054] scsi 5:0:1:0: Direct-Access     ATA      ST9250410AS      SDM1 PQ: 0 ANSI: 5
> [   18.795335] sd 5:0:1:0: Attached scsi generic sg2 type 0
> [   18.795723] sd 5:0:1:0: [sdb] 488397168 512-byte logical blocks: (250 GB/232 GiB)
> [   18.795735] mptsas: ioc0: attaching sata device: fw_channel 0, fw_id 4, phy 4, sas_addr 0x1221000004000000
> [   18.797974] scsi 5:0:2:0: Direct-Access     ATA      ST9250410AS      SDM1 PQ: 0 ANSI: 5
> [   18.798277] sd 5:0:2:0: Attached scsi generic sg3 type 0
> [   18.798703] sd 5:0:2:0: [sdc] 488397168 512-byte logical blocks: (250 GB/232 GiB)
> [   18.798715] mptsas: ioc0: attaching sata device: fw_channel 0, fw_id 6, phy 6, sas_addr 0x1221000006000000
> [   18.799672] scsi 5:0:3:0: Direct-Access     ATA      WDC WD1200BEVS-7 1A01 PQ: 0 ANSI: 5
> [   18.799996] sd 5:0:3:0: Attached scsi generic sg4 type 0
> [   18.800161] sd 5:0:3:0: [sdd] 234441648 512-byte logical blocks: (120 GB/111 GiB)
> [   18.800227] mptsas: ioc0: attaching sata device: fw_channel 0, fw_id 7, phy 7, sas_addr 0x1221000007000000
> [   18.801271] scsi 5:0:4:0: Direct-Access     ATA      FUJITSU MHW2160B 001C PQ: 0 ANSI: 5
> [   18.801586] sd 5:0:4:0: Attached scsi generic sg5 type 0
> [   18.801874] sd 5:0:4:0: [sde] 312581808 512-byte logical blocks: (160 GB/149 GiB)
> [   18.804204] sd 5:0:3:0: [sdd] Write Protect is off
> [   18.804209] sd 5:0:3:0: [sdd] Mode Sense: 73 00 00 08
> [   18.805014] sd 5:0:3:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [   18.852237] sd 5:0:0:0: [sda] Write Protect is off
> [   18.852242] sd 5:0:0:0: [sda] Mode Sense: 73 00 00 08
> [   18.854438] sd 5:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [   18.860200]  sdd:
> [   18.870716] sd 5:0:3:0: [sdd] Attached SCSI disk
> [   18.891148] sd 5:0:1:0: [sdb] Write Protect is off
> [   18.891153] sd 5:0:1:0: [sdb] Mode Sense: 73 00 00 08
> [   18.891891] sd 5:0:2:0: [sdc] Write Protect is off
> [   18.891896] sd 5:0:2:0: [sdc] Mode Sense: 73 00 00 08
> [   18.893312] sd 5:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [   18.894018] sd 5:0:2:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [   18.946635]  sda: sda1 sda2 < sda5 >
> [   18.950451] sd 5:0:4:0: [sde] Write Protect is off
> [   18.950456] sd 5:0:4:0: [sde] Mode Sense: 73 00 00 08
> [   18.951701] sd 5:0:4:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> [   18.995660] sd 5:0:0:0: [sda] Attached SCSI disk
> [   19.004417]  sdb: sdb1
> [   19.004423] sdb: p1 size 1523816448 extends beyond EOD, enabling native capacity
> [   19.006525]  sdc: unknown partition table
> [   19.086892]  sde:
> [   19.115914]  sdb: sdb1
> [   19.115919] sdb: p1 size 1523816448 extends beyond EOD, truncated
> [   19.116889] sd 5:0:2:0: [sdc] Attached SCSI disk
> [   19.206417] sd 5:0:1:0: [sdb] Attached SCSI disk
> [   19.206975] sd 5:0:4:0: [sde] Attached SCSI disk
> [   19.231554] md: bind<sde>
> [   19.236108] md: bind<sdc>
> [   19.251788] md: bind<sdb>
> [   19.269073] md: bind<sdd>
> [   19.276739] md/raid0:md0: looking at sdd
> [   19.276742] md/raid0:md0:   comparing sdd(234441472) with sdd(234441472)
> [   19.276744] md/raid0:md0:   END
> [   19.276745] md/raid0:md0:   ==> UNIQUE
> [   19.276746] md/raid0:md0: 1 zones
> [   19.276747] md/raid0:md0: looking at sdb
> [   19.276748] md/raid0:md0:   comparing sdb(488396928) with sdd(234441472)
> [   19.276753] md/raid0:md0:   NOT EQUAL
> [   19.276755] md/raid0:md0:   comparing sdb(488396928) with sdb(488396928)
> [   19.276759] md/raid0:md0:   END
> [   19.276760] md/raid0:md0:   ==> UNIQUE
> [   19.276762] md/raid0:md0: 2 zones
> [   19.276764] md/raid0:md0: looking at sdc
> [   19.276766] md/raid0:md0:   comparing sdc(488396928) with sdd(234441472)
> [   19.276769] md/raid0:md0:   NOT EQUAL
> [   19.276771] md/raid0:md0:   comparing sdc(488396928) with sdb(488396928)
> [   19.276774] md/raid0:md0:   EQUAL
> [   19.276776] md/raid0:md0: looking at sde
> [   19.276778] md/raid0:md0:   comparing sde(312581632) with sdd(234441472)
> [   19.276782] md/raid0:md0:   NOT EQUAL
> [   19.276784] md/raid0:md0:   comparing sde(312581632) with sdb(488396928)
> [   19.276787] md/raid0:md0:   NOT EQUAL
> [   19.276789] md/raid0:md0:   comparing sde(312581632) with sdc(488396928)
> [   19.276792] md/raid0:md0:   NOT EQUAL
> [   19.276794] md/raid0:md0:   comparing sde(312581632) with sde(312581632)
> [   19.276797] md/raid0:md0:   END
> [   19.276799] md/raid0:md0:   ==> UNIQUE
> [   19.276801] md/raid0:md0: 3 zones
> [   19.276803] md/raid0:md0: FINAL 3 zones
> [   19.276806] md/raid0:md0: zone 1
> [   19.276808] md/raid0:md0: checking sdb ... contained as device 0
> [   19.276812] md/raid0:md0:  (488396928) is smallest!.
> [   19.276814] md/raid0:md0: checking sdc ... contained as device 1
> [   19.276817] md/raid0:md0: checking sdd ... nope.
> [   19.276819] md/raid0:md0: checking sde ... contained as device 2
> [   19.276822] md/raid0:md0:  (312581632) is smallest!.
> [   19.276825] md/raid0:md0: zone->nb_dev: 3, sectors: 234420480
> [   19.276827] md/raid0:md0: current zone start: 312581632
> [   19.276829] md/raid0:md0: zone 2
> [   19.276831] md/raid0:md0: checking sdb ... contained as device 0
> [   19.276834] md/raid0:md0:  (488396928) is smallest!.
> [   19.276836] md/raid0:md0: checking sdc ... contained as device 1
> [   19.276839] md/raid0:md0: checking sdd ... nope.
> [   19.276841] md/raid0:md0: checking sde ... nope.
> [   19.276844] md/raid0:md0: zone->nb_dev: 2, sectors: 351630592
> [   19.276849] md/raid0:md0: current zone start: 488396928
> [   19.276850] md/raid0:md0: done.
> [   19.276851] md/raid0:md0: md_size is 1523816960 sectors.
> [   19.276853] ******* md0 configuration *********
> [   19.276854] zone0=[sdb/sdc/sdd/sde/]
> [   19.276857]         zone offset=0kb device offset=0kb size=468882944kb
> [   19.276858] zone1=[sdb/sdc/sde/]
> [   19.276861]         zone offset=468882944kb device offset=117220736kb size=117210240kb
> [   19.276862] zone2=[sdb/sdc/]
> [   19.276864]         zone offset=586093184kb device offset=156290816kb size=175815296kb
> [   19.276866] **********************************
> [   19.276866] 
> [   19.276875] md0: detected capacity change from 0 to 780194283520
> [   19.292386]  md0: p1
> [   19.600417] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
> [   22.797985] udev[522]: starting version 162
> [   22.817744] Adding 19800076k swap on /dev/sda5.  Priority:-1 extents:1 across:19800076k 
> [   22.992519] type=1400 audit(1283350670.483:2): apparmor="STATUS" info="failed to unpack profile" error=-71 pid=585 comm="apparmor_parser" name="/sbin/dhclient3" offset=125
> [   22.992525] type=1400 audit(1283350670.483:3): apparmor="STATUS" operation="profile_replace" pid=585 comm="apparmor_parser"
> [   23.084845] igb: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/TX
> [   23.085918] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   23.086842] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [   23.113638] GHES: Generic hardware error source: 1 notified via NMI is not supported!
> [   23.132145] lp: driver loaded but no devices found
> [   23.140153] RPC: Registered udp transport module.
> [   23.140155] RPC: Registered tcp transport module.
> [   23.140156] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [   23.141985] tpm_tis 00:0a: 1.2 TPM (device-id 0x0, rev-id 78)
> [   23.167524] ioatdma: Intel(R) QuickData Technology Driver 4.00
> [   23.167571]   alloc irq_desc for 43 on node -1
> [   23.167573]   alloc kstat_irqs on node -1
> [   23.167579] ioatdma 0000:00:16.0: PCI INT A -> GSI 43 (level, low) -> IRQ 43
> [   23.168202] ioatdma 0000:00:16.0: setting latency timer to 64
> [   23.168236]   alloc irq_desc for 95 on node -1
> [   23.168237]   alloc kstat_irqs on node -1
> [   23.168242] ioatdma 0000:00:16.0: irq 95 for MSI/MSI-X
> [   23.168464] igb 0000:01:00.0: DCA enabled
> [   23.168497] igb 0000:01:00.1: DCA enabled
> [   23.168526]   alloc irq_desc for 44 on node -1
> [   23.168529]   alloc kstat_irqs on node -1
> [   23.168533] ioatdma 0000:00:16.1: PCI INT B -> GSI 44 (level, low) -> IRQ 44
> [   23.168549] ioatdma 0000:00:16.1: setting latency timer to 64
> [   23.168576]   alloc irq_desc for 96 on node -1
> [   23.168578]   alloc kstat_irqs on node -1
> [   23.168581] ioatdma 0000:00:16.1: irq 96 for MSI/MSI-X
> [   23.168783]   alloc irq_desc for 45 on node -1
> [   23.168784]   alloc kstat_irqs on node -1
> [   23.168789] ioatdma 0000:00:16.2: PCI INT C -> GSI 45 (level, low) -> IRQ 45
> [   23.168805] ioatdma 0000:00:16.2: setting latency timer to 64
> [   23.168832]   alloc irq_desc for 97 on node -1
> [   23.168833]   alloc kstat_irqs on node -1
> [   23.168837] ioatdma 0000:00:16.2: irq 97 for MSI/MSI-X
> [   23.169044]   alloc irq_desc for 46 on node -1
> [   23.169045]   alloc kstat_irqs on node -1
> [   23.169050] ioatdma 0000:00:16.3: PCI INT D -> GSI 46 (level, low) -> IRQ 46
> [   23.169066] ioatdma 0000:00:16.3: setting latency timer to 64
> [   23.169093]   alloc irq_desc for 98 on node -1
> [   23.169094]   alloc kstat_irqs on node -1
> [   23.169098] ioatdma 0000:00:16.3: irq 98 for MSI/MSI-X
> [   23.169307] ioatdma 0000:00:16.4: PCI INT A -> GSI 43 (level, low) -> IRQ 43
> [   23.169323] ioatdma 0000:00:16.4: setting latency timer to 64
> [   23.169351]   alloc irq_desc for 99 on node -1
> [   23.169352]   alloc kstat_irqs on node -1
> [   23.169356] ioatdma 0000:00:16.4: irq 99 for MSI/MSI-X
> [   23.169567] ioatdma 0000:00:16.5: PCI INT B -> GSI 44 (level, low) -> IRQ 44
> [   23.169583] ioatdma 0000:00:16.5: setting latency timer to 64
> [   23.169612]   alloc irq_desc for 100 on node -1
> [   23.169613]   alloc kstat_irqs on node -1
> [   23.169617] ioatdma 0000:00:16.5: irq 100 for MSI/MSI-X
> [   23.169824] ioatdma 0000:00:16.6: PCI INT C -> GSI 45 (level, low) -> IRQ 45
> [   23.169841] ioatdma 0000:00:16.6: setting latency timer to 64
> [   23.169869]   alloc irq_desc for 101 on node -1
> [   23.169870]   alloc kstat_irqs on node -1
> [   23.169874] ioatdma 0000:00:16.6: irq 101 for MSI/MSI-X
> [   23.170083] ioatdma 0000:00:16.7: PCI INT D -> GSI 46 (level, low) -> IRQ 46
> [   23.170100] ioatdma 0000:00:16.7: setting latency timer to 64
> [   23.170128]   alloc irq_desc for 102 on node -1
> [   23.170129]   alloc kstat_irqs on node -1
> [   23.170133] ioatdma 0000:00:16.7: irq 102 for MSI/MSI-X
> [   23.175279] EDAC MC: Ver: 2.1.0 Sep  1 2010
> [   23.192162] PCI: Discovered peer bus ff
> [   23.194096] PCI: Discovered peer bus fe
> [   23.197633] EDAC MC0: Giving out device to 'i7core_edac.c' 'i7 core #0': DEV 0000:ff:03.0
> [   23.197649] EDAC PCI0: Giving out device to module 'i7core_edac' controller 'EDAC PCI controller': DEV '0000:ff:03.0' (POLLED)
> [   23.197737] EDAC MC1: Giving out device to 'i7core_edac.c' 'i7 core #1': DEV 0000:fe:03.0
> [   23.197744] EDAC PCI1: Giving out device to module 'i7core_edac' controller 'EDAC PCI controller': DEV '0000:fe:03.0' (POLLED)
> [   23.197746] EDAC i7core: Driver loaded.
> [   23.460664] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
> [   33.610436] eth0: no IPv6 routers present
> [  139.876861] usb 6-2: new full speed USB device using uhci_hcd and address 2
> [  140.057606] hub 6-2:1.0: USB hub found
> [  140.058577] hub 6-2:1.0: 3 ports detected
> [  140.336842] usb 6-2.1: new low speed USB device using uhci_hcd and address 3
> [  140.513501] input: Dell Dell USB Keyboard Hub as /devices/pci0000:00/0000:00:1d.0/usb6/6-2/6-2.1/6-2.1:1.0/input/input4
> [  140.513589] generic-usb 0003:413C:2006.0003: input,hidraw2: USB HID v1.10 Keyboard [Dell Dell USB Keyboard Hub] on usb-0000:00:1d.0-2.1/input0
> [  140.561327] input: Dell Dell USB Keyboard Hub as /devices/pci0000:00/0000:00:1d.0/usb6/6-2/6-2.1/6-2.1:1.1/input/input5
> [  140.561426] generic-usb 0003:413C:2006.0004: input,hidraw3: USB HID v1.10 Device [Dell Dell USB Keyboard Hub] on usb-0000:00:1d.0-2.1/input1
> [  195.425787] EXT4-fs (md0p1): mounted filesystem with ordered data mode. Opts: errors=remount-ro
> [  195.439324] sshd (1135): /proc/1135/oom_adj is deprecated, please use /proc/1135/oom_score_adj instead.
> [  195.457698] apparmor_parser[1148]: segfault at 0 ip 000000000040a14e sp 00007ffff83d9380 error 4 in apparmor_parser[400000+c9000]
> [  195.457763] apparmor_parser[1149]: segfault at 0 ip 000000000040a14e sp 00007fff872af890 error 4 in apparmor_parser[400000+c9000]
> [  195.573004] FS-Cache: Loaded
> [  195.665644] FS-Cache: Netfs 'nfs' registered for caching
> [  195.750659] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> [  195.954782] svc: failed to register lockdv1 RPC service (errno 97).
> [  195.954915] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> [  195.955193] NFSD: starting 90-second grace period
> [ 2397.763208] INFO: task nfsd:1263 blocked for more than 120 seconds.
> [ 2397.763234] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.763264] nfsd          D 00000001000300f4     0  1263      2 0x00000000
> [ 2397.763268]  ffff8803608a7da0 0000000000000046 ffff8803608ab2b8 ffff8803608aa000
> [ 2397.763273]  ffff8803ffffffff 0000000000014f00 ffff8803611b0000 0000000000014f00
> [ 2397.763277]  ffff8803611b0388 ffff8803608a7fd8 ffff8803611b0390 ffff8803608a7fd8
> [ 2397.763282] Call Trace:
> [ 2397.763292]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2397.763302]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.763306]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2397.763321]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2397.763327]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.763338]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.763345]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.763349]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.763354]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.763357]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.763360]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.763363] INFO: task nfsd:1264 blocked for more than 120 seconds.
> [ 2397.763385] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.763413] nfsd          D 00000001000300ad     0  1264      2 0x00000000
> [ 2397.763417]  ffff88035e4d5da0 0000000000000046 ffff8803608ae2b8 ffff8803608af000
> [ 2397.763421]  ffff880300000000 0000000000014f00 ffff8803611b1760 0000000000014f00
> [ 2397.763426]  ffff8803611b1ae8 ffff88035e4d5fd8 ffff8803611b1af0 ffff88035e4d5fd8
> [ 2397.763430] Call Trace:
> [ 2397.763433]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2397.763440]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.763444]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2397.763456]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2397.763459]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.763470]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.763477]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.763480]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.763484]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.763487]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.763490]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.763493] INFO: task nfsd:1265 blocked for more than 120 seconds.
> [ 2397.763514] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.763543] nfsd          D 000000010003021f     0  1265      2 0x00000000
> [ 2397.763547]  ffff880358f5fda0 0000000000000046 ffff88035fa9b2b8 ffff880360f5f000
> [ 2397.763551]  ffff880300000000 0000000000014f00 ffff8803611b2ec0 0000000000014f00
> [ 2397.763555]  ffff8803611b3248 ffff880358f5ffd8 ffff8803611b3250 ffff880358f5ffd8
> [ 2397.763559] Call Trace:
> [ 2397.763563]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2397.763570]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.763573]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2397.763585]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2397.763588]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.763599]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.763606]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.763609]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.763613]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.763616]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.763619]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.763622] INFO: task nfsd:1266 blocked for more than 120 seconds.
> [ 2397.763643] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.763672] nfsd          D 000000010003002d     0  1266      2 0x00000000
> [ 2397.763676]  ffff8803290d93d0 0000000000000046 ffff8806613b6180 ffff880001e14f00
> [ 2397.763680]  ffff880600000000 0000000000014f00 ffff8803611b4620 0000000000014f00
> [ 2397.763684]  ffff8803611b49a8 ffff8803290d9fd8 ffff8803611b49b0 ffff8803290d9fd8
> [ 2397.763688] Call Trace:
> [ 2397.763693]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2397.763697]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2397.763700]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2397.763703]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2397.763706]  [<ffffffff815ad0a9>] ? schedule_timeout+0x199/0x2f0
> [ 2397.763709]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2397.763713]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2397.763718]  [<ffffffff81113f6b>] shrink_page_list+0x15b/0x500
> [ 2397.763722]  [<ffffffff810824f0>] ? autoremove_wake_function+0x0/0x40
> [ 2397.763725]  [<ffffffff81114524>] shrink_inactive_list+0x214/0x3c0
> [ 2397.763731]  [<ffffffff812d674e>] ? do_raw_spin_unlock+0x5e/0xb0
> [ 2397.763734]  [<ffffffff815af27e>] ? _raw_spin_unlock_irq+0xe/0x20
> [ 2397.763738]  [<ffffffff8111487b>] shrink_zone+0x1ab/0x230
> [ 2397.763745]  [<ffffffff81230287>] ? jbd2_journal_stop+0x1c7/0x2b0
> [ 2397.763748]  [<ffffffff81114b2c>] __zone_reclaim+0x10c/0x2c0
> [ 2397.763752]  [<ffffffff81114def>] zone_reclaim+0x10f/0x130
> [ 2397.763757]  [<ffffffff8110a531>] get_page_from_freelist+0x541/0x6c0
> [ 2397.763761]  [<ffffffff811034b4>] ? generic_file_buffered_write+0x64/0xa0
> [ 2397.763765]  [<ffffffff8110af32>] __alloc_pages_nodemask+0xf2/0x1d0
> [ 2397.763772]  [<ffffffff8113e90a>] alloc_pages_current+0x9a/0x100
> [ 2397.763775]  [<ffffffff81144f95>] new_slab+0x215/0x2b0
> [ 2397.763779]  [<ffffffff81147091>] __slab_alloc+0x231/0x320
> [ 2397.763783]  [<ffffffff814b01ff>] ? __alloc_skb+0x4f/0x170
> [ 2397.763787]  [<ffffffff811472d2>] kmem_cache_alloc_node+0x82/0x140
> [ 2397.763790]  [<ffffffff814b01ff>] __alloc_skb+0x4f/0x170
> [ 2397.763796]  [<ffffffff814fae81>] sk_stream_alloc_skb+0x41/0x110
> [ 2397.763800]  [<ffffffff814fb2c4>] do_tcp_sendpages+0x374/0x510
> [ 2397.763803]  [<ffffffff812d67f4>] ? do_raw_spin_lock+0x54/0x150
> [ 2397.763809]  [<ffffffff8118f694>] ? fsnotify+0x1b4/0x2d0
> [ 2397.763813]  [<ffffffff814fb4c9>] tcp_sendpage+0x69/0x80
> [ 2397.763818]  [<ffffffff815209e2>] inet_sendpage+0x52/0xe0
> [ 2397.763823]  [<ffffffff814a5ff8>] kernel_sendpage+0x58/0x90
> [ 2397.763835]  [<ffffffffa01b8dd4>] svc_send_common+0x64/0x160 [sunrpc]
> [ 2397.763846]  [<ffffffffa01b8f42>] svc_sendto+0x72/0x1f0 [sunrpc]
> [ 2397.763850]  [<ffffffff8116bf4a>] ? dput+0xba/0x170
> [ 2397.763859]  [<ffffffffa02fc711>] ? nfsd4_release_compoundargs+0x31/0x70 [nfsd]
> [ 2397.763868]  [<ffffffffa02f9d9e>] ? nfsd4_proc_compound+0x2ce/0x500 [nfsd]
> [ 2397.763873]  [<ffffffff8109389c>] ? debug_mutex_add_waiter+0x2c/0x70
> [ 2397.763876]  [<ffffffff815adc70>] ? __mutex_lock_slowpath+0x1e0/0x280
> [ 2397.763883]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.763894]  [<ffffffffa01b9164>] svc_tcp_sendto+0x54/0xb0 [sunrpc]
> [ 2397.763906]  [<ffffffffa01c495b>] svc_send+0x9b/0xe0 [sunrpc]
> [ 2397.763910]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.763921]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.763928]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.763931]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.763935]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.763938]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.763941]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.763944] INFO: task nfsd:1267 blocked for more than 120 seconds.
> [ 2397.763965] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.763993] nfsd          D 00000001000300ad     0  1267      2 0x00000000
> [ 2397.763997]  ffff880358c93da0 0000000000000046 ffff88035fcca2b8 ffff88035fccb000
> [ 2397.764001]  ffff880300000000 0000000000014f00 ffff8803611b5d80 0000000000014f00
> [ 2397.764006]  ffff8803611b6108 ffff880358c93fd8 ffff8803611b6110 ffff880358c93fd8
> [ 2397.764010] Call Trace:
> [ 2397.764013]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2397.764020]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.764023]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2397.764035]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2397.764039]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.764050]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.764057]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.764060]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.764063]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.764067]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.764070]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.764073] INFO: task nfsd:1268 blocked for more than 120 seconds.
> [ 2397.764094] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.764122] nfsd          D 000000010003003a     0  1268      2 0x00000000
> [ 2397.764126]  ffff880329f0bda0 0000000000000046 ffff88035fccc2b8 ffff88035fccd000
> [ 2397.764131]  ffff880300000000 0000000000014f00 ffff880329f10000 0000000000014f00
> [ 2397.764135]  ffff880329f10388 ffff880329f0bfd8 ffff880329f10390 ffff880329f0bfd8
> [ 2397.764139] Call Trace:
> [ 2397.764142]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2397.764149]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.764152]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2397.764164]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2397.764168]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.764179]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.764186]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.764189]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.764192]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.764196]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.764199]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.764201] INFO: task nfsd:1269 blocked for more than 120 seconds.
> [ 2397.764223] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.764281] nfsd          D 00000000ffffffff     0  1269      2 0x00000000
> [ 2397.764284]  ffff88032bf95da0 0000000000000046 ffff88035fcce2b8 ffff88035fccf000
> [ 2397.764289]  ffff88032bf95d30 0000000000014f00 ffff880329f11760 0000000000014f00
> [ 2397.764293]  ffff880329f11ae8 ffff88032bf95fd8 ffff880329f11af0 ffff88032bf95fd8
> [ 2397.764297] Call Trace:
> [ 2397.764301]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2397.764308]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.764311]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2397.764323]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2397.764326]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.764337]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.764344]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.764347]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.764351]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.764354]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.764357]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.764360] INFO: task nfsd:1270 blocked for more than 120 seconds.
> [ 2397.764411] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.764493] nfsd          D 00000001000301c4     0  1270      2 0x00000000
> [ 2397.764497]  ffff880358cdfda0 0000000000000046 ffff88032bfa02b8 ffff88032bfa1000
> [ 2397.764501]  ffff880300000000 0000000000014f00 ffff880329f12ec0 0000000000014f00
> [ 2397.764505]  ffff880329f13248 ffff880358cdffd8 ffff880329f13250 ffff880358cdffd8
> [ 2397.764509] Call Trace:
> [ 2397.764513]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2397.764520]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2397.764523]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2397.764535]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2397.764539]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2397.764550]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2397.764557]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2397.764560]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2397.764563]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2397.764567]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2397.764570]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2397.764575] INFO: task dd:2828 blocked for more than 120 seconds.
> [ 2397.764625] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.764708] dd            D 000000010002fba9     0  2828   2776 0x00000000
> [ 2397.764712]  ffff8806434ffc98 0000000000000082 ffff8806434ffc08 ffffffff812d0daa
> [ 2397.764716]  0000000000000007 0000000000014f00 ffff88065a4b9760 0000000000014f00
> [ 2397.764720]  ffff88065a4b9ae8 ffff8806434fffd8 ffff88065a4b9af0 ffff8806434fffd8
> [ 2397.764724] Call Trace:
> [ 2397.764730]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2397.764733]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2397.764736]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2397.764739]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2397.764743]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2397.764746]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2397.764749]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2397.764752]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2397.764756]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2397.764760]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2397.764765]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2397.764769]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2397.764780]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2397.764785]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2397.764788]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2397.764793]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2397.764796] INFO: task dd:2835 blocked for more than 120 seconds.
> [ 2397.764847] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 2397.764929] dd            D 000000010002fbad     0  2835   2785 0x00000000
> [ 2397.764933]  ffff88031499bc98 0000000000000086 ffff88031499bc08 ffffffff812d0daa
> [ 2397.764937]  0000000000000002 0000000000014f00 ffff88035e58dd80 0000000000014f00
> [ 2397.764941]  ffff88035e58e108 ffff88031499bfd8 ffff88035e58e110 ffff88031499bfd8
> [ 2397.764945] Call Trace:
> [ 2397.764949]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2397.764952]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2397.764955]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2397.764958]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2397.764961]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2397.764965]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2397.764968]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2397.764971]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2397.764974]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2397.764978]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2397.764982]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2397.764985]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2397.764993]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2397.764996]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2397.765000]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2397.765003]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2434.805486] nfs: server 127.0.0.1 not responding, still trying
> [ 2479.766864] nfs: server 127.0.0.1 not responding, still trying
> [ 2481.984273] SysRq : HELP : loglevel(0-9) reBoot Crash terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W) dump-ftrace-buffer(Z) 
> [ 2509.511707] SysRq : Show Blocked State
> [ 2509.511755]   task                        PC stack   pid father
> [ 2509.511770] nfsd          D 00000001000300f4     0  1263      2 0x00000000
> [ 2509.511774]  ffff8803608a7da0 0000000000000046 ffff8803608ab2b8 ffff8803608aa000
> [ 2509.511779]  ffff8803ffffffff 0000000000014f00 ffff8803611b0000 0000000000014f00
> [ 2509.511783]  ffff8803611b0388 ffff8803608a7fd8 ffff8803611b0390 ffff8803608a7fd8
> [ 2509.511787] Call Trace:
> [ 2509.511794]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2509.511803]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.511806]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2509.511820]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2509.511824]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.511836]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.511843]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.511846]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.511850]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.511854]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.511857]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.511859] nfsd          D 00000001000300ad     0  1264      2 0x00000000
> [ 2509.511863]  ffff88035e4d5da0 0000000000000046 ffff8803608ae2b8 ffff8803608af000
> [ 2509.511867]  ffff880300000000 0000000000014f00 ffff8803611b1760 0000000000014f00
> [ 2509.511871]  ffff8803611b1ae8 ffff88035e4d5fd8 ffff8803611b1af0 ffff88035e4d5fd8
> [ 2509.511875] Call Trace:
> [ 2509.511879]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2509.511886]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.511889]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2509.511901]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2509.511904]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.511916]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.511922]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.511926]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.511929]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.511932]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.511935]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.511937] nfsd          D 000000010003021f     0  1265      2 0x00000000
> [ 2509.511941]  ffff880358f5fda0 0000000000000046 ffff88035fa9b2b8 ffff880360f5f000
> [ 2509.511946]  ffff880300000000 0000000000014f00 ffff8803611b2ec0 0000000000014f00
> [ 2509.511950]  ffff8803611b3248 ffff880358f5ffd8 ffff8803611b3250 ffff880358f5ffd8
> [ 2509.511954] Call Trace:
> [ 2509.511957]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2509.511964]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.511968]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2509.511979]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2509.511983]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.511994]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.512001]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.512004]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.512007]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.512011]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.512014]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.512016] nfsd          D 000000010003002d     0  1266      2 0x00000000
> [ 2509.512020]  ffff8803290d93d0 0000000000000046 ffff8806613b6180 ffff880001e14f00
> [ 2509.512024]  ffff880600000000 0000000000014f00 ffff8803611b4620 0000000000014f00
> [ 2509.512028]  ffff8803611b49a8 ffff8803290d9fd8 ffff8803611b49b0 ffff8803290d9fd8
> [ 2509.512032] Call Trace:
> [ 2509.512037]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.512040]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.512043]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.512046]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.512049]  [<ffffffff815ad0a9>] ? schedule_timeout+0x199/0x2f0
> [ 2509.512053]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.512056]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.512061]  [<ffffffff81113f6b>] shrink_page_list+0x15b/0x500
> [ 2509.512064]  [<ffffffff810824f0>] ? autoremove_wake_function+0x0/0x40
> [ 2509.512068]  [<ffffffff81114524>] shrink_inactive_list+0x214/0x3c0
> [ 2509.512072]  [<ffffffff812d674e>] ? do_raw_spin_unlock+0x5e/0xb0
> [ 2509.512076]  [<ffffffff815af27e>] ? _raw_spin_unlock_irq+0xe/0x20
> [ 2509.512079]  [<ffffffff8111487b>] shrink_zone+0x1ab/0x230
> [ 2509.512083]  [<ffffffff81230287>] ? jbd2_journal_stop+0x1c7/0x2b0
> [ 2509.512087]  [<ffffffff81114b2c>] __zone_reclaim+0x10c/0x2c0
> [ 2509.512090]  [<ffffffff81114def>] zone_reclaim+0x10f/0x130
> [ 2509.512094]  [<ffffffff8110a531>] get_page_from_freelist+0x541/0x6c0
> [ 2509.512098]  [<ffffffff811034b4>] ? generic_file_buffered_write+0x64/0xa0
> [ 2509.512102]  [<ffffffff8110af32>] __alloc_pages_nodemask+0xf2/0x1d0
> [ 2509.512107]  [<ffffffff8113e90a>] alloc_pages_current+0x9a/0x100
> [ 2509.512110]  [<ffffffff81144f95>] new_slab+0x215/0x2b0
> [ 2509.512113]  [<ffffffff81147091>] __slab_alloc+0x231/0x320
> [ 2509.512117]  [<ffffffff814b01ff>] ? __alloc_skb+0x4f/0x170
> [ 2509.512120]  [<ffffffff811472d2>] kmem_cache_alloc_node+0x82/0x140
> [ 2509.512123]  [<ffffffff814b01ff>] __alloc_skb+0x4f/0x170
> [ 2509.512128]  [<ffffffff814fae81>] sk_stream_alloc_skb+0x41/0x110
> [ 2509.512131]  [<ffffffff814fb2c4>] do_tcp_sendpages+0x374/0x510
> [ 2509.512135]  [<ffffffff812d67f4>] ? do_raw_spin_lock+0x54/0x150
> [ 2509.512140]  [<ffffffff8118f694>] ? fsnotify+0x1b4/0x2d0
> [ 2509.512144]  [<ffffffff814fb4c9>] tcp_sendpage+0x69/0x80
> [ 2509.512148]  [<ffffffff815209e2>] inet_sendpage+0x52/0xe0
> [ 2509.512151]  [<ffffffff814a5ff8>] kernel_sendpage+0x58/0x90
> [ 2509.512163]  [<ffffffffa01b8dd4>] svc_send_common+0x64/0x160 [sunrpc]
> [ 2509.512175]  [<ffffffffa01b8f42>] svc_sendto+0x72/0x1f0 [sunrpc]
> [ 2509.512178]  [<ffffffff8116bf4a>] ? dput+0xba/0x170
> [ 2509.512187]  [<ffffffffa02fc711>] ? nfsd4_release_compoundargs+0x31/0x70 [nfsd]
> [ 2509.512196]  [<ffffffffa02f9d9e>] ? nfsd4_proc_compound+0x2ce/0x500 [nfsd]
> [ 2509.512200]  [<ffffffff8109389c>] ? debug_mutex_add_waiter+0x2c/0x70
> [ 2509.512203]  [<ffffffff815adc70>] ? __mutex_lock_slowpath+0x1e0/0x280
> [ 2509.512210]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.512222]  [<ffffffffa01b9164>] svc_tcp_sendto+0x54/0xb0 [sunrpc]
> [ 2509.512234]  [<ffffffffa01c495b>] svc_send+0x9b/0xe0 [sunrpc]
> [ 2509.512237]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.512249]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.512255]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.512259]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.512262]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.512265]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.512268]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.512270] nfsd          D 00000001000300ad     0  1267      2 0x00000000
> [ 2509.512274]  ffff880358c93da0 0000000000000046 ffff88035fcca2b8 ffff88035fccb000
> [ 2509.512278]  ffff880300000000 0000000000014f00 ffff8803611b5d80 0000000000014f00
> [ 2509.512282]  ffff8803611b6108 ffff880358c93fd8 ffff8803611b6110 ffff880358c93fd8
> [ 2509.512286] Call Trace:
> [ 2509.512290]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2509.512297]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.512300]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2509.512312]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2509.512316]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.512327]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.512334]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.512337]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.512340]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.512344]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.512347]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.512349] nfsd          D 000000010003003a     0  1268      2 0x00000000
> [ 2509.512353]  ffff880329f0bda0 0000000000000046 ffff88035fccc2b8 ffff88035fccd000
> [ 2509.512357]  ffff880300000000 0000000000014f00 ffff880329f10000 0000000000014f00
> [ 2509.512361]  ffff880329f10388 ffff880329f0bfd8 ffff880329f10390 ffff880329f0bfd8
> [ 2509.512365] Call Trace:
> [ 2509.512369]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2509.512376]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.512379]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2509.512391]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2509.512394]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.512406]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.512413]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.512416]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.512419]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.512422]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.512425]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.512428] nfsd          D 00000000ffffffff     0  1269      2 0x00000000
> [ 2509.512432]  ffff88032bf95da0 0000000000000046 ffff88035fcce2b8 ffff88035fccf000
> [ 2509.512436]  ffff88032bf95d30 0000000000014f00 ffff880329f11760 0000000000014f00
> [ 2509.512440]  ffff880329f11ae8 ffff88032bf95fd8 ffff880329f11af0 ffff88032bf95fd8
> [ 2509.512444] Call Trace:
> [ 2509.512448]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2509.512454]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.512458]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2509.512469]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2509.512473]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.512484]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.512491]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.512494]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.512498]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.512501]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.512504]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.512506] nfsd          D 00000001000301c4     0  1270      2 0x00000000
> [ 2509.512510]  ffff880358cdfda0 0000000000000046 ffff88032bfa02b8 ffff88032bfa1000
> [ 2509.512514]  ffff880300000000 0000000000014f00 ffff880329f12ec0 0000000000014f00
> [ 2509.512518]  ffff880329f13248 ffff880358cdffd8 ffff880329f13250 ffff880358cdffd8
> [ 2509.512522] Call Trace:
> [ 2509.512526]  [<ffffffff815adb9f>] __mutex_lock_slowpath+0x10f/0x280
> [ 2509.512533]  [<ffffffffa02e7af0>] ? nfsd+0x0/0x170 [nfsd]
> [ 2509.512536]  [<ffffffff815add26>] mutex_lock+0x16/0x30
> [ 2509.512548]  [<ffffffffa01c4918>] svc_send+0x58/0xe0 [sunrpc]
> [ 2509.512551]  [<ffffffff8105a230>] ? default_wake_function+0x0/0x20
> [ 2509.512563]  [<ffffffffa01b6e0c>] svc_process+0x11c/0x150 [sunrpc]
> [ 2509.512569]  [<ffffffffa02e7bb5>] nfsd+0xc5/0x170 [nfsd]
> [ 2509.512573]  [<ffffffff81081fb6>] kthread+0x96/0xa0
> [ 2509.512576]  [<ffffffff8100bee4>] kernel_thread_helper+0x4/0x10
> [ 2509.512579]  [<ffffffff81081f20>] ? kthread+0x0/0xa0
> [ 2509.512582]  [<ffffffff8100bee0>] ? kernel_thread_helper+0x0/0x10
> [ 2509.512586] test_master.s D 000000010003079e     0  2770   1532 0x00000000
> [ 2509.512590]  ffff88035ffc78e8 0000000000000082 ffff88035ffc7938 ffff88035ffc7858
> [ 2509.512594]  ffff880300000000 0000000000014f00 ffff880360b78000 0000000000014f00
> [ 2509.512598]  ffff880360b78388 ffff88035ffc7fd8 ffff880360b78390 ffff88035ffc7fd8
> [ 2509.512602] Call Trace:
> [ 2509.512613]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.512624]  [<ffffffffa01b2fc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
> [ 2509.512627]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.512631]  [<ffffffff815af267>] ? _raw_spin_unlock_bh+0x17/0x20
> [ 2509.512640]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.512644]  [<ffffffff815ad4b8>] out_of_line_wait_on_bit+0x78/0x90
> [ 2509.512648]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.512651]  [<ffffffff812d674e>] ? do_raw_spin_unlock+0x5e/0xb0
> [ 2509.512662]  [<ffffffffa01b377d>] __rpc_execute+0xed/0x230 [sunrpc]
> [ 2509.512672]  [<ffffffffa01b3903>] rpc_execute+0x43/0x50 [sunrpc]
> [ 2509.512680]  [<ffffffffa01abf7b>] rpc_run_task+0xeb/0x140 [sunrpc]
> [ 2509.512688]  [<ffffffffa01ac0d2>] rpc_call_sync+0x42/0x70 [sunrpc]
> [ 2509.512699]  [<ffffffffa028e9a6>] ? nfs_alloc_fattr+0x26/0xc0 [nfs]
> [ 2509.512712]  [<ffffffffa02a6fd2>] _nfs4_call_sync+0x22/0x30 [nfs]
> [ 2509.512724]  [<ffffffffa02a58da>] _nfs4_proc_access+0x11a/0x1d0 [nfs]
> [ 2509.512728]  [<ffffffff812d67f4>] ? do_raw_spin_lock+0x54/0x150
> [ 2509.512740]  [<ffffffffa02a59d3>] nfs4_proc_access+0x43/0x70 [nfs]
> [ 2509.512749]  [<ffffffffa0288807>] nfs_do_access+0x97/0xf0 [nfs]
> [ 2509.512760]  [<ffffffffa01b5b15>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
> [ 2509.512771]  [<ffffffffa01b4b10>] ? rpcauth_lookupcred+0x70/0xc0 [sunrpc]
> [ 2509.512780]  [<ffffffffa02888f5>] nfs_permission+0x95/0x1d0 [nfs]
> [ 2509.512786]  [<ffffffff81162680>] exec_permission+0x30/0x90
> [ 2509.512790]  [<ffffffff81164ff3>] link_path_walk+0x93/0x9e0
> [ 2509.512793]  [<ffffffff812d674e>] ? do_raw_spin_unlock+0x5e/0xb0
> [ 2509.512797]  [<ffffffff81165a57>] path_walk+0x67/0xe0
> [ 2509.512800]  [<ffffffff81165c2b>] do_path_lookup+0x5b/0xa0
> [ 2509.512804]  [<ffffffff811668f7>] user_path_at+0x57/0xa0
> [ 2509.512808]  [<ffffffff8112447d>] ? do_wp_page+0x3cd/0x820
> [ 2509.512811]  [<ffffffff8115cd7c>] vfs_fstatat+0x3c/0x80
> [ 2509.512814]  [<ffffffff812d67f4>] ? do_raw_spin_lock+0x54/0x150
> [ 2509.512817]  [<ffffffff8115ce9b>] vfs_stat+0x1b/0x20
> [ 2509.512820]  [<ffffffff8115cec4>] sys_newstat+0x24/0x50
> [ 2509.512823]  [<ffffffff812d674e>] ? do_raw_spin_unlock+0x5e/0xb0
> [ 2509.512827]  [<ffffffff815af27e>] ? _raw_spin_unlock_irq+0xe/0x20
> [ 2509.512831]  [<ffffffff81076fa7>] ? sys_rt_sigprocmask+0xa7/0x100
> [ 2509.512835]  [<ffffffff815af995>] ? page_fault+0x25/0x30
> [ 2509.512839]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.512843] dd            D 0000000000000082     0  2826   2779 0x00000000
> [ 2509.512847]  ffff8803512e5d38 0000000000000082 ffff88031e8846a8 ffff8801a2a18008
> [ 2509.512851]  ffff8803512e5ce8 0000000000014f00 ffff8803290c2ec0 0000000000014f00
> [ 2509.512856]  ffff8803290c3248 ffff8803512e5fd8 ffff8803290c3250 ffff8803512e5fd8
> [ 2509.512860] Call Trace:
> [ 2509.512869]  [<ffffffffa028e8a0>] ? nfs_wait_bit_killable+0x0/0x40 [nfs]
> [ 2509.512878]  [<ffffffffa028e8c4>] nfs_wait_bit_killable+0x24/0x40 [nfs]
> [ 2509.512881]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.512890]  [<ffffffffa028e8a0>] ? nfs_wait_bit_killable+0x0/0x40 [nfs]
> [ 2509.512894]  [<ffffffff815ad4b8>] out_of_line_wait_on_bit+0x78/0x90
> [ 2509.512897]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.512908]  [<ffffffffa029c38d>] nfs_commit_inode+0x19d/0x1c0 [nfs]
> [ 2509.512917]  [<ffffffffa028ab22>] nfs_file_fsync+0x62/0xc0 [nfs]
> [ 2509.512922]  [<ffffffff8118122c>] vfs_fsync_range+0x7c/0xa0
> [ 2509.512925]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.512933]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.512937]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.512941]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.512944]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.512947] dd            D 000000010002fba9     0  2828   2776 0x00000000
> [ 2509.512950]  ffff8806434ffc98 0000000000000082 ffff8806434ffc08 ffffffff812d0daa
> [ 2509.512955]  0000000000000007 0000000000014f00 ffff88065a4b9760 0000000000014f00
> [ 2509.512959]  ffff88065a4b9ae8 ffff8806434fffd8 ffff88065a4b9af0 ffff8806434fffd8
> [ 2509.512963] Call Trace:
> [ 2509.512967]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.512971]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.512974]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.512977]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.512980]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.512983]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.512986]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.512990]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.512993]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.512997]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513001]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513004]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513012]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513015]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513018]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513022]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513024] dd            D 000000010002fbad     0  2835   2785 0x00000000
> [ 2509.513028]  ffff88031499bc98 0000000000000086 ffff88031499bc08 ffffffff812d0daa
> [ 2509.513032]  0000000000000002 0000000000014f00 ffff88035e58dd80 0000000000014f00
> [ 2509.513036]  ffff88035e58e108 ffff88031499bfd8 ffff88035e58e110 ffff88031499bfd8
> [ 2509.513040] Call Trace:
> [ 2509.513043]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513047]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513050]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513053]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513056]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513059]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513063]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513066]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513069]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513073]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513077]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513080]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513088]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513091]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513094]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513098]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513100] dd            D 000000010002fb37     0  2838   2784 0x00000000
> [ 2509.513104]  ffff880643313c98 0000000000000086 ffff880643313c08 ffffffff812d0daa
> [ 2509.513108]  0000000000000011 0000000000014f00 ffff88065a555d80 0000000000014f00
> [ 2509.513112]  ffff88065a556108 ffff880643313fd8 ffff88065a556110 ffff880643313fd8
> [ 2509.513116] Call Trace:
> [ 2509.513120]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513123]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513126]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513129]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513132]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513136]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513139]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513142]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513145]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513149]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513153]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513156]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513164]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513167]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513171]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513174]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513177] dd            D 000000010002fb3a     0  2839   2790 0x00000000
> [ 2509.513180]  ffff880661129c98 0000000000000082 ffff880661129c08 ffffffff812d0daa
> [ 2509.513184]  0000000000000002 0000000000014f00 ffff88065a4f2ec0 0000000000014f00
> [ 2509.513189]  ffff88065a4f3248 ffff880661129fd8 ffff88065a4f3250 ffff880661129fd8
> [ 2509.513193] Call Trace:
> [ 2509.513196]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513199]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513202]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513205]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513208]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513212]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513215]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513218]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513221]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513226]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513229]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513233]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513240]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513244]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513247]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513251]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513253] dd            D 0000000100030030     0  2840   2788 0x00000000
> [ 2509.513257]  ffff8806602dbc98 0000000000000086 ffff8806602dbc08 ffffffff812d0daa
> [ 2509.513261]  0000000000000002 0000000000014f00 ffff88066177dd80 0000000000014f00
> [ 2509.513265]  ffff88066177e108 ffff8806602dbfd8 ffff88066177e110 ffff8806602dbfd8
> [ 2509.513269] Call Trace:
> [ 2509.513272]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513276]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513279]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513282]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513285]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513288]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513291]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513294]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513298]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513302]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513306]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513309]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513317]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513320]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513323]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513327]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513329] dd            D 0000000000000002     0  2842   2791 0x00000000
> [ 2509.513333]  ffff8802f2a3bc98 0000000000000086 ffff8802f2a3bbe8 ffffffff8107af85
> [ 2509.513337]  ffff8802f2a3bbf8 0000000000014f00 ffff880360e60000 0000000000014f00
> [ 2509.513342]  ffff880360e60388 ffff8802f2a3bfd8 ffff880360e60390 ffff8802f2a3bfd8
> [ 2509.513345] Call Trace:
> [ 2509.513349]  [<ffffffff8107af85>] ? queue_work_on+0x25/0x40
> [ 2509.513353]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513356]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513359]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513362]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513365]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513368]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513372]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513375]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513379]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513383]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513386]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513394]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513397]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513400]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513404]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513406] dd            D 000000010002fb08     0  2843   2787 0x00000000
> [ 2509.513410]  ffff88031f301c98 0000000000000086 ffff88031f301c08 ffffffff812d0daa
> [ 2509.513414]  0000000000000004 0000000000014f00 ffff88035ee25d80 0000000000014f00
> [ 2509.513418]  ffff88035ee26108 ffff88031f301fd8 ffff88035ee26110 ffff88031f301fd8
> [ 2509.513422] Call Trace:
> [ 2509.513425]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513429]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513432]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513435]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513438]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513441]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513445]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513448]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513451]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513456]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513459]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513462]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513470]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513474]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513477]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513480]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513483] dd            D 000000010002fb74     0  2844   2793 0x00000000
> [ 2509.513487]  ffff88035f19bc98 0000000000000086 ffff88035f19bc08 ffffffff812d0daa
> [ 2509.513491]  0000000000000005 0000000000014f00 ffff8803290c5d80 0000000000014f00
> [ 2509.513495]  ffff8803290c6108 ffff88035f19bfd8 ffff8803290c6110 ffff88035f19bfd8
> [ 2509.513499] Call Trace:
> [ 2509.513502]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513506]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513509]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513512]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513515]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513518]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513521]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513524]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513528]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513532]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513536]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513539]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513547]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513550]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513553]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513557]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513559] dd            D 000000010002fbc7     0  2845   2789 0x00000000
> [ 2509.513563]  ffff880361215c98 0000000000000086 ffff880361215c08 ffffffff812d0daa
> [ 2509.513567]  000000000000000e 0000000000014f00 ffff880360b7dd80 0000000000014f00
> [ 2509.513571]  ffff880360b7e108 ffff880361215fd8 ffff880360b7e110 ffff880361215fd8
> [ 2509.513575] Call Trace:
> [ 2509.513579]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513582]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513585]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513588]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513591]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513595]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513598]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513601]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513604]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513609]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513612]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513616]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513623]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513627]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513630]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513633]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513636] dd            D 000000010002f8bc     0  2848   2798 0x00000000
> [ 2509.513639]  ffff880642445c98 0000000000000082 ffff880642445c08 ffffffff812d0daa
> [ 2509.513644]  00000000ffffffff 0000000000014f00 ffff88065ab8c620 0000000000014f00
> [ 2509.513648]  ffff88065ab8c9a8 ffff880642445fd8 ffff88065ab8c9b0 ffff880642445fd8
> [ 2509.513652] Call Trace:
> [ 2509.513655]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513658]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513661]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513665]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513668]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513671]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513674]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513677]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513681]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513685]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513689]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513692]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513700]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513703]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513706]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513710]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513712] dd            D 000000010002fb24     0  2850   2797 0x00000000
> [ 2509.513716]  ffff88035e7e3c98 0000000000000082 ffff88035e7e3c08 ffffffff812d0daa
> [ 2509.513720]  0000000000000004 0000000000014f00 ffff88035ee24620 0000000000014f00
> [ 2509.513724]  ffff88035ee249a8 ffff88035e7e3fd8 ffff88035ee249b0 ffff88035e7e3fd8
> [ 2509.513728] Call Trace:
> [ 2509.513731]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513735]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513738]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513741]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513744]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513747]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513751]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513754]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513757]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513761]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513765]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513768]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513776]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513779]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513782]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513786]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513789] dd            D 000000010002fb38     0  2853   2795 0x00000000
> [ 2509.513792]  ffff88036143bc98 0000000000000086 ffff88036143bc08 ffffffff812d0daa
> [ 2509.513797]  0000000000000012 0000000000014f00 ffff88035eefdd80 0000000000014f00
> [ 2509.513801]  ffff88035eefe108 ffff88036143bfd8 ffff88035eefe110 ffff88036143bfd8
> [ 2509.513805] Call Trace:
> [ 2509.513808]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513811]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513815]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513818]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513821]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513824]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513827]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513830]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513834]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513838]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513842]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513845]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513853]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513856]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513859]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513863]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513865] dd            D 0000000100030031     0  2854   2804 0x00000000
> [ 2509.513869]  ffff8806431bfc98 0000000000000082 ffff8806431bfc08 ffffffff812d0daa
> [ 2509.513873]  0000000000000007 0000000000014f00 ffff88065ab88000 0000000000014f00
> [ 2509.513877]  ffff88065ab88388 ffff8806431bffd8 ffff88065ab88390 ffff8806431bffd8
> [ 2509.513881] Call Trace:
> [ 2509.513884]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513888]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513891]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513894]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513897]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513900]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513904]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513907]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513910]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513914]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513918]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513921]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.513929]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.513932]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.513935]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.513939]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.513941] dd            D 000000010002fb70     0  2855   2808 0x00000000
> [ 2509.513945]  ffff88066166fc98 0000000000000082 ffff88066166fc08 ffffffff812d0daa
> [ 2509.513949]  0000000000000003 0000000000014f00 ffff88065a4bc620 0000000000014f00
> [ 2509.513953]  ffff88065a4bc9a8 ffff88066166ffd8 ffff88065a4bc9b0 ffff88066166ffd8
> [ 2509.513957] Call Trace:
> [ 2509.513960]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.513964]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.513967]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.513970]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.513973]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.513976]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.513980]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.513983]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.513986]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.513990]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.513994]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.513997]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514005]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514008]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514011]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514015]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514017] dd            D 000000010002fbab     0  2857   2806 0x00000000
> [ 2509.514021]  ffff880642ad5c98 0000000000000086 ffff880642ad5c08 ffffffff812d0daa
> [ 2509.514025]  0000000000000007 0000000000014f00 ffff88064461c620 0000000000014f00
> [ 2509.514029]  ffff88064461c9a8 ffff880642ad5fd8 ffff88064461c9b0 ffff880642ad5fd8
> [ 2509.514033] Call Trace:
> [ 2509.514037]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514040]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514043]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514046]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514050]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514053]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514056]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514059]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514063]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514067]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514070]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514074]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514081]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514085]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514088]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514092]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514094] dd            D 000000010003002f     0  2858   2807 0x00000000
> [ 2509.514098]  ffff88035fcd1c98 0000000000000086 ffff88035fcd1c08 ffffffff812d0daa
> [ 2509.514102]  0000000000000004 0000000000014f00 ffff88035f349760 0000000000014f00
> [ 2509.514106]  ffff88035f349ae8 ffff88035fcd1fd8 ffff88035f349af0 ffff88035fcd1fd8
> [ 2509.514110] Call Trace:
> [ 2509.514113]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514117]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514120]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514123]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514126]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514129]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514133]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514136]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514139]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514143]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514147]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514150]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514158]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514161]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514164]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514168]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514170] dd            D 000000010002fbdf     0  2859   2809 0x00000000
> [ 2509.514174]  ffff88031f4a3c98 0000000000000086 ffff88031f4a3c08 ffffffff812d0daa
> [ 2509.514178]  000000000000000b 0000000000014f00 ffff88035ee21760 0000000000014f00
> [ 2509.514182]  ffff88035ee21ae8 ffff88031f4a3fd8 ffff88035ee21af0 ffff88031f4a3fd8
> [ 2509.514186] Call Trace:
> [ 2509.514190]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514193]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514196]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514199]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514202]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514206]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514209]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514212]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514216]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514220]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514223]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514227]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514234]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514238]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514241]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514244]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514247] dd            D 0000000100030030     0  2860   2805 0x00000000
> [ 2509.514251]  ffff88035ef19c98 0000000000000082 ffff88035ef19c08 ffffffff812d0daa
> [ 2509.514255]  0000000000000000 0000000000014f00 ffff8803290c4620 0000000000014f00
> [ 2509.514259]  ffff8803290c49a8 ffff88035ef19fd8 ffff8803290c49b0 ffff88035ef19fd8
> [ 2509.514263] Call Trace:
> [ 2509.514266]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514270]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514273]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514276]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514279]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514282]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514285]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514288]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514292]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514296]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514300]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514303]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514311]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514314]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514317]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514321]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514323] dd            D 000000010002fb1f     0  2861   2803 0x00000000
> [ 2509.514327]  ffff88035dfb5c98 0000000000000082 ffff88035dfb5c08 ffffffff812d0daa
> [ 2509.514331]  0000000000000005 0000000000014f00 ffff880358df0000 0000000000014f00
> [ 2509.514335]  ffff880358df0388 ffff88035dfb5fd8 ffff880358df0390 ffff88035dfb5fd8
> [ 2509.514339] Call Trace:
> [ 2509.514343]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514346]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514349]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514352]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514355]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514358]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514362]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514365]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514368]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514372]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514376]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514379]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514387]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514390]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514393]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514397]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514399] dd            D 0000000000000002     0  2862   2819 0x00000000
> [ 2509.514403]  ffff880644133c98 0000000000000086 ffff880644133be8 ffffffff8107af85
> [ 2509.514407]  ffff880644133bf8 0000000000014f00 ffff8806612c8000 0000000000014f00
> [ 2509.514412]  ffff8806612c8388 ffff880644133fd8 ffff8806612c8390 ffff880644133fd8
> [ 2509.514416] Call Trace:
> [ 2509.514419]  [<ffffffff8107af85>] ? queue_work_on+0x25/0x40
> [ 2509.514423]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514426]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514429]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514432]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514435]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514438]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514442]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514445]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514449]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514453]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514456]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514464]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514467]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514470]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514474]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514476] dd            D 000000010002fbdb     0  2863   2810 0x00000000
> [ 2509.514480]  ffff880651f73c98 0000000000000086 ffff880651f73c08 ffffffff812d0daa
> [ 2509.514484]  0000000000000003 0000000000014f00 ffff88065a552ec0 0000000000014f00
> [ 2509.514488]  ffff88065a553248 ffff880651f73fd8 ffff88065a553250 ffff880651f73fd8
> [ 2509.514492] Call Trace:
> [ 2509.514496]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514499]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514502]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514505]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514508]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514511]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514515]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514518]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514521]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514525]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514529]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514532]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514540]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514543]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514547]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514550]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514553] dd            D 0000000000000002     0  2864   2812 0x00000000
> [ 2509.514556]  ffff880644a9fc98 0000000000000086 ffff880644a9fbe8 ffffffff8107af85
> [ 2509.514561]  ffff880644a9fbf8 0000000000014f00 ffff88065ab8dd80 0000000000014f00
> [ 2509.514565]  ffff88065ab8e108 ffff880644a9ffd8 ffff88065ab8e110 ffff880644a9ffd8
> [ 2509.514569] Call Trace:
> [ 2509.514572]  [<ffffffff8107af85>] ? queue_work_on+0x25/0x40
> [ 2509.514576]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514579]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514582]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514585]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514588]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514591]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514595]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514598]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514602]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514606]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514609]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514617]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514620]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514623]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514627]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514629] dd            D 0000000000000082     0  2866   2820 0x00000000
> [ 2509.514633]  ffff880644641c08 0000000000000086 0000000000000082 ffff880001e74f00
> [ 2509.514637]  ffff880644641bb8 0000000000014f00 ffff88064461aec0 0000000000014f00
> [ 2509.514641]  ffff88064461b248 ffff880644641fd8 ffff88064461b250 ffff880644641fd8
> [ 2509.514645] Call Trace:
> [ 2509.514656]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.514666]  [<ffffffffa01b2fc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
> [ 2509.514670]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514679]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.514683]  [<ffffffff815ad4b8>] out_of_line_wait_on_bit+0x78/0x90
> [ 2509.514686]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514696]  [<ffffffffa01b2f5e>] __rpc_wait_for_completion_task+0x3e/0x40 [sunrpc]
> [ 2509.514709]  [<ffffffffa02a9c48>] nfs4_do_close+0x1d8/0x2f0 [nfs]
> [ 2509.514718]  [<ffffffffa028e8a0>] ? nfs_wait_bit_killable+0x0/0x40 [nfs]
> [ 2509.514732]  [<ffffffffa02b37dd>] __nfs4_close+0xbd/0x1a0 [nfs]
> [ 2509.514745]  [<ffffffffa02b38d9>] nfs4_close_sync+0x19/0x20 [nfs]
> [ 2509.514757]  [<ffffffffa02a306c>] nfs4_close_context+0x3c/0x50 [nfs]
> [ 2509.514767]  [<ffffffffa028dcb8>] __put_nfs_open_context+0xb8/0xe0 [nfs]
> [ 2509.514776]  [<ffffffffa028dd82>] nfs_release+0xa2/0xc0 [nfs]
> [ 2509.514784]  [<ffffffffa028b5ce>] nfs_file_release+0x4e/0x80 [nfs]
> [ 2509.514788]  [<ffffffff81159e16>] __fput+0xa6/0x250
> [ 2509.514791]  [<ffffffff81159fe5>] fput+0x25/0x30
> [ 2509.514794]  [<ffffffff8115632d>] filp_close+0x5d/0x90
> [ 2509.514798]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514801]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514804] dd            D 000000010002fb9f     0  2867   2814 0x00000000
> [ 2509.514808]  ffff88031f505c98 0000000000000082 ffff88031f505c08 ffffffff812d0daa
> [ 2509.514812]  0000000000000000 0000000000014f00 ffff88035f34aec0 0000000000014f00
> [ 2509.514816]  ffff88035f34b248 ffff88031f505fd8 ffff88035f34b250 ffff88031f505fd8
> [ 2509.514820] Call Trace:
> [ 2509.514823]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514827]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514830]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514833]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514836]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514839]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514843]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514846]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514849]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514853]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514857]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514860]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514868]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514871]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514875]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514878]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514880] dd            D 0000000100030030     0  2869   2818 0x00000000
> [ 2509.514884]  ffff88035de77c98 0000000000000082 ffff88035de77c08 ffffffff812d0daa
> [ 2509.514888]  0000000000000002 0000000000014f00 ffff88035e514620 0000000000014f00
> [ 2509.514893]  ffff88035e5149a8 ffff88035de77fd8 ffff88035e5149b0 ffff88035de77fd8
> [ 2509.514897] Call Trace:
> [ 2509.514900]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514903]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514906]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514909]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514913]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514916]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514919]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514922]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.514926]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.514930]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.514933]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.514937]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.514944]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.514948]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.514951]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.514955]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.514957] dd            D 000000010002fb70     0  2870   2821 0x00000000
> [ 2509.514961]  ffff8806615b5c98 0000000000000082 ffff8806615b5c08 ffffffff812d0daa
> [ 2509.514965]  0000000000000007 0000000000014f00 ffff88065a55c620 0000000000014f00
> [ 2509.514969]  ffff88065a55c9a8 ffff8806615b5fd8 ffff88065a55c9b0 ffff8806615b5fd8
> [ 2509.514973] Call Trace:
> [ 2509.514976]  [<ffffffff812d0daa>] ? delay_tsc+0x4a/0x80
> [ 2509.514980]  [<ffffffff81103d10>] ? sync_page+0x0/0x60
> [ 2509.514983]  [<ffffffff815acdb3>] io_schedule+0x73/0xc0
> [ 2509.514986]  [<ffffffff81103d55>] sync_page+0x45/0x60
> [ 2509.514989]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.514992]  [<ffffffff81103f13>] wait_on_page_bit+0x73/0x80
> [ 2509.514996]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.514999]  [<ffffffff8110ef35>] ? pagevec_lookup_tag+0x25/0x40
> [ 2509.515002]  [<ffffffff811042ed>] filemap_fdatawait_range+0x10d/0x1a0
> [ 2509.515006]  [<ffffffff81104480>] filemap_write_and_wait_range+0x70/0x80
> [ 2509.515010]  [<ffffffff8118120a>] vfs_fsync_range+0x5a/0xa0
> [ 2509.515013]  [<ffffffff811812bc>] vfs_fsync+0x1c/0x20
> [ 2509.515021]  [<ffffffffa028b127>] nfs_file_flush+0x57/0x80 [nfs]
> [ 2509.515024]  [<ffffffff8115630c>] filp_close+0x3c/0x90
> [ 2509.515027]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.515031]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.515033] touch         D 0000000000000082     0  3263   2800 0x00000000
> [ 2509.515037]  ffff880660377c08 0000000000000086 0000000000000082 ffff880001e14f00
> [ 2509.515041]  ffff880660377bb8 0000000000014f00 ffff88065a79dd80 0000000000014f00
> [ 2509.515045]  ffff88065a79e108 ffff880660377fd8 ffff88065a79e110 ffff880660377fd8
> [ 2509.515049] Call Trace:
> [ 2509.515060]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515070]  [<ffffffffa01b2fc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
> [ 2509.515074]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.515083]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515087]  [<ffffffff815ad4b8>] out_of_line_wait_on_bit+0x78/0x90
> [ 2509.515091]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.515101]  [<ffffffffa01b2f5e>] __rpc_wait_for_completion_task+0x3e/0x40 [sunrpc]
> [ 2509.515114]  [<ffffffffa02a9c48>] nfs4_do_close+0x1d8/0x2f0 [nfs]
> [ 2509.515118]  [<ffffffff815af2ce>] ? _raw_spin_unlock+0xe/0x10
> [ 2509.515131]  [<ffffffffa02b37dd>] __nfs4_close+0xbd/0x1a0 [nfs]
> [ 2509.515144]  [<ffffffffa02b38d9>] nfs4_close_sync+0x19/0x20 [nfs]
> [ 2509.515156]  [<ffffffffa02a306c>] nfs4_close_context+0x3c/0x50 [nfs]
> [ 2509.515165]  [<ffffffffa028dcb8>] __put_nfs_open_context+0xb8/0xe0 [nfs]
> [ 2509.515175]  [<ffffffffa028dd82>] nfs_release+0xa2/0xc0 [nfs]
> [ 2509.515183]  [<ffffffffa028b5ce>] nfs_file_release+0x4e/0x80 [nfs]
> [ 2509.515186]  [<ffffffff81159e16>] __fput+0xa6/0x250
> [ 2509.515190]  [<ffffffff81159fe5>] fput+0x25/0x30
> [ 2509.515193]  [<ffffffff8115632d>] filp_close+0x5d/0x90
> [ 2509.515196]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.515200]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.515202] touch         D 0000000000000082     0  3264   2794 0x00000000
> [ 2509.515206]  ffff88065a6f7c08 0000000000000086 0000000000000082 ffff880001f14f00
> [ 2509.515210]  ffff88065a6f7bb8 0000000000014f00 ffff88065a559760 0000000000014f00
> [ 2509.515214]  ffff88065a559ae8 ffff88065a6f7fd8 ffff88065a559af0 ffff88065a6f7fd8
> [ 2509.515218] Call Trace:
> [ 2509.515229]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515239]  [<ffffffffa01b2fc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
> [ 2509.515242]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.515252]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515256]  [<ffffffff815ad4b8>] out_of_line_wait_on_bit+0x78/0x90
> [ 2509.515259]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.515270]  [<ffffffffa01b2f5e>] __rpc_wait_for_completion_task+0x3e/0x40 [sunrpc]
> [ 2509.515282]  [<ffffffffa02a9c48>] nfs4_do_close+0x1d8/0x2f0 [nfs]
> [ 2509.515286]  [<ffffffff812d67f4>] ? do_raw_spin_lock+0x54/0x150
> [ 2509.515299]  [<ffffffffa02b37dd>] __nfs4_close+0xbd/0x1a0 [nfs]
> [ 2509.515312]  [<ffffffffa02b38d9>] nfs4_close_sync+0x19/0x20 [nfs]
> [ 2509.515324]  [<ffffffffa02a306c>] nfs4_close_context+0x3c/0x50 [nfs]
> [ 2509.515333]  [<ffffffffa028dcb8>] __put_nfs_open_context+0xb8/0xe0 [nfs]
> [ 2509.515343]  [<ffffffffa028dd82>] nfs_release+0xa2/0xc0 [nfs]
> [ 2509.515351]  [<ffffffffa028b5ce>] nfs_file_release+0x4e/0x80 [nfs]
> [ 2509.515354]  [<ffffffff81159e16>] __fput+0xa6/0x250
> [ 2509.515358]  [<ffffffff81159fe5>] fput+0x25/0x30
> [ 2509.515361]  [<ffffffff8115632d>] filp_close+0x5d/0x90
> [ 2509.515364]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.515368]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.515370] touch         D 0000000000000082     0  3267   2792 0x00000000
> [ 2509.515374]  ffff88065ab2fc08 0000000000000082 0000000000000082 ffff880001e34f00
> [ 2509.515378]  ffff88065ab2fbb8 0000000000014f00 ffff88065a808000 0000000000014f00
> [ 2509.515382]  ffff88065a808388 ffff88065ab2ffd8 ffff88065a808390 ffff88065ab2ffd8
> [ 2509.515386] Call Trace:
> [ 2509.515397]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515407]  [<ffffffffa01b2fc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
> [ 2509.515410]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.515420]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515424]  [<ffffffff815ad4b8>] out_of_line_wait_on_bit+0x78/0x90
> [ 2509.515427]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.515438]  [<ffffffffa01b2f5e>] __rpc_wait_for_completion_task+0x3e/0x40 [sunrpc]
> [ 2509.515450]  [<ffffffffa02a9c48>] nfs4_do_close+0x1d8/0x2f0 [nfs]
> [ 2509.515454]  [<ffffffff815af2ce>] ? _raw_spin_unlock+0xe/0x10
> [ 2509.515468]  [<ffffffffa02b37dd>] __nfs4_close+0xbd/0x1a0 [nfs]
> [ 2509.515481]  [<ffffffffa02b38d9>] nfs4_close_sync+0x19/0x20 [nfs]
> [ 2509.515492]  [<ffffffffa02a306c>] nfs4_close_context+0x3c/0x50 [nfs]
> [ 2509.515502]  [<ffffffffa028dcb8>] __put_nfs_open_context+0xb8/0xe0 [nfs]
> [ 2509.515511]  [<ffffffffa028dd82>] nfs_release+0xa2/0xc0 [nfs]
> [ 2509.515519]  [<ffffffffa028b5ce>] nfs_file_release+0x4e/0x80 [nfs]
> [ 2509.515523]  [<ffffffff81159e16>] __fput+0xa6/0x250
> [ 2509.515526]  [<ffffffff81159fe5>] fput+0x25/0x30
> [ 2509.515529]  [<ffffffff8115632d>] filp_close+0x5d/0x90
> [ 2509.515532]  [<ffffffff81156419>] sys_close+0xb9/0x120
> [ 2509.515536]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.515539] touch         D 0000000000000082     0  3272   2817 0x00000000
> [ 2509.515542]  ffff8804c3fe7948 0000000000000086 0000000000000082 ffff88037aa54f00
> [ 2509.515546]  ffff8804c3fe78f8 0000000000014f00 ffff88065a80dd80 0000000000014f00
> [ 2509.515551]  ffff88065a80e108 ffff8804c3fe7fd8 ffff88065a80e110 ffff8804c3fe7fd8
> [ 2509.515555] Call Trace:
> [ 2509.515565]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515575]  [<ffffffffa01b2fc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
> [ 2509.515579]  [<ffffffff815ad40f>] __wait_on_bit+0x5f/0x90
> [ 2509.515588]  [<ffffffffa01b2fa0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [ 2509.515592]  [<ffffffff815ad4b8>] out_of_line_wait_on_bit+0x78/0x90
> [ 2509.515595]  [<ffffffff81082530>] ? wake_bit_function+0x0/0x40
> [ 2509.515606]  [<ffffffffa01b2f5e>] __rpc_wait_for_completion_task+0x3e/0x40 [sunrpc]
> [ 2509.515618]  [<ffffffffa02a5ae3>] nfs4_run_open_task+0xe3/0x130 [nfs]
> [ 2509.515630]  [<ffffffffa02a5c93>] _nfs4_proc_open+0x43/0x110 [nfs]
> [ 2509.515642]  [<ffffffffa02a7e40>] _nfs4_do_open+0x180/0x290 [nfs]
> [ 2509.515654]  [<ffffffffa02a7fbd>] nfs4_do_open+0x6d/0x120 [nfs]
> [ 2509.515666]  [<ffffffffa01b5b15>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
> [ 2509.515678]  [<ffffffffa02a8141>] nfs4_atomic_open+0xd1/0x210 [nfs]
> [ 2509.515682]  [<ffffffff815af2ce>] ? _raw_spin_unlock+0xe/0x10
> [ 2509.515685]  [<ffffffff812d67f4>] ? do_raw_spin_lock+0x54/0x150
> [ 2509.515694]  [<ffffffffa028785e>] nfs_atomic_lookup+0xae/0x130 [nfs]
> [ 2509.515698]  [<ffffffff811628bc>] d_alloc_and_lookup+0x4c/0x90
> [ 2509.515701]  [<ffffffff8116db0c>] ? d_lookup+0x3c/0x60
> [ 2509.515704]  [<ffffffff811629be>] __lookup_hash+0xbe/0xe0
> [ 2509.515709]  [<ffffffff8126a45f>] ? security_inode_permission+0x1f/0x30
> [ 2509.515712]  [<ffffffff81162a15>] lookup_hash+0x35/0x50
> [ 2509.515716]  [<ffffffff81164894>] do_last+0xe4/0x420
> [ 2509.515719]  [<ffffffff81166cd3>] do_filp_open+0x203/0x5f0
> [ 2509.515723]  [<ffffffff81103e37>] ? unlock_page+0x27/0x30
> [ 2509.515726]  [<ffffffff812d67f4>] ? do_raw_spin_lock+0x54/0x150
> [ 2509.515729]  [<ffffffff812d674e>] ? do_raw_spin_unlock+0x5e/0xb0
> [ 2509.515733]  [<ffffffff811722ba>] ? alloc_fd+0xfa/0x140
> [ 2509.515736]  [<ffffffff811564e5>] do_sys_open+0x65/0x160
> [ 2509.515740]  [<ffffffff81156620>] sys_open+0x20/0x30
> [ 2509.515743]  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b
> [ 2509.515746] Sched Debug Version: v0.09, 2.6.36-0-server #1
> [ 2509.515749] now at 2516307.455882 msecs
> [ 2509.515751]   .jiffies                                 : 4295188926
> [ 2509.515753]   .sysctl_sched_latency                    : 24.000000
> [ 2509.515755]   .sysctl_sched_min_granularity            : 8.000000
> [ 2509.515757]   .sysctl_sched_wakeup_granularity         : 4.000000
> [ 2509.515759]   .sysctl_sched_child_runs_first           : 0
> [ 2509.515761]   .sysctl_sched_features                   : 15471
> [ 2509.515763]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
> [ 2509.515766] 
> [ 2509.515767] cpu#0, 2926.377 MHz
> [ 2509.515769]   .nr_running                    : 0
> [ 2509.515771]   .load                          : 0
> [ 2509.515773]   .nr_switches                   : 712048
> [ 2509.515774]   .nr_load_updates               : 55039
> [ 2509.515776]   .nr_uninterruptible            : 5
> [ 2509.515778]   .next_balance                  : 4295.188926
> [ 2509.515780]   .curr->pid                     : 0
> [ 2509.515782]   .clock                         : 2509498.408476
> [ 2509.515784]   .cpu_load[0]                   : 0
> [ 2509.515786]   .cpu_load[1]                   : 0
> [ 2509.515787]   .cpu_load[2]                   : 0
> [ 2509.515789]   .cpu_load[3]                   : 0
> [ 2509.515791]   .cpu_load[4]                   : 0
> [ 2509.515792]   .yld_count                     : 1410
> [ 2509.515794]   .sched_switch                  : 0
> [ 2509.515796]   .sched_count                   : 759983
> [ 2509.515798]   .sched_goidle                  : 326310
> [ 2509.515800]   .avg_idle                      : 1000000
> [ 2509.515802]   .ttwu_count                    : 367889
> [ 2509.515803]   .ttwu_local                    : 119270
> [ 2509.515805]   .bkl_count                     : 0
> [ 2509.515807] 
> [ 2509.515808] cfs_rq[0]:/
> [ 2509.515810]   .exec_clock                    : 39390.757785
> [ 2509.515812]   .MIN_vruntime                  : 0.000001
> [ 2509.515814]   .min_vruntime                  : 28904.373967
> [ 2509.515816]   .max_vruntime                  : 0.000001
> [ 2509.515818]   .spread                        : 0.000000
> [ 2509.515820]   .spread0                       : 0.000000
> [ 2509.515822]   .nr_running                    : 0
> [ 2509.515823]   .load                          : 0
> [ 2509.515825]   .nr_spread_over                : 1
> [ 2509.515827]   .shares                        : 0
> [ 2509.515829] 
> [ 2509.515830] rt_rq[0]:/
> [ 2509.515831]   .rt_nr_running                 : 0
> [ 2509.515833]   .rt_throttled                  : 0
> [ 2509.515835]   .rt_time                       : 0.000000
> [ 2509.515837]   .rt_runtime                    : 950.000000
> [ 2509.515839] 
> [ 2509.515839] runnable tasks:
> [ 2509.515840]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.515842] ----------------------------------------------------------------------------------------------------------
> [ 2509.515856] 
> [ 2509.515857] cpu#1, 2926.377 MHz
> [ 2509.515859]   .nr_running                    : 0
> [ 2509.515860]   .load                          : 0
> [ 2509.515862]   .nr_switches                   : 649443
> [ 2509.515864]   .nr_load_updates               : 42147
> [ 2509.515866]   .nr_uninterruptible            : 4
> [ 2509.515868]   .next_balance                  : 4295.188657
> [ 2509.515869]   .curr->pid                     : 0
> [ 2509.515871]   .clock                         : 2509510.532309
> [ 2509.515873]   .cpu_load[0]                   : 0
> [ 2509.515875]   .cpu_load[1]                   : 0
> [ 2509.515877]   .cpu_load[2]                   : 0
> [ 2509.515878]   .cpu_load[3]                   : 0
> [ 2509.515880]   .cpu_load[4]                   : 0
> [ 2509.515882]   .yld_count                     : 140
> [ 2509.515883]   .sched_switch                  : 0
> [ 2509.515885]   .sched_count                   : 662529
> [ 2509.515887]   .sched_goidle                  : 289126
> [ 2509.515889]   .avg_idle                      : 1000000
> [ 2509.515891]   .ttwu_count                    : 342872
> [ 2509.515892]   .ttwu_local                    : 111020
> [ 2509.515894]   .bkl_count                     : 12
> [ 2509.515896] 
> [ 2509.515896] cfs_rq[1]:/
> [ 2509.515898]   .exec_clock                    : 48711.605064
> [ 2509.515900]   .MIN_vruntime                  : 0.000001
> [ 2509.515902]   .min_vruntime                  : 34161.400516
> [ 2509.515904]   .max_vruntime                  : 0.000001
> [ 2509.515906]   .spread                        : 0.000000
> [ 2509.515908]   .spread0                       : 5257.026549
> [ 2509.515910]   .nr_running                    : 0
> [ 2509.515912]   .load                          : 0
> [ 2509.515913]   .nr_spread_over                : 0
> [ 2509.515915]   .shares                        : 0
> [ 2509.515917] 
> [ 2509.515917] rt_rq[1]:/
> [ 2509.515919]   .rt_nr_running                 : 0
> [ 2509.515921]   .rt_throttled                  : 0
> [ 2509.515922]   .rt_time                       : 0.000000
> [ 2509.515924]   .rt_runtime                    : 950.000000
> [ 2509.515926] 
> [ 2509.515927] runnable tasks:
> [ 2509.515927]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.515929] ----------------------------------------------------------------------------------------------------------
> [ 2509.515943] 
> [ 2509.515943] cpu#2, 2926.377 MHz
> [ 2509.515945]   .nr_running                    : 0
> [ 2509.515947]   .load                          : 0
> [ 2509.515949]   .nr_switches                   : 594460
> [ 2509.515950]   .nr_load_updates               : 38515
> [ 2509.515952]   .nr_uninterruptible            : 5
> [ 2509.515954]   .next_balance                  : 4295.188795
> [ 2509.515956]   .curr->pid                     : 0
> [ 2509.515958]   .clock                         : 2509508.780482
> [ 2509.515960]   .cpu_load[0]                   : 0
> [ 2509.515961]   .cpu_load[1]                   : 0
> [ 2509.515963]   .cpu_load[2]                   : 0
> [ 2509.515965]   .cpu_load[3]                   : 0
> [ 2509.515966]   .cpu_load[4]                   : 0
> [ 2509.515968]   .yld_count                     : 3
> [ 2509.515970]   .sched_switch                  : 0
> [ 2509.515971]   .sched_count                   : 606786
> [ 2509.515973]   .sched_goidle                  : 269458
> [ 2509.515975]   .avg_idle                      : 1000000
> [ 2509.515977]   .ttwu_count                    : 309588
> [ 2509.515979]   .ttwu_local                    : 73938
> [ 2509.515980]   .bkl_count                     : 2
> [ 2509.515982] 
> [ 2509.515983] cfs_rq[2]:/
> [ 2509.515985]   .exec_clock                    : 26953.163461
> [ 2509.515987]   .MIN_vruntime                  : 0.000001
> [ 2509.515989]   .min_vruntime                  : 16697.979887
> [ 2509.515991]   .max_vruntime                  : 0.000001
> [ 2509.515993]   .spread                        : 0.000000
> [ 2509.515995]   .spread0                       : -12206.394080
> [ 2509.515996]   .nr_running                    : 0
> [ 2509.515998]   .load                          : 0
> [ 2509.516000]   .nr_spread_over                : 2
> [ 2509.516001]   .shares                        : 0
> [ 2509.516003] 
> [ 2509.516004] rt_rq[2]:/
> [ 2509.516005]   .rt_nr_running                 : 0
> [ 2509.516007]   .rt_throttled                  : 0
> [ 2509.516009]   .rt_time                       : 0.000000
> [ 2509.516011]   .rt_runtime                    : 950.000000
> [ 2509.516013] 
> [ 2509.516013] runnable tasks:
> [ 2509.516014]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516015] ----------------------------------------------------------------------------------------------------------
> [ 2509.516029] 
> [ 2509.516030] cpu#3, 2926.377 MHz
> [ 2509.516032]   .nr_running                    : 1
> [ 2509.516033]   .load                          : 1024
> [ 2509.516035]   .nr_switches                   : 620871
> [ 2509.516037]   .nr_load_updates               : 38353
> [ 2509.516039]   .nr_uninterruptible            : 2
> [ 2509.516041]   .next_balance                  : 4295.188298
> [ 2509.516043]   .curr->pid                     : 3329
> [ 2509.516045]   .clock                         : 2509511.043783
> [ 2509.516047]   .cpu_load[0]                   : 0
> [ 2509.516048]   .cpu_load[1]                   : 0
> [ 2509.516050]   .cpu_load[2]                   : 0
> [ 2509.516052]   .cpu_load[3]                   : 0
> [ 2509.516053]   .cpu_load[4]                   : 0
> [ 2509.516055]   .yld_count                     : 99
> [ 2509.516057]   .sched_switch                  : 0
> [ 2509.516058]   .sched_count                   : 632377
> [ 2509.516060]   .sched_goidle                  : 280463
> [ 2509.516062]   .avg_idle                      : 1000000
> [ 2509.516064]   .ttwu_count                    : 324782
> [ 2509.516066]   .ttwu_local                    : 77541
> [ 2509.516068]   .bkl_count                     : 5
> [ 2509.516069] 
> [ 2509.516070] cfs_rq[3]:/
> [ 2509.516072]   .exec_clock                    : 28017.133012
> [ 2509.516074]   .MIN_vruntime                  : 0.000001
> [ 2509.516076]   .min_vruntime                  : 17494.649578
> [ 2509.516078]   .max_vruntime                  : 0.000001
> [ 2509.516080]   .spread                        : 0.000000
> [ 2509.516081]   .spread0                       : -11409.724389
> [ 2509.516083]   .nr_running                    : 1
> [ 2509.516085]   .load                          : 1024
> [ 2509.516087]   .nr_spread_over                : 0
> [ 2509.516089]   .shares                        : 0
> [ 2509.516090] 
> [ 2509.516091] rt_rq[3]:/
> [ 2509.516092]   .rt_nr_running                 : 0
> [ 2509.516094]   .rt_throttled                  : 0
> [ 2509.516096]   .rt_time                       : 0.000000
> [ 2509.516098]   .rt_runtime                    : 950.000000
> [ 2509.516100] 
> [ 2509.516100] runnable tasks:
> [ 2509.516101]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516102] ----------------------------------------------------------------------------------------------------------
> [ 2509.516116] R            tee  3329     17494.649578         2   120     17494.649578         2.292700         0.005230 /
> [ 2509.516124] 
> [ 2509.516124] cpu#4, 2926.377 MHz
> [ 2509.516126]   .nr_running                    : 0
> [ 2509.516128]   .load                          : 0
> [ 2509.516129]   .nr_switches                   : 375028
> [ 2509.516131]   .nr_load_updates               : 14821
> [ 2509.516133]   .nr_uninterruptible            : 0
> [ 2509.516135]   .next_balance                  : 4295.188348
> [ 2509.516137]   .curr->pid                     : 0
> [ 2509.516139]   .clock                         : 2503733.643848
> [ 2509.516141]   .cpu_load[0]                   : 0
> [ 2509.516143]   .cpu_load[1]                   : 0
> [ 2509.516144]   .cpu_load[2]                   : 0
> [ 2509.516146]   .cpu_load[3]                   : 0
> [ 2509.516147]   .cpu_load[4]                   : 0
> [ 2509.516149]   .yld_count                     : 3
> [ 2509.516151]   .sched_switch                  : 0
> [ 2509.516152]   .sched_count                   : 381917
> [ 2509.516154]   .sched_goidle                  : 172613
> [ 2509.516156]   .avg_idle                      : 1000000
> [ 2509.516158]   .ttwu_count                    : 191911
> [ 2509.516160]   .ttwu_local                    : 30752
> [ 2509.516162]   .bkl_count                     : 2
> [ 2509.516163] 
> [ 2509.516164] cfs_rq[4]:/
> [ 2509.516166]   .exec_clock                    : 15086.503095
> [ 2509.516168]   .MIN_vruntime                  : 0.000001
> [ 2509.516170]   .min_vruntime                  : 9804.795930
> [ 2509.516172]   .max_vruntime                  : 0.000001
> [ 2509.516174]   .spread                        : 0.000000
> [ 2509.516176]   .spread0                       : -19099.578037
> [ 2509.516178]   .nr_running                    : 0
> [ 2509.516179]   .load                          : 0
> [ 2509.516181]   .nr_spread_over                : 0
> [ 2509.516183]   .shares                        : 0
> [ 2509.516184] 
> [ 2509.516185] rt_rq[4]:/
> [ 2509.516186]   .rt_nr_running                 : 0
> [ 2509.516188]   .rt_throttled                  : 0
> [ 2509.516190]   .rt_time                       : 0.000000
> [ 2509.516192]   .rt_runtime                    : 950.000000
> [ 2509.516194] 
> [ 2509.516194] runnable tasks:
> [ 2509.516195]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516196] ----------------------------------------------------------------------------------------------------------
> [ 2509.516210] 
> [ 2509.516211] cpu#5, 2926.377 MHz
> [ 2509.516213]   .nr_running                    : 0
> [ 2509.516214]   .load                          : 0
> [ 2509.516216]   .nr_switches                   : 349857
> [ 2509.516218]   .nr_load_updates               : 13882
> [ 2509.516220]   .nr_uninterruptible            : 4
> [ 2509.516222]   .next_balance                  : 4295.188398
> [ 2509.516223]   .curr->pid                     : 0
> [ 2509.516225]   .clock                         : 2504232.325682
> [ 2509.516227]   .cpu_load[0]                   : 0
> [ 2509.516229]   .cpu_load[1]                   : 0
> [ 2509.516231]   .cpu_load[2]                   : 0
> [ 2509.516232]   .cpu_load[3]                   : 0
> [ 2509.516234]   .cpu_load[4]                   : 0
> [ 2509.516235]   .yld_count                     : 3
> [ 2509.516237]   .sched_switch                  : 0
> [ 2509.516239]   .sched_count                   : 355322
> [ 2509.516241]   .sched_goidle                  : 161495
> [ 2509.516242]   .avg_idle                      : 1000000
> [ 2509.516244]   .ttwu_count                    : 179141
> [ 2509.516246]   .ttwu_local                    : 28516
> [ 2509.516248]   .bkl_count                     : 1
> [ 2509.516249] 
> [ 2509.516250] cfs_rq[5]:/
> [ 2509.516252]   .exec_clock                    : 14135.218756
> [ 2509.516254]   .MIN_vruntime                  : 0.000001
> [ 2509.516256]   .min_vruntime                  : 8986.644138
> [ 2509.516258]   .max_vruntime                  : 0.000001
> [ 2509.516260]   .spread                        : 0.000000
> [ 2509.516262]   .spread0                       : -19917.729829
> [ 2509.516263]   .nr_running                    : 0
> [ 2509.516265]   .load                          : 0
> [ 2509.516267]   .nr_spread_over                : 0
> [ 2509.516269]   .shares                        : 0
> [ 2509.516270] 
> [ 2509.516271] rt_rq[5]:/
> [ 2509.516272]   .rt_nr_running                 : 0
> [ 2509.516274]   .rt_throttled                  : 0
> [ 2509.516276]   .rt_time                       : 0.000000
> [ 2509.516278]   .rt_runtime                    : 950.000000
> [ 2509.516280] 
> [ 2509.516280] runnable tasks:
> [ 2509.516281]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516282] ----------------------------------------------------------------------------------------------------------
> [ 2509.516296] 
> [ 2509.516297] cpu#6, 2926.377 MHz
> [ 2509.516298]   .nr_running                    : 0
> [ 2509.516300]   .load                          : 0
> [ 2509.516302]   .nr_switches                   : 231301
> [ 2509.516304]   .nr_load_updates               : 12254
> [ 2509.516306]   .nr_uninterruptible            : 2
> [ 2509.516308]   .next_balance                  : 4295.188448
> [ 2509.516310]   .curr->pid                     : 0
> [ 2509.516312]   .clock                         : 2504731.012557
> [ 2509.516313]   .cpu_load[0]                   : 0
> [ 2509.516315]   .cpu_load[1]                   : 0
> [ 2509.516317]   .cpu_load[2]                   : 0
> [ 2509.516318]   .cpu_load[3]                   : 0
> [ 2509.516320]   .cpu_load[4]                   : 0
> [ 2509.516322]   .yld_count                     : 0
> [ 2509.516323]   .sched_switch                  : 0
> [ 2509.516325]   .sched_count                   : 236246
> [ 2509.516327]   .sched_goidle                  : 105147
> [ 2509.516329]   .avg_idle                      : 1000000
> [ 2509.516331]   .ttwu_count                    : 119309
> [ 2509.516332]   .ttwu_local                    : 23648
> [ 2509.516334]   .bkl_count                     : 2
> [ 2509.516336] 
> [ 2509.516337] cfs_rq[6]:/
> [ 2509.516338]   .exec_clock                    : 9921.039532
> [ 2509.516340]   .MIN_vruntime                  : 0.000001
> [ 2509.516342]   .min_vruntime                  : 5900.983168
> [ 2509.516344]   .max_vruntime                  : 0.000001
> [ 2509.516346]   .spread                        : 0.000000
> [ 2509.516348]   .spread0                       : -23003.390799
> [ 2509.516350]   .nr_running                    : 0
> [ 2509.516352]   .load                          : 0
> [ 2509.516353]   .nr_spread_over                : 0
> [ 2509.516355]   .shares                        : 0
> [ 2509.516357] 
> [ 2509.516358] rt_rq[6]:/
> [ 2509.516359]   .rt_nr_running                 : 0
> [ 2509.516361]   .rt_throttled                  : 0
> [ 2509.516363]   .rt_time                       : 0.000000
> [ 2509.516365]   .rt_runtime                    : 950.000000
> [ 2509.516366] 
> [ 2509.516367] runnable tasks:
> [ 2509.516368]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516369] ----------------------------------------------------------------------------------------------------------
> [ 2509.516383] 
> [ 2509.516384] cpu#7, 2926.377 MHz
> [ 2509.516385]   .nr_running                    : 0
> [ 2509.516387]   .load                          : 0
> [ 2509.516389]   .nr_switches                   : 188769
> [ 2509.516391]   .nr_load_updates               : 11194
> [ 2509.516392]   .nr_uninterruptible            : 1
> [ 2509.516394]   .next_balance                  : 4295.188498
> [ 2509.516396]   .curr->pid                     : 0
> [ 2509.516398]   .clock                         : 2505229.694898
> [ 2509.516400]   .cpu_load[0]                   : 0
> [ 2509.516402]   .cpu_load[1]                   : 0
> [ 2509.516403]   .cpu_load[2]                   : 0
> [ 2509.516405]   .cpu_load[3]                   : 0
> [ 2509.516406]   .cpu_load[4]                   : 0
> [ 2509.516408]   .yld_count                     : 0
> [ 2509.516410]   .sched_switch                  : 0
> [ 2509.516411]   .sched_count                   : 191939
> [ 2509.516413]   .sched_goidle                  : 84989
> [ 2509.516415]   .avg_idle                      : 1000000
> [ 2509.516417]   .ttwu_count                    : 97414
> [ 2509.516419]   .ttwu_local                    : 21071
> [ 2509.516420]   .bkl_count                     : 2
> [ 2509.516422] 
> [ 2509.516422] cfs_rq[7]:/
> [ 2509.516424]   .exec_clock                    : 10037.290643
> [ 2509.516426]   .MIN_vruntime                  : 0.000001
> [ 2509.516428]   .min_vruntime                  : 6496.608344
> [ 2509.516430]   .max_vruntime                  : 0.000001
> [ 2509.516432]   .spread                        : 0.000000
> [ 2509.516434]   .spread0                       : -22407.765623
> [ 2509.516436]   .nr_running                    : 0
> [ 2509.516438]   .load                          : 0
> [ 2509.516439]   .nr_spread_over                : 0
> [ 2509.516441]   .shares                        : 0
> [ 2509.516443] 
> [ 2509.516443] rt_rq[7]:/
> [ 2509.516445]   .rt_nr_running                 : 0
> [ 2509.516446]   .rt_throttled                  : 0
> [ 2509.516448]   .rt_time                       : 0.000000
> [ 2509.516450]   .rt_runtime                    : 950.000000
> [ 2509.516452] 
> [ 2509.516452] runnable tasks:
> [ 2509.516453]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516455] ----------------------------------------------------------------------------------------------------------
> [ 2509.516469] 
> [ 2509.516469] cpu#8, 2926.377 MHz
> [ 2509.516471]   .nr_running                    : 0
> [ 2509.516472]   .load                          : 0
> [ 2509.516474]   .nr_switches                   : 468877
> [ 2509.516476]   .nr_load_updates               : 37664
> [ 2509.516478]   .nr_uninterruptible            : 6
> [ 2509.516480]   .next_balance                  : 4295.188548
> [ 2509.516482]   .curr->pid                     : 0
> [ 2509.516484]   .clock                         : 2505728.386974
> [ 2509.516486]   .cpu_load[0]                   : 0
> [ 2509.516487]   .cpu_load[1]                   : 0
> [ 2509.516489]   .cpu_load[2]                   : 0
> [ 2509.516491]   .cpu_load[3]                   : 0
> [ 2509.516492]   .cpu_load[4]                   : 0
> [ 2509.516494]   .yld_count                     : 0
> [ 2509.516496]   .sched_switch                  : 0
> [ 2509.516497]   .sched_count                   : 478354
> [ 2509.516499]   .sched_goidle                  : 204132
> [ 2509.516501]   .avg_idle                      : 1000000
> [ 2509.516503]   .ttwu_count                    : 252419
> [ 2509.516504]   .ttwu_local                    : 112787
> [ 2509.516506]   .bkl_count                     : 1
> [ 2509.516508] 
> [ 2509.516509] cfs_rq[8]:/
> [ 2509.516510]   .exec_clock                    : 34666.550946
> [ 2509.516513]   .MIN_vruntime                  : 0.000001
> [ 2509.516515]   .min_vruntime                  : 16072.959040
> [ 2509.516517]   .max_vruntime                  : 0.000001
> [ 2509.516518]   .spread                        : 0.000000
> [ 2509.516520]   .spread0                       : -12831.414927
> [ 2509.516522]   .nr_running                    : 0
> [ 2509.516524]   .load                          : 0
> [ 2509.516526]   .nr_spread_over                : 4
> [ 2509.516527]   .shares                        : 0
> [ 2509.516529] 
> [ 2509.516530] rt_rq[8]:/
> [ 2509.516531]   .rt_nr_running                 : 0
> [ 2509.516533]   .rt_throttled                  : 0
> [ 2509.516535]   .rt_time                       : 0.000000
> [ 2509.516537]   .rt_runtime                    : 950.000000
> [ 2509.516539] 
> [ 2509.516539] runnable tasks:
> [ 2509.516540]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516541] ----------------------------------------------------------------------------------------------------------
> [ 2509.516555] 
> [ 2509.516556] cpu#9, 2926.377 MHz
> [ 2509.516558]   .nr_running                    : 0
> [ 2509.516559]   .load                          : 0
> [ 2509.516561]   .nr_switches                   : 104940
> [ 2509.516563]   .nr_load_updates               : 7672
> [ 2509.516565]   .nr_uninterruptible            : 1
> [ 2509.516567]   .next_balance                  : 4295.188598
> [ 2509.516568]   .curr->pid                     : 0
> [ 2509.516570]   .clock                         : 2506227.065008
> [ 2509.516572]   .cpu_load[0]                   : 0
> [ 2509.516574]   .cpu_load[1]                   : 0
> [ 2509.516576]   .cpu_load[2]                   : 0
> [ 2509.516577]   .cpu_load[3]                   : 0
> [ 2509.516579]   .cpu_load[4]                   : 0
> [ 2509.516580]   .yld_count                     : 0
> [ 2509.516582]   .sched_switch                  : 0
> [ 2509.516584]   .sched_count                   : 107480
> [ 2509.516586]   .sched_goidle                  : 47685
> [ 2509.516587]   .avg_idle                      : 1000000
> [ 2509.516589]   .ttwu_count                    : 54332
> [ 2509.516591]   .ttwu_local                    : 12272
> [ 2509.516593]   .bkl_count                     : 2
> [ 2509.516594] 
> [ 2509.516595] cfs_rq[9]:/
> [ 2509.516597]   .exec_clock                    : 6381.886750
> [ 2509.516599]   .MIN_vruntime                  : 0.000001
> [ 2509.516601]   .min_vruntime                  : 4379.369007
> [ 2509.516603]   .max_vruntime                  : 0.000001
> [ 2509.516604]   .spread                        : 0.000000
> [ 2509.516606]   .spread0                       : -24525.004960
> [ 2509.516608]   .nr_running                    : 0
> [ 2509.516610]   .load                          : 0
> [ 2509.516612]   .nr_spread_over                : 0
> [ 2509.516613]   .shares                        : 0
> [ 2509.516615] 
> [ 2509.516616] rt_rq[9]:/
> [ 2509.516617]   .rt_nr_running                 : 0
> [ 2509.516619]   .rt_throttled                  : 0
> [ 2509.516621]   .rt_time                       : 0.000000
> [ 2509.516623]   .rt_runtime                    : 950.000000
> [ 2509.516624] 
> [ 2509.516625] runnable tasks:
> [ 2509.516626]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516627] ----------------------------------------------------------------------------------------------------------
> [ 2509.516641] 
> [ 2509.516642] cpu#10, 2926.377 MHz
> [ 2509.516643]   .nr_running                    : 0
> [ 2509.516645]   .load                          : 0
> [ 2509.516647]   .nr_switches                   : 78843
> [ 2509.516648]   .nr_load_updates               : 7166
> [ 2509.516650]   .nr_uninterruptible            : 0
> [ 2509.516652]   .next_balance                  : 4295.188648
> [ 2509.516654]   .curr->pid                     : 0
> [ 2509.516656]   .clock                         : 2506725.750756
> [ 2509.516658]   .cpu_load[0]                   : 0
> [ 2509.516659]   .cpu_load[1]                   : 0
> [ 2509.516661]   .cpu_load[2]                   : 0
> [ 2509.516663]   .cpu_load[3]                   : 0
> [ 2509.516664]   .cpu_load[4]                   : 0
> [ 2509.516666]   .yld_count                     : 0
> [ 2509.516668]   .sched_switch                  : 0
> [ 2509.516669]   .sched_count                   : 80248
> [ 2509.516671]   .sched_goidle                  : 34143
> [ 2509.516673]   .avg_idle                      : 1000000
> [ 2509.516675]   .ttwu_count                    : 41236
> [ 2509.516677]   .ttwu_local                    : 12318
> [ 2509.516678]   .bkl_count                     : 2
> [ 2509.516680] 
> [ 2509.516681] cfs_rq[10]:/
> [ 2509.516682]   .exec_clock                    : 5801.317959
> [ 2509.516685]   .MIN_vruntime                  : 0.000001
> [ 2509.516687]   .min_vruntime                  : 3520.900691
> [ 2509.516689]   .max_vruntime                  : 0.000001
> [ 2509.516690]   .spread                        : 0.000000
> [ 2509.516692]   .spread0                       : -25383.473276
> [ 2509.516694]   .nr_running                    : 0
> [ 2509.516696]   .load                          : 0
> [ 2509.516698]   .nr_spread_over                : 0
> [ 2509.516699]   .shares                        : 0
> [ 2509.516701] 
> [ 2509.516702] rt_rq[10]:/
> [ 2509.516703]   .rt_nr_running                 : 0
> [ 2509.516705]   .rt_throttled                  : 0
> [ 2509.516707]   .rt_time                       : 0.000000
> [ 2509.516709]   .rt_runtime                    : 950.000000
> [ 2509.516710] 
> [ 2509.516711] runnable tasks:
> [ 2509.516712]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516713] ----------------------------------------------------------------------------------------------------------
> [ 2509.516727] 
> [ 2509.516728] cpu#11, 2926.377 MHz
> [ 2509.516729]   .nr_running                    : 0
> [ 2509.516731]   .load                          : 0
> [ 2509.516733]   .nr_switches                   : 43691
> [ 2509.516734]   .nr_load_updates               : 5960
> [ 2509.516736]   .nr_uninterruptible            : 0
> [ 2509.516738]   .next_balance                  : 4295.188698
> [ 2509.516740]   .curr->pid                     : 0
> [ 2509.516742]   .clock                         : 2507224.421340
> [ 2509.516744]   .cpu_load[0]                   : 0
> [ 2509.516745]   .cpu_load[1]                   : 0
> [ 2509.516747]   .cpu_load[2]                   : 0
> [ 2509.516749]   .cpu_load[3]                   : 0
> [ 2509.516750]   .cpu_load[4]                   : 0
> [ 2509.516752]   .yld_count                     : 0
> [ 2509.516753]   .sched_switch                  : 0
> [ 2509.516755]   .sched_count                   : 44639
> [ 2509.516757]   .sched_goidle                  : 18573
> [ 2509.516759]   .avg_idle                      : 1000000
> [ 2509.516761]   .ttwu_count                    : 22914
> [ 2509.516762]   .ttwu_local                    : 8336
> [ 2509.516764]   .bkl_count                     : 2
> [ 2509.516766] 
> [ 2509.516766] cfs_rq[11]:/
> [ 2509.516768]   .exec_clock                    : 4006.651797
> [ 2509.516770]   .MIN_vruntime                  : 0.000001
> [ 2509.516772]   .min_vruntime                  : 2412.588532
> [ 2509.516774]   .max_vruntime                  : 0.000001
> [ 2509.516776]   .spread                        : 0.000000
> [ 2509.516778]   .spread0                       : -26491.785435
> [ 2509.516780]   .nr_running                    : 0
> [ 2509.516782]   .load                          : 0
> [ 2509.516783]   .nr_spread_over                : 0
> [ 2509.516785]   .shares                        : 0
> [ 2509.516787] 
> [ 2509.516787] rt_rq[11]:/
> [ 2509.516789]   .rt_nr_running                 : 0
> [ 2509.516790]   .rt_throttled                  : 0
> [ 2509.516792]   .rt_time                       : 0.000000
> [ 2509.516794]   .rt_runtime                    : 950.000000
> [ 2509.516796] 
> [ 2509.516796] runnable tasks:
> [ 2509.516797]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516798] ----------------------------------------------------------------------------------------------------------
> [ 2509.516812] 
> [ 2509.516813] cpu#12, 2926.377 MHz
> [ 2509.516815]   .nr_running                    : 0
> [ 2509.516816]   .load                          : 0
> [ 2509.516818]   .nr_switches                   : 179851
> [ 2509.516820]   .nr_load_updates               : 11642
> [ 2509.516822]   .nr_uninterruptible            : 1
> [ 2509.516824]   .next_balance                  : 4295.188748
> [ 2509.516826]   .curr->pid                     : 0
> [ 2509.516828]   .clock                         : 2507723.110546
> [ 2509.516829]   .cpu_load[0]                   : 0
> [ 2509.516831]   .cpu_load[1]                   : 0
> [ 2509.516833]   .cpu_load[2]                   : 0
> [ 2509.516834]   .cpu_load[3]                   : 0
> [ 2509.516836]   .cpu_load[4]                   : 0
> [ 2509.516838]   .yld_count                     : 1
> [ 2509.516839]   .sched_switch                  : 0
> [ 2509.516841]   .sched_count                   : 183971
> [ 2509.516843]   .sched_goidle                  : 83137
> [ 2509.516845]   .avg_idle                      : 1000000
> [ 2509.516847]   .ttwu_count                    : 92806
> [ 2509.516848]   .ttwu_local                    : 18375
> [ 2509.516850]   .bkl_count                     : 0
> [ 2509.516852] 
> [ 2509.516852] cfs_rq[12]:/
> [ 2509.516854]   .exec_clock                    : 8705.397738
> [ 2509.516856]   .MIN_vruntime                  : 0.000001
> [ 2509.516858]   .min_vruntime                  : 5850.703454
> [ 2509.516860]   .max_vruntime                  : 0.000001
> [ 2509.516862]   .spread                        : 0.000000
> [ 2509.516864]   .spread0                       : -23053.670513
> [ 2509.516866]   .nr_running                    : 0
> [ 2509.516868]   .load                          : 0
> [ 2509.516869]   .nr_spread_over                : 0
> [ 2509.516871]   .shares                        : 0
> [ 2509.516873] 
> [ 2509.516873] rt_rq[12]:/
> [ 2509.516875]   .rt_nr_running                 : 0
> [ 2509.516876]   .rt_throttled                  : 0
> [ 2509.516878]   .rt_time                       : 0.000000
> [ 2509.516880]   .rt_runtime                    : 950.000000
> [ 2509.516882] 
> [ 2509.516882] runnable tasks:
> [ 2509.516883]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516885] ----------------------------------------------------------------------------------------------------------
> [ 2509.516899] 
> [ 2509.516899] cpu#13, 2926.377 MHz
> [ 2509.516901]   .nr_running                    : 0
> [ 2509.516903]   .load                          : 0
> [ 2509.516904]   .nr_switches                   : 339188
> [ 2509.516906]   .nr_load_updates               : 19948
> [ 2509.516908]   .nr_uninterruptible            : 0
> [ 2509.516910]   .next_balance                  : 4295.188798
> [ 2509.516912]   .curr->pid                     : 0
> [ 2509.516914]   .clock                         : 2508221.784865
> [ 2509.516915]   .cpu_load[0]                   : 0
> [ 2509.516917]   .cpu_load[1]                   : 0
> [ 2509.516919]   .cpu_load[2]                   : 0
> [ 2509.516920]   .cpu_load[3]                   : 0
> [ 2509.516922]   .cpu_load[4]                   : 0
> [ 2509.516924]   .yld_count                     : 0
> [ 2509.516925]   .sched_switch                  : 0
> [ 2509.516927]   .sched_count                   : 353787
> [ 2509.516929]   .sched_goidle                  : 148589
> [ 2509.516931]   .avg_idle                      : 1000000
> [ 2509.516932]   .ttwu_count                    : 181994
> [ 2509.516934]   .ttwu_local                    : 45296
> [ 2509.516936]   .bkl_count                     : 2
> [ 2509.516938] 
> [ 2509.516938] cfs_rq[13]:/
> [ 2509.516940]   .exec_clock                    : 14989.804191
> [ 2509.516942]   .MIN_vruntime                  : 0.000001
> [ 2509.516944]   .min_vruntime                  : 8237.475529
> [ 2509.516946]   .max_vruntime                  : 0.000001
> [ 2509.516948]   .spread                        : 0.000000
> [ 2509.516950]   .spread0                       : -20666.898438
> [ 2509.516952]   .nr_running                    : 0
> [ 2509.516953]   .load                          : 0
> [ 2509.516955]   .nr_spread_over                : 0
> [ 2509.516957]   .shares                        : 0
> [ 2509.516959] 
> [ 2509.516959] rt_rq[13]:/
> [ 2509.516961]   .rt_nr_running                 : 0
> [ 2509.516962]   .rt_throttled                  : 0
> [ 2509.516964]   .rt_time                       : 0.000000
> [ 2509.516966]   .rt_runtime                    : 950.000000
> [ 2509.516968] 
> [ 2509.516968] runnable tasks:
> [ 2509.516969]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.516971] ----------------------------------------------------------------------------------------------------------
> [ 2509.516985] 
> [ 2509.516985] cpu#14, 2926.377 MHz
> [ 2509.516987]   .nr_running                    : 0
> [ 2509.516989]   .load                          : 0
> [ 2509.516990]   .nr_switches                   : 131086
> [ 2509.516992]   .nr_load_updates               : 11042
> [ 2509.516994]   .nr_uninterruptible            : 0
> [ 2509.516996]   .next_balance                  : 4295.186451
> [ 2509.516998]   .curr->pid                     : 0
> [ 2509.517000]   .clock                         : 2509510.570169
> [ 2509.517002]   .cpu_load[0]                   : 0
> [ 2509.517004]   .cpu_load[1]                   : 0
> [ 2509.517005]   .cpu_load[2]                   : 0
> [ 2509.517007]   .cpu_load[3]                   : 0
> [ 2509.517008]   .cpu_load[4]                   : 0
> [ 2509.517010]   .yld_count                     : 248
> [ 2509.517012]   .sched_switch                  : 0
> [ 2509.517014]   .sched_count                   : 134032
> [ 2509.517016]   .sched_goidle                  : 58670
> [ 2509.517017]   .avg_idle                      : 1000000
> [ 2509.517019]   .ttwu_count                    : 67945
> [ 2509.517021]   .ttwu_local                    : 18482
> [ 2509.517023]   .bkl_count                     : 9
> [ 2509.517025] 
> [ 2509.517025] cfs_rq[14]:/
> [ 2509.517027]   .exec_clock                    : 7616.526420
> [ 2509.517029]   .MIN_vruntime                  : 0.000001
> [ 2509.517031]   .min_vruntime                  : 17325.906067
> [ 2509.517033]   .max_vruntime                  : 0.000001
> [ 2509.517035]   .spread                        : 0.000000
> [ 2509.517037]   .spread0                       : -11578.467900
> [ 2509.517039]   .nr_running                    : 0
> [ 2509.517040]   .load                          : 0
> [ 2509.517042]   .nr_spread_over                : 1
> [ 2509.517044]   .shares                        : 0
> [ 2509.517045] 
> [ 2509.517046] rt_rq[14]:/
> [ 2509.517048]   .rt_nr_running                 : 0
> [ 2509.517049]   .rt_throttled                  : 0
> [ 2509.517051]   .rt_time                       : 0.000000
> [ 2509.517053]   .rt_runtime                    : 950.000000
> [ 2509.517055] 
> [ 2509.517056] runnable tasks:
> [ 2509.517056]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517058] ----------------------------------------------------------------------------------------------------------
> [ 2509.517072] 
> [ 2509.517072] cpu#15, 2926.377 MHz
> [ 2509.517074]   .nr_running                    : 0
> [ 2509.517076]   .load                          : 0
> [ 2509.517077]   .nr_switches                   : 134374
> [ 2509.517079]   .nr_load_updates               : 12190
> [ 2509.517081]   .nr_uninterruptible            : 2
> [ 2509.517083]   .next_balance                  : 4295.188898
> [ 2509.517085]   .curr->pid                     : 0
> [ 2509.517087]   .clock                         : 2509511.044387
> [ 2509.517089]   .cpu_load[0]                   : 0
> [ 2509.517090]   .cpu_load[1]                   : 0
> [ 2509.517092]   .cpu_load[2]                   : 0
> [ 2509.517093]   .cpu_load[3]                   : 0
> [ 2509.517095]   .cpu_load[4]                   : 0
> [ 2509.517097]   .yld_count                     : 14
> [ 2509.517098]   .sched_switch                  : 0
> [ 2509.517100]   .sched_count                   : 137743
> [ 2509.517102]   .sched_goidle                  : 60550
> [ 2509.517104]   .avg_idle                      : 912840
> [ 2509.517106]   .ttwu_count                    : 69593
> [ 2509.517107]   .ttwu_local                    : 18493
> [ 2509.517109]   .bkl_count                     : 11
> [ 2509.517111] 
> [ 2509.517111] cfs_rq[15]:/
> [ 2509.517113]   .exec_clock                    : 7787.256403
> [ 2509.517115]   .MIN_vruntime                  : 0.000001
> [ 2509.517117]   .min_vruntime                  : 18367.809185
> [ 2509.517119]   .max_vruntime                  : 0.000001
> [ 2509.517121]   .spread                        : 0.000000
> [ 2509.517123]   .spread0                       : -10536.564782
> [ 2509.517125]   .nr_running                    : 0
> [ 2509.517126]   .load                          : 0
> [ 2509.517128]   .nr_spread_over                : 0
> [ 2509.517130]   .shares                        : 0
> [ 2509.517131] 
> [ 2509.517132] rt_rq[15]:/
> [ 2509.517133]   .rt_nr_running                 : 0
> [ 2509.517135]   .rt_throttled                  : 0
> [ 2509.517137]   .rt_time                       : 0.006518
> [ 2509.517139]   .rt_runtime                    : 950.000000
> [ 2509.517141] 
> [ 2509.517141] runnable tasks:
> [ 2509.517142]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517144] ----------------------------------------------------------------------------------------------------------
> [ 2509.517158] 
> [ 2509.517158] cpu#16, 2926.377 MHz
> [ 2509.517160]   .nr_running                    : 0
> [ 2509.517161]   .load                          : 0
> [ 2509.517163]   .nr_switches                   : 110310
> [ 2509.517165]   .nr_load_updates               : 7381
> [ 2509.517167]   .nr_uninterruptible            : 1
> [ 2509.517169]   .next_balance                  : 4295.188927
> [ 2509.517171]   .curr->pid                     : 0
> [ 2509.517173]   .clock                         : 2509508.373496
> [ 2509.517174]   .cpu_load[0]                   : 0
> [ 2509.517176]   .cpu_load[1]                   : 0
> [ 2509.517178]   .cpu_load[2]                   : 0
> [ 2509.517179]   .cpu_load[3]                   : 0
> [ 2509.517181]   .cpu_load[4]                   : 0
> [ 2509.517183]   .yld_count                     : 1
> [ 2509.517184]   .sched_switch                  : 0
> [ 2509.517186]   .sched_count                   : 112652
> [ 2509.517188]   .sched_goidle                  : 51021
> [ 2509.517190]   .avg_idle                      : 1000000
> [ 2509.517192]   .ttwu_count                    : 56915
> [ 2509.517193]   .ttwu_local                    : 11649
> [ 2509.517195]   .bkl_count                     : 0
> [ 2509.517197] 
> [ 2509.517197] cfs_rq[16]:/
> [ 2509.517199]   .exec_clock                    : 5469.665435
> [ 2509.517201]   .MIN_vruntime                  : 0.000001
> [ 2509.517203]   .min_vruntime                  : 5621.333338
> [ 2509.517205]   .max_vruntime                  : 0.000001
> [ 2509.517207]   .spread                        : 0.000000
> [ 2509.517209]   .spread0                       : -23283.040629
> [ 2509.517211]   .nr_running                    : 0
> [ 2509.517213]   .load                          : 0
> [ 2509.517214]   .nr_spread_over                : 0
> [ 2509.517216]   .shares                        : 0
> [ 2509.517218] 
> [ 2509.517218] rt_rq[16]:/
> [ 2509.517220]   .rt_nr_running                 : 0
> [ 2509.517222]   .rt_throttled                  : 0
> [ 2509.517224]   .rt_time                       : 0.000000
> [ 2509.517226]   .rt_runtime                    : 950.000000
> [ 2509.517227] 
> [ 2509.517228] runnable tasks:
> [ 2509.517228]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517230] ----------------------------------------------------------------------------------------------------------
> [ 2509.517244] 
> [ 2509.517245] cpu#17, 2926.377 MHz
> [ 2509.517246]   .nr_running                    : 0
> [ 2509.517248]   .load                          : 0
> [ 2509.517250]   .nr_switches                   : 108005
> [ 2509.517251]   .nr_load_updates               : 7484
> [ 2509.517253]   .nr_uninterruptible            : 0
> [ 2509.517255]   .next_balance                  : 4295.187798
> [ 2509.517257]   .curr->pid                     : 0
> [ 2509.517259]   .clock                         : 2498248.102592
> [ 2509.517261]   .cpu_load[0]                   : 0
> [ 2509.517262]   .cpu_load[1]                   : 0
> [ 2509.517264]   .cpu_load[2]                   : 0
> [ 2509.517266]   .cpu_load[3]                   : 0
> [ 2509.517267]   .cpu_load[4]                   : 0
> [ 2509.517269]   .yld_count                     : 3
> [ 2509.517270]   .sched_switch                  : 0
> [ 2509.517272]   .sched_count                   : 110436
> [ 2509.517274]   .sched_goidle                  : 49469
> [ 2509.517276]   .avg_idle                      : 1000000
> [ 2509.517278]   .ttwu_count                    : 55414
> [ 2509.517279]   .ttwu_local                    : 11556
> [ 2509.517281]   .bkl_count                     : 0
> [ 2509.517283] 
> [ 2509.517283] cfs_rq[17]:/
> [ 2509.517285]   .exec_clock                    : 4921.763855
> [ 2509.517287]   .MIN_vruntime                  : 0.000001
> [ 2509.517289]   .min_vruntime                  : 4830.184841
> [ 2509.517291]   .max_vruntime                  : 0.000001
> [ 2509.517293]   .spread                        : 0.000000
> [ 2509.517295]   .spread0                       : -24074.189126
> [ 2509.517297]   .nr_running                    : 0
> [ 2509.517298]   .load                          : 0
> [ 2509.517300]   .nr_spread_over                : 0
> [ 2509.517302]   .shares                        : 0
> [ 2509.517303] 
> [ 2509.517304] rt_rq[17]:/
> [ 2509.517305]   .rt_nr_running                 : 0
> [ 2509.517307]   .rt_throttled                  : 0
> [ 2509.517309]   .rt_time                       : 0.000000
> [ 2509.517311]   .rt_runtime                    : 950.000000
> [ 2509.517313] 
> [ 2509.517313] runnable tasks:
> [ 2509.517314]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517315] ----------------------------------------------------------------------------------------------------------
> [ 2509.517329] 
> [ 2509.517330] cpu#18, 2926.377 MHz
> [ 2509.517331]   .nr_running                    : 0
> [ 2509.517333]   .load                          : 0
> [ 2509.517335]   .nr_switches                   : 57638
> [ 2509.517337]   .nr_load_updates               : 7266
> [ 2509.517339]   .nr_uninterruptible            : 1
> [ 2509.517341]   .next_balance                  : 4295.187848
> [ 2509.517342]   .curr->pid                     : 0
> [ 2509.517344]   .clock                         : 2498746.802506
> [ 2509.517346]   .cpu_load[0]                   : 0
> [ 2509.517348]   .cpu_load[1]                   : 0
> [ 2509.517349]   .cpu_load[2]                   : 0
> [ 2509.517351]   .cpu_load[3]                   : 0
> [ 2509.517353]   .cpu_load[4]                   : 0
> [ 2509.517354]   .yld_count                     : 1
> [ 2509.517356]   .sched_switch                  : 0
> [ 2509.517358]   .sched_count                   : 58989
> [ 2509.517359]   .sched_goidle                  : 25237
> [ 2509.517361]   .avg_idle                      : 1000000
> [ 2509.517363]   .ttwu_count                    : 30026
> [ 2509.517365]   .ttwu_local                    : 9061
> [ 2509.517367]   .bkl_count                     : 0
> [ 2509.517368] 
> [ 2509.517369] cfs_rq[18]:/
> [ 2509.517371]   .exec_clock                    : 4067.866938
> [ 2509.517373]   .MIN_vruntime                  : 0.000001
> [ 2509.517375]   .min_vruntime                  : 3650.853857
> [ 2509.517377]   .max_vruntime                  : 0.000001
> [ 2509.517379]   .spread                        : 0.000000
> [ 2509.517381]   .spread0                       : -25253.520110
> [ 2509.517383]   .nr_running                    : 0
> [ 2509.517384]   .load                          : 0
> [ 2509.517386]   .nr_spread_over                : 0
> [ 2509.517388]   .shares                        : 0
> [ 2509.517389] 
> [ 2509.517390] rt_rq[18]:/
> [ 2509.517391]   .rt_nr_running                 : 0
> [ 2509.517393]   .rt_throttled                  : 0
> [ 2509.517395]   .rt_time                       : 0.000000
> [ 2509.517397]   .rt_runtime                    : 950.000000
> [ 2509.517399] 
> [ 2509.517399] runnable tasks:
> [ 2509.517400]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517401] ----------------------------------------------------------------------------------------------------------
> [ 2509.517415] 
> [ 2509.517416] cpu#19, 2926.377 MHz
> [ 2509.517417]   .nr_running                    : 0
> [ 2509.517419]   .load                          : 0
> [ 2509.517421]   .nr_switches                   : 73078
> [ 2509.517423]   .nr_load_updates               : 5801
> [ 2509.517425]   .nr_uninterruptible            : 1
> [ 2509.517426]   .next_balance                  : 4295.187898
> [ 2509.517428]   .curr->pid                     : 0
> [ 2509.517430]   .clock                         : 2499245.484622
> [ 2509.517432]   .cpu_load[0]                   : 0
> [ 2509.517434]   .cpu_load[1]                   : 0
> [ 2509.517435]   .cpu_load[2]                   : 0
> [ 2509.517437]   .cpu_load[3]                   : 0
> [ 2509.517438]   .cpu_load[4]                   : 0
> [ 2509.517440]   .yld_count                     : 0
> [ 2509.517442]   .sched_switch                  : 0
> [ 2509.517443]   .sched_count                   : 74557
> [ 2509.517445]   .sched_goidle                  : 33178
> [ 2509.517447]   .avg_idle                      : 1000000
> [ 2509.517449]   .ttwu_count                    : 37930
> [ 2509.517451]   .ttwu_local                    : 8528
> [ 2509.517452]   .bkl_count                     : 0
> [ 2509.517454] 
> [ 2509.517454] cfs_rq[19]:/
> [ 2509.517456]   .exec_clock                    : 4041.764616
> [ 2509.517458]   .MIN_vruntime                  : 0.000001
> [ 2509.517461]   .min_vruntime                  : 3394.953139
> [ 2509.517462]   .max_vruntime                  : 0.000001
> [ 2509.517464]   .spread                        : 0.000000
> [ 2509.517466]   .spread0                       : -25509.420828
> [ 2509.517468]   .nr_running                    : 0
> [ 2509.517470]   .load                          : 0
> [ 2509.517471]   .nr_spread_over                : 0
> [ 2509.517473]   .shares                        : 0
> [ 2509.517475] 
> [ 2509.517475] rt_rq[19]:/
> [ 2509.517477]   .rt_nr_running                 : 0
> [ 2509.517479]   .rt_throttled                  : 0
> [ 2509.517480]   .rt_time                       : 0.000000
> [ 2509.517482]   .rt_runtime                    : 950.000000
> [ 2509.517484] 
> [ 2509.517485] runnable tasks:
> [ 2509.517485]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517487] ----------------------------------------------------------------------------------------------------------
> [ 2509.517501] 
> [ 2509.517501] cpu#20, 2926.377 MHz
> [ 2509.517503]   .nr_running                    : 0
> [ 2509.517505]   .load                          : 0
> [ 2509.517506]   .nr_switches                   : 536867
> [ 2509.517508]   .nr_load_updates               : 30592
> [ 2509.517510]   .nr_uninterruptible            : 3
> [ 2509.517512]   .next_balance                  : 4295.187948
> [ 2509.517514]   .curr->pid                     : 0
> [ 2509.517516]   .clock                         : 2499744.171932
> [ 2509.517518]   .cpu_load[0]                   : 0
> [ 2509.517519]   .cpu_load[1]                   : 0
> [ 2509.517521]   .cpu_load[2]                   : 0
> [ 2509.517523]   .cpu_load[3]                   : 0
> [ 2509.517524]   .cpu_load[4]                   : 0
> [ 2509.517526]   .yld_count                     : 1378
> [ 2509.517528]   .sched_switch                  : 0
> [ 2509.517530]   .sched_count                   : 560733
> [ 2509.517531]   .sched_goidle                  : 233569
> [ 2509.517533]   .avg_idle                      : 1000000
> [ 2509.517535]   .ttwu_count                    : 294146
> [ 2509.517537]   .ttwu_local                    : 70167
> [ 2509.517539]   .bkl_count                     : 0
> [ 2509.517540] 
> [ 2509.517541] cfs_rq[20]:/
> [ 2509.517543]   .exec_clock                    : 21760.395483
> [ 2509.517545]   .MIN_vruntime                  : 0.000001
> [ 2509.517547]   .min_vruntime                  : 10857.317131
> [ 2509.517549]   .max_vruntime                  : 0.000001
> [ 2509.517551]   .spread                        : 0.000000
> [ 2509.517553]   .spread0                       : -18047.056836
> [ 2509.517555]   .nr_running                    : 0
> [ 2509.517556]   .load                          : 0
> [ 2509.517558]   .nr_spread_over                : 4
> [ 2509.517560]   .shares                        : 0
> [ 2509.517561] 
> [ 2509.517562] rt_rq[20]:/
> [ 2509.517564]   .rt_nr_running                 : 0
> [ 2509.517565]   .rt_throttled                  : 0
> [ 2509.517567]   .rt_time                       : 0.000000
> [ 2509.517569]   .rt_runtime                    : 950.000000
> [ 2509.517571] 
> [ 2509.517571] runnable tasks:
> [ 2509.517572]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517573] ----------------------------------------------------------------------------------------------------------
> [ 2509.517587] 
> [ 2509.517588] cpu#21, 2926.377 MHz
> [ 2509.517590]   .nr_running                    : 0
> [ 2509.517591]   .load                          : 0
> [ 2509.517593]   .nr_switches                   : 30818
> [ 2509.517595]   .nr_load_updates               : 5693
> [ 2509.517597]   .nr_uninterruptible            : 0
> [ 2509.517598]   .next_balance                  : 4295.187998
> [ 2509.517600]   .curr->pid                     : 0
> [ 2509.517602]   .clock                         : 2500242.848196
> [ 2509.517604]   .cpu_load[0]                   : 0
> [ 2509.517606]   .cpu_load[1]                   : 0
> [ 2509.517607]   .cpu_load[2]                   : 0
> [ 2509.517609]   .cpu_load[3]                   : 0
> [ 2509.517611]   .cpu_load[4]                   : 0
> [ 2509.517612]   .yld_count                     : 0
> [ 2509.517614]   .sched_switch                  : 0
> [ 2509.517616]   .sched_count                   : 31675
> [ 2509.517617]   .sched_goidle                  : 13350
> [ 2509.517619]   .avg_idle                      : 1000000
> [ 2509.517621]   .ttwu_count                    : 16249
> [ 2509.517623]   .ttwu_local                    : 5412
> [ 2509.517625]   .bkl_count                     : 0
> [ 2509.517626] 
> [ 2509.517627] cfs_rq[21]:/
> [ 2509.517629]   .exec_clock                    : 2773.432434
> [ 2509.517631]   .MIN_vruntime                  : 0.000001
> [ 2509.517633]   .min_vruntime                  : 2312.427615
> [ 2509.517635]   .max_vruntime                  : 0.000001
> [ 2509.517636]   .spread                        : 0.000000
> [ 2509.517638]   .spread0                       : -26591.946352
> [ 2509.517640]   .nr_running                    : 0
> [ 2509.517642]   .load                          : 0
> [ 2509.517644]   .nr_spread_over                : 0
> [ 2509.517645]   .shares                        : 0
> [ 2509.517647] 
> [ 2509.517648] rt_rq[21]:/
> [ 2509.517649]   .rt_nr_running                 : 0
> [ 2509.517651]   .rt_throttled                  : 0
> [ 2509.517652]   .rt_time                       : 0.000000
> [ 2509.517654]   .rt_runtime                    : 950.000000
> [ 2509.517656] 
> [ 2509.517657] runnable tasks:
> [ 2509.517657]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517659] ----------------------------------------------------------------------------------------------------------
> [ 2509.517673] 
> [ 2509.517674] cpu#22, 2926.377 MHz
> [ 2509.517675]   .nr_running                    : 0
> [ 2509.517677]   .load                          : 0
> [ 2509.517679]   .nr_switches                   : 27401
> [ 2509.517681]   .nr_load_updates               : 4062
> [ 2509.517682]   .nr_uninterruptible            : 0
> [ 2509.517684]   .next_balance                  : 4295.188048
> [ 2509.517686]   .curr->pid                     : 0
> [ 2509.517688]   .clock                         : 2500741.533867
> [ 2509.517690]   .cpu_load[0]                   : 0
> [ 2509.517692]   .cpu_load[1]                   : 0
> [ 2509.517693]   .cpu_load[2]                   : 0
> [ 2509.517695]   .cpu_load[3]                   : 0
> [ 2509.517696]   .cpu_load[4]                   : 0
> [ 2509.517698]   .yld_count                     : 0
> [ 2509.517700]   .sched_switch                  : 0
> [ 2509.517701]   .sched_count                   : 28307
> [ 2509.517703]   .sched_goidle                  : 11970
> [ 2509.517705]   .avg_idle                      : 1000000
> [ 2509.517707]   .ttwu_count                    : 14508
> [ 2509.517709]   .ttwu_local                    : 5094
> [ 2509.517710]   .bkl_count                     : 0
> [ 2509.517712] 
> [ 2509.517713] cfs_rq[22]:/
> [ 2509.517715]   .exec_clock                    : 2991.653558
> [ 2509.517717]   .MIN_vruntime                  : 0.000001
> [ 2509.517719]   .min_vruntime                  : 2540.856737
> [ 2509.517721]   .max_vruntime                  : 0.000001
> [ 2509.517723]   .spread                        : 0.000000
> [ 2509.517724]   .spread0                       : -26363.517230
> [ 2509.517726]   .nr_running                    : 0
> [ 2509.517728]   .load                          : 0
> [ 2509.517730]   .nr_spread_over                : 0
> [ 2509.517731]   .shares                        : 0
> [ 2509.517733] 
> [ 2509.517734] rt_rq[22]:/
> [ 2509.517735]   .rt_nr_running                 : 0
> [ 2509.517737]   .rt_throttled                  : 0
> [ 2509.517739]   .rt_time                       : 0.000000
> [ 2509.517741]   .rt_runtime                    : 950.000000
> [ 2509.517743] 
> [ 2509.517743] runnable tasks:
> [ 2509.517744]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517745] ----------------------------------------------------------------------------------------------------------
> [ 2509.517759] 
> [ 2509.517760] cpu#23, 2926.377 MHz
> [ 2509.517761]   .nr_running                    : 0
> [ 2509.517763]   .load                          : 0
> [ 2509.517765]   .nr_switches                   : 86804
> [ 2509.517767]   .nr_load_updates               : 18018
> [ 2509.517768]   .nr_uninterruptible            : 1
> [ 2509.517770]   .next_balance                  : 4295.188926
> [ 2509.517772]   .curr->pid                     : 0
> [ 2509.517774]   .clock                         : 2509498.407337
> [ 2509.517776]   .cpu_load[0]                   : 0
> [ 2509.517778]   .cpu_load[1]                   : 0
> [ 2509.517779]   .cpu_load[2]                   : 0
> [ 2509.517781]   .cpu_load[3]                   : 0
> [ 2509.517782]   .cpu_load[4]                   : 0
> [ 2509.517784]   .yld_count                     : 0
> [ 2509.517786]   .sched_switch                  : 0
> [ 2509.517787]   .sched_count                   : 87395
> [ 2509.517789]   .sched_goidle                  : 39167
> [ 2509.517791]   .avg_idle                      : 1000000
> [ 2509.517793]   .ttwu_count                    : 46000
> [ 2509.517794]   .ttwu_local                    : 39609
> [ 2509.517796]   .bkl_count                     : 0
> [ 2509.517798] 
> [ 2509.517798] cfs_rq[23]:/
> [ 2509.517800]   .exec_clock                    : 4299.577232
> [ 2509.517802]   .MIN_vruntime                  : 0.000001
> [ 2509.517804]   .min_vruntime                  : 2855.282608
> [ 2509.517806]   .max_vruntime                  : 0.000001
> [ 2509.517808]   .spread                        : 0.000000
> [ 2509.517810]   .spread0                       : -26049.091359
> [ 2509.517812]   .nr_running                    : 0
> [ 2509.517813]   .load                          : 0
> [ 2509.517815]   .nr_spread_over                : 0
> [ 2509.517817]   .shares                        : 0
> [ 2509.517819] 
> [ 2509.517819] rt_rq[23]:/
> [ 2509.517821]   .rt_nr_running                 : 0
> [ 2509.517822]   .rt_throttled                  : 0
> [ 2509.517824]   .rt_time                       : 0.000000
> [ 2509.517826]   .rt_runtime                    : 950.000000
> [ 2509.517828] 
> [ 2509.517828] runnable tasks:
> [ 2509.517829]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [ 2509.517830] ----------------------------------------------------------------------------------------------------------
> [ 2509.517844] 
> [ 2527.800140] nfs: server 127.0.0.1 not responding, still trying

> #
> # Automatically generated make config: don't edit
> # Linux kernel version: 2.6.36-0-server
> # Wed Sep  1 08:07:26 2010
> #
> CONFIG_64BIT=y
> # CONFIG_X86_32 is not set
> CONFIG_X86_64=y
> CONFIG_X86=y
> CONFIG_INSTRUCTION_DECODER=y
> CONFIG_OUTPUT_FORMAT="elf64-x86-64"
> CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
> CONFIG_GENERIC_CMOS_UPDATE=y
> CONFIG_CLOCKSOURCE_WATCHDOG=y
> CONFIG_GENERIC_CLOCKEVENTS=y
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> CONFIG_MMU=y
> CONFIG_ZONE_DMA=y
> CONFIG_NEED_DMA_MAP_STATE=y
> CONFIG_NEED_SG_DMA_LENGTH=y
> CONFIG_GENERIC_ISA_DMA=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_GENERIC_BUG=y
> CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
> CONFIG_GENERIC_HWEIGHT=y
> CONFIG_GENERIC_GPIO=y
> CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> # CONFIG_RWSEM_GENERIC_SPINLOCK is not set
> CONFIG_RWSEM_XCHGADD_ALGORITHM=y
> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
> CONFIG_GENERIC_CALIBRATE_DELAY=y
> CONFIG_GENERIC_TIME_VSYSCALL=y
> CONFIG_ARCH_HAS_CPU_RELAX=y
> CONFIG_ARCH_HAS_DEFAULT_IDLE=y
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
> CONFIG_HAVE_SETUP_PER_CPU_AREA=y
> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
> CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
> CONFIG_ARCH_HIBERNATION_POSSIBLE=y
> CONFIG_ARCH_SUSPEND_POSSIBLE=y
> CONFIG_ZONE_DMA32=y
> CONFIG_ARCH_POPULATES_NODE_MAP=y
> CONFIG_AUDIT_ARCH=y
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
> CONFIG_HAVE_EARLY_RES=y
> CONFIG_GENERIC_HARDIRQS=y
> CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=y
> CONFIG_GENERIC_IRQ_PROBE=y
> CONFIG_GENERIC_PENDING_IRQ=y
> CONFIG_USE_GENERIC_SMP_HELPERS=y
> CONFIG_X86_64_SMP=y
> CONFIG_X86_HT=y
> CONFIG_X86_TRAMPOLINE=y
> CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
> # CONFIG_KTIME_SCALAR is not set
> CONFIG_ARCH_CPU_PROBE_RELEASE=y
> CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
> CONFIG_CONSTRUCTORS=y
> 
> #
> # General setup
> #
> CONFIG_EXPERIMENTAL=y
> CONFIG_LOCK_KERNEL=y
> CONFIG_INIT_ENV_ARG_LIMIT=32
> CONFIG_CROSS_COMPILE=""
> CONFIG_LOCALVERSION=""
> # CONFIG_LOCALVERSION_AUTO is not set
> CONFIG_HAVE_KERNEL_GZIP=y
> CONFIG_HAVE_KERNEL_BZIP2=y
> CONFIG_HAVE_KERNEL_LZMA=y
> CONFIG_HAVE_KERNEL_LZO=y
> CONFIG_KERNEL_GZIP=y
> # CONFIG_KERNEL_BZIP2 is not set
> # CONFIG_KERNEL_LZMA is not set
> # CONFIG_KERNEL_LZO is not set
> CONFIG_VERSION_SIGNATURE="Ubuntu 2.6.36-0.1-server 2.6.36-rc3"
> CONFIG_SWAP=y
> CONFIG_SYSVIPC=y
> CONFIG_SYSVIPC_SYSCTL=y
> CONFIG_POSIX_MQUEUE=y
> CONFIG_POSIX_MQUEUE_SYSCTL=y
> CONFIG_BSD_PROCESS_ACCT=y
> CONFIG_BSD_PROCESS_ACCT_V3=y
> CONFIG_TASKSTATS=y
> CONFIG_TASK_DELAY_ACCT=y
> CONFIG_TASK_XACCT=y
> CONFIG_TASK_IO_ACCOUNTING=y
> CONFIG_AUDIT=y
> CONFIG_AUDITSYSCALL=y
> CONFIG_AUDIT_WATCH=y
> CONFIG_AUDIT_TREE=y
> 
> #
> # RCU Subsystem
> #
> CONFIG_TREE_RCU=y
> # CONFIG_RCU_TRACE is not set
> CONFIG_RCU_FANOUT=64
> # CONFIG_RCU_FANOUT_EXACT is not set
> CONFIG_RCU_FAST_NO_HZ=y
> # CONFIG_TREE_RCU_TRACE is not set
> # CONFIG_IKCONFIG is not set
> CONFIG_LOG_BUF_SHIFT=18
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
> CONFIG_CGROUPS=y
> # CONFIG_CGROUP_DEBUG is not set
> CONFIG_CGROUP_NS=y
> CONFIG_CGROUP_FREEZER=y
> CONFIG_CGROUP_DEVICE=y
> CONFIG_CPUSETS=y
> CONFIG_PROC_PID_CPUSET=y
> CONFIG_CGROUP_CPUACCT=y
> CONFIG_RESOURCE_COUNTERS=y
> CONFIG_CGROUP_MEM_RES_CTLR=y
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
> CONFIG_CGROUP_SCHED=y
> CONFIG_FAIR_GROUP_SCHED=y
> CONFIG_RT_GROUP_SCHED=y
> # CONFIG_BLK_CGROUP is not set
> CONFIG_MM_OWNER=y
> # CONFIG_SYSFS_DEPRECATED_V2 is not set
> CONFIG_RELAY=y
> CONFIG_NAMESPACES=y
> CONFIG_UTS_NS=y
> CONFIG_IPC_NS=y
> CONFIG_USER_NS=y
> CONFIG_PID_NS=y
> CONFIG_NET_NS=y
> CONFIG_BLK_DEV_INITRD=y
> CONFIG_INITRAMFS_SOURCE=""
> CONFIG_RD_GZIP=y
> CONFIG_RD_BZIP2=y
> CONFIG_RD_LZMA=y
> CONFIG_RD_LZO=y
> # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
> CONFIG_SYSCTL=y
> CONFIG_ANON_INODES=y
> # CONFIG_EMBEDDED is not set
> CONFIG_UID16=y
> CONFIG_SYSCTL_SYSCALL=y
> CONFIG_KALLSYMS=y
> CONFIG_KALLSYMS_ALL=y
> # CONFIG_KALLSYMS_EXTRA_PASS is not set
> CONFIG_HOTPLUG=y
> CONFIG_PRINTK=y
> CONFIG_BUG=y
> CONFIG_ELF_CORE=y
> CONFIG_PCSPKR_PLATFORM=y
> CONFIG_BASE_FULL=y
> CONFIG_FUTEX=y
> CONFIG_EPOLL=y
> CONFIG_SIGNALFD=y
> CONFIG_TIMERFD=y
> CONFIG_EVENTFD=y
> CONFIG_SHMEM=y
> CONFIG_AIO=y
> CONFIG_HAVE_PERF_EVENTS=y
> 
> #
> # Kernel Performance Events And Counters
> #
> CONFIG_PERF_EVENTS=y
> CONFIG_PERF_COUNTERS=y
> # CONFIG_DEBUG_PERF_USE_VMALLOC is not set
> CONFIG_VM_EVENT_COUNTERS=y
> CONFIG_PCI_QUIRKS=y
> CONFIG_SLUB_DEBUG=y
> # CONFIG_COMPAT_BRK is not set
> # CONFIG_SLAB is not set
> CONFIG_SLUB=y
> CONFIG_PROFILING=y
> CONFIG_TRACEPOINTS=y
> CONFIG_OPROFILE=m
> # CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
> CONFIG_HAVE_OPROFILE=y
> CONFIG_KPROBES=y
> CONFIG_OPTPROBES=y
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
> CONFIG_KRETPROBES=y
> CONFIG_USER_RETURN_NOTIFIER=y
> CONFIG_HAVE_IOREMAP_PROT=y
> CONFIG_HAVE_KPROBES=y
> CONFIG_HAVE_KRETPROBES=y
> CONFIG_HAVE_OPTPROBES=y
> CONFIG_HAVE_ARCH_TRACEHOOK=y
> CONFIG_HAVE_DMA_ATTRS=y
> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
> CONFIG_HAVE_DMA_API_DEBUG=y
> CONFIG_HAVE_HW_BREAKPOINT=y
> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
> CONFIG_HAVE_USER_RETURN_NOTIFIER=y
> CONFIG_HAVE_PERF_EVENTS_NMI=y
> 
> #
> # GCOV-based kernel profiling
> #
> # CONFIG_GCOV_KERNEL is not set
> # CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
> CONFIG_SLABINFO=y
> CONFIG_RT_MUTEXES=y
> CONFIG_BASE_SMALL=0
> CONFIG_MODULES=y
> # CONFIG_MODULE_FORCE_LOAD is not set
> CONFIG_MODULE_UNLOAD=y
> # CONFIG_MODULE_FORCE_UNLOAD is not set
> CONFIG_MODVERSIONS=y
> CONFIG_MODULE_SRCVERSION_ALL=y
> CONFIG_STOP_MACHINE=y
> CONFIG_BLOCK=y
> CONFIG_BLK_DEV_BSG=y
> CONFIG_BLK_DEV_INTEGRITY=y
> CONFIG_BLOCK_COMPAT=y
> 
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=y
> CONFIG_IOSCHED_DEADLINE=y
> CONFIG_IOSCHED_CFQ=y
> CONFIG_DEFAULT_DEADLINE=y
> # CONFIG_DEFAULT_CFQ is not set
> # CONFIG_DEFAULT_NOOP is not set
> CONFIG_DEFAULT_IOSCHED="deadline"
> CONFIG_PREEMPT_NOTIFIERS=y
> CONFIG_PADATA=y
> # CONFIG_INLINE_SPIN_TRYLOCK is not set
> # CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
> # CONFIG_INLINE_SPIN_LOCK is not set
> # CONFIG_INLINE_SPIN_LOCK_BH is not set
> # CONFIG_INLINE_SPIN_LOCK_IRQ is not set
> # CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_SPIN_UNLOCK is not set
> # CONFIG_INLINE_SPIN_UNLOCK_BH is not set
> # CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
> # CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
> # CONFIG_INLINE_READ_TRYLOCK is not set
> # CONFIG_INLINE_READ_LOCK is not set
> # CONFIG_INLINE_READ_LOCK_BH is not set
> # CONFIG_INLINE_READ_LOCK_IRQ is not set
> # CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_READ_UNLOCK is not set
> # CONFIG_INLINE_READ_UNLOCK_BH is not set
> # CONFIG_INLINE_READ_UNLOCK_IRQ is not set
> # CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
> # CONFIG_INLINE_WRITE_TRYLOCK is not set
> # CONFIG_INLINE_WRITE_LOCK is not set
> # CONFIG_INLINE_WRITE_LOCK_BH is not set
> # CONFIG_INLINE_WRITE_LOCK_IRQ is not set
> # CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
> # CONFIG_INLINE_WRITE_UNLOCK is not set
> # CONFIG_INLINE_WRITE_UNLOCK_BH is not set
> # CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
> # CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
> # CONFIG_MUTEX_SPIN_ON_OWNER is not set
> CONFIG_FREEZER=y
> 
> #
> # Processor type and features
> #
> CONFIG_TICK_ONESHOT=y
> CONFIG_NO_HZ=y
> CONFIG_HIGH_RES_TIMERS=y
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
> CONFIG_SMP=y
> CONFIG_X86_X2APIC=y
> CONFIG_SPARSE_IRQ=y
> CONFIG_NUMA_IRQ_DESC=y
> CONFIG_X86_MPPARSE=y
> CONFIG_X86_EXTENDED_PLATFORM=y
> # CONFIG_X86_VSMP is not set
> # CONFIG_X86_UV is not set
> CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
> CONFIG_SCHED_OMIT_FRAME_POINTER=y
> CONFIG_PARAVIRT_GUEST=y
> CONFIG_XEN=y
> CONFIG_XEN_PVHVM=y
> CONFIG_XEN_MAX_DOMAIN_MEMORY=32
> CONFIG_XEN_SAVE_RESTORE=y
> # CONFIG_XEN_DEBUG_FS is not set
> CONFIG_KVM_CLOCK=y
> CONFIG_KVM_GUEST=y
> CONFIG_PARAVIRT=y
> CONFIG_PARAVIRT_SPINLOCKS=y
> CONFIG_PARAVIRT_CLOCK=y
> # CONFIG_PARAVIRT_DEBUG is not set
> CONFIG_NO_BOOTMEM=y
> # CONFIG_MEMTEST is not set
> # CONFIG_MK8 is not set
> # CONFIG_MPSC is not set
> # CONFIG_MCORE2 is not set
> # CONFIG_MATOM is not set
> CONFIG_GENERIC_CPU=y
> CONFIG_X86_CPU=y
> CONFIG_X86_INTERNODE_CACHE_SHIFT=7
> CONFIG_X86_CMPXCHG=y
> CONFIG_X86_L1_CACHE_SHIFT=6
> CONFIG_X86_XADD=y
> CONFIG_X86_WP_WORKS_OK=y
> CONFIG_X86_TSC=y
> CONFIG_X86_CMPXCHG64=y
> CONFIG_X86_CMOV=y
> CONFIG_X86_MINIMUM_CPU_FAMILY=64
> CONFIG_X86_DEBUGCTLMSR=y
> CONFIG_CPU_SUP_INTEL=y
> CONFIG_CPU_SUP_AMD=y
> CONFIG_CPU_SUP_CENTAUR=y
> CONFIG_HPET_TIMER=y
> CONFIG_HPET_EMULATE_RTC=y
> CONFIG_DMI=y
> CONFIG_GART_IOMMU=y
> CONFIG_CALGARY_IOMMU=y
> CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
> CONFIG_AMD_IOMMU=y
> CONFIG_AMD_IOMMU_STATS=y
> CONFIG_SWIOTLB=y
> CONFIG_IOMMU_HELPER=y
> CONFIG_IOMMU_API=y
> # CONFIG_MAXSMP is not set
> CONFIG_NR_CPUS=64
> CONFIG_SCHED_SMT=y
> CONFIG_SCHED_MC=y
> CONFIG_PREEMPT_NONE=y
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> CONFIG_X86_LOCAL_APIC=y
> CONFIG_X86_IO_APIC=y
> CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
> CONFIG_X86_MCE=y
> CONFIG_X86_MCE_INTEL=y
> CONFIG_X86_MCE_XEON75XX=m
> CONFIG_X86_MCE_AMD=y
> CONFIG_X86_MCE_THRESHOLD=y
> CONFIG_X86_MCE_INJECT=m
> CONFIG_X86_THERMAL_VECTOR=y
> CONFIG_I8K=m
> CONFIG_MICROCODE=m
> CONFIG_MICROCODE_INTEL=y
> CONFIG_MICROCODE_AMD=y
> CONFIG_MICROCODE_OLD_INTERFACE=y
> CONFIG_X86_MSR=m
> CONFIG_X86_CPUID=m
> CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
> CONFIG_DIRECT_GBPAGES=y
> CONFIG_NUMA=y
> CONFIG_K8_NUMA=y
> CONFIG_X86_64_ACPI_NUMA=y
> CONFIG_NODES_SPAN_OTHER_NODES=y
> # CONFIG_NUMA_EMU is not set
> CONFIG_NODES_SHIFT=6
> CONFIG_ARCH_PROC_KCORE_TEXT=y
> CONFIG_ARCH_SPARSEMEM_DEFAULT=y
> CONFIG_ARCH_SPARSEMEM_ENABLE=y
> CONFIG_ARCH_SELECT_MEMORY_MODEL=y
> CONFIG_ARCH_MEMORY_PROBE=y
> CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
> CONFIG_SELECT_MEMORY_MODEL=y
> CONFIG_SPARSEMEM_MANUAL=y
> CONFIG_SPARSEMEM=y
> CONFIG_NEED_MULTIPLE_NODES=y
> CONFIG_HAVE_MEMORY_PRESENT=y
> CONFIG_SPARSEMEM_EXTREME=y
> CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
> CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
> CONFIG_SPARSEMEM_VMEMMAP=y
> CONFIG_MEMORY_HOTPLUG=y
> CONFIG_MEMORY_HOTPLUG_SPARSE=y
> CONFIG_MEMORY_HOTREMOVE=y
> CONFIG_PAGEFLAGS_EXTENDED=y
> CONFIG_SPLIT_PTLOCK_CPUS=999999
> # CONFIG_COMPACTION is not set
> CONFIG_MIGRATION=y
> CONFIG_PHYS_ADDR_T_64BIT=y
> CONFIG_ZONE_DMA_FLAG=1
> CONFIG_BOUNCE=y
> CONFIG_VIRT_TO_BUS=y
> CONFIG_MMU_NOTIFIER=y
> CONFIG_KSM=y
> CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
> CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
> CONFIG_MEMORY_FAILURE=y
> # CONFIG_HWPOISON_INJECT is not set
> CONFIG_X86_CHECK_BIOS_CORRUPTION=y
> CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
> CONFIG_X86_RESERVE_LOW_64K=y
> CONFIG_MTRR=y
> CONFIG_MTRR_SANITIZER=y
> CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
> CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
> CONFIG_X86_PAT=y
> CONFIG_ARCH_USES_PG_UNCACHED=y
> CONFIG_EFI=y
> CONFIG_SECCOMP=y
> CONFIG_CC_STACKPROTECTOR=y
> CONFIG_HZ_100=y
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> # CONFIG_HZ_1000 is not set
> CONFIG_HZ=100
> CONFIG_SCHED_HRTICK=y
> CONFIG_KEXEC=y
> CONFIG_CRASH_DUMP=y
> CONFIG_KEXEC_JUMP=y
> CONFIG_PHYSICAL_START=0x200000
> CONFIG_RELOCATABLE=y
> CONFIG_PHYSICAL_ALIGN=0x1000000
> CONFIG_HOTPLUG_CPU=y
> # CONFIG_COMPAT_VDSO is not set
> # CONFIG_CMDLINE_BOOL is not set
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
> CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
> CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
> CONFIG_USE_PERCPU_NUMA_NODE_ID=y
> 
> #
> # Power management and ACPI options
> #
> CONFIG_ARCH_HIBERNATION_HEADER=y
> CONFIG_PM=y
> CONFIG_PM_DEBUG=y
> # CONFIG_PM_ADVANCED_DEBUG is not set
> # CONFIG_PM_VERBOSE is not set
> CONFIG_CAN_PM_TRACE=y
> CONFIG_PM_TRACE=y
> CONFIG_PM_TRACE_RTC=y
> CONFIG_PM_SLEEP_SMP=y
> CONFIG_PM_SLEEP=y
> CONFIG_SUSPEND_NVS=y
> CONFIG_SUSPEND=y
> CONFIG_PM_TEST_SUSPEND=y
> CONFIG_SUSPEND_FREEZER=y
> CONFIG_HIBERNATION=y
> CONFIG_PM_STD_PARTITION=""
> CONFIG_PM_RUNTIME=y
> CONFIG_PM_OPS=y
> CONFIG_ACPI=y
> CONFIG_ACPI_SLEEP=y
> CONFIG_ACPI_PROCFS=y
> CONFIG_ACPI_PROCFS_POWER=y
> CONFIG_ACPI_POWER_METER=m
> CONFIG_ACPI_SYSFS_POWER=y
> CONFIG_ACPI_EC_DEBUGFS=m
> CONFIG_ACPI_PROC_EVENT=y
> CONFIG_ACPI_AC=y
> CONFIG_ACPI_BATTERY=y
> CONFIG_ACPI_BUTTON=y
> CONFIG_ACPI_VIDEO=m
> CONFIG_ACPI_FAN=y
> CONFIG_ACPI_DOCK=y
> CONFIG_ACPI_PROCESSOR=y
> CONFIG_ACPI_HOTPLUG_CPU=y
> CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
> CONFIG_ACPI_THERMAL=y
> CONFIG_ACPI_NUMA=y
> CONFIG_ACPI_CUSTOM_DSDT_FILE=""
> # CONFIG_ACPI_CUSTOM_DSDT is not set
> CONFIG_ACPI_BLACKLIST_YEAR=0
> # CONFIG_ACPI_DEBUG is not set
> CONFIG_ACPI_PCI_SLOT=y
> CONFIG_X86_PM_TIMER=y
> CONFIG_ACPI_CONTAINER=y
> CONFIG_ACPI_HOTPLUG_MEMORY=m
> CONFIG_ACPI_SBS=y
> CONFIG_ACPI_HED=m
> CONFIG_ACPI_APEI=y
> CONFIG_ACPI_APEI_GHES=m
> CONFIG_ACPI_APEI_EINJ=m
> CONFIG_ACPI_APEI_ERST_DEBUG=m
> CONFIG_SFI=y
> 
> #
> # CPU Frequency scaling
> #
> CONFIG_CPU_FREQ=y
> CONFIG_CPU_FREQ_TABLE=y
> # CONFIG_CPU_FREQ_DEBUG is not set
> CONFIG_CPU_FREQ_STAT=y
> CONFIG_CPU_FREQ_STAT_DETAILS=y
> CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
> # CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
> CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
> CONFIG_CPU_FREQ_GOV_POWERSAVE=y
> CONFIG_CPU_FREQ_GOV_USERSPACE=y
> CONFIG_CPU_FREQ_GOV_ONDEMAND=y
> CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
> 
> #
> # CPUFreq processor drivers
> #
> CONFIG_X86_PCC_CPUFREQ=m
> CONFIG_X86_ACPI_CPUFREQ=y
> CONFIG_X86_POWERNOW_K8=y
> CONFIG_X86_SPEEDSTEP_CENTRINO=y
> CONFIG_X86_P4_CLOCKMOD=m
> 
> #
> # shared options
> #
> CONFIG_X86_SPEEDSTEP_LIB=m
> CONFIG_CPU_IDLE=y
> CONFIG_CPU_IDLE_GOV_LADDER=y
> CONFIG_CPU_IDLE_GOV_MENU=y
> CONFIG_INTEL_IDLE=y
> 
> #
> # Memory power savings
> #
> CONFIG_I7300_IDLE_IOAT_CHANNEL=y
> CONFIG_I7300_IDLE=m
> 
> #
> # Bus options (PCI etc.)
> #
> CONFIG_PCI=y
> CONFIG_PCI_DIRECT=y
> CONFIG_PCI_MMCONFIG=y
> CONFIG_PCI_DOMAINS=y
> CONFIG_PCI_CNB20LE_QUIRK=y
> # CONFIG_DMAR is not set
> CONFIG_INTR_REMAP=y
> CONFIG_PCIEPORTBUS=y
> CONFIG_HOTPLUG_PCI_PCIE=y
> CONFIG_PCIEAER=y
> # CONFIG_PCIE_ECRC is not set
> # CONFIG_PCIEAER_INJECT is not set
> CONFIG_PCIEASPM=y
> # CONFIG_PCIEASPM_DEBUG is not set
> CONFIG_PCIE_PME=y
> CONFIG_ARCH_SUPPORTS_MSI=y
> CONFIG_PCI_MSI=y
> # CONFIG_PCI_DEBUG is not set
> CONFIG_PCI_STUB=m
> CONFIG_HT_IRQ=y
> CONFIG_PCI_IOV=y
> CONFIG_PCI_IOAPIC=y
> CONFIG_ISA_DMA_API=y
> CONFIG_K8_NB=y
> CONFIG_PCCARD=m
> CONFIG_PCMCIA=m
> CONFIG_PCMCIA_LOAD_CIS=y
> CONFIG_CARDBUS=y
> 
> #
> # PC-card bridges
> #
> CONFIG_YENTA=m
> CONFIG_YENTA_O2=y
> CONFIG_YENTA_RICOH=y
> CONFIG_YENTA_TI=y
> CONFIG_YENTA_ENE_TUNE=y
> CONFIG_YENTA_TOSHIBA=y
> CONFIG_PD6729=m
> CONFIG_I82092=m
> CONFIG_PCCARD_NONSTATIC=y
> CONFIG_HOTPLUG_PCI=y
> CONFIG_HOTPLUG_PCI_FAKE=m
> CONFIG_HOTPLUG_PCI_ACPI=m
> CONFIG_HOTPLUG_PCI_ACPI_IBM=m
> CONFIG_HOTPLUG_PCI_CPCI=y
> CONFIG_HOTPLUG_PCI_CPCI_ZT5550=m
> CONFIG_HOTPLUG_PCI_CPCI_GENERIC=m
> CONFIG_HOTPLUG_PCI_SHPC=m
> 
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=y
> CONFIG_COMPAT_BINFMT_ELF=y
> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
> # CONFIG_HAVE_AOUT is not set
> CONFIG_BINFMT_MISC=m
> CONFIG_IA32_EMULATION=y
> # CONFIG_IA32_AOUT is not set
> CONFIG_COMPAT=y
> CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
> CONFIG_SYSVIPC_COMPAT=y
> CONFIG_NET=y
> CONFIG_COMPAT_NETLINK_MESSAGES=y
> 
> #
> # Networking options
> #
> CONFIG_PACKET=y
> CONFIG_UNIX=y
> CONFIG_XFRM=y
> CONFIG_XFRM_USER=m
> # CONFIG_XFRM_SUB_POLICY is not set
> # CONFIG_XFRM_MIGRATE is not set
> # CONFIG_XFRM_STATISTICS is not set
> CONFIG_XFRM_IPCOMP=m
> CONFIG_NET_KEY=m
> # CONFIG_NET_KEY_MIGRATE is not set
> CONFIG_INET=y
> CONFIG_IP_MULTICAST=y
> CONFIG_IP_ADVANCED_ROUTER=y
> CONFIG_ASK_IP_FIB_HASH=y
> # CONFIG_IP_FIB_TRIE is not set
> CONFIG_IP_FIB_HASH=y
> CONFIG_IP_MULTIPLE_TABLES=y
> CONFIG_IP_ROUTE_MULTIPATH=y
> CONFIG_IP_ROUTE_VERBOSE=y
> # CONFIG_IP_PNP is not set
> CONFIG_NET_IPIP=m
> CONFIG_NET_IPGRE=m
> CONFIG_NET_IPGRE_BROADCAST=y
> CONFIG_IP_MROUTE=y
> # CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
> CONFIG_IP_PIMSM_V1=y
> CONFIG_IP_PIMSM_V2=y
> # CONFIG_ARPD is not set
> CONFIG_SYN_COOKIES=y
> CONFIG_INET_AH=m
> CONFIG_INET_ESP=m
> CONFIG_INET_IPCOMP=m
> CONFIG_INET_XFRM_TUNNEL=m
> CONFIG_INET_TUNNEL=m
> CONFIG_INET_XFRM_MODE_TRANSPORT=m
> CONFIG_INET_XFRM_MODE_TUNNEL=m
> CONFIG_INET_XFRM_MODE_BEET=m
> CONFIG_INET_LRO=y
> CONFIG_INET_DIAG=y
> CONFIG_INET_TCP_DIAG=y
> CONFIG_TCP_CONG_ADVANCED=y
> CONFIG_TCP_CONG_BIC=m
> CONFIG_TCP_CONG_CUBIC=y
> CONFIG_TCP_CONG_WESTWOOD=m
> CONFIG_TCP_CONG_HTCP=m
> CONFIG_TCP_CONG_HSTCP=m
> CONFIG_TCP_CONG_HYBLA=m
> CONFIG_TCP_CONG_VEGAS=m
> CONFIG_TCP_CONG_SCALABLE=m
> CONFIG_TCP_CONG_LP=m
> CONFIG_TCP_CONG_VENO=m
> CONFIG_TCP_CONG_YEAH=m
> CONFIG_TCP_CONG_ILLINOIS=m
> CONFIG_DEFAULT_CUBIC=y
> # CONFIG_DEFAULT_RENO is not set
> CONFIG_DEFAULT_TCP_CONG="cubic"
> CONFIG_TCP_MD5SIG=y
> CONFIG_IPV6=y
> CONFIG_IPV6_PRIVACY=y
> # CONFIG_IPV6_ROUTER_PREF is not set
> # CONFIG_IPV6_OPTIMISTIC_DAD is not set
> CONFIG_INET6_AH=m
> CONFIG_INET6_ESP=m
> CONFIG_INET6_IPCOMP=m
> # CONFIG_IPV6_MIP6 is not set
> CONFIG_INET6_XFRM_TUNNEL=m
> CONFIG_INET6_TUNNEL=m
> CONFIG_INET6_XFRM_MODE_TRANSPORT=m
> CONFIG_INET6_XFRM_MODE_TUNNEL=m
> CONFIG_INET6_XFRM_MODE_BEET=m
> CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
> CONFIG_IPV6_SIT=m
> CONFIG_IPV6_SIT_6RD=y
> CONFIG_IPV6_NDISC_NODETYPE=y
> CONFIG_IPV6_TUNNEL=m
> CONFIG_IPV6_MULTIPLE_TABLES=y
> # CONFIG_IPV6_SUBTREES is not set
> # CONFIG_IPV6_MROUTE is not set
> CONFIG_NETLABEL=y
> CONFIG_NETWORK_SECMARK=y
> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
> CONFIG_NETFILTER=y
> # CONFIG_NETFILTER_DEBUG is not set
> CONFIG_NETFILTER_ADVANCED=y
> CONFIG_BRIDGE_NETFILTER=y
> 
> #
> # Core Netfilter Configuration
> #
> CONFIG_NETFILTER_NETLINK=m
> CONFIG_NETFILTER_NETLINK_QUEUE=m
> CONFIG_NETFILTER_NETLINK_LOG=m
> CONFIG_NF_CONNTRACK=m
> CONFIG_NF_CONNTRACK_MARK=y
> CONFIG_NF_CONNTRACK_SECMARK=y
> CONFIG_NF_CONNTRACK_ZONES=y
> CONFIG_NF_CONNTRACK_EVENTS=y
> CONFIG_NF_CT_PROTO_DCCP=m
> CONFIG_NF_CT_PROTO_GRE=m
> CONFIG_NF_CT_PROTO_SCTP=m
> CONFIG_NF_CT_PROTO_UDPLITE=m
> CONFIG_NF_CONNTRACK_AMANDA=m
> CONFIG_NF_CONNTRACK_FTP=m
> CONFIG_NF_CONNTRACK_H323=m
> CONFIG_NF_CONNTRACK_IRC=m
> CONFIG_NF_CONNTRACK_NETBIOS_NS=m
> CONFIG_NF_CONNTRACK_PPTP=m
> CONFIG_NF_CONNTRACK_SANE=m
> CONFIG_NF_CONNTRACK_SIP=m
> CONFIG_NF_CONNTRACK_TFTP=m
> CONFIG_NF_CT_NETLINK=m
> CONFIG_NETFILTER_TPROXY=m
> CONFIG_NETFILTER_XTABLES=m
> 
> #
> # Xtables combined modules
> #
> CONFIG_NETFILTER_XT_MARK=m
> CONFIG_NETFILTER_XT_CONNMARK=m
> 
> #
> # Xtables targets
> #
> CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
> CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
> CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
> CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
> CONFIG_NETFILTER_XT_TARGET_CT=m
> CONFIG_NETFILTER_XT_TARGET_DSCP=m
> CONFIG_NETFILTER_XT_TARGET_HL=m
> CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
> CONFIG_NETFILTER_XT_TARGET_LED=m
> CONFIG_NETFILTER_XT_TARGET_MARK=m
> CONFIG_NETFILTER_XT_TARGET_NFLOG=m
> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
> CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
> CONFIG_NETFILTER_XT_TARGET_RATEEST=m
> CONFIG_NETFILTER_XT_TARGET_TEE=m
> CONFIG_NETFILTER_XT_TARGET_TPROXY=m
> CONFIG_NETFILTER_XT_TARGET_TRACE=m
> CONFIG_NETFILTER_XT_TARGET_SECMARK=m
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
> # CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set
> 
> #
> # Xtables matches
> #
> CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
> CONFIG_NETFILTER_XT_MATCH_COMMENT=m
> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
> CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
> CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
> CONFIG_NETFILTER_XT_MATCH_CPU=m
> CONFIG_NETFILTER_XT_MATCH_DCCP=m
> CONFIG_NETFILTER_XT_MATCH_DSCP=m
> CONFIG_NETFILTER_XT_MATCH_ESP=m
> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
> CONFIG_NETFILTER_XT_MATCH_HELPER=m
> CONFIG_NETFILTER_XT_MATCH_HL=m
> CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
> CONFIG_NETFILTER_XT_MATCH_IPVS=m
> CONFIG_NETFILTER_XT_MATCH_LENGTH=m
> CONFIG_NETFILTER_XT_MATCH_LIMIT=m
> CONFIG_NETFILTER_XT_MATCH_MAC=m
> CONFIG_NETFILTER_XT_MATCH_MARK=m
> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
> CONFIG_NETFILTER_XT_MATCH_OSF=m
> CONFIG_NETFILTER_XT_MATCH_OWNER=m
> CONFIG_NETFILTER_XT_MATCH_POLICY=m
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
> CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
> CONFIG_NETFILTER_XT_MATCH_QUOTA=m
> CONFIG_NETFILTER_XT_MATCH_RATEEST=m
> CONFIG_NETFILTER_XT_MATCH_REALM=m
> CONFIG_NETFILTER_XT_MATCH_RECENT=m
> CONFIG_NETFILTER_XT_MATCH_SCTP=m
> CONFIG_NETFILTER_XT_MATCH_SOCKET=m
> CONFIG_NETFILTER_XT_MATCH_STATE=m
> CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
> CONFIG_NETFILTER_XT_MATCH_STRING=m
> CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
> CONFIG_NETFILTER_XT_MATCH_TIME=m
> CONFIG_NETFILTER_XT_MATCH_U32=m
> CONFIG_IP_VS=m
> CONFIG_IP_VS_IPV6=y
> # CONFIG_IP_VS_DEBUG is not set
> CONFIG_IP_VS_TAB_BITS=12
> 
> #
> # IPVS transport protocol load balancing support
> #
> CONFIG_IP_VS_PROTO_TCP=y
> CONFIG_IP_VS_PROTO_UDP=y
> CONFIG_IP_VS_PROTO_AH_ESP=y
> CONFIG_IP_VS_PROTO_ESP=y
> CONFIG_IP_VS_PROTO_AH=y
> CONFIG_IP_VS_PROTO_SCTP=y
> 
> #
> # IPVS scheduler
> #
> CONFIG_IP_VS_RR=m
> CONFIG_IP_VS_WRR=m
> CONFIG_IP_VS_LC=m
> CONFIG_IP_VS_WLC=m
> CONFIG_IP_VS_LBLC=m
> CONFIG_IP_VS_LBLCR=m
> CONFIG_IP_VS_DH=m
> CONFIG_IP_VS_SH=m
> CONFIG_IP_VS_SED=m
> CONFIG_IP_VS_NQ=m
> 
> #
> # IPVS application helper
> #
> CONFIG_IP_VS_FTP=m
> 
> #
> # IP: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV4=m
> CONFIG_NF_CONNTRACK_IPV4=m
> CONFIG_NF_CONNTRACK_PROC_COMPAT=y
> CONFIG_IP_NF_QUEUE=m
> CONFIG_IP_NF_IPTABLES=m
> CONFIG_IP_NF_MATCH_ADDRTYPE=m
> CONFIG_IP_NF_MATCH_AH=m
> CONFIG_IP_NF_MATCH_ECN=m
> CONFIG_IP_NF_MATCH_TTL=m
> CONFIG_IP_NF_FILTER=m
> CONFIG_IP_NF_TARGET_REJECT=m
> CONFIG_IP_NF_TARGET_LOG=m
> CONFIG_IP_NF_TARGET_ULOG=m
> CONFIG_NF_NAT=m
> CONFIG_NF_NAT_NEEDED=y
> CONFIG_IP_NF_TARGET_MASQUERADE=m
> CONFIG_IP_NF_TARGET_NETMAP=m
> CONFIG_IP_NF_TARGET_REDIRECT=m
> CONFIG_NF_NAT_SNMP_BASIC=m
> CONFIG_NF_NAT_PROTO_DCCP=m
> CONFIG_NF_NAT_PROTO_GRE=m
> CONFIG_NF_NAT_PROTO_UDPLITE=m
> CONFIG_NF_NAT_PROTO_SCTP=m
> CONFIG_NF_NAT_FTP=m
> CONFIG_NF_NAT_IRC=m
> CONFIG_NF_NAT_TFTP=m
> CONFIG_NF_NAT_AMANDA=m
> CONFIG_NF_NAT_PPTP=m
> CONFIG_NF_NAT_H323=m
> CONFIG_NF_NAT_SIP=m
> CONFIG_IP_NF_MANGLE=m
> CONFIG_IP_NF_TARGET_CLUSTERIP=m
> CONFIG_IP_NF_TARGET_ECN=m
> CONFIG_IP_NF_TARGET_TTL=m
> CONFIG_IP_NF_RAW=m
> CONFIG_IP_NF_SECURITY=m
> CONFIG_IP_NF_ARPTABLES=m
> CONFIG_IP_NF_ARPFILTER=m
> CONFIG_IP_NF_ARP_MANGLE=m
> 
> #
> # IPv6: Netfilter Configuration
> #
> CONFIG_NF_CONNTRACK_IPV6=m
> CONFIG_IP6_NF_QUEUE=m
> CONFIG_IP6_NF_IPTABLES=m
> CONFIG_IP6_NF_MATCH_AH=m
> CONFIG_IP6_NF_MATCH_EUI64=m
> CONFIG_IP6_NF_MATCH_FRAG=m
> CONFIG_IP6_NF_MATCH_OPTS=m
> CONFIG_IP6_NF_MATCH_HL=m
> CONFIG_IP6_NF_MATCH_IPV6HEADER=m
> CONFIG_IP6_NF_MATCH_MH=m
> CONFIG_IP6_NF_MATCH_RT=m
> CONFIG_IP6_NF_TARGET_HL=m
> CONFIG_IP6_NF_TARGET_LOG=m
> CONFIG_IP6_NF_FILTER=m
> CONFIG_IP6_NF_TARGET_REJECT=m
> CONFIG_IP6_NF_MANGLE=m
> CONFIG_IP6_NF_RAW=m
> CONFIG_IP6_NF_SECURITY=m
> 
> #
> # DECnet: Netfilter Configuration
> #
> CONFIG_DECNET_NF_GRABULATOR=m
> CONFIG_BRIDGE_NF_EBTABLES=m
> CONFIG_BRIDGE_EBT_BROUTE=m
> CONFIG_BRIDGE_EBT_T_FILTER=m
> CONFIG_BRIDGE_EBT_T_NAT=m
> CONFIG_BRIDGE_EBT_802_3=m
> CONFIG_BRIDGE_EBT_AMONG=m
> CONFIG_BRIDGE_EBT_ARP=m
> CONFIG_BRIDGE_EBT_IP=m
> CONFIG_BRIDGE_EBT_IP6=m
> CONFIG_BRIDGE_EBT_LIMIT=m
> CONFIG_BRIDGE_EBT_MARK=m
> CONFIG_BRIDGE_EBT_PKTTYPE=m
> CONFIG_BRIDGE_EBT_STP=m
> CONFIG_BRIDGE_EBT_VLAN=m
> CONFIG_BRIDGE_EBT_ARPREPLY=m
> CONFIG_BRIDGE_EBT_DNAT=m
> CONFIG_BRIDGE_EBT_MARK_T=m
> CONFIG_BRIDGE_EBT_REDIRECT=m
> CONFIG_BRIDGE_EBT_SNAT=m
> CONFIG_BRIDGE_EBT_LOG=m
> CONFIG_BRIDGE_EBT_ULOG=m
> CONFIG_BRIDGE_EBT_NFLOG=m
> CONFIG_IP_DCCP=m
> CONFIG_INET_DCCP_DIAG=m
> 
> #
> # DCCP CCIDs Configuration (EXPERIMENTAL)
> #
> # CONFIG_IP_DCCP_CCID2_DEBUG is not set
> CONFIG_IP_DCCP_CCID3=y
> # CONFIG_IP_DCCP_CCID3_DEBUG is not set
> CONFIG_IP_DCCP_CCID3_RTO=100
> CONFIG_IP_DCCP_TFRC_LIB=y
> 
> #
> # DCCP Kernel Hacking
> #
> # CONFIG_IP_DCCP_DEBUG is not set
> CONFIG_NET_DCCPPROBE=m
> CONFIG_IP_SCTP=m
> CONFIG_NET_SCTPPROBE=m
> # CONFIG_SCTP_DBG_MSG is not set
> # CONFIG_SCTP_DBG_OBJCNT is not set
> # CONFIG_SCTP_HMAC_NONE is not set
> # CONFIG_SCTP_HMAC_SHA1 is not set
> CONFIG_SCTP_HMAC_MD5=y
> CONFIG_RDS=m
> CONFIG_RDS_RDMA=m
> CONFIG_RDS_TCP=m
> # CONFIG_RDS_DEBUG is not set
> CONFIG_TIPC=m
> # CONFIG_TIPC_ADVANCED is not set
> # CONFIG_TIPC_DEBUG is not set
> CONFIG_ATM=m
> CONFIG_ATM_CLIP=m
> # CONFIG_ATM_CLIP_NO_ICMP is not set
> CONFIG_ATM_LANE=m
> CONFIG_ATM_MPOA=m
> CONFIG_ATM_BR2684=m
> # CONFIG_ATM_BR2684_IPFILTER is not set
> CONFIG_L2TP=m
> CONFIG_L2TP_DEBUGFS=m
> # CONFIG_L2TP_V3 is not set
> CONFIG_STP=m
> CONFIG_GARP=m
> CONFIG_BRIDGE=m
> CONFIG_BRIDGE_IGMP_SNOOPING=y
> CONFIG_NET_DSA=y
> CONFIG_NET_DSA_TAG_DSA=y
> CONFIG_NET_DSA_TAG_EDSA=y
> CONFIG_NET_DSA_TAG_TRAILER=y
> CONFIG_NET_DSA_MV88E6XXX=y
> CONFIG_NET_DSA_MV88E6060=y
> CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
> CONFIG_NET_DSA_MV88E6131=y
> CONFIG_NET_DSA_MV88E6123_61_65=y
> CONFIG_VLAN_8021Q=m
> CONFIG_VLAN_8021Q_GVRP=y
> CONFIG_DECNET=m
> # CONFIG_DECNET_ROUTER is not set
> CONFIG_LLC=y
> CONFIG_LLC2=m
> CONFIG_IPX=m
> # CONFIG_IPX_INTERN is not set
> CONFIG_ATALK=m
> CONFIG_DEV_APPLETALK=m
> CONFIG_IPDDP=m
> CONFIG_IPDDP_ENCAP=y
> CONFIG_IPDDP_DECAP=y
> CONFIG_X25=m
> CONFIG_LAPB=m
> CONFIG_ECONET=m
> CONFIG_ECONET_AUNUDP=y
> CONFIG_ECONET_NATIVE=y
> CONFIG_WAN_ROUTER=m
> CONFIG_PHONET=m
> CONFIG_IEEE802154=m
> CONFIG_NET_SCHED=y
> 
> #
> # Queueing/Scheduling
> #
> CONFIG_NET_SCH_CBQ=m
> CONFIG_NET_SCH_HTB=m
> CONFIG_NET_SCH_HFSC=m
> CONFIG_NET_SCH_ATM=m
> CONFIG_NET_SCH_PRIO=m
> CONFIG_NET_SCH_MULTIQ=m
> CONFIG_NET_SCH_RED=m
> CONFIG_NET_SCH_SFQ=m
> CONFIG_NET_SCH_TEQL=m
> CONFIG_NET_SCH_TBF=m
> CONFIG_NET_SCH_GRED=m
> CONFIG_NET_SCH_DSMARK=m
> CONFIG_NET_SCH_NETEM=m
> CONFIG_NET_SCH_DRR=m
> CONFIG_NET_SCH_INGRESS=m
> 
> #
> # Classification
> #
> CONFIG_NET_CLS=y
> CONFIG_NET_CLS_BASIC=m
> CONFIG_NET_CLS_TCINDEX=m
> CONFIG_NET_CLS_ROUTE4=m
> CONFIG_NET_CLS_ROUTE=y
> CONFIG_NET_CLS_FW=m
> CONFIG_NET_CLS_U32=m
> # CONFIG_CLS_U32_PERF is not set
> CONFIG_CLS_U32_MARK=y
> CONFIG_NET_CLS_RSVP=m
> CONFIG_NET_CLS_RSVP6=m
> CONFIG_NET_CLS_FLOW=m
> CONFIG_NET_CLS_CGROUP=y
> CONFIG_NET_EMATCH=y
> CONFIG_NET_EMATCH_STACK=32
> CONFIG_NET_EMATCH_CMP=m
> CONFIG_NET_EMATCH_NBYTE=m
> CONFIG_NET_EMATCH_U32=m
> CONFIG_NET_EMATCH_META=m
> CONFIG_NET_EMATCH_TEXT=m
> CONFIG_NET_CLS_ACT=y
> CONFIG_NET_ACT_POLICE=m
> CONFIG_NET_ACT_GACT=m
> CONFIG_GACT_PROB=y
> CONFIG_NET_ACT_MIRRED=m
> CONFIG_NET_ACT_IPT=m
> CONFIG_NET_ACT_NAT=m
> CONFIG_NET_ACT_PEDIT=m
> CONFIG_NET_ACT_SIMP=m
> CONFIG_NET_ACT_SKBEDIT=m
> # CONFIG_NET_CLS_IND is not set
> CONFIG_NET_SCH_FIFO=y
> CONFIG_DCB=y
> CONFIG_DNS_RESOLVER=y
> CONFIG_RPS=y
> 
> #
> # Network testing
> #
> CONFIG_NET_PKTGEN=m
> CONFIG_NET_TCPPROBE=m
> # CONFIG_NET_DROP_MONITOR is not set
> CONFIG_HAMRADIO=y
> 
> #
> # Packet Radio protocols
> #
> CONFIG_AX25=m
> CONFIG_AX25_DAMA_SLAVE=y
> CONFIG_NETROM=m
> CONFIG_ROSE=m
> 
> #
> # AX.25 network device drivers
> #
> CONFIG_MKISS=m
> CONFIG_6PACK=m
> CONFIG_BPQETHER=m
> CONFIG_BAYCOM_SER_FDX=m
> CONFIG_BAYCOM_SER_HDX=m
> CONFIG_BAYCOM_PAR=m
> CONFIG_YAM=m
> CONFIG_CAN=m
> CONFIG_CAN_RAW=m
> CONFIG_CAN_BCM=m
> 
> #
> # CAN Device Drivers
> #
> CONFIG_CAN_VCAN=m
> CONFIG_CAN_DEV=m
> # CONFIG_CAN_CALC_BITTIMING is not set
> CONFIG_CAN_MCP251X=m
> CONFIG_CAN_JANZ_ICAN3=m
> CONFIG_CAN_SJA1000=m
> CONFIG_CAN_SJA1000_PLATFORM=m
> CONFIG_CAN_EMS_PCI=m
> CONFIG_CAN_KVASER_PCI=m
> CONFIG_CAN_PLX_PCI=m
> 
> #
> # CAN USB interfaces
> #
> CONFIG_CAN_EMS_USB=m
> CONFIG_CAN_ESD_USB2=m
> # CONFIG_CAN_DEBUG_DEVICES is not set
> CONFIG_IRDA=m
> 
> #
> # IrDA protocols
> #
> CONFIG_IRLAN=m
> CONFIG_IRNET=m
> CONFIG_IRCOMM=m
> CONFIG_IRDA_ULTRA=y
> 
> #
> # IrDA options
> #
> CONFIG_IRDA_CACHE_LAST_LSAP=y
> CONFIG_IRDA_FAST_RR=y
> CONFIG_IRDA_DEBUG=y
> 
> #
> # Infrared-port device drivers
> #
> 
> #
> # SIR device drivers
> #
> CONFIG_IRTTY_SIR=m
> 
> #
> # Dongle support
> #
> CONFIG_DONGLE=y
> CONFIG_ESI_DONGLE=m
> CONFIG_ACTISYS_DONGLE=m
> CONFIG_TEKRAM_DONGLE=m
> CONFIG_TOIM3232_DONGLE=m
> CONFIG_LITELINK_DONGLE=m
> CONFIG_MA600_DONGLE=m
> CONFIG_GIRBIL_DONGLE=m
> CONFIG_MCP2120_DONGLE=m
> CONFIG_OLD_BELKIN_DONGLE=m
> CONFIG_ACT200L_DONGLE=m
> CONFIG_KINGSUN_DONGLE=m
> CONFIG_KSDAZZLE_DONGLE=m
> CONFIG_KS959_DONGLE=m
> 
> #
> # FIR device drivers
> #
> CONFIG_USB_IRDA=m
> CONFIG_SIGMATEL_FIR=m
> CONFIG_NSC_FIR=m
> CONFIG_WINBOND_FIR=m
> CONFIG_SMC_IRCC_FIR=m
> CONFIG_ALI_FIR=m
> CONFIG_VLSI_FIR=m
> CONFIG_VIA_FIR=m
> CONFIG_MCS_FIR=m
> CONFIG_BT=m
> CONFIG_BT_L2CAP=m
> CONFIG_BT_SCO=m
> CONFIG_BT_RFCOMM=m
> CONFIG_BT_RFCOMM_TTY=y
> CONFIG_BT_BNEP=m
> CONFIG_BT_BNEP_MC_FILTER=y
> CONFIG_BT_BNEP_PROTO_FILTER=y
> CONFIG_BT_CMTP=m
> CONFIG_BT_HIDP=m
> 
> #
> # Bluetooth device drivers
> #
> CONFIG_BT_HCIBTUSB=m
> CONFIG_BT_HCIBTSDIO=m
> CONFIG_BT_HCIUART=m
> CONFIG_BT_HCIUART_H4=y
> CONFIG_BT_HCIUART_BCSP=y
> CONFIG_BT_HCIUART_ATH3K=y
> CONFIG_BT_HCIUART_LL=y
> CONFIG_BT_HCIBCM203X=m
> CONFIG_BT_HCIBPA10X=m
> CONFIG_BT_HCIBFUSB=m
> CONFIG_BT_HCIDTL1=m
> CONFIG_BT_HCIBT3C=m
> CONFIG_BT_HCIBLUECARD=m
> CONFIG_BT_HCIBTUART=m
> CONFIG_BT_HCIVHCI=m
> CONFIG_BT_MRVL=m
> CONFIG_BT_MRVL_SDIO=m
> CONFIG_BT_ATH3K=m
> CONFIG_AF_RXRPC=m
> # CONFIG_AF_RXRPC_DEBUG is not set
> CONFIG_RXKAD=m
> CONFIG_FIB_RULES=y
> CONFIG_WIRELESS=y
> CONFIG_WIRELESS_EXT=y
> CONFIG_WEXT_CORE=y
> CONFIG_WEXT_PROC=y
> CONFIG_WEXT_SPY=y
> CONFIG_WEXT_PRIV=y
> CONFIG_CFG80211=m
> CONFIG_NL80211_TESTMODE=y
> # CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
> CONFIG_CFG80211_REG_DEBUG=y
> CONFIG_CFG80211_DEFAULT_PS=y
> CONFIG_CFG80211_DEBUGFS=y
> # CONFIG_CFG80211_INTERNAL_REGDB is not set
> CONFIG_CFG80211_WEXT=y
> CONFIG_WIRELESS_EXT_SYSFS=y
> CONFIG_LIB80211=m
> CONFIG_LIB80211_CRYPT_WEP=m
> CONFIG_LIB80211_CRYPT_CCMP=m
> CONFIG_LIB80211_CRYPT_TKIP=m
> # CONFIG_LIB80211_DEBUG is not set
> CONFIG_MAC80211=m
> CONFIG_MAC80211_HAS_RC=y
> CONFIG_MAC80211_RC_MINSTREL=y
> CONFIG_MAC80211_RC_MINSTREL_HT=y
> CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
> CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
> CONFIG_MAC80211_MESH=y
> CONFIG_MAC80211_LEDS=y
> CONFIG_MAC80211_DEBUGFS=y
> # CONFIG_MAC80211_DEBUG_MENU is not set
> CONFIG_WIMAX=m
> CONFIG_WIMAX_DEBUG_LEVEL=8
> CONFIG_RFKILL=y
> CONFIG_RFKILL_LEDS=y
> CONFIG_RFKILL_INPUT=y
> CONFIG_NET_9P=m
> CONFIG_NET_9P_VIRTIO=m
> CONFIG_NET_9P_RDMA=m
> # CONFIG_NET_9P_DEBUG is not set
> CONFIG_CAIF=m
> # CONFIG_CAIF_DEBUG is not set
> CONFIG_CAIF_NETDEV=m
> 
> #
> # Device Drivers
> #
> 
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH=""
> CONFIG_DEVTMPFS=y
> CONFIG_DEVTMPFS_MOUNT=y
> # CONFIG_STANDALONE is not set
> CONFIG_PREVENT_FIRMWARE_BUILD=y
> CONFIG_FW_LOADER=y
> CONFIG_FIRMWARE_IN_KERNEL=y
> CONFIG_EXTRA_FIRMWARE=""
> # CONFIG_DEBUG_DRIVER is not set
> # CONFIG_DEBUG_DEVRES is not set
> CONFIG_SYS_HYPERVISOR=y
> CONFIG_SR_REPORT_TIME_LIMIT=100
> CONFIG_CONNECTOR=y
> CONFIG_PROC_EVENTS=y
> CONFIG_MTD=m
> # CONFIG_MTD_DEBUG is not set
> CONFIG_MTD_TESTS=m
> CONFIG_MTD_CONCAT=m
> CONFIG_MTD_PARTITIONS=y
> CONFIG_MTD_REDBOOT_PARTS=m
> CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
> # CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
> # CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
> CONFIG_MTD_AR7_PARTS=m
> 
> #
> # User Modules And Translation Layers
> #
> CONFIG_MTD_CHAR=m
> CONFIG_HAVE_MTD_OTP=y
> CONFIG_MTD_BLKDEVS=m
> CONFIG_MTD_BLOCK=m
> CONFIG_MTD_BLOCK_RO=m
> CONFIG_FTL=m
> CONFIG_NFTL=m
> CONFIG_NFTL_RW=y
> CONFIG_INFTL=m
> CONFIG_RFD_FTL=m
> CONFIG_SSFDC=m
> CONFIG_SM_FTL=m
> CONFIG_MTD_OOPS=m
> 
> #
> # RAM/ROM/Flash chip drivers
> #
> CONFIG_MTD_CFI=m
> CONFIG_MTD_JEDECPROBE=m
> CONFIG_MTD_GEN_PROBE=m
> # CONFIG_MTD_CFI_ADV_OPTIONS is not set
> CONFIG_MTD_MAP_BANK_WIDTH_1=y
> CONFIG_MTD_MAP_BANK_WIDTH_2=y
> CONFIG_MTD_MAP_BANK_WIDTH_4=y
> # CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
> # CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
> # CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
> CONFIG_MTD_CFI_I1=y
> CONFIG_MTD_CFI_I2=y
> # CONFIG_MTD_CFI_I4 is not set
> # CONFIG_MTD_CFI_I8 is not set
> CONFIG_MTD_CFI_INTELEXT=m
> CONFIG_MTD_CFI_AMDSTD=m
> CONFIG_MTD_CFI_STAA=m
> CONFIG_MTD_CFI_UTIL=m
> CONFIG_MTD_RAM=m
> CONFIG_MTD_ROM=m
> CONFIG_MTD_ABSENT=m
> 
> #
> # Mapping drivers for chip access
> #
> CONFIG_MTD_COMPLEX_MAPPINGS=y
> CONFIG_MTD_PHYSMAP=m
> # CONFIG_MTD_PHYSMAP_COMPAT is not set
> CONFIG_MTD_SC520CDP=m
> CONFIG_MTD_NETSC520=m
> CONFIG_MTD_TS5500=m
> CONFIG_MTD_SBC_GXX=m
> CONFIG_MTD_AMD76XROM=m
> CONFIG_MTD_ICHXROM=m
> CONFIG_MTD_ESB2ROM=m
> CONFIG_MTD_CK804XROM=m
> CONFIG_MTD_SCB2_FLASH=m
> CONFIG_MTD_NETtel=m
> CONFIG_MTD_L440GX=m
> CONFIG_MTD_PCI=m
> CONFIG_MTD_PCMCIA=m
> # CONFIG_MTD_PCMCIA_ANONYMOUS is not set
> CONFIG_MTD_GPIO_ADDR=m
> CONFIG_MTD_INTEL_VR_NOR=m
> CONFIG_MTD_PLATRAM=m
> 
> #
> # Self-contained MTD device drivers
> #
> CONFIG_MTD_PMC551=m
> # CONFIG_MTD_PMC551_BUGFIX is not set
> # CONFIG_MTD_PMC551_DEBUG is not set
> CONFIG_MTD_DATAFLASH=m
> # CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
> CONFIG_MTD_DATAFLASH_OTP=y
> CONFIG_MTD_M25P80=m
> CONFIG_M25PXX_USE_FAST_READ=y
> CONFIG_MTD_SST25L=m
> CONFIG_MTD_SLRAM=m
> CONFIG_MTD_PHRAM=m
> CONFIG_MTD_MTDRAM=m
> CONFIG_MTDRAM_TOTAL_SIZE=4096
> CONFIG_MTDRAM_ERASE_SIZE=128
> CONFIG_MTD_BLOCK2MTD=m
> 
> #
> # Disk-On-Chip Device Drivers
> #
> CONFIG_MTD_DOC2000=m
> CONFIG_MTD_DOC2001=m
> CONFIG_MTD_DOC2001PLUS=m
> CONFIG_MTD_DOCPROBE=m
> CONFIG_MTD_DOCECC=m
> # CONFIG_MTD_DOCPROBE_ADVANCED is not set
> CONFIG_MTD_DOCPROBE_ADDRESS=0
> CONFIG_MTD_NAND_ECC=m
> # CONFIG_MTD_NAND_ECC_SMC is not set
> CONFIG_MTD_NAND=m
> # CONFIG_MTD_NAND_VERIFY_WRITE is not set
> CONFIG_MTD_SM_COMMON=m
> # CONFIG_MTD_NAND_MUSEUM_IDS is not set
> CONFIG_MTD_NAND_DENALI=m
> CONFIG_MTD_NAND_DENALI_SCRATCH_REG_ADDR=0xFF108018
> CONFIG_MTD_NAND_IDS=m
> CONFIG_MTD_NAND_RICOH=m
> CONFIG_MTD_NAND_DISKONCHIP=m
> # CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
> CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
> # CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
> CONFIG_MTD_NAND_CAFE=m
> CONFIG_MTD_NAND_NANDSIM=m
> CONFIG_MTD_NAND_PLATFORM=m
> CONFIG_MTD_ALAUDA=m
> CONFIG_MTD_ONENAND=m
> CONFIG_MTD_ONENAND_VERIFY_WRITE=y
> CONFIG_MTD_ONENAND_GENERIC=m
> # CONFIG_MTD_ONENAND_OTP is not set
> CONFIG_MTD_ONENAND_2X_PROGRAM=y
> CONFIG_MTD_ONENAND_SIM=m
> 
> #
> # LPDDR flash memory drivers
> #
> CONFIG_MTD_LPDDR=m
> CONFIG_MTD_QINFO_PROBE=m
> 
> #
> # UBI - Unsorted block images
> #
> CONFIG_MTD_UBI=m
> CONFIG_MTD_UBI_WL_THRESHOLD=4096
> CONFIG_MTD_UBI_BEB_RESERVE=1
> CONFIG_MTD_UBI_GLUEBI=m
> 
> #
> # UBI debugging options
> #
> # CONFIG_MTD_UBI_DEBUG is not set
> CONFIG_PARPORT=m
> CONFIG_PARPORT_PC=m
> CONFIG_PARPORT_SERIAL=m
> CONFIG_PARPORT_PC_FIFO=y
> # CONFIG_PARPORT_PC_SUPERIO is not set
> CONFIG_PARPORT_PC_PCMCIA=m
> # CONFIG_PARPORT_GSC is not set
> CONFIG_PARPORT_AX88796=m
> CONFIG_PARPORT_1284=y
> CONFIG_PARPORT_NOT_PC=y
> CONFIG_PNP=y
> CONFIG_PNP_DEBUG_MESSAGES=y
> 
> #
> # Protocols
> #
> CONFIG_PNPACPI=y
> CONFIG_BLK_DEV=y
> CONFIG_BLK_DEV_FD=m
> CONFIG_PARIDE=m
> 
> #
> # Parallel IDE high-level drivers
> #
> CONFIG_PARIDE_PD=m
> CONFIG_PARIDE_PCD=m
> CONFIG_PARIDE_PF=m
> CONFIG_PARIDE_PT=m
> CONFIG_PARIDE_PG=m
> 
> #
> # Parallel IDE protocol modules
> #
> CONFIG_PARIDE_ATEN=m
> CONFIG_PARIDE_BPCK=m
> CONFIG_PARIDE_COMM=m
> CONFIG_PARIDE_DSTR=m
> CONFIG_PARIDE_FIT2=m
> CONFIG_PARIDE_FIT3=m
> CONFIG_PARIDE_EPAT=m
> # CONFIG_PARIDE_EPATC8 is not set
> CONFIG_PARIDE_EPIA=m
> CONFIG_PARIDE_FRIQ=m
> CONFIG_PARIDE_FRPW=m
> CONFIG_PARIDE_KBIC=m
> CONFIG_PARIDE_KTTI=m
> CONFIG_PARIDE_ON20=m
> CONFIG_PARIDE_ON26=m
> CONFIG_BLK_CPQ_DA=m
> CONFIG_BLK_CPQ_CISS_DA=m
> CONFIG_CISS_SCSI_TAPE=y
> CONFIG_BLK_DEV_DAC960=m
> CONFIG_BLK_DEV_UMEM=m
> # CONFIG_BLK_DEV_COW_COMMON is not set
> CONFIG_BLK_DEV_LOOP=y
> CONFIG_BLK_DEV_CRYPTOLOOP=m
> CONFIG_BLK_DEV_DRBD=m
> # CONFIG_DRBD_FAULT_INJECTION is not set
> CONFIG_BLK_DEV_NBD=m
> CONFIG_BLK_DEV_OSD=m
> CONFIG_BLK_DEV_SX8=m
> # CONFIG_BLK_DEV_UB is not set
> CONFIG_BLK_DEV_RAM=y
> CONFIG_BLK_DEV_RAM_COUNT=16
> CONFIG_BLK_DEV_RAM_SIZE=65536
> # CONFIG_BLK_DEV_XIP is not set
> CONFIG_CDROM_PKTCDVD=y
> CONFIG_CDROM_PKTCDVD_BUFFERS=8
> # CONFIG_CDROM_PKTCDVD_WCACHE is not set
> CONFIG_ATA_OVER_ETH=m
> CONFIG_XEN_BLKDEV_FRONTEND=m
> CONFIG_VIRTIO_BLK=y
> # CONFIG_BLK_DEV_HD is not set
> CONFIG_MISC_DEVICES=y
> CONFIG_AD525X_DPOT=m
> CONFIG_AD525X_DPOT_I2C=m
> CONFIG_AD525X_DPOT_SPI=m
> CONFIG_IBM_ASM=m
> CONFIG_PHANTOM=m
> CONFIG_SGI_IOC4=m
> CONFIG_TIFM_CORE=m
> CONFIG_TIFM_7XX1=m
> CONFIG_ICS932S401=m
> CONFIG_ENCLOSURE_SERVICES=m
> # CONFIG_CS5535_MFGPT is not set
> CONFIG_HP_ILO=m
> CONFIG_ISL29003=m
> CONFIG_SENSORS_TSL2550=m
> CONFIG_SENSORS_BH1780=m
> CONFIG_HMC6352=m
> CONFIG_DS1682=m
> CONFIG_TI_DAC7512=m
> CONFIG_VMWARE_BALLOON=m
> CONFIG_BMP085=m
> CONFIG_C2PORT=m
> CONFIG_C2PORT_DURAMAR_2150=m
> 
> #
> # EEPROM support
> #
> CONFIG_EEPROM_AT24=m
> CONFIG_EEPROM_AT25=m
> CONFIG_EEPROM_LEGACY=m
> CONFIG_EEPROM_MAX6875=m
> CONFIG_EEPROM_93CX6=m
> CONFIG_CB710_CORE=m
> # CONFIG_CB710_DEBUG is not set
> CONFIG_CB710_DEBUG_ASSUMPTIONS=y
> CONFIG_IWMC3200TOP=m
> # CONFIG_IWMC3200TOP_DEBUG is not set
> CONFIG_IWMC3200TOP_DEBUGFS=y
> CONFIG_HAVE_IDE=y
> # CONFIG_IDE is not set
> 
> #
> # SCSI device support
> #
> CONFIG_SCSI_MOD=y
> CONFIG_RAID_ATTRS=m
> CONFIG_SCSI=y
> CONFIG_SCSI_DMA=y
> CONFIG_SCSI_TGT=m
> CONFIG_SCSI_NETLINK=y
> CONFIG_SCSI_PROC_FS=y
> 
> #
> # SCSI support type (disk, tape, CD-ROM)
> #
> CONFIG_BLK_DEV_SD=y
> CONFIG_CHR_DEV_ST=m
> CONFIG_CHR_DEV_OSST=m
> CONFIG_BLK_DEV_SR=y
> # CONFIG_BLK_DEV_SR_VENDOR is not set
> CONFIG_CHR_DEV_SG=y
> CONFIG_CHR_DEV_SCH=m
> CONFIG_SCSI_ENCLOSURE=m
> CONFIG_SCSI_MULTI_LUN=y
> CONFIG_SCSI_CONSTANTS=y
> CONFIG_SCSI_LOGGING=y
> CONFIG_SCSI_SCAN_ASYNC=y
> CONFIG_SCSI_WAIT_SCAN=m
> 
> #
> # SCSI Transports
> #
> CONFIG_SCSI_SPI_ATTRS=y
> CONFIG_SCSI_FC_ATTRS=m
> CONFIG_SCSI_FC_TGT_ATTRS=y
> CONFIG_SCSI_ISCSI_ATTRS=m
> CONFIG_SCSI_SAS_ATTRS=m
> CONFIG_SCSI_SAS_LIBSAS=m
> CONFIG_SCSI_SAS_ATA=y
> CONFIG_SCSI_SAS_HOST_SMP=y
> # CONFIG_SCSI_SAS_LIBSAS_DEBUG is not set
> CONFIG_SCSI_SRP_ATTRS=m
> CONFIG_SCSI_SRP_TGT_ATTRS=y
> CONFIG_SCSI_LOWLEVEL=y
> CONFIG_ISCSI_TCP=m
> CONFIG_ISCSI_BOOT_SYSFS=m
> CONFIG_SCSI_CXGB3_ISCSI=m
> CONFIG_SCSI_BNX2_ISCSI=m
> CONFIG_BE2ISCSI=m
> CONFIG_BLK_DEV_3W_XXXX_RAID=m
> CONFIG_SCSI_HPSA=m
> CONFIG_SCSI_3W_9XXX=m
> CONFIG_SCSI_3W_SAS=m
> CONFIG_SCSI_ACARD=m
> CONFIG_SCSI_AACRAID=m
> CONFIG_SCSI_AIC7XXX=m
> CONFIG_AIC7XXX_CMDS_PER_DEVICE=8
> CONFIG_AIC7XXX_RESET_DELAY_MS=15000
> CONFIG_AIC7XXX_DEBUG_ENABLE=y
> CONFIG_AIC7XXX_DEBUG_MASK=0
> CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
> # CONFIG_SCSI_AIC7XXX_OLD is not set
> CONFIG_SCSI_AIC79XX=m
> CONFIG_AIC79XX_CMDS_PER_DEVICE=32
> CONFIG_AIC79XX_RESET_DELAY_MS=5000
> CONFIG_AIC79XX_DEBUG_ENABLE=y
> CONFIG_AIC79XX_DEBUG_MASK=0
> CONFIG_AIC79XX_REG_PRETTY_PRINT=y
> CONFIG_SCSI_AIC94XX=m
> # CONFIG_AIC94XX_DEBUG is not set
> CONFIG_SCSI_MVSAS=m
> CONFIG_SCSI_MVSAS_DEBUG=y
> CONFIG_SCSI_DPT_I2O=m
> CONFIG_SCSI_ADVANSYS=m
> CONFIG_SCSI_ARCMSR=m
> CONFIG_SCSI_ARCMSR_AER=y
> CONFIG_MEGARAID_NEWGEN=y
> CONFIG_MEGARAID_MM=m
> CONFIG_MEGARAID_MAILBOX=m
> CONFIG_MEGARAID_LEGACY=m
> CONFIG_MEGARAID_SAS=m
> CONFIG_SCSI_MPT2SAS=m
> CONFIG_SCSI_MPT2SAS_MAX_SGE=128
> # CONFIG_SCSI_MPT2SAS_LOGGING is not set
> CONFIG_SCSI_HPTIOP=m
> CONFIG_SCSI_BUSLOGIC=m
> CONFIG_VMWARE_PVSCSI=m
> CONFIG_LIBFC=m
> CONFIG_LIBFCOE=m
> CONFIG_FCOE=m
> CONFIG_FCOE_FNIC=m
> CONFIG_SCSI_DMX3191D=m
> CONFIG_SCSI_EATA=m
> CONFIG_SCSI_EATA_TAGGED_QUEUE=y
> CONFIG_SCSI_EATA_LINKED_COMMANDS=y
> CONFIG_SCSI_EATA_MAX_TAGS=16
> CONFIG_SCSI_FUTURE_DOMAIN=m
> CONFIG_SCSI_GDTH=m
> CONFIG_SCSI_IPS=m
> CONFIG_SCSI_INITIO=m
> CONFIG_SCSI_INIA100=m
> CONFIG_SCSI_PPA=m
> CONFIG_SCSI_IMM=m
> # CONFIG_SCSI_IZIP_EPP16 is not set
> # CONFIG_SCSI_IZIP_SLOW_CTR is not set
> CONFIG_SCSI_STEX=m
> CONFIG_SCSI_SYM53C8XX_2=y
> CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
> CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
> CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
> CONFIG_SCSI_SYM53C8XX_MMIO=y
> CONFIG_SCSI_IPR=m
> # CONFIG_SCSI_IPR_TRACE is not set
> # CONFIG_SCSI_IPR_DUMP is not set
> CONFIG_SCSI_QLOGIC_1280=m
> CONFIG_SCSI_QLA_FC=m
> CONFIG_SCSI_QLA_ISCSI=m
> CONFIG_SCSI_LPFC=m
> CONFIG_SCSI_LPFC_DEBUG_FS=y
> CONFIG_SCSI_DC395x=m
> CONFIG_SCSI_DC390T=m
> CONFIG_SCSI_DEBUG=m
> CONFIG_SCSI_PMCRAID=m
> CONFIG_SCSI_PM8001=m
> CONFIG_SCSI_SRP=m
> CONFIG_SCSI_BFA_FC=m
> CONFIG_SCSI_LOWLEVEL_PCMCIA=y
> CONFIG_PCMCIA_FDOMAIN=m
> CONFIG_PCMCIA_QLOGIC=m
> CONFIG_PCMCIA_SYM53C500=m
> CONFIG_SCSI_DH=y
> CONFIG_SCSI_DH_RDAC=m
> CONFIG_SCSI_DH_HP_SW=m
> CONFIG_SCSI_DH_EMC=m
> CONFIG_SCSI_DH_ALUA=m
> CONFIG_SCSI_OSD_INITIATOR=m
> CONFIG_SCSI_OSD_ULD=m
> CONFIG_SCSI_OSD_DPRINT_SENSE=1
> # CONFIG_SCSI_OSD_DEBUG is not set
> CONFIG_ATA=y
> # CONFIG_ATA_NONSTANDARD is not set
> CONFIG_ATA_VERBOSE_ERROR=y
> CONFIG_ATA_ACPI=y
> CONFIG_SATA_PMP=y
> 
> #
> # Controllers with non-SFF native interface
> #
> CONFIG_SATA_AHCI=m
> CONFIG_SATA_AHCI_PLATFORM=m
> CONFIG_SATA_INIC162X=m
> CONFIG_SATA_SIL24=m
> CONFIG_ATA_SFF=y
> 
> #
> # SFF controllers with custom DMA interface
> #
> CONFIG_PDC_ADMA=y
> CONFIG_SATA_QSTOR=m
> CONFIG_SATA_SX4=m
> CONFIG_ATA_BMDMA=y
> 
> #
> # SATA SFF controllers with BMDMA
> #
> CONFIG_ATA_PIIX=y
> CONFIG_SATA_MV=m
> CONFIG_SATA_NV=m
> CONFIG_SATA_PROMISE=m
> CONFIG_SATA_SIL=m
> CONFIG_SATA_SIS=m
> CONFIG_SATA_SVW=m
> CONFIG_SATA_ULI=m
> CONFIG_SATA_VIA=m
> CONFIG_SATA_VITESSE=m
> 
> #
> # PATA SFF controllers with BMDMA
> #
> CONFIG_PATA_ALI=m
> CONFIG_PATA_AMD=m
> CONFIG_PATA_ARTOP=m
> CONFIG_PATA_ATIIXP=m
> CONFIG_PATA_ATP867X=m
> CONFIG_PATA_CMD64X=m
> CONFIG_PATA_CS5520=m
> CONFIG_PATA_CS5530=m
> CONFIG_PATA_CYPRESS=m
> CONFIG_PATA_EFAR=m
> CONFIG_PATA_HPT366=m
> CONFIG_PATA_HPT37X=m
> CONFIG_PATA_HPT3X2N=m
> CONFIG_PATA_HPT3X3=m
> # CONFIG_PATA_HPT3X3_DMA is not set
> CONFIG_PATA_IT8213=m
> CONFIG_PATA_IT821X=m
> CONFIG_PATA_JMICRON=m
> CONFIG_PATA_MARVELL=m
> CONFIG_PATA_NETCELL=m
> CONFIG_PATA_NINJA32=m
> CONFIG_PATA_NS87415=m
> CONFIG_PATA_OLDPIIX=m
> CONFIG_PATA_OPTIDMA=m
> CONFIG_PATA_PDC2027X=m
> CONFIG_PATA_PDC_OLD=m
> CONFIG_PATA_RADISYS=m
> CONFIG_PATA_RDC=m
> CONFIG_PATA_SC1200=m
> CONFIG_PATA_SCH=m
> CONFIG_PATA_SERVERWORKS=m
> CONFIG_PATA_SIL680=m
> CONFIG_PATA_SIS=y
> # CONFIG_PATA_TOSHIBA is not set
> CONFIG_PATA_TRIFLEX=m
> CONFIG_PATA_VIA=m
> CONFIG_PATA_WINBOND=m
> 
> #
> # PIO-only SFF controllers
> #
> CONFIG_PATA_CMD640_PCI=m
> CONFIG_PATA_MPIIX=m
> CONFIG_PATA_NS87410=m
> CONFIG_PATA_OPTI=m
> CONFIG_PATA_PCMCIA=m
> CONFIG_PATA_RZ1000=m
> 
> #
> # Generic fallback / legacy drivers
> #
> CONFIG_PATA_ACPI=y
> CONFIG_ATA_GENERIC=y
> CONFIG_PATA_LEGACY=m
> CONFIG_MD=y
> CONFIG_BLK_DEV_MD=y
> CONFIG_MD_AUTODETECT=y
> CONFIG_MD_LINEAR=m
> CONFIG_MD_RAID0=m
> CONFIG_MD_RAID1=m
> CONFIG_MD_RAID10=m
> CONFIG_MD_RAID456=m
> # CONFIG_MULTICORE_RAID456 is not set
> CONFIG_MD_MULTIPATH=m
> CONFIG_MD_FAULTY=m
> CONFIG_BLK_DEV_DM=y
> # CONFIG_DM_DEBUG is not set
> CONFIG_DM_CRYPT=m
> CONFIG_DM_SNAPSHOT=y
> CONFIG_DM_MIRROR=y
> # CONFIG_DM_LOG_USERSPACE is not set
> CONFIG_DM_ZERO=m
> CONFIG_DM_MULTIPATH=y
> CONFIG_DM_MULTIPATH_QL=m
> CONFIG_DM_MULTIPATH_ST=m
> # CONFIG_DM_DELAY is not set
> CONFIG_DM_UEVENT=y
> CONFIG_FUSION=y
> CONFIG_FUSION_SPI=m
> CONFIG_FUSION_FC=m
> CONFIG_FUSION_SAS=m
> CONFIG_FUSION_MAX_SGE=128
> CONFIG_FUSION_CTL=m
> CONFIG_FUSION_LAN=m
> CONFIG_FUSION_LOGGING=y
> 
> #
> # IEEE 1394 (FireWire) support
> #
> 
> #
> # You can enable one or both FireWire driver stacks.
> #
> 
> #
> # The newer stack is recommended.
> #
> CONFIG_FIREWIRE=m
> CONFIG_FIREWIRE_OHCI=m
> CONFIG_FIREWIRE_OHCI_DEBUG=y
> CONFIG_FIREWIRE_SBP2=m
> CONFIG_FIREWIRE_NET=m
> CONFIG_IEEE1394=m
> CONFIG_IEEE1394_OHCI1394=m
> CONFIG_IEEE1394_PCILYNX=m
> CONFIG_IEEE1394_SBP2=m
> # CONFIG_IEEE1394_SBP2_PHYS_DMA is not set
> CONFIG_IEEE1394_ETH1394_ROM_ENTRY=y
> CONFIG_IEEE1394_ETH1394=m
> CONFIG_IEEE1394_RAWIO=m
> CONFIG_IEEE1394_VIDEO1394=m
> CONFIG_IEEE1394_DV1394=m
> # CONFIG_IEEE1394_VERBOSEDEBUG is not set
> CONFIG_FIREWIRE_NOSY=m
> CONFIG_I2O=m
> CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
> CONFIG_I2O_EXT_ADAPTEC=y
> CONFIG_I2O_EXT_ADAPTEC_DMA64=y
> CONFIG_I2O_CONFIG=m
> CONFIG_I2O_CONFIG_OLD_IOCTL=y
> CONFIG_I2O_BUS=m
> CONFIG_I2O_BLOCK=m
> CONFIG_I2O_SCSI=m
> CONFIG_I2O_PROC=m
> CONFIG_MACINTOSH_DRIVERS=y
> CONFIG_MAC_EMUMOUSEBTN=y
> CONFIG_NETDEVICES=y
> CONFIG_IFB=m
> CONFIG_DUMMY=m
> CONFIG_BONDING=m
> CONFIG_MACVLAN=m
> # CONFIG_MACVTAP is not set
> CONFIG_EQUALIZER=m
> CONFIG_TUN=y
> CONFIG_VETH=m
> CONFIG_NET_SB1000=m
> CONFIG_ARCNET=m
> CONFIG_ARCNET_1201=m
> CONFIG_ARCNET_1051=m
> CONFIG_ARCNET_RAW=m
> CONFIG_ARCNET_CAP=m
> CONFIG_ARCNET_COM90xx=m
> CONFIG_ARCNET_COM90xxIO=m
> CONFIG_ARCNET_RIM_I=m
> CONFIG_ARCNET_COM20020=m
> CONFIG_ARCNET_COM20020_PCI=m
> CONFIG_PHYLIB=y
> 
> #
> # MII PHY device drivers
> #
> CONFIG_MARVELL_PHY=y
> CONFIG_DAVICOM_PHY=y
> CONFIG_QSEMI_PHY=y
> CONFIG_LXT_PHY=y
> CONFIG_CICADA_PHY=y
> CONFIG_VITESSE_PHY=y
> CONFIG_SMSC_PHY=y
> CONFIG_BROADCOM_PHY=y
> CONFIG_ICPLUS_PHY=y
> CONFIG_REALTEK_PHY=y
> CONFIG_NATIONAL_PHY=y
> CONFIG_STE10XP=y
> CONFIG_LSI_ET1011C_PHY=y
> CONFIG_MICREL_PHY=m
> CONFIG_FIXED_PHY=y
> CONFIG_MDIO_BITBANG=y
> CONFIG_MDIO_GPIO=y
> CONFIG_NET_ETHERNET=y
> CONFIG_MII=m
> CONFIG_HAPPYMEAL=m
> CONFIG_SUNGEM=m
> CONFIG_CASSINI=m
> CONFIG_NET_VENDOR_3COM=y
> CONFIG_VORTEX=m
> CONFIG_TYPHOON=m
> # CONFIG_ENC28J60 is not set
> CONFIG_ETHOC=m
> CONFIG_DNET=m
> CONFIG_NET_TULIP=y
> CONFIG_DE2104X=m
> CONFIG_DE2104X_DSL=0
> CONFIG_TULIP=m
> # CONFIG_TULIP_MWI is not set
> # CONFIG_TULIP_MMIO is not set
> # CONFIG_TULIP_NAPI is not set
> CONFIG_DE4X5=m
> CONFIG_WINBOND_840=m
> CONFIG_DM9102=m
> CONFIG_ULI526X=m
> CONFIG_PCMCIA_XIRCOM=m
> CONFIG_HP100=m
> # CONFIG_IBM_NEW_EMAC_ZMII is not set
> # CONFIG_IBM_NEW_EMAC_RGMII is not set
> # CONFIG_IBM_NEW_EMAC_TAH is not set
> # CONFIG_IBM_NEW_EMAC_EMAC4 is not set
> # CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
> # CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
> # CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
> CONFIG_NET_PCI=y
> CONFIG_PCNET32=m
> CONFIG_AMD8111_ETH=m
> CONFIG_ADAPTEC_STARFIRE=m
> CONFIG_KSZ884X_PCI=m
> CONFIG_B44=m
> CONFIG_B44_PCI_AUTOSELECT=y
> CONFIG_B44_PCICORE_AUTOSELECT=y
> CONFIG_B44_PCI=y
> CONFIG_FORCEDETH=m
> CONFIG_E100=m
> CONFIG_FEALNX=m
> CONFIG_NATSEMI=m
> CONFIG_NE2K_PCI=m
> CONFIG_8139CP=m
> CONFIG_8139TOO=m
> CONFIG_8139TOO_PIO=y
> # CONFIG_8139TOO_TUNE_TWISTER is not set
> CONFIG_8139TOO_8129=y
> # CONFIG_8139_OLD_RX_RESET is not set
> # CONFIG_R6040 is not set
> CONFIG_SIS900=m
> CONFIG_EPIC100=m
> CONFIG_SMSC9420=m
> CONFIG_SUNDANCE=m
> # CONFIG_SUNDANCE_MMIO is not set
> CONFIG_TLAN=m
> CONFIG_KS8842=m
> CONFIG_KS8851=m
> CONFIG_KS8851_MLL=m
> CONFIG_VIA_RHINE=m
> CONFIG_VIA_RHINE_MMIO=y
> CONFIG_SC92031=m
> CONFIG_NET_POCKET=y
> CONFIG_ATP=m
> CONFIG_DE600=m
> CONFIG_DE620=m
> CONFIG_ATL2=m
> CONFIG_NETDEV_1000=y
> CONFIG_ACENIC=m
> # CONFIG_ACENIC_OMIT_TIGON_I is not set
> # CONFIG_DL2K is not set
> CONFIG_E1000=m
> CONFIG_E1000E=m
> CONFIG_IP1000=m
> CONFIG_IGB=m
> CONFIG_IGB_DCA=y
> CONFIG_IGBVF=m
> CONFIG_NS83820=m
> CONFIG_HAMACHI=m
> CONFIG_YELLOWFIN=m
> CONFIG_R8169=m
> CONFIG_R8169_VLAN=y
> CONFIG_SIS190=m
> CONFIG_SKGE=m
> # CONFIG_SKGE_DEBUG is not set
> CONFIG_SKY2=m
> # CONFIG_SKY2_DEBUG is not set
> CONFIG_VIA_VELOCITY=m
> CONFIG_TIGON3=m
> CONFIG_BNX2=m
> CONFIG_CNIC=m
> CONFIG_QLA3XXX=m
> CONFIG_ATL1=m
> CONFIG_ATL1E=m
> CONFIG_ATL1C=m
> CONFIG_JME=m
> CONFIG_NETDEV_10000=y
> CONFIG_MDIO=m
> CONFIG_CHELSIO_T1=m
> CONFIG_CHELSIO_T1_1G=y
> CONFIG_CHELSIO_T3_DEPENDS=y
> CONFIG_CHELSIO_T3=m
> CONFIG_CHELSIO_T4_DEPENDS=y
> CONFIG_CHELSIO_T4=m
> CONFIG_CHELSIO_T4VF_DEPENDS=y
> CONFIG_CHELSIO_T4VF=m
> CONFIG_ENIC=m
> CONFIG_IXGBE=m
> CONFIG_IXGBE_DCA=y
> CONFIG_IXGBE_DCB=y
> CONFIG_IXGBEVF=m
> CONFIG_IXGB=m
> CONFIG_S2IO=m
> CONFIG_VXGE=m
> # CONFIG_VXGE_DEBUG_TRACE_ALL is not set
> CONFIG_MYRI10GE=m
> CONFIG_MYRI10GE_DCA=y
> CONFIG_NETXEN_NIC=m
> CONFIG_NIU=m
> CONFIG_MLX4_EN=m
> CONFIG_MLX4_CORE=m
> CONFIG_MLX4_DEBUG=y
> CONFIG_TEHUTI=m
> CONFIG_BNX2X=m
> CONFIG_QLCNIC=m
> CONFIG_QLGE=m
> CONFIG_SFC=m
> CONFIG_SFC_MTD=y
> CONFIG_BE2NET=m
> CONFIG_TR=y
> CONFIG_IBMOL=m
> CONFIG_3C359=m
> CONFIG_TMS380TR=m
> CONFIG_TMSPCI=m
> CONFIG_ABYSS=m
> CONFIG_WLAN=y
> CONFIG_PCMCIA_RAYCS=m
> CONFIG_LIBERTAS_THINFIRM=m
> # CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
> CONFIG_LIBERTAS_THINFIRM_USB=m
> CONFIG_AIRO=m
> CONFIG_ATMEL=m
> CONFIG_PCI_ATMEL=m
> CONFIG_PCMCIA_ATMEL=m
> CONFIG_AT76C50X_USB=m
> CONFIG_AIRO_CS=m
> CONFIG_PCMCIA_WL3501=m
> CONFIG_PRISM54=m
> CONFIG_USB_ZD1201=m
> CONFIG_USB_NET_RNDIS_WLAN=m
> CONFIG_RTL8180=m
> CONFIG_RTL8187=m
> CONFIG_RTL8187_LEDS=y
> CONFIG_ADM8211=m
> CONFIG_MAC80211_HWSIM=m
> CONFIG_MWL8K=m
> CONFIG_ATH_COMMON=m
> # CONFIG_ATH_DEBUG is not set
> CONFIG_ATH5K=m
> # CONFIG_ATH5K_DEBUG is not set
> CONFIG_ATH9K_HW=m
> CONFIG_ATH9K_COMMON=m
> CONFIG_ATH9K=m
> CONFIG_ATH9K_DEBUGFS=y
> CONFIG_ATH9K_HTC=m
> CONFIG_ATH9K_HTC_DEBUGFS=y
> CONFIG_AR9170_USB=m
> CONFIG_AR9170_LEDS=y
> CONFIG_B43=m
> CONFIG_B43_PCI_AUTOSELECT=y
> CONFIG_B43_PCICORE_AUTOSELECT=y
> # CONFIG_B43_PCMCIA is not set
> # CONFIG_B43_SDIO is not set
> CONFIG_B43_PIO=y
> CONFIG_B43_PHY_LP=y
> CONFIG_B43_LEDS=y
> CONFIG_B43_HWRNG=y
> # CONFIG_B43_DEBUG is not set
> CONFIG_B43LEGACY=m
> CONFIG_B43LEGACY_PCI_AUTOSELECT=y
> CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
> CONFIG_B43LEGACY_LEDS=y
> CONFIG_B43LEGACY_HWRNG=y
> CONFIG_B43LEGACY_DEBUG=y
> CONFIG_B43LEGACY_DMA=y
> CONFIG_B43LEGACY_PIO=y
> CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
> # CONFIG_B43LEGACY_DMA_MODE is not set
> # CONFIG_B43LEGACY_PIO_MODE is not set
> CONFIG_HOSTAP=m
> CONFIG_HOSTAP_FIRMWARE=y
> CONFIG_HOSTAP_FIRMWARE_NVRAM=y
> CONFIG_HOSTAP_PLX=m
> CONFIG_HOSTAP_PCI=m
> CONFIG_HOSTAP_CS=m
> CONFIG_IPW2100=m
> CONFIG_IPW2100_MONITOR=y
> # CONFIG_IPW2100_DEBUG is not set
> CONFIG_IPW2200=m
> CONFIG_IPW2200_MONITOR=y
> CONFIG_IPW2200_RADIOTAP=y
> CONFIG_IPW2200_PROMISCUOUS=y
> CONFIG_IPW2200_QOS=y
> # CONFIG_IPW2200_DEBUG is not set
> CONFIG_LIBIPW=m
> CONFIG_LIBIPW_DEBUG=y
> CONFIG_IWLWIFI=m
> # CONFIG_IWLWIFI_DEBUG is not set
> CONFIG_IWLWIFI_DEBUGFS=y
> CONFIG_IWLWIFI_DEVICE_TRACING=y
> CONFIG_IWLAGN=m
> CONFIG_IWL4965=y
> CONFIG_IWL5000=y
> CONFIG_IWL3945=m
> CONFIG_IWM=m
> # CONFIG_IWM_DEBUG is not set
> CONFIG_IWM_TRACING=y
> CONFIG_LIBERTAS=m
> CONFIG_LIBERTAS_USB=m
> CONFIG_LIBERTAS_CS=m
> CONFIG_LIBERTAS_SDIO=m
> CONFIG_LIBERTAS_SPI=m
> # CONFIG_LIBERTAS_DEBUG is not set
> CONFIG_LIBERTAS_MESH=y
> CONFIG_HERMES=m
> # CONFIG_HERMES_PRISM is not set
> CONFIG_HERMES_CACHE_FW_ON_INIT=y
> CONFIG_PLX_HERMES=m
> CONFIG_TMD_HERMES=m
> CONFIG_NORTEL_HERMES=m
> CONFIG_PCMCIA_HERMES=m
> CONFIG_PCMCIA_SPECTRUM=m
> CONFIG_ORINOCO_USB=m
> CONFIG_P54_COMMON=m
> CONFIG_P54_USB=m
> CONFIG_P54_PCI=m
> CONFIG_P54_SPI=m
> CONFIG_P54_LEDS=y
> CONFIG_RT2X00=m
> CONFIG_RT2400PCI=m
> CONFIG_RT2500PCI=m
> CONFIG_RT61PCI=m
> CONFIG_RT2800PCI_PCI=y
> CONFIG_RT2800PCI=m
> CONFIG_RT2800PCI_RT30XX=y
> CONFIG_RT2800PCI_RT35XX=y
> CONFIG_RT2500USB=m
> CONFIG_RT73USB=m
> CONFIG_RT2800USB=m
> # CONFIG_RT2800USB_RT30XX is not set
> # CONFIG_RT2800USB_RT35XX is not set
> CONFIG_RT2800USB_UNKNOWN=y
> CONFIG_RT2800_LIB=m
> CONFIG_RT2X00_LIB_PCI=m
> CONFIG_RT2X00_LIB_USB=m
> CONFIG_RT2X00_LIB=m
> CONFIG_RT2X00_LIB_HT=y
> CONFIG_RT2X00_LIB_FIRMWARE=y
> CONFIG_RT2X00_LIB_CRYPTO=y
> CONFIG_RT2X00_LIB_LEDS=y
> # CONFIG_RT2X00_LIB_DEBUGFS is not set
> # CONFIG_RT2X00_DEBUG is not set
> CONFIG_WL12XX=m
> CONFIG_WL1251=m
> CONFIG_WL1251_SPI=m
> CONFIG_WL1251_SDIO=m
> CONFIG_WL1271=m
> CONFIG_WL1271_SPI=m
> CONFIG_WL1271_SDIO=m
> CONFIG_ZD1211RW=m
> # CONFIG_ZD1211RW_DEBUG is not set
> 
> #
> # WiMAX Wireless Broadband devices
> #
> CONFIG_WIMAX_I2400M=m
> CONFIG_WIMAX_I2400M_USB=m
> CONFIG_WIMAX_I2400M_SDIO=m
> CONFIG_WIMAX_IWMC3200_SDIO=y
> CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
> 
> #
> # USB Network Adapters
> #
> CONFIG_USB_CATC=m
> CONFIG_USB_KAWETH=m
> CONFIG_USB_PEGASUS=m
> CONFIG_USB_RTL8150=m
> CONFIG_USB_USBNET=m
> CONFIG_USB_NET_AX8817X=m
> CONFIG_USB_NET_CDCETHER=m
> CONFIG_USB_NET_CDC_EEM=m
> CONFIG_USB_NET_DM9601=m
> CONFIG_USB_NET_SMSC75XX=m
> CONFIG_USB_NET_SMSC95XX=m
> CONFIG_USB_NET_GL620A=m
> CONFIG_USB_NET_NET1080=m
> CONFIG_USB_NET_PLUSB=m
> CONFIG_USB_NET_MCS7830=m
> CONFIG_USB_NET_RNDIS_HOST=m
> CONFIG_USB_NET_CDC_SUBSET=m
> CONFIG_USB_ALI_M5632=y
> CONFIG_USB_AN2720=y
> CONFIG_USB_BELKIN=y
> CONFIG_USB_ARMLINUX=y
> CONFIG_USB_EPSON2888=y
> CONFIG_USB_KC2190=y
> CONFIG_USB_NET_ZAURUS=m
> CONFIG_USB_HSO=m
> CONFIG_USB_NET_INT51X1=m
> CONFIG_USB_CDC_PHONET=m
> CONFIG_USB_IPHETH=m
> CONFIG_USB_SIERRA_NET=m
> CONFIG_NET_PCMCIA=y
> CONFIG_PCMCIA_3C589=m
> CONFIG_PCMCIA_3C574=m
> CONFIG_PCMCIA_FMVJ18X=m
> CONFIG_PCMCIA_PCNET=m
> CONFIG_PCMCIA_NMCLAN=m
> CONFIG_PCMCIA_SMC91C92=m
> CONFIG_PCMCIA_XIRC2PS=m
> CONFIG_PCMCIA_AXNET=m
> CONFIG_ARCNET_COM20020_CS=m
> CONFIG_PCMCIA_IBMTR=m
> CONFIG_WAN=y
> CONFIG_LANMEDIA=m
> CONFIG_HDLC=m
> CONFIG_HDLC_RAW=m
> CONFIG_HDLC_RAW_ETH=m
> CONFIG_HDLC_CISCO=m
> CONFIG_HDLC_FR=m
> CONFIG_HDLC_PPP=m
> CONFIG_HDLC_X25=m
> CONFIG_PCI200SYN=m
> CONFIG_WANXL=m
> # CONFIG_PC300TOO is not set
> CONFIG_FARSYNC=m
> CONFIG_DSCC4=m
> CONFIG_DSCC4_PCISYNC=y
> CONFIG_DSCC4_PCI_RST=y
> CONFIG_DLCI=m
> CONFIG_DLCI_MAX=8
> CONFIG_WAN_ROUTER_DRIVERS=m
> CONFIG_CYCLADES_SYNC=m
> CONFIG_CYCLOMX_X25=y
> CONFIG_LAPBETHER=m
> CONFIG_X25_ASY=m
> CONFIG_SBNI=m
> # CONFIG_SBNI_MULTILINE is not set
> CONFIG_ATM_DRIVERS=y
> # CONFIG_ATM_DUMMY is not set
> CONFIG_ATM_TCP=m
> CONFIG_ATM_LANAI=m
> CONFIG_ATM_ENI=m
> # CONFIG_ATM_ENI_DEBUG is not set
> # CONFIG_ATM_ENI_TUNE_BURST is not set
> CONFIG_ATM_FIRESTREAM=m
> CONFIG_ATM_ZATM=m
> # CONFIG_ATM_ZATM_DEBUG is not set
> CONFIG_ATM_NICSTAR=m
> # CONFIG_ATM_NICSTAR_USE_SUNI is not set
> # CONFIG_ATM_NICSTAR_USE_IDT77105 is not set
> CONFIG_ATM_IDT77252=m
> # CONFIG_ATM_IDT77252_DEBUG is not set
> # CONFIG_ATM_IDT77252_RCV_ALL is not set
> CONFIG_ATM_IDT77252_USE_SUNI=y
> CONFIG_ATM_AMBASSADOR=m
> # CONFIG_ATM_AMBASSADOR_DEBUG is not set
> CONFIG_ATM_HORIZON=m
> # CONFIG_ATM_HORIZON_DEBUG is not set
> CONFIG_ATM_IA=m
> # CONFIG_ATM_IA_DEBUG is not set
> CONFIG_ATM_FORE200E=m
> # CONFIG_ATM_FORE200E_USE_TASKLET is not set
> CONFIG_ATM_FORE200E_TX_RETRY=16
> CONFIG_ATM_FORE200E_DEBUG=0
> CONFIG_ATM_HE=m
> CONFIG_ATM_HE_USE_SUNI=y
> CONFIG_ATM_SOLOS=m
> CONFIG_IEEE802154_DRIVERS=m
> # CONFIG_IEEE802154_FAKEHARD is not set
> 
> #
> # CAIF transport drivers
> #
> CONFIG_CAIF_TTY=m
> CONFIG_CAIF_SPI_SLAVE=m
> # CONFIG_CAIF_SPI_SYNC is not set
> CONFIG_XEN_NETDEV_FRONTEND=m
> CONFIG_FDDI=y
> CONFIG_DEFXX=m
> # CONFIG_DEFXX_MMIO is not set
> CONFIG_SKFP=m
> CONFIG_HIPPI=y
> CONFIG_ROADRUNNER=m
> # CONFIG_ROADRUNNER_LARGE_RINGS is not set
> CONFIG_PLIP=m
> CONFIG_PPP=y
> CONFIG_PPP_MULTILINK=y
> CONFIG_PPP_FILTER=y
> CONFIG_PPP_ASYNC=m
> CONFIG_PPP_SYNC_TTY=m
> CONFIG_PPP_DEFLATE=m
> CONFIG_PPP_BSDCOMP=m
> CONFIG_PPP_MPPE=m
> CONFIG_PPPOE=m
> CONFIG_PPPOATM=m
> CONFIG_PPPOL2TP=m
> CONFIG_SLIP=m
> CONFIG_SLIP_COMPRESSED=y
> CONFIG_SLHC=y
> CONFIG_SLIP_SMART=y
> CONFIG_SLIP_MODE_SLIP6=y
> CONFIG_NET_FC=y
> CONFIG_NETCONSOLE=m
> CONFIG_NETCONSOLE_DYNAMIC=y
> CONFIG_NETPOLL=y
> # CONFIG_NETPOLL_TRAP is not set
> CONFIG_NET_POLL_CONTROLLER=y
> CONFIG_VIRTIO_NET=y
> CONFIG_VMXNET3=m
> CONFIG_ISDN=y
> CONFIG_ISDN_I4L=m
> CONFIG_ISDN_PPP=y
> CONFIG_ISDN_PPP_VJ=y
> CONFIG_ISDN_MPP=y
> CONFIG_IPPP_FILTER=y
> CONFIG_ISDN_PPP_BSDCOMP=m
> CONFIG_ISDN_AUDIO=y
> CONFIG_ISDN_TTY_FAX=y
> CONFIG_ISDN_X25=y
> 
> #
> # ISDN feature submodules
> #
> CONFIG_ISDN_DIVERSION=m
> 
> #
> # ISDN4Linux hardware drivers
> #
> 
> #
> # Passive cards
> #
> CONFIG_ISDN_DRV_HISAX=m
> 
> #
> # D-channel protocol features
> #
> CONFIG_HISAX_EURO=y
> CONFIG_DE_AOC=y
> # CONFIG_HISAX_NO_SENDCOMPLETE is not set
> # CONFIG_HISAX_NO_LLC is not set
> # CONFIG_HISAX_NO_KEYPAD is not set
> CONFIG_HISAX_1TR6=y
> CONFIG_HISAX_NI1=y
> CONFIG_HISAX_MAX_CARDS=8
> 
> #
> # HiSax supported cards
> #
> CONFIG_HISAX_16_3=y
> CONFIG_HISAX_TELESPCI=y
> CONFIG_HISAX_S0BOX=y
> CONFIG_HISAX_FRITZPCI=y
> CONFIG_HISAX_AVM_A1_PCMCIA=y
> CONFIG_HISAX_ELSA=y
> CONFIG_HISAX_DIEHLDIVA=y
> CONFIG_HISAX_SEDLBAUER=y
> CONFIG_HISAX_NETJET=y
> CONFIG_HISAX_NETJET_U=y
> CONFIG_HISAX_NICCY=y
> CONFIG_HISAX_BKM_A4T=y
> CONFIG_HISAX_SCT_QUADRO=y
> CONFIG_HISAX_GAZEL=y
> CONFIG_HISAX_HFC_PCI=y
> CONFIG_HISAX_W6692=y
> CONFIG_HISAX_HFC_SX=y
> CONFIG_HISAX_ENTERNOW_PCI=y
> # CONFIG_HISAX_DEBUG is not set
> 
> #
> # HiSax PCMCIA card service modules
> #
> CONFIG_HISAX_SEDLBAUER_CS=m
> CONFIG_HISAX_ELSA_CS=m
> CONFIG_HISAX_AVM_A1_CS=m
> CONFIG_HISAX_TELES_CS=m
> 
> #
> # HiSax sub driver modules
> #
> CONFIG_HISAX_ST5481=m
> CONFIG_HISAX_HFCUSB=m
> CONFIG_HISAX_HFC4S8S=m
> CONFIG_HISAX_FRITZ_PCIPNP=m
> 
> #
> # Active cards
> #
> CONFIG_ISDN_CAPI=m
> CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
> CONFIG_CAPI_TRACE=y
> CONFIG_ISDN_CAPI_MIDDLEWARE=y
> CONFIG_ISDN_CAPI_CAPI20=m
> CONFIG_ISDN_CAPI_CAPIFS_BOOL=y
> CONFIG_ISDN_CAPI_CAPIFS=m
> CONFIG_ISDN_CAPI_CAPIDRV=m
> 
> #
> # CAPI hardware drivers
> #
> CONFIG_CAPI_AVM=y
> CONFIG_ISDN_DRV_AVMB1_B1PCI=m
> CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
> CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=m
> CONFIG_ISDN_DRV_AVMB1_AVM_CS=m
> CONFIG_ISDN_DRV_AVMB1_T1PCI=m
> CONFIG_ISDN_DRV_AVMB1_C4=m
> CONFIG_CAPI_EICON=y
> CONFIG_ISDN_DIVAS=m
> CONFIG_ISDN_DIVAS_BRIPCI=y
> CONFIG_ISDN_DIVAS_PRIPCI=y
> CONFIG_ISDN_DIVAS_DIVACAPI=m
> CONFIG_ISDN_DIVAS_USERIDI=m
> CONFIG_ISDN_DIVAS_MAINT=m
> CONFIG_ISDN_DRV_GIGASET=m
> # CONFIG_GIGASET_CAPI is not set
> CONFIG_GIGASET_I4L=y
> # CONFIG_GIGASET_DUMMYLL is not set
> CONFIG_GIGASET_BASE=m
> CONFIG_GIGASET_M105=m
> CONFIG_GIGASET_M101=m
> # CONFIG_GIGASET_DEBUG is not set
> CONFIG_HYSDN=m
> CONFIG_HYSDN_CAPI=y
> CONFIG_MISDN=m
> CONFIG_MISDN_DSP=m
> CONFIG_MISDN_L1OIP=m
> 
> #
> # mISDN hardware drivers
> #
> CONFIG_MISDN_HFCPCI=m
> CONFIG_MISDN_HFCMULTI=m
> CONFIG_MISDN_HFCUSB=m
> CONFIG_MISDN_AVMFRITZ=m
> CONFIG_MISDN_SPEEDFAX=m
> CONFIG_MISDN_INFINEON=m
> CONFIG_MISDN_W6692=m
> CONFIG_MISDN_NETJET=m
> CONFIG_MISDN_IPAC=m
> CONFIG_MISDN_ISAR=m
> CONFIG_ISDN_HDLC=m
> CONFIG_PHONE=m
> CONFIG_PHONE_IXJ=m
> CONFIG_PHONE_IXJ_PCMCIA=m
> 
> #
> # Input device support
> #
> CONFIG_INPUT=y
> CONFIG_INPUT_FF_MEMLESS=m
> CONFIG_INPUT_POLLDEV=m
> CONFIG_INPUT_SPARSEKMAP=m
> 
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=y
> CONFIG_INPUT_MOUSEDEV_PSAUX=y
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
> CONFIG_INPUT_JOYDEV=m
> CONFIG_INPUT_EVDEV=y
> CONFIG_INPUT_EVBUG=m
> CONFIG_XEN_KBDDEV_FRONTEND=m
> 
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=y
> CONFIG_KEYBOARD_ADP5520=m
> CONFIG_KEYBOARD_ADP5588=m
> CONFIG_KEYBOARD_ATKBD=y
> # CONFIG_KEYBOARD_QT2160 is not set
> CONFIG_KEYBOARD_LKKBD=m
> CONFIG_KEYBOARD_GPIO=m
> CONFIG_KEYBOARD_TCA6416=m
> CONFIG_KEYBOARD_MATRIX=m
> CONFIG_KEYBOARD_LM8323=m
> CONFIG_KEYBOARD_MAX7359=m
> CONFIG_KEYBOARD_MCS=m
> CONFIG_KEYBOARD_NEWTON=m
> CONFIG_KEYBOARD_OPENCORES=m
> CONFIG_KEYBOARD_STOWAWAY=m
> CONFIG_KEYBOARD_SUNKBD=m
> CONFIG_KEYBOARD_STMPE=m
> CONFIG_KEYBOARD_TWL4030=m
> CONFIG_KEYBOARD_XTKBD=m
> CONFIG_INPUT_MOUSE=y
> CONFIG_MOUSE_PS2=m
> CONFIG_MOUSE_PS2_ALPS=y
> CONFIG_MOUSE_PS2_LOGIPS2PP=y
> CONFIG_MOUSE_PS2_SYNAPTICS=y
> CONFIG_MOUSE_PS2_LIFEBOOK=y
> CONFIG_MOUSE_PS2_TRACKPOINT=y
> CONFIG_MOUSE_PS2_ELANTECH=y
> CONFIG_MOUSE_PS2_SENTELIC=y
> # CONFIG_MOUSE_PS2_TOUCHKIT is not set
> CONFIG_MOUSE_SERIAL=m
> CONFIG_MOUSE_APPLETOUCH=m
> CONFIG_MOUSE_BCM5974=m
> CONFIG_MOUSE_VSXXXAA=m
> CONFIG_MOUSE_GPIO=m
> CONFIG_MOUSE_SYNAPTICS_I2C=m
> CONFIG_INPUT_JOYSTICK=y
> CONFIG_JOYSTICK_ANALOG=m
> CONFIG_JOYSTICK_A3D=m
> CONFIG_JOYSTICK_ADI=m
> CONFIG_JOYSTICK_COBRA=m
> CONFIG_JOYSTICK_GF2K=m
> CONFIG_JOYSTICK_GRIP=m
> CONFIG_JOYSTICK_GRIP_MP=m
> CONFIG_JOYSTICK_GUILLEMOT=m
> CONFIG_JOYSTICK_INTERACT=m
> CONFIG_JOYSTICK_SIDEWINDER=m
> CONFIG_JOYSTICK_TMDC=m
> CONFIG_JOYSTICK_IFORCE=m
> CONFIG_JOYSTICK_IFORCE_USB=y
> CONFIG_JOYSTICK_IFORCE_232=y
> CONFIG_JOYSTICK_WARRIOR=m
> CONFIG_JOYSTICK_MAGELLAN=m
> CONFIG_JOYSTICK_SPACEORB=m
> CONFIG_JOYSTICK_SPACEBALL=m
> CONFIG_JOYSTICK_STINGER=m
> CONFIG_JOYSTICK_TWIDJOY=m
> CONFIG_JOYSTICK_ZHENHUA=m
> CONFIG_JOYSTICK_DB9=m
> CONFIG_JOYSTICK_GAMECON=m
> CONFIG_JOYSTICK_TURBOGRAFX=m
> CONFIG_JOYSTICK_JOYDUMP=m
> CONFIG_JOYSTICK_XPAD=m
> CONFIG_JOYSTICK_XPAD_FF=y
> CONFIG_JOYSTICK_XPAD_LEDS=y
> CONFIG_JOYSTICK_WALKERA0701=m
> CONFIG_INPUT_TABLET=y
> CONFIG_TABLET_USB_ACECAD=m
> CONFIG_TABLET_USB_AIPTEK=m
> CONFIG_TABLET_USB_GTCO=m
> CONFIG_TABLET_USB_KBTAB=m
> CONFIG_TABLET_USB_WACOM=m
> CONFIG_INPUT_TOUCHSCREEN=y
> CONFIG_TOUCHSCREEN_88PM860X=m
> CONFIG_TOUCHSCREEN_ADS7846=m
> CONFIG_TOUCHSCREEN_AD7877=m
> CONFIG_TOUCHSCREEN_AD7879=m
> CONFIG_TOUCHSCREEN_AD7879_I2C=m
> CONFIG_TOUCHSCREEN_AD7879_SPI=m
> CONFIG_TOUCHSCREEN_CY8CTMG110=m
> CONFIG_TOUCHSCREEN_DA9034=m
> CONFIG_TOUCHSCREEN_DYNAPRO=m
> CONFIG_TOUCHSCREEN_HAMPSHIRE=m
> CONFIG_TOUCHSCREEN_EETI=m
> CONFIG_TOUCHSCREEN_FUJITSU=m
> CONFIG_TOUCHSCREEN_GUNZE=m
> CONFIG_TOUCHSCREEN_ELO=m
> CONFIG_TOUCHSCREEN_WACOM_W8001=m
> CONFIG_TOUCHSCREEN_MCS5000=m
> CONFIG_TOUCHSCREEN_MTOUCH=m
> CONFIG_TOUCHSCREEN_INEXIO=m
> CONFIG_TOUCHSCREEN_MK712=m
> CONFIG_TOUCHSCREEN_PENMOUNT=m
> CONFIG_TOUCHSCREEN_QT602240=m
> CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
> CONFIG_TOUCHSCREEN_TOUCHWIN=m
> CONFIG_TOUCHSCREEN_UCB1400=m
> CONFIG_TOUCHSCREEN_WM97XX=m
> CONFIG_TOUCHSCREEN_WM9705=y
> CONFIG_TOUCHSCREEN_WM9712=y
> CONFIG_TOUCHSCREEN_WM9713=y
> CONFIG_TOUCHSCREEN_USB_COMPOSITE=m
> CONFIG_TOUCHSCREEN_MC13783=m
> CONFIG_TOUCHSCREEN_USB_EGALAX=y
> CONFIG_TOUCHSCREEN_USB_PANJIT=y
> CONFIG_TOUCHSCREEN_USB_3M=y
> CONFIG_TOUCHSCREEN_USB_ITM=y
> CONFIG_TOUCHSCREEN_USB_ETURBO=y
> CONFIG_TOUCHSCREEN_USB_GUNZE=y
> CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
> CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
> CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
> CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
> CONFIG_TOUCHSCREEN_USB_GOTOP=y
> CONFIG_TOUCHSCREEN_USB_JASTEC=y
> CONFIG_TOUCHSCREEN_USB_E2I=y
> CONFIG_TOUCHSCREEN_USB_ZYTRONIC=y
> CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
> CONFIG_TOUCHSCREEN_USB_NEXIO=y
> CONFIG_TOUCHSCREEN_TOUCHIT213=m
> CONFIG_TOUCHSCREEN_TSC2007=m
> CONFIG_TOUCHSCREEN_TPS6507X=m
> CONFIG_TOUCHSCREEN_STMPE=m
> CONFIG_INPUT_MISC=y
> CONFIG_INPUT_88PM860X_ONKEY=m
> CONFIG_INPUT_AD714X=m
> CONFIG_INPUT_AD714X_I2C=m
> CONFIG_INPUT_AD714X_SPI=m
> CONFIG_INPUT_PCSPKR=m
> CONFIG_INPUT_MAX8925_ONKEY=m
> # CONFIG_INPUT_APANEL is not set
> CONFIG_INPUT_ATLAS_BTNS=m
> CONFIG_INPUT_ATI_REMOTE=m
> CONFIG_INPUT_ATI_REMOTE2=m
> CONFIG_INPUT_KEYSPAN_REMOTE=m
> CONFIG_INPUT_POWERMATE=m
> CONFIG_INPUT_YEALINK=m
> CONFIG_INPUT_CM109=m
> CONFIG_INPUT_TWL4030_PWRBUTTON=m
> CONFIG_INPUT_TWL4030_VIBRA=m
> CONFIG_INPUT_UINPUT=m
> CONFIG_INPUT_WINBOND_CIR=m
> CONFIG_INPUT_PCF50633_PMU=m
> CONFIG_INPUT_PCF8574=m
> CONFIG_INPUT_GPIO_ROTARY_ENCODER=m
> CONFIG_INPUT_WM831X_ON=m
> CONFIG_INPUT_ADXL34X=m
> CONFIG_INPUT_ADXL34X_I2C=m
> CONFIG_INPUT_ADXL34X_SPI=m
> 
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=y
> CONFIG_SERIO_I8042=y
> CONFIG_SERIO_SERPORT=m
> CONFIG_SERIO_CT82C710=m
> CONFIG_SERIO_PARKBD=m
> CONFIG_SERIO_PCIPS2=m
> CONFIG_SERIO_LIBPS2=y
> CONFIG_SERIO_RAW=m
> CONFIG_SERIO_ALTERA_PS2=m
> CONFIG_GAMEPORT=m
> CONFIG_GAMEPORT_NS558=m
> CONFIG_GAMEPORT_L4=m
> CONFIG_GAMEPORT_EMU10K1=m
> CONFIG_GAMEPORT_FM801=m
> 
> #
> # Character devices
> #
> CONFIG_VT=y
> CONFIG_CONSOLE_TRANSLATIONS=y
> CONFIG_VT_CONSOLE=y
> CONFIG_HW_CONSOLE=y
> CONFIG_VT_HW_CONSOLE_BINDING=y
> # CONFIG_DEVKMEM is not set
> CONFIG_SERIAL_NONSTANDARD=y
> CONFIG_COMPUTONE=m
> CONFIG_ROCKETPORT=m
> CONFIG_CYCLADES=m
> # CONFIG_CYZ_INTR is not set
> CONFIG_DIGIEPCA=m
> CONFIG_MOXA_INTELLIO=m
> CONFIG_MOXA_SMARTIO=m
> # CONFIG_ISI is not set
> CONFIG_SYNCLINK=m
> CONFIG_SYNCLINKMP=m
> CONFIG_SYNCLINK_GT=m
> CONFIG_N_HDLC=m
> # CONFIG_N_GSM is not set
> CONFIG_RISCOM8=m
> CONFIG_SPECIALIX=m
> CONFIG_STALDRV=y
> CONFIG_STALLION=m
> CONFIG_ISTALLION=m
> CONFIG_NOZOMI=m
> 
> #
> # Serial drivers
> #
> CONFIG_SERIAL_8250=y
> CONFIG_SERIAL_8250_CONSOLE=y
> CONFIG_FIX_EARLYCON_MEM=y
> CONFIG_SERIAL_8250_PCI=y
> CONFIG_SERIAL_8250_PNP=y
> CONFIG_SERIAL_8250_CS=m
> CONFIG_SERIAL_8250_NR_UARTS=48
> CONFIG_SERIAL_8250_RUNTIME_UARTS=4
> CONFIG_SERIAL_8250_EXTENDED=y
> CONFIG_SERIAL_8250_MANY_PORTS=y
> CONFIG_SERIAL_8250_SHARE_IRQ=y
> # CONFIG_SERIAL_8250_DETECT_IRQ is not set
> CONFIG_SERIAL_8250_RSA=y
> 
> #
> # Non-8250 serial port support
> #
> CONFIG_SERIAL_MAX3100=m
> CONFIG_SERIAL_MAX3107=m
> CONFIG_SERIAL_MRST_MAX3110=m
> # CONFIG_MRST_MAX3110_IRQ is not set
> CONFIG_SERIAL_MFD_HSU=m
> CONFIG_SERIAL_UARTLITE=m
> CONFIG_SERIAL_CORE=y
> CONFIG_SERIAL_CORE_CONSOLE=y
> CONFIG_CONSOLE_POLL=y
> CONFIG_SERIAL_JSM=m
> CONFIG_SERIAL_TIMBERDALE=m
> CONFIG_SERIAL_ALTERA_JTAGUART=m
> CONFIG_SERIAL_ALTERA_UART=m
> CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
> CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
> CONFIG_UNIX98_PTYS=y
> CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
> CONFIG_LEGACY_PTYS=y
> CONFIG_LEGACY_PTY_COUNT=0
> CONFIG_PRINTER=m
> # CONFIG_LP_CONSOLE is not set
> CONFIG_PPDEV=m
> CONFIG_HVC_DRIVER=y
> CONFIG_HVC_IRQ=y
> CONFIG_HVC_XEN=y
> CONFIG_VIRTIO_CONSOLE=m
> CONFIG_IPMI_HANDLER=m
> # CONFIG_IPMI_PANIC_EVENT is not set
> CONFIG_IPMI_DEVICE_INTERFACE=m
> CONFIG_IPMI_SI=m
> CONFIG_IPMI_WATCHDOG=m
> CONFIG_IPMI_POWEROFF=m
> CONFIG_HW_RANDOM=y
> CONFIG_HW_RANDOM_TIMERIOMEM=m
> CONFIG_HW_RANDOM_INTEL=m
> CONFIG_HW_RANDOM_AMD=m
> CONFIG_HW_RANDOM_VIA=m
> CONFIG_HW_RANDOM_VIRTIO=m
> CONFIG_NVRAM=m
> CONFIG_R3964=m
> CONFIG_APPLICOM=m
> 
> #
> # PCMCIA character devices
> #
> CONFIG_SYNCLINK_CS=m
> CONFIG_CARDMAN_4000=m
> CONFIG_CARDMAN_4040=m
> CONFIG_IPWIRELESS=m
> CONFIG_MWAVE=m
> CONFIG_RAW_DRIVER=m
> CONFIG_MAX_RAW_DEVS=256
> CONFIG_HPET=y
> CONFIG_HPET_MMAP=y
> CONFIG_HANGCHECK_TIMER=m
> CONFIG_TCG_TPM=m
> CONFIG_TCG_TIS=m
> CONFIG_TCG_NSC=m
> CONFIG_TCG_ATMEL=m
> CONFIG_TCG_INFINEON=m
> CONFIG_TELCLOCK=m
> CONFIG_DEVPORT=y
> CONFIG_RAMOOPS=m
> CONFIG_I2C=y
> CONFIG_I2C_BOARDINFO=y
> CONFIG_I2C_COMPAT=y
> CONFIG_I2C_CHARDEV=m
> CONFIG_I2C_MUX=m
> 
> #
> # Multiplexer I2C Chip support
> #
> CONFIG_I2C_MUX_PCA954x=m
> # CONFIG_I2C_HELPER_AUTO is not set
> CONFIG_I2C_SMBUS=m
> 
> #
> # I2C Algorithms
> #
> CONFIG_I2C_ALGOBIT=m
> CONFIG_I2C_ALGOPCF=m
> CONFIG_I2C_ALGOPCA=m
> 
> #
> # I2C Hardware Bus support
> #
> 
> #
> # PC SMBus host controller drivers
> #
> CONFIG_I2C_ALI1535=m
> CONFIG_I2C_ALI1563=m
> CONFIG_I2C_ALI15X3=m
> CONFIG_I2C_AMD756=m
> CONFIG_I2C_AMD756_S4882=m
> CONFIG_I2C_AMD8111=m
> CONFIG_I2C_I801=m
> CONFIG_I2C_ISCH=m
> CONFIG_I2C_PIIX4=m
> CONFIG_I2C_NFORCE2=m
> CONFIG_I2C_NFORCE2_S4985=m
> CONFIG_I2C_SIS5595=m
> CONFIG_I2C_SIS630=m
> CONFIG_I2C_SIS96X=m
> CONFIG_I2C_VIA=m
> CONFIG_I2C_VIAPRO=m
> 
> #
> # ACPI drivers
> #
> CONFIG_I2C_SCMI=m
> 
> #
> # I2C system bus drivers (mostly embedded / system-on-chip)
> #
> CONFIG_I2C_GPIO=m
> CONFIG_I2C_OCORES=m
> CONFIG_I2C_PCA_PLATFORM=m
> CONFIG_I2C_SIMTEC=m
> CONFIG_I2C_XILINX=m
> 
> #
> # External I2C/SMBus adapter drivers
> #
> CONFIG_I2C_PARPORT=m
> CONFIG_I2C_PARPORT_LIGHT=m
> CONFIG_I2C_TAOS_EVM=m
> CONFIG_I2C_TINY_USB=m
> 
> #
> # Other I2C/SMBus bus drivers
> #
> CONFIG_I2C_STUB=m
> # CONFIG_I2C_DEBUG_CORE is not set
> # CONFIG_I2C_DEBUG_ALGO is not set
> # CONFIG_I2C_DEBUG_BUS is not set
> CONFIG_SPI=y
> # CONFIG_SPI_DEBUG is not set
> CONFIG_SPI_MASTER=y
> 
> #
> # SPI Master Controller Drivers
> #
> CONFIG_SPI_BITBANG=m
> CONFIG_SPI_BUTTERFLY=m
> CONFIG_SPI_GPIO=m
> CONFIG_SPI_LM70_LLP=m
> # CONFIG_SPI_XILINX is not set
> CONFIG_SPI_DESIGNWARE=y
> CONFIG_SPI_DW_PCI=m
> 
> #
> # SPI Protocol Masters
> #
> CONFIG_SPI_SPIDEV=m
> CONFIG_SPI_TLE62X0=m
> 
> #
> # PPS support
> #
> CONFIG_PPS=m
> # CONFIG_PPS_DEBUG is not set
> 
> #
> # PPS clients support
> #
> # CONFIG_PPS_CLIENT_KTIMER is not set
> CONFIG_PPS_CLIENT_LDISC=m
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
> CONFIG_GPIOLIB=y
> # CONFIG_DEBUG_GPIO is not set
> CONFIG_GPIO_SYSFS=y
> CONFIG_GPIO_MAX730X=m
> 
> #
> # Memory mapped GPIO expanders:
> #
> CONFIG_GPIO_IT8761E=m
> CONFIG_GPIO_SCH=m
> 
> #
> # I2C GPIO expanders:
> #
> CONFIG_GPIO_MAX7300=m
> CONFIG_GPIO_MAX732X=m
> CONFIG_GPIO_PCA953X=m
> CONFIG_GPIO_PCF857X=m
> CONFIG_GPIO_SX150X=y
> CONFIG_GPIO_STMPE=y
> CONFIG_GPIO_TC35892=y
> CONFIG_GPIO_TWL4030=m
> CONFIG_GPIO_WM831X=m
> CONFIG_GPIO_WM8350=m
> CONFIG_GPIO_WM8994=m
> CONFIG_GPIO_ADP5520=m
> CONFIG_GPIO_ADP5588=m
> 
> #
> # PCI GPIO expanders:
> #
> CONFIG_GPIO_CS5535=m
> CONFIG_GPIO_LANGWELL=y
> CONFIG_GPIO_TIMBERDALE=y
> CONFIG_GPIO_RDC321X=m
> 
> #
> # SPI GPIO expanders:
> #
> CONFIG_GPIO_MAX7301=m
> CONFIG_GPIO_MCP23S08=m
> CONFIG_GPIO_MC33880=m
> 
> #
> # AC97 GPIO expanders:
> #
> CONFIG_GPIO_UCB1400=y
> 
> #
> # MODULbus GPIO expanders:
> #
> CONFIG_GPIO_JANZ_TTL=m
> CONFIG_W1=m
> CONFIG_W1_CON=y
> 
> #
> # 1-wire Bus Masters
> #
> CONFIG_W1_MASTER_MATROX=m
> CONFIG_W1_MASTER_DS2490=m
> CONFIG_W1_MASTER_DS2482=m
> CONFIG_W1_MASTER_GPIO=m
> 
> #
> # 1-wire Slaves
> #
> CONFIG_W1_SLAVE_THERM=m
> CONFIG_W1_SLAVE_SMEM=m
> CONFIG_W1_SLAVE_DS2431=m
> CONFIG_W1_SLAVE_DS2433=m
> # CONFIG_W1_SLAVE_DS2433_CRC is not set
> CONFIG_W1_SLAVE_DS2760=m
> CONFIG_W1_SLAVE_BQ27000=m
> CONFIG_POWER_SUPPLY=y
> # CONFIG_POWER_SUPPLY_DEBUG is not set
> CONFIG_PDA_POWER=m
> CONFIG_MAX8925_POWER=m
> CONFIG_WM831X_BACKUP=m
> CONFIG_WM831X_POWER=m
> CONFIG_WM8350_POWER=m
> CONFIG_TEST_POWER=m
> CONFIG_BATTERY_DS2760=m
> CONFIG_BATTERY_DS2782=m
> CONFIG_BATTERY_BQ27x00=m
> CONFIG_BATTERY_DA9030=m
> CONFIG_BATTERY_MAX17040=m
> CONFIG_CHARGER_PCF50633=m
> CONFIG_HWMON=y
> CONFIG_HWMON_VID=m
> # CONFIG_HWMON_DEBUG_CHIP is not set
> 
> #
> # Native drivers
> #
> CONFIG_SENSORS_ABITUGURU=m
> CONFIG_SENSORS_ABITUGURU3=m
> CONFIG_SENSORS_AD7414=m
> CONFIG_SENSORS_AD7418=m
> CONFIG_SENSORS_ADCXX=m
> CONFIG_SENSORS_ADM1021=m
> CONFIG_SENSORS_ADM1025=m
> CONFIG_SENSORS_ADM1026=m
> CONFIG_SENSORS_ADM1029=m
> CONFIG_SENSORS_ADM1031=m
> CONFIG_SENSORS_ADM9240=m
> CONFIG_SENSORS_ADT7411=m
> CONFIG_SENSORS_ADT7462=m
> CONFIG_SENSORS_ADT7470=m
> CONFIG_SENSORS_ADT7475=m
> CONFIG_SENSORS_ASC7621=m
> CONFIG_SENSORS_K8TEMP=m
> CONFIG_SENSORS_K10TEMP=m
> CONFIG_SENSORS_ASB100=m
> CONFIG_SENSORS_ATXP1=m
> CONFIG_SENSORS_DS1621=m
> CONFIG_SENSORS_I5K_AMB=m
> CONFIG_SENSORS_F71805F=m
> CONFIG_SENSORS_F71882FG=m
> CONFIG_SENSORS_F75375S=m
> CONFIG_SENSORS_FSCHMD=m
> CONFIG_SENSORS_G760A=m
> CONFIG_SENSORS_GL518SM=m
> CONFIG_SENSORS_GL520SM=m
> CONFIG_SENSORS_CORETEMP=m
> CONFIG_SENSORS_PKGTEMP=m
> CONFIG_SENSORS_IBMAEM=m
> CONFIG_SENSORS_IBMPEX=m
> CONFIG_SENSORS_IT87=m
> CONFIG_SENSORS_JC42=m
> CONFIG_SENSORS_LM63=m
> CONFIG_SENSORS_LM70=m
> CONFIG_SENSORS_LM73=m
> CONFIG_SENSORS_LM75=m
> CONFIG_SENSORS_LM77=m
> CONFIG_SENSORS_LM78=m
> CONFIG_SENSORS_LM80=m
> CONFIG_SENSORS_LM83=m
> CONFIG_SENSORS_LM85=m
> CONFIG_SENSORS_LM87=m
> CONFIG_SENSORS_LM90=m
> CONFIG_SENSORS_LM92=m
> CONFIG_SENSORS_LM93=m
> CONFIG_SENSORS_LTC4215=m
> CONFIG_SENSORS_LTC4245=m
> CONFIG_SENSORS_LM95241=m
> CONFIG_SENSORS_MAX1111=m
> CONFIG_SENSORS_MAX1619=m
> CONFIG_SENSORS_MAX6650=m
> CONFIG_SENSORS_PC87360=m
> CONFIG_SENSORS_PC87427=m
> CONFIG_SENSORS_PCF8591=m
> CONFIG_SENSORS_SHT15=m
> CONFIG_SENSORS_SIS5595=m
> CONFIG_SENSORS_SMM665=m
> CONFIG_SENSORS_DME1737=m
> CONFIG_SENSORS_EMC1403=m
> CONFIG_SENSORS_EMC2103=m
> CONFIG_SENSORS_SMSC47M1=m
> CONFIG_SENSORS_SMSC47M192=m
> CONFIG_SENSORS_SMSC47B397=m
> CONFIG_SENSORS_ADS7828=m
> CONFIG_SENSORS_ADS7871=m
> CONFIG_SENSORS_AMC6821=m
> CONFIG_SENSORS_THMC50=m
> CONFIG_SENSORS_TMP102=m
> CONFIG_SENSORS_TMP401=m
> CONFIG_SENSORS_TMP421=m
> CONFIG_SENSORS_VIA_CPUTEMP=m
> CONFIG_SENSORS_VIA686A=m
> CONFIG_SENSORS_VT1211=m
> CONFIG_SENSORS_VT8231=m
> CONFIG_SENSORS_W83781D=m
> CONFIG_SENSORS_W83791D=m
> CONFIG_SENSORS_W83792D=m
> CONFIG_SENSORS_W83793=m
> CONFIG_SENSORS_W83L785TS=m
> CONFIG_SENSORS_W83L786NG=m
> CONFIG_SENSORS_W83627HF=m
> CONFIG_SENSORS_W83627EHF=m
> CONFIG_SENSORS_WM831X=m
> CONFIG_SENSORS_WM8350=m
> CONFIG_SENSORS_HDAPS=m
> CONFIG_SENSORS_LIS3_I2C=m
> CONFIG_SENSORS_APPLESMC=m
> CONFIG_SENSORS_MC13783_ADC=m
> 
> #
> # ACPI drivers
> #
> CONFIG_SENSORS_ATK0110=m
> CONFIG_SENSORS_LIS3LV02D=m
> CONFIG_THERMAL=y
> CONFIG_THERMAL_HWMON=y
> CONFIG_WATCHDOG=y
> # CONFIG_WATCHDOG_NOWAYOUT is not set
> 
> #
> # Watchdog Device Drivers
> #
> CONFIG_SOFT_WATCHDOG=m
> CONFIG_WM831X_WATCHDOG=m
> CONFIG_WM8350_WATCHDOG=m
> CONFIG_TWL4030_WATCHDOG=m
> CONFIG_ACQUIRE_WDT=m
> CONFIG_ADVANTECH_WDT=m
> CONFIG_ALIM1535_WDT=m
> CONFIG_ALIM7101_WDT=m
> CONFIG_F71808E_WDT=m
> CONFIG_SC520_WDT=m
> CONFIG_SBC_FITPC2_WATCHDOG=m
> CONFIG_EUROTECH_WDT=m
> CONFIG_IB700_WDT=m
> CONFIG_IBMASR=m
> CONFIG_WAFER_WDT=m
> CONFIG_I6300ESB_WDT=m
> CONFIG_ITCO_WDT=m
> CONFIG_ITCO_VENDOR_SUPPORT=y
> CONFIG_IT8712F_WDT=m
> CONFIG_IT87_WDT=m
> # CONFIG_HP_WATCHDOG is not set
> CONFIG_SC1200_WDT=m
> CONFIG_PC87413_WDT=m
> CONFIG_60XX_WDT=m
> CONFIG_SBC8360_WDT=m
> CONFIG_CPU5_WDT=m
> CONFIG_SMSC_SCH311X_WDT=m
> CONFIG_SMSC37B787_WDT=m
> CONFIG_W83627HF_WDT=m
> CONFIG_W83697HF_WDT=m
> CONFIG_W83697UG_WDT=m
> CONFIG_W83877F_WDT=m
> CONFIG_W83977F_WDT=m
> CONFIG_MACHZ_WDT=m
> CONFIG_SBC_EPX_C3_WATCHDOG=m
> 
> #
> # PCI-based Watchdog Cards
> #
> CONFIG_PCIPCWATCHDOG=m
> CONFIG_WDTPCI=m
> 
> #
> # USB-based Watchdog Cards
> #
> CONFIG_USBPCWATCHDOG=m
> CONFIG_SSB_POSSIBLE=y
> 
> #
> # Sonics Silicon Backplane
> #
> CONFIG_SSB=m
> CONFIG_SSB_SPROM=y
> CONFIG_SSB_BLOCKIO=y
> CONFIG_SSB_PCIHOST_POSSIBLE=y
> CONFIG_SSB_PCIHOST=y
> CONFIG_SSB_B43_PCI_BRIDGE=y
> CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
> # CONFIG_SSB_PCMCIAHOST is not set
> CONFIG_SSB_SDIOHOST_POSSIBLE=y
> CONFIG_SSB_SDIOHOST=y
> # CONFIG_SSB_DEBUG is not set
> CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
> CONFIG_SSB_DRIVER_PCICORE=y
> CONFIG_MFD_SUPPORT=y
> CONFIG_MFD_CORE=y
> CONFIG_MFD_88PM860X=y
> CONFIG_MFD_SM501=m
> # CONFIG_MFD_SM501_GPIO is not set
> CONFIG_HTC_PASIC3=m
> CONFIG_HTC_I2CPLD=y
> CONFIG_UCB1400_CORE=m
> CONFIG_TPS65010=m
> CONFIG_TPS6507X=m
> CONFIG_TWL4030_CORE=y
> CONFIG_TWL4030_CODEC=y
> CONFIG_TWL6030_PWM=m
> CONFIG_MFD_STMPE=y
> CONFIG_MFD_TC35892=y
> # CONFIG_MFD_TMIO is not set
> CONFIG_PMIC_DA903X=y
> CONFIG_PMIC_ADP5520=y
> CONFIG_MFD_MAX8925=y
> CONFIG_MFD_MAX8998=y
> CONFIG_MFD_WM8400=m
> CONFIG_MFD_WM831X=y
> CONFIG_MFD_WM8350=y
> CONFIG_MFD_WM8350_I2C=y
> CONFIG_MFD_WM8994=y
> CONFIG_MFD_PCF50633=m
> CONFIG_MFD_MC13783=m
> CONFIG_PCF50633_ADC=m
> CONFIG_PCF50633_GPIO=m
> CONFIG_ABX500_CORE=y
> CONFIG_AB3100_CORE=y
> CONFIG_AB3100_OTP=m
> # CONFIG_EZX_PCAP is not set
> CONFIG_AB8500_CORE=y
> CONFIG_AB3550_CORE=y
> CONFIG_MFD_TIMBERDALE=m
> CONFIG_LPC_SCH=m
> CONFIG_MFD_RDC321X=m
> CONFIG_MFD_JANZ_CMODIO=m
> CONFIG_MFD_TPS6586X=m
> CONFIG_REGULATOR=y
> # CONFIG_REGULATOR_DEBUG is not set
> # CONFIG_REGULATOR_DUMMY is not set
> # CONFIG_REGULATOR_FIXED_VOLTAGE is not set
> CONFIG_REGULATOR_VIRTUAL_CONSUMER=m
> CONFIG_REGULATOR_USERSPACE_CONSUMER=m
> CONFIG_REGULATOR_BQ24022=m
> CONFIG_REGULATOR_MAX1586=m
> CONFIG_REGULATOR_MAX8649=m
> CONFIG_REGULATOR_MAX8660=m
> CONFIG_REGULATOR_MAX8925=m
> CONFIG_REGULATOR_MAX8998=m
> CONFIG_REGULATOR_TWL4030=y
> CONFIG_REGULATOR_WM831X=m
> CONFIG_REGULATOR_WM8350=m
> CONFIG_REGULATOR_WM8400=m
> CONFIG_REGULATOR_WM8994=m
> CONFIG_REGULATOR_DA903X=m
> CONFIG_REGULATOR_PCF50633=m
> CONFIG_REGULATOR_LP3971=m
> CONFIG_REGULATOR_MC13783=m
> CONFIG_REGULATOR_AB3100=m
> CONFIG_REGULATOR_TPS65023=m
> CONFIG_REGULATOR_TPS6507X=m
> CONFIG_REGULATOR_88PM8607=y
> CONFIG_REGULATOR_ISL6271A=m
> CONFIG_REGULATOR_AD5398=m
> CONFIG_REGULATOR_AB8500=y
> CONFIG_REGULATOR_TPS6586X=m
> CONFIG_MEDIA_SUPPORT=m
> 
> #
> # Multimedia core support
> #
> CONFIG_VIDEO_DEV=m
> CONFIG_VIDEO_V4L2_COMMON=m
> CONFIG_VIDEO_ALLOW_V4L1=y
> CONFIG_VIDEO_V4L1_COMPAT=y
> CONFIG_DVB_CORE=m
> CONFIG_VIDEO_MEDIA=m
> 
> #
> # Multimedia drivers
> #
> CONFIG_VIDEO_SAA7146=m
> CONFIG_VIDEO_SAA7146_VV=m
> CONFIG_IR_CORE=m
> CONFIG_VIDEO_IR=m
> CONFIG_LIRC=m
> CONFIG_RC_MAP=m
> CONFIG_IR_NEC_DECODER=m
> CONFIG_IR_RC5_DECODER=m
> CONFIG_IR_RC6_DECODER=m
> CONFIG_IR_JVC_DECODER=m
> CONFIG_IR_SONY_DECODER=m
> CONFIG_IR_LIRC_CODEC=m
> CONFIG_IR_IMON=m
> CONFIG_IR_MCEUSB=m
> CONFIG_IR_ENE=m
> CONFIG_IR_STREAMZAP=m
> CONFIG_MEDIA_ATTACH=y
> CONFIG_MEDIA_TUNER=m
> # CONFIG_MEDIA_TUNER_CUSTOMISE is not set
> CONFIG_MEDIA_TUNER_SIMPLE=m
> CONFIG_MEDIA_TUNER_TDA8290=m
> CONFIG_MEDIA_TUNER_TDA827X=m
> CONFIG_MEDIA_TUNER_TDA18271=m
> CONFIG_MEDIA_TUNER_TDA9887=m
> CONFIG_MEDIA_TUNER_TEA5761=m
> CONFIG_MEDIA_TUNER_TEA5767=m
> CONFIG_MEDIA_TUNER_MT20XX=m
> CONFIG_MEDIA_TUNER_MT2060=m
> CONFIG_MEDIA_TUNER_MT2266=m
> CONFIG_MEDIA_TUNER_MT2131=m
> CONFIG_MEDIA_TUNER_QT1010=m
> CONFIG_MEDIA_TUNER_XC2028=m
> CONFIG_MEDIA_TUNER_XC5000=m
> CONFIG_MEDIA_TUNER_MXL5005S=m
> CONFIG_MEDIA_TUNER_MXL5007T=m
> CONFIG_MEDIA_TUNER_MC44S803=m
> CONFIG_MEDIA_TUNER_MAX2165=m
> CONFIG_VIDEO_V4L2=m
> CONFIG_VIDEO_V4L1=m
> CONFIG_VIDEOBUF_GEN=m
> CONFIG_VIDEOBUF_DMA_SG=m
> CONFIG_VIDEOBUF_VMALLOC=m
> CONFIG_VIDEOBUF_DMA_CONTIG=m
> CONFIG_VIDEOBUF_DVB=m
> CONFIG_VIDEO_BTCX=m
> CONFIG_VIDEO_TVEEPROM=m
> CONFIG_VIDEO_TUNER=m
> CONFIG_V4L2_MEM2MEM_DEV=m
> CONFIG_VIDEO_CAPTURE_DRIVERS=y
> # CONFIG_VIDEO_ADV_DEBUG is not set
> # CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
> CONFIG_VIDEO_HELPER_CHIPS_AUTO=y
> CONFIG_VIDEO_IR_I2C=m
> CONFIG_VIDEO_TVAUDIO=m
> CONFIG_VIDEO_TDA7432=m
> CONFIG_VIDEO_TDA9840=m
> CONFIG_VIDEO_TEA6415C=m
> CONFIG_VIDEO_TEA6420=m
> CONFIG_VIDEO_MSP3400=m
> CONFIG_VIDEO_CS5345=m
> CONFIG_VIDEO_CS53L32A=m
> CONFIG_VIDEO_M52790=m
> CONFIG_VIDEO_WM8775=m
> CONFIG_VIDEO_WM8739=m
> CONFIG_VIDEO_VP27SMPX=m
> CONFIG_VIDEO_SAA6588=m
> CONFIG_VIDEO_BT819=m
> CONFIG_VIDEO_BT856=m
> CONFIG_VIDEO_BT866=m
> CONFIG_VIDEO_KS0127=m
> CONFIG_VIDEO_OV7670=m
> CONFIG_VIDEO_MT9V011=m
> CONFIG_VIDEO_SAA7110=m
> CONFIG_VIDEO_SAA711X=m
> CONFIG_VIDEO_SAA717X=m
> CONFIG_VIDEO_TVP5150=m
> CONFIG_VIDEO_VPX3220=m
> CONFIG_VIDEO_CX25840=m
> CONFIG_VIDEO_CX2341X=m
> CONFIG_VIDEO_SAA7127=m
> CONFIG_VIDEO_SAA7185=m
> CONFIG_VIDEO_ADV7170=m
> CONFIG_VIDEO_ADV7175=m
> CONFIG_VIDEO_UPD64031A=m
> CONFIG_VIDEO_UPD64083=m
> CONFIG_VIDEO_BT848=m
> CONFIG_VIDEO_BT848_DVB=y
> CONFIG_VIDEO_BWQCAM=m
> CONFIG_VIDEO_CQCAM=m
> CONFIG_VIDEO_W9966=m
> CONFIG_VIDEO_CPIA=m
> CONFIG_VIDEO_CPIA_PP=m
> CONFIG_VIDEO_CPIA_USB=m
> CONFIG_VIDEO_CPIA2=m
> CONFIG_VIDEO_SAA5246A=m
> CONFIG_VIDEO_SAA5249=m
> CONFIG_VIDEO_STRADIS=m
> CONFIG_VIDEO_ZORAN=m
> CONFIG_VIDEO_ZORAN_DC30=m
> CONFIG_VIDEO_ZORAN_ZR36060=m
> CONFIG_VIDEO_ZORAN_BUZ=m
> CONFIG_VIDEO_ZORAN_DC10=m
> CONFIG_VIDEO_ZORAN_LML33=m
> CONFIG_VIDEO_ZORAN_LML33R10=m
> CONFIG_VIDEO_ZORAN_AVS6EYES=m
> CONFIG_VIDEO_MEYE=m
> CONFIG_VIDEO_SAA7134=m
> CONFIG_VIDEO_SAA7134_ALSA=m
> CONFIG_VIDEO_SAA7134_DVB=m
> CONFIG_VIDEO_MXB=m
> CONFIG_VIDEO_HEXIUM_ORION=m
> CONFIG_VIDEO_HEXIUM_GEMINI=m
> CONFIG_VIDEO_CX88=m
> CONFIG_VIDEO_CX88_ALSA=m
> CONFIG_VIDEO_CX88_BLACKBIRD=m
> CONFIG_VIDEO_CX88_DVB=m
> CONFIG_VIDEO_CX88_MPEG=m
> CONFIG_VIDEO_CX88_VP3054=m
> CONFIG_VIDEO_CX23885=m
> CONFIG_VIDEO_AU0828=m
> CONFIG_VIDEO_IVTV=m
> CONFIG_VIDEO_FB_IVTV=m
> CONFIG_VIDEO_CX18=m
> CONFIG_VIDEO_CX18_ALSA=m
> CONFIG_VIDEO_SAA7164=m
> CONFIG_VIDEO_CAFE_CCIC=m
> CONFIG_SOC_CAMERA=m
> CONFIG_SOC_CAMERA_MT9M001=m
> CONFIG_SOC_CAMERA_MT9M111=m
> CONFIG_SOC_CAMERA_MT9T031=m
> CONFIG_SOC_CAMERA_MT9T112=m
> CONFIG_SOC_CAMERA_MT9V022=m
> CONFIG_SOC_CAMERA_RJ54N1=m
> CONFIG_SOC_CAMERA_TW9910=m
> CONFIG_SOC_CAMERA_PLATFORM=m
> CONFIG_SOC_CAMERA_OV772X=m
> CONFIG_SOC_CAMERA_OV9640=m
> CONFIG_V4L_USB_DRIVERS=y
> CONFIG_USB_VIDEO_CLASS=m
> CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
> CONFIG_USB_GSPCA=m
> CONFIG_USB_M5602=m
> CONFIG_USB_STV06XX=m
> CONFIG_USB_GL860=m
> CONFIG_USB_GSPCA_BENQ=m
> CONFIG_USB_GSPCA_CONEX=m
> CONFIG_USB_GSPCA_CPIA1=m
> CONFIG_USB_GSPCA_ETOMS=m
> CONFIG_USB_GSPCA_FINEPIX=m
> CONFIG_USB_GSPCA_JEILINJ=m
> CONFIG_USB_GSPCA_MARS=m
> CONFIG_USB_GSPCA_MR97310A=m
> CONFIG_USB_GSPCA_OV519=m
> CONFIG_USB_GSPCA_OV534=m
> CONFIG_USB_GSPCA_OV534_9=m
> CONFIG_USB_GSPCA_PAC207=m
> CONFIG_USB_GSPCA_PAC7302=m
> CONFIG_USB_GSPCA_PAC7311=m
> CONFIG_USB_GSPCA_SN9C2028=m
> CONFIG_USB_GSPCA_SN9C20X=m
> CONFIG_USB_GSPCA_SONIXB=m
> CONFIG_USB_GSPCA_SONIXJ=m
> CONFIG_USB_GSPCA_SPCA500=m
> CONFIG_USB_GSPCA_SPCA501=m
> CONFIG_USB_GSPCA_SPCA505=m
> CONFIG_USB_GSPCA_SPCA506=m
> CONFIG_USB_GSPCA_SPCA508=m
> CONFIG_USB_GSPCA_SPCA561=m
> CONFIG_USB_GSPCA_SPCA1528=m
> CONFIG_USB_GSPCA_SQ905=m
> CONFIG_USB_GSPCA_SQ905C=m
> CONFIG_USB_GSPCA_SQ930X=m
> CONFIG_USB_GSPCA_STK014=m
> CONFIG_USB_GSPCA_STV0680=m
> CONFIG_USB_GSPCA_SUNPLUS=m
> CONFIG_USB_GSPCA_T613=m
> CONFIG_USB_GSPCA_TV8532=m
> CONFIG_USB_GSPCA_VC032X=m
> CONFIG_USB_GSPCA_ZC3XX=m
> CONFIG_VIDEO_PVRUSB2=m
> CONFIG_VIDEO_PVRUSB2_SYSFS=y
> CONFIG_VIDEO_PVRUSB2_DVB=y
> # CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
> CONFIG_VIDEO_HDPVR=m
> CONFIG_VIDEO_EM28XX=m
> CONFIG_VIDEO_EM28XX_ALSA=m
> CONFIG_VIDEO_EM28XX_DVB=m
> CONFIG_VIDEO_TLG2300=m
> CONFIG_VIDEO_CX231XX=m
> CONFIG_VIDEO_CX231XX_ALSA=m
> CONFIG_VIDEO_CX231XX_DVB=m
> CONFIG_VIDEO_USBVISION=m
> CONFIG_VIDEO_USBVIDEO=m
> CONFIG_USB_VICAM=m
> CONFIG_USB_IBMCAM=m
> CONFIG_USB_KONICAWC=m
> CONFIG_USB_ET61X251=m
> CONFIG_USB_SE401=m
> CONFIG_USB_SN9C102=m
> CONFIG_USB_PWC=m
> # CONFIG_USB_PWC_DEBUG is not set
> CONFIG_USB_PWC_INPUT_EVDEV=y
> CONFIG_USB_ZR364XX=m
> CONFIG_USB_STKWEBCAM=m
> CONFIG_USB_S2255=m
> CONFIG_V4L_MEM2MEM_DRIVERS=y
> CONFIG_VIDEO_MEM2MEM_TESTDEV=m
> CONFIG_RADIO_ADAPTERS=y
> CONFIG_RADIO_GEMTEK_PCI=m
> CONFIG_RADIO_MAXIRADIO=m
> CONFIG_RADIO_MAESTRO=m
> CONFIG_I2C_SI4713=m
> CONFIG_RADIO_SI4713=m
> CONFIG_USB_DSBR=m
> CONFIG_RADIO_SI470X=y
> CONFIG_USB_SI470X=m
> CONFIG_I2C_SI470X=m
> CONFIG_USB_MR800=m
> CONFIG_RADIO_TEA5764=m
> CONFIG_RADIO_SAA7706H=m
> CONFIG_RADIO_TEF6862=m
> CONFIG_RADIO_TIMBERDALE=m
> CONFIG_DVB_MAX_ADAPTERS=8
> CONFIG_DVB_DYNAMIC_MINORS=y
> CONFIG_DVB_CAPTURE_DRIVERS=y
> 
> #
> # Supported SAA7146 based PCI Adapters
> #
> CONFIG_TTPCI_EEPROM=m
> CONFIG_DVB_AV7110=m
> CONFIG_DVB_AV7110_OSD=y
> CONFIG_DVB_BUDGET_CORE=m
> CONFIG_DVB_BUDGET=m
> CONFIG_DVB_BUDGET_CI=m
> CONFIG_DVB_BUDGET_AV=m
> CONFIG_DVB_BUDGET_PATCH=m
> 
> #
> # Supported USB Adapters
> #
> CONFIG_DVB_USB=m
> # CONFIG_DVB_USB_DEBUG is not set
> CONFIG_DVB_USB_A800=m
> CONFIG_DVB_USB_DIBUSB_MB=m
> # CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
> CONFIG_DVB_USB_DIBUSB_MC=m
> CONFIG_DVB_USB_DIB0700=m
> CONFIG_DVB_USB_UMT_010=m
> CONFIG_DVB_USB_CXUSB=m
> CONFIG_DVB_USB_M920X=m
> CONFIG_DVB_USB_GL861=m
> CONFIG_DVB_USB_AU6610=m
> CONFIG_DVB_USB_DIGITV=m
> CONFIG_DVB_USB_VP7045=m
> CONFIG_DVB_USB_VP702X=m
> CONFIG_DVB_USB_GP8PSK=m
> CONFIG_DVB_USB_NOVA_T_USB2=m
> CONFIG_DVB_USB_TTUSB2=m
> CONFIG_DVB_USB_DTT200U=m
> CONFIG_DVB_USB_OPERA1=m
> CONFIG_DVB_USB_AF9005=m
> CONFIG_DVB_USB_AF9005_REMOTE=m
> CONFIG_DVB_USB_DW2102=m
> CONFIG_DVB_USB_CINERGY_T2=m
> CONFIG_DVB_USB_ANYSEE=m
> CONFIG_DVB_USB_DTV5100=m
> CONFIG_DVB_USB_AF9015=m
> CONFIG_DVB_USB_CE6230=m
> CONFIG_DVB_USB_FRIIO=m
> # CONFIG_DVB_USB_EC168 is not set
> CONFIG_DVB_USB_AZ6027=m
> CONFIG_DVB_TTUSB_BUDGET=m
> CONFIG_DVB_TTUSB_DEC=m
> CONFIG_SMS_SIANO_MDTV=m
> 
> #
> # Siano module components
> #
> CONFIG_SMS_USB_DRV=m
> CONFIG_SMS_SDIO_DRV=m
> 
> #
> # Supported FlexCopII (B2C2) Adapters
> #
> CONFIG_DVB_B2C2_FLEXCOP=m
> CONFIG_DVB_B2C2_FLEXCOP_PCI=m
> CONFIG_DVB_B2C2_FLEXCOP_USB=m
> # CONFIG_DVB_B2C2_FLEXCOP_DEBUG is not set
> 
> #
> # Supported BT878 Adapters
> #
> CONFIG_DVB_BT8XX=m
> 
> #
> # Supported Pluto2 Adapters
> #
> CONFIG_DVB_PLUTO2=m
> 
> #
> # Supported SDMC DM1105 Adapters
> #
> CONFIG_DVB_DM1105=m
> 
> #
> # Supported FireWire (IEEE 1394) Adapters
> #
> CONFIG_DVB_FIREDTV=m
> CONFIG_DVB_FIREDTV_FIREWIRE=y
> CONFIG_DVB_FIREDTV_IEEE1394=y
> CONFIG_DVB_FIREDTV_INPUT=y
> 
> #
> # Supported Earthsoft PT1 Adapters
> #
> CONFIG_DVB_PT1=m
> 
> #
> # Supported Mantis Adapters
> #
> CONFIG_MANTIS_CORE=m
> CONFIG_DVB_MANTIS=m
> CONFIG_DVB_HOPPER=m
> 
> #
> # Supported nGene Adapters
> #
> CONFIG_DVB_NGENE=m
> 
> #
> # Supported DVB Frontends
> #
> # CONFIG_DVB_FE_CUSTOMISE is not set
> CONFIG_DVB_STB0899=m
> CONFIG_DVB_STB6100=m
> CONFIG_DVB_STV090x=m
> CONFIG_DVB_STV6110x=m
> CONFIG_DVB_CX24110=m
> CONFIG_DVB_CX24123=m
> CONFIG_DVB_MT312=m
> CONFIG_DVB_ZL10036=m
> CONFIG_DVB_ZL10039=m
> CONFIG_DVB_S5H1420=m
> CONFIG_DVB_STV0288=m
> CONFIG_DVB_STB6000=m
> CONFIG_DVB_STV0299=m
> CONFIG_DVB_STV6110=m
> CONFIG_DVB_STV0900=m
> CONFIG_DVB_TDA8083=m
> CONFIG_DVB_TDA10086=m
> CONFIG_DVB_TDA8261=m
> CONFIG_DVB_VES1X93=m
> CONFIG_DVB_TUNER_ITD1000=m
> CONFIG_DVB_TUNER_CX24113=m
> CONFIG_DVB_TDA826X=m
> CONFIG_DVB_TUA6100=m
> CONFIG_DVB_CX24116=m
> CONFIG_DVB_SI21XX=m
> CONFIG_DVB_DS3000=m
> CONFIG_DVB_MB86A16=m
> CONFIG_DVB_SP8870=m
> CONFIG_DVB_SP887X=m
> CONFIG_DVB_CX22700=m
> CONFIG_DVB_CX22702=m
> CONFIG_DVB_L64781=m
> CONFIG_DVB_TDA1004X=m
> CONFIG_DVB_NXT6000=m
> CONFIG_DVB_MT352=m
> CONFIG_DVB_ZL10353=m
> CONFIG_DVB_DIB3000MB=m
> CONFIG_DVB_DIB3000MC=m
> CONFIG_DVB_DIB7000M=m
> CONFIG_DVB_DIB7000P=m
> CONFIG_DVB_TDA10048=m
> CONFIG_DVB_AF9013=m
> CONFIG_DVB_VES1820=m
> CONFIG_DVB_TDA10021=m
> CONFIG_DVB_TDA10023=m
> CONFIG_DVB_STV0297=m
> CONFIG_DVB_NXT200X=m
> CONFIG_DVB_OR51211=m
> CONFIG_DVB_OR51132=m
> CONFIG_DVB_BCM3510=m
> CONFIG_DVB_LGDT330X=m
> CONFIG_DVB_LGDT3305=m
> CONFIG_DVB_S5H1409=m
> CONFIG_DVB_AU8522=m
> CONFIG_DVB_S5H1411=m
> CONFIG_DVB_DIB8000=m
> CONFIG_DVB_PLL=m
> CONFIG_DVB_TUNER_DIB0070=m
> CONFIG_DVB_TUNER_DIB0090=m
> CONFIG_DVB_LNBP21=m
> CONFIG_DVB_ISL6405=m
> CONFIG_DVB_ISL6421=m
> CONFIG_DVB_ISL6423=m
> CONFIG_DVB_LGS8GXX=m
> CONFIG_DVB_ATBM8830=m
> CONFIG_DVB_TDA665x=m
> CONFIG_DAB=y
> CONFIG_USB_DABUSB=m
> 
> #
> # Graphics support
> #
> CONFIG_AGP=y
> CONFIG_AGP_AMD64=y
> CONFIG_AGP_INTEL=m
> CONFIG_AGP_SIS=m
> CONFIG_AGP_VIA=m
> CONFIG_VGA_ARB=y
> CONFIG_VGA_ARB_MAX_GPUS=16
> CONFIG_VGA_SWITCHEROO=y
> CONFIG_DRM=m
> CONFIG_DRM_KMS_HELPER=m
> CONFIG_DRM_TTM=m
> CONFIG_DRM_TDFX=m
> CONFIG_DRM_R128=m
> CONFIG_DRM_RADEON=m
> CONFIG_DRM_RADEON_KMS=y
> CONFIG_DRM_I810=m
> CONFIG_DRM_I830=m
> CONFIG_DRM_I915=m
> CONFIG_DRM_I915_KMS=y
> CONFIG_DRM_MGA=m
> CONFIG_DRM_SIS=m
> CONFIG_DRM_VIA=m
> CONFIG_DRM_SAVAGE=m
> CONFIG_VGASTATE=m
> CONFIG_VIDEO_OUTPUT_CONTROL=m
> CONFIG_FB=y
> CONFIG_FIRMWARE_EDID=y
> CONFIG_FB_DDC=m
> CONFIG_FB_BOOT_VESA_SUPPORT=y
> CONFIG_FB_CFB_FILLRECT=y
> CONFIG_FB_CFB_COPYAREA=y
> CONFIG_FB_CFB_IMAGEBLIT=y
> # CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
> CONFIG_FB_SYS_FILLRECT=m
> CONFIG_FB_SYS_COPYAREA=m
> CONFIG_FB_SYS_IMAGEBLIT=m
> # CONFIG_FB_FOREIGN_ENDIAN is not set
> CONFIG_FB_SYS_FOPS=m
> CONFIG_FB_DEFERRED_IO=y
> CONFIG_FB_HECUBA=m
> CONFIG_FB_SVGALIB=m
> # CONFIG_FB_MACMODES is not set
> CONFIG_FB_BACKLIGHT=y
> CONFIG_FB_MODE_HELPERS=y
> CONFIG_FB_TILEBLITTING=y
> 
> #
> # Frame buffer hardware drivers
> #
> CONFIG_FB_CIRRUS=m
> CONFIG_FB_PM2=m
> CONFIG_FB_PM2_FIFO_DISCONNECT=y
> CONFIG_FB_CYBER2000=m
> CONFIG_FB_ARC=m
> CONFIG_FB_ASILIANT=y
> CONFIG_FB_IMSTT=y
> CONFIG_FB_VGA16=m
> CONFIG_FB_UVESA=m
> CONFIG_FB_VESA=y
> CONFIG_FB_EFI=y
> CONFIG_FB_N411=m
> CONFIG_FB_HGA=m
> # CONFIG_FB_HGA_ACCEL is not set
> CONFIG_FB_S1D13XXX=m
> CONFIG_FB_NVIDIA=m
> CONFIG_FB_NVIDIA_I2C=y
> # CONFIG_FB_NVIDIA_DEBUG is not set
> CONFIG_FB_NVIDIA_BACKLIGHT=y
> CONFIG_FB_RIVA=m
> CONFIG_FB_RIVA_I2C=y
> # CONFIG_FB_RIVA_DEBUG is not set
> CONFIG_FB_RIVA_BACKLIGHT=y
> CONFIG_FB_LE80578=m
> CONFIG_FB_CARILLO_RANCH=m
> CONFIG_FB_MATROX=m
> CONFIG_FB_MATROX_MILLENIUM=y
> CONFIG_FB_MATROX_MYSTIQUE=y
> CONFIG_FB_MATROX_G=y
> CONFIG_FB_MATROX_I2C=m
> CONFIG_FB_MATROX_MAVEN=m
> CONFIG_FB_RADEON=m
> CONFIG_FB_RADEON_I2C=y
> CONFIG_FB_RADEON_BACKLIGHT=y
> # CONFIG_FB_RADEON_DEBUG is not set
> CONFIG_FB_ATY128=m
> CONFIG_FB_ATY128_BACKLIGHT=y
> CONFIG_FB_ATY=m
> CONFIG_FB_ATY_CT=y
> CONFIG_FB_ATY_GENERIC_LCD=y
> CONFIG_FB_ATY_GX=y
> CONFIG_FB_ATY_BACKLIGHT=y
> CONFIG_FB_S3=m
> CONFIG_FB_SAVAGE=m
> CONFIG_FB_SAVAGE_I2C=y
> CONFIG_FB_SAVAGE_ACCEL=y
> CONFIG_FB_SIS=m
> CONFIG_FB_SIS_300=y
> CONFIG_FB_SIS_315=y
> CONFIG_FB_VIA=m
> # CONFIG_FB_VIA_DIRECT_PROCFS is not set
> CONFIG_FB_NEOMAGIC=m
> CONFIG_FB_KYRO=m
> CONFIG_FB_3DFX=m
> # CONFIG_FB_3DFX_ACCEL is not set
> CONFIG_FB_3DFX_I2C=y
> CONFIG_FB_VOODOO1=m
> CONFIG_FB_VT8623=m
> CONFIG_FB_TRIDENT=m
> CONFIG_FB_ARK=m
> CONFIG_FB_PM3=m
> CONFIG_FB_CARMINE=m
> CONFIG_FB_CARMINE_DRAM_EVAL=y
> # CONFIG_CARMINE_DRAM_CUSTOM is not set
> CONFIG_FB_GEODE=y
> CONFIG_FB_GEODE_LX=m
> CONFIG_FB_GEODE_GX=m
> CONFIG_FB_GEODE_GX1=m
> CONFIG_FB_TMIO=m
> CONFIG_FB_TMIO_ACCELL=y
> CONFIG_FB_SM501=m
> # CONFIG_FB_VIRTUAL is not set
> CONFIG_XEN_FBDEV_FRONTEND=m
> CONFIG_FB_METRONOME=m
> CONFIG_FB_MB862XX=m
> CONFIG_FB_MB862XX_PCI_GDC=y
> CONFIG_FB_BROADSHEET=m
> CONFIG_BACKLIGHT_LCD_SUPPORT=y
> CONFIG_LCD_CLASS_DEVICE=m
> CONFIG_LCD_L4F00242T03=m
> CONFIG_LCD_LMS283GF05=m
> CONFIG_LCD_LTV350QV=m
> CONFIG_LCD_ILI9320=m
> CONFIG_LCD_TDO24M=m
> CONFIG_LCD_VGG2432A4=m
> CONFIG_LCD_PLATFORM=m
> CONFIG_LCD_S6E63M0=m
> CONFIG_BACKLIGHT_CLASS_DEVICE=y
> CONFIG_BACKLIGHT_GENERIC=m
> CONFIG_BACKLIGHT_PROGEAR=m
> CONFIG_BACKLIGHT_CARILLO_RANCH=m
> CONFIG_BACKLIGHT_DA903X=m
> CONFIG_BACKLIGHT_MAX8925=m
> CONFIG_BACKLIGHT_MBP_NVIDIA=m
> CONFIG_BACKLIGHT_SAHARA=m
> CONFIG_BACKLIGHT_WM831X=m
> CONFIG_BACKLIGHT_ADP5520=m
> CONFIG_BACKLIGHT_ADP8860=m
> CONFIG_BACKLIGHT_88PM860X=m
> CONFIG_BACKLIGHT_PCF50633=m
> 
> #
> # Display device support
> #
> CONFIG_DISPLAY_SUPPORT=m
> 
> #
> # Display hardware drivers
> #
> 
> #
> # Console display driver support
> #
> CONFIG_VGA_CONSOLE=y
> # CONFIG_VGACON_SOFT_SCROLLBACK is not set
> CONFIG_DUMMY_CONSOLE=y
> CONFIG_FRAMEBUFFER_CONSOLE=y
> # CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY is not set
> # CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
> # CONFIG_FONTS is not set
> CONFIG_FONT_8x8=y
> CONFIG_FONT_8x16=y
> # CONFIG_LOGO is not set
> CONFIG_SOUND=m
> # CONFIG_SOUND_OSS_CORE is not set
> CONFIG_SND=m
> CONFIG_SND_TIMER=m
> CONFIG_SND_PCM=m
> CONFIG_SND_HWDEP=m
> CONFIG_SND_RAWMIDI=m
> CONFIG_SND_JACK=y
> CONFIG_SND_SEQUENCER=m
> CONFIG_SND_SEQ_DUMMY=m
> # CONFIG_SND_MIXER_OSS is not set
> # CONFIG_SND_PCM_OSS is not set
> # CONFIG_SND_SEQUENCER_OSS is not set
> CONFIG_SND_HRTIMER=m
> CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
> CONFIG_SND_DYNAMIC_MINORS=y
> CONFIG_SND_SUPPORT_OLD_API=y
> CONFIG_SND_VERBOSE_PROCFS=y
> # CONFIG_SND_VERBOSE_PRINTK is not set
> # CONFIG_SND_DEBUG is not set
> CONFIG_SND_VMASTER=y
> CONFIG_SND_DMA_SGBUF=y
> CONFIG_SND_RAWMIDI_SEQ=m
> CONFIG_SND_OPL3_LIB_SEQ=m
> # CONFIG_SND_OPL4_LIB_SEQ is not set
> # CONFIG_SND_SBAWE_SEQ is not set
> CONFIG_SND_EMU10K1_SEQ=m
> CONFIG_SND_MPU401_UART=m
> CONFIG_SND_OPL3_LIB=m
> CONFIG_SND_VX_LIB=m
> CONFIG_SND_AC97_CODEC=m
> CONFIG_SND_DRIVERS=y
> CONFIG_SND_PCSP=m
> CONFIG_SND_DUMMY=m
> CONFIG_SND_VIRMIDI=m
> CONFIG_SND_MTPAV=m
> CONFIG_SND_MTS64=m
> CONFIG_SND_SERIAL_U16550=m
> CONFIG_SND_MPU401=m
> CONFIG_SND_PORTMAN2X4=m
> CONFIG_SND_AC97_POWER_SAVE=y
> CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
> CONFIG_SND_SB_COMMON=m
> CONFIG_SND_SB16_DSP=m
> CONFIG_SND_PCI=y
> CONFIG_SND_AD1889=m
> CONFIG_SND_ALS300=m
> CONFIG_SND_ALS4000=m
> CONFIG_SND_ALI5451=m
> CONFIG_SND_ASIHPI=m
> CONFIG_SND_ATIIXP=m
> CONFIG_SND_ATIIXP_MODEM=m
> CONFIG_SND_AU8810=m
> CONFIG_SND_AU8820=m
> CONFIG_SND_AU8830=m
> CONFIG_SND_AW2=m
> CONFIG_SND_AZT3328=m
> CONFIG_SND_BT87X=m
> # CONFIG_SND_BT87X_OVERCLOCK is not set
> CONFIG_SND_CA0106=m
> CONFIG_SND_CMIPCI=m
> CONFIG_SND_OXYGEN_LIB=m
> CONFIG_SND_OXYGEN=m
> CONFIG_SND_CS4281=m
> CONFIG_SND_CS46XX=m
> CONFIG_SND_CS46XX_NEW_DSP=y
> CONFIG_SND_CS5530=m
> CONFIG_SND_CS5535AUDIO=m
> CONFIG_SND_CTXFI=m
> CONFIG_SND_DARLA20=m
> CONFIG_SND_GINA20=m
> CONFIG_SND_LAYLA20=m
> CONFIG_SND_DARLA24=m
> CONFIG_SND_GINA24=m
> CONFIG_SND_LAYLA24=m
> CONFIG_SND_MONA=m
> CONFIG_SND_MIA=m
> CONFIG_SND_ECHO3G=m
> CONFIG_SND_INDIGO=m
> CONFIG_SND_INDIGOIO=m
> CONFIG_SND_INDIGODJ=m
> CONFIG_SND_INDIGOIOX=m
> CONFIG_SND_INDIGODJX=m
> CONFIG_SND_EMU10K1=m
> CONFIG_SND_EMU10K1X=m
> CONFIG_SND_ENS1370=m
> CONFIG_SND_ENS1371=m
> CONFIG_SND_ES1938=m
> CONFIG_SND_ES1968=m
> CONFIG_SND_ES1968_INPUT=y
> CONFIG_SND_FM801=m
> CONFIG_SND_FM801_TEA575X_BOOL=y
> CONFIG_SND_FM801_TEA575X=m
> CONFIG_SND_HDA_INTEL=m
> CONFIG_SND_HDA_HWDEP=y
> CONFIG_SND_HDA_RECONFIG=y
> CONFIG_SND_HDA_INPUT_BEEP=y
> CONFIG_SND_HDA_INPUT_BEEP_MODE=0
> CONFIG_SND_HDA_INPUT_JACK=y
> CONFIG_SND_HDA_PATCH_LOADER=y
> CONFIG_SND_HDA_CODEC_REALTEK=y
> CONFIG_SND_HDA_CODEC_ANALOG=y
> CONFIG_SND_HDA_CODEC_SIGMATEL=y
> CONFIG_SND_HDA_CODEC_VIA=y
> CONFIG_SND_HDA_CODEC_ATIHDMI=y
> CONFIG_SND_HDA_CODEC_NVHDMI=y
> CONFIG_SND_HDA_CODEC_INTELHDMI=y
> CONFIG_SND_HDA_ELD=y
> CONFIG_SND_HDA_CODEC_CIRRUS=y
> CONFIG_SND_HDA_CODEC_CONEXANT=y
> CONFIG_SND_HDA_CODEC_CA0110=y
> CONFIG_SND_HDA_CODEC_CMEDIA=y
> CONFIG_SND_HDA_CODEC_SI3054=y
> CONFIG_SND_HDA_GENERIC=y
> CONFIG_SND_HDA_POWER_SAVE=y
> CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
> CONFIG_SND_HDSP=m
> CONFIG_SND_HDSPM=m
> CONFIG_SND_HIFIER=m
> CONFIG_SND_ICE1712=m
> CONFIG_SND_ICE1724=m
> CONFIG_SND_INTEL8X0=m
> CONFIG_SND_INTEL8X0M=m
> CONFIG_SND_KORG1212=m
> CONFIG_SND_LX6464ES=m
> CONFIG_SND_MAESTRO3=m
> CONFIG_SND_MAESTRO3_INPUT=y
> CONFIG_SND_MIXART=m
> CONFIG_SND_NM256=m
> CONFIG_SND_PCXHR=m
> CONFIG_SND_RIPTIDE=m
> CONFIG_SND_RME32=m
> CONFIG_SND_RME96=m
> CONFIG_SND_RME9652=m
> CONFIG_SND_SONICVIBES=m
> CONFIG_SND_TRIDENT=m
> CONFIG_SND_VIA82XX=m
> CONFIG_SND_VIA82XX_MODEM=m
> CONFIG_SND_VIRTUOSO=m
> CONFIG_SND_VX222=m
> CONFIG_SND_YMFPCI=m
> CONFIG_SND_SPI=y
> CONFIG_SND_USB=y
> CONFIG_SND_USB_AUDIO=m
> CONFIG_SND_USB_UA101=m
> CONFIG_SND_USB_USX2Y=m
> CONFIG_SND_USB_CAIAQ=m
> CONFIG_SND_USB_CAIAQ_INPUT=y
> CONFIG_SND_USB_US122L=m
> CONFIG_SND_PCMCIA=y
> CONFIG_SND_VXPOCKET=m
> CONFIG_SND_PDAUDIOCF=m
> CONFIG_SND_SOC=m
> CONFIG_SND_SOC_I2C_AND_SPI=m
> CONFIG_SND_SOC_ALL_CODECS=m
> CONFIG_SND_SOC_WM_HUBS=m
> CONFIG_SND_SOC_AD1836=m
> CONFIG_SND_SOC_AD193X=m
> CONFIG_SND_SOC_AD73311=m
> CONFIG_SND_SOC_ADS117X=m
> CONFIG_SND_SOC_AK4104=m
> CONFIG_SND_SOC_AK4535=m
> CONFIG_SND_SOC_AK4642=m
> CONFIG_SND_SOC_AK4671=m
> CONFIG_SND_SOC_CS42L51=m
> CONFIG_SND_SOC_CS4270=m
> CONFIG_SND_SOC_L3=m
> CONFIG_SND_SOC_DA7210=m
> CONFIG_SND_SOC_PCM3008=m
> CONFIG_SND_SOC_SPDIF=m
> CONFIG_SND_SOC_SSM2602=m
> CONFIG_SND_SOC_TLV320AIC23=m
> CONFIG_SND_SOC_TLV320AIC26=m
> CONFIG_SND_SOC_TLV320AIC3X=m
> CONFIG_SND_SOC_TLV320DAC33=m
> CONFIG_SND_SOC_TWL4030=m
> CONFIG_SND_SOC_TWL6040=m
> CONFIG_SND_SOC_UDA134X=m
> CONFIG_SND_SOC_UDA1380=m
> CONFIG_SND_SOC_WM8350=m
> CONFIG_SND_SOC_WM8400=m
> CONFIG_SND_SOC_WM8510=m
> CONFIG_SND_SOC_WM8523=m
> CONFIG_SND_SOC_WM8580=m
> CONFIG_SND_SOC_WM8711=m
> CONFIG_SND_SOC_WM8727=m
> CONFIG_SND_SOC_WM8728=m
> CONFIG_SND_SOC_WM8731=m
> CONFIG_SND_SOC_WM8741=m
> CONFIG_SND_SOC_WM8750=m
> CONFIG_SND_SOC_WM8753=m
> CONFIG_SND_SOC_WM8776=m
> CONFIG_SND_SOC_WM8900=m
> CONFIG_SND_SOC_WM8903=m
> CONFIG_SND_SOC_WM8904=m
> CONFIG_SND_SOC_WM8940=m
> CONFIG_SND_SOC_WM8955=m
> CONFIG_SND_SOC_WM8960=m
> CONFIG_SND_SOC_WM8961=m
> CONFIG_SND_SOC_WM8971=m
> CONFIG_SND_SOC_WM8974=m
> CONFIG_SND_SOC_WM8978=m
> CONFIG_SND_SOC_WM8988=m
> CONFIG_SND_SOC_WM8990=m
> CONFIG_SND_SOC_WM8993=m
> CONFIG_SND_SOC_WM8994=m
> CONFIG_SND_SOC_WM9081=m
> CONFIG_SND_SOC_MAX9877=m
> CONFIG_SND_SOC_TPA6130A2=m
> CONFIG_SND_SOC_WM2000=m
> CONFIG_SND_SOC_WM9090=m
> # CONFIG_SOUND_PRIME is not set
> CONFIG_AC97_BUS=m
> CONFIG_HID_SUPPORT=y
> CONFIG_HID=m
> CONFIG_HIDRAW=y
> 
> #
> # USB Input Devices
> #
> CONFIG_USB_HID=m
> CONFIG_HID_PID=y
> CONFIG_USB_HIDDEV=y
> 
> #
> # Special HID drivers
> #
> CONFIG_HID_3M_PCT=m
> CONFIG_HID_A4TECH=m
> CONFIG_HID_ACRUX_FF=m
> CONFIG_HID_APPLE=m
> CONFIG_HID_BELKIN=m
> CONFIG_HID_CANDO=m
> CONFIG_HID_CHERRY=m
> CONFIG_HID_CHICONY=m
> CONFIG_HID_PRODIKEYS=m
> CONFIG_HID_CYPRESS=m
> CONFIG_HID_DRAGONRISE=m
> CONFIG_DRAGONRISE_FF=y
> CONFIG_HID_EGALAX=m
> CONFIG_HID_ELECOM=m
> CONFIG_HID_EZKEY=m
> CONFIG_HID_KYE=m
> CONFIG_HID_GYRATION=m
> CONFIG_HID_TWINHAN=m
> CONFIG_HID_KENSINGTON=m
> CONFIG_HID_LOGITECH=m
> CONFIG_LOGITECH_FF=y
> CONFIG_LOGIRUMBLEPAD2_FF=y
> CONFIG_LOGIG940_FF=y
> CONFIG_HID_MAGICMOUSE=m
> CONFIG_HID_MICROSOFT=m
> CONFIG_HID_MOSART=m
> CONFIG_HID_MONTEREY=m
> CONFIG_HID_NTRIG=m
> CONFIG_HID_ORTEK=m
> CONFIG_HID_PANTHERLORD=m
> CONFIG_PANTHERLORD_FF=y
> CONFIG_HID_PETALYNX=m
> CONFIG_HID_PICOLCD=m
> CONFIG_HID_PICOLCD_FB=y
> CONFIG_HID_PICOLCD_BACKLIGHT=y
> CONFIG_HID_PICOLCD_LCD=y
> CONFIG_HID_PICOLCD_LEDS=y
> CONFIG_HID_QUANTA=m
> CONFIG_HID_ROCCAT=m
> CONFIG_HID_ROCCAT_KONE=m
> CONFIG_HID_SAMSUNG=m
> CONFIG_HID_SONY=m
> CONFIG_HID_STANTUM=m
> CONFIG_HID_SUNPLUS=m
> CONFIG_HID_GREENASIA=m
> CONFIG_GREENASIA_FF=y
> CONFIG_HID_SMARTJOYPLUS=m
> CONFIG_SMARTJOYPLUS_FF=y
> CONFIG_HID_TOPSEED=m
> CONFIG_HID_THRUSTMASTER=m
> CONFIG_THRUSTMASTER_FF=y
> CONFIG_HID_WACOM=m
> CONFIG_HID_WACOM_POWER_SUPPLY=y
> CONFIG_HID_ZEROPLUS=m
> CONFIG_ZEROPLUS_FF=y
> CONFIG_HID_ZYDACRON=m
> CONFIG_USB_SUPPORT=y
> CONFIG_USB_ARCH_HAS_HCD=y
> CONFIG_USB_ARCH_HAS_OHCI=y
> CONFIG_USB_ARCH_HAS_EHCI=y
> CONFIG_USB=y
> # CONFIG_USB_DEBUG is not set
> # CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set
> 
> #
> # Miscellaneous USB options
> #
> # CONFIG_USB_DEVICEFS is not set
> # CONFIG_USB_DEVICE_CLASS is not set
> # CONFIG_USB_DYNAMIC_MINORS is not set
> CONFIG_USB_SUSPEND=y
> # CONFIG_USB_OTG is not set
> CONFIG_USB_MON=y
> CONFIG_USB_WUSB=m
> CONFIG_USB_WUSB_CBAF=m
> # CONFIG_USB_WUSB_CBAF_DEBUG is not set
> 
> #
> # USB Host Controller Drivers
> #
> CONFIG_USB_C67X00_HCD=m
> CONFIG_USB_XHCI_HCD=m
> # CONFIG_USB_XHCI_HCD_DEBUGGING is not set
> CONFIG_USB_EHCI_HCD=y
> CONFIG_USB_EHCI_ROOT_HUB_TT=y
> CONFIG_USB_EHCI_TT_NEWSCHED=y
> CONFIG_USB_OXU210HP_HCD=m
> CONFIG_USB_ISP116X_HCD=m
> CONFIG_USB_ISP1760_HCD=m
> CONFIG_USB_ISP1362_HCD=m
> CONFIG_USB_OHCI_HCD=y
> # CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
> # CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
> CONFIG_USB_OHCI_LITTLE_ENDIAN=y
> CONFIG_USB_UHCI_HCD=y
> CONFIG_USB_U132_HCD=m
> CONFIG_USB_SL811_HCD=m
> CONFIG_USB_SL811_CS=m
> CONFIG_USB_R8A66597_HCD=m
> CONFIG_USB_WHCI_HCD=m
> CONFIG_USB_HWA_HCD=m
> 
> #
> # USB Device Class drivers
> #
> CONFIG_USB_ACM=m
> CONFIG_USB_PRINTER=m
> CONFIG_USB_WDM=m
> CONFIG_USB_TMC=m
> 
> #
> # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
> #
> 
> #
> # also be needed; see USB_STORAGE Help for more info
> #
> CONFIG_USB_STORAGE=m
> # CONFIG_USB_STORAGE_DEBUG is not set
> CONFIG_USB_STORAGE_DATAFAB=m
> CONFIG_USB_STORAGE_FREECOM=m
> CONFIG_USB_STORAGE_ISD200=m
> CONFIG_USB_STORAGE_USBAT=m
> CONFIG_USB_STORAGE_SDDR09=m
> CONFIG_USB_STORAGE_SDDR55=m
> CONFIG_USB_STORAGE_JUMPSHOT=m
> CONFIG_USB_STORAGE_ALAUDA=m
> CONFIG_USB_STORAGE_ONETOUCH=m
> CONFIG_USB_STORAGE_KARMA=m
> CONFIG_USB_STORAGE_CYPRESS_ATACB=m
> # CONFIG_USB_LIBUSUAL is not set
> 
> #
> # USB Imaging devices
> #
> CONFIG_USB_MDC800=m
> CONFIG_USB_MICROTEK=m
> 
> #
> # USB port drivers
> #
> CONFIG_USB_USS720=m
> CONFIG_USB_SERIAL=m
> CONFIG_USB_EZUSB=y
> CONFIG_USB_SERIAL_GENERIC=y
> CONFIG_USB_SERIAL_AIRCABLE=m
> CONFIG_USB_SERIAL_ARK3116=m
> CONFIG_USB_SERIAL_BELKIN=m
> CONFIG_USB_SERIAL_CH341=m
> CONFIG_USB_SERIAL_WHITEHEAT=m
> CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
> CONFIG_USB_SERIAL_CP210X=m
> CONFIG_USB_SERIAL_CYPRESS_M8=m
> CONFIG_USB_SERIAL_EMPEG=m
> CONFIG_USB_SERIAL_FTDI_SIO=m
> CONFIG_USB_SERIAL_FUNSOFT=m
> CONFIG_USB_SERIAL_VISOR=m
> CONFIG_USB_SERIAL_IPAQ=m
> CONFIG_USB_SERIAL_IR=m
> CONFIG_USB_SERIAL_EDGEPORT=m
> CONFIG_USB_SERIAL_EDGEPORT_TI=m
> CONFIG_USB_SERIAL_GARMIN=m
> CONFIG_USB_SERIAL_IPW=m
> CONFIG_USB_SERIAL_IUU=m
> CONFIG_USB_SERIAL_KEYSPAN_PDA=m
> CONFIG_USB_SERIAL_KEYSPAN=m
> CONFIG_USB_SERIAL_KEYSPAN_MPR=y
> CONFIG_USB_SERIAL_KEYSPAN_USA28=y
> CONFIG_USB_SERIAL_KEYSPAN_USA28X=y
> CONFIG_USB_SERIAL_KEYSPAN_USA28XA=y
> CONFIG_USB_SERIAL_KEYSPAN_USA28XB=y
> CONFIG_USB_SERIAL_KEYSPAN_USA19=y
> CONFIG_USB_SERIAL_KEYSPAN_USA18X=y
> CONFIG_USB_SERIAL_KEYSPAN_USA19W=y
> CONFIG_USB_SERIAL_KEYSPAN_USA19QW=y
> CONFIG_USB_SERIAL_KEYSPAN_USA19QI=y
> CONFIG_USB_SERIAL_KEYSPAN_USA49W=y
> CONFIG_USB_SERIAL_KEYSPAN_USA49WLC=y
> CONFIG_USB_SERIAL_KLSI=m
> CONFIG_USB_SERIAL_KOBIL_SCT=m
> CONFIG_USB_SERIAL_MCT_U232=m
> CONFIG_USB_SERIAL_MOS7720=m
> CONFIG_USB_SERIAL_MOS7715_PARPORT=y
> CONFIG_USB_SERIAL_MOS7840=m
> CONFIG_USB_SERIAL_MOTOROLA=m
> CONFIG_USB_SERIAL_NAVMAN=m
> CONFIG_USB_SERIAL_PL2303=m
> CONFIG_USB_SERIAL_OTI6858=m
> CONFIG_USB_SERIAL_QCAUX=m
> CONFIG_USB_SERIAL_QUALCOMM=m
> CONFIG_USB_SERIAL_SPCP8X5=m
> CONFIG_USB_SERIAL_HP4X=m
> CONFIG_USB_SERIAL_SAFE=m
> # CONFIG_USB_SERIAL_SAFE_PADDED is not set
> CONFIG_USB_SERIAL_SIEMENS_MPI=m
> CONFIG_USB_SERIAL_SIERRAWIRELESS=m
> CONFIG_USB_SERIAL_SYMBOL=m
> CONFIG_USB_SERIAL_TI=m
> CONFIG_USB_SERIAL_CYBERJACK=m
> CONFIG_USB_SERIAL_XIRCOM=m
> CONFIG_USB_SERIAL_WWAN=m
> CONFIG_USB_SERIAL_OPTION=m
> CONFIG_USB_SERIAL_OMNINET=m
> CONFIG_USB_SERIAL_OPTICON=m
> CONFIG_USB_SERIAL_VIVOPAY_SERIAL=m
> CONFIG_USB_SERIAL_ZIO=m
> CONFIG_USB_SERIAL_SSU100=m
> CONFIG_USB_SERIAL_DEBUG=m
> 
> #
> # USB Miscellaneous drivers
> #
> CONFIG_USB_EMI62=m
> CONFIG_USB_EMI26=m
> CONFIG_USB_ADUTUX=m
> CONFIG_USB_SEVSEG=m
> CONFIG_USB_RIO500=m
> CONFIG_USB_LEGOTOWER=m
> CONFIG_USB_LCD=m
> CONFIG_USB_LED=m
> CONFIG_USB_CYPRESS_CY7C63=m
> CONFIG_USB_CYTHERM=m
> CONFIG_USB_IDMOUSE=m
> CONFIG_USB_FTDI_ELAN=m
> CONFIG_USB_APPLEDISPLAY=m
> CONFIG_USB_SISUSBVGA=m
> # CONFIG_USB_SISUSBVGA_CON is not set
> CONFIG_USB_LD=m
> CONFIG_USB_TRANCEVIBRATOR=m
> CONFIG_USB_IOWARRIOR=m
> CONFIG_USB_TEST=m
> CONFIG_USB_ISIGHTFW=m
> CONFIG_USB_ATM=m
> CONFIG_USB_SPEEDTOUCH=m
> CONFIG_USB_CXACRU=m
> CONFIG_USB_UEAGLEATM=m
> CONFIG_USB_XUSBATM=m
> CONFIG_USB_GADGET=m
> # CONFIG_USB_GADGET_DEBUG is not set
> # CONFIG_USB_GADGET_DEBUG_FILES is not set
> # CONFIG_USB_GADGET_DEBUG_FS is not set
> CONFIG_USB_GADGET_VBUS_DRAW=2
> CONFIG_USB_GADGET_SELECTED=y
> # CONFIG_USB_GADGET_R8A66597 is not set
> # CONFIG_USB_GADGET_M66592 is not set
> # CONFIG_USB_GADGET_AMD5536UDC is not set
> # CONFIG_USB_GADGET_CI13XXX is not set
> # CONFIG_USB_GADGET_NET2280 is not set
> # CONFIG_USB_GADGET_GOKU is not set
> # CONFIG_USB_GADGET_LANGWELL is not set
> CONFIG_USB_GADGET_DUMMY_HCD=y
> CONFIG_USB_DUMMY_HCD=m
> CONFIG_USB_GADGET_DUALSPEED=y
> CONFIG_USB_ZERO=m
> CONFIG_USB_AUDIO=m
> CONFIG_USB_ETH=m
> CONFIG_USB_ETH_RNDIS=y
> # CONFIG_USB_ETH_EEM is not set
> CONFIG_USB_GADGETFS=m
> CONFIG_USB_FUNCTIONFS=m
> CONFIG_USB_FUNCTIONFS_ETH=y
> CONFIG_USB_FUNCTIONFS_RNDIS=y
> CONFIG_USB_FUNCTIONFS_GENERIC=y
> CONFIG_USB_FILE_STORAGE=m
> # CONFIG_USB_FILE_STORAGE_TEST is not set
> CONFIG_USB_MASS_STORAGE=m
> CONFIG_USB_G_SERIAL=m
> CONFIG_USB_MIDI_GADGET=m
> CONFIG_USB_G_PRINTER=m
> CONFIG_USB_CDC_COMPOSITE=m
> CONFIG_USB_G_NOKIA=m
> # CONFIG_USB_G_MULTI is not set
> CONFIG_USB_G_HID=m
> CONFIG_USB_G_DBGP=m
> # CONFIG_USB_G_DBGP_PRINTK is not set
> CONFIG_USB_G_DBGP_SERIAL=y
> CONFIG_USB_G_WEBCAM=m
> 
> #
> # OTG and related infrastructure
> #
> CONFIG_USB_OTG_UTILS=y
> CONFIG_USB_GPIO_VBUS=m
> CONFIG_TWL4030_USB=m
> CONFIG_NOP_USB_XCEIV=m
> CONFIG_UWB=m
> CONFIG_UWB_HWA=m
> CONFIG_UWB_WHCI=m
> CONFIG_UWB_WLP=m
> CONFIG_UWB_I1480U=m
> CONFIG_UWB_I1480U_WLP=m
> CONFIG_MMC=y
> # CONFIG_MMC_DEBUG is not set
> # CONFIG_MMC_UNSAFE_RESUME is not set
> 
> #
> # MMC/SD/SDIO Card Drivers
> #
> CONFIG_MMC_BLOCK=m
> CONFIG_MMC_BLOCK_BOUNCE=y
> CONFIG_SDIO_UART=m
> # CONFIG_MMC_TEST is not set
> 
> #
> # MMC/SD/SDIO Host Controller Drivers
> #
> CONFIG_MMC_SDHCI=m
> CONFIG_MMC_SDHCI_PCI=m
> CONFIG_MMC_RICOH_MMC=y
> CONFIG_MMC_SDHCI_PLTFM=m
> CONFIG_MMC_WBSD=m
> CONFIG_MMC_TIFM_SD=m
> CONFIG_MMC_SPI=m
> CONFIG_MMC_SDRICOH_CS=m
> CONFIG_MMC_CB710=m
> CONFIG_MMC_VIA_SDMMC=m
> CONFIG_MEMSTICK=m
> # CONFIG_MEMSTICK_DEBUG is not set
> 
> #
> # MemoryStick drivers
> #
> # CONFIG_MEMSTICK_UNSAFE_RESUME is not set
> CONFIG_MSPRO_BLOCK=m
> 
> #
> # MemoryStick Host Controller Drivers
> #
> CONFIG_MEMSTICK_TIFM_MS=m
> CONFIG_MEMSTICK_JMICRON_38X=m
> CONFIG_NEW_LEDS=y
> CONFIG_LEDS_CLASS=m
> 
> #
> # LED drivers
> #
> CONFIG_LEDS_88PM860X=m
> CONFIG_LEDS_NET5501=m
> CONFIG_LEDS_ALIX2=m
> CONFIG_LEDS_PCA9532=m
> CONFIG_LEDS_GPIO=m
> CONFIG_LEDS_GPIO_PLATFORM=y
> CONFIG_LEDS_LP3944=m
> # CONFIG_LEDS_CLEVO_MAIL is not set
> CONFIG_LEDS_PCA955X=m
> CONFIG_LEDS_WM831X_STATUS=m
> CONFIG_LEDS_WM8350=m
> CONFIG_LEDS_DA903X=m
> CONFIG_LEDS_DAC124S085=m
> CONFIG_LEDS_REGULATOR=m
> CONFIG_LEDS_BD2802=m
> CONFIG_LEDS_INTEL_SS4200=m
> CONFIG_LEDS_LT3593=m
> CONFIG_LEDS_ADP5520=m
> CONFIG_LEDS_DELL_NETBOOKS=m
> CONFIG_LEDS_MC13783=m
> CONFIG_LEDS_TRIGGERS=y
> 
> #
> # LED Triggers
> #
> CONFIG_LEDS_TRIGGER_TIMER=m
> CONFIG_LEDS_TRIGGER_HEARTBEAT=m
> CONFIG_LEDS_TRIGGER_BACKLIGHT=m
> CONFIG_LEDS_TRIGGER_GPIO=m
> CONFIG_LEDS_TRIGGER_DEFAULT_ON=m
> 
> #
> # iptables trigger is under Netfilter config (LED target)
> #
> # CONFIG_ACCESSIBILITY is not set
> CONFIG_INFINIBAND=m
> CONFIG_INFINIBAND_USER_MAD=m
> CONFIG_INFINIBAND_USER_ACCESS=m
> CONFIG_INFINIBAND_USER_MEM=y
> CONFIG_INFINIBAND_ADDR_TRANS=y
> CONFIG_INFINIBAND_MTHCA=m
> CONFIG_INFINIBAND_MTHCA_DEBUG=y
> CONFIG_INFINIBAND_IPATH=m
> CONFIG_INFINIBAND_QIB=m
> CONFIG_INFINIBAND_AMSO1100=m
> CONFIG_INFINIBAND_AMSO1100_DEBUG=y
> CONFIG_INFINIBAND_CXGB3=m
> # CONFIG_INFINIBAND_CXGB3_DEBUG is not set
> CONFIG_INFINIBAND_CXGB4=m
> CONFIG_MLX4_INFINIBAND=m
> # CONFIG_INFINIBAND_NES is not set
> CONFIG_INFINIBAND_IPOIB=m
> CONFIG_INFINIBAND_IPOIB_CM=y
> CONFIG_INFINIBAND_IPOIB_DEBUG=y
> # CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
> CONFIG_INFINIBAND_SRP=m
> CONFIG_INFINIBAND_ISER=m
> CONFIG_EDAC=y
> 
> #
> # Reporting subsystems
> #
> # CONFIG_EDAC_DEBUG is not set
> CONFIG_EDAC_DECODE_MCE=m
> CONFIG_EDAC_MM_EDAC=m
> CONFIG_EDAC_MCE=y
> CONFIG_EDAC_AMD64=m
> # CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
> CONFIG_EDAC_E752X=m
> CONFIG_EDAC_I82975X=m
> CONFIG_EDAC_I3000=m
> CONFIG_EDAC_I3200=m
> CONFIG_EDAC_X38=m
> CONFIG_EDAC_I5400=m
> CONFIG_EDAC_I7CORE=m
> CONFIG_EDAC_I5000=m
> CONFIG_EDAC_I5100=m
> CONFIG_RTC_LIB=y
> CONFIG_RTC_CLASS=y
> CONFIG_RTC_HCTOSYS=y
> CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
> # CONFIG_RTC_DEBUG is not set
> 
> #
> # RTC interfaces
> #
> CONFIG_RTC_INTF_SYSFS=y
> CONFIG_RTC_INTF_PROC=y
> CONFIG_RTC_INTF_DEV=y
> CONFIG_RTC_INTF_DEV_UIE_EMUL=y
> CONFIG_RTC_DRV_TEST=m
> 
> #
> # I2C RTC drivers
> #
> CONFIG_RTC_DRV_DS1307=m
> CONFIG_RTC_DRV_DS1374=m
> CONFIG_RTC_DRV_DS1672=m
> CONFIG_RTC_DRV_DS3232=m
> CONFIG_RTC_DRV_MAX6900=m
> CONFIG_RTC_DRV_MAX8925=m
> CONFIG_RTC_DRV_RS5C372=m
> CONFIG_RTC_DRV_ISL1208=m
> CONFIG_RTC_DRV_ISL12022=m
> CONFIG_RTC_DRV_X1205=m
> CONFIG_RTC_DRV_PCF8563=m
> CONFIG_RTC_DRV_PCF8583=m
> CONFIG_RTC_DRV_M41T80=m
> CONFIG_RTC_DRV_M41T80_WDT=y
> CONFIG_RTC_DRV_BQ32K=m
> CONFIG_RTC_DRV_TWL4030=m
> CONFIG_RTC_DRV_S35390A=m
> CONFIG_RTC_DRV_FM3130=m
> CONFIG_RTC_DRV_RX8581=m
> CONFIG_RTC_DRV_RX8025=m
> 
> #
> # SPI RTC drivers
> #
> CONFIG_RTC_DRV_M41T94=m
> CONFIG_RTC_DRV_DS1305=m
> CONFIG_RTC_DRV_DS1390=m
> CONFIG_RTC_DRV_MAX6902=m
> CONFIG_RTC_DRV_R9701=m
> CONFIG_RTC_DRV_RS5C348=m
> CONFIG_RTC_DRV_DS3234=m
> CONFIG_RTC_DRV_PCF2123=m
> 
> #
> # Platform RTC drivers
> #
> CONFIG_RTC_DRV_CMOS=y
> CONFIG_RTC_DRV_DS1286=m
> CONFIG_RTC_DRV_DS1511=m
> CONFIG_RTC_DRV_DS1553=m
> CONFIG_RTC_DRV_DS1742=m
> CONFIG_RTC_DRV_STK17TA8=m
> CONFIG_RTC_DRV_M48T86=m
> CONFIG_RTC_DRV_M48T35=m
> CONFIG_RTC_DRV_M48T59=m
> CONFIG_RTC_DRV_MSM6242=m
> CONFIG_RTC_DRV_BQ4802=m
> CONFIG_RTC_DRV_RP5C01=m
> CONFIG_RTC_DRV_V3020=m
> CONFIG_RTC_DRV_WM831X=m
> CONFIG_RTC_DRV_WM8350=m
> CONFIG_RTC_DRV_PCF50633=m
> CONFIG_RTC_DRV_AB3100=m
> CONFIG_RTC_DRV_AB8500=m
> 
> #
> # on-CPU RTC drivers
> #
> CONFIG_RTC_DRV_MC13783=m
> CONFIG_DMADEVICES=y
> # CONFIG_DMADEVICES_DEBUG is not set
> 
> #
> # DMA Devices
> #
> CONFIG_INTEL_MID_DMAC=m
> CONFIG_ASYNC_TX_DISABLE_CHANNEL_SWITCH=y
> CONFIG_INTEL_IOATDMA=m
> CONFIG_TIMB_DMA=m
> CONFIG_PCH_DMA=m
> CONFIG_DMA_ENGINE=y
> 
> #
> # DMA Clients
> #
> CONFIG_NET_DMA=y
> # CONFIG_ASYNC_TX_DMA is not set
> # CONFIG_DMATEST is not set
> CONFIG_DCA=m
> CONFIG_AUXDISPLAY=y
> CONFIG_KS0108=m
> CONFIG_KS0108_PORT=0x378
> CONFIG_KS0108_DELAY=2
> CONFIG_CFAG12864B=m
> CONFIG_CFAG12864B_RATE=20
> CONFIG_UIO=m
> CONFIG_UIO_CIF=m
> CONFIG_UIO_PDRV=m
> CONFIG_UIO_PDRV_GENIRQ=m
> CONFIG_UIO_AEC=m
> CONFIG_UIO_SERCOS3=m
> CONFIG_UIO_PCI_GENERIC=m
> CONFIG_UIO_NETX=m
> 
> #
> # Xen driver support
> #
> CONFIG_XEN_BALLOON=y
> CONFIG_XEN_SCRUB_PAGES=y
> CONFIG_XEN_DEV_EVTCHN=m
> CONFIG_XENFS=m
> CONFIG_XEN_COMPAT_XENFS=y
> CONFIG_XEN_SYS_HYPERVISOR=y
> CONFIG_XEN_PLATFORM_PCI=m
> CONFIG_SWIOTLB_XEN=y
> CONFIG_STAGING=y
> # CONFIG_STAGING_EXCLUDE_BUILD is not set
> CONFIG_ET131X=m
> # CONFIG_ET131X_DEBUG is not set
> CONFIG_SLICOSS=m
> CONFIG_VIDEO_GO7007=m
> CONFIG_VIDEO_GO7007_USB=m
> CONFIG_VIDEO_GO7007_USB_S2250_BOARD=m
> CONFIG_VIDEO_GO7007_OV7640=m
> CONFIG_VIDEO_GO7007_SAA7113=m
> CONFIG_VIDEO_GO7007_SAA7115=m
> CONFIG_VIDEO_GO7007_TW9903=m
> CONFIG_VIDEO_GO7007_UDA1342=m
> CONFIG_VIDEO_GO7007_SONY_TUNER=m
> CONFIG_VIDEO_GO7007_TW2804=m
> CONFIG_VIDEO_CX25821=m
> CONFIG_VIDEO_CX25821_ALSA=m
> CONFIG_VIDEO_TM6000=m
> CONFIG_VIDEO_TM6000_ALSA=m
> CONFIG_VIDEO_TM6000_DVB=m
> CONFIG_USB_IP_COMMON=m
> CONFIG_USB_IP_VHCI_HCD=m
> CONFIG_USB_IP_HOST=m
> # CONFIG_USB_IP_DEBUG_ENABLE is not set
> CONFIG_W35UND=m
> CONFIG_PRISM2_USB=m
> CONFIG_ECHO=m
> # CONFIG_OTUS is not set
> CONFIG_RT2860=m
> CONFIG_RT2870=m
> CONFIG_COMEDI=m
> # CONFIG_COMEDI_DEBUG is not set
> CONFIG_COMEDI_MISC_DRIVERS=m
> CONFIG_COMEDI_KCOMEDILIB=m
> CONFIG_COMEDI_BOND=m
> CONFIG_COMEDI_TEST=m
> CONFIG_COMEDI_PARPORT=m
> CONFIG_COMEDI_SERIAL2002=m
> CONFIG_COMEDI_SKEL=m
> CONFIG_COMEDI_PCI_DRIVERS=m
> CONFIG_COMEDI_ADDI_APCI_035=m
> CONFIG_COMEDI_ADDI_APCI_1032=m
> CONFIG_COMEDI_ADDI_APCI_1500=m
> CONFIG_COMEDI_ADDI_APCI_1516=m
> CONFIG_COMEDI_ADDI_APCI_1564=m
> CONFIG_COMEDI_ADDI_APCI_16XX=m
> CONFIG_COMEDI_ADDI_APCI_2016=m
> CONFIG_COMEDI_ADDI_APCI_2032=m
> CONFIG_COMEDI_ADDI_APCI_2200=m
> CONFIG_COMEDI_ADDI_APCI_3001=m
> CONFIG_COMEDI_ADDI_APCI_3120=m
> CONFIG_COMEDI_ADDI_APCI_3501=m
> CONFIG_COMEDI_ADDI_APCI_3XXX=m
> CONFIG_COMEDI_ADL_PCI6208=m
> CONFIG_COMEDI_ADL_PCI7230=m
> CONFIG_COMEDI_ADL_PCI7296=m
> CONFIG_COMEDI_ADL_PCI7432=m
> CONFIG_COMEDI_ADL_PCI8164=m
> CONFIG_COMEDI_ADL_PCI9111=m
> CONFIG_COMEDI_ADL_PCI9118=m
> CONFIG_COMEDI_ADV_PCI1710=m
> CONFIG_COMEDI_ADV_PCI1723=m
> CONFIG_COMEDI_ADV_PCI_DIO=m
> CONFIG_COMEDI_AMPLC_DIO200=m
> CONFIG_COMEDI_AMPLC_PC236=m
> CONFIG_COMEDI_AMPLC_PC263=m
> CONFIG_COMEDI_AMPLC_PCI224=m
> CONFIG_COMEDI_AMPLC_PCI230=m
> CONFIG_COMEDI_CONTEC_PCI_DIO=m
> CONFIG_COMEDI_DT3000=m
> CONFIG_COMEDI_UNIOXX5=m
> CONFIG_COMEDI_GSC_HPDI=m
> CONFIG_COMEDI_ICP_MULTI=m
> CONFIG_COMEDI_II_PCI20KC=m
> CONFIG_COMEDI_DAQBOARD2000=m
> CONFIG_COMEDI_JR3_PCI=m
> CONFIG_COMEDI_KE_COUNTER=m
> CONFIG_COMEDI_CB_PCIDAS64=m
> CONFIG_COMEDI_CB_PCIDAS=m
> CONFIG_COMEDI_CB_PCIDDA=m
> CONFIG_COMEDI_CB_PCIDIO=m
> CONFIG_COMEDI_CB_PCIMDAS=m
> CONFIG_COMEDI_CB_PCIMDDA=m
> CONFIG_COMEDI_ME4000=m
> CONFIG_COMEDI_ME_DAQ=m
> CONFIG_COMEDI_NI_6527=m
> CONFIG_COMEDI_NI_65XX=m
> CONFIG_COMEDI_NI_660X=m
> CONFIG_COMEDI_NI_670X=m
> CONFIG_COMEDI_NI_PCIDIO=m
> CONFIG_COMEDI_NI_PCIMIO=m
> CONFIG_COMEDI_RTD520=m
> CONFIG_COMEDI_S526=m
> CONFIG_COMEDI_S626=m
> CONFIG_COMEDI_SSV_DNP=m
> CONFIG_COMEDI_PCMCIA_DRIVERS=m
> CONFIG_COMEDI_CB_DAS16_CS=m
> CONFIG_COMEDI_DAS08_CS=m
> CONFIG_COMEDI_NI_DAQ_700_CS=m
> CONFIG_COMEDI_NI_DAQ_DIO24_CS=m
> CONFIG_COMEDI_NI_LABPC_CS=m
> CONFIG_COMEDI_NI_MIO_CS=m
> CONFIG_COMEDI_QUATECH_DAQP_CS=m
> CONFIG_COMEDI_USB_DRIVERS=m
> CONFIG_COMEDI_DT9812=m
> CONFIG_COMEDI_USBDUX=m
> CONFIG_COMEDI_USBDUXFAST=m
> CONFIG_COMEDI_VMK80XX=m
> CONFIG_COMEDI_NI_COMMON=m
> CONFIG_COMEDI_MITE=m
> CONFIG_COMEDI_NI_TIO=m
> CONFIG_COMEDI_NI_LABPC=m
> CONFIG_COMEDI_8255=m
> CONFIG_COMEDI_DAS08=m
> CONFIG_COMEDI_FC=m
> CONFIG_ASUS_OLED=m
> CONFIG_PANEL=m
> CONFIG_PANEL_PARPORT=0
> CONFIG_PANEL_PROFILE=5
> # CONFIG_PANEL_CHANGE_MESSAGE is not set
> CONFIG_R8187SE=m
> CONFIG_RTL8192SU=m
> CONFIG_RTL8192U=m
> CONFIG_RTL8192E=m
> CONFIG_TRANZPORT=m
> CONFIG_POHMELFS=m
> # CONFIG_POHMELFS_DEBUG is not set
> CONFIG_POHMELFS_CRYPTO=y
> CONFIG_IDE_PHISON=m
> CONFIG_LINE6_USB=m
> # CONFIG_DRM_VMWGFX is not set
> CONFIG_DRM_NOUVEAU=m
> CONFIG_DRM_NOUVEAU_BACKLIGHT=y
> CONFIG_DRM_NOUVEAU_DEBUG=y
> 
> #
> # I2C encoder or helper chips
> #
> CONFIG_DRM_I2C_CH7006=m
> CONFIG_DRM_I2C_SIL164=m
> CONFIG_USB_SERIAL_QUATECH2=m
> CONFIG_SPECTRA=m
> CONFIG_SPECTRA_MRST_HW=y
> # CONFIG_SPECTRA_MTD is not set
> # CONFIG_SPECTRA_EMU is not set
> # CONFIG_SPECTRA_MRST_HW_DMA is not set
> CONFIG_USB_SERIAL_QUATECH_USB2=m
> # CONFIG_VT6655 is not set
> CONFIG_VT6656=m
> CONFIG_FB_UDL=m
> CONFIG_HYPERV=m
> CONFIG_HYPERV_STORAGE=m
> CONFIG_HYPERV_BLOCK=m
> CONFIG_HYPERV_NET=m
> CONFIG_HYPERV_UTILS=m
> CONFIG_VME_BUS=m
> 
> #
> # VME Bridge Drivers
> #
> CONFIG_VME_CA91CX42=m
> CONFIG_VME_TSI148=m
> 
> #
> # VME Device Drivers
> #
> CONFIG_VME_USER=m
> 
> #
> # VME Board Drivers
> #
> CONFIG_VMIVME_7805=m
> CONFIG_IIO=m
> CONFIG_IIO_RING_BUFFER=y
> CONFIG_IIO_SW_RING=m
> CONFIG_IIO_TRIGGER=y
> 
> #
> # Accelerometers
> #
> CONFIG_ADIS16209=m
> CONFIG_ADIS16220=m
> CONFIG_ADIS16240=m
> CONFIG_KXSD9=m
> CONFIG_LIS3L02DQ=m
> CONFIG_SCA3000=m
> 
> #
> # Analog to digital convertors
> #
> CONFIG_MAX1363=m
> CONFIG_MAX1363_RING_BUFFER=y
> 
> #
> # Digital gyroscope sensors
> #
> CONFIG_ADIS16260=m
> 
> #
> # Inertial measurement units
> #
> CONFIG_ADIS16300=m
> CONFIG_ADIS16350=m
> CONFIG_ADIS16400=m
> 
> #
> # Light sensors
> #
> CONFIG_SENSORS_TSL2563=m
> 
> #
> # Magnetometer sensors
> #
> CONFIG_SENSORS_HMC5843=m
> 
> #
> # Triggers - standalone
> #
> CONFIG_IIO_PERIODIC_RTC_TRIGGER=m
> CONFIG_IIO_GPIO_TRIGGER=m
> CONFIG_ZRAM=m
> CONFIG_ZRAM_STATS=y
> CONFIG_WLAGS49_H2=m
> CONFIG_WLAGS49_H25=m
> CONFIG_BATMAN_ADV=m
> # CONFIG_BATMAN_ADV_DEBUG is not set
> CONFIG_SAMSUNG_LAPTOP=m
> CONFIG_FB_SM7XX=m
> CONFIG_VIDEO_DT3155=m
> # CONFIG_DT3155_CCIR is not set
> CONFIG_CRYSTALHD=m
> CONFIG_CXT1E1=m
> CONFIG_SBE_PMCC4_NCOMM=y
> 
> #
> # Texas Instruments shared transport line discipline
> #
> CONFIG_TI_ST=m
> CONFIG_ST_BT=m
> CONFIG_ADIS16255=m
> CONFIG_FB_XGI=m
> CONFIG_LIRC_STAGING=y
> CONFIG_LIRC_BT829=m
> CONFIG_LIRC_I2C=m
> CONFIG_LIRC_IGORPLUGUSB=m
> CONFIG_LIRC_IMON=m
> CONFIG_LIRC_IT87=m
> CONFIG_LIRC_ITE8709=m
> # CONFIG_LIRC_PARALLEL is not set
> CONFIG_LIRC_SASEM=m
> CONFIG_LIRC_SERIAL=m
> CONFIG_LIRC_SERIAL_TRANSMITTER=y
> CONFIG_LIRC_SIR=m
> CONFIG_LIRC_TTUSBIR=m
> CONFIG_LIRC_ZILOG=m
> CONFIG_EASYCAP=m
> CONFIG_SOLO6X10=m
> CONFIG_ACPI_QUICKSTART=m
> CONFIG_X86_PLATFORM_DEVICES=y
> CONFIG_ACER_WMI=m
> CONFIG_ACERHDF=m
> CONFIG_ASUS_LAPTOP=m
> CONFIG_DELL_LAPTOP=m
> CONFIG_DELL_WMI=m
> CONFIG_FUJITSU_LAPTOP=m
> # CONFIG_FUJITSU_LAPTOP_DEBUG is not set
> CONFIG_HP_WMI=m
> CONFIG_MSI_LAPTOP=m
> CONFIG_PANASONIC_LAPTOP=m
> CONFIG_COMPAL_LAPTOP=m
> CONFIG_SONY_LAPTOP=m
> CONFIG_SONYPI_COMPAT=y
> CONFIG_IDEAPAD_ACPI=m
> CONFIG_THINKPAD_ACPI=m
> CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
> CONFIG_THINKPAD_ACPI_DEBUGFACILITIES=y
> # CONFIG_THINKPAD_ACPI_DEBUG is not set
> # CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
> CONFIG_THINKPAD_ACPI_VIDEO=y
> CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
> CONFIG_INTEL_MENLOW=m
> CONFIG_EEEPC_LAPTOP=m
> CONFIG_EEEPC_WMI=m
> CONFIG_ACPI_WMI=y
> CONFIG_MSI_WMI=m
> # CONFIG_ACPI_ASUS is not set
> CONFIG_TOPSTAR_LAPTOP=m
> CONFIG_ACPI_TOSHIBA=m
> CONFIG_TOSHIBA_BT_RFKILL=m
> CONFIG_ACPI_CMPC=m
> CONFIG_INTEL_IPS=m
> 
> #
> # Ubuntu Supplied Third-Party Device Drivers
> #
> CONFIG_AUFS_FS=m
> CONFIG_AUFS_BRANCH_MAX_127=y
> # CONFIG_AUFS_BRANCH_MAX_511 is not set
> # CONFIG_AUFS_BRANCH_MAX_1023 is not set
> # CONFIG_AUFS_BRANCH_MAX_32767 is not set
> # CONFIG_AUFS_HNOTIFY is not set
> # CONFIG_AUFS_EXPORT is not set
> # CONFIG_AUFS_RDU is not set
> # CONFIG_AUFS_SP_IATTR is not set
> # CONFIG_AUFS_SHWH is not set
> CONFIG_AUFS_BR_RAMFS=y
> CONFIG_AUFS_BR_FUSE=y
> CONFIG_AUFS_POLL=y
> CONFIG_AUFS_BR_HFSPLUS=y
> CONFIG_AUFS_BDEV_LOOP=y
> # CONFIG_AUFS_DEBUG is not set
> 
> #
> # Compcache options
> #
> CONFIG_BLK_DEV_COMPCACHE=m
> # CONFIG_BLK_DEV_COMPCACHE_DEBUG is not set
> # CONFIG_BLK_DEV_COMPCACHE_STATS is not set
> CONFIG_DM_RAID45=m
> CONFIG_FSAM7400=m
> CONFIG_SCSI_ISCSITARGET=m
> CONFIG_LIRC_DEV=m
> CONFIG_LIRC_ATIUSB=m
> CONFIG_LIRC_ENE0100=m
> CONFIG_LIRC_MCEUSB=m
> CONFIG_LIRC_STREAMZAP=m
> CONFIG_LIRC_CONFIG_LIRC_WPC8769L=m
> # CONFIG_LIRC_GPIO is not set
> CONFIG_NDISWRAPPER=m
> CONFIG_OMNIBOOK=m
> CONFIG_RTL8192SE=m
> CONFIG_AVERATEC_5100P=m
> CONFIG_PACKARDBELL_E5=m
> 
> #
> # Firmware Drivers
> #
> CONFIG_EDD=y
> CONFIG_EDD_OFF=y
> CONFIG_FIRMWARE_MEMMAP=y
> CONFIG_EFI_VARS=y
> CONFIG_DELL_RBU=m
> CONFIG_DCDBAS=m
> CONFIG_DMIID=y
> CONFIG_ISCSI_IBFT_FIND=y
> CONFIG_ISCSI_IBFT=m
> 
> #
> # File systems
> #
> CONFIG_EXT2_FS=y
> CONFIG_EXT2_FS_XATTR=y
> CONFIG_EXT2_FS_POSIX_ACL=y
> CONFIG_EXT2_FS_SECURITY=y
> # CONFIG_EXT2_FS_XIP is not set
> CONFIG_EXT3_FS=y
> CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
> CONFIG_EXT3_FS_XATTR=y
> CONFIG_EXT3_FS_POSIX_ACL=y
> CONFIG_EXT3_FS_SECURITY=y
> CONFIG_EXT4_FS=y
> CONFIG_EXT4_FS_XATTR=y
> CONFIG_EXT4_FS_POSIX_ACL=y
> CONFIG_EXT4_FS_SECURITY=y
> # CONFIG_EXT4_DEBUG is not set
> CONFIG_JBD=y
> # CONFIG_JBD_DEBUG is not set
> CONFIG_JBD2=y
> # CONFIG_JBD2_DEBUG is not set
> CONFIG_FS_MBCACHE=y
> CONFIG_REISERFS_FS=m
> # CONFIG_REISERFS_CHECK is not set
> # CONFIG_REISERFS_PROC_INFO is not set
> CONFIG_REISERFS_FS_XATTR=y
> CONFIG_REISERFS_FS_POSIX_ACL=y
> CONFIG_REISERFS_FS_SECURITY=y
> CONFIG_JFS_FS=m
> CONFIG_JFS_POSIX_ACL=y
> CONFIG_JFS_SECURITY=y
> # CONFIG_JFS_DEBUG is not set
> CONFIG_JFS_STATISTICS=y
> CONFIG_FS_POSIX_ACL=y
> CONFIG_XFS_FS=m
> CONFIG_XFS_QUOTA=y
> CONFIG_XFS_POSIX_ACL=y
> CONFIG_XFS_RT=y
> # CONFIG_XFS_DEBUG is not set
> CONFIG_GFS2_FS=m
> CONFIG_GFS2_FS_LOCKING_DLM=y
> CONFIG_OCFS2_FS=m
> CONFIG_OCFS2_FS_O2CB=m
> CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
> CONFIG_OCFS2_FS_STATS=y
> CONFIG_OCFS2_DEBUG_MASKLOG=y
> # CONFIG_OCFS2_DEBUG_FS is not set
> CONFIG_BTRFS_FS=m
> CONFIG_BTRFS_FS_POSIX_ACL=y
> CONFIG_NILFS2_FS=m
> CONFIG_FILE_LOCKING=y
> CONFIG_FSNOTIFY=y
> CONFIG_DNOTIFY=y
> CONFIG_INOTIFY_USER=y
> CONFIG_FANOTIFY=y
> CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
> CONFIG_QUOTA=y
> CONFIG_QUOTA_NETLINK_INTERFACE=y
> # CONFIG_PRINT_QUOTA_WARNING is not set
> # CONFIG_QUOTA_DEBUG is not set
> CONFIG_QUOTA_TREE=m
> CONFIG_QFMT_V1=m
> CONFIG_QFMT_V2=m
> CONFIG_QUOTACTL=y
> CONFIG_QUOTACTL_COMPAT=y
> CONFIG_AUTOFS_FS=m
> CONFIG_AUTOFS4_FS=m
> CONFIG_FUSE_FS=y
> CONFIG_CUSE=m
> CONFIG_GENERIC_ACL=y
> 
> #
> # Caches
> #
> CONFIG_FSCACHE=m
> CONFIG_FSCACHE_STATS=y
> CONFIG_FSCACHE_HISTOGRAM=y
> # CONFIG_FSCACHE_DEBUG is not set
> # CONFIG_FSCACHE_OBJECT_LIST is not set
> CONFIG_CACHEFILES=m
> # CONFIG_CACHEFILES_DEBUG is not set
> # CONFIG_CACHEFILES_HISTOGRAM is not set
> 
> #
> # CD-ROM/DVD Filesystems
> #
> CONFIG_ISO9660_FS=m
> CONFIG_JOLIET=y
> CONFIG_ZISOFS=y
> CONFIG_UDF_FS=m
> CONFIG_UDF_NLS=y
> 
> #
> # DOS/FAT/NT Filesystems
> #
> CONFIG_FAT_FS=m
> CONFIG_MSDOS_FS=m
> CONFIG_VFAT_FS=m
> CONFIG_FAT_DEFAULT_CODEPAGE=437
> CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
> CONFIG_NTFS_FS=m
> # CONFIG_NTFS_DEBUG is not set
> # CONFIG_NTFS_RW is not set
> 
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=y
> CONFIG_PROC_KCORE=y
> CONFIG_PROC_VMCORE=y
> CONFIG_PROC_SYSCTL=y
> CONFIG_PROC_PAGE_MONITOR=y
> CONFIG_SYSFS=y
> CONFIG_TMPFS=y
> CONFIG_TMPFS_POSIX_ACL=y
> CONFIG_HUGETLBFS=y
> CONFIG_HUGETLB_PAGE=y
> CONFIG_CONFIGFS_FS=m
> CONFIG_MISC_FILESYSTEMS=y
> CONFIG_ADFS_FS=m
> # CONFIG_ADFS_FS_RW is not set
> CONFIG_AFFS_FS=m
> CONFIG_ECRYPT_FS=y
> CONFIG_HFS_FS=m
> CONFIG_HFSPLUS_FS=m
> CONFIG_BEFS_FS=m
> # CONFIG_BEFS_DEBUG is not set
> CONFIG_BFS_FS=m
> CONFIG_EFS_FS=m
> CONFIG_JFFS2_FS=m
> CONFIG_JFFS2_FS_DEBUG=0
> CONFIG_JFFS2_FS_WRITEBUFFER=y
> # CONFIG_JFFS2_FS_WBUF_VERIFY is not set
> # CONFIG_JFFS2_SUMMARY is not set
> # CONFIG_JFFS2_FS_XATTR is not set
> CONFIG_JFFS2_COMPRESSION_OPTIONS=y
> CONFIG_JFFS2_ZLIB=y
> CONFIG_JFFS2_LZO=y
> CONFIG_JFFS2_RTIME=y
> # CONFIG_JFFS2_RUBIN is not set
> # CONFIG_JFFS2_CMODE_NONE is not set
> # CONFIG_JFFS2_CMODE_PRIORITY is not set
> # CONFIG_JFFS2_CMODE_SIZE is not set
> CONFIG_JFFS2_CMODE_FAVOURLZO=y
> CONFIG_UBIFS_FS=m
> CONFIG_UBIFS_FS_XATTR=y
> # CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
> CONFIG_UBIFS_FS_LZO=y
> CONFIG_UBIFS_FS_ZLIB=y
> # CONFIG_UBIFS_FS_DEBUG is not set
> # CONFIG_LOGFS is not set
> CONFIG_CRAMFS=m
> CONFIG_SQUASHFS=m
> CONFIG_SQUASHFS_XATTR=y
> CONFIG_SQUASHFS_LZO=y
> # CONFIG_SQUASHFS_EMBEDDED is not set
> CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
> CONFIG_VXFS_FS=m
> CONFIG_MINIX_FS=m
> CONFIG_OMFS_FS=m
> CONFIG_HPFS_FS=m
> CONFIG_QNX4FS_FS=m
> CONFIG_ROMFS_FS=m
> CONFIG_ROMFS_BACKED_BY_BLOCK=y
> # CONFIG_ROMFS_BACKED_BY_MTD is not set
> # CONFIG_ROMFS_BACKED_BY_BOTH is not set
> CONFIG_ROMFS_ON_BLOCK=y
> CONFIG_SYSV_FS=m
> CONFIG_UFS_FS=m
> # CONFIG_UFS_FS_WRITE is not set
> # CONFIG_UFS_DEBUG is not set
> CONFIG_EXOFS_FS=m
> # CONFIG_EXOFS_DEBUG is not set
> CONFIG_NETWORK_FILESYSTEMS=y
> CONFIG_NFS_FS=m
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=y
> # CONFIG_NFS_V4_1 is not set
> CONFIG_NFS_FSCACHE=y
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> CONFIG_NFSD=m
> CONFIG_NFSD_V2_ACL=y
> CONFIG_NFSD_V3=y
> CONFIG_NFSD_V3_ACL=y
> CONFIG_NFSD_V4=y
> CONFIG_LOCKD=m
> CONFIG_LOCKD_V4=y
> CONFIG_EXPORTFS=m
> CONFIG_NFS_ACL_SUPPORT=m
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=m
> CONFIG_SUNRPC_GSS=m
> CONFIG_SUNRPC_XPRT_RDMA=m
> CONFIG_RPCSEC_GSS_KRB5=m
> CONFIG_RPCSEC_GSS_SPKM3=m
> CONFIG_SMB_FS=m
> # CONFIG_SMB_NLS_DEFAULT is not set
> CONFIG_CEPH_FS=m
> # CONFIG_CEPH_FS_PRETTYDEBUG is not set
> CONFIG_CIFS=m
> # CONFIG_CIFS_STATS is not set
> CONFIG_CIFS_WEAK_PW_HASH=y
> CONFIG_CIFS_UPCALL=y
> CONFIG_CIFS_XATTR=y
> CONFIG_CIFS_POSIX=y
> # CONFIG_CIFS_DEBUG2 is not set
> CONFIG_CIFS_DFS_UPCALL=y
> # CONFIG_CIFS_FSCACHE is not set
> CONFIG_CIFS_EXPERIMENTAL=y
> CONFIG_NCP_FS=m
> CONFIG_NCPFS_PACKET_SIGNING=y
> CONFIG_NCPFS_IOCTL_LOCKING=y
> CONFIG_NCPFS_STRONG=y
> CONFIG_NCPFS_NFS_NS=y
> CONFIG_NCPFS_OS2_NS=y
> # CONFIG_NCPFS_SMALLDOS is not set
> CONFIG_NCPFS_NLS=y
> CONFIG_NCPFS_EXTRAS=y
> CONFIG_CODA_FS=m
> CONFIG_AFS_FS=m
> # CONFIG_AFS_DEBUG is not set
> # CONFIG_AFS_FSCACHE is not set
> CONFIG_9P_FS=m
> # CONFIG_9P_FSCACHE is not set
> 
> #
> # Partition Types
> #
> CONFIG_PARTITION_ADVANCED=y
> CONFIG_ACORN_PARTITION=y
> # CONFIG_ACORN_PARTITION_CUMANA is not set
> # CONFIG_ACORN_PARTITION_EESOX is not set
> CONFIG_ACORN_PARTITION_ICS=y
> # CONFIG_ACORN_PARTITION_ADFS is not set
> # CONFIG_ACORN_PARTITION_POWERTEC is not set
> CONFIG_ACORN_PARTITION_RISCIX=y
> CONFIG_OSF_PARTITION=y
> CONFIG_AMIGA_PARTITION=y
> CONFIG_ATARI_PARTITION=y
> CONFIG_MAC_PARTITION=y
> CONFIG_MSDOS_PARTITION=y
> CONFIG_BSD_DISKLABEL=y
> CONFIG_MINIX_SUBPARTITION=y
> CONFIG_SOLARIS_X86_PARTITION=y
> CONFIG_UNIXWARE_DISKLABEL=y
> CONFIG_LDM_PARTITION=y
> # CONFIG_LDM_DEBUG is not set
> CONFIG_SGI_PARTITION=y
> CONFIG_ULTRIX_PARTITION=y
> CONFIG_SUN_PARTITION=y
> CONFIG_KARMA_PARTITION=y
> CONFIG_EFI_PARTITION=y
> CONFIG_SYSV68_PARTITION=y
> CONFIG_NLS=y
> CONFIG_NLS_DEFAULT="cp437"
> CONFIG_NLS_CODEPAGE_437=m
> CONFIG_NLS_CODEPAGE_737=m
> CONFIG_NLS_CODEPAGE_775=m
> CONFIG_NLS_CODEPAGE_850=m
> CONFIG_NLS_CODEPAGE_852=m
> CONFIG_NLS_CODEPAGE_855=m
> CONFIG_NLS_CODEPAGE_857=m
> CONFIG_NLS_CODEPAGE_860=m
> CONFIG_NLS_CODEPAGE_861=m
> CONFIG_NLS_CODEPAGE_862=m
> CONFIG_NLS_CODEPAGE_863=m
> CONFIG_NLS_CODEPAGE_864=m
> CONFIG_NLS_CODEPAGE_865=m
> CONFIG_NLS_CODEPAGE_866=m
> CONFIG_NLS_CODEPAGE_869=m
> CONFIG_NLS_CODEPAGE_936=m
> CONFIG_NLS_CODEPAGE_950=m
> CONFIG_NLS_CODEPAGE_932=m
> CONFIG_NLS_CODEPAGE_949=m
> CONFIG_NLS_CODEPAGE_874=m
> CONFIG_NLS_ISO8859_8=m
> CONFIG_NLS_CODEPAGE_1250=m
> CONFIG_NLS_CODEPAGE_1251=m
> CONFIG_NLS_ASCII=m
> CONFIG_NLS_ISO8859_1=m
> CONFIG_NLS_ISO8859_2=m
> CONFIG_NLS_ISO8859_3=m
> CONFIG_NLS_ISO8859_4=m
> CONFIG_NLS_ISO8859_5=m
> CONFIG_NLS_ISO8859_6=m
> CONFIG_NLS_ISO8859_7=m
> CONFIG_NLS_ISO8859_9=m
> CONFIG_NLS_ISO8859_13=m
> CONFIG_NLS_ISO8859_14=m
> CONFIG_NLS_ISO8859_15=m
> CONFIG_NLS_KOI8_R=m
> CONFIG_NLS_KOI8_U=m
> CONFIG_NLS_UTF8=m
> CONFIG_DLM=m
> # CONFIG_DLM_DEBUG is not set
> 
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> CONFIG_PRINTK_TIME=y
> # CONFIG_ENABLE_WARN_DEPRECATED is not set
> # CONFIG_ENABLE_MUST_CHECK is not set
> CONFIG_FRAME_WARN=1024
> CONFIG_MAGIC_SYSRQ=y
> # CONFIG_STRIP_ASM_SYMS is not set
> CONFIG_UNUSED_SYMBOLS=y
> CONFIG_DEBUG_FS=y
> # CONFIG_HEADERS_CHECK is not set
> CONFIG_DEBUG_KERNEL=y
> # CONFIG_DEBUG_SHIRQ is not set
> # CONFIG_LOCKUP_DETECTOR is not set
> # CONFIG_HARDLOCKUP_DETECTOR is not set
> CONFIG_DETECT_HUNG_TASK=y
> # CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
> CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
> CONFIG_SCHED_DEBUG=y
> CONFIG_SCHEDSTATS=y
> CONFIG_TIMER_STATS=y
> # CONFIG_DEBUG_OBJECTS is not set
> # CONFIG_SLUB_DEBUG_ON is not set
> # CONFIG_SLUB_STATS is not set
> # CONFIG_DEBUG_RT_MUTEXES is not set
> # CONFIG_RT_MUTEX_TESTER is not set
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_MUTEXES=y
> # CONFIG_DEBUG_LOCK_ALLOC is not set
> # CONFIG_PROVE_LOCKING is not set
> # CONFIG_LOCK_STAT is not set
> # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
> # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
> CONFIG_STACKTRACE=y
> # CONFIG_DEBUG_KOBJECT is not set
> CONFIG_DEBUG_BUGVERBOSE=y
> CONFIG_DEBUG_INFO=y
> # CONFIG_DEBUG_INFO_REDUCED is not set
> # CONFIG_DEBUG_VM is not set
> # CONFIG_DEBUG_VIRTUAL is not set
> # CONFIG_DEBUG_WRITECOUNT is not set
> CONFIG_DEBUG_MEMORY_INIT=y
> # CONFIG_DEBUG_LIST is not set
> # CONFIG_DEBUG_SG is not set
> # CONFIG_DEBUG_NOTIFIERS is not set
> # CONFIG_DEBUG_CREDENTIALS is not set
> CONFIG_ARCH_WANT_FRAME_POINTERS=y
> CONFIG_FRAME_POINTER=y
> # CONFIG_BOOT_PRINTK_DELAY is not set
> # CONFIG_RCU_TORTURE_TEST is not set
> # CONFIG_RCU_CPU_STALL_DETECTOR is not set
> # CONFIG_KPROBES_SANITY_TEST is not set
> # CONFIG_BACKTRACE_SELF_TEST is not set
> # CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
> # CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
> # CONFIG_LKDTM is not set
> CONFIG_CPU_NOTIFIER_ERROR_INJECT=m
> # CONFIG_FAULT_INJECTION is not set
> CONFIG_LATENCYTOP=y
> CONFIG_SYSCTL_SYSCALL_CHECK=y
> # CONFIG_DEBUG_PAGEALLOC is not set
> CONFIG_USER_STACKTRACE_SUPPORT=y
> CONFIG_NOP_TRACER=y
> CONFIG_HAVE_FTRACE_NMI_ENTER=y
> CONFIG_HAVE_FUNCTION_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
> CONFIG_HAVE_DYNAMIC_FTRACE=y
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
> CONFIG_TRACER_MAX_TRACE=y
> CONFIG_RING_BUFFER=y
> CONFIG_FTRACE_NMI_ENTER=y
> CONFIG_EVENT_TRACING=y
> CONFIG_CONTEXT_SWITCH_TRACER=y
> CONFIG_RING_BUFFER_ALLOW_SWAP=y
> CONFIG_TRACING=y
> CONFIG_GENERIC_TRACER=y
> CONFIG_TRACING_SUPPORT=y
> CONFIG_FTRACE=y
> CONFIG_FUNCTION_TRACER=y
> CONFIG_FUNCTION_GRAPH_TRACER=y
> # CONFIG_IRQSOFF_TRACER is not set
> CONFIG_SCHED_TRACER=y
> CONFIG_FTRACE_SYSCALLS=y
> CONFIG_BRANCH_PROFILE_NONE=y
> # CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
> # CONFIG_PROFILE_ALL_BRANCHES is not set
> CONFIG_STACK_TRACER=y
> CONFIG_BLK_DEV_IO_TRACE=y
> CONFIG_KPROBE_EVENT=y
> CONFIG_DYNAMIC_FTRACE=y
> CONFIG_FUNCTION_PROFILER=y
> CONFIG_FTRACE_MCOUNT_RECORD=y
> # CONFIG_FTRACE_STARTUP_TEST is not set
> CONFIG_MMIOTRACE=y
> # CONFIG_MMIOTRACE_TEST is not set
> # CONFIG_RING_BUFFER_BENCHMARK is not set
> # CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
> # CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
> # CONFIG_DYNAMIC_DEBUG is not set
> # CONFIG_DMA_API_DEBUG is not set
> # CONFIG_ATOMIC64_SELFTEST is not set
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=y
> CONFIG_KGDB=y
> CONFIG_KGDB_SERIAL_CONSOLE=y
> # CONFIG_KGDB_TESTS is not set
> CONFIG_KGDB_LOW_LEVEL_TRAP=y
> CONFIG_KGDB_KDB=y
> CONFIG_KDB_KEYBOARD=y
> CONFIG_HAVE_ARCH_KMEMCHECK=y
> CONFIG_STRICT_DEVMEM=y
> # CONFIG_X86_VERBOSE_BOOTUP is not set
> CONFIG_EARLY_PRINTK=y
> # CONFIG_EARLY_PRINTK_DBGP is not set
> # CONFIG_DEBUG_STACKOVERFLOW is not set
> # CONFIG_DEBUG_STACK_USAGE is not set
> # CONFIG_DEBUG_PER_CPU_MAPS is not set
> # CONFIG_X86_PTDUMP is not set
> CONFIG_DEBUG_RODATA=y
> # CONFIG_DEBUG_RODATA_TEST is not set
> # CONFIG_DEBUG_NX_TEST is not set
> # CONFIG_IOMMU_DEBUG is not set
> # CONFIG_IOMMU_STRESS is not set
> CONFIG_HAVE_MMIOTRACE_SUPPORT=y
> # CONFIG_X86_DECODER_SELFTEST is not set
> CONFIG_IO_DELAY_TYPE_0X80=0
> CONFIG_IO_DELAY_TYPE_0XED=1
> CONFIG_IO_DELAY_TYPE_UDELAY=2
> CONFIG_IO_DELAY_TYPE_NONE=3
> # CONFIG_IO_DELAY_0X80 is not set
> CONFIG_IO_DELAY_0XED=y
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=1
> # CONFIG_DEBUG_BOOT_PARAMS is not set
> # CONFIG_CPA_DEBUG is not set
> CONFIG_OPTIMIZE_INLINING=y
> # CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
> 
> #
> # Security options
> #
> CONFIG_KEYS=y
> # CONFIG_KEYS_DEBUG_PROC_KEYS is not set
> CONFIG_SECURITY=y
> CONFIG_SECURITYFS=y
> CONFIG_SECURITY_NETWORK=y
> # CONFIG_SECURITY_NETWORK_XFRM is not set
> CONFIG_SECURITY_PATH=y
> CONFIG_LSM_MMAP_MIN_ADDR=0
> CONFIG_SECURITY_SELINUX=y
> CONFIG_SECURITY_SELINUX_BOOTPARAM=y
> CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=0
> CONFIG_SECURITY_SELINUX_DISABLE=y
> CONFIG_SECURITY_SELINUX_DEVELOP=y
> CONFIG_SECURITY_SELINUX_AVC_STATS=y
> CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
> # CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
> CONFIG_SECURITY_SMACK=y
> CONFIG_SECURITY_TOMOYO=y
> CONFIG_SECURITY_APPARMOR=y
> CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
> CONFIG_SECURITY_YAMA=y
> # CONFIG_IMA is not set
> # CONFIG_DEFAULT_SECURITY_SELINUX is not set
> # CONFIG_DEFAULT_SECURITY_SMACK is not set
> # CONFIG_DEFAULT_SECURITY_TOMOYO is not set
> CONFIG_DEFAULT_SECURITY_APPARMOR=y
> # CONFIG_DEFAULT_SECURITY_YAMA is not set
> # CONFIG_DEFAULT_SECURITY_DAC is not set
> CONFIG_DEFAULT_SECURITY="apparmor"
> CONFIG_XOR_BLOCKS=m
> CONFIG_ASYNC_CORE=m
> CONFIG_ASYNC_MEMCPY=m
> CONFIG_ASYNC_XOR=m
> CONFIG_ASYNC_PQ=m
> CONFIG_ASYNC_RAID6_RECOV=m
> CONFIG_ASYNC_RAID6_TEST=m
> CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
> CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
> CONFIG_CRYPTO=y
> 
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_FIPS=y
> CONFIG_CRYPTO_ALGAPI=y
> CONFIG_CRYPTO_ALGAPI2=y
> CONFIG_CRYPTO_AEAD=m
> CONFIG_CRYPTO_AEAD2=y
> CONFIG_CRYPTO_BLKCIPHER=y
> CONFIG_CRYPTO_BLKCIPHER2=y
> CONFIG_CRYPTO_HASH=y
> CONFIG_CRYPTO_HASH2=y
> CONFIG_CRYPTO_RNG=m
> CONFIG_CRYPTO_RNG2=y
> CONFIG_CRYPTO_PCOMP=m
> CONFIG_CRYPTO_PCOMP2=y
> CONFIG_CRYPTO_MANAGER=y
> CONFIG_CRYPTO_MANAGER2=y
> CONFIG_CRYPTO_MANAGER_TESTS=y
> CONFIG_CRYPTO_GF128MUL=m
> CONFIG_CRYPTO_NULL=m
> CONFIG_CRYPTO_PCRYPT=m
> CONFIG_CRYPTO_WORKQUEUE=y
> CONFIG_CRYPTO_CRYPTD=m
> CONFIG_CRYPTO_AUTHENC=m
> CONFIG_CRYPTO_TEST=m
> 
> #
> # Authenticated Encryption with Associated Data
> #
> CONFIG_CRYPTO_CCM=m
> CONFIG_CRYPTO_GCM=m
> CONFIG_CRYPTO_SEQIV=m
> 
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=y
> CONFIG_CRYPTO_CTR=m
> CONFIG_CRYPTO_CTS=m
> CONFIG_CRYPTO_ECB=y
> CONFIG_CRYPTO_LRW=m
> CONFIG_CRYPTO_PCBC=m
> CONFIG_CRYPTO_XTS=m
> CONFIG_CRYPTO_FPU=m
> 
> #
> # Hash modes
> #
> CONFIG_CRYPTO_HMAC=y
> CONFIG_CRYPTO_XCBC=m
> CONFIG_CRYPTO_VMAC=m
> 
> #
> # Digest
> #
> CONFIG_CRYPTO_CRC32C=m
> CONFIG_CRYPTO_CRC32C_INTEL=m
> CONFIG_CRYPTO_GHASH=m
> CONFIG_CRYPTO_MD4=m
> CONFIG_CRYPTO_MD5=y
> CONFIG_CRYPTO_MICHAEL_MIC=m
> CONFIG_CRYPTO_RMD128=m
> CONFIG_CRYPTO_RMD160=m
> CONFIG_CRYPTO_RMD256=m
> CONFIG_CRYPTO_RMD320=m
> CONFIG_CRYPTO_SHA1=m
> CONFIG_CRYPTO_SHA256=m
> CONFIG_CRYPTO_SHA512=m
> CONFIG_CRYPTO_TGR192=m
> CONFIG_CRYPTO_WP512=m
> CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m
> 
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=m
> CONFIG_CRYPTO_AES_X86_64=m
> CONFIG_CRYPTO_AES_NI_INTEL=m
> CONFIG_CRYPTO_ANUBIS=m
> CONFIG_CRYPTO_ARC4=m
> CONFIG_CRYPTO_BLOWFISH=m
> CONFIG_CRYPTO_CAMELLIA=m
> CONFIG_CRYPTO_CAST5=m
> CONFIG_CRYPTO_CAST6=m
> CONFIG_CRYPTO_DES=m
> CONFIG_CRYPTO_FCRYPT=m
> CONFIG_CRYPTO_KHAZAD=m
> CONFIG_CRYPTO_SALSA20=m
> CONFIG_CRYPTO_SALSA20_X86_64=m
> CONFIG_CRYPTO_SEED=m
> CONFIG_CRYPTO_SERPENT=m
> CONFIG_CRYPTO_TEA=m
> CONFIG_CRYPTO_TWOFISH=m
> CONFIG_CRYPTO_TWOFISH_COMMON=m
> CONFIG_CRYPTO_TWOFISH_X86_64=m
> 
> #
> # Compression
> #
> CONFIG_CRYPTO_DEFLATE=m
> CONFIG_CRYPTO_ZLIB=m
> CONFIG_CRYPTO_LZO=m
> 
> #
> # Random Number Generation
> #
> CONFIG_CRYPTO_ANSI_CPRNG=m
> CONFIG_CRYPTO_HW=y
> CONFIG_CRYPTO_DEV_PADLOCK=y
> CONFIG_CRYPTO_DEV_PADLOCK_AES=m
> CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
> CONFIG_CRYPTO_DEV_HIFN_795X=m
> CONFIG_CRYPTO_DEV_HIFN_795X_RNG=y
> CONFIG_HAVE_KVM=y
> CONFIG_HAVE_KVM_IRQCHIP=y
> CONFIG_HAVE_KVM_EVENTFD=y
> CONFIG_KVM_APIC_ARCHITECTURE=y
> CONFIG_KVM_MMIO=y
> CONFIG_VIRTUALIZATION=y
> CONFIG_KVM=m
> CONFIG_KVM_INTEL=m
> CONFIG_KVM_AMD=m
> CONFIG_VHOST_NET=m
> CONFIG_VIRTIO=y
> CONFIG_VIRTIO_RING=y
> CONFIG_VIRTIO_PCI=y
> CONFIG_VIRTIO_BALLOON=m
> CONFIG_BINARY_PRINTF=y
> 
> #
> # Library routines
> #
> CONFIG_RAID6_PQ=m
> CONFIG_BITREVERSE=y
> CONFIG_GENERIC_FIND_FIRST_BIT=y
> CONFIG_GENERIC_FIND_NEXT_BIT=y
> CONFIG_GENERIC_FIND_LAST_BIT=y
> CONFIG_CRC_CCITT=m
> CONFIG_CRC16=y
> CONFIG_CRC_T10DIF=y
> CONFIG_CRC_ITU_T=m
> CONFIG_CRC32=y
> CONFIG_CRC7=m
> CONFIG_LIBCRC32C=m
> CONFIG_ZLIB_INFLATE=y
> CONFIG_ZLIB_DEFLATE=m
> CONFIG_LZO_COMPRESS=m
> CONFIG_LZO_DECOMPRESS=y
> CONFIG_DECOMPRESS_GZIP=y
> CONFIG_DECOMPRESS_BZIP2=y
> CONFIG_DECOMPRESS_LZMA=y
> CONFIG_DECOMPRESS_LZO=y
> CONFIG_GENERIC_ALLOCATOR=y
> CONFIG_REED_SOLOMON=m
> CONFIG_REED_SOLOMON_DEC16=y
> CONFIG_TEXTSEARCH=y
> CONFIG_TEXTSEARCH_KMP=m
> CONFIG_TEXTSEARCH_BM=m
> CONFIG_TEXTSEARCH_FSM=m
> CONFIG_HAS_IOMEM=y
> CONFIG_HAS_IOPORT=y
> CONFIG_HAS_DMA=y
> CONFIG_CHECK_SIGNATURE=y
> CONFIG_NLATTR=y
> CONFIG_LRU_CACHE=m
