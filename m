Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm1-vm0.bullet.mail.ird.yahoo.com ([77.238.189.95]:42716 "HELO
	nm1-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752180Ab1KECOP convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 22:14:15 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>  <1320353685.18396.119.camel@lade.trondhjem.org>  <20111103211100.GA8393@umich.edu>  <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>  <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>  <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>  <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>  <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>  <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>  <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>  <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com> <1320455965.2750.9.camel@lade.trondhjem.org>
Message-ID: <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com>
Date: Sat, 5 Nov 2011 02:14:12 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <1320455965.2750.9.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

***IMPORTANT HINT***

In the test belowI've tried to ping the NFS client (cluster2) as soon as I've got the

ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
message.


And at first I've got no answers from the client. But 10-20sec later I've got pongs back.
So the NIC comes up some seconds later than the message "link becomes ready" is shown...
In the case of 'mountproto=tcp' it comes up after the kernel panic. So that's much too late.



[  126.134520] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  128.282991] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[  128.305364] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  128.326199] IP-Config: Complete:
[  128.326269]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=255.255.255.255,
[  128.326471]      host=137.226.167.242, domain=, nis-domain=(none),
[  128.326586]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[  128.327055] Root-NFS: nfsroot=/srv/nfs/cluster2,mountproto=tcp
[  128.327404] NFS: nfs mount opts='vers=2,udp,rsize=4096,wsize=4096,mountproto=tcp,nolock,addr=137.226.167.241'
[  128.327477] NFS:   parsing nfs mount option 'vers=2'
[  128.327538] NFS:   parsing nfs mount option 'udp'
[  128.327573] NFS:   parsing nfs mount option 'rsize=4096'
[  128.327623] NFS:   parsing nfs mount option 'wsize=4096'
[  128.327673] NFS:   parsing nfs mount option 'mountproto=tcp'
[  128.327728] NFS:   parsing nfs mount option 'nolock'
[  128.327774] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[  128.327838] NFS: MNTPATH: '/srv/nfs/cluster2'
[  128.327873] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[  128.327942] RPC:       set up xprt to 137.226.167.241 (autobind) via tcp
[  128.327992] RPC:       created transport fffff807fdec0800 with 128 slots
[  128.328042] RPC:       creating mount client for 137.226.167.241 (xprt fffff807fdec0800)
[  128.328103] RPC:       creating UNIX authenticator for client fffff807fdea0600
[  128.328168] RPC:       new task initialized, procpid 1
[  128.328213] RPC:       allocated task fffff807fe38e000
[  128.328260] RPC:     1 __rpc_execute flags=0x680
[  128.328295] RPC:     1 call_start mount1 proc NULL (sync)
[  128.328341] RPC:     1 call_reserve (status 0)
[  128.328376] RPC:     1 reserved req fffff807fdea0400 xid 39411b74
[  128.328425] RPC:       wake_up_next(fffff807fdec0978 "xprt_sending")
[  128.328474] RPC:     1 call_reserveresult (status 0)
[  128.328518] RPC:     1 call_refresh (status 0)
[  128.328551] RPC:     1 holding NULL cred 00000000008b8cf0
[  128.328597] RPC:     1 refreshing NULL cred 00000000008b8cf0
[  128.328643] RPC:     1 call_refreshresult (status 0)
[  128.328687] RPC:     1 call_allocate (status 0)
[  128.328722] RPC:     1 allocated buffer of size 96 at fffff807fdec1000
[  128.328770] RPC:     1 call_bind (status 0)
[  128.328804] RPC:     1 rpcb_getport_async(137.226.167.241, 100005, 1, 6)
[  128.328854] RPC:     1 sleep_on(queue "xprt_binding" time 4294893514)
[  128.328902] RPC:     1 added to queue fffff807fdec08c8 "xprt_binding"
[  128.328949] RPC:     1 setting alarm for 60000 ms
[  128.328986] RPC:     1 rpcb_getport_async: trying rpcbind version 2
[  128.329046] RPC:       set up xprt to 137.226.167.241 (port 111) via tcp
[  128.329096] RPC:       created transport fffff807fdec1800 with 128 slots
[  128.329146] RPC:       creating rpcbind client for 137.226.167.241 (xprt fffff807fdec1800)
[  128.329204] RPC:       creating UNIX authenticator for client fffff807fdea0c00
[  128.329262] RPC:       new task initialized, procpid 1
[  128.329306] RPC:       allocated task fffff807fe38e0e0
[  128.329358] RPC:       rpc_release_client(fffff807fdea0c00)
[  128.329406] RPC:     1 sync task going to sleep
[  128.329446] RPC:     2 __rpc_execute flags=0x681
[  128.329482] RPC:     2 call_start rpcbind2 proc GETPORT (async)
[  128.329529] RPC:     2 call_reserve (status 0)
[  128.329563] RPC:     2 reserved req fffff807fdea0a00 xid 54cf8ddb
[  128.329610] RPC:       wake_up_next(fffff807fdec1978 "xprt_sending")
[  128.329659] RPC:     2 call_reserveresult (status 0)
[  128.329703] RPC:     2 call_refresh (status 0)
[  128.329735] RPC:     2 looking up UNIX cred
[  128.329765] RPC:       looking up UNIX cred
[  128.329809] RPC:       allocating UNIX cred for uid 0 gid 0
[  128.329859] RPC:     2 refreshing UNIX cred fffff807fe37c900
[  128.329906] RPC:     2 call_refreshresult (status 0)
[  128.329950] RPC:     2 call_allocate (status 0)
[  128.329984] RPC:     2 allocated buffer of size 416 at fffff807fdec2000
[  128.330032] RPC:     2 call_bind (status 0)
[  128.330064] RPC:     2 call_connect xprt fffff807fdec1800 is not connected
[  128.330114] RPC:     2 xprt_connect xprt fffff807fdec1800 is not connected
[  128.330165] RPC:     2 sleep_on(queue "xprt_pending" time 4294893515)
[  128.330213] RPC:     2 added to queue fffff807fdec1a28 "xprt_pending"
[  128.330260] RPC:     2 setting alarm for 60000 ms
[  128.330294] RPC:       xs_connect scheduled xprt fffff807fdec1800
[  128.330453] RPC:       xs_bind 0.0.0.0:0: ok (0)
[  128.330490] RPC:       worker connecting xprt fffff807fdec1800 via tcp to 137.226.167.241 (port 111)
[  128.330650] RPC:       fffff807fdec1800 connect status 36 connected 0 sock state 2
[  131.335657] RPC:       xs_error_report client fffff807fdec1800...
[  131.335665] RPC:       error 65
[  131.335822] RPC:     2 __rpc_wake_up_task (now 4294894266)
[  131.335924] RPC:     2 disabling timer
[  131.335985] RPC:     2 removed from queue fffff807fdec1a28 "xprt_pending"
[  131.336061] RPC:       __rpc_wake_up_task done
[  131.336097] RPC:       xs_tcp_state_change client fffff807fdec1800...
[  131.336146] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[  131.336194] RPC:       disconnected transport fffff807fdec1800
[  131.336291] RPC:     2 __rpc_execute flags=0x681
[  131.336355] RPC:     2 xprt_connect_status: retrying
[  131.336399] RPC:     2 call_connect_status (status -11)
[  131.336473] RPC:     2 call_transmit (status 0)
[  131.336504] RPC:     2 xprt_prepare_transmit
[  131.336565] RPC:     2 rpc_xdr_encode (status 0)
[  131.336599] RPC:     2 marshaling UNIX cred fffff807fe37c900
[  131.336676] RPC:     2 using AUTH_UNIX cred fffff807fe37c900 to wrap rpc data
[  131.336757] RPC:     2 encoding PMAP_GETPORT call (100005, 1, 6, 0)
[  131.336805] RPC:     2 xprt_transmit(96)
[  131.336873] RPC:       xs_tcp_send_request(96) = -65
[  131.336946] RPC:       sendmsg returned unrecognized error 65
[  131.336993] RPC:       xs_tcp_state_change client fffff807fdec1800...
[  131.337071] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[  131.337146] RPC:       disconnected transport fffff807fdec1800
[  131.337195] RPC:       wake_up_next(fffff807fdec1978 "xprt_sending")
[  131.337273] RPC:       setting port for xprt fffff807fdec0800 to 0
[  131.337352] RPC:     2 rpcb_getport_done(status -65, port 0)
[  131.337398] RPC:     2 return 0, status -65
[  131.337456] RPC:     2 release task
[  131.337490] RPC:       freeing buffer of size 416 at fffff807fdec2000
[  131.337568] RPC:     2 release request fffff807fdea0a00
[  131.337642] RPC:       wake_up_next(fffff807fdec1ad8 "xprt_backlog")
[  131.337690] RPC:       rpc_release_client(fffff807fdea0c00)
[  131.337764] RPC:       destroying rpcbind client for 137.226.167.241
[  131.337841] RPC:       destroying transport fffff807fdec1800
[  131.337921] RPC:       xs_destroy xprt fffff807fdec1800
[  131.338045] RPC:       xs_close xprt fffff807fdec1800
[  131.338134] RPC:       disconnected transport fffff807fdec1800
[  131.338184] RPC:     2 freeing task
[  131.338245] RPC:     1 __rpc_wake_up_task (now 4294894266)
[  131.338317] RPC:     1 disabling timer
[  131.338348] RPC:     1 removed from queue fffff807fdec08c8 "xprt_binding"
[  131.338429] RPC:       __rpc_wake_up_task done
[  131.338443] RPC:     1 sync task resuming
[  131.338454] RPC:     1 remote rpcbind unreachable: -65
[  131.338466] RPC:     1 return 0, status -65
[  131.338473] RPC:     1 release task
[  131.338483] RPC:       freeing buffer of size 96 at fffff807fdec1000
[  131.338495] RPC:     1 release request fffff807fdea0400
[  131.338505] RPC:       wake_up_next(fffff807fdec0ad8 "xprt_backlog")
[  131.338517] RPC:       rpc_release_client(fffff807fdea0600)
[  131.338527] RPC:     1 freeing task
[  131.338537] RPC:       shutting down mount client for 137.226.167.241
[  131.338548] RPC:       rpc_release_client(fffff807fdea0600)
[  131.338559] RPC:       destroying UNIX authenticator 00000000008b8d78
[  131.338572] RPC:       destroying mount client for 137.226.167.241
[  131.338584] NFS: failed to create MNT RPC client, status=-65
[  131.338593] NFS: unable to mount server 137.226.167.241, error -65
[  131.338627] VFS: Unable to mount root fs via NFS, trying floppy.
[  131.338687] List of all partitions:
[  131.338697] No filesystem could mount root, tried: 
[  131.338713] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)
[  131.338723] Call Trace:
[  131.338752]  [00000000008c6d18] mount_block_root+0x210/0x228
[  131.338767]  [00000000008c6df4] mount_root+0xc4/0xd4
[  131.338781]  [00000000008c6f80] prepare_namespace+0x17c/0x1c0
[  131.338795]  [00000000008c6250] kernel_init+0x140/0x158
[  131.338816]  [000000000042ac68] kernel_thread+0x30/0x48
[  131.338835]  [0000000000767840] rest_init+0x18/0x74
[  131.338941] Press Stop-A (L1-A) to return to the boot prom
[  131.339844] RPC:       destroying transport fffff807fdec0800
[  131.339948] RPC:       xs_destroy xprt fffff807fdec0800
[  131.340039] RPC:       xs_close xprt fffff807fdec0800
[  131.340114] RPC:       disconnected transport fffff807fdec0800
[  138.467087] eth0: no IPv6 routers present
