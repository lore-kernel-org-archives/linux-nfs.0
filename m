From: =?ISO-8859-1?Q?Rasmus_B=F8g_Hansen?= <rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org>
Subject: PROBLEM: nfsd crashes in 2.6.29
Date: Tue, 31 Mar 2009 15:21:12 +0200
Message-ID: <49D218C8.2040503@msconsult.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020205030805030201080402"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from port254.ds1-he.adsl.cybercity.dk ([217.157.198.197]:42288 "EHLO
	gere.msconsult.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759069AbZCaNlN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 09:41:13 -0400
Received: from sif.msconsult.dk ([10.0.0.60] ident=moffe)
	by gere.msconsult.dk with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org>)
	id 1Lodty-000192-3t
	for linux-nfs@vger.kernel.org; Tue, 31 Mar 2009 15:21:14 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020205030805030201080402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Dear NFS maintainers

I upgraded to 2.6.29 and after some time nfsd crashed.  It had been 
running for about 4 hours without trouble with just one NFS client (it 
never has more).

The server had much disk activity under the crash but little NFS-related 
activity. It is running Debian Lenny and is otherwise extremly stable. 
It is currently running 2.6.28.8 (which is what I tried to upgrade from).

moffe@gere:~/software/kernel/linux-2.6.29# sh scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux gere 2.6.28.8 #1 SMP Tue Mar 17 07:53:42 CET 2009 i686 GNU/Linux
 
Gnu C                  4.3.2
Gnu make               3.81
binutils               2.18.0.20080103
util-linux             2.13.1.1
mount                  2.13.1.1
module-init-tools      found
Linux C Library        2.7
Dynamic linker (ldd)   2.7
Procps                 3.2.7
Kbd                    [tilvalg...]
Console-tools          0.2.3
Sh-utils               6.10
Modules Loaded         parport_pc lp parport autofs4 microcode nfsd 
exportfs nfs lockd nfs_acl sunrpc fuse lm85 hwmon_vid hwmon i2c_i801 
i2c_core ipv6

The 2.6.28.8 and 2.6.29 are slightly differently configured - 2.6.29 has 
support for the EDAC controller in kernel (CONFIG_EDAC_I82875P=y - 
absent in 2.6.28.8) and i2c_i801, lm85, hwmon, hwmon_vid, i2c_core and 
ipv6 in kernel (rather than as modules).

The CPU is a pentium 4 with hyperthreading:

root@gere:~# cat /proc/cpuinfo
processor    : 0
vendor_id    : GenuineIntel
cpu family    : 15
model        : 3
model name    : Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping    : 3
cpu MHz        : 2792.992
cache size    : 1024 KB
physical id    : 0
siblings    : 2
core id        : 0
cpu cores    : 1
apicid        : 0
initial apicid    : 0
fdiv_bug    : no
hlt_bug        : no
f00f_bug    : no
coma_bug    : no
fpu        : yes
fpu_exception    : yes
cpuid level    : 5
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe 
constant_tsc pebs bts pni dtes64 monitor ds_cpl cid
bogomips    : 5585.98
clflush size    : 64
power management:

processor    : 1
vendor_id    : GenuineIntel
cpu family    : 15
model        : 3
model name    : Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping    : 3
cpu MHz        : 2792.992
cache size    : 1024 KB
physical id    : 0
siblings    : 2
core id        : 0
cpu cores    : 1
apicid        : 1
initial apicid    : 1
fdiv_bug    : no
hlt_bug        : no
f00f_bug    : no
coma_bug    : no
fpu        : yes
fpu_exception    : yes
cpuid level    : 5
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe 
constant_tsc pebs bts pni dtes64 monitor ds_cpl cid
bogomips    : 5586.09
clflush size    : 64
power management:

which means the the system runs SMP.

root@gere:~# lspci -vvv
00:00.0 Host bridge: Intel Corporation 82875P/E7210 Memory Controller 
Hub (rev 02)
    Subsystem: Intel Corporation 82875P/E7210 Memory Controller Hub
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ >SERR- <PERR- INTx-
    Latency: 0
    Region 0: Memory at f8000000 (32-bit, prefetchable) [size=64M]
    Capabilities: [e4] Vendor Specific Information <?>
    Capabilities: [a0] AGP version 3.0
        Status: RQ=32 Iso- ArqSz=2 Cal=0 SBA+ ITACoh- GART64- HTrans- 
64bit- FW+ AGP3- Rate=x1,x2,x4
        Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=<none>
    Kernel driver in use: i82875p_edac
    Kernel modules: intel-agp

00:01.0 PCI bridge: Intel Corporation 82875P Processor to AGP Controller 
(rev 02) (prog-if 00 [Normal decode])
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32
    Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: fff00000-000fffff
    Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:03.0 PCI bridge: Intel Corporation 82875P/E7210 Processor to PCI to 
CSA Bridge (rev 02) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32
    Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
    I/O behind bridge: 00009000-00009fff
    Memory behind bridge: fc800000-fc8fffff
    Prefetchable memory behind bridge: fff00000-000fffff
    Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:06.0 System peripheral: Intel Corporation 82875P/E7210 Processor to 
I/O Memory Interface (rev 02)
    Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Region 0: Memory at 30101000 (32-bit, non-prefetchable) [size=4K]

00:1d.0 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB 
UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 5
    Region 4: I/O ports at cc00 [size=32]
    Kernel modules: uhci-hcd

00:1d.1 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB 
UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin B routed to IRQ 9
    Region 4: I/O ports at d000 [size=32]
    Kernel modules: uhci-hcd

00:1d.2 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB 
UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin C routed to IRQ 10
    Region 4: I/O ports at d400 [size=32]
    Kernel modules: uhci-hcd

00:1d.3 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB 
UHCI Controller #4 (rev 02) (prog-if 00 [UHCI])
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 5
    Region 4: I/O ports at d800 [size=32]
    Kernel modules: uhci-hcd

00:1d.7 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB2 
EHCI Controller (rev 02) (prog-if 20 [EHCI])
    Subsystem: Intel Corporation Device 3428
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin D routed to IRQ 9
    Region 0: Memory at febffc00 (32-bit, non-prefetchable) [size=1K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [58] Debug port: BAR=1 offset=00a0
    Kernel modules: ehci-hcd

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev c2) (prog-if 
00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Bus: primary=00, secondary=03, subordinate=03, sec-latency=32
    I/O behind bridge: 0000a000-0000bfff
    Memory behind bridge: fc900000-feafffff
    Prefetchable memory behind bridge: 30000000-300fffff
    Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr+ DiscTmrStat- DiscTmrSERREn-

00:1f.0 ISA bridge: Intel Corporation 82801EB/ER (ICH5/ICH5R) LPC 
Interface Bridge (rev 02)
    Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0

00:1f.1 IDE interface: Intel Corporation 82801EB/ER (ICH5/ICH5R) IDE 
Controller (rev 02) (prog-if 8a [Master SecP PriP])
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 18
    Region 0: I/O ports at 01f0 [size=8]
    Region 1: I/O ports at 03f4 [size=1]
    Region 2: I/O ports at 0170 [size=8]
    Region 3: I/O ports at 0374 [size=1]
    Region 4: I/O ports at ffa0 [size=16]
    Region 5: Memory at 30100000 (32-bit, non-prefetchable) [size=1K]
    Kernel driver in use: ata_piix

00:1f.2 IDE interface: Intel Corporation 82801EB (ICH5) SATA Controller 
(rev 02) (prog-if 8f [Master SecP SecO PriP PriO])
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 18
    Region 0: I/O ports at ec00 [size=8]
    Region 1: I/O ports at e800 [size=4]
    Region 2: I/O ports at e400 [size=8]
    Region 3: I/O ports at e000 [size=4]
    Region 4: I/O ports at dc00 [size=16]
    Kernel driver in use: ata_piix

00:1f.3 SMBus: Intel Corporation 82801EB/ER (ICH5/ICH5R) SMBus 
Controller (rev 02)
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Interrupt: pin B routed to IRQ 17
    Region 4: I/O ports at c800 [size=32]
    Kernel driver in use: i801_smbus
    Kernel modules: i2c-i801

02:01.0 Ethernet controller: Intel Corporation 82547EI Gigabit Ethernet 
Controller
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx+
    Latency: 0 (63750ns min), Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 18
    Region 0: Memory at fc8e0000 (32-bit, non-prefetchable) [size=128K]
    Region 2: I/O ports at 9c00 [size=32]
    Capabilities: [dc] Power Management version 2
        Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Kernel driver in use: e1000

03:01.0 RAID bus controller: Silicon Image, Inc. Adaptec AAR-1210SA SATA 
HostRAID Controller (rev 02) (prog-if 01)
    Subsystem: Adaptec Device 0240
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 22
    Region 0: I/O ports at bc00 [size=8]
    Region 1: I/O ports at b400 [size=4]
    Region 2: I/O ports at b000 [size=8]
    Region 3: I/O ports at ac00 [size=4]
    Region 4: I/O ports at a800 [size=16]
    Region 5: Memory at feafec00 (32-bit, non-prefetchable) [size=512]
    Expansion ROM at 30000000 [disabled] [size=512K]
    Capabilities: [60] Power Management version 2
        Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME-
    Kernel driver in use: sata_sil

03:06.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) 
(prog-if 00 [VGA controller])
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping+ SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32 (2000ns min), Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 11
    Region 0: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
    Region 1: I/O ports at b800 [size=256]
    Region 2: Memory at feaff000 (32-bit, non-prefetchable) [size=4K]
    Expansion ROM at 30080000 [disabled] [size=128K]
    Capabilities: [5c] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-

03:08.0 Ethernet controller: Intel Corporation 82562EZ 10/100 Ethernet 
Controller (rev 01)
    Subsystem: Intel Corporation Device 3428
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 32 (2000ns min, 14000ns max), Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 11
    Region 0: Memory at feafd000 (32-bit, non-prefetchable) [size=4K]
    Region 1: I/O ports at a400 [size=64]
    Capabilities: [dc] Power Management version 2
        Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME-
    Kernel modules: e100

As dmesg indicates, the kernel has selinux enabled though it is unused.

I am unsure how and where to debug but I'd sure like to help anything I can.



Regards
/Rasmus

-- 
Rasmus Bøg Hansen
MSC Aps
Bøgesvinget 8
2740 Skovlunde
44 53 93 66


--------------020205030805030201080402
Content-Type: text/plain;
 name="config-2.6.29"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="config-2.6.29"

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.29
# Tue Mar 31 09:18:15 2009
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
# CONFIG_X86_64 is not set
CONFIG_X86=y
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
# CONFIG_GENERIC_TIME_VSYSCALL is not set
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
# CONFIG_HAVE_CPUMASK_OF_CPU_MAP is not set
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
# CONFIG_ZONE_DMA32 is not set
CONFIG_ARCH_POPULATES_NODE_MAP=y
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_X86_SMP=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_X86_TRAMPOLINE=y
CONFIG_KTIME_SCALAR=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_TREE=y

#
# RCU Subsystem
#
CONFIG_CLASSIC_RCU=y
# CONFIG_TREE_RCU is not set
# CONFIG_PREEMPT_RCU is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_PREEMPT_RCU_TRACE is not set
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=15
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_GROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUPS is not set
# CONFIG_SYSFS_DEPRECATED_V2 is not set
CONFIG_RELAY=y
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
# CONFIG_NET_NS is not set
# CONFIG_BLK_DEV_INITRD is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EMBEDDED is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
# CONFIG_MARKERS is not set
CONFIG_HAVE_OPROFILE=y
# CONFIG_KPROBES is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_LBD is not set
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_BLK_DEV_BSG is not set
# CONFIG_BLK_DEV_INTEGRITY is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=m
CONFIG_IOSCHED_CFQ=m
CONFIG_DEFAULT_AS=y
# CONFIG_DEFAULT_DEADLINE is not set
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="anticipatory"
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
# CONFIG_SPARSE_IRQ is not set
CONFIG_X86_FIND_SMP_CONFIG=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_PC=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_VSMP is not set
# CONFIG_X86_RDC321X is not set
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
# CONFIG_MEMTEST is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
CONFIG_MPENTIUM4=y
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_GENERIC_CPU is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_CPU=y
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=7
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR_32=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_X86_DS=y
CONFIG_X86_PTRACE_BTS=y
# CONFIG_HPET_TIMER is not set
CONFIG_DMI=y
# CONFIG_IOMMU_HELPER is not set
# CONFIG_IOMMU_API is not set
CONFIG_NR_CPUS=32
CONFIG_SCHED_SMT=y
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_NONFATAL=y
CONFIG_X86_MCE_P4THERMAL=y
CONFIG_VM86=y
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_DISCONTIGMEM_MANUAL is not set
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_UNEVICTABLE_LRU=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
# CONFIG_X86_RESERVE_LOW_64K is not set
# CONFIG_MATH_EMULATION is not set
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_PHYSICAL_START=0x100000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x100000
# CONFIG_HOTPLUG_CPU is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set

#
# Power management and ACPI options
#
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_FAN=m
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_THERMAL=m
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=m
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
# CONFIG_CPU_FREQ_DEBUG is not set
CONFIG_CPU_FREQ_STAT=m
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=m
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# CPUFreq processor drivers
#
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_POWERNOW_K6 is not set
# CONFIG_X86_POWERNOW_K7 is not set
# CONFIG_X86_POWERNOW_K8 is not set
# CONFIG_X86_GX_SUSPMOD is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_SPEEDSTEP_ICH is not set
# CONFIG_X86_SPEEDSTEP_SMI is not set
CONFIG_X86_P4_CLOCKMOD=m
# CONFIG_X86_CPUFREQ_NFORCE2 is not set
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_LEGACY is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_MCA is not set
# CONFIG_SCx200 is not set
# CONFIG_OLPC is not set
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=m
CONFIG_BINFMT_MISC=m
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_COMPAT_NET_DEV_OPS=y
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=m
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=m
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=m
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_AF_RXRPC=m
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=m
# CONFIG_PHONET is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=m
# CONFIG_MTD is not set
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=m
# CONFIG_PARIDE is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_CRYPTOLOOP=m
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
CONFIG_MISC_DEVICES=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_93CX6 is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=m
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=m
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_DH is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=y
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
CONFIG_SATA_SIL=y
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ACPI is not set
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5535 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
CONFIG_PATA_MPIIX=y
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_SCH is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
CONFIG_MD_RAID1=y
# CONFIG_MD_RAID10 is not set
CONFIG_MD_RAID456=m
# CONFIG_MD_RAID5_RESHAPE is not set
# CONFIG_MD_MULTIPATH is not set
CONFIG_MD_FAULTY=m
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
# CONFIG_DM_MIRROR is not set
# CONFIG_DM_ZERO is not set
# CONFIG_DM_MULTIPATH is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#

#
# Enable only one of the two stacks, unless you know what you are doing
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
CONFIG_PHYLIB=m

#
# MII PHY device drivers
#
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
CONFIG_LXT_PHY=m
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
# CONFIG_BROADCOM_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MDIO_BITBANG is not set
CONFIG_NET_ETHERNET=y
CONFIG_MII=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_DNET is not set
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_B44 is not set
# CONFIG_FORCEDETH is not set
CONFIG_E100=m
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R6040 is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_TLAN is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_SC92031 is not set
# CONFIG_NET_POCKET is not set
# CONFIG_ATL2 is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IP1000 is not set
# CONFIG_IGB is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_JME is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set
# CONFIG_IWLWIFI_LEDS is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
# CONFIG_DEVKMEM is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=m
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=m
CONFIG_SERIAL_8250_PNP=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=m
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
# CONFIG_PPDEV is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_GEODE is not set
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_NVRAM=m
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_NSC_GPIO is not set
# CONFIG_CS5535_GPIO is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=m
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_SIMTEC is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Graphics adapter I2C/DDC channel drivers
#
# CONFIG_I2C_VOODOO3 is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_STUB is not set
# CONFIG_SCx200_ACB is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_DS1682 is not set
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_PCF8575 is not set
# CONFIG_SENSORS_PCA9539 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set
# CONFIG_SPI is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7473 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_HWMON_DEBUG_CHIP is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_REGULATOR is not set

#
# Multimedia devices
#

#
# Multimedia core support
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_DVB_CORE is not set
# CONFIG_VIDEO_MEDIA is not set

#
# Multimedia drivers
#
# CONFIG_DAB is not set

#
# Graphics support
#
CONFIG_AGP=m
# CONFIG_AGP_ALI is not set
# CONFIG_AGP_ATI is not set
# CONFIG_AGP_AMD is not set
# CONFIG_AGP_AMD64 is not set
CONFIG_AGP_INTEL=m
# CONFIG_AGP_NVIDIA is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_SWORKS is not set
# CONFIG_AGP_VIA is not set
# CONFIG_AGP_EFFICEON is not set
CONFIG_DRM=m
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
# CONFIG_DRM_I810 is not set
# CONFIG_DRM_I830 is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=m
# CONFIG_HID_DEBUG is not set
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=m
# CONFIG_HID_PID is not set
CONFIG_USB_HIDDEV=y

#
# Special HID drivers
#
# CONFIG_HID_COMPAT is not set
CONFIG_HID_A4TECH=m
CONFIG_HID_APPLE=m
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
CONFIG_HID_CYPRESS=m
CONFIG_HID_EZKEY=m
CONFIG_HID_GYRATION=m
CONFIG_HID_LOGITECH=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
CONFIG_HID_NTRIG=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
CONFIG_HID_SUNPLUS=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_TOPSEED=m
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_ZEROPLUS_FF is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=m
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_EHCI_HCD=m
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=m
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# Enable Host or Gadget support to see Inventra options
#

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=m
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may also be needed;
#

#
# see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
CONFIG_USB_STORAGE_ONETOUCH=y
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_VST is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_UWB is not set
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_BOUNCE=y
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=m
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_AMD76X is not set
# CONFIG_EDAC_E7XXX is not set
# CONFIG_EDAC_E752X is not set
CONFIG_EDAC_I82875P=y
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I82860 is not set
# CONFIG_EDAC_R82600 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
CONFIG_RTC_LIB=m
CONFIG_RTC_CLASS=m

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=m
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y

#
# DMA Devices
#
CONFIG_INTEL_IOATDMA=m
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=m
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV=m
CONFIG_UIO_PDRV_GENIRQ=m
# CONFIG_UIO_SMX is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=m
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
# CONFIG_EXT4DEV_COMPAT is not set
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
# CONFIG_XFS_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_DNOTIFY=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=m

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
CONFIG_ROMFS_FS=m
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
# CONFIG_NFS_V4 is not set
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
# CONFIG_NFSD_V4 is not set
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
# CONFIG_SUNRPC_REGISTER_V4 is not set
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_RPCSEC_GSS_SPKM3=m
CONFIG_SMB_FS=m
CONFIG_SMB_NLS_DEFAULT=y
CONFIG_SMB_NLS_REMOTE="cp865"
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=m
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=m
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=m
CONFIG_NLS_ISO8859_1=m
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=m
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=m
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_KERNEL is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
# CONFIG_FRAME_POINTER is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_LATENCYTOP is not set
CONFIG_SYSCTL_SYSCALL_CHECK=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_HW_BRANCH_TRACER=y

#
# Tracers
#
# CONFIG_SYSPROF_TRACER is not set
# CONFIG_HW_BRANCH_TRACER is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DYNAMIC_PRINTK_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_4KSTACKS=y
CONFIG_DOUBLEFAULT=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY=y
# CONFIG_SECURITYFS is not set
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
# CONFIG_SECURITY_PATH is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR=0
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_FIPS=y
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=m
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_CRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_SEQIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=m
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=m

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=m
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=m
CONFIG_CRYPTO_AES_586=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_586=m
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_586=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRYPTO_LZO=m

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
# CONFIG_CRYPTO_HW is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_FIND_LAST_BIT=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=m
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=m
CONFIG_AUDIT_GENERIC=y
CONFIG_ZLIB_INFLATE=m
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_COMPRESS=m
CONFIG_LZO_DECOMPRESS=m
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y

--------------020205030805030201080402
Content-Type: text/plain;
 name="dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg.txt"

Linux version 2.6.29 (root@gere) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #2 SMP Tue Mar 31 09:21:43 CEST 2009
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  NSC Geode by NSC
  Cyrix CyrixInstead
  Centaur CentaurHauls
  Transmeta GenuineTMx86
  Transmeta TransmetaCPU
  UMC UMC UMC UMC
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fe30000 (usable)
 BIOS-e820: 000000001fe30000 - 000000001fe414a0 (ACPI NVS)
 BIOS-e820: 000000001fe414a0 - 000000001ff30000 (usable)
 BIOS-e820: 000000001ff30000 - 000000001ff40000 (ACPI data)
 BIOS-e820: 000000001ff40000 - 000000001fff0000 (ACPI NVS)
 BIOS-e820: 000000001fff0000 - 0000000020000000 (reserved)
 BIOS-e820: 00000000fecf0000 - 00000000fecf1000 (reserved)
 BIOS-e820: 00000000fed20000 - 00000000feda0000 (reserved)
DMI 2.3 present.
last_pfn = 0x1ff30 max_arch_pfn = 0x1000000
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
kernel direct mapping tables up to 1ff30000 @ 7000-d000
ACPI: RSDP 000F61A0, 0014 (r0 ACPIAM)
ACPI: RSDT 1FF30000, 0030 (r1 INTEL  S875PWP3 20040429 MSFT       97)
ACPI: FACP 1FF30200, 0081 (r2 INTEL  S875PWP3 20040429 MSFT       97)
FADT: X_PM1a_EVT_BLK.bit_width (16) does not match PM1_EVT_LEN (4)
ACPI: DSDT 1FF30370, 424E (r1 INTEL  S875PWP3        1 MSFT  100000D)
ACPI: FACS 1FF40000, 0040
ACPI: APIC 1FF30300, 0068 (r1 INTEL  S875PWP3 20040429 MSFT       97)
ACPI: WDDT 1FF345C0, 0040 (r1 INTEL  OEMWDDT         1 MSFT  100000D)
ACPI: Local APIC address 0xfee00000
511MB LOWMEM available.
  mapped low ram: 0 - 1ff30000
  low ram: 00000000 - 1ff30000
  bootmap 00002000 - 00005fe8
(8 early reservations) ==> bootmem [0000000000 - 001ff30000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
  #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
  #3 [0000100000 - 0000577098]    TEXT DATA BSS ==> [0000100000 - 0000577098]
  #4 [0000578000 - 000057f000]    INIT_PG_TABLE ==> [0000578000 - 000057f000]
  #5 [000009dc00 - 0000100000]    BIOS reserved ==> [000009dc00 - 0000100000]
  #6 [0000007000 - 0000008000]          PGTABLE ==> [0000007000 - 0000008000]
  #7 [0000002000 - 0000006000]          BOOTMAP ==> [0000002000 - 0000006000]
found SMP MP-table at [c00ff780] 000ff780
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x0001ff30
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0001fe30
    0: 0x0001fe42 -> 0x0001ff30
On node 0 totalpages: 130749
free_area_init_node: node 0, pgdat c0485f00, node_mem_map c1000000
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3967 pages, LIFO batch:0
  Normal zone: 991 pages used for memmap
  Normal zone: 125759 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Using ACPI (MADT) for SMP configuration information
SMP: Allowing 2 CPUs, 0 hotplug CPUs
nr_irqs_gsi: 24
Allocating PCI resources starting at 30000000 (gap: 20000000:decf0000)
NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_node_ids:1
PERCPU: Allocating 40960 bytes of per cpu data
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129726
Kernel command line: root=/dev/md0 ro 
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c0530000 soft=c0510000
PID hash table entries: 2048 (order: 11, 8192 bytes)
Fast TSC calibration using PIT
Detected 2793.205 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 513512k/523456k available (2662k kernel code, 9212k reserved, 1162k data, 300k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xffe19000 - 0xfffff000   (1944 kB)
    vmalloc : 0xe0730000 - 0xffe17000   ( 502 MB)
    lowmem  : 0xc0000000 - 0xdff30000   ( 511 MB)
      .init : 0xc04c2000 - 0xc050d000   ( 300 kB)
      .data : 0xc039998d - 0xc04bc3a0   (1162 kB)
      .text : 0xc0100000 - 0xc039998d   (2662 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
SLUB: Genslabs=12, HWalign=128, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
Calibrating delay loop (skipped), value calculated using timer frequency.. 5586.41 BogoMIPS (lpj=27932050)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Mount-cache hash table entries: 512
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
CPU0: Thermal monitoring enabled
using mwait in idle threads.
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 15k freed
ACPI: Core revision 20081204
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Pentium(R) 4 CPU 2.80GHz stepping 03
CPU 1 irqstacks, hard=c0531000 soft=c0511000
Booting processor 1 APIC 0x1 ip 0x6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5586.12 BogoMIPS (lpj=27930621)
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel P4/Xeon Extended MCE MSRs (12) available
CPU1: Thermal monitoring enabled
x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
CPU1: Intel(R) Pentium(R) 4 CPU 2.80GHz stepping 03
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
Total of 2 processors activated (11172.53 BogoMIPS).
net_namespace: 728 bytes
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xf0031, last bus=3
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:00.0: reg 10 32bit mmio: [0xf8000000-0xfbffffff]
pci 0000:00:1d.0: reg 20 io port: [0xcc00-0xcc1f]
pci 0000:00:1d.1: reg 20 io port: [0xd000-0xd01f]
pci 0000:00:1d.2: reg 20 io port: [0xd400-0xd41f]
pci 0000:00:1d.3: reg 20 io port: [0xd800-0xd81f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xfebffc00-0xfebfffff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH4 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH4 GPIO
pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
pci 0000:00:1f.1: reg 20 io port: [0xffa0-0xffaf]
pci 0000:00:1f.1: reg 24 32bit mmio: [0x000000-0x0003ff]
pci 0000:00:1f.2: reg 10 io port: [0xec00-0xec07]
pci 0000:00:1f.2: reg 14 io port: [0xe800-0xe803]
pci 0000:00:1f.2: reg 18 io port: [0xe400-0xe407]
pci 0000:00:1f.2: reg 1c io port: [0xe000-0xe003]
pci 0000:00:1f.2: reg 20 io port: [0xdc00-0xdc0f]
pci 0000:00:1f.3: reg 20 io port: [0xc800-0xc81f]
pci 0000:02:01.0: reg 10 32bit mmio: [0xfc8e0000-0xfc8fffff]
pci 0000:02:01.0: reg 18 io port: [0x9c00-0x9c1f]
pci 0000:02:01.0: PME# supported from D0 D3hot D3cold
pci 0000:02:01.0: PME# disabled
pci 0000:00:03.0: bridge io port: [0x9000-0x9fff]
pci 0000:00:03.0: bridge 32bit mmio: [0xfc800000-0xfc8fffff]
pci 0000:03:01.0: reg 10 io port: [0xbc00-0xbc07]
pci 0000:03:01.0: reg 14 io port: [0xb400-0xb403]
pci 0000:03:01.0: reg 18 io port: [0xb000-0xb007]
pci 0000:03:01.0: reg 1c io port: [0xac00-0xac03]
pci 0000:03:01.0: reg 20 io port: [0xa800-0xa80f]
pci 0000:03:01.0: reg 24 32bit mmio: [0xfeafec00-0xfeafedff]
pci 0000:03:01.0: reg 30 32bit mmio: [0xfea00000-0xfea7ffff]
pci 0000:03:01.0: supports D1 D2
pci 0000:03:06.0: reg 10 32bit mmio: [0xfd000000-0xfdffffff]
pci 0000:03:06.0: reg 14 io port: [0xb800-0xb8ff]
pci 0000:03:06.0: reg 18 32bit mmio: [0xfeaff000-0xfeafffff]
pci 0000:03:06.0: reg 30 32bit mmio: [0xfeac0000-0xfeadffff]
pci 0000:03:06.0: supports D1 D2
pci 0000:03:08.0: reg 10 32bit mmio: [0xfeafd000-0xfeafdfff]
pci 0000:03:08.0: reg 14 io port: [0xa400-0xa43f]
pci 0000:03:08.0: supports D1 D2
pci 0000:03:08.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:03:08.0: PME# disabled
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1e.0: bridge io port: [0xa000-0xbfff]
pci 0000:00:1e.0: bridge 32bit mmio: [0xfc900000-0xfeafffff]
pci_bus 0000:00: on NUMA node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P3._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 *9 10 11 12 14 15)
ACPI: Power Resource [URP1] (off)
ACPI: Power Resource [URP2] (off)
ACPI: Power Resource [FDDP] (off)
ACPI: Power Resource [LPTP] (off)
SCSI subsystem initialized
libata version 3.00 loaded.
PCI: Using ACPI for IRQ routing
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
system 00:0b: ioport range 0x4d0-0x4d1 has been reserved
system 00:0d: ioport range 0x400-0x47f has been reserved
system 00:0d: ioport range 0x680-0x6ff has been reserved
system 00:0d: ioport range 0x500-0x53f has been reserved
system 00:0d: iomem range 0xfec00000-0xfec00fff has been reserved
system 00:0d: iomem range 0xfee00000-0xfee00fff has been reserved
system 00:0d: iomem range 0xfed20000-0xfed9ffff has been reserved
system 00:0e: iomem range 0x0-0x9ffff could not be reserved
system 00:0e: iomem range 0xc0000-0xdffff could not be reserved
system 00:0e: iomem range 0xe0000-0xfffff could not be reserved
system 00:0e: iomem range 0x100000-0x1fffffff could not be reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: disabled
pci 0000:00:01.0:   MEM window: disabled
pci 0000:00:01.0:   PREFETCH window: disabled
pci 0000:00:03.0: PCI bridge, secondary bus 0000:02
pci 0000:00:03.0:   IO window: 0x9000-0x9fff
pci 0000:00:03.0:   MEM window: 0xfc800000-0xfc8fffff
pci 0000:00:03.0:   PREFETCH window: disabled
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:03
pci 0000:00:1e.0:   IO window: 0xa000-0xbfff
pci 0000:00:1e.0:   MEM window: 0xfc900000-0xfeafffff
pci 0000:00:1e.0:   PREFETCH window: 0x00000030000000-0x000000300fffff
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:01: resource 0 mem: [0x0-0x0]
pci_bus 0000:01: resource 1 mem: [0x0-0x0]
pci_bus 0000:01: resource 2 mem: [0x0-0x0]
pci_bus 0000:01: resource 3 mem: [0x0-0x0]
pci_bus 0000:02: resource 0 io:  [0x9000-0x9fff]
pci_bus 0000:02: resource 1 mem: [0xfc800000-0xfc8fffff]
pci_bus 0000:02: resource 2 mem: [0x0-0x0]
pci_bus 0000:02: resource 3 mem: [0x0-0x0]
pci_bus 0000:03: resource 0 io:  [0xa000-0xbfff]
pci_bus 0000:03: resource 1 mem: [0xfc900000-0xfeafffff]
pci_bus 0000:03: resource 2 mem: [0x30000000-0x300fffff]
pci_bus 0000:03: resource 3 io:  [0x00-0xffff]
pci_bus 0000:03: resource 4 mem: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 5, 131072 bytes)
TCP bind hash table entries: 16384 (order: 5, 131072 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
TCP reno registered
NET: Registered protocol family 1
Machine check exception polling timer started.
audit: initializing netlink socket (disabled)
type=2000 audit(1238485013.629:1): initialized
msgmni has been set to 1003
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler anticipatory registered (default)
pci 0000:03:06.0: Boot video device
pci 0000:03:08.0: Firmware left e100 interrupts enabled; disabling
Intel 82802 RNG detected
Intel(R) PRO/1000 Network Driver - version 7.3.21-k3-NAPI
Copyright (c) 1999-2006 Intel Corporation.
e1000 0000:02:01.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
e1000 0000:02:01.0: setting latency timer to 64
e1000: 0000:02:01.0: e1000_probe: (PCI:33MHz:32-bit) 00:0c:f1:e8:33:eb
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 0
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
Driver 'sd' needs updating - please use bus_type methods
ata_piix 0000:00:1f.1: version 2.12
ata_piix 0000:00:1f.1: enabling device (0005 -> 0007)
ata_piix 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ata_piix 0000:00:1f.1: setting latency timer to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
ata1.00: ATA-6: WDC WD1200JB-00DUA3, 75.13B75, max UDMA/100
ata1.00: 234441648 sectors, multi 16: LBA48 
ata1.01: ATA-6: WDC WD1200JB-00DUA3, 75.13B75, max UDMA/100
ata1.01: 234441648 sectors, multi 16: LBA48 
ata1.00: configured for UDMA/100
ata1.01: configured for UDMA/100
scsi 0:0:0:0: Direct-Access     ATA      WDC WD1200JB-00D 75.1 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3 sda4
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 0:0:1:0: Direct-Access     ATA      WDC WD1200JB-00D 75.1 PQ: 0 ANSI: 5
sd 0:0:1:0: [sdb] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
sd 0:0:1:0: [sdb] Write Protect is off
sd 0:0:1:0: [sdb] Mode Sense: 00 3a 00 00
sd 0:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:1:0: [sdb] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
sd 0:0:1:0: [sdb] Write Protect is off
sd 0:0:1:0: [sdb] Mode Sense: 00 3a 00 00
sd 0:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2 sdb3 sdb4
sd 0:0:1:0: [sdb] Attached SCSI disk
ata2.00: ATA-6: WDC WD1200JB-00DUA3, 75.13B75, max UDMA/100
ata2.00: 234441648 sectors, multi 16: LBA48 
ata2.01: ATAPI: GCR-8523B, 1.02, max MWDMA2
ata2.00: configured for UDMA/100
ata2.01: configured for MWDMA2
scsi 1:0:0:0: Direct-Access     ATA      WDC WD1200JB-00D 75.1 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdc] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
sd 1:0:0:0: [sdc] Write Protect is off
sd 1:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdc] 234441648 512-byte hardware sectors: (120 GB/111 GiB)
sd 1:0:0:0: [sdc] Write Protect is off
sd 1:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdc: sdc1 sdc2 sdc3 sdc4
sd 1:0:0:0: [sdc] Attached SCSI disk
scsi 1:0:1:0: CD-ROM            HL-DT-ST CD-ROM GCR-8523B 1.02 PQ: 0 ANSI: 5
ata_piix 0000:00:1f.2: PCI INT A -> GSI 18 (level, low) -> IRQ 18
ata_piix 0000:00:1f.2: MAP [ P0 -- P1 -- ]
ata_piix 0000:00:1f.2: setting latency timer to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0xec00 ctl 0xe800 bmdma 0xdc00 irq 18
ata4: SATA max UDMA/133 cmd 0xe400 ctl 0xe000 bmdma 0xdc08 irq 18
ata3.00: ATA-7: ST3250823AS, 3.03, max UDMA/133
ata3.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata3.00: configured for UDMA/133
scsi 2:0:0:0: Direct-Access     ATA      ST3250823AS      3.03 PQ: 0 ANSI: 5
sd 2:0:0:0: [sdd] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
sd 2:0:0:0: [sdd] Write Protect is off
sd 2:0:0:0: [sdd] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 2:0:0:0: [sdd] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
sd 2:0:0:0: [sdd] Write Protect is off
sd 2:0:0:0: [sdd] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdd: sdd1
sd 2:0:0:0: [sdd] Attached SCSI disk
ata4.00: ATA-7: ST3250823AS, 3.03, max UDMA/133
ata4.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata4.00: configured for UDMA/133
scsi 3:0:0:0: Direct-Access     ATA      ST3250823AS      3.03 PQ: 0 ANSI: 5
sd 3:0:0:0: [sde] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
sd 3:0:0:0: [sde] Write Protect is off
sd 3:0:0:0: [sde] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 3:0:0:0: [sde] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
sd 3:0:0:0: [sde] Write Protect is off
sd 3:0:0:0: [sde] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sde: sde1
sd 3:0:0:0: [sde] Attached SCSI disk
sata_sil 0000:03:01.0: version 2.4
sata_sil 0000:03:01.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
scsi4 : sata_sil
scsi5 : sata_sil
ata5: SATA max UDMA/100 mmio m512@0xfeafec00 tf 0xfeafec80 irq 22
ata6: SATA max UDMA/100 mmio m512@0xfeafec00 tf 0xfeafecc0 irq 22
ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 310)
ata5.00: ATA-7: ST3750640AS, 3.AAE, max UDMA/133
ata5.00: 1465149168 sectors, multi 0: LBA48 NCQ (depth 0/32)
ata5.00: configured for UDMA/100
scsi 4:0:0:0: Direct-Access     ATA      ST3750640AS      3.AA PQ: 0 ANSI: 5
sd 4:0:0:0: [sdf] 1465149168 512-byte hardware sectors: (750 GB/698 GiB)
sd 4:0:0:0: [sdf] Write Protect is off
sd 4:0:0:0: [sdf] Mode Sense: 00 3a 00 00
sd 4:0:0:0: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 4:0:0:0: [sdf] 1465149168 512-byte hardware sectors: (750 GB/698 GiB)
sd 4:0:0:0: [sdf] Write Protect is off
sd 4:0:0:0: [sdf] Mode Sense: 00 3a 00 00
sd 4:0:0:0: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdf: sdf1
sd 4:0:0:0: [sdf] Attached SCSI disk
ata6: SATA link down (SStatus 0 SControl 310)
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
i801_smbus 0000:00:1f.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
md: raid1 personality registered for level 1
EDAC MC: Ver: 2.1.0 Mar 31 2009
EDAC i82875p: i82875p init one
pci 0000:00:06.0: reg 10 32bit mmio: [0xfecf0000-0xfecf0fff]
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: disabled
pci 0000:00:01.0:   MEM window: disabled
pci 0000:00:01.0:   PREFETCH window: disabled
pci 0000:00:03.0: PCI bridge, secondary bus 0000:02
pci 0000:00:03.0:   IO window: 0x9000-0x9fff
pci 0000:00:03.0:   MEM window: 0xfc800000-0xfc8fffff
pci 0000:00:03.0:   PREFETCH window: disabled
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:03
pci 0000:00:1e.0:   IO window: 0xa000-0xbfff
pci 0000:00:1e.0:   MEM window: 0xfc900000-0xfeafffff
pci 0000:00:1e.0:   PREFETCH window: 0x00000030000000-0x000000300fffff
EDAC MC0: Giving out device to 'i82875p_edac' 'i82875p': DEV 0000:00:00.0
EDAC PCI0: Giving out device to module 'i82875p_edac' controller 'EDAC PCI controller': DEV '0000:00:00.0' (POLLED)
cpuidle: using governor ladder
cpuidle: using governor menu
TCP cubic registered
NET: Registered protocol family 10
NET: Registered protocol family 17
Using IPI Shortcut mode
md: Waiting for all devices to be available before autodetect
md: If you don't use raid, use raid=noautodetect
md: Autodetecting RAID arrays.
md: Scanned 14 and added 14 devices.
md: autorun ...
md: considering sde1 ...
md:  adding sde1 ...
md:  adding sdd1 ...
md: sdc4 has different UUID to sde1
md: sdc3 has different UUID to sde1
md: sdc2 has different UUID to sde1
md: sdc1 has different UUID to sde1
md: sdb4 has different UUID to sde1
md: sdb3 has different UUID to sde1
md: sdb2 has different UUID to sde1
md: sdb1 has different UUID to sde1
md: sda4 has different UUID to sde1
md: sda3 has different UUID to sde1
md: sda2 has different UUID to sde1
md: sda1 has different UUID to sde1
md: created md3
md: bind<sdd1>
md: bind<sde1>
md: running: <sde1><sdd1>
raid1: raid set md3 active with 2 out of 2 mirrors
md: considering sdc4 ...
md:  adding sdc4 ...
md: sdc3 has different UUID to sdc4
md: sdc2 has different UUID to sdc4
md: sdc1 has different UUID to sdc4
md:  adding sdb4 ...
md: sdb3 has different UUID to sdc4
md: sdb2 has different UUID to sdc4
md: sdb1 has different UUID to sdc4
md:  adding sda4 ...
md: sda3 has different UUID to sdc4
md: sda2 has different UUID to sdc4
md: sda1 has different UUID to sdc4
md: created md2
md: bind<sda4>
md: bind<sdb4>
md: bind<sdc4>
md: running: <sdc4><sdb4><sda4>
raid1: raid set md2 active with 2 out of 2 mirrors
md: considering sdc3 ...
md:  adding sdc3 ...
md: sdc2 has different UUID to sdc3
md: sdc1 has different UUID to sdc3
md:  adding sdb3 ...
md: sdb2 has different UUID to sdc3
md: sdb1 has different UUID to sdc3
md:  adding sda3 ...
md: sda2 has different UUID to sdc3
md: sda1 has different UUID to sdc3
md: created md1
md: bind<sda3>
md: bind<sdb3>
md: bind<sdc3>
md: running: <sdc3><sdb3><sda3>
raid1: raid set md1 active with 2 out of 2 mirrors
md: considering sdc2 ...
md:  adding sdc2 ...
md: sdc1 has different UUID to sdc2
md:  adding sdb2 ...
md: sdb1 has different UUID to sdc2
md:  adding sda2 ...
md: sda1 has different UUID to sdc2
md: created md4
md: bind<sda2>
md: bind<sdb2>
md: bind<sdc2>
md: running: <sdc2><sdb2><sda2>
raid1: raid set md4 active with 2 out of 2 mirrors
md: considering sdc1 ...
md:  adding sdc1 ...
md:  adding sdb1 ...
md:  adding sda1 ...
md: created md0
md: bind<sda1>
md: bind<sdb1>
md: bind<sdc1>
md: running: <sdc1><sdb1><sda1>
raid1: raid set md0 active with 2 out of 2 mirrors
md: ... autorun DONE.
 md0:
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly on device 9:0.
Freeing unused kernel memory: 300k freed
 md4: unknown partition table
Adding 248888k swap on /dev/md4.  Priority:1 extents:1 across:248888k 
EXT3 FS on md0, internal journal
 md1: unknown partition table
 md2: unknown partition table
 md3: unknown partition table
fuse init (API version 7.11)
kjournald starting.  Commit interval 5 seconds
EXT3 FS on md1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on md2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on md3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdf1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
ADDRCONF(NETDEV_UP): eth0: link is not ready
e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
Installing knfsd (copyright (C) 1996 okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org).
platform microcode: firmware: requesting intel-ucode/0f-03-03
platform microcode: firmware: requesting intel-ucode/0f-03-03
Microcode Update Driver: v2.00 <tigran-ppwZ4lME3+KI6QP4U9MhSdBc4/FLrbF6@public.gmane.org>, Peter Oruba
microcode: CPU0 updated from revision 0x9 to 0xc, date = 2005-04-21 
microcode: CPU1 updated from revision 0x9 to 0xc, date = 2005-04-21 
parport_pc 00:0a: reported by Plug and Play ACPI
parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
lp0: using parport0 (interrupt-driven).
warning: `ntpd' uses 32-bit capabilities (legacy support in use)
BUG: unable to handle kernel NULL pointer dereference at 00000004
IP: [<c022f288>] inode_has_perm+0x1f/0x69
*pdpt = 0000000015a0e001 *pde = 0000000000000000 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.3/i2c-adapter/i2c-0/0-002e/temp3_alarm
Modules linked in: parport_pc lp parport autofs4 microcode nfsd exportfs nfs lockd nfs_acl sunrpc fuse

Pid: 2604, comm: nfsd Not tainted (2.6.29 #2)         
EIP: 0060:[<c022f288>] EFLAGS: 00010246 CPU: 0
EIP is at inode_has_perm+0x1f/0x69
EAX: 00000000 EBX: 00000000 ECX: 00000004 EDX: cd45fd30
ESI: df3aa280 EDI: cd45fd30 EBP: df3aa280 ESP: dac6fe24
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process nfsd (pid: 2604, ti=dac6f000 task=df36c6e0 task.ti=dac6f000)
Stack:
 00000020 00000018 00000004 d597dd6c dac59000 c0166888 d597dd00 df3aa2ec
 d597dd6c c0231e95 c046cfa0 00000246 00000042 e08c393a df7e1dd0 c5646480
 00000000 00000004 d59bdf00 cd45fd30 df3aa280 c0231f5a 00000000 00000001
Call Trace:
 [<c0166888>] kmemdup+0x16/0x30
 [<c0231e95>] selinux_cred_prepare+0x10/0x22
 [<e08c393a>] nfsd_permission+0x88/0xf2 [nfsd]
 [<c0231f5a>] selinux_dentry_open+0xb3/0xe5
 [<c022a769>] security_dentry_open+0xc/0xd
 [<c017bf5e>] __dentry_open+0x9f/0x23a
 [<c017c130>] dentry_open+0x37/0x7f
 [<e08c5035>] nfsd_open+0xe6/0x14e [nfsd]
 [<e08c52d4>] nfsd_commit+0x34/0x91 [nfsd]
 [<e07ffee6>] cache_check+0x2b/0x3f6 [sunrpc]
 [<e08cae07>] nfsd3_proc_commit+0x94/0x10f [nfsd]
 [<e07fbc8c>] svcauth_unix_accept+0x1c1/0x273 [sunrpc]
 [<e08c01d3>] nfsd_dispatch+0x97/0x209 [nfsd]
 [<e07f8b04>] svc_process+0x3e8/0x707 [sunrpc]
 [<c01035a7>] common_interrupt+0x27/0x2c
 [<e08c0829>] nfsd+0x16c/0x26a [nfsd]
 [<c011b198>] complete+0x37/0x46
 [<e08c06bd>] nfsd+0x0/0x26a [nfsd]
 [<c0136376>] kthread+0x39/0x62
 [<c013633d>] kthread+0x0/0x62
 [<c010380b>] kernel_thread_helper+0x7/0x1c
Code: 00 e8 f4 e4 ff ff 83 c4 08 5b 5e c3 55 57 56 53 83 ec 44 89 c6 89 4c 24 08 8b 5c 24 58 31 c0 f6 82 39 01 00 00 02 75 29 8b 46 58 <8b> 68 04 8b b2 40 01 00 00 85 db 74 21 0f b7 4e 14 8b 56 10 89 
EIP: [<c022f288>] inode_has_perm+0x1f/0x69 SS:ESP 0068:dac6fe24
---[ end trace 2545eed1715071f5 ]---
BUG: unable to handle kernel NULL pointer dereference at 00000004
IP: [<c022f288>] inode_has_perm+0x1f/0x69
*pdpt = 0000000015a0e001 *pde = 0000000000000000 
Oops: 0000 [#2] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.3/i2c-adapter/i2c-0/0-002e/temp3_alarm
Modules linked in: parport_pc lp parport autofs4 microcode nfsd exportfs nfs lockd nfs_acl sunrpc fuse

Pid: 2605, comm: nfsd Tainted: G      D    (2.6.29 #2)         
EIP: 0060:[<c022f288>] EFLAGS: 00010246 CPU: 0
EIP is at inode_has_perm+0x1f/0x69
EAX: 00000000 EBX: 00000000 ECX: 00000004 EDX: cd45e280
ESI: df3aa100 EDI: cd45e280 EBP: df3aa100 ESP: dac92e24
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process nfsd (pid: 2605, ti=dac92000 task=df36d130 task.ti=dac92000)
Stack:
 00000020 00000018 00000004 d597d66c dac5d000 c0166888 d597d600 df3aa16c
 d597d66c c0231e95 c046cfa0 00000246 00000042 e08c393a df7e16e8 c5646480
 00000000 00000004 d5943f00 cd45e280 df3aa100 c0231f5a 00000000 00000001
Call Trace:
 [<c0166888>] kmemdup+0x16/0x30
 [<c0231e95>] selinux_cred_prepare+0x10/0x22
 [<e08c393a>] nfsd_permission+0x88/0xf2 [nfsd]
 [<c0231f5a>] selinux_dentry_open+0xb3/0xe5
 [<c022a769>] security_dentry_open+0xc/0xd
 [<c017bf5e>] __dentry_open+0x9f/0x23a
 [<c017c130>] dentry_open+0x37/0x7f
 [<e08c5035>] nfsd_open+0xe6/0x14e [nfsd]
 [<e08c52d4>] nfsd_commit+0x34/0x91 [nfsd]
 [<e07ffee6>] cache_check+0x2b/0x3f6 [sunrpc]
 [<e08cae07>] nfsd3_proc_commit+0x94/0x10f [nfsd]
 [<e07fbc8c>] svcauth_unix_accept+0x1c1/0x273 [sunrpc]
 [<e08c01d3>] nfsd_dispatch+0x97/0x209 [nfsd]
 [<e07f8b04>] svc_process+0x3e8/0x707 [sunrpc]
 [<c01035a7>] common_interrupt+0x27/0x2c
 [<e08c0829>] nfsd+0x16c/0x26a [nfsd]
 [<c011b198>] complete+0x37/0x46
 [<e08c06bd>] nfsd+0x0/0x26a [nfsd]
 [<c0136376>] kthread+0x39/0x62
 [<c013633d>] kthread+0x0/0x62
 [<c010380b>] kernel_thread_helper+0x7/0x1c
Code: 00 e8 f4 e4 ff ff 83 c4 08 5b 5e c3 55 57 56 53 83 ec 44 89 c6 89 4c 24 08 8b 5c 24 58 31 c0 f6 82 39 01 00 00 02 75 29 8b 46 58 <8b> 68 04 8b b2 40 01 00 00 85 db 74 21 0f b7 4e 14 8b 56 10 89 
EIP: [<c022f288>] inode_has_perm+0x1f/0x69 SS:ESP 0068:dac92e24
---[ end trace 2545eed1715071f6 ]---

--------------020205030805030201080402--
