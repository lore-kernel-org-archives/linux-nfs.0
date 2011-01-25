Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41462 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab1AYSE4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 13:04:56 -0500
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D3EBA54.4020308@st.com>
Date: Tue, 25 Jan 2011 13:04:21 -0500
Cc: Armando VISCONTI <armando.visconti@st.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>, netdev@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, amitgoel <amit.goel@st.com>
Message-Id: <EFFBD485-8B7E-44D1-A8D2-61E73BF42DF9@oracle.com>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com> <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com> <4D3EBA54.4020308@st.com>
To: deepaksi <deepak.sikri@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

See analysis in line.

On Jan 25, 2011, at 6:56 AM, deepaksi wrote:

> Hi All,
> 
> Please find more debug information on the issue. The log below is related to the kernel debug information.
> 
> 1. Kernel Debug Information log : ( The relevant portions are marked in bold )
> 
> [    2.980000] stmmac: Rx Checksum Offload Engine supported
> [    3.980000]  ** phydev->state 4 
> [    4.000000] IP-Config: Complete:                                                                                        /* Ethernet device open print */
> [    4.000000]      device=eth0, addr=192.168.1.10, mask=255.255.255.0, gw=192.168.1.1,
> [    4.010000]      host=192.168.1.10, domain=, nis-domain=(none),
> [    4.010000]      bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
> [    4.020000] Root-NFS: nfsroot=/opt/STM/STLinux-2.4/devkit/armv7/target
> [    4.030000] NFS: nfs mount opts='nolock,addr=192.168.1.1'
> [    4.030000] NFS:   parsing nfs mount option 'nolock'
> [    4.040000] NFS:   parsing nfs mount option 'addr=192.168.1.1'
> [    4.040000] NFS: MNTPATH: '/opt/STM/STLinux-2.4/devkit/armv7/target'
> [    4.050000] NFS: sending MNT request for 192.168.1.1:/opt/STM/STLinux-2.4/devkit/armv7/target
> [    4.060000] Calling rpc_create
> [    4.060000] RPC:       set up xprt to 192.168.1.1 (autobind) via tcp
> [    4.070000] RPC:       created transport cf894000 with 16 slots
> [    4.080000] xprt_create_transport: RPC:       created transport cf894000 with 16 slots
> [    4.080000] RPC:       creating mount client for 192.168.1.1 (xprt cf894000)
> [    4.090000] RPC:       creating UNIX authenticator for client cfa90800
> [    4.100000] Calling rpc_ping
> [    4.100000] RPC:       new task initialized, procpid 1
> [    4.100000] RPC:       allocated task cfa11980
> [    4.110000] RPC:     1 __rpc_execute flags=0x680
> [    4.110000] RPC:     1 call_start mount3 proc NULL (sync)

The first RPC request is a MNT protocol request to determine the NFS file handle for the export to be mounted.

> [    4.120000] RPC:     1 call_reserve (status 0)
> [    4.120000] RPC:     1 reserved req cfb80000 xid f68b1f23
> [    4.130000] RPC:     1 call_reserveresult (status 0)
> [    4.130000] RPC:     1 call_refresh (status 0)
> [    4.140000] RPC:     1 holding NULL cred c0492798
> [    4.140000] RPC:     1 refreshing NULL cred c0492798
> [    4.150000] RPC:     1 call_refreshresult (status 0)
> [    4.150000] RPC:     1 call_allocate (status 0)
> [    4.160000] RPC:     1 allocated buffer of size 92 at cf894800
> [    4.160000] RPC:     1 call_bind (status 0)
> [    4.170000] RPC:     1 rpcb_getport_async(192.168.1.1, 100005, 3, 6)
> [    4.170000] RPC:     1 sleep_on(queue "xprt_binding" time 4294937713)
> [    4.180000] RPC:     1 added to queue cf8940a4 "xprt_binding"
> [    4.190000] RPC:     1 setting alarm for 60000 ms
> [    4.190000] RPC:     1 rpcb_getport_async: trying rpcbind version 2
> [    4.200000] Calling rpc_create
> [    4.200000] RPC:       set up xprt to 192.168.1.1 (port 111) via tcp
> [    4.210000] RPC:       created transport cf895000 with 16 slots
> [    4.210000] xprt_create_transport: RPC:       created transport cf895000 with 16 slots
> [    4.220000] RPC:       creating rpcbind client for 192.168.1.1 (xprt cf895000)
> [    4.230000] RPC:       creating UNIX authenticator for client cfa90a00
> [    4.230000] rpc_create returns 0xcfa90a00
> [    4.240000] RPC:       new task initialized, procpid 1
> [    4.240000] RPC:       allocated task cfa11a00
> [    4.250000] RPC:       rpc_release_client(cfa90a00)
> [    4.250000] RPC:     1 sync task going to sleep
> [    4.260000] RPC:     2 __rpc_execute flags=0x681
> [    4.260000] RPC:     2 call_start rpcbind2 proc GETPORT (async)

This is a child RPC request, which is an rpcbind query to discover the port where the NFS server's MNT service resides.  This is necessary before a transport socket for the MNT request can be set up.  The MNT request is put to sleep while the rpcbind query proceeds.

> [    4.270000] RPC:     2 call_reserve (status 0)
> [    4.270000] RPC:     2 reserved req cfb81000 xid 59bc347d
> [    4.280000] RPC:     2 call_reserveresult (status 0)
> [    4.280000] RPC:     2 call_refresh (status 0)
> [    4.290000] RPC:     2 looking up UNIX cred
> [    4.290000] RPC:       looking up UNIX cred
> [    4.300000] RPC:       allocating UNIX cred for uid 0 gid 0
> [    4.300000] RPC:     2 refreshing UNIX cred cfa11a80
> [    4.310000] RPC:     2 call_refreshresult (status 0)
> [    4.310000] RPC:     2 call_allocate (status 0)
> [    4.320000] RPC:     2 allocated buffer of size 412 at cf895800
> [    4.320000] RPC:     2 call_bind (status 0)
> [    4.330000] RPC:     2 call_connect xprt cf895000 is not connected
> [    4.330000] RPC:     2 xprt_connect xprt cf895000 is not connected
> [    4.340000] RPC:     2 sleep_on(queue "xprt_pending" time 4294937730)
> [    4.340000] RPC:     2 added to queue cf8951dc "xprt_pending"
> [    4.350000] RPC:     2 setting alarm for 60000 ms
> [    4.360000] RPC:       xs_connect scheduled xprt cf895000
> [    4.360000] RPC:       xs_bind 0.0.0.0:0: ok (0)
> [    4.370000] RPC:       worker connecting xprt cf895000 via tcp to 192.168.1.1 (port 111)
> [    4.370000] RPC:       cf895000 connect status 115 connected 0 sock state 2

A transport socket is set up for the rpcbind query, which connects to port 111 on the server.  The RPC client puts the rpcbind query request to sleep waiting for the transport socket connection to complete.  This is done in a worker thread.

> [    6.980000] PHY: 0:05 - Link is Up - 1000/Full            /* As soon as network link is up, post auto negotiation, we get the error below ( Unable to reach icmp)*/
> [    7.380000] RPC:       xs_error_report client cf895000...    /* The ethernet phy on our board typically takes 3 seconds for auto negotiation process */
> [    7.380000] RPC:       error 113                                 /* In case the frequency of the phy state machine (in phy framework) polling is increased from HZ to HZ/10, we do not face this issue*/

After three seconds, the initial socket connection attempt is getting EHOSTUNREACH.  The transport socket's error report callback wakes up RPC task 2 with status -EAGAIN.

"we do not face this issue" -- in that case, does the connection attempt succeed?  Do you have debugging output for that case?

> [    7.390000] RPC:     2 __rpc_wake_up_task (now 4294938035)
> [    7.390000] RPC:     2 disabling timer
> [    7.390000] RPC:     2 removed from queue cf8951dc "xprt_pending"
> [    7.400000] RPC:       __rpc_wake_up_task done
> [    7.410000] RPC:       xs_tcp_state_change client cf895000...
> [    7.410000] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> [    7.420000] RPC:       disconnected transport cf895000

The transport is marked disconnected here by the transport socket's state change callback.  The socket state is TCP_CLOSE.  xprt_disconnect_done() wakes up any pending tasks with -EAGAIN (a second wake up).

> [    7.420000] RPC:     2 __rpc_execute flags=0x681
> [    7.420000] ************* skb->protocol = 608**************
> [    7.420000] ************* skb->protocol = 8**************
> [    7.440000] RPC:     2 xprt_connect_status: retrying

Here is RPC task 2 waking up in xprt_connect_status with status -EAGAIN.

> [    7.440000] RPC:     2 call_connect_status (status -11)
> [    7.450000] RPC:     2 call_transmit (status 0)
> [    7.450000] RPC:     2 xprt_prepare_transmit
> [    7.460000] RPC:     2 rpc_xdr_encode (status 0)
> [    7.460000] RPC:     2 marshaling UNIX cred cfa11a80
> [    7.470000] RPC:     2 using AUTH_UNIX cred cfa11a80 to wrap rpc data
> [    7.470000] RPC:     2 encoding PMAP_GETPORT call (100005, 3, 6, 0)
> [    7.480000] RPC:     2 xprt_transmit(92)
> [    7.480000] RPC:       xs_tcp_send_request(92) = -113

> [    7.490000] RPC:       sendmsg returned unrecognized error 113

I don't see a fresh connection attempt here.  The RPC client appears to be attempting to send on an unconnected transport socket.  The next send request is getting EHOSTUNREACH again, and thus the rpcbind query fails.

I thought there used to be code in xprt_prepare_transmit() to reconnect if needed, but I no longer find it here.  call_connect_status() handles -EAGAIN by advancing the state machine to call_transmit(), so the FSM does expect call_transmit() and its children to deal with an unconnected transport.

Possibly relevant commits: 2a491991, c8485e4d

In any event, the outcome is probably correct: if the RPC client gets EHOSTUNREACH while trying to connect or send, then it will fail this RPC request.

> [    7.490000] RPC:       xs_tcp_state_change client cf895000...
> [    7.500000] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> [    7.510000] RPC:       disconnected transport cf895000
> [    7.510000] RPC:       wake_up_next(cf895174 "xprt_resend")
> [    7.520000] RPC:       wake_up_next(cf89510c "xprt_sending")
> [    7.520000] RPC:       setting port for xprt cf894000 to 0
> [    7.530000] RPC:     2 rpcb_getport_done(status -113, port 0)
> [    7.530000] RPC:     2 return 0, status -113
> [    7.540000] RPC:     2 release task
> [    7.540000] RPC:       freeing buffer of size 412 at cf895800
> [    7.550000] RPC:     2 release request cfb81000
> [    7.550000] RPC:       wake_up_next(cf895244 "xprt_backlog")
> [    7.560000] RPC:       rpc_release_client(cfa90a00)
> [    7.560000] RPC:       destroying rpcbind client for 192.168.1.1
> [    7.570000] RPC:       destroying transport cf895000
> [    7.570000] RPC:       xs_destroy xprt cf895000
> [    7.580000] RPC:       xs_close xprt cf895000
> [    7.580000] RPC:       disconnected transport cf895000
> [    7.590000] RPC:     2 freeing task
> [    7.590000] RPC:     1 __rpc_wake_up_task (now 4294938055)
> [    7.600000] RPC:     1 disabling timer
> [    7.600000] RPC:     1 removed from queue cf8940a4 "xprt_binding"
> [    7.610000] RPC:       __rpc_wake_up_task done
> [    7.610000] RPC:     1 sync task resuming
> [    7.620000] RPC:     1 remote rpcbind unreachable: -113
> [    7.620000] RPC:     1 return 0, status -113
> [    7.630000] RPC:     1 release task
> [    7.630000] RPC:       freeing buffer of size 92 at cf894800
> [    7.630000] RPC:     1 release request cfb80000
> [    7.640000] RPC:       wake_up_next(cf894244 "xprt_backlog")
> [    7.640000] RPC:       rpc_release_client(cfa90800)
> [    7.650000] RPC:     1 freeing task
> [    7.650000] rpc_ping returned -113
> [    7.660000] Calling rpc_ping failed

Note that the RPC ping is for RPC task 1, the MNT request, not for the rpcbind query (RPC task 2).

An RPC ping for the MNT request can't proceed until the rpcbind query has discovered the correct server port to connect to.  The rpcbind query is done first, then, and is what is failing to connect.  So RPC ping is a red herring here -- the RPC client doesn't get far enough to send a MNT NULL request.

  [ ... remaining dump contents snipped ... ]

> We have made following observations
> 1. It seems that the time taken by phy auto negotiation process is long and as soon as the link gets up rpc ping request is getting timed out and we receive "Unable to reach ICMP" error. The time out error is same even if you do not connect a network cable and do a nfs boot.
> 2. We tried to modify the rate at which the work queue is scheduled in the phy framework. instead of scheduling every HZ ( 1 sec), we modified it to HZ/10. We did not received the error. This probably reduced the margin of the phy framework informing the kernel that the link is up.
> 3. We tried to use another network card and did a nfs boot. The only relevant difference we could find was the time of auto negotiation.

Can you post a similar debugging dump of a root mount that succeeds using a different network card?

> Are there some changes in the kernel framework w.r.t rpc ping time out ? This problem was not there in previous kernels.

There have been changes in the RPC socket code around how it manages recovery from failed attempts to connect.  We also have new logic now in the RPC client that causes RPC ping to fail immediately if a host can't be reached.

Thanks for your efforts so far.  It would be helpful if you could bisect to determine which commit(s) introduced this RPC client behavior (or any related changes to your network driver behavior).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




