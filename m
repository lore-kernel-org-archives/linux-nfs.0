From: Scott Sturdivant <scott-ILTxhEaIe5LR7s880joybQ@public.gmane.org>
Subject: Re: NFS Server Not Responding after hw change (svc: transport	busy,
 not enqueued)
Date: Thu, 7 Jan 2010 09:53:35 -0500 (EST)
Message-ID: <alpine.DEB.1.10.1001070942180.12318@asgard.binrock.net>
References: <alpine.DEB.1.10.1001052221550.22025@asgard.binrock.net> <20100106204017.GN6612@fieldses.org> <alpine.DEB.1.10.1001061958560.22025@asgard.binrock.net> <20100107143557.GA24418@fieldses.org> <20100107144146.GB24418@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.binrock.net ([64.34.170.100]:52425 "EHLO binrock.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab0AGOxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:53:37 -0500
In-Reply-To: <20100107144146.GB24418@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>> However, as the
>>> onboard LAN is able to handle Samba / scp but fails with NFS, I'm curious
>>> if this is an actual hardware problem or a driver issue?  Does anyone
>>> know where the appropriate place for this problem would be?  Is there an
>>> atl1c list?
>>
>> Adding netdev-u79uwXL29TaiAVqoAR/hOOOyGI2DFzLe@public.gmane.org  Could you repeat any details about
>> the exact models of the network interfaces?
>>
>> --b.
>

For those of you just joining us, I have some new hardware that handles 
ssh, scp, and samba all fine but NFS does not work.  Put back in the old 
NIC and all services are functional.

The onboard LAN (the bad one!) as seen from lspci -vvv:

01:00.0 Ethernet controller [0200]: Attansic Technology Corp. Device 
[1969:1063] (rev c0)
 	Subsystem: Elitegroup Computer Systems Device [1019:8131]
 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B- DisINTx+
 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
 	Latency: 0, Cache Line Size: 32 bytes
 	Interrupt: pin A routed to IRQ 25
 	Region 0: Memory at feac0000 (64-bit, non-prefetchable) 
[size=256K]
 	Region 2: I/O ports at dc00 [size=128]
 	Capabilities: [40] Power Management version 3
 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
 	Capabilities: [48] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/0 Enable+
 		Address: 00000000fee0f00c  Data: 4171
 	Capabilities: [58] Express (v1) Endpoint, MSI 00
 		DevCap:	MaxPayload 4096 bytes, PhantFunc 0, Latency L0s 
<4us, L1 unlimited
 			ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE+ FLReset-
 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
 			MaxPayload 128 bytes, MaxReadReq 512 bytes
 		DevSta:	CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ 
TransPend-
 		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, 
Latency L0 unlimited, L1 unlimited
 			ClockPM+ Suprise- LLActRep- BwNot-
 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- 
CommClk+
 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
 		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
 	Capabilities: [6c] Vital Product Data <?>
 	Kernel driver in use: atl1c
 	Kernel modules: atl1c

This is on an ECS 945GCD-M motherboard:

dmi.bios.date: 07/21/2009
dmi.bios.vendor: American Megatrends Inc.
dmi.bios.version: 080013
dmi.board.asset.tag: To Be Filled By O.E.M.
dmi.board.name: 945GCD-M
dmi.board.vendor: ECS
dmi.board.version: V1.0
dmi.chassis.asset.tag: To Be Filled By O.E.M.
dmi.chassis.type: 3
dmi.chassis.vendor: ECS
dmi.chassis.version: V1.0
dmi.modalias: 
dmi:bvnAmericanMegatrendsInc.:bvr080013:bd07/21/2009:svnECS:pn945GCD-M:pvrV1.0:rvnECS:rn945GCD-M:rvrV1.0:cvnECS:ct3:cvrV1.0:
dmi.product.name: 945GCD-M
dmi.product.version: V1.0
dmi.sys.vendor: ECS


The PCI add-on NIC (the good one!):

02:01.0 Ethernet controller: Intel Corporation 82541PI Gigabit Ethernet 
Controller (rev 05)
         Subsystem: Intel Corporation Device 1376
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- 
ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 64 (63750ns min), Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 18
         Region 0: Memory at febe0000 (32-bit, non-prefetchable) 
[size=128K]
         Region 1: Memory at febc0000 (32-bit, non-prefetchable) 
[size=128K]
         Region 2: I/O ports at ec00 [size=64]
         Expansion ROM at 40000000 [disabled] [size=128K]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [e4] PCI-X non-bridge device
                 Command: DPERE- ERO+ RBC=512 OST=1
                 Status: Dev=00:00.0 64bit- 133MHz- SCD- USC- DC=simple 
DMMRBC=2048 DMOST=1 DMCRS=8 RSCEM- 266MHz- 533MHz-
         Kernel driver in use: e1000
         Kernel modules: e1000


I've filed a bug here: 
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/503484

Basically I see this in dmesg on the buggy onboad LAN:

[ 6588.482854] svc: transport f45f8e00 busy, not enqueued
[ 6588.482870] nfsd: fh_verify(36: 01070001 0141401d 00000000 e12f98aa 
1c4965f0 0d4e5b93)
[ 6588.483499] svc: socket f45f8e00 sendto([cddbc000 132... ], 131204) = 
131204 (addr 192.168.1.100, port=915)
[ 6588.483531] svc: transport f45f8e00 busy, not enqueued
[ 6588.483543] svc: server de5f6000 waiting for data (to = 900000)
[ 6588.483639] svc: socket f45f8e00 sendto([f4dbd000 132... ], 131204) = 
131204 (addr 192.168.1.100, port=915)
[ 6588.483667] svc: transport f45f8e00 busy, not enqueued
[ 6588.483674] svc: server f45d4000 waiting for data (to = 900000)
[ 6588.483904] svc: socket f45f8e00 sendto([ea445000 132... ], 131204) = 
131204 (addr 192.168.1.100, port=915)
[ 6588.483931] svc: transport f45f8e00 busy, not enqueued

Thank you!

Scott
