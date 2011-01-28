Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:61963 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321Ab1A1Q7F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jan 2011 11:59:05 -0500
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110128124331.GD1140@DLHLAP0379>
Date: Fri, 28 Jan 2011 11:58:10 -0500
Cc: Deepak SIKRI <deepak.sikri@st.com>,
        Armando VISCONTI <armando.visconti@st.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, amitgoel <amit.goel@st.com>
Message-Id: <136811BD-9971-4E3F-B113-1266A58A0363@oracle.com>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com> <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com> <20110128124331.GD1140@DLHLAP0379>
To: Shiraz Hashim <shiraz.hashim@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

On Jan 28, 2011, at 7:43 AM, Shiraz Hashim wrote:

> Hello Chuck,
> 
> On Wed, Jan 26, 2011 at 02:04:21AM +0800, Chuck Lever wrote:
>> See analysis in line.
>> 
>> On Jan 25, 2011, at 6:56 AM, deepaksi wrote:
> 
> [...]
> 
>>> We have made following observations
>>> 1. It seems that the time taken by phy auto negotiation process is
>>> long and as soon as the link gets up rpc ping request is getting
>>> timed out and we receive "Unable to reach ICMP" error. The time
>>> out error is same even if you do not connect a network cable and
>>> do a nfs boot.
>>> 
>>> 2. We tried to modify the rate at which the work queue is
>>> scheduled in the phy framework. instead of scheduling every HZ ( 1
>>> sec), we modified it to HZ/10. We did not received
>>> the error. This probably reduced the margin of the phy framework
>>> informing the kernel that the link is up.
>>> 
>>> 3. We tried to use another network card and did a nfs boot. The
>>> only relevant difference we could find was the time of auto
>>> negotiation.
>> 
>> Can you post a similar debugging dump of a root mount that succeeds
>> using a different network card?
> 
> Following is the NFS boot log with a PCIe based e1000e nic card.
> 
> ....
> ....
> [    1.570000] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
> [    1.580000] e1000: Copyright (c) 1999-2006 Intel Corporation.
> [    1.590000] e1000e: Intel(R) PRO/1000 Network Driver - 1.2.7-k2
> [    1.590000] e1000e: Copyright (c) 1999 - 2010 Intel Corporation.
> [    1.600000] e1000e 0000:01:00.0: Disabling ASPM  L1
> [    1.600000] PCI: enabling device 0000:01:00.0 (0140 -> 0142)
> [    1.610000] e1000e 0000:01:00.0: (unregistered net_device): Failed to initialize MSI interrupts.  Falling back to legacy interrupts.
> [    1.850000] e1000e 0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:15:17:ec:02:ff
> [    1.860000] e1000e 0000:01:00.0: eth0: Intel(R) PRO/1000 Network Connection
> [    1.870000] e1000e 0000:01:00.0: eth0: MAC: 1, PHY: 4, PBA No: d50861-004
> [    1.870000] Intel(R) Gigabit Ethernet Network Driver - version 2.1.0-k2
> [    1.880000] Copyright (c) 2007-2009 Intel Corporation.
> [    1.880000] Intel(R) Virtual Function Network Driver - version 1.0.0-k0
> [    1.890000] Copyright (c) 2009 Intel Corporation.
> [    1.900000] CAN device driver interface
> [    1.900000] STMMAC driver:
> [    1.900000] 	platform registration... 
> [    1.910000] 	done!
> [    1.910000] 	DWMAC1000 - user ID: 0x10, Synopsys ID: 0x35
> [    1.920000] 	Enhanced descriptor structure
> [    1.920000] 	eth1 - (dev. name: stmmaceth - id: 0, IRQ #65
> [    1.920000] 	IO base addr: 0xd00f0000)
> [    1.940000] STMMAC MII Bus: probed
> [    1.940000] eth1: PHY ID 20005c7a at 5 IRQ -1 (0:05) active
> [    1.950000] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    1.950000] spear-ehci spear-ehci.0: SPEAr EHCI
> [    1.960000] spear-ehci spear-ehci.0: new USB bus registered, assigned bus number 1
> [    2.020000] spear-ehci spear-ehci.0: irq 96, io mem 0xe4800000
> [    2.040000] spear-ehci spear-ehci.0: USB 0.0 started, EHCI 1.00
> [    2.040000] hub 1-0:1.0: USB hub found
> [    2.050000] hub 1-0:1.0: 1 port detected
> [    2.050000] spear-ehci spear-ehci.1: SPEAr EHCI
> [    2.060000] spear-ehci spear-ehci.1: new USB bus registered, assigned bus number 2
> [    2.120000] spear-ehci spear-ehci.1: irq 98, io mem 0xe5800000
> [    2.140000] spear-ehci spear-ehci.1: USB 0.0 started, EHCI 1.00
> [    2.140000] hub 2-0:1.0: USB hub found
> [    2.150000] hub 2-0:1.0: 1 port detected
> [    2.150000] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    2.160000] spear-ohci spear-ohci.0: SPEAr OHCI
> [    2.160000] spear-ohci spear-ohci.0: new USB bus registered, assigned bus number 3
> [    2.200000] spear-ohci spear-ohci.0: irq 97, io mem 0xe4000000
> [    2.260000] hub 3-0:1.0: USB hub found
> [    2.270000] hub 3-0:1.0: 1 port detected
> [    2.270000] spear-ohci spear-ohci.1: SPEAr OHCI
> [    2.280000] spear-ohci spear-ohci.1: new USB bus registered, assigned bus number 4
> [    2.310000] spear-ohci spear-ohci.1: irq 99, io mem 0xe5000000
> [    2.370000] hub 4-0:1.0: USB hub found
> [    2.380000] hub 4-0:1.0: 1 port detected
> [    2.380000] Initializing USB Mass Storage driver...
> [    2.390000] usbcore: registered new interface driver usb-storage
> [    2.390000] USB Mass Storage support registered.
> [    2.400000] usbcore: registered new interface driver usbtest
> [    2.400000] designware_udc designware_udc: Device Synopsys UDC probed csr d00fe000: plug d01c4000
> [    2.410000] zero gadget: Gadget Zero, version: Cinco de Mayo 2008
> [    2.420000] zero gadget: zero ready
> [    2.420000] designware_udc designware_udc: reg gadget driver 'zero'
> [    2.430000] mice: PS/2 mouse device common for all mice
> [    2.440000] input: Spear Keyboard as /devices/platform/keyboard/input/input0
> [    2.470000] usbcore: registered new interface driver usbtouchscreen
> [    2.470000] input: STMPE610 Touchscreen as /devices/ssp-pl022/spi0.0/input/input1
> [    2.670000] stmpe610-spi spi0.0: Detected Touch Screen with chip id: ffff and version: ff
> [    2.690000] rtc-spear rtc-spear: rtc core: registered rtc-spear as rtc0
> [    2.730000] i2c /dev entries driver
> [    2.730000] cortexa9-wdt cortexa9-wdt: registration successful
> [    2.740000] dw_dmac.0: DesignWare DMA Controller, 8 channels
> [    2.750000] dw_dmac.1: DesignWare DMA Controller, 8 channels
> [    2.760000] sdhci: Secure Digital Host Controller Interface driver
> [    2.770000] sdhci: Copyright(c) Pierre Ossman
> [    2.780000] mmc0: SDHCI controller on sdhci [platform] using DMA
> [    2.780000] IPv4 over IPv4 tunneling driver
> [    2.790000] TCP cubic registered
> [    2.790000] NET: Registered protocol family 17
> [    2.800000] can: controller area network core (rev 20090105 abi 8)
> [    2.810000] NET: Registered protocol family 29
> [    2.810000] can: raw protocol (rev 20090105)
> [    2.810000] can: broadcast manager protocol (rev 20090105 t)
> [    2.820000] rtc-spear rtc-spear: hctosys: invalid date/time
> [    4.520000] IP-Config: Complete:
> [    4.520000]      device=eth0, addr=192.168.1.10, mask=255.255.255.0, gw=192.168.1.1,
> [    4.530000]      host=192.168.1.10, domain=, nis-domain=(none),
> [    4.530000]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
> [    4.540000] Root-NFS: nfsroot=/opt/STM/STLinux-2.4/devkit/armv7/target
> [    4.550000] NFS: nfs mount opts='nolock,addr=192.168.1.1'
> [    4.550000] NFS:   parsing nfs mount option 'nolock'
> [    4.560000] NFS:   parsing nfs mount option 'addr=192.168.1.1'
> [    4.560000] NFS: MNTPATH: '/opt/STM/STLinux-2.4/devkit/armv7/target'
> [    4.570000] NFS: sending MNT request for 192.168.1.1:/opt/STM/STLinux-2.4/devkit/armv7/target
> [    4.580000] Calling rpc_create
> [    4.580000] RPC:       set up xprt to 192.168.1.1 (autobind) via tcp
> [    4.590000] RPC:       created transport cfb13800 with 16 slots
> [    4.590000] xprt_create_transport: RPC:       created transport cfb13800 with 16 slots
> [    4.600000] RPC:       creating mount client for 192.168.1.1 (xprt cfb13800)
> [    4.610000] RPC:       creating UNIX authenticator for client cfaae800
> [    4.620000] Calling rpc_ping
> [    4.620000] RPC:       new task initialized, procpid 1
> [    4.620000] RPC:       allocated task cfa93100
> [    4.630000] RPC:     1 __rpc_execute flags=0x680
> [    4.630000] RPC:     1 call_start mount3 proc NULL (sync)
> [    4.640000] RPC:     1 call_reserve (status 0)
> [    4.640000] RPC:     1 reserved req cfb20000 xid a026435b
> [    4.650000] RPC:     1 call_reserveresult (status 0)
> [    4.650000] RPC:     1 call_refresh (status 0)
> [    4.660000] RPC:     1 holding NULL cred c0492798
> [    4.660000] RPC:     1 refreshing NULL cred c0492798
> [    4.670000] RPC:     1 call_refreshresult (status 0)
> [    4.670000] RPC:     1 call_allocate (status 0)
> [    4.680000] RPC:     1 allocated buffer of size 92 at cfb14000
> [    4.680000] RPC:     1 call_bind (status 0)
> [    4.690000] RPC:     1 rpcb_getport_async(192.168.1.1, 100005, 3, 6)
> [    4.690000] RPC:     1 sleep_on(queue "xprt_binding" time 4294937765)
> [    4.700000] RPC:     1 added to queue cfb138a4 "xprt_binding"
> [    4.710000] RPC:     1 setting alarm for 60000 ms
> [    4.710000] RPC:     1 rpcb_getport_async: trying rpcbind version 2
> [    4.720000] Calling rpc_create
> [    4.720000] RPC:       set up xprt to 192.168.1.1 (port 111) via tcp
> [    4.730000] RPC:       created transport cfb14800 with 16 slots
> [    4.730000] xprt_create_transport: RPC:       created transport cfb14800 with 16 slots
> [    4.740000] RPC:       creating rpcbind client for 192.168.1.1 (xprt cfb14800)
> [    4.750000] RPC:       creating UNIX authenticator for client cfaaea00
> [    4.750000] rpc_create returns 0xcfaaea00
> [    4.760000] RPC:       new task initialized, procpid 1
> [    4.760000] RPC:       allocated task cfa93180
> [    4.770000] RPC:       rpc_release_client(cfaaea00)
> [    4.770000] RPC:     1 sync task going to sleep
> [    4.780000] RPC:     2 __rpc_execute flags=0x681
> [    4.780000] RPC:     2 call_start rpcbind2 proc GETPORT (async)
> [    4.790000] RPC:     2 call_reserve (status 0)
> [    4.790000] RPC:     2 reserved req cfb21000 xid aa41d674
> [    4.800000] RPC:     2 call_reserveresult (status 0)
> [    4.800000] RPC:     2 call_refresh (status 0)
> [    4.810000] RPC:     2 looking up UNIX cred
> [    4.810000] RPC:       looking up UNIX cred
> [    4.820000] RPC:       allocating UNIX cred for uid 0 gid 0
> [    4.820000] RPC:     2 refreshing UNIX cred cfa93200
> [    4.830000] RPC:     2 call_refreshresult (status 0)
> [    4.830000] RPC:     2 call_allocate (status 0)
> [    4.840000] RPC:     2 allocated buffer of size 412 at cfb15000
> [    4.840000] RPC:     2 call_bind (status 0)
> [    4.850000] RPC:     2 call_connect xprt cfb14800 is not connected
> [    4.850000] RPC:     2 xprt_connect xprt cfb14800 is not connected
> [    4.860000] RPC:     2 sleep_on(queue "xprt_pending" time 4294937782)
> [    4.860000] RPC:     2 added to queue cfb149dc "xprt_pending"
> [    4.870000] RPC:     2 setting alarm for 60000 ms
> 
> [    4.880000] RPC:       xs_connect scheduled xprt cfb14800
> [    4.880000] RPC:       xs_bind 0.0.0.0:0: ok (0)
> [    4.890000] RPC:       worker connecting xprt cfb14800 via tcp to 192.168.1.1 (port 111)
> [    4.890000] RPC:       cfb14800 connect status 115 connected 0 sock state 2
> 
> [    5.870000] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> 
> [    5.900000] RPC:       xs_tcp_state_change client cfb14800...
> [    5.900000] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0

In the earlier trace, the transport socket connection attempt returns EHOSTUNREACH when a socket connect operation is attempted before the interface is up.  In this trace, the network layer allows the transport socket to connect straight away; there's no race with interface initialization.  So your problem is not likely to be in the RPC client, but in the network layer or below (hardware driver, etc).

> [    5.910000] RPC:     2 __rpc_wake_up_task (now 4294937887)
> [    5.910000] RPC:     2 disabling timer
> [    5.920000] RPC:     2 removed from queue cfb149dc "xprt_pending"
> [    5.920000] RPC:       __rpc_wake_up_task done
> [    5.930000] RPC:     2 __rpc_execute flags=0x681
> [    5.930000] RPC:     2 xprt_connect_status: retrying
> [    5.940000] RPC:     2 call_connect_status (status -11)
> [    5.940000] RPC:     2 call_transmit (status 0)
> [    5.950000] RPC:     2 xprt_prepare_transmit
> [    5.950000] RPC:     2 rpc_xdr_encode (status 0)
> [    5.960000] RPC:     2 marshaling UNIX cred cfa93200
> [    5.960000] RPC:     2 using AUTH_UNIX cred cfa93200 to wrap rpc data
> [    5.970000] RPC:     2 encoding PMAP_GETPORT call (100005, 3, 6, 0)
> [    5.980000] RPC:     2 xprt_transmit(92)
> [    5.980000] RPC:       xs_tcp_send_request(92) = 92
> [    5.980000] RPC:       xs_tcp_data_ready...
> [    5.990000] RPC:       xs_tcp_data_recv started
> [    5.990000] RPC:       reading TCP record fragment of length 28
> [    6.000000] RPC:       reading XID (4 bytes)
> [    6.000000] RPC:       reading request with XID aa41d674
> [    6.010000] RPC:       reading CALL/REPLY flag (4 bytes)
> [    6.010000] RPC:       read reply XID aa41d674
> [    6.020000] RPC:       XID aa41d674 read 20 bytes
> [    6.020000] RPC:       xprt = cfb14800, tcp_copied = 28, tcp_offset = 28, tcp_reclen = 28
> [    6.030000] RPC:     2 xid aa41d674 complete (28 bytes received)
> [    6.040000] RPC:       xs_tcp_data_recv done
> [    6.040000] RPC:     2 xmit complete
> [    6.050000] RPC:       wake_up_next(cfb14974 "xprt_resend")
> [    6.050000] RPC:       wake_up_next(cfb1490c "xprt_sending")
> [    6.060000] RPC:     2 call_status (status 28)
> [    6.060000] RPC:     2 call_decode (status 28)
> [    6.070000] RPC:     2 validating UNIX cred cfa93200
> [    6.070000] RPC:     2 using AUTH_UNIX cred cfa93200 to unwrap rpc data
> [    6.080000] RPC:     2 PMAP_GETPORT result: 48734
> [    6.080000] RPC:     2 call_decode result 0
> [    6.090000] RPC:       setting port for xprt cfb13800 to 48734
> [    6.090000] RPC:     2 rpcb_getport_done(status 0, port 48734)
> [    6.100000] RPC:     2 return 0, status 0
> [    6.100000] RPC:     2 release task
> [    6.110000] RPC:       freeing buffer of size 412 at cfb15000
> [    6.110000] RPC:     2 release request cfb21000
> [    6.120000] RPC:       wake_up_next(cfb14a44 "xprt_backlog")
> [    6.120000] RPC:       rpc_release_client(cfaaea00)
> [    6.130000] RPC:       destroying rpcbind client for 192.168.1.1
> [    6.130000] RPC:       destroying transport cfb14800
> [    6.140000] RPC:       xs_destroy xprt cfb14800
> [    6.140000] RPC:       xs_close xprt cfb14800
> [    6.150000] RPC:       disconnected transport cfb14800
> [    6.150000] RPC:     2 freeing task
> [    6.160000] RPC:     1 __rpc_wake_up_task (now 4294937912)
> [    6.160000] RPC:     1 disabling timer
> [    6.160000] RPC:     1 removed from queue cfb138a4 "xprt_binding"
> [    6.170000] RPC:       __rpc_wake_up_task done

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




