Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49841 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab1BIUOT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 15:14:19 -0500
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110209200129.GA6402@glaurung.lavos.net>
Date: Wed, 9 Feb 2011 15:12:22 -0500
Cc: deepaksi <deepak.sikri@st.com>, Armando VISCONTI <armando.visconti@st.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, netdev@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, amitgoel <amit.goel@st.com>
Message-Id: <D031EAC4-68E9-4E56-8DB3-208B34C8DFD7@oracle.com>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com> <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com> <20110209200129.GA6402@glaurung.lavos.net>
To: Brian Downing <bdowning@lavos.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 9, 2011, at 3:01 PM, Brian Downing wrote:

> [See http://marc.info/?l=linux-nfs&m=129597871731431&w=2 for the
> remainder of the context that was trimmed here; it's long enough as is!]
> 
> On Tue, Jan 25, 2011 at 01:04:21PM -0500, Chuck Lever wrote:
>> On Jan 25, 2011, at 6:56 AM, deepaksi wrote:
>>> Are there some changes in the kernel framework w.r.t rpc ping time
>>> out ?  This problem was not there in previous kernels.
>> 
>> There have been changes in the RPC socket code around how it manages
>> recovery from failed attempts to connect.  We also have new logic now
>> in the RPC client that causes RPC ping to fail immediately if a host
>> can't be reached.
>> 
>> Thanks for your efforts so far.  It would be helpful if you could
>> bisect to determine which commit(s) introduced this RPC client
>> behavior (or any related changes to your network driver behavior).
> 
> I'm having this same problem with a Freescale MPC8313E-RDB board while
> trying to do nfsroot in 2.6.37 with its built-in gianfar ethernet.
> I was able to bisect it down to this commit:
> 
> 56463e50d1fc3f070492434cea6303b35ea000de is the first bad commit
> commit 56463e50d1fc3f070492434cea6303b35ea000de
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Fri Sep 17 10:54:37 2010 -0400
> 
>    NFS: Use super.c for NFSROOT mount option parsing
> 
>    Replace duplicate code in NFSROOT for mounting an NFS server on '/'
>    with logic that uses the existing mainline text-based logic in the NFS
>    client.
> 
>    Add documenting comments where appropriate.
> 
>    Note that this means NFSROOT mounts now use the same default settings
>    as v2/v3 mounts done via mount(2) from user space.
> 
>      vers=3,tcp,rsize=<negotiated default>,wsize=<negotiated default>
> 
>    As before, however, no version/protocol negotiation with the server is
>    done.

Based on your console logs, I see that the working case uses UDP to contact the server's mountd, but the failing case uses TCP.  You can try explicitly specifying "proto=udp" to force the use of UDP, to test this theory.

Meanwhile, the patch description explicitly states that the default mount option settings have changed.  Does it make sense to change the default behavior of NFSROOT mounts to use UDP again?  I don't see another way to make this process more reliable across NIC initialization.  If this is considered a regression, we can make a patch for 2.6.38-rc and 2.6.37.

>    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Here's the boot console logs from both the good and bad cases with NFS
> and RPC debug enabled.  Note that the gianfar ethernet driver takes
> approximately 2 seconds to get a useful link (i.e. between
> "ADDRCONF(NETDEV_UP): eth1: link is not ready" and
> "ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready"), which I suspect is
> part of the problem here.  Also, once I added RPC debug in the bad case
> it started working occasionally, which I suspect is because of delays
> induced by the serial console blocking.
> 
> Hopefully this helps narrow it down.
> 
> ********** good (60ac03685bf513f9d9b6e8e098018b35309ed326) **********
> Using MPC831x RDB machine description
> Linux version 2.6.36-rc3+ (bdowning@scatha) (gcc version 4.4.2 (crosstool-NG-hg_default@1733_02db017f4fe1) ) #25 Wed Feb 9 13:08:52 CST 2011
> bootconsole [udbg0] enabled
> setup_arch: bootmem
> mpc831x_rdb_setup_arch()
> Found FSL PCI host bridge at 0x00000000e0008500. Firmware bus number: 0->0
> PCI host bridge /sleep-nexus/pci@e0008500 (primary) ranges:
> MEM 0x0000000090000000..0x000000009fffffff -> 0x0000000090000000 
> MEM 0x0000000080000000..0x000000008fffffff -> 0x0000000080000000 Prefetch
>  IO 0x00000000e2000000..0x00000000e20fffff -> 0x0000000000000000
> arch: exit
> Zone PFN ranges:
>  DMA      0x00000000 -> 0x00008000
>  Normal   empty
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>    0: 0x00000000 -> 0x00008000
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
> Kernel command line: nfsroot=172.26.128.52:/srv/nfs/root0 ip=172.26.130.10:172.26.128.52:172.26.128.1:255.255.240.0:ppc10:eth1:off root=/dev/nfs rw console=ttyS0,115200 nfsrootdebug
> PID hash table entries: 512 (order: -1, 2048 bytes)
> Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
> Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
> Memory: 124812k/131072k available (4768k kernel code, 6260k reserved, 216k data, 101k bss, 192k init)
> Kernel virtual memory layout:
>  * 0xfffdf000..0xfffff000  : fixmap
>  * 0xfdefb000..0xfe000000  : early ioremap
>  * 0xc9000000..0xfdefb000  : vmalloc & ioremap
> SLUB: Genslabs=13, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
> NR_IRQS:512
> IPIC (128 IRQ sources) at c9000700
> clocksource: timebase mult[6000002] shift[22] registered
> pid_max: default: 32768 minimum: 301
> Mount-cache hash table entries: 512
> NET: Registered protocol family 16
> 
> PCI: Probing PCI hardware
> bio: create slab <bio-0> at 0
> vgaarb: loaded
> SCSI subsystem initialized
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Switching to clocksource timebase
> NET: Registered protocol family 2
> IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
> TCP established hash table entries: 4096 (order: 3, 32768 bytes)
> TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
> TCP: Hash tables configured (established 4096 bind 4096)
> TCP reno registered
> UDP hash table entries: 256 (order: 0, 4096 bytes)
> UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
> NET: Registered protocol family 1
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> msgmni has been set to 243
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
> console [ttyS0] enabled, bootconsole disabled
> console [ttyS0] enabled, bootconsole disabled
> serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
> brd: module loaded
> loop: module loaded
> fe000000.flash: Found 1 x16 devices at 0x0 in 16-bit bank. Manufacturer ID 0x000001 Chip ID 0x001001
> Amd/Fujitsu Extended Query Table at 0x0040
>  Amd/Fujitsu Extended Query version 1.3.
> fe000000.flash: Swapping erase regions for top-boot CFI table.
> number of CFI chips: 1
> cmdlinepart partition parsing not available
> RedBoot partition parsing not available
> of:fsl-elbc e0005000.localbus: read_byte beyond end of buffer
> of:fsl-elbc e0005000.localbus: read_byte beyond end of buffer
> of:fsl-elbc e0005000.localbus: read_byte beyond end of buffer
> NAND device: Manufacturer ID: 0xec, Chip ID: 0x75 (Samsung NAND 32MiB 3,3V 8-bit)
> cmdlinepart partition parsing not available
> RedBoot partition parsing not available
> Creating 3 MTD partitions on "e2800000.flash":
> 0x000000000000-0x000000100000 : "u-boot"
> 0x000000100000-0x000000400000 : "kernel"
> 0x000000400000-0x000002000000 : "fs"
> eLBC NAND device at 0xe2800000, bank 1
> Fixed MDIO Bus: probed
> of:fsl-gianfar e0024000.ethernet: enabled errata workarounds, flags: 0x7
> eth0: Gianfar Ethernet Controller Version 1.2, 08:00:3e:03:01:a0
> eth0: Running with NAPI enabled
> eth0: RX BD ring size for Q[0]: 256
> eth0: TX BD ring size for Q[0]: 256
> of:fsl-gianfar e0025000.ethernet: enabled errata workarounds, flags: 0x7
> eth1: Gianfar Ethernet Controller Version 1.2, 08:00:3e:03:01:a1
> eth1: Running with NAPI enabled
> eth1: RX BD ring size for Q[0]: 256
> eth1: TX BD ring size for Q[0]: 256
> Freescale PowerQUICC MII Bus: probed
> Freescale PowerQUICC MII Bus: probed
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> fsl-ehci fsl-ehci.0: Freescale On-Chip EHCI Host Controller
> fsl-ehci fsl-ehci.0: new USB bus registered, assigned bus number 1
> fsl-ehci fsl-ehci.0: irq 38, io base 0xe0023000
> fsl-ehci fsl-ehci.0: USB 2.0 started, EHCI 1.00
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 1 port detected
> i2c /dev entries driver
> of:mpc-i2c e0003000.i2c: timeout 1000000 us
> rtc-ds1307 0-0068: rtc core: registered ds1339 as rtc0
> of:mpc-i2c e0003100.i2c: timeout 1000000 us
> alg: No test for authenc(hmac(sha1),cbc(aes)) (authenc-hmac-sha1-cbc-aes-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha1-cbc-aes-talitos
> alg: No test for authenc(hmac(sha1),cbc(des3_ede)) (authenc-hmac-sha1-cbc-3des-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha1-cbc-3des-talitos
> alg: No test for authenc(hmac(sha256),cbc(aes)) (authenc-hmac-sha256-cbc-aes-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha256-cbc-aes-talitos
> alg: No test for authenc(hmac(sha256),cbc(des3_ede)) (authenc-hmac-sha256-cbc-3des-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha256-cbc-3des-talitos
> alg: No test for authenc(hmac(md5),cbc(aes)) (authenc-hmac-md5-cbc-aes-talitos)
> of:talitos e0030000.crypto: authenc-hmac-md5-cbc-aes-talitos
> alg: No test for authenc(hmac(md5),cbc(des3_ede)) (authenc-hmac-md5-cbc-3des-talitos)
> of:talitos e0030000.crypto: authenc-hmac-md5-cbc-3des-talitos
> of:talitos e0030000.crypto: cbc-aes-talitos
> of:talitos e0030000.crypto: cbc-3des-talitos
> of:talitos e0030000.crypto: md5-talitos
> of:talitos e0030000.crypto: sha1-talitos
> of:talitos e0030000.crypto: sha224-talitos
> of:talitos e0030000.crypto: sha256-talitos
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> TCP cubic registered
> NET: Registered protocol family 10
> IPv6 over IPv4 tunneling driver
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> Registering the dns_resolver key type
> rtc-ds1307 0-0068: setting system clock to 2000-01-06 16:34:00 UTC (947176440)
> ADDRCONF(NETDEV_UP): eth1: link is not ready
> IP-Config: Complete:
>     device=eth1, addr=172.26.130.10, mask=255.255.240.0, gw=172.26.128.1,
>     host=ppc10, domain=, nis-domain=(none),
>     bootserver=172.26.128.52, rootserver=172.26.128.52, rootpath=
> Looking up port of RPC 100003/2 on 172.26.128.52
> RPC:       rpcb_getport_sync(172.26.128.52, 100003, 2, 17)
> RPC:       set up xprt to 172.26.128.52 (port 111) via udp
> RPC:       created transport c79c6800 with 16 slots
> RPC:       creating rpcbind client for 172.26.128.52 (xprt c79c6800)
> RPC:       creating UNIX authenticator for client c7920800
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fa80
> RPC:     1 __rpc_execute flags=0x280
> RPC:     1 call_start rpcbind2 proc GETPORT (sync)
> RPC:     1 call_reserve (status 0)
> RPC:     1 reserved req c780b000 xid 5420c919
> RPC:     1 call_reserveresult (status 0)
> RPC:     1 call_allocate (status 0)
> RPC:     1 allocated buffer of size 412 at c79c7000
> RPC:     1 call_refresh (status 0)
> RPC:     1 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:       allocating UNIX cred for uid 0 gid 0
> RPC:     1 refreshing UNIX cred c792fb00
> RPC:     1 call_refreshresult (status 0)
> RPC:     1 call_bind (status 0)
> RPC:     1 call_connect xprt c79c6800 is not connected
> RPC:     1 xprt_connect xprt c79c6800 is not connected
> RPC:     1 xprt_cwnd_limited cong = 0 cwnd = 256
> RPC:     1 sleep_on(queue "xprt_pending" time 4294892880)
> RPC:     1 added to queue c79c69ac "xprt_pending"
> RPC:     1 setting alarm for 5000 ms
> RPC:       xs_connect scheduled xprt c79c6800
> RPC:     1 sync task going to sleep
> RPC:       xs_bind4 0.0.0.0:0: ok (0)
> RPC:       worker connecting xprt c79c6800 via udp to 172.26.128.52 (port 111)
> RPC:     1 __rpc_wake_up_task (now 4294892888)
> RPC:     1 disabling timer
> RPC:     1 removed from queue c79c69ac "xprt_pending"
> RPC:       __rpc_wake_up_task done
> RPC:     1 sync task resuming
> RPC:     1 xprt_connect_status: connection established
> RPC:     1 call_connect_status (status 0)
> RPC:     1 call_transmit (status 0)
> RPC:     1 xprt_prepare_transmit
> RPC:     1 rpc_xdr_encode (status 0)
> RPC:     1 marshaling UNIX cred c792fb00
> RPC:     1 using AUTH_UNIX cred c792fb00 to wrap rpc data
> RPC:     1 encoding PMAP_GETPORT call (100003, 2, 17, 0)
> RPC:     1 xprt_transmit(84)
> RPC:       xs_udp_send_request(84) = 84
> RPC:     1 xmit complete
> RPC:     1 sleep_on(queue "xprt_pending" time 4294892902)
> RPC:     1 added to queue c79c69ac "xprt_pending"
> RPC:     1 setting alarm for 5000 ms
> RPC:     1 sync task going to sleep
> PHY: mdio@e0024520:04 - Link is Up - 1000/Full
> ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
> RPC:     1 timeout
> RPC:     1 __rpc_wake_up_task (now 4294894156)
> RPC:     1 disabling timer
> RPC:     1 removed from queue c79c69ac "xprt_pending"
> RPC:       __rpc_wake_up_task done
> RPC:     1 sync task resuming
> RPC:     1 xprt_timer
> RPC:       cong 256, cwnd was 256, now 256
> RPC:       wake_up_next(c79c6954 "xprt_resend")
> RPC:       wake_up_next(c79c68fc "xprt_sending")
> RPC:     1 call_status (status -110)
> RPC:     1 call_timeout (minor)
> RPC:     1 call_bind (status 0)
> RPC:     1 call_connect xprt c79c6800 is connected
> RPC:     1 call_transmit (status 0)
> RPC:     1 xprt_prepare_transmit
> RPC:     1 xprt_cwnd_limited cong = 0 cwnd = 256
> RPC:     1 rpc_xdr_encode (status 0)
> RPC:     1 marshaling UNIX cred c792fb00
> RPC:     1 using AUTH_UNIX cred c792fb00 to wrap rpc data
> RPC:     1 encoding PMAP_GETPORT call (100003, 2, 17, 0)
> RPC:     1 xprt_transmit(84)
> RPC:       xs_udp_send_request(84) = 84
> RPC:     1 xmit complete
> RPC:     1 sleep_on(queue "xprt_pending" time 4294894176)
> RPC:     1 added to queue c79c69ac "xprt_pending"
> RPC:     1 setting alarm for 10000 ms
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 256, now 512
> RPC:     1 xid 5420c919 complete (28 bytes received)
> RPC:     1 __rpc_wake_up_task (now 4294894183)
> RPC:     1 disabling timer
> RPC:     1 removed from queue c79c69ac "xprt_pending"
> RPC:       __rpc_wake_up_task done
> RPC:       wake_up_next(c79c6954 "xprt_resend")
> RPC:       wake_up_next(c79c68fc "xprt_sending")
> RPC:     1 call_status (status 28)
> RPC:     1 call_decode (status 28)
> RPC:     1 validating UNIX cred c792fb00
> RPC:     1 using AUTH_UNIX cred c792fb00 to unwrap rpc data
> RPC:     1 PMAP_GETPORT result: 2049
> RPC:     1 call_decode result 0
> RPC:     1 return 0, status 0
> RPC:     1 release task
> RPC:       freeing buffer of size 412 at c79c7000
> RPC:     1 release request c780b000
> RPC:       wake_up_next(c79c6a04 "xprt_backlog")
> RPC:       rpc_release_client(c7920800)
> RPC:     1 freeing task
> RPC:       shutting down rpcbind client for 172.26.128.52
> RPC:       rpc_release_client(c7920800)
> RPC:       destroying UNIX authenticator c04d5950
> RPC:       destroying rpcbind client for 172.26.128.52
> RPC:       destroying transport c79c6800
> RPC:       xs_destroy xprt c79c6800
> RPC:       xs_close xprt c79c6800
> RPC:       disconnected transport c79c6800
> Root-NFS: Portmapper on server returned 2049 as nfsd port
> Looking up port of RPC 100005/1 on 172.26.128.52
> RPC:       rpcb_getport_sync(172.26.128.52, 100005, 1, 17)
> RPC:       set up xprt to 172.26.128.52 (port 111) via udp
> RPC:       created transport c793f800 with 16 slots
> RPC:       creating rpcbind client for 172.26.128.52 (xprt c793f800)
> RPC:       creating UNIX authenticator for client c79c8a00
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fa80
> RPC:     2 __rpc_execute flags=0x280
> RPC:     2 call_start rpcbind2 proc GETPORT (sync)
> RPC:     2 call_reserve (status 0)
> RPC:     2 reserved req c780b000 xid 0fe4a33c
> RPC:     2 call_reserveresult (status 0)
> RPC:     2 call_allocate (status 0)
> RPC:     2 allocated buffer of size 412 at c79c6800
> RPC:     2 call_refresh (status 0)
> RPC:     2 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:       allocating UNIX cred for uid 0 gid 0
> RPC:     2 refreshing UNIX cred c792fe80
> RPC:     2 call_refreshresult (status 0)
> RPC:     2 call_bind (status 0)
> RPC:     2 call_connect xprt c793f800 is not connected
> RPC:     2 xprt_connect xprt c793f800 is not connected
> RPC:     2 xprt_cwnd_limited cong = 0 cwnd = 256
> RPC:     2 sleep_on(queue "xprt_pending" time 4294894234)
> RPC:     2 added to queue c793f9ac "xprt_pending"
> RPC:     2 setting alarm for 5000 ms
> RPC:       xs_connect scheduled xprt c793f800
> RPC:     2 sync task going to sleep
> RPC:       unx_free_cred c792fb00
> RPC:       xs_bind4 0.0.0.0:0: ok (0)
> RPC:       worker connecting xprt c793f800 via udp to 172.26.128.52 (port 111)
> RPC:     2 __rpc_wake_up_task (now 4294894243)
> RPC:     2 disabling timer
> RPC:     2 removed from queue c793f9ac "xprt_pending"
> RPC:       __rpc_wake_up_task done
> RPC:     2 sync task resuming
> RPC:     2 xprt_connect_status: connection established
> RPC:     2 call_connect_status (status 0)
> RPC:     2 call_transmit (status 0)
> RPC:     2 xprt_prepare_transmit
> RPC:     2 rpc_xdr_encode (status 0)
> RPC:     2 marshaling UNIX cred c792fe80
> RPC:     2 using AUTH_UNIX cred c792fe80 to wrap rpc data
> RPC:     2 encoding PMAP_GETPORT call (100005, 1, 17, 0)
> RPC:     2 xprt_transmit(84)
> RPC:       xs_udp_send_request(84) = 84
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 256, now 512
> RPC:     2 xid 0fe4a33c complete (28 bytes received)
> RPC:     2 xmit complete
> RPC:       wake_up_next(c793f954 "xprt_resend")
> RPC:       wake_up_next(c793f8fc "xprt_sending")
> RPC:     2 call_status (status 28)
> RPC:     2 call_decode (status 28)
> RPC:     2 validating UNIX cred c792fe80
> RPC:     2 using AUTH_UNIX cred c792fe80 to unwrap rpc data
> RPC:     2 PMAP_GETPORT result: 37346
> RPC:     2 call_decode result 0
> RPC:     2 return 0, status 0
> RPC:     2 release task
> RPC:       freeing buffer of size 412 at c79c6800
> RPC:     2 release request c780b000
> RPC:       wake_up_next(c793fa04 "xprt_backlog")
> RPC:       rpc_release_client(c79c8a00)
> RPC:     2 freeing task
> RPC:       shutting down rpcbind client for 172.26.128.52
> RPC:       rpc_release_client(c79c8a00)
> RPC:       destroying UNIX authenticator c04d5950
> RPC:       destroying rpcbind client for 172.26.128.52
> RPC:       destroying transport c793f800
> RPC:       xs_destroy xprt c793f800
> RPC:       xs_close xprt c793f800
> RPC:       disconnected transport c793f800
> Root-NFS: mountd port is 37346
> NFS: sending MNT request for server:/srv/nfs/root0
> RPC:       set up xprt to 172.26.128.52 (port 37346) via udp
> RPC:       created transport c79c6800 with 16 slots
> RPC:       creating mount client for 172.26.128.52 (xprt c79c6800)
> RPC:       creating UNIX authenticator for client c79c8a00
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fb00
> RPC:     3 __rpc_execute flags=0x680
> RPC:     3 call_start mount1 proc NULL (sync)
> RPC:     3 call_reserve (status 0)
> RPC:     3 reserved req c780b000 xid e265f825
> RPC:     3 call_reserveresult (status 0)
> RPC:     3 call_allocate (status 0)
> RPC:     3 allocated buffer of size 392 at c7940000
> RPC:     3 call_refresh (status 0)
> RPC:     3 holding NULL cred c04d591c
> RPC:     3 refreshing NULL cred c04d591c
> RPC:     3 call_refreshresult (status 0)
> RPC:     3 call_bind (status 0)
> RPC:     3 call_connect xprt c79c6800 is not connected
> RPC:     3 xprt_connect xprt c79c6800 is not connected
> RPC:     3 xprt_cwnd_limited cong = 0 cwnd = 256
> RPC:     3 sleep_on(queue "xprt_pending" time 4294894305)
> RPC:     3 added to queue c79c69ac "xprt_pending"
> RPC:     3 setting alarm for 5000 ms
> RPC:       xs_connect scheduled xprt c79c6800
> RPC:     3 sync task going to sleep
> RPC:       unx_free_cred c792fe80
> RPC:       xs_bind4 0.0.0.0:672: ok (0)
> RPC:       worker connecting xprt c79c6800 via udp to 172.26.128.52 (port 37346)
> RPC:     3 __rpc_wake_up_task (now 4294894313)
> RPC:     3 disabling timer
> RPC:     3 removed from queue c79c69ac "xprt_pending"
> RPC:       __rpc_wake_up_task done
> RPC:     3 sync task resuming
> RPC:     3 xprt_connect_status: connection established
> RPC:     3 call_connect_status (status 0)
> RPC:     3 call_transmit (status 0)
> RPC:     3 xprt_prepare_transmit
> RPC:     3 rpc_xdr_encode (status 0)
> RPC:     3 marshaling NULL cred c04d591c
> RPC:     3 using AUTH_NULL cred c04d591c to wrap rpc data
> RPC:     3 xprt_transmit(40)
> RPC:       xs_udp_send_request(40) = 40
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 256, now 512
> RPC:     3 xid e265f825 complete (24 bytes received)
> RPC:     3 xmit complete
> RPC:       wake_up_next(c79c6954 "xprt_resend")
> RPC:       wake_up_next(c79c68fc "xprt_sending")
> RPC:     3 call_status (status 24)
> RPC:     3 call_decode (status 24)
> RPC:     3 validating NULL cred c04d591c
> RPC:     3 using AUTH_NULL cred c04d591c to unwrap rpc data
> RPC:     3 call_decode result 0
> RPC:     3 return 0, status 0
> RPC:     3 release task
> RPC:       freeing buffer of size 392 at c7940000
> RPC:     3 release request c780b000
> RPC:       wake_up_next(c79c6a04 "xprt_backlog")
> RPC:       rpc_release_client(c79c8a00)
> RPC:     3 freeing task
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fb00
> RPC:     4 __rpc_execute flags=0x280
> RPC:     4 call_start mount1 proc MOUNT (sync)
> RPC:     4 call_reserve (status 0)
> RPC:     4 reserved req c780b000 xid e265f826
> RPC:     4 call_reserveresult (status 0)
> RPC:     4 call_allocate (status 0)
> RPC:     4 allocated buffer of size 1456 at c7940000
> RPC:     4 call_refresh (status 0)
> RPC:     4 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:       allocating UNIX cred for uid 0 gid 0
> RPC:     4 refreshing UNIX cred c792fe80
> RPC:     4 call_refreshresult (status 0)
> RPC:     4 call_bind (status 0)
> RPC:     4 call_connect xprt c79c6800 is connected
> RPC:     4 call_transmit (status 0)
> RPC:     4 xprt_prepare_transmit
> RPC:     4 xprt_cwnd_limited cong = 0 cwnd = 512
> RPC:     4 rpc_xdr_encode (status 0)
> RPC:     4 marshaling UNIX cred c792fe80
> RPC:     4 using AUTH_UNIX cred c792fe80 to wrap rpc data
> RPC:     4 xprt_transmit(88)
> RPC:       xs_udp_send_request(88) = 88
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 512, now 512
> RPC:     4 xid e265f826 complete (60 bytes received)
> RPC:     4 xmit complete
> RPC:       wake_up_next(c79c6954 "xprt_resend")
> RPC:       wake_up_next(c79c68fc "xprt_sending")
> RPC:     4 call_status (status 60)
> RPC:     4 call_decode (status 60)
> RPC:     4 validating UNIX cred c792fe80
> RPC:     4 using AUTH_UNIX cred c792fe80 to unwrap rpc data
> RPC:     4 call_decode result 0
> RPC:     4 return 0, status 0
> RPC:     4 release task
> RPC:       freeing buffer of size 1456 at c7940000
> RPC:     4 release request c780b000
> RPC:       wake_up_next(c79c6a04 "xprt_backlog")
> RPC:       rpc_release_client(c79c8a00)
> RPC:     4 freeing task
> RPC:       shutting down mount client for 172.26.128.52
> RPC:       rpc_release_client(c79c8a00)
> RPC:       destroying UNIX authenticator c04d5950
> RPC:       destroying mount client for 172.26.128.52
> RPC:       destroying transport c79c6800
> RPC:       xs_destroy xprt c79c6800
> RPC:       xs_close xprt c79c6800
> RPC:       disconnected transport c79c6800
> NFS: MNT request succeeded
> RPC:       looking up machine cred
> RPC:       allocated machine cred c7927300 for uid 0 gid 0
> RPC:       set up xprt to 172.26.128.52 (port 2049) via udp
> RPC:       created transport c7940000 with 16 slots
> RPC:       creating nfs client for 172.26.128.52 (xprt c7940000)
> RPC:       creating UNIX authenticator for client c79c8a00
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fa80
> RPC:     5 __rpc_execute flags=0x680
> RPC:     5 call_start nfs2 proc NULL (sync)
> RPC:     5 call_reserve (status 0)
> RPC:     5 reserved req c780e000 xid 0d837923
> RPC:     5 call_reserveresult (status 0)
> RPC:     5 call_allocate (status 0)
> RPC:     5 allocated buffer of size 392 at c79c6800
> RPC:     5 call_refresh (status 0)
> RPC:     5 holding NULL cred c04d591c
> RPC:     5 refreshing NULL cred c04d591c
> RPC:     5 call_refreshresult (status 0)
> RPC:     5 call_bind (status 0)
> RPC:     5 call_connect xprt c7940000 is not connected
> RPC:     5 xprt_connect xprt c7940000 is not connected
> RPC:     5 xprt_cwnd_limited cong = 0 cwnd = 256
> RPC:     5 sleep_on(queue "xprt_pending" time 4294894412)
> RPC:     5 added to queue c79401ac "xprt_pending"
> RPC:     5 setting alarm for 1100 ms
> RPC:       xs_connect scheduled xprt c7940000
> RPC:     5 sync task going to sleep
> RPC:       unx_free_cred c792fe80
> RPC:       xs_bind4 0.0.0.0:866: ok (0)
> RPC:       worker connecting xprt c7940000 via udp to 172.26.128.52 (port 2049)
> RPC:     5 __rpc_wake_up_task (now 4294894421)
> RPC:     5 disabling timer
> RPC:     5 removed from queue c79401ac "xprt_pending"
> RPC:       __rpc_wake_up_task done
> RPC:     5 sync task resuming
> RPC:     5 xprt_connect_status: connection established
> RPC:     5 call_connect_status (status 0)
> RPC:     5 call_transmit (status 0)
> RPC:     5 xprt_prepare_transmit
> RPC:     5 rpc_xdr_encode (status 0)
> RPC:     5 marshaling NULL cred c04d591c
> RPC:     5 using AUTH_NULL cred c04d591c to wrap rpc data
> RPC:     5 xprt_transmit(40)
> RPC:       xs_udp_send_request(40) = 40
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 256, now 512
> RPC:     5 xid 0d837923 complete (24 bytes received)
> RPC:     5 xmit complete
> RPC:       wake_up_next(c7940154 "xprt_resend")
> RPC:       wake_up_next(c79400fc "xprt_sending")
> RPC:     5 call_status (status 24)
> RPC:     5 call_decode (status 24)
> RPC:     5 validating NULL cred c04d591c
> RPC:     5 using AUTH_NULL cred c04d591c to unwrap rpc data
> RPC:     5 call_decode result 0
> RPC:     5 return 0, status 0
> RPC:     5 release task
> RPC:       freeing buffer of size 392 at c79c6800
> RPC:     5 release request c780e000
> RPC:       wake_up_next(c7940204 "xprt_backlog")
> RPC:       rpc_release_client(c79c8a00)
> RPC:     5 freeing task
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fa80
> RPC:     6 __rpc_execute flags=0x80
> RPC:     6 call_start nfs2 proc STATFS (sync)
> RPC:     6 call_reserve (status 0)
> RPC:     6 reserved req c780e000 xid 0d837924
> RPC:     6 call_reserveresult (status 0)
> RPC:     6 call_allocate (status 0)
> RPC:     6 allocated buffer of size 448 at c79d2800
> RPC:     6 call_refresh (status 0)
> RPC:     6 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:       allocating UNIX cred for uid 0 gid 0
> RPC:     6 refreshing UNIX cred c792fe80
> RPC:     6 call_refreshresult (status 0)
> RPC:     6 call_bind (status 0)
> RPC:     6 call_connect xprt c7940000 is connected
> RPC:     6 call_transmit (status 0)
> RPC:     6 xprt_prepare_transmit
> RPC:     6 xprt_cwnd_limited cong = 0 cwnd = 512
> RPC:     6 rpc_xdr_encode (status 0)
> RPC:     6 marshaling UNIX cred c792fe80
> RPC:     6 using AUTH_UNIX cred c792fe80 to wrap rpc data
> RPC:     6 xprt_transmit(100)
> RPC:       xs_udp_send_request(100) = 100
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 512, now 512
> RPC:     6 xid 0d837924 complete (48 bytes received)
> RPC:     6 xmit complete
> RPC:       wake_up_next(c7940154 "xprt_resend")
> RPC:       wake_up_next(c79400fc "xprt_sending")
> RPC:     6 call_status (status 48)
> RPC:     6 call_decode (status 48)
> RPC:     6 validating UNIX cred c792fe80
> RPC:     6 using AUTH_UNIX cred c792fe80 to unwrap rpc data
> RPC:     6 call_decode result 0
> RPC:     6 return 0, status 0
> RPC:     6 release task
> RPC:       freeing buffer of size 448 at c79d2800
> RPC:     6 release request c780e000
> RPC:       wake_up_next(c7940204 "xprt_backlog")
> RPC:       rpc_release_client(c79c8b00)
> RPC:     6 freeing task
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fa80
> RPC:     7 __rpc_execute flags=0x80
> RPC:     7 call_start nfs2 proc GETATTR (sync)
> RPC:     7 call_reserve (status 0)
> RPC:     7 reserved req c780e000 xid 0d837925
> RPC:     7 call_reserveresult (status 0)
> RPC:     7 call_allocate (status 0)
> RPC:     7 allocated buffer of size 496 at c79d2800
> RPC:     7 call_refresh (status 0)
> RPC:     7 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:     7 refreshing UNIX cred c792fe80
> RPC:     7 call_refreshresult (status 0)
> RPC:     7 call_bind (status 0)
> RPC:     7 call_connect xprt c7940000 is connected
> RPC:     7 call_transmit (status 0)
> RPC:     7 xprt_prepare_transmit
> RPC:     7 xprt_cwnd_limited cong = 0 cwnd = 512
> RPC:     7 rpc_xdr_encode (status 0)
> RPC:     7 marshaling UNIX cred c792fe80
> RPC:     7 using AUTH_UNIX cred c792fe80 to wrap rpc data
> RPC:     7 xprt_transmit(100)
> RPC:       xs_udp_send_request(100) = 100
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 512, now 512
> RPC:     7 xid 0d837925 complete (96 bytes received)
> RPC:     7 xmit complete
> RPC:       wake_up_next(c7940154 "xprt_resend")
> RPC:       wake_up_next(c79400fc "xprt_sending")
> RPC:     7 call_status (status 96)
> RPC:     7 call_decode (status 96)
> RPC:     7 validating UNIX cred c792fe80
> RPC:     7 using AUTH_UNIX cred c792fe80 to unwrap rpc data
> RPC:     7 call_decode result 0
> RPC:     7 return 0, status 0
> RPC:     7 release task
> RPC:       freeing buffer of size 496 at c79d2800
> RPC:     7 release request c780e000
> RPC:       wake_up_next(c7940204 "xprt_backlog")
> RPC:       rpc_release_client(c79c8b00)
> RPC:     7 freeing task
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fa80
> RPC:     8 __rpc_execute flags=0x80
> RPC:     8 call_start nfs2 proc GETATTR (sync)
> RPC:     8 call_reserve (status 0)
> RPC:     8 reserved req c780e000 xid 0d837926
> RPC:     8 call_reserveresult (status 0)
> RPC:     8 call_allocate (status 0)
> RPC:     8 allocated buffer of size 496 at c79d2800
> RPC:     8 call_refresh (status 0)
> RPC:     8 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:     8 refreshing UNIX cred c792fe80
> RPC:     8 call_refreshresult (status 0)
> RPC:     8 call_bind (status 0)
> RPC:     8 call_connect xprt c7940000 is connected
> RPC:     8 call_transmit (status 0)
> RPC:     8 xprt_prepare_transmit
> RPC:     8 xprt_cwnd_limited cong = 0 cwnd = 512
> RPC:     8 rpc_xdr_encode (status 0)
> RPC:     8 marshaling UNIX cred c792fe80
> RPC:     8 using AUTH_UNIX cred c792fe80 to wrap rpc data
> RPC:     8 xprt_transmit(100)
> RPC:       xs_udp_send_request(100) = 100
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 512, now 512
> RPC:     8 xid 0d837926 complete (96 bytes received)
> RPC:     8 xmit complete
> RPC:       wake_up_next(c7940154 "xprt_resend")
> RPC:       wake_up_next(c79400fc "xprt_sending")
> RPC:     8 call_status (status 96)
> RPC:     8 call_decode (status 96)
> RPC:     8 validating UNIX cred c792fe80
> RPC:     8 using AUTH_UNIX cred c792fe80 to unwrap rpc data
> RPC:     8 call_decode result 0
> RPC:     8 return 0, status 0
> RPC:     8 release task
> RPC:       freeing buffer of size 496 at c79d2800
> RPC:     8 release request c780e000
> RPC:       wake_up_next(c7940204 "xprt_backlog")
> RPC:       rpc_release_client(c79c8b00)
> RPC:     8 freeing task
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fa80
> RPC:     9 __rpc_execute flags=0x80
> RPC:     9 call_start nfs2 proc STATFS (sync)
> RPC:     9 call_reserve (status 0)
> RPC:     9 reserved req c780e000 xid 0d837927
> RPC:     9 call_reserveresult (status 0)
> RPC:     9 call_allocate (status 0)
> RPC:     9 allocated buffer of size 448 at c7943000
> RPC:     9 call_refresh (status 0)
> RPC:     9 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:     9 refreshing UNIX cred c792fe80
> RPC:     9 call_refreshresult (status 0)
> RPC:     9 call_bind (status 0)
> RPC:     9 call_connect xprt c7940000 is connected
> RPC:     9 call_transmit (status 0)
> RPC:     9 xprt_prepare_transmit
> RPC:     9 xprt_cwnd_limited cong = 0 cwnd = 512
> RPC:     9 rpc_xdr_encode (status 0)
> RPC:     9 marshaling UNIX cred c792fe80
> RPC:     9 using AUTH_UNIX cred c792fe80 to wrap rpc data
> RPC:     9 xprt_transmit(100)
> RPC:       xs_udp_send_request(100) = 100
> RPC:       xs_udp_data_ready...
> RPC:       cong 256, cwnd was 512, now 512
> RPC:     9 xid 0d837927 complete (48 bytes received)
> RPC:     9 xmit complete
> RPC:       wake_up_next(c7940154 "xprt_resend")
> RPC:       wake_up_next(c79400fc "xprt_sending")
> RPC:     9 call_status (status 48)
> RPC:     9 call_decode (status 48)
> RPC:     9 validating UNIX cred c792fe80
> RPC:     9 using AUTH_UNIX cred c792fe80 to unwrap rpc data
> RPC:     9 call_decode result 0
> RPC:     9 return 0, status 0
> RPC:     9 release task
> RPC:       freeing buffer of size 448 at c7943000
> RPC:     9 release request c780e000
> RPC:       wake_up_next(c7940204 "xprt_backlog")
> RPC:       rpc_release_client(c79c8b00)
> RPC:     9 freeing task
> VFS: Mounted root (nfs filesystem) on device 0:12.
> Freeing unused kernel memory: 192k init
> 
> ********** bad (56463e50d1fc3f070492434cea6303b35ea000de) **********
> Using MPC831x RDB machine description
> Linux version 2.6.36-rc3+ (bdowning@scatha) (gcc version 4.4.2 (crosstool-NG-hg_default@1733_02db017f4fe1) ) #30 Wed Feb 9 13:20:18 CST 2011
> bootconsole [udbg0] enabled
> setup_arch: bootmem
> mpc831x_rdb_setup_arch()
> Found FSL PCI host bridge at 0x00000000e0008500. Firmware bus number: 0->0
> PCI host bridge /sleep-nexus/pci@e0008500 (primary) ranges:
> MEM 0x0000000090000000..0x000000009fffffff -> 0x0000000090000000 
> MEM 0x0000000080000000..0x000000008fffffff -> 0x0000000080000000 Prefetch
>  IO 0x00000000e2000000..0x00000000e20fffff -> 0x0000000000000000
> arch: exit
> Zone PFN ranges:
>  DMA      0x00000000 -> 0x00008000
>  Normal   empty
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>    0: 0x00000000 -> 0x00008000
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
> Kernel command line: nfsroot=172.26.128.52:/srv/nfs/root0 ip=172.26.130.10:172.26.128.52:172.26.128.1:255.255.240.0:ppc10:eth1:off root=/dev/nfs rw console=ttyS0,115200 nfsrootdebug
> PID hash table entries: 512 (order: -1, 2048 bytes)
> Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
> Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
> Memory: 124812k/131072k available (4768k kernel code, 6260k reserved, 216k data, 101k bss, 192k init)
> Kernel virtual memory layout:
>  * 0xfffdf000..0xfffff000  : fixmap
>  * 0xfdefb000..0xfe000000  : early ioremap
>  * 0xc9000000..0xfdefb000  : vmalloc & ioremap
> SLUB: Genslabs=13, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
> NR_IRQS:512
> IPIC (128 IRQ sources) at c9000700
> clocksource: timebase mult[6000002] shift[22] registered
> pid_max: default: 32768 minimum: 301
> Mount-cache hash table entries: 512
> NET: Registered protocol family 16
> 
> PCI: Probing PCI hardware
> bio: create slab <bio-0> at 0
> vgaarb: loaded
> SCSI subsystem initialized
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Switching to clocksource timebase
> NET: Registered protocol family 2
> IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
> TCP established hash table entries: 4096 (order: 3, 32768 bytes)
> TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
> TCP: Hash tables configured (established 4096 bind 4096)
> TCP reno registered
> UDP hash table entries: 256 (order: 0, 4096 bytes)
> UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
> NET: Registered protocol family 1
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> msgmni has been set to 243
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
> console [ttyS0] enabled, bootconsole disabled
> console [ttyS0] enabled, bootconsole disabled
> serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
> brd: module loaded
> loop: module loaded
> fe000000.flash: Found 1 x16 devices at 0x0 in 16-bit bank. Manufacturer ID 0x000001 Chip ID 0x001001
> Amd/Fujitsu Extended Query Table at 0x0040
>  Amd/Fujitsu Extended Query version 1.3.
> fe000000.flash: Swapping erase regions for top-boot CFI table.
> number of CFI chips: 1
> cmdlinepart partition parsing not available
> RedBoot partition parsing not available
> of:fsl-elbc e0005000.localbus: read_byte beyond end of buffer
> of:fsl-elbc e0005000.localbus: read_byte beyond end of buffer
> of:fsl-elbc e0005000.localbus: read_byte beyond end of buffer
> NAND device: Manufacturer ID: 0xec, Chip ID: 0x75 (Samsung NAND 32MiB 3,3V 8-bit)
> cmdlinepart partition parsing not available
> RedBoot partition parsing not available
> Creating 3 MTD partitions on "e2800000.flash":
> 0x000000000000-0x000000100000 : "u-boot"
> 0x000000100000-0x000000400000 : "kernel"
> 0x000000400000-0x000002000000 : "fs"
> eLBC NAND device at 0xe2800000, bank 1
> Fixed MDIO Bus: probed
> of:fsl-gianfar e0024000.ethernet: enabled errata workarounds, flags: 0x7
> eth0: Gianfar Ethernet Controller Version 1.2, 08:00:3e:03:01:a0
> eth0: Running with NAPI enabled
> eth0: RX BD ring size for Q[0]: 256
> eth0: TX BD ring size for Q[0]: 256
> of:fsl-gianfar e0025000.ethernet: enabled errata workarounds, flags: 0x7
> eth1: Gianfar Ethernet Controller Version 1.2, 08:00:3e:03:01:a1
> eth1: Running with NAPI enabled
> eth1: RX BD ring size for Q[0]: 256
> eth1: TX BD ring size for Q[0]: 256
> Freescale PowerQUICC MII Bus: probed
> Freescale PowerQUICC MII Bus: probed
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> fsl-ehci fsl-ehci.0: Freescale On-Chip EHCI Host Controller
> fsl-ehci fsl-ehci.0: new USB bus registered, assigned bus number 1
> fsl-ehci fsl-ehci.0: irq 38, io base 0xe0023000
> fsl-ehci fsl-ehci.0: USB 2.0 started, EHCI 1.00
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 1 port detected
> i2c /dev entries driver
> of:mpc-i2c e0003000.i2c: timeout 1000000 us
> rtc-ds1307 0-0068: rtc core: registered ds1339 as rtc0
> of:mpc-i2c e0003100.i2c: timeout 1000000 us
> alg: No test for authenc(hmac(sha1),cbc(aes)) (authenc-hmac-sha1-cbc-aes-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha1-cbc-aes-talitos
> alg: No test for authenc(hmac(sha1),cbc(des3_ede)) (authenc-hmac-sha1-cbc-3des-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha1-cbc-3des-talitos
> alg: No test for authenc(hmac(sha256),cbc(aes)) (authenc-hmac-sha256-cbc-aes-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha256-cbc-aes-talitos
> alg: No test for authenc(hmac(sha256),cbc(des3_ede)) (authenc-hmac-sha256-cbc-3des-talitos)
> of:talitos e0030000.crypto: authenc-hmac-sha256-cbc-3des-talitos
> alg: No test for authenc(hmac(md5),cbc(aes)) (authenc-hmac-md5-cbc-aes-talitos)
> of:talitos e0030000.crypto: authenc-hmac-md5-cbc-aes-talitos
> alg: No test for authenc(hmac(md5),cbc(des3_ede)) (authenc-hmac-md5-cbc-3des-talitos)
> of:talitos e0030000.crypto: authenc-hmac-md5-cbc-3des-talitos
> of:talitos e0030000.crypto: cbc-aes-talitos
> of:talitos e0030000.crypto: cbc-3des-talitos
> of:talitos e0030000.crypto: md5-talitos
> of:talitos e0030000.crypto: sha1-talitos
> of:talitos e0030000.crypto: sha224-talitos
> of:talitos e0030000.crypto: sha256-talitos
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> TCP cubic registered
> NET: Registered protocol family 10
> IPv6 over IPv4 tunneling driver
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> Registering the dns_resolver key type
> rtc-ds1307 0-0068: setting system clock to 2000-01-06 16:45:22 UTC (947177122)
> ADDRCONF(NETDEV_UP): eth1: link is not ready
> IP-Config: Complete:
>     device=eth1, addr=172.26.130.10, mask=255.255.240.0, gw=172.26.128.1,
>     host=ppc10, domain=, nis-domain=(none),
>     bootserver=172.26.128.52, rootserver=172.26.128.52, rootpath=
> Root-NFS: nfsroot=/srv/nfs/root0
> NFS: nfs mount opts='nolock,addr=172.26.128.52'
> NFS:   parsing nfs mount option 'nolock'
> NFS:   parsing nfs mount option 'addr=172.26.128.52'
> NFS: MNTPATH: '/srv/nfs/root0'
> NFS: sending MNT request for 172.26.128.52:/srv/nfs/root0
> RPC:       set up xprt to 172.26.128.52 (autobind) via tcp
> RPC:       created transport c79c6800 with 16 slots
> RPC:       creating mount client for 172.26.128.52 (xprt c79c6800)
> RPC:       creating UNIX authenticator for client c7920800
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fb00
> RPC:     1 __rpc_execute flags=0x680
> RPC:     1 call_start mount3 proc NULL (sync)
> RPC:     1 call_reserve (status 0)
> RPC:     1 reserved req c780e000 xid fd74e0cd
> RPC:     1 call_reserveresult (status 0)
> RPC:     1 call_allocate (status 0)
> RPC:     1 allocated buffer of size 392 at c79c7000
> RPC:     1 call_refresh (status 0)
> RPC:     1 holding NULL cred c04d591c
> RPC:     1 refreshing NULL cred c04d591c
> RPC:     1 call_refreshresult (status 0)
> RPC:     1 call_bind (status 0)
> RPC:     1 rpcb_getport_async(172.26.128.52, 100005, 3, 6)
> RPC:     1 sleep_on(queue "xprt_binding" time 4294892879)
> RPC:     1 added to queue c79c68a4 "xprt_binding"
> RPC:     1 setting alarm for 60000 ms
> RPC:     1 rpcb_getport_async: trying rpcbind version 2
> RPC:       set up xprt to 172.26.128.52 (port 111) via tcp
> RPC:       created transport c79c7800 with 16 slots
> RPC:       creating rpcbind client for 172.26.128.52 (xprt c79c7800)
> RPC:       creating UNIX authenticator for client c7920900
> RPC:       new task initialized, procpid 1
> RPC:       allocated task c792fb80
> RPC:       rpc_release_client(c7920900)
> RPC:     1 sync task going to sleep
> RPC:     2 __rpc_execute flags=0x681
> RPC:     2 call_start rpcbind2 proc GETPORT (async)
> RPC:     2 call_reserve (status 0)
> RPC:     2 reserved req c780f000 xid 5741830a
> RPC:     2 call_reserveresult (status 0)
> RPC:     2 call_allocate (status 0)
> RPC:     2 allocated buffer of size 412 at c79c8000
> RPC:     2 call_refresh (status 0)
> RPC:     2 looking up UNIX cred
> RPC:       looking up UNIX cred
> RPC:       allocating UNIX cred for uid 0 gid 0
> RPC:     2 refreshing UNIX cred c792f980
> RPC:     2 call_refreshresult (status 0)
> RPC:     2 call_bind (status 0)
> RPC:     2 call_connect xprt c79c7800 is not connected
> RPC:     2 xprt_connect xprt c79c7800 is not connected
> RPC:     2 sleep_on(queue "xprt_pending" time 4294892908)
> RPC:     2 added to queue c79c79ac "xprt_pending"
> RPC:     2 setting alarm for 60000 ms
> RPC:       xs_connect scheduled xprt c79c7800
> RPC:       xs_bind4 0.0.0.0:0: ok (0)
> RPC:       worker connecting xprt c79c7800 via tcp to 172.26.128.52 (port 111)
> RPC:       c79c7800 connect status 115 connected 0 sock state 2
> PHY: mdio@e0024520:04 - Link is Up - 1000/Full
> ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
> RPC:       xs_error_report client c79c7800...
> RPC:       error 113
> RPC:     2 __rpc_wake_up_task (now 4294893667)
> RPC:     2 disabling timer
> RPC:     2 removed from queue c79c79ac "xprt_pending"
> RPC:       __rpc_wake_up_task done
> RPC:       xs_tcp_state_change client c79c7800...
> RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> RPC:       disconnected transport c79c7800
> RPC:     2 __rpc_execute flags=0x681
> RPC:     2 xprt_connect_status: retrying
> RPC:     2 call_connect_status (status -11)
> RPC:     2 call_transmit (status 0)
> RPC:     2 xprt_prepare_transmit
> RPC:     2 rpc_xdr_encode (status 0)
> RPC:     2 marshaling UNIX cred c792f980
> RPC:     2 using AUTH_UNIX cred c792f980 to wrap rpc data
> RPC:     2 encoding PMAP_GETPORT call (100005, 3, 6, 0)
> RPC:     2 xprt_transmit(88)
> RPC:       xs_tcp_send_request(88) = -113
> RPC:       sendmsg returned unrecognized error 113
> RPC:       xs_tcp_state_change client c79c7800...
> RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> RPC:       disconnected transport c79c7800
> RPC:       wake_up_next(c79c7954 "xprt_resend")
> RPC:       wake_up_next(c79c78fc "xprt_sending")
> RPC:       setting port for xprt c79c6800 to 0
> RPC:     2 rpcb_getport_done(status -113, port 0)
> RPC:     2 return 0, status -113
> RPC:     2 release task
> RPC:       freeing buffer of size 412 at c79c8000
> RPC:     2 release request c780f000
> RPC:       wake_up_next(c79c7a04 "xprt_backlog")
> RPC:       rpc_release_client(c7920900)
> RPC:       destroying rpcbind client for 172.26.128.52
> RPC:       destroying transport c79c7800
> RPC:       xs_destroy xprt c79c7800
> RPC:       xs_close xprt c79c7800
> RPC:       disconnected transport c79c7800
> RPC:     2 freeing task
> RPC:     1 __rpc_wake_up_task (now 4294893704)
> RPC:     1 disabling timer
> RPC:     1 removed from queue c79c68a4 "xprt_binding"
> RPC:       __rpc_wake_up_task done
> RPC:     1 sync task resuming
> RPC:     1 remote rpcbind unreachable: -113
> RPC:     1 return 0, status -113
> RPC:     1 release task
> RPC:       freeing buffer of size 392 at c79c7000
> RPC:     1 release request c780e000
> RPC:       wake_up_next(c79c6a04 "xprt_backlog")
> RPC:       rpc_release_client(c7920800)
> RPC:     1 freeing task
> RPC:       shutting down mount client for 172.26.128.52
> RPC:       rpc_release_client(c7920800)
> RPC:       destroying UNIX authenticator c04d5950
> RPC:       destroying mount client for 172.26.128.52
> RPC:       destroying transport c79c6800
> RPC:       xs_destroy xprt c79c6800
> RPC:       xs_close xprt c79c6800
> RPC:       disconnected transport c79c6800
> NFS: failed to create MNT RPC client, status=-113
> NFS: unable to mount server 172.26.128.52, error -113
> VFS: Unable to mount root fs via NFS, trying floppy.
> RPC:       unx_free_cred c792f980
> VFS: Cannot open root device "nfs" or unknown-block(2,0)
> Please append a correct "root=" boot option; here are the available partitions:
> 1f00            8192 mtdblock0 (driver?)
> 1f01            1024 mtdblock1 (driver?)
> 1f02            3072 mtdblock2 (driver?)
> 1f03           28672 mtdblock3 (driver?)
> Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)
> Call Trace:
> [c7827ed0] [c0008988] show_stack+0x70/0x1bc (unreliable)
> [c7827f10] [c03a9dd8] panic+0xb8/0x1e8
> [c7827f60] [c0478e38] mount_block_root+0x1a4/0x268
> [c7827fb0] [c0478fb8] mount_root+0xbc/0xd4
> [c7827fd0] [c0479174] prepare_namespace+0x1a4/0x1e8
> [c7827fe0] [c0478270] kernel_init+0x150/0x170
> [c7827ff0] [c0010378] kernel_thread+0x4c/0x68
> Rebooting in 180 seconds..
> 
> -bcd

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




