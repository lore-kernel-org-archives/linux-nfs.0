Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.wiktel.com ([69.89.207.152]:33815 "EHLO smtp2.wiktel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbcCHRGK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 12:06:10 -0500
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
References: <56BFE55D.1010509@wiktel.com>
Cc: linux-nfs@vger.kernel.org
From: Richard Laager <rlaager@wiktel.com>
Message-ID: <56DF067F.4090606@wiktel.com>
Date: Tue, 8 Mar 2016 11:06:07 -0600
MIME-Version: 1.0
In-Reply-To: <56BFE55D.1010509@wiktel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there anything else I can do to help diagnose this?

Am I correct in thinking this is a bug?

On 02/13/2016 08:24 PM, Richard Laager wrote:
> [1.] One line summary of the problem:
>
> NFS Client Ignores TCP Resets
>
> [2.] Full description of the problem/report:
>
> Steps to reproduce:
> 1) Mount NFS share from HA cluster with TCP.
> 2) Failover the HA cluster. (The NFS server's IP address moves from one
>     machine to the other.)
> 3) Access the mounted NFS share from the client (an `ls` is sufficient).
>
> Expected results:
> Accessing the NFS mount works fine immediately.
>
> Actual results:
> Accessing the NFS mount hangs for 5 minutes. Then the TCP connection
> times out, a new connection is established, and it works fine again.
>
> After the IP moves, the new server responds to the client with TCP RST
> packets, just as I would expect. I would expect the client to tear down
> its TCP connection immediately and re-establish a new one. But it
> doesn't. Am I confused, or is this a bug?
>
> For the duration of this test, all iptables firewalling was disabled on
> the client machine.
>
> I have a packet capture of a minimized test (just a simple ls):
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1542826/+attachment/4571304/+files/dovecot-test.upstream-kernel.pcap
>
>
> Note that this is a "single failover" scenario. It is NOT a case of
> failing over and then failing back before the TCP connection times out
> on the first NFS server.
>
> [3.] Keywords (i.e., modules, networking, kernel):
>
> [4.] Kernel version (from /proc/version):
>
> Linux version 4.5.0-040500rc3-generic (kernel@gomeisa) (gcc version
> 5.2.1 20151010 (Ubuntu 5.2.1-22ubuntu2) ) #201602071930 SMP Mon Feb 8
> 00:34:43 UTC 2016
>
> [5.] Output of Oops.. message (if applicable) with symbolic information
>       resolved (see Documentation/oops-tracing.txt)
>
> N/A. No Oops.
>
> [6.] A small shell script or example program which triggers the
>       problem (if possible)
>
> This is not a self-contained example, but this information may be useful:
>
> echo 10.20.0.30:/export/krls1/mail /mnt/mail nfs
> bg,noacl,noatime,noexec,nordirplus,proto=tcp,vers=3 0 0 >> /etc/fstab
> mount /mnt/mail
> ls /mnt/mail # Works
> # Failover HA cluster
> ls /mnt/mail # Hangs for 5 minutes
>
> [7.] Environment
>
> $ lsb_release -rd
> Description:    Ubuntu 15.10
> Release:    15.10
>
> [7.1.] Software (add the output of the ver_linux script here)
>
> $ sh ver_linux
> If some fields are empty or look unusual you may have an old version.
> Compare to the current minimal requirements in Documentation/Changes.
>
> Linux dovecot-test 4.5.0-040500rc3-generic #201602071930 SMP Mon Feb 8
> 00:34:43 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>
> GNU C            5.2.1
> GNU Make        4.0
> Binutils        2.25.1
> Util-linux        2.26.2
> Mount            2.26.2
> Module-init-tools    21
> E2fsprogs        1.42.12
> Linux C Library        2.21
> Dynamic linker (ldd)    2.21
> Linux C++ Library    6.0.21
> Procps            3.3.9
> Net-tools        1.60
> Kbd            1.15.5
> Console-tools        1.15.5
> Sh-utils        8.23
> Udev            225
> Wireless-tools        30
> Modules Loaded        8250_fintek autofs4 cirrus drm drm_kms_helper
> fb_sys_fops floppy fscache grace i2c_piix4 input_leds ip6table_filter
> ip6_tables ip6t_REJECT ip6t_rt iptable_filter ip_tables ipt_REJECT
> irqbypass joydev kvm kvm_intel lockd mac_hid nf_conntrack
> nf_conntrack_broadcast nf_conntrack_ftp nf_conntrack_ipv4
> nf_conntrack_ipv6 nf_conntrack_netbios_ns nf_defrag_ipv4 nf_defrag_ipv6
> nf_nat nf_nat_ftp nf_reject_ipv4 nf_reject_ipv6 nfs nfs_acl nfsv3
> parport parport_pc pata_acpi ppdev psmouse pvpanic serio_raw sunrpc
> syscopyarea sysfillrect sysimgblt ttm x_tables xt_addrtype xt_comment
> xt_conntrack xt_hl xt_limit xt_multiport xt_recent xt_tcpudp
>
> [7.2.] Processor information (from /proc/cpuinfo):
>
> $ cat /proc/cpuinfo
> processor    : 0
> vendor_id    : GenuineIntel
> cpu family    : 6
> model        : 23
> model name    : Intel Core 2 Duo P9xxx (Penryn Class Core 2)
> stepping    : 3
> microcode    : 0x1
> cpu MHz        : 2666.764
> cache size    : 4096 KB
> physical id    : 0
> siblings    : 1
> core id        : 0
> cpu cores    : 1
> apicid        : 0
> initial apicid    : 0
> fpu        : yes
> fpu_exception    : yes
> cpuid level    : 4
> wp        : yes
> flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
> cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx lm constant_tsc
> rep_good nopl pni vmx ssse3 cx16 sse4_1 x2apic hypervisor lahf_lm vnmi ept
> bugs        :
> bogomips    : 5333.52
> clflush size    : 64
> cache_alignment    : 64
> address sizes    : 40 bits physical, 48 bits virtual
> power management:
>
> processor    : 1
> vendor_id    : GenuineIntel
> cpu family    : 6
> model        : 23
> model name    : Intel Core 2 Duo P9xxx (Penryn Class Core 2)
> stepping    : 3
> microcode    : 0x1
> cpu MHz        : 2666.764
> cache size    : 4096 KB
> physical id    : 1
> siblings    : 1
> core id        : 0
> cpu cores    : 1
> apicid        : 1
> initial apicid    : 1
> fpu        : yes
> fpu_exception    : yes
> cpuid level    : 4
> wp        : yes
> flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
> cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx lm constant_tsc
> rep_good nopl pni vmx ssse3 cx16 sse4_1 x2apic hypervisor lahf_lm vnmi ept
> bugs        :
> bogomips    : 5333.52
> clflush size    : 64
> cache_alignment    : 64
> address sizes    : 40 bits physical, 48 bits virtual
> power management:
>
> [7.3.] Module information (from /proc/modules):
>
> $ cat /proc/modules
> nfsv3 40960 1 - Live 0x0000000000000000
> nfs_acl 16384 1 nfsv3, Live 0x0000000000000000
> nfs 253952 2 nfsv3, Live 0x0000000000000000
> lockd 94208 2 nfsv3,nfs, Live 0x0000000000000000
> grace 16384 1 lockd, Live 0x0000000000000000
> fscache 61440 1 nfs, Live 0x0000000000000000
> ppdev 20480 0 - Live 0x0000000000000000
> kvm_intel 184320 0 - Live 0x0000000000000000
> kvm 561152 1 kvm_intel, Live 0x0000000000000000
> joydev 20480 0 - Live 0x0000000000000000
> input_leds 16384 0 - Live 0x0000000000000000
> irqbypass 16384 1 kvm, Live 0x0000000000000000
> serio_raw 16384 0 - Live 0x0000000000000000
> i2c_piix4 24576 0 - Live 0x0000000000000000
> 8250_fintek 16384 0 - Live 0x0000000000000000
> pvpanic 16384 0 - Live 0x0000000000000000
> parport_pc 32768 0 - Live 0x0000000000000000
> parport 49152 2 ppdev,parport_pc, Live 0x0000000000000000
> mac_hid 16384 0 - Live 0x0000000000000000
> ip6t_REJECT 16384 1 - Live 0x0000000000000000
> nf_reject_ipv6 16384 1 ip6t_REJECT, Live 0x0000000000000000
> xt_hl 16384 22 - Live 0x0000000000000000
> ip6t_rt 16384 3 - Live 0x0000000000000000
> nf_conntrack_ipv6 20480 9 - Live 0x0000000000000000
> nf_defrag_ipv6 36864 1 nf_conntrack_ipv6, Live 0x0000000000000000
> ipt_REJECT 16384 1 - Live 0x0000000000000000
> nf_reject_ipv4 16384 1 ipt_REJECT, Live 0x0000000000000000
> xt_comment 16384 8 - Live 0x0000000000000000
> xt_multiport 16384 2 - Live 0x0000000000000000
> xt_recent 20480 4 - Live 0x0000000000000000
> xt_limit 16384 1 - Live 0x0000000000000000
> xt_tcpudp 16384 26 - Live 0x0000000000000000
> xt_addrtype 16384 4 - Live 0x0000000000000000
> nf_conntrack_ipv4 16384 9 - Live 0x0000000000000000
> nf_defrag_ipv4 16384 1 nf_conntrack_ipv4, Live 0x0000000000000000
> xt_conntrack 16384 18 - Live 0x0000000000000000
> ip6table_filter 16384 1 - Live 0x0000000000000000
> ip6_tables 28672 1 ip6table_filter, Live 0x0000000000000000
> nf_conntrack_netbios_ns 16384 0 - Live 0x0000000000000000
> nf_conntrack_broadcast 16384 1 nf_conntrack_netbios_ns, Live
> 0x0000000000000000
> nf_nat_ftp 16384 0 - Live 0x0000000000000000
> nf_nat 24576 1 nf_nat_ftp, Live 0x0000000000000000
> nf_conntrack_ftp 20480 1 nf_nat_ftp, Live 0x0000000000000000
> nf_conntrack 106496 8
> nf_conntrack_ipv6,nf_conntrack_ipv4,xt_conntrack,nf_conntrack_netbios_ns,nf_conntrack_broadcast,nf_nat_ftp,nf_nat,nf_conntrack_ftp,
> Live 0x0000000000000000
> iptable_filter 16384 1 - Live 0x0000000000000000
> ip_tables 28672 1 iptable_filter, Live 0x0000000000000000
> x_tables 36864 15
> ip6t_REJECT,xt_hl,ip6t_rt,ipt_REJECT,xt_comment,xt_multiport,xt_recent,xt_limit,xt_tcpudp,xt_addrtype,xt_conntrack,ip6table_filter,ip6_tables,iptable_filter,ip_tables,
> Live 0x0000000000000000
> sunrpc 335872 17 nfsv3,nfs_acl,nfs,lockd, Live 0x0000000000000000
> autofs4 40960 2 - Live 0x0000000000000000
> cirrus 28672 1 - Live 0x0000000000000000
> ttm 98304 1 cirrus, Live 0x0000000000000000
> drm_kms_helper 147456 1 cirrus, Live 0x0000000000000000
> syscopyarea 16384 1 drm_kms_helper, Live 0x0000000000000000
> sysfillrect 16384 1 drm_kms_helper, Live 0x0000000000000000
> sysimgblt 16384 1 drm_kms_helper, Live 0x0000000000000000
> fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
> floppy 73728 0 - Live 0x0000000000000000
> drm 364544 4 cirrus,ttm,drm_kms_helper, Live 0x0000000000000000
> psmouse 126976 0 - Live 0x0000000000000000
> pata_acpi 16384 0 - Live 0x0000000000000000
>
> [7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
>
> $ cat /proc/ioports
> 0000-0cf7 : PCI Bus 0000:00
>    0000-001f : dma1
>    0020-0021 : pic1
>    0040-0043 : timer0
>    0050-0053 : timer1
>    0060-0060 : keyboard
>    0064-0064 : keyboard
>    0070-0071 : rtc0
>    0080-008f : dma page reg
>    00a0-00a1 : pic2
>    00c0-00df : dma2
>    00f0-00ff : fpu
>    0170-0177 : 0000:00:01.1
>      0170-0177 : ata_piix
>    01f0-01f7 : 0000:00:01.1
>      01f0-01f7 : ata_piix
>    0376-0376 : 0000:00:01.1
>      0376-0376 : ata_piix
>    03f2-03f2 : floppy
>    03f4-03f5 : floppy
>    03f6-03f6 : 0000:00:01.1
>      03f6-03f6 : ata_piix
>    03f7-03f7 : floppy
>    03f8-03ff : serial
> 0cf8-0cff : PCI conf1
> 0d00-adff : PCI Bus 0000:00
>    5658-565b : vmmouse
> ae0f-aeff : PCI Bus 0000:00
> af20-afdf : PCI Bus 0000:00
> afe0-afe3 : ACPI GPE0_BLK
> afe4-ffff : PCI Bus 0000:00
>    b000-b03f : 0000:00:01.3
>      b000-b003 : ACPI PM1a_EVT_BLK
>      b004-b005 : ACPI PM1a_CNT_BLK
>      b008-b00b : ACPI PM_TMR
>    b100-b10f : 0000:00:01.3
>      b100-b107 : piix4_smbus
>    c000-c03f : 0000:00:04.0
>      c000-c03f : virtio-pci-legacy
>    c040-c07f : 0000:00:05.0
>      c040-c07f : virtio-pci-legacy
>    c080-c09f : 0000:00:01.2
>      c080-c09f : uhci_hcd
>    c0a0-c0bf : 0000:00:03.0
>      c0a0-c0bf : virtio-pci-legacy
>    c0c0-c0df : 0000:00:06.0
>      c0c0-c0df : virtio-pci-legacy
>    c0e0-c0ff : 0000:00:08.0
>      c0e0-c0ff : virtio-pci-legacy
>    c100-c10f : 0000:00:01.1
>      c100-c10f : ata_piix
>
> $ cat /proc/iomem
> 00000000-00000fff : reserved
> 00001000-0009fbff : System RAM
> 0009fc00-0009ffff : reserved
> 000a0000-000bffff : PCI Bus 0000:00
> 000c0000-000c8dff : Video ROM
> 000c9000-000c99ff : Adapter ROM
> 000ca000-000ca9ff : Adapter ROM
> 000cb000-000cd3ff : Adapter ROM
> 000f0000-000fffff : reserved
>    000f0000-000fffff : System ROM
> 00100000-3fffdfff : System RAM
>    01000000-018284f9 : Kernel code
>    018284fa-01f4497f : Kernel data
>    020c3000-02205fff : Kernel bss
> 3fffe000-3fffffff : reserved
> 40000000-febfffff : PCI Bus 0000:00
>    fc000000-fdffffff : 0000:00:02.0
>      fc000000-fdffffff : cirrusdrmfb_vram
>    feb40000-feb7ffff : 0000:00:03.0
>    feb80000-febbffff : 0000:00:08.0
>    febc0000-febcffff : 0000:00:02.0
>    febd0000-febd0fff : 0000:00:02.0
>      febd0000-febd0fff : cirrusdrmfb_mmio
>    febd1000-febd1fff : 0000:00:03.0
>    febd2000-febd2fff : 0000:00:04.0
>    febd3000-febd3fff : 0000:00:05.0
>    febd4000-febd400f : 0000:00:07.0
>    febd5000-febd5fff : 0000:00:08.0
> fec00000-fec003ff : IOAPIC 0
> fed00000-fed003ff : HPET 0
>    fed00000-fed003ff : PNP0103:00
> fee00000-fee00fff : Local APIC
> feffc000-feffffff : reserved
> fffc0000-ffffffff : reserved
>
> [7.5.] PCI information ('lspci -vvv' as root)
>
> $ sudo lspci -vvv
> 00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev
> 02)
>      Subsystem: Red Hat, Inc Qemu virtual machine
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>
> 00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
>      Subsystem: Red Hat, Inc Qemu virtual machine
>      Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>
> 00:01.1 IDE interface: Intel Corporation 82371SB PIIX3 IDE
> [Natoma/Triton II] (prog-if 80 [Master])
>      Subsystem: Red Hat, Inc Qemu virtual machine
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable)
> [size=8]
>      Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)
>      Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable)
> [size=8]
>      Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)
>      Region 4: I/O ports at c100 [size=16]
>      Kernel driver in use: ata_piix
>
> 00:01.2 USB controller: Intel Corporation 82371SB PIIX3 USB
> [Natoma/Triton II] (rev 01) (prog-if 00 [UHCI])
>      Subsystem: Red Hat, Inc QEMU Virtual Machine
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin D routed to IRQ 10
>      Region 4: I/O ports at c080 [size=32]
>      Kernel driver in use: uhci_hcd
>
> 00:01.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 03)
>      Subsystem: Red Hat, Inc Qemu virtual machine
>      Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Interrupt: pin A routed to IRQ 9
>      Kernel driver in use: piix4_smbus
>
> 00:02.0 VGA compatible controller: Cirrus Logic GD 5446 (prog-if 00 [VGA
> controller])
>      Subsystem: Red Hat, Inc QEMU Virtual Machine
>      Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Region 0: Memory at fc000000 (32-bit, prefetchable) [size=32M]
>      Region 1: Memory at febd0000 (32-bit, non-prefetchable) [size=4K]
>      Expansion ROM at febc0000 [disabled] [size=64K]
>      Kernel driver in use: cirrus
>
> 00:03.0 Ethernet controller: Red Hat, Inc Virtio network device
>      Subsystem: Red Hat, Inc Device 0001
>      Physical Slot: 3
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx+
>      Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin A routed to IRQ 0
>      Region 0: I/O ports at c0a0 [size=32]
>      Region 1: Memory at febd1000 (32-bit, non-prefetchable) [size=4K]
>      Expansion ROM at feb40000 [disabled] [size=256K]
>      Capabilities: [40] MSI-X: Enable+ Count=3 Masked-
>          Vector table: BAR=1 offset=00000000
>          PBA: BAR=1 offset=00000800
>      Kernel driver in use: virtio-pci
>
> 00:04.0 SCSI storage controller: Red Hat, Inc Virtio block device
>      Subsystem: Red Hat, Inc Device 0002
>      Physical Slot: 4
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx+
>      Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin A routed to IRQ 0
>      Region 0: I/O ports at c000 [size=64]
>      Region 1: Memory at febd2000 (32-bit, non-prefetchable) [size=4K]
>      Capabilities: [40] MSI-X: Enable+ Count=2 Masked-
>          Vector table: BAR=1 offset=00000000
>          PBA: BAR=1 offset=00000800
>      Kernel driver in use: virtio-pci
>
> 00:05.0 SCSI storage controller: Red Hat, Inc Virtio block device
>      Subsystem: Red Hat, Inc Device 0002
>      Physical Slot: 5
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx+
>      Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin A routed to IRQ 0
>      Region 0: I/O ports at c040 [size=64]
>      Region 1: Memory at febd3000 (32-bit, non-prefetchable) [size=4K]
>      Capabilities: [40] MSI-X: Enable+ Count=2 Masked-
>          Vector table: BAR=1 offset=00000000
>          PBA: BAR=1 offset=00000800
>      Kernel driver in use: virtio-pci
>
> 00:06.0 Unclassified device [00ff]: Red Hat, Inc Virtio memory balloon
>      Subsystem: Red Hat, Inc Device 0005
>      Physical Slot: 6
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin A routed to IRQ 11
>      Region 0: I/O ports at c0c0 [size=32]
>      Kernel driver in use: virtio-pci
>
> 00:07.0 System peripheral: Intel Corporation 6300ESB Watchdog Timer
>      Subsystem: Red Hat, Inc QEMU Virtual Machine
>      Physical Slot: 7
>      Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Region 0: Memory at febd4000 (32-bit, non-prefetchable) [size=16]
>
> 00:08.0 Ethernet controller: Red Hat, Inc Virtio network device
>      Subsystem: Red Hat, Inc Device 0001
>      Physical Slot: 8
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx+
>      Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin A routed to IRQ 0
>      Region 0: I/O ports at c0e0 [size=32]
>      Region 1: Memory at febd5000 (32-bit, non-prefetchable) [size=4K]
>      Expansion ROM at feb80000 [disabled] [size=256K]
>      Capabilities: [40] MSI-X: Enable+ Count=3 Masked-
>          Vector table: BAR=1 offset=00000000
>          PBA: BAR=1 offset=00000800
>      Kernel driver in use: virtio-pci
>
> [7.6.] SCSI information (from /proc/scsi/scsi)
>
> $ cat /proc/scsi/scsi
> Attached devices:
> Host: scsi1 Channel: 00 Id: 00 Lun: 00
>    Vendor: QEMU     Model: QEMU DVD-ROM     Rev: 2.0.
>    Type:   CD-ROM                           ANSI  SCSI revision: 05
>
> [7.7.] Other information that might be relevant to the problem
>         (please look in /proc and include all information that you
>         think to be relevant):
>
> $ grep mail /proc/mounts
> 10.20.0.30:/export/krls1/mail /mnt/mail nfs
> rw,noexec,noatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,noacl,nordirplus,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.20.0.30,mountvers=3,mountport=59274,mountproto=tcp,local_lock=none,addr=10.20.0.30
> 0 0
>
> [X.] Other notes, patches, fixes, workarounds:
>
> This particular system is a virtual machine, but we have seen this on
> physical hardware as well.
>
> If we use UDP instead of TCP, then the NFS client handles the failover
> in a timely manner.
>
> The NFS HA cluster is a system from Nexenta running their latest
> software, which is based on Illumos. Our Nexenta reseller's standard
> recommendation for HA clusters is to use UDP, because of this behavior.
>
> For our physical machines acting as virtual hosts, it doesn't make a lot
> of difference, but in the virtual machine, I'd especially like to use
> TCP, as it performs quite a bit better.
>


-- 
Richard
