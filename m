Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.archive.org ([207.241.224.6]:44294 "EHLO mail.archive.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbaKYBNg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2014 20:13:36 -0500
Received: from mail.archive.org (localhost [127.0.0.1])
	by mail.archive.org (Postfix) with ESMTP id 66798BB67
	for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2014 01:06:50 +0000 (UTC)
Received: from [10.30.65.27] (router300.sf.archive.org [208.70.27.190])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: abezella@archive.org)
	by mail.archive.org (Postfix) with ESMTPSA id 5F7E8BB65
	for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2014 01:06:50 +0000 (UTC)
Message-ID: <1416877610.325.37.camel@abezella-laptop.us.archive.org>
Subject: xprt_adjust_timeout followed by lockd: server not responding /
 server OK
From: andrew bezella <abezella@archive.org>
To: linux-nfs@vger.kernel.org
Date: Mon, 24 Nov 2014 17:06:50 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[1.] One line summary of the problem:  
kernel and lockd xprt_adjust_timeout rq_timeout 
  
[2.] Full description of the problem/report:
we recently deployed an ubuntu 14.04 vm w/an nfs-mounted /home as a
shell server and transitioned a power user/developer over to it for
testing.  after a few weeks w/o issues there were reports of sporadic
hangs and/or unresponsiveness.  i noticed that messages like the
following had been logged: 
[ 3363.821785] xprt_adjust_timeout: rq_timeout = 0!
[ 3363.821792] lockd: server nfs-home not responding, still trying
[ 3364.063298] lockd: server nfs-home OK
[ 3809.070778] xprt_adjust_timeout: rq_timeout = 0!
[ 3809.070784] lockd: server nfs-home not responding, still trying
[ 3809.332988] lockd: server nfs-home OK

further investigation showed that these had been occurring and continue
to occur, so i do not believe they are necessarily related to the
reported issues.  however, they are appearing on a number of ubuntu
14.04 hosts.  as requested by the ubuntu maintainers i installed the
newest upstream mainline kernel and verified that the messages continue
to be logged.

[3.] Keywords (i.e., modules, networking, kernel):

[4.] Kernel version (from /proc/version): 
Linux version 3.18.0-031800rc6-generic (apw@gomeisa) (gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201411231935 SMP Mon Nov 24 00:36:20 UTC 2014

[5.] Output of Oops.. message (if applicable) with symbolic information 
     resolved (see Documentation/oops-tracing.txt)

not applicable

[6.] A small shell script or example program which triggers the
     problem (if possible)

immediate trigger unknown. it appears to be brought on by something in
the user's workflow; i am unable to trigger it but w/o minutes of the
other's login the messages start appearing.

[7.] Environment
Description: Ubuntu 14.04.1 LTS
Release: 14.04

[7.1.] Software (add the output of the ver_linux script here)
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux vm-home1.archive.org 3.18.0-031800rc6-generic #201411231935 SMP
Mon Nov 24 00:36:20 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux

Gnu C                  4.8
Gnu make               3.81
binutils               2.24
util-linux             2.20.1
mount                  support
module-init-tools      15
e2fsprogs              1.42.9
Linux C Library        2.19
Dynamic linker (ldd)   2.19
Procps                 3.3.9
Net-tools              1.60
Kbd                    1.15.5
Sh-utils               8.21
Modules Loaded         ip6table_filter ip6_tables iptable_filter
ip_tables x_tables nfsv3 nfsd auth_rpcgss nfs_acl nfs lockd grace sunrpc
fscache ppdev joydev hid_generic cirrus kvm ttm drm_kms_helper
8250_fintek parport_pc drm serio_raw parport syscopyarea sysfillrect
sysimgblt i2c_piix4 mac_hid usbhid hid sch_fq_codel usbkbd floppy
psmouse

[7.2.] Processor information (from /proc/cpuinfo): 
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 0
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 1
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 2
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 2
initial apicid	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 3
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 3
initial apicid	: 3
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 4
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 4
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 4
initial apicid	: 4
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 5
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 5
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 5
initial apicid	: 5
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 6
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 6
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 6
initial apicid	: 6
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 7
vendor_id	: GenuineIntel
cpu family	: 6
model		: 2
model name	: QEMU Virtual CPU version 1.0
stepping	: 3
microcode	: 0x1
cpu MHz		: 2399.996
cache size	: 4096 KB
physical id	: 7
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 7
initial apicid	: 7
fpu		: yes
fpu_exception	: yes
cpuid level	: 4
wp		: yes
flags		: fpu de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pse36 clflush mmx fxsr sse sse2 syscall nx lm rep_good nopl pni vmx cx16 popcnt hypervisor lahf_lm
bugs		:
bogomips	: 4799.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

[7.3.] Module information (from /proc/modules): 
ip6table_filter 12815 0 - Live 0x0000000000000000
ip6_tables 27504 1 ip6table_filter, Live 0x0000000000000000
iptable_filter 12810 1 - Live 0x0000000000000000
ip_tables 27718 1 iptable_filter, Live 0x0000000000000000
x_tables 34102 4 ip6table_filter,ip6_tables,iptable_filter,ip_tables, Live 0x0000000000000000
nfsv3 39619 1 - Live 0x0000000000000000
nfsd 302377 2 - Live 0x0000000000000000
auth_rpcgss 60078 1 nfsd, Live 0x0000000000000000
nfs_acl 12883 2 nfsv3,nfsd, Live 0x0000000000000000
nfs 249550 2 nfsv3, Live 0x0000000000000000
lockd 94786 3 nfsv3,nfsd,nfs, Live 0x0000000000000000
grace 13295 2 nfsd,lockd, Live 0x0000000000000000
sunrpc 302693 20 nfsv3,nfsd,auth_rpcgss,nfs_acl,nfs,lockd, Live 0x0000000000000000
fscache 64236 1 nfs, Live 0x0000000000000000
ppdev 17711 0 - Live 0x0000000000000000
joydev 17587 0 - Live 0x0000000000000000
hid_generic 12559 0 - Live 0x0000000000000000
cirrus 25159 1 - Live 0x0000000000000000
kvm 475233 0 - Live 0x0000000000000000
ttm 90228 1 cirrus, Live 0x0000000000000000
drm_kms_helper 99802 1 cirrus, Live 0x0000000000000000
8250_fintek 12925 0 - Live 0x0000000000000000
parport_pc 32909 0 - Live 0x0000000000000000
drm 323675 4 cirrus,ttm,drm_kms_helper, Live 0x0000000000000000
serio_raw 13483 0 - Live 0x0000000000000000
parport 42481 2 ppdev,parport_pc, Live 0x0000000000000000
syscopyarea 12633 1 cirrus, Live 0x0000000000000000
sysfillrect 12901 1 cirrus, Live 0x0000000000000000
sysimgblt 12806 1 cirrus, Live 0x0000000000000000
i2c_piix4 22311 0 - Live 0x0000000000000000
mac_hid 13275 0 - Live 0x0000000000000000
usbhid 53155 0 - Live 0x0000000000000000
hid 110572 2 hid_generic,usbhid, Live 0x0000000000000000
sch_fq_codel 17646 2 - Live 0x0000000000000000
usbkbd 12968 0 - Live 0x0000000000000000
floppy 74508 0 - Live 0x0000000000000000
psmouse 118326 0 - Live 0x0000000000000000

[7.4.] Loaded driver and hardware information
(/proc/ioports, /proc/iomem)
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-0060 : keyboard
0064-0064 : keyboard
0070-0071 : rtc0
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : 0000:00:01.1
  0170-0177 : ata_piix
01f0-01f7 : 0000:00:01.1
  01f0-01f7 : ata_piix
0376-0376 : 0000:00:01.1
  0376-0376 : ata_piix
0378-037a : parport0
03c0-03df : vga+
03f2-03f2 : floppy
03f4-03f5 : floppy
03f6-03f6 : 0000:00:01.1
  03f6-03f6 : ata_piix
03f7-03f7 : floppy
03f8-03ff : serial
0cf8-0cff : PCI conf1
afe0-afe3 : ACPI GPE0_BLK
b000-b03f : 0000:00:01.3
  b000-b003 : ACPI PM1a_EVT_BLK
  b004-b005 : ACPI PM1a_CNT_BLK
  b008-b00b : ACPI PM_TMR
  b010-b015 : ACPI CPU throttle
b100-b10f : 0000:00:01.3
  b100-b107 : piix4_smbus
c000-c03f : 0000:00:05.0
  c000-c03f : virtio-pci
c040-c05f : 0000:00:01.2
  c040-c05f : uhci_hcd
c060-c07f : 0000:00:03.0
  c060-c07f : virtio-pci
c080-c09f : 0000:00:04.0
  c080-c09f : virtio-pci
c0a0-c0af : 0000:00:01.1
  c0a0-c0af : ata_pii

00000000-00000fff : reserved
00001000-0009dbff : System RAM
0009dc00-0009ffff : reserved
000c0000-000c8bff : Video ROM
000c9000-000cb3ff : Adapter ROM
000f0000-000fffff : reserved
  000f0000-000fffff : System ROM
00100000-dfffcfff : System RAM
  01000000-017b84f7 : Kernel code
  017b84f8-01d20f7f : Kernel data
  01e86000-01fcefff : Kernel bss
dfffd000-dfffffff : reserved
fc000000-fdffffff : 0000:00:02.0
  fc000000-fc3fffff : cirrusdrmfb_vram
febe0000-febeffff : 0000:00:02.0
febf0000-febf0fff : 0000:00:02.0
  febf0000-febf0fff : cirrusdrmfb_mmio
febf1000-febf1fff : 0000:00:04.0
  febf1000-febf1fff : virtio-pci
febf2000-febf2fff : 0000:00:05.0
  febf2000-febf2fff : virtio-pci
fec00000-fec003ff : IOAPIC 0
fed00000-fed003ff : HPET 0
  fed00000-fed003ff : PNP0103:00
fee00000-fee00fff : Local APIC
feffc000-feffffff : reserved
fffc0000-ffffffff : reserved
100000000-21fffffff : System RAM

[7.5.] PCI information ('lspci -vvv' as root) 
00:00.0 Host bridge: Intel Corporation 440FX - 82441FX PMC [Natoma] (rev 02)
	Subsystem: Red Hat, Inc Qemu virtual machine
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:01.0 ISA bridge: Intel Corporation 82371SB PIIX3 ISA [Natoma/Triton II]
	Subsystem: Red Hat, Inc Qemu virtual machine
	Physical Slot: 1
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:01.1 IDE interface: Intel Corporation 82371SB PIIX3 IDE [Natoma/Triton II] (prog-if 80 [Master])
	Subsystem: Red Hat, Inc Qemu virtual machine
	Physical Slot: 1
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)
	Region 4: I/O ports at c0a0 [size=16]
	Kernel driver in use: ata_piix

00:01.2 USB controller: Intel Corporation 82371SB PIIX3 USB [Natoma/Triton II] (rev 01) (prog-if 00 [UHCI])
	Subsystem: Red Hat, Inc QEMU Virtual Machine
	Physical Slot: 1
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 11
	Region 4: I/O ports at c040 [size=32]
	Kernel driver in use: uhci_hcd

00:01.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 03)
	Subsystem: Red Hat, Inc Qemu virtual machine
	Physical Slot: 1
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 9
	Kernel driver in use: piix4_smbus

00:02.0 VGA compatible controller: Cirrus Logic GD 5446 (prog-if 00 [VGA controller])
	Subsystem: Red Hat, Inc QEMU Virtual Machine
	Physical Slot: 2
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Region 0: Memory at fc000000 (32-bit, prefetchable) [size=32M]
	Region 1: Memory at febf0000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at febe0000 [disabled] [size=64K]
	Kernel driver in use: cirrus

00:03.0 RAM memory: Red Hat, Inc Virtio memory balloon
	Subsystem: Red Hat, Inc Device 0005
	Physical Slot: 3
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at c060 [size=32]
	Kernel driver in use: virtio-pci

00:04.0 Ethernet controller: Red Hat, Inc Virtio network device
	Subsystem: Red Hat, Inc Device 0001
	Physical Slot: 4
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: I/O ports at c080 [size=32]
	Region 1: Memory at febf1000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] MSI-X: Enable+ Count=3 Masked-
		Vector table: BAR=1 offset=00000000
		PBA: BAR=1 offset=00000800
	Kernel driver in use: virtio-pci

00:05.0 SCSI storage controller: Red Hat, Inc Virtio block device
	Subsystem: Red Hat, Inc Device 0002
	Physical Slot: 5
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at c000 [size=64]
	Region 1: Memory at febf2000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] MSI-X: Enable+ Count=2 Masked-
		Vector table: BAR=1 offset=00000000
		PBA: BAR=1 offset=00000800
	Kernel driver in use: virtio-pci

[7.6.] SCSI information (from /proc/scsi/scsi)
Attached devices:
Host: scsi1 Channel: 00 Id: 00 Lun: 00
  Vendor: QEMU     Model: QEMU DVD-ROM     Rev: 1.0 
  Type:   CD-ROM                           ANSI  SCSI revision: 05

[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
1/      15/     15760/  24886/  44/    66/    897/         kpagecount
10/     1511/   15799/  24890/  45/    67/    9/           kpageflags
102/    1532/   17/     25/     46/    68/    90/          loadavg
103/    15729/  1732/   25300/  47/    69/    902/         locks
104/    15730/  1797/   25307/  48/    7/     930/         mdstat
105/    15731/  1798/   25405/  49/    70/    972/         meminfo
106/    15732/  1799/   26/     5/     708/   984/         misc
107/    15733/  18/     26208/  50/    71/    986/         modules
108/    15734/  1800/   26265/  51/    72/    994/         mounts@
1088/   15735/  1801/   26499/  517/   73/    acpi/        mtrr
1090/   15736/  1802/   26500/  52/    74/    buddyinfo    net@
1097/   15737/  1803/   26578/  53/    7447/  bus/         pagetypeinfo
11/     15738/  1804/   27/     538/   7448/  cgroups      partitions
110/    15739/  1805/   28/     54/    7451/  cmdline      sched_debug
11579/  15740/  1806/   29/     541/   75/    consoles     schedstat
11684/  15741/  1835/   3/      5498/  76/    cpuinfo      scsi/
12/     15742/  19/     30/     55/    77/    crypto       self@
1246/   15743/  190/    31/     5501/  78/    devices      slabinfo
1281/   15744/  191/    32/     5502/  79/    diskstats    softirqs
129/    15745/  197/    33/     5513/  798/   dma          stat
13/     15746/  2/      339/    5524/  799/   driver/      swaps
130/    15747/  20/     34/     5525/  8/     execdomains  sys/
1362/   15748/  2044/   344/    5543/  80/    fb           sysrq-trigger
1397/   15749/  20996/  35/     56/    81/    filesystems  sysvipc/
14/     15750/  21/     36/     57/    82/    fs/          thread-self@
1409/   15751/  22/     37/     579/   83/    interrupts   timer_list
1427/   15752/  23/     38/     58/    84/    iomem        timer_stats
1430/   15753/  23294/  39/     59/    85/    ioports      tty/
1431/   15754/  23305/  4/      60/    876/   irq/         uptime
1432/   15755/  23306/  40/     61/    88/    kallsyms     version
1433/   15756/  23650/  41/     62/    880/   kcore        vmallocinfo
1436/   15757/  23661/  417/    63/    89/    keys         vmstat
1437/   15758/  23662/  42/     64/    894/   key-users    zoneinfo
1488/   15759/  24/     43/     65/    895/   kmsg

[X.] Other notes, patches, fixes, workarounds: 
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1358226

-- 
andrew bezella <abezella@archive.org>
Internet Archive
