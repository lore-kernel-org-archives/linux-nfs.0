Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:59498 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965476Ab3DPWnf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Apr 2013 18:43:35 -0400
In-Reply-To: <1366150010.27817.8.camel@leira.trondhjem.org>
References: <OF6F031A84.8897519B-ONC1257B4E.002D1BA3-C1257B4E.002DBED0@LocalDomain>		 <OF83CD52DB.8DBE497B-ONC1257B4E.002F8695-C1257B4E.002FBBD0@LocalDomain>
	 <OF64305930.0F7881A0-ONC1257B4E.0030250F-C1257B4E.00306CEC@LocalDomain>
	 <OFA06D4153.317BAF9A-ONC1257B4F.002F597B-C1257B4F.003AC46C@transmode.se>
	 <1366126613.12556.18.camel@leira.trondhjem.org>	 <OFB2555ACD.CF7424A9-ONC1257B4F.00613A5E-C1257B4F.006908CE@transmode.se> <1366150010.27817.8.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: NFS loop on 3.4.39
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OF9FC4D7D3.ABC463C9-ONC1257B4F.007BD973-C1257B4F.007CD610@transmode.se>
Date: Wed, 17 Apr 2013 00:43:33 +0200
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 2013/04/17 
00:06:51:
> 
> On Tue, 2013-04-16 at 21:07 +0200, Joakim Tjernlund wrote:
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 2013/04/16 
> > 17:36:55:
> > 
> > > From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> > > To: Joakim Tjernlund <joakim.tjernlund@transmode.se>, 
> > > Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> > > Date: 2013/04/16 17:37
> > > Subject: Re: NFS loop on 3.4.39
> > > 
> > > On Tue, 2013-04-16 at 12:41 +0200, Joakim Tjernlund wrote:
> > > > Here we go again, this time i happened while browsing the Boston 
news 
> > on 
> > > > www.dn.se
> > > > Now gvfsd-metadata is turned off(not running at all) and I get:
> > > > 10:28:44.616146 IP 192.168.201.44.nfs > 172.20.4.10.3671768838: 
reply 
> > ok 
> > > > 52 getattr ERROR: unk 10024
> > > 
> > > Part of the reason why you are getting no response to these posts is
> > > that you are posting tcpdump-decoded data. Tcpdump still has no 
support
> > > for NFSv4, and therefore completely garbles the output by trying to
> > > interpret it as NFSv2/v3.
> > > In general, if you are posting network traffic, please record it as
> > > binary raw packet data (using the '-w' option on tcdump) so that we 
can
> > > look at the full contents. Either include it as an attachment, or
> > > provide us with details on how to download it from an http server.
> > > 
> > > Other information that is needed in order to make sense of NFS bug
> > > reports includes:
> > 
> > Thank you Trond, I figured there was something missing but I didn't 
know 
> > where to start but here goes:
> > 
> > > 
> > > - client OS (non-linux) or kernel version (linux)
> > Client OS Linux 3.4.39, x86
> > 
> > > - mount options on the client
> > ~ # ypmatch jocke auto.home
> > -fstype=nfs,soft devsrv:/mnt/home/jocke
> > 
> > > - server OS (non-linux) or kernel version (linux)
> > Server OS Linux 3.4.39, amd64
> > 
> > > - type of exported filesystem on the server
> > XFS
> > 
> > > - contents of /etc/exports on the server
> > more /etc/exports
> > # /etc/exports: NFS file systems being exported.  See exports(5).
> > /mnt/home              *(rw,async,root_squash,no_subtree_check)
> > /mnt/systemtest        *(rw,sync,root_squash,no_subtree_check)
> > /mnt/TNM               *(rw,sync,root_squash,no_subtree_check)
> > /tftproot              *(rw,async,root_squash,no_subtree_check)
> > /mnt/images *(rw,async,no_root_squash,no_subtree_check,insecure)
> > /rescue *(ro,async,no_root_squash,no_subtree_check,insecure)
> > 
> > /mnt/home is the one failing
> > 
> > > 
> > > Please ensure that you always include those in your emails.
> > 
> > nfs.pcap: 
> > http://ftp-us.transmode.se/get/?id=1bf2561ed2e7d4e379b2936319c82c25
> > 
> > nfs2.pcap: 
> > http://ftp-us.transmode.se/get/?id=759c7645248a426720da8e9ba7074040
> > 
> > nfs3.pcap: 
> > http://ftp-us.transmode.se/get/?id=051c6d771978b2407e15e96152bd6e66
> > 
> > nfs4.pcap: 
> > http://ftp-us.transmode.se/get/?id=5dfab4da6cbbe400697bc1621b541c9f
> > 
> > nfs3.pcap is the gvsd-metadata problem one can find using google, 
doesn't 
> > have to be a NFS problem
> > The other 3 all come from surfing the www using firefox 17.0.3
> 
> The nfs2.pcap file and nfs4.pcap seem to show the server returning
> NFS4ERR_OLD_STATEID, which usually means that the client has an
> OPEN/CLOSE/LOCK or LOCKU... in flight and that while the server has
> updated the stateid, the client has not yet received the reply. The
> problem is that I see no sign of the OPEN/CLOSE/LOCK/LOCKU...

That figures, I only can only start tcpdump after the problem has occurred 
as
it is not so easy to trigger.

> 
> The nfs.pcap file is resending a load of LOCK requests that are
> receiving NFS4ERR_BAD_STATEID replies. Normally, I'd expect the recovery
> engine to kick in and try to recover the OPEN.
> 
> So when you do 'ps -efwww', on any of these clients, do you see a
> process with a name containing the server IP address (192.168.201.44)?

When I have the error you mean? Will have to do that the next time.
ATM I don't have any such processes, the only this I have save is:
ps uaxww| grep firefox
jocke     6330  0.2  0.0      0     0 tty1     Zl   Apr15   3:04 [firefox] 
<defunct>
jocke    10655  0.0  6.8 733648 279432 tty1    D    10:25   0:00 firefox
jocke    10691  0.0  6.8 733648 279432 tty1    D    10:26   0:00 firefox

Strangely there are 3 ff processes

> 
> Also, is there anything special in the log when you do 'dmesg -s 90000'?

Don't have the problem ATM but I did save a dmesg form nfs4.pcap run:
 [io  0x0089-0x008b]
pnp 00:05: [io  0x008f]
pnp 00:05: [io  0x00c0-0x00df]
pnp 00:05: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:06: [io  0x0070-0x0071]
pnp 00:06: [irq 8]
pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:07: [io  0x0061]
pnp 00:07: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:08: [io  0x0010-0x001f]
pnp 00:08: [io  0x0022-0x003f]
pnp 00:08: [io  0x0044-0x005f]
pnp 00:08: [io  0x0062-0x0063]
pnp 00:08: [io  0x0065-0x006f]
pnp 00:08: [io  0x0072-0x007f]
pnp 00:08: [io  0x0080]
pnp 00:08: [io  0x0084-0x0086]
pnp 00:08: [io  0x0088]
pnp 00:08: [io  0x008c-0x008e]
pnp 00:08: [io  0x0090-0x009f]
pnp 00:08: [io  0x00a2-0x00bf]
pnp 00:08: [io  0x00e0-0x00ef]
pnp 00:08: [io  0x04d0-0x04d1]
system 00:08: [io  0x04d0-0x04d1] has been reserved
system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: [io  0x00f0-0x00ff]
pnp 00:09: [irq 13]
pnp 00:09: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:0a: [io  0x03f8-0x03ff]
pnp 00:0a: [irq 4]
pnp 00:0a: [dma 0 disabled]
pnp 00:0a: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:0b: [mem 0xfed40000-0xfed44fff]
pnp 00:0b: Plug and Play ACPI device, IDs IFX0102 PNP0c31 (active)
pnp 00:0c: [io  0x0400-0x0453]
pnp 00:0c: [io  0x0458-0x047f]
pnp 00:0c: [io  0x1180-0x119f]
pnp 00:0c: [io  0x0500-0x057f]
pnp 00:0c: [mem 0xfed1c000-0xfed1ffff]
pnp 00:0c: [mem 0xfec00000-0xfecfffff]
pnp 00:0c: [mem 0xfed08000-0xfed08fff]
pnp 00:0c: [mem 0xff000000-0xffffffff]
system 00:0c: [io  0x0400-0x0453] has been reserved
system 00:0c: [io  0x0458-0x047f] has been reserved
system 00:0c: [io  0x1180-0x119f] has been reserved
system 00:0c: [io  0x0500-0x057f] has been reserved
system 00:0c: [mem 0xfed1c000-0xfed1ffff] has been reserved
system 00:0c: [mem 0xfec00000-0xfecfffff] could not be reserved
system 00:0c: [mem 0xfed08000-0xfed08fff] has been reserved
system 00:0c: [mem 0xff000000-0xffffffff] has been reserved
system 00:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp 00:0d: [io  0x0454-0x0457]
system 00:0d: [io  0x0454-0x0457] has been reserved
system 00:0d: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
pnp 00:0e: [mem 0xfed00000-0xfed003ff]
pnp 00:0e: Plug and Play ACPI device, IDs PNP0103 (active)
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
pci 0000:00:01.0: PCI bridge to [bus 01-01]
pci 0000:00:01.0:   bridge window [io  0xe000-0xefff]
pci 0000:00:01.0:   bridge window [mem 0xfe600000-0xfe6fffff]
pci 0000:00:01.0:   bridge window [mem 0xd0000000-0xdfffffff 64bit pref]
pci 0000:00:1c.0: PCI bridge to [bus 02-02]
pci 0000:00:1c.4: PCI bridge to [bus 03-03]
pci 0000:00:1c.6: PCI bridge to [bus 04-04]
pci 0000:00:1c.7: PCI bridge to [bus 05-05]
pci 0000:00:1e.0: PCI bridge to [bus 06-06]
pci 0000:00:1e.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:1e.0:   bridge window [mem 0xfe500000-0xfe5fffff]
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 4 [io  0x0000-0x03af]
pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7]
pci_bus 0000:00: resource 6 [io  0x03b0-0x03df]
pci_bus 0000:00: resource 7 [io  0x0d00-0xffff]
pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff]
pci_bus 0000:00: resource 10 [mem 0xd0000000-0xffffffff]
pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
pci_bus 0000:01: resource 1 [mem 0xfe600000-0xfe6fffff]
pci_bus 0000:01: resource 2 [mem 0xd0000000-0xdfffffff 64bit pref]
pci_bus 0000:06: resource 0 [io  0xd000-0xdfff]
pci_bus 0000:06: resource 1 [mem 0xfe500000-0xfe5fffff]
pci_bus 0000:06: resource 4 [io  0x0000-0x03af]
pci_bus 0000:06: resource 5 [io  0x03e0-0x0cf7]
pci_bus 0000:06: resource 6 [io  0x03b0-0x03df]
pci_bus 0000:06: resource 7 [io  0x0d00-0xffff]
pci_bus 0000:06: resource 8 [mem 0x000a0000-0x000bffff]
pci_bus 0000:06: resource 9 [mem 0x000c0000-0x000dffff]
pci_bus 0000:06: resource 10 [mem 0xd0000000-0xffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP: reno registered
UDP hash table entries: 512 (order: 2, 16384 bytes)
UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
NET: Registered protocol family 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
pci 0000:01:00.0: Boot video device
PCI: CLS 64 bytes, default 64
audit: initializing netlink socket (disabled)
type=2000 audit(1366021073.520:1): initialized
highmem bounce pool size: 64 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
NFS: Registering the id_resolver key type
FS-Cache: Netfs 'nfs' registered for caching
SGI XFS with ACLs, security attributes, realtime, large block/inode 
numbers, no debug enabled
msgmni has been set to 1670
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler deadline registered (default)
pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
pcieport 0000:00:1c.0: irq 41 for MSI/MSI-X
pcieport 0000:00:1c.4: irq 42 for MSI/MSI-X
pcieport 0000:00:1c.6: irq 43 for MSI/MSI-X
pcieport 0000:00:1c.7: irq 44 for MSI/MSI-X
pcieport 0000:00:01.0: Signaling PME through PCIe PME interrupt
pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:01.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
pcieport 0000:00:1c.4: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:1c.4:pcie01: service driver pcie_pme loaded
pcieport 0000:00:1c.6: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:1c.6:pcie01: service driver pcie_pme loaded
pcieport 0000:00:1c.7: Signaling PME through PCIe PME interrupt
pcie_pme 0000:00:1c.7:pcie01: service driver pcie_pme loaded
intel_idle: MWAIT substates: 0x1120
intel_idle: v0.4 model 0x2A
intel_idle: lapic_timer_reliable_states 0xffffffff
input: Power Button as 
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: Requesting acpi_cpufreq
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:0a: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
0000:00:16.3: ttyS1 at I/O 0xf0a0 (irq = 17) is a 16550A
0000:06:01.0: ttyS2 at I/O 0xd020 (irq = 21) is a 16550A
Linux agpgart interface v0.103
[drm] Initialized drm 1.1.0 20060810
Refined TSC clocksource calibration: 3392.286 MHz.
Switching to clocksource tsc
floppy0: no floppy controllers found
brd: module loaded
loop: module loaded
Compaq SMART2 Driver (v 2.6.0)
HP CISS Driver (v 3.6.26)
Adaptec aacraid driver 1.2-0[28900]-ms
st: Version 20101219, fixed bufsize 32768, s/g segs 256
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: irq 45 for MSI/MSI-X
ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x15 impl SATA 
mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems sxs 
apst 
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xfe725000 port 0xfe725100 irq 45
ata2: DUMMY
ata3: SATA max UDMA/133 abar m2048@0xfe725000 port 0xfe725200 irq 45
ata4: DUMMY
ata5: SATA max UDMA/133 abar m2048@0xfe725000 port 0xfe725300 irq 45
ata6: DUMMY
e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
e1000: Copyright (c) 1999-2006 Intel Corporation.
e1000e: Intel(R) PRO/1000 Network Driver - 1.9.5-k
e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
e1000e 0000:00:19.0: setting latency timer to 64
e1000e 0000:00:19.0: (unregistered net_device): Interrupt Throttling Rate 
(ints/sec) set to dynamic conservative mode
e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 
08:2e:5f:1b:3d:98
e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
e1000e 0000:00:19.0: eth0: MAC: 10, PHY: 11, PBA No: 0100FF-0FF
igb: Intel(R) Gigabit Ethernet Network Driver - version 3.2.10-k
igb: Copyright (c) 2007-2012 Intel Corporation.
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.0: setting latency timer to 64
ehci_hcd 0000:00:1a.0: EHCI Host Controller
ehci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.0: debug port 2
ehci_hcd 0000:00:1a.0: cache line size of 64 is not supported
ehci_hcd 0000:00:1a.0: irq 16, io mem 0xfe727000
ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 3 ports detected
ehci_hcd 0000:00:1d.0: setting latency timer to 64
ehci_hcd 0000:00:1d.0: EHCI Host Controller
ehci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.0: debug port 2
ehci_hcd 0000:00:1d.0: cache line size of 64 is not supported
ehci_hcd 0000:00:1d.0: irq 23, io mem 0xfe726000
ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 
1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mousedev: PS/2 mouse device common for all mice
input: PC Speaker as /devices/platform/pcspkr/input/input2
device-mapper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: 
dm-devel@redhat.com
EISA: Probing bus 0 at eisa.0
EISA: Cannot allocate resource for mainboard
Cannot allocate resource for EISA slot 1
Cannot allocate resource for EISA slot 2
Cannot allocate resource for EISA slot 3
Cannot allocate resource for EISA slot 4
Cannot allocate resource for EISA slot 5
Cannot allocate resource for EISA slot 6
Cannot allocate resource for EISA slot 7
Cannot allocate resource for EISA slot 8
EISA: Detected 0 cards.
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP: cubic registered
NET: Registered protocol family 10
NET: Registered protocol family 17
Bridge firewalling registered
8021q: 802.1Q VLAN Support v1.8
TIPC: Activated (version 2.0.0)
NET: Registered protocol family 30
TIPC: Started in single node mode
Registering the dns_resolver key type
openvswitch: Open vSwitch switching datapath
Using IPI No-Shortcut mode
registered taskstats version 1
ALSA device list:
  No soundcards found.
ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata3.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
ata3.00: ATAPI: hp      DVD RW AD-7250H5, 1HNK, max UDMA/100
ata3.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
ata3.00: configured for UDMA/100
ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
ata1.00: ATA-8: ST3500413AS, HP64, max UDMA/100
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
ata1.00: configured for UDMA/100
scsi 0:0:0:0: Direct-Access     ATA      ST3500413AS      HP64 PQ: 0 ANSI: 
5
sd 0:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 2:0:0:0: CD-ROM            hp       DVD RW AD-7250H5 1HNK PQ: 0 ANSI: 
5
sr0: scsi3-mmc drive: 40x/40x writer dvd-ram cd/rw xa/form2 cdda tray
cdrom: Uniform CD-ROM driver Revision: 3.20
sr 2:0:0:0: Attached scsi CD-ROM sr0
sr 2:0:0:0: Attached scsi generic sg1 type 5
 sda: sda1 sda2 sda3 sda4
sd 0:0:0:0: [sda] Attached SCSI disk
usb 1-1: new high-speed USB device number 2 using ehci_hcd
hub 1-1:1.0: USB hub found
hub 1-1:1.0: 6 ports detected
usb 2-1: new high-speed USB device number 2 using ehci_hcd
hub 2-1:1.0: USB hub found
hub 2-1:1.0: 8 ports detected
input: ImPS/2 Generic Wheel Mouse as 
/devices/platform/i8042/serio1/input/input3
usb 1-1.5: new low-speed USB device number 3 using ehci_hcd
XFS (sda3): Mounting Filesystem
input: CHICONY HP Basic USB Keyboard as 
/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.5/1-1.5:1.0/input/input4
generic-usb 0003:03F0:0024.0001: input: USB HID v1.11 Keyboard [CHICONY HP 
Basic USB Keyboard] on usb-0000:00:1a.0-1.5/input0
XFS (sda3): Starting recovery (logdev: internal)
XFS (sda3): Ending recovery (logdev: internal)
VFS: Mounted root (xfs filesystem) readonly on device 8:3.
Freeing unused kernel memory: 424k freed
systemd-udevd[1205]: starting version 197
microcode: CPU0 sig=0x206a7, pf=0x2, revision=0x1b
snd_hda_intel 0000:00:1b.0: irq 47 for MSI/MSI-X
microcode: CPU1 sig=0x206a7, pf=0x2, revision=0x1b
microcode: CPU2 sig=0x206a7, pf=0x2, revision=0x1b
microcode: CPU3 sig=0x206a7, pf=0x2, revision=0x1b
microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, 
Peter Oruba
snd_hda_intel 0000:01:00.1: irq 48 for MSI/MSI-X
[drm] radeon defaulting to kernel modesetting.
[drm] radeon kernel modesetting enabled.
[drm] initializing kernel modesetting (TURKS 0x1002:0x6759 0x103C:0x3130).
[drm] register mmio base: 0xFE620000
[drm] register mmio size: 131072
ATOM BIOS: Bobafet
radeon 0000:01:00.0: VRAM: 1024M 0x0000000000000000 - 0x000000003FFFFFFF 
(1024M used)
radeon 0000:01:00.0: GTT: 512M 0x0000000040000000 - 0x000000005FFFFFFF
[drm] Detected VRAM RAM=1024M, BAR=256M
[drm] RAM width 128bits DDR
[TTM] Zone  kernel: Available graphics memory: 427752 kiB
[TTM] Zone highmem: Available graphics memory: 2046914 kiB
[TTM] Initializing pool allocator
[drm] radeon: 1024M of VRAM memory ready
[drm] radeon: 512M of GTT memory ready.
[drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[drm] Driver supports precise vblank timestamp query.
radeon 0000:01:00.0: irq 49 for MSI/MSI-X
radeon 0000:01:00.0: radeon: using MSI.
[drm] radeon: irq initialized.
[drm] GART: num cpu pages 131072, num gpu pages 131072
[drm] radeon: ib pool ready.
[drm] Loading TURKS Microcode
[drm] PCIE GART of 512M enabled (table at 0x0000000000040000).
radeon 0000:01:00.0: WB enabled
[drm] fence driver on ring 0 use gpu addr 0x40000c00 and cpu addr 
0xffceec00
[drm] ring test on 0 succeeded in 3 usecs
[drm] ib test on ring 0 succeeded in 0 usecs
[drm] Radeon Display Connectors
[drm] Connector 0:
[drm]   DisplayPort
[drm]   HPD4
[drm]   DDC: 0x6450 0x6450 0x6454 0x6454 0x6458 0x6458 0x645c 0x645c
[drm]   Encoders:
[drm]     DFP1: INTERNAL_UNIPHY2
[drm] Connector 1:
[drm]   DisplayPort
[drm]   HPD5
[drm]   DDC: 0x6470 0x6470 0x6474 0x6474 0x6478 0x6478 0x647c 0x647c
[drm]   Encoders:
[drm]     DFP2: INTERNAL_UNIPHY2
[drm] Connector 2:
[drm]   DVI-I
[drm]   HPD1
[drm]   DDC: 0x6460 0x6460 0x6464 0x6464 0x6468 0x6468 0x646c 0x646c
[drm]   Encoders:
[drm]     DFP3: INTERNAL_UNIPHY
[drm]     CRT1: INTERNAL_KLDSCP_DAC1
[drm] Internal thermal controller with fan control
[drm] radeon: power management initialized
[drm] fb mappable at 0xD0142000
[drm] vram apper at 0xD0000000
[drm] size 9216000
[drm] fb depth is 24
[drm]    pitch is 7680
fbcon: radeondrmfb (fb0) is primary device
Console: switching to colour frame buffer device 240x75
fb0: radeondrmfb frame buffer device
drm: registered panic notifier
[drm] Initialized radeon 2.16.0 20080528 for 0000:01:00.0 on minor 0
Adding 4194300k swap on /dev/sda2.  Priority:-1 extents:1 across:4194300k 
EXT4-fs (sda1): barriers disabled
EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: nobarrier
EXT4-fs (dm-2): VFS: Can't find ext4 filesystem
FAT-fs (dm-2): Unrecognized mount option "nobarrier" or missing value
XFS (dm-2): Mounting Filesystem
XFS (dm-2): Starting recovery (logdev: internal)
XFS (dm-2): Ending recovery (logdev: internal)
e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
ADDRCONF(NETDEV_UP): eth0: link is not ready
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
eth0: no IPv6 routers present
ata1.00: configured for UDMA/100
ata1: EH complete
EXT4-fs (sda1): re-mounted. Opts: nobarrier,commit=0
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000000
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
INFO: task Gecko_IOThread:10655 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10655   6336 0x00000004
 f44a3400 00000086 ece3dea0 00000000 00000000 c10cb15b ef6fe030 c17e4280
 f30c17c0 ece3de60 c17e4280 c17e4280 ef6fe030 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434638 f4434638
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task Gecko_IOThread:10691 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10691   6336 0x00000000
 f44a3400 00000086 d0247ea0 00000000 00000000 c10cb15b ef317400 c17e4280
 f31590c0 d0247e60 c17e4280 c17e4280 ef317400 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434ae8 f4434ae8
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000004
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
INFO: task Gecko_IOThread:10655 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10655   6355 0x00000004
 f44a3400 00000086 ece3dea0 00000000 00000000 c10cb15b ef6fe030 c17e4280
 f30c17c0 ece3de60 c17e4280 c17e4280 ef6fe030 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434638 f4434638
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task Gecko_IOThread:10691 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10691   6355 0x00000000
 f44a3400 00000086 d0247ea0 00000000 00000000 c10cb15b ef317400 c17e4280
 f31590c0 d0247e60 c17e4280 c17e4280 ef317400 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434ae8 f4434ae8
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000004
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
INFO: task Gecko_IOThread:10655 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10655   6355 0x00000004
 f44a3400 00000086 ece3dea0 00000000 00000000 c10cb15b ef6fe030 c17e4280
 f30c17c0 ece3de60 c17e4280 c17e4280 ef6fe030 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434638 f4434638
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task Gecko_IOThread:10691 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10691   6355 0x00000000
 f44a3400 00000086 d0247ea0 00000000 00000000 c10cb15b ef317400 c17e4280
 f31590c0 d0247e60 c17e4280 c17e4280 ef317400 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434ae8 f4434ae8
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
nfsd: last server has exited, flushing export cache
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000004
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
