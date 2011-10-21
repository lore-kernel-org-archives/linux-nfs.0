Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-1.concepts.nl ([213.197.30.124]:38344 "EHLO
	smtp-1.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab1JUUKS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2011 16:10:18 -0400
Date: Fri, 21 Oct 2011 22:10:01 +0200
From: Arno Schuring <aelschuring@hotmail.com>
To: Kevin Coffman <kwc@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: sec=krb5 mounts never return
Message-ID: <20111021221001.71628099@neminis.intra.loos.site>
In-Reply-To: <CAKnQG+d66Driv-D7fTeyh=MP4iNqpTzjXyFEiLE34E3YV2KG_g@mail.gmail.com>
References: <20111021012327.612839b5@neminis.loos.site>
	<CAKnQG+d66Driv-D7fTeyh=MP4iNqpTzjXyFEiLE34E3YV2KG_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/SKurn4=OsfkSnMu/_AT+z1w"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/SKurn4=OsfkSnMu/_AT+z1w
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Kevin,

thanks for your reply. Attached is all the information I have been able
to gather thus far (kernel and daemon logs).

Kevin Coffman (kwc@umich.edu on 2011-10-21 10:33 -0400):
> On Thu, Oct 20, 2011 at 7:23 PM, Arno Schuring
> <aelschuring@hotmail.com> wrote:
> >
> > I've been running a succesful NFS4 setup at home for a year now, but
> > incorporating krb5 security has so far proven fruitless. I believe
> > the Kerberos side of the equation is no longer causing problems; it
> > is used for user authentication too, and nfs security contexts seem
> > to work properly. As said above, the mount request for any Kerberos
> > mount gets halted somewhere in flight:
[..]
> > [600472.772226] nfsd: connect from 172.22.21.8, port=46257
> > [600472.772300] svc: svc_setup_socket created deda1a00 (inet
> > df948900) [600473.431966] svc_recv: found XPT_CLOSE
> > [600473.431982] svc: svc_delete_xprt(deda1a00)
> > [600473.432114] svc: transport deda1a00 is dead, not enqueued
> >
> 
> You should be seeing syslog messages if not, but I'll ask anyway.
> You've got rpc.gssd configured and running on the client, and if this
> is a linux server, rpc.svcgssd configured and running on the server.
> ("Configured" more or less means you've got a keytab.)  If they are
> running, what does their output look like?  (Perhaps using "-vvv" to
> get detailed output.)

In this case I'm trying with a local mount, so client==server. The gssd
logs invariably end with the following lines:
rpc.gssd[26133]: creating context with server nfs@genie.loos.site
rpc.gssd[28189]: DEBUG: serialize_krb5_ctx: lucid version!
rpc.gssd[28189]: prepare_krb5_rfc1964_buffer: serializing keys with
enctype 4 and length 8
rpc.gssd[28189]: doing downcall
[ then nothing until I kill the mount process ]

In the svcgssd logs, nothing stands out to me. It all appears proper
to the untrained eye:

rpc.svcgssd[26188]: handling null request
rpc.svcgssd[26188]: sname = nfs/genie.loos.site@LOOS.SITE
rpc.svcgssd[26188]: libnfsidmap: using (default) domain: loos.site
rpc.svcgssd[26188]: DEBUG: serialize_krb5_ctx: lucid version!
rpc.svcgssd[26188]: prepare_krb5_rfc1964_buffer: serializing keys with
enctype 4 and length 8
rpc.svcgssd[26188]: doing downcall
rpc.svcgssd[26188]: mech: krb5, hndl len: 4, ctx len 85, timeout:
1319183270 (35999 from now), clnt: nfs@genie.loos.site, uid: -1, gid:
-1, num aux grps: 0:
rpc.svcgssd[26188]: sending null reply
rpc.svcgssd[26188]: finished handling null request


Regards,
Arno
--MP_/SKurn4=OsfkSnMu/_AT+z1w
Content-Type: text/x-log
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=daemon.log

Oct 20 23:47:50 genie rpc.idmapd[26204]: New client: 80
Oct 20 23:47:50 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:47:50 genie rpc.idmapd[26204]: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt80/idmap
Oct 20 23:47:50 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:47:50 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:47:50 genie rpc.idmapd[26204]: New client: 81
Oct 20 23:47:50 genie rpc.gssd[26133]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt80)
Oct 20 23:47:50 genie rpc.gssd[26133]: handle_gssd_upcall: 'mech=krb5 uid=0 '
Oct 20 23:47:50 genie rpc.gssd[26133]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt80)
Oct 20 23:47:50 genie rpc.gssd[26133]: process_krb5_upcall: service is '<null>'
Oct 20 23:47:50 genie rpc.gssd[26133]: Full hostname for 'genie.loos.site' is 'genie.loos.site'
Oct 20 23:47:50 genie rpc.gssd[26133]: Full hostname for 'genie.loos.site' is 'genie.loos.site'
Oct 20 23:47:50 genie rpc.gssd[26133]: Key table entry not found while getting keytab entry for 'root/genie.loos.site@'
Oct 20 23:47:50 genie rpc.gssd[26133]: Success getting keytab entry for 'nfs/genie.loos.site@'
Oct 20 23:47:50 genie krb5kdc[15110]: AS_REQ (7 etypes {18 17 16 23 1 3 2}) 172.22.21.8: NEEDED_PREAUTH: nfs/genie.loos.site@LOOS.SITE for krbtgt/LOOS.SITE@LOOS.SITE, Additional pre-authentication required
Oct 20 23:47:50 genie krb5kdc[15110]: AS_REQ (7 etypes {18 17 16 23 1 3 2}) 172.22.21.8: ISSUE: authtime 1319147270, etypes {rep=1 tkt=18 ses=18}, nfs/genie.loos.site@LOOS.SITE for krbtgt/LOOS.SITE@LOOS.SITE
Oct 20 23:47:50 genie rpc.gssd[26133]: Successfully obtained machine credentials for principal 'nfs/genie.loos.site@LOOS.SITE' stored in ccache 'FILE:/tmp/krb5cc_machine_LOOS.SITE'
Oct 20 23:47:50 genie rpc.gssd[26133]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_LOOS.SITE' are good until 1319183270
Oct 20 23:47:50 genie rpc.gssd[26133]: using FILE:/tmp/krb5cc_machine_LOOS.SITE as credentials cache for machine creds
Oct 20 23:47:50 genie rpc.gssd[26133]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_LOOS.SITE
Oct 20 23:47:50 genie rpc.gssd[26133]: creating context using fsuid 0 (save_uid 0)
Oct 20 23:47:50 genie rpc.gssd[26133]: creating tcp client for server genie.loos.site
Oct 20 23:47:50 genie rpc.gssd[26133]: DEBUG: port already set to 2049
Oct 20 23:47:50 genie rpc.gssd[26133]: creating context with server nfs@genie.loos.site
Oct 20 23:47:51 genie krb5kdc[15110]: TGS_REQ (7 etypes {18 17 16 23 1 3 2}) 172.22.21.8: ISSUE: authtime 1319147270, etypes {rep=18 tkt=1 ses=1}, nfs/genie.loos.site@LOOS.SITE for nfs/genie.loos.site@LOOS.SITE
Oct 20 23:47:51 genie rpc.svcgssd[26188]: leaving poll
Oct 20 23:47:51 genie rpc.svcgssd[26188]: handling null request
Oct 20 23:47:51 genie rpc.svcgssd[26188]: sname = nfs/genie.loos.site@LOOS.SITE
Oct 20 23:47:51 genie rpc.svcgssd[26188]: libnfsidmap: using (default) domain: loos.site
Oct 20 23:47:51 genie rpc.svcgssd[26188]: libnfsidmap: loaded plugin /usr/lib/libnfsidmap/nsswitch.so for method nsswitch
Oct 20 23:47:51 genie nslcd[1259]: [625c6d] nslcd_passwd_byname(nfs/genie.loos.site): invalid user name
Oct 20 23:47:51 genie rpc.svcgssd[26188]: DEBUG: serialize_krb5_ctx: lucid version!
Oct 20 23:47:51 genie rpc.svcgssd[26188]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
Oct 20 23:47:51 genie rpc.svcgssd[26188]: doing downcall
Oct 20 23:47:51 genie rpc.svcgssd[26188]: mech: krb5, hndl len: 4, ctx len 85, timeout: 1319183270 (35999 from now), clnt: nfs@genie.loos.site, uid: -1, gid: -1, num aux grps: 0:
Oct 20 23:47:51 genie rpc.svcgssd[26188]: sending null reply
Oct 20 23:47:51 genie rpc.svcgssd[26188]: writing message: \x \x6082023206092a864886f71201020201006e8202213082021da003020105a10302010ea20703050020000000a382014d6182014930820145a003020105a10b1b094c4f4f532e53495445a221301fa003020103a11830161b036e66731b0f67656e69652e6c6f6f732e73697465a382010c30820108a003020101a103020102a281fb0481f8ce3a7a6904c0e5231523f1df46aff97f72a916f2490880b147f12630ce6e88585dafe8af3796140b7f1a95b0373c41010174ad17cbefb97d6aa1b366fcd04a172ed3a92bebcccb36e19410fc47b44fe51f4e7c3e1991ccc00198565b748848daaa8106dc93d2b3323f2a3aeda70bdc4f89033f54c3ca9739c6c7804b6951b6623649bed18968708f8649782c212d8cbbd2761f9e199c4475a1e3183cb295db24c1c538684aa9631bc535639a3f016bda9799ba2b591e70103f105ec3061f9468dbafe09b1fa4705b7530253cd602e3122effb562bd2c1cd64eb0d548015e9ebf670aeb222ba60ab9dad0f51657e9981864031c2bb1a136d3a481b63081b3a003020101a281ab0481a8a2f5bf88f8f4f98407b7b43b495e9c2c689ebe95295868187ce071a96488bd917a45925869bee752d59eae4b50e39c9de669e5e7e7f2b05d560c751fcc5655e93!
 5d8c31898b2321a692903e96d830148a3de0bd2f81f71701d1e6ff0df3e7de1f49ac3919aa392b897e07f98b41dc99cc919b504452f910a1be55180cca6a7c14f8af3def2ce12def8ca6d7bdb8b1447271d482fa6920fb02ab113c75821e54669c9ac5eb7bcf917 1319147331 0 0 \x01000000 \x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a04489223de969a87b450168fe4c6c58f461510434adf6c87786d56fb7ac9e8f1918ecba6794e146e3210dc6925629da9b6c797d7aef3211bf845e15b8226bfe69d59983efc34a626f5a1 
Oct 20 23:47:51 genie rpc.svcgssd[26188]: finished handling null request
Oct 20 23:47:51 genie rpc.svcgssd[26188]: entering poll
Oct 20 23:47:51 genie rpc.gssd[26133]: DEBUG: serialize_krb5_ctx: lucid version!
Oct 20 23:47:51 genie rpc.gssd[26133]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
Oct 20 23:47:51 genie rpc.gssd[26133]: doing downcall
Oct 20 23:47:51 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:48:18 genie rpc.idmapd[26204]: Stale client: 81
Oct 20 23:48:18 genie rpc.idmapd[26204]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt81/idmap
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt81
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:48:18 genie rpc.idmapd[26204]: Stale client: 80
Oct 20 23:48:18 genie rpc.idmapd[26204]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt80/idmap
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt7d
Oct 20 23:48:18 genie rpc.gssd[26133]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt80

--MP_/SKurn4=OsfkSnMu/_AT+z1w
Content-Type: text/x-log
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=kern.log

Oct 20 23:47:50 genie kernel: [600472.037146] --> nfs4_create_server()
Oct 20 23:47:50 genie kernel: [600472.037179] --> nfs4_init_server()
Oct 20 23:47:50 genie kernel: [600472.037193] --> nfs4_set_client()
Oct 20 23:47:50 genie kernel: [600472.037208] --> nfs_get_client(genie,v4)
Oct 20 23:47:50 genie kernel: [600472.037225] RPC:       looking up machine cred
Oct 20 23:47:50 genie kernel: [600472.037248] --> nfs_get_client() = de825e00 [new]
Oct 20 23:47:50 genie kernel: [600472.037284] RPC:       set up xprt to 172.22.21.8 (port 2049) via tcp
Oct 20 23:47:50 genie kernel: [600472.037307] RPC:       created transport c3966000 with 16 slots
Oct 20 23:47:50 genie kernel: [600472.037327] RPC:       creating nfs client for genie (xprt c3966000)
Oct 20 23:47:50 genie kernel: [600472.037823] RPC:       creating GSS authenticator for client de639900
Oct 20 23:47:50 genie kernel: [600472.040355] RPC:       rpc_release_client(de639900)
Oct 20 23:47:50 genie kernel: [600472.045656] RPC:     0 holding NULL cred bf3ecc2c
Oct 20 23:47:50 genie kernel: [600472.045685] RPC:       new task initialized, procpid 26217
Oct 20 23:47:50 genie kernel: [600472.045702] RPC:       allocated task c39f93c0
Oct 20 23:47:50 genie kernel: [600472.045718] RPC:   435 __rpc_execute flags=0x280
Oct 20 23:47:50 genie kernel: [600472.045736] RPC:   435 call_start nfs4 proc NULL (sync)
Oct 20 23:47:50 genie kernel: [600472.045752] RPC:   435 call_reserve (status 0)
Oct 20 23:47:50 genie kernel: [600472.045770] RPC:   435 reserved req d6911000 xid 664da781
Oct 20 23:47:50 genie kernel: [600472.045787] RPC:   435 call_reserveresult (status 0)
Oct 20 23:47:50 genie kernel: [600472.045803] RPC:   435 call_allocate (status 0)
Oct 20 23:47:50 genie kernel: [600472.045821] RPC:   435 allocated buffer of size 92 at dfb78800
Oct 20 23:47:50 genie kernel: [600472.045840] RPC:   435 call_bind (status 0)
Oct 20 23:47:50 genie kernel: [600472.045856] RPC:   435 call_connect xprt c3966000 is not connected
Oct 20 23:47:50 genie kernel: [600472.045875] RPC:   435 xprt_connect xprt c3966000 is not connected
Oct 20 23:47:50 genie kernel: [600472.045896] RPC:   435 sleep_on(queue "xprt_pending" time 60015056)
Oct 20 23:47:50 genie kernel: [600472.045915] RPC:   435 added to queue c39661d0 "xprt_pending"
Oct 20 23:47:50 genie kernel: [600472.045933] RPC:   435 setting alarm for 60000 ms
Oct 20 23:47:50 genie kernel: [600472.045949] RPC:       xs_connect scheduled xprt c3966000
Oct 20 23:47:50 genie kernel: [600472.045974] RPC:   435 sync task going to sleep
Oct 20 23:47:50 genie kernel: [600472.046023] RPC:       xs_bind4 0.0.0.0:935: ok (0)
Oct 20 23:47:50 genie kernel: [600472.046044] RPC:       worker connecting xprt c3966000 via tcp to 172.22.21.8 (port 2049)
Oct 20 23:47:50 genie kernel: [600472.046164] RPC:       xs_tcp_state_change client c3966000...
Oct 20 23:47:50 genie kernel: [600472.046189] RPC:       state 1 conn 0 dead 0 zapped 1 sk_shutdown 0
Oct 20 23:47:50 genie kernel: [600472.046210] RPC:   435 __rpc_wake_up_task (now 60015056)
Oct 20 23:47:50 genie kernel: [600472.046226] RPC:   435 disabling timer
Oct 20 23:47:50 genie kernel: [600472.046242] RPC:   435 removed from queue c39661d0 "xprt_pending"
Oct 20 23:47:50 genie kernel: [600472.046265] RPC:       __rpc_wake_up_task done
Oct 20 23:47:50 genie kernel: [600472.046329] svc: socket df94ba80 TCP (listen) state change 10
Oct 20 23:47:50 genie kernel: [600472.046354] svc: transport de4ace00 served by daemon c0f0b000
Oct 20 23:47:50 genie kernel: [600472.046384] RPC:       c3966000 connect status 115 connected 1 sock state 1
Oct 20 23:47:50 genie kernel: [600472.046414] svc: tcp_accept de4ace00 sock ccd38000
Oct 20 23:47:50 genie kernel: [600472.046444] nfsd: connect from 172.22.21.8, port=935
Oct 20 23:47:50 genie kernel: [600472.046461] svc: svc_setup_socket ccfd7780
Oct 20 23:47:50 genie kernel: [600472.046479] setting up TCP socket for reading
Oct 20 23:47:50 genie kernel: [600472.046497] svc: socket de825400(inet df94a880), write_space busy=1
Oct 20 23:47:50 genie kernel: [600472.046517] svc: svc_setup_socket created de825400 (inet df94a880)
Oct 20 23:47:50 genie kernel: [600472.046540] svc: transport de825400 served by daemon dee34000
Oct 20 23:47:50 genie kernel: [600472.046564] svc: transport de4ace00 served by daemon c0f0a000
Oct 20 23:47:50 genie kernel: [600472.046588] svc: transport de4ace00 busy, not enqueued
Oct 20 23:47:50 genie kernel: [600472.046607] svc: server c0f0b000 waiting for data (to = 360000)
Oct 20 23:47:50 genie kernel: [600472.046637] svc: server dee34000, pool 0, transport de825400, inuse=2
Oct 20 23:47:50 genie kernel: [600472.046659] svc: tcp_recv de825400 data 1 conn 0 close 0
Oct 20 23:47:50 genie kernel: [600472.046678] svc: socket de825400(inet df94a880), write_space busy=1
Oct 20 23:47:50 genie kernel: [600472.046696] svc: transport de825400 busy, not enqueued
Oct 20 23:47:50 genie kernel: [600472.046718] svc: socket de825400 recvfrom(de8255c4, 4) = -11
Oct 20 23:47:50 genie kernel: [600472.046735] RPC: TCP recv_record got EAGAIN
Oct 20 23:47:50 genie kernel: [600472.046749] svc: got len=-11
Oct 20 23:47:50 genie kernel: [600472.046763] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:50 genie kernel: [600472.046790] svc: tcp_accept de4ace00 sock ccd38000
Oct 20 23:47:50 genie kernel: [600472.046820] svc: server c0f0a000 waiting for data (to = 360000)
Oct 20 23:47:50 genie kernel: [600472.046846] RPC:   435 sync task resuming
Oct 20 23:47:50 genie kernel: [600472.046862] RPC:   435 xprt_connect_status: retrying
Oct 20 23:47:50 genie kernel: [600472.046880] RPC:   435 call_connect_status (status -11)
Oct 20 23:47:50 genie kernel: [600472.046897] RPC:   435 call_transmit (status 0)
Oct 20 23:47:50 genie kernel: [600472.046912] RPC:   435 xprt_prepare_transmit
Oct 20 23:47:50 genie kernel: [600472.046928] RPC:   435 rpc_xdr_encode (status 0)
Oct 20 23:47:50 genie kernel: [600472.046946] RPC:   435 marshaling NULL cred bf3ecc2c
Oct 20 23:47:50 genie kernel: [600472.046965] RPC:   435 using AUTH_NULL cred bf3ecc2c to wrap rpc data
Oct 20 23:47:50 genie kernel: [600472.046984] RPC:   435 xprt_transmit(44)
Oct 20 23:47:50 genie kernel: [600472.047044] svc: socket df94a880 TCP data ready (svsk de825400)
Oct 20 23:47:50 genie kernel: [600472.047069] svc: transport de825400 served by daemon c0f0a000
Oct 20 23:47:50 genie kernel: [600472.047128] svc: server c0f0a000, pool 0, transport de825400, inuse=2
Oct 20 23:47:50 genie kernel: [600472.047153] svc: tcp_recv de825400 data 1 conn 0 close 0
Oct 20 23:47:50 genie kernel: [600472.047177] svc: socket de825400 recvfrom(de8255c8, 0) = 4
Oct 20 23:47:50 genie kernel: [600472.047195] svc: TCP record, 40 bytes
Oct 20 23:47:50 genie kernel: [600472.047215] svc: socket de825400 recvfrom(dec71008, 4088) = 8
Oct 20 23:47:50 genie kernel: [600472.047238] svc: socket de825400 recvfrom(dec71028, 4056) = 32
Oct 20 23:47:50 genie kernel: [600472.047256] svc: TCP complete record (40 bytes)
Oct 20 23:47:50 genie kernel: [600472.047274] svc: transport de825400 served by daemon dee34000
Oct 20 23:47:50 genie kernel: [600472.047295] svc: got len=40
Oct 20 23:47:50 genie kernel: [600472.047312] svc: svc_authenticate (0)
Oct 20 23:47:50 genie kernel: [600472.047333] svc: transport de825400 busy, not enqueued
Oct 20 23:47:50 genie kernel: [600472.047349] svc: calling dispatcher
Oct 20 23:47:50 genie kernel: [600472.047405] svc: socket de825400 sendto([df3fc000 28... ], 28) = 28 (addr 172.22.21.8, port=935)
Oct 20 23:47:50 genie kernel: [600472.047436] svc: transport de825400 busy, not enqueued
Oct 20 23:47:50 genie kernel: [600472.047455] svc: server c0f0a000 waiting for data (to = 360000)
Oct 20 23:47:50 genie kernel: [600472.047486] svc: server dee34000, pool 0, transport de825400, inuse=2
Oct 20 23:47:50 genie kernel: [600472.047508] svc: tcp_recv de825400 data 1 conn 0 close 0
Oct 20 23:47:50 genie kernel: [600472.047530] svc: socket de825400 recvfrom(de8255c4, 4) = -11
Oct 20 23:47:50 genie kernel: [600472.047546] RPC: TCP recv_record got EAGAIN
Oct 20 23:47:50 genie kernel: [600472.047561] svc: got len=-11
Oct 20 23:47:50 genie kernel: [600472.047574] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:50 genie kernel: [600472.047902] RPC:       xs_tcp_data_ready...
Oct 20 23:47:50 genie kernel: [600472.047926] RPC:       xs_tcp_data_recv started
Oct 20 23:47:50 genie kernel: [600472.047944] RPC:       reading TCP record fragment of length 24
Oct 20 23:47:50 genie kernel: [600472.047961] RPC:       reading XID (4 bytes)
Oct 20 23:47:50 genie kernel: [600472.047977] RPC:       reading request with XID 664da781
Oct 20 23:47:50 genie kernel: [600472.047994] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 20 23:47:50 genie kernel: [600472.048010] RPC:       read reply XID 664da781
Oct 20 23:47:50 genie kernel: [600472.048027] RPC:       XID 664da781 read 16 bytes
Oct 20 23:47:50 genie kernel: [600472.048045] RPC:       xprt = c3966000, tcp_copied = 24, tcp_offset = 24, tcp_reclen = 24
Oct 20 23:47:50 genie kernel: [600472.048070] RPC:   435 xid 664da781 complete (24 bytes received)
Oct 20 23:47:50 genie kernel: [600472.048088] RPC:       xs_tcp_data_recv done
Oct 20 23:47:50 genie kernel: [600472.048148] RPC:       xs_tcp_send_request(44) = 44
Oct 20 23:47:50 genie kernel: [600472.048167] RPC:   435 xmit complete
Oct 20 23:47:50 genie kernel: [600472.048185] RPC:       wake_up_next(c396616c "xprt_resend")
Oct 20 23:47:50 genie kernel: [600472.048203] RPC:       wake_up_next(c3966108 "xprt_sending")
Oct 20 23:47:50 genie kernel: [600472.048223] RPC:   435 call_status (status 24)
Oct 20 23:47:50 genie kernel: [600472.048238] RPC:   435 call_decode (status 24)
Oct 20 23:47:50 genie kernel: [600472.048256] RPC:   435 validating NULL cred bf3ecc2c
Oct 20 23:47:50 genie kernel: [600472.048274] RPC:   435 using AUTH_NULL cred bf3ecc2c to unwrap rpc data
Oct 20 23:47:50 genie kernel: [600472.048293] RPC:   435 call_decode result 0
Oct 20 23:47:50 genie kernel: [600472.048308] RPC:   435 return 0, status 0
Oct 20 23:47:50 genie kernel: [600472.048322] RPC:   435 release task
Oct 20 23:47:50 genie kernel: [600472.048340] RPC:       freeing buffer of size 92 at dfb78800
Oct 20 23:47:50 genie kernel: [600472.048359] RPC:   435 release request d6911000
Oct 20 23:47:50 genie kernel: [600472.048375] RPC:       wake_up_next(c3966234 "xprt_backlog")
Oct 20 23:47:50 genie kernel: [600472.048394] RPC:   435 releasing NULL cred bf3ecc2c
Oct 20 23:47:50 genie kernel: [600472.048410] RPC:       rpc_release_client(de639900)
Oct 20 23:47:50 genie kernel: [600472.048426] RPC:   435 freeing task
Oct 20 23:47:50 genie kernel: [600472.051474] svc: initialising pool 0 for NFSv4 callback
Oct 20 23:47:50 genie kernel: [600472.051508] RPC:       unregistering [1073741824, 1, ''] with local rpcbind
Oct 20 23:47:50 genie kernel: [600472.051549] RPC:       set up xprt to 127.0.0.1 (port 111) via udp
Oct 20 23:47:50 genie kernel: [600472.051574] RPC:       created transport def54000 with 16 slots
Oct 20 23:47:50 genie kernel: [600472.051593] RPC:       creating rpcbind client for localhost (xprt def54000)
Oct 20 23:47:50 genie kernel: [600472.051620] RPC:       creating UNIX authenticator for client de639e00
Oct 20 23:47:50 genie kernel: [600472.051644] RPC:     0 looking up UNIX cred
Oct 20 23:47:50 genie kernel: [600472.051658] RPC:       looking up UNIX cred
Oct 20 23:47:50 genie kernel: [600472.051675] RPC:       new task initialized, procpid 26217
Oct 20 23:47:50 genie kernel: [600472.051692] RPC:       allocated task c39f93c0
Oct 20 23:47:50 genie kernel: [600472.051707] RPC:   436 __rpc_execute flags=0x280
Oct 20 23:47:50 genie kernel: [600472.051725] RPC:   436 call_start rpcbind4 proc UNSET (sync)
Oct 20 23:47:50 genie kernel: [600472.051743] RPC:   436 call_reserve (status 0)
Oct 20 23:47:50 genie kernel: [600472.051760] RPC:   436 reserved req d6913000 xid 25fd7bd4
Oct 20 23:47:50 genie kernel: [600472.051777] RPC:   436 call_reserveresult (status 0)
Oct 20 23:47:50 genie kernel: [600472.051794] RPC:   436 call_allocate (status 0)
Oct 20 23:47:50 genie kernel: [600472.051811] RPC:   436 allocated buffer of size 484 at def55800
Oct 20 23:47:50 genie kernel: [600472.051829] RPC:   436 call_bind (status 0)
Oct 20 23:47:50 genie kernel: [600472.051845] RPC:   436 call_connect xprt def54000 is not connected
Oct 20 23:47:50 genie kernel: [600472.051864] RPC:   436 xprt_connect xprt def54000 is not connected
Oct 20 23:47:50 genie kernel: [600472.051883] RPC:   436 xprt_cwnd_limited cong = 0 cwnd = 256
Oct 20 23:47:50 genie kernel: [600472.051903] RPC:   436 sleep_on(queue "xprt_pending" time 60015056)
Oct 20 23:47:50 genie kernel: [600472.051923] RPC:   436 added to queue def541d0 "xprt_pending"
Oct 20 23:47:50 genie kernel: [600472.051940] RPC:   436 setting alarm for 5000 ms
Oct 20 23:47:50 genie kernel: [600472.051957] RPC:       xs_connect scheduled xprt def54000
Oct 20 23:47:50 genie kernel: [600472.051983] RPC:   436 sync task going to sleep
Oct 20 23:47:50 genie kernel: [600472.052028] RPC:       xs_bind4 0.0.0.0:843: ok (0)
Oct 20 23:47:50 genie kernel: [600472.052048] RPC:       worker connecting xprt def54000 via udp to 127.0.0.1 (port 111)
Oct 20 23:47:50 genie kernel: [600472.052074] RPC:   436 __rpc_wake_up_task (now 60015056)
Oct 20 23:47:50 genie kernel: [600472.052091] RPC:   436 disabling timer
Oct 20 23:47:50 genie kernel: [600472.052106] RPC:   436 removed from queue def541d0 "xprt_pending"
Oct 20 23:47:50 genie kernel: [600472.052128] RPC:       __rpc_wake_up_task done
Oct 20 23:47:50 genie kernel: [600472.052148] RPC:   436 sync task resuming
Oct 20 23:47:50 genie kernel: [600472.052164] RPC:   436 xprt_connect_status: connection established
Oct 20 23:47:50 genie kernel: [600472.052183] RPC:   436 call_connect_status (status 0)
Oct 20 23:47:50 genie kernel: [600472.052199] RPC:   436 call_transmit (status 0)
Oct 20 23:47:50 genie kernel: [600472.052214] RPC:   436 xprt_prepare_transmit
Oct 20 23:47:50 genie kernel: [600472.052230] RPC:   436 rpc_xdr_encode (status 0)
Oct 20 23:47:50 genie kernel: [600472.052248] RPC:   436 marshaling UNIX cred deee8280
Oct 20 23:47:50 genie kernel: [600472.052267] RPC:   436 using AUTH_UNIX cred deee8280 to wrap rpc data
Oct 20 23:47:50 genie kernel: [600472.052289] RPC:   436 encoding RPCB_UNSET call (1073741824, 1, '', '')
Oct 20 23:47:50 genie kernel: [600472.052310] RPC:   436 xprt_transmit(96)
Oct 20 23:47:50 genie kernel: [600472.052464] RPC:       xs_udp_send_request(96) = 96
Oct 20 23:47:50 genie kernel: [600472.052487] RPC:   436 xmit complete
Oct 20 23:47:50 genie kernel: [600472.052503] RPC:   436 sleep_on(queue "xprt_pending" time 60015057)
Oct 20 23:47:50 genie kernel: [600472.052524] RPC:   436 added to queue def541d0 "xprt_pending"
Oct 20 23:47:50 genie kernel: [600472.052541] RPC:   436 setting alarm for 5000 ms
Oct 20 23:47:50 genie kernel: [600472.052559] RPC:   436 sync task going to sleep
Oct 20 23:47:50 genie kernel: [600472.054876] RPC:       xs_udp_data_ready...
Oct 20 23:47:50 genie kernel: [600472.054908] RPC:       cong 256, cwnd was 256, now 512
Oct 20 23:47:50 genie kernel: [600472.054928] RPC:       wake_up_next(def5416c "xprt_resend")
Oct 20 23:47:50 genie kernel: [600472.054946] RPC:       wake_up_next(def54108 "xprt_sending")
Oct 20 23:47:50 genie kernel: [600472.054966] RPC:   436 xid 25fd7bd4 complete (28 bytes received)
Oct 20 23:47:50 genie kernel: [600472.054984] RPC:   436 __rpc_wake_up_task (now 60015057)
Oct 20 23:47:50 genie kernel: [600472.055000] RPC:   436 disabling timer
Oct 20 23:47:50 genie kernel: [600472.055016] RPC:   436 removed from queue def541d0 "xprt_pending"
Oct 20 23:47:50 genie kernel: [600472.055042] RPC:       __rpc_wake_up_task done
Oct 20 23:47:50 genie kernel: [600472.065171] RPC:   436 sync task resuming
Oct 20 23:47:50 genie kernel: [600472.065199] RPC:   436 call_status (status 28)
Oct 20 23:47:50 genie kernel: [600472.065215] RPC:   436 call_decode (status 28)
Oct 20 23:47:50 genie kernel: [600472.065234] RPC:   436 validating UNIX cred deee8280
Oct 20 23:47:50 genie kernel: [600472.065252] RPC:   436 using AUTH_UNIX cred deee8280 to unwrap rpc data
Oct 20 23:47:50 genie kernel: [600472.065273] RPC:   436 RPCB_UNSET call succeeded
Oct 20 23:47:50 genie kernel: [600472.065289] RPC:   436 call_decode result 0
Oct 20 23:47:50 genie kernel: [600472.065304] RPC:   436 return 0, status 0
Oct 20 23:47:50 genie kernel: [600472.065318] RPC:   436 release task
Oct 20 23:47:50 genie kernel: [600472.065338] RPC:       freeing buffer of size 484 at def55800
Oct 20 23:47:50 genie kernel: [600472.065358] RPC:   436 release request d6913000
Oct 20 23:47:50 genie kernel: [600472.065373] RPC:       wake_up_next(def54234 "xprt_backlog")
Oct 20 23:47:50 genie kernel: [600472.065393] RPC:   436 releasing UNIX cred deee8280
Oct 20 23:47:50 genie kernel: [600472.065409] RPC:       rpc_release_client(de639e00)
Oct 20 23:47:50 genie kernel: [600472.065426] RPC:   436 freeing task
Oct 20 23:47:50 genie kernel: [600472.065440] RPC:       shutting down rpcbind client for localhost
Oct 20 23:47:50 genie kernel: [600472.065458] RPC:       rpc_release_client(de639e00)
Oct 20 23:47:50 genie kernel: [600472.065474] RPC:       destroying rpcbind client for localhost
Oct 20 23:47:50 genie kernel: [600472.065494] RPC:       destroying transport def54000
Oct 20 23:47:50 genie kernel: [600472.065511] RPC:       xs_destroy xprt def54000
Oct 20 23:47:50 genie kernel: [600472.065528] RPC:       xs_close xprt def54000
Oct 20 23:47:50 genie kernel: [600472.065557] RPC:       disconnected transport def54000
Oct 20 23:47:50 genie kernel: [600472.065580] svc: __svc_unregister(NFSv4 callbackv1), error 0
Oct 20 23:47:50 genie kernel: [600472.065601] svc: creating transport tcp[20490]
Oct 20 23:47:50 genie kernel: [600472.065622] svc: svc_create_socket(NFSv4 callback, 6, 0.0.0.0, port=20490)
Oct 20 23:47:50 genie kernel: [600472.065680] svc: svc_setup_socket ccfd7d80
Oct 20 23:47:50 genie kernel: [600472.065699] setting up TCP socket for listening
Oct 20 23:47:50 genie kernel: [600472.065716] svc: svc_setup_socket created df930e00 (inet df949680)
Oct 20 23:47:50 genie kernel: [600472.065736] NFS: Callback listener port = 20490 (af 2)
Oct 20 23:47:50 genie kernel: [600472.065752] svc: creating transport tcp[20490]
Oct 20 23:47:50 genie kernel: [600472.065772] svc: svc_create_socket(NFSv4 callback, 6, 0000:0000:0000:0000:0000:0000:0000:0000, port=20490)
Oct 20 23:47:50 genie kernel: [600472.065834] svc: svc_setup_socket df47a180
Oct 20 23:47:50 genie kernel: [600472.065852] setting up TCP socket for listening
Oct 20 23:47:50 genie kernel: [600472.065869] svc: svc_setup_socket created df930a00 (inet d4b88000)
Oct 20 23:47:50 genie kernel: [600472.065888] NFS: Callback listener port = 20490 (af 10)
Oct 20 23:47:50 genie kernel: [600472.068027] svc: svc_destroy(NFSv4 callback, 2)
Oct 20 23:47:50 genie kernel: [600472.068056] <-- nfs4_set_client() = 0 [new de825e00]
Oct 20 23:47:50 genie kernel: [600472.068232] <-- nfs4_init_server() = 0
Oct 20 23:47:50 genie kernel: [600472.068266] --> nfs4_path_walk(,,/)
Oct 20 23:47:50 genie kernel: [600472.068684] RPC:     0 looking up RPCSEC_GSS cred
Oct 20 23:47:50 genie kernel: [600472.068707] RPC:       looking up RPCSEC_GSS cred
Oct 20 23:47:50 genie kernel: [600472.068724] RPC:       gss_create_cred for uid 0, flavor 390003
Oct 20 23:47:50 genie kernel: [600472.068744] RPC:       gss_upcall for uid 0
Oct 20 23:47:50 genie kernel: [600472.068764] RPC:       gss_find_upcall found nothing
Oct 20 23:47:50 genie kernel: [600472.068792] svc: server d6913000 waiting for data (to = 2147483647)
Oct 20 23:47:50 genie kernel: [600472.772055] svc: socket df94ba80 TCP (listen) state change 10
Oct 20 23:47:50 genie kernel: [600472.772096] svc: transport de4ace00 served by daemon dee34000
Oct 20 23:47:50 genie kernel: [600472.772170] svc: tcp_accept de4ace00 sock ccd38000
Oct 20 23:47:50 genie kernel: [600472.772203] nfsd: connect from unprivileged port: 172.22.21.8, port=46257
Oct 20 23:47:50 genie kernel: [600472.772226] nfsd: connect from 172.22.21.8, port=46257
Oct 20 23:47:50 genie kernel: [600472.772243] svc: svc_setup_socket ccc2b600
Oct 20 23:47:50 genie kernel: [600472.772261] setting up TCP socket for reading
Oct 20 23:47:50 genie kernel: [600472.772280] svc: socket deda1a00(inet df948900), write_space busy=1
Oct 20 23:47:50 genie kernel: [600472.772300] svc: svc_setup_socket created deda1a00 (inet df948900)
Oct 20 23:47:50 genie kernel: [600472.772322] svc: transport deda1a00 served by daemon c0f0a000
Oct 20 23:47:50 genie kernel: [600472.772411] svc: transport de4ace00 served by daemon c0f0b000
Oct 20 23:47:50 genie kernel: [600472.772438] svc: transport de4ace00 busy, not enqueued
Oct 20 23:47:50 genie kernel: [600472.772458] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:50 genie kernel: [600472.772915] svc: server c0f0a000, pool 0, transport deda1a00, inuse=2
Oct 20 23:47:50 genie kernel: [600472.772942] svc: tcp_recv deda1a00 data 1 conn 0 close 0
Oct 20 23:47:50 genie kernel: [600472.772962] svc: socket deda1a00(inet df948900), write_space busy=1
Oct 20 23:47:50 genie kernel: [600472.772981] svc: transport deda1a00 busy, not enqueued
Oct 20 23:47:50 genie kernel: [600472.773004] svc: socket deda1a00 recvfrom(deda1bc4, 4) = -11
Oct 20 23:47:50 genie kernel: [600472.773020] RPC: TCP recv_record got EAGAIN
Oct 20 23:47:50 genie kernel: [600472.773035] svc: got len=-11
Oct 20 23:47:50 genie kernel: [600472.773050] svc: server c0f0a000 waiting for data (to = 360000)
Oct 20 23:47:50 genie kernel: [600472.773080] svc: tcp_accept de4ace00 sock ccd38000
Oct 20 23:47:50 genie kernel: [600472.773110] svc: server c0f0b000 waiting for data (to = 360000)
Oct 20 23:47:51 genie kernel: [600473.384481] svc: socket df948900 TCP data ready (svsk deda1a00)
Oct 20 23:47:51 genie kernel: [600473.384524] svc: transport deda1a00 served by daemon dee34000
Oct 20 23:47:51 genie kernel: [600473.384644] svc: server dee34000, pool 0, transport deda1a00, inuse=2
Oct 20 23:47:51 genie kernel: [600473.384670] svc: tcp_recv deda1a00 data 1 conn 0 close 0
Oct 20 23:47:51 genie kernel: [600473.384696] svc: socket deda1a00 recvfrom(deda1bc8, 0) = 4
Oct 20 23:47:51 genie kernel: [600473.384713] svc: TCP record, 632 bytes
Oct 20 23:47:51 genie kernel: [600473.384734] svc: socket deda1a00 recvfrom(c3953008, 4088) = 8
Oct 20 23:47:51 genie kernel: [600473.384760] svc: socket deda1a00 recvfrom(c3953278, 3464) = 624
Oct 20 23:47:51 genie kernel: [600473.384778] svc: TCP complete record (632 bytes)
Oct 20 23:47:51 genie kernel: [600473.384797] svc: transport deda1a00 served by daemon c0f0b000
Oct 20 23:47:51 genie kernel: [600473.384820] svc: got len=632
Oct 20 23:47:51 genie kernel: [600473.384837] svc: svc_authenticate (6)
Oct 20 23:47:51 genie kernel: [600473.384852] RPC:       svcauth_gss: argv->iov_len = 604
Oct 20 23:47:51 genie kernel: [600473.384918] svc: svc_process dropit
Oct 20 23:47:51 genie kernel: [600473.384935] svc: xprt deda1a00 dropped request
Oct 20 23:47:51 genie kernel: [600473.384955] svc: transport deda1a00 busy, not enqueued
Oct 20 23:47:51 genie kernel: [600473.384974] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:51 genie kernel: [600473.385008] svc: server c0f0b000, pool 0, transport deda1a00, inuse=3
Oct 20 23:47:51 genie kernel: [600473.385030] svc: tcp_recv deda1a00 data 1 conn 0 close 0
Oct 20 23:47:51 genie kernel: [600473.385092] svc: socket deda1a00 recvfrom(deda1bc4, 4) = -11
Oct 20 23:47:51 genie kernel: [600473.385112] RPC: TCP recv_record got EAGAIN
Oct 20 23:47:51 genie kernel: [600473.385127] svc: got len=-11
Oct 20 23:47:51 genie kernel: [600473.385142] svc: server c0f0b000 waiting for data (to = 360000)
Oct 20 23:47:51 genie kernel: [600473.410873] RPC:       Successfully imported new context.
Oct 20 23:47:51 genie kernel: [600473.411373] revisit queued
Oct 20 23:47:51 genie kernel: [600473.411400] svc: transport deda1a00 served by daemon c0f0b000
Oct 20 23:47:51 genie kernel: [600473.411950] svc: server c0f0b000, pool 0, transport deda1a00, inuse=2
Oct 20 23:47:51 genie kernel: [600473.411978] svc: transport deda1a00 served by daemon dee34000
Oct 20 23:47:51 genie kernel: [600473.412003] svc: got len=632
Oct 20 23:47:51 genie kernel: [600473.412021] svc: svc_authenticate (6)
Oct 20 23:47:51 genie kernel: [600473.412036] RPC:       svcauth_gss: argv->iov_len = 604
Oct 20 23:47:51 genie kernel: [600473.412074] RPC:       gss_krb5_seal
Oct 20 23:47:51 genie kernel: [600473.412134] RPC:       krb5_encrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.412165] RPC:       krb5_encrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.412298] svc: socket deda1a00 sendto([df2dd000 208... ], 208) = 208 (addr 172.22.21.8, port=46257)
Oct 20 23:47:51 genie kernel: [600473.412334] svc: transport deda1a00 busy, not enqueued
Oct 20 23:47:51 genie kernel: [600473.412467] svc: server c0f0b000 waiting for data (to = 360000)
Oct 20 23:47:51 genie kernel: [600473.412503] svc: server dee34000, pool 0, transport deda1a00, inuse=2
Oct 20 23:47:51 genie kernel: [600473.412526] svc: tcp_recv deda1a00 data 0 conn 0 close 0
Oct 20 23:47:51 genie kernel: [600473.412549] svc: socket deda1a00 recvfrom(deda1bc4, 4) = -11
Oct 20 23:47:51 genie kernel: [600473.412566] RPC: TCP recv_record got EAGAIN
Oct 20 23:47:51 genie kernel: [600473.412580] svc: got len=-11
Oct 20 23:47:51 genie kernel: [600473.412594] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:51 genie kernel: [600473.429159] RPC:       gss_find_upcall found msg deda1c00
Oct 20 23:47:51 genie kernel: [600473.429229] RPC:       Successfully imported new context.
Oct 20 23:47:51 genie kernel: [600473.429258] RPC:       gss_pipe_downcall returning 109
Oct 20 23:47:51 genie kernel: [600473.429299] RPC:       gss_create_upcall for uid 0 result 0
Oct 20 23:47:51 genie kernel: [600473.429322] RPC:       new task initialized, procpid 26217
Oct 20 23:47:51 genie kernel: [600473.429340] RPC:       allocated task c39f93c0
Oct 20 23:47:51 genie kernel: [600473.429356] RPC:   437 __rpc_execute flags=0x80
Oct 20 23:47:51 genie kernel: [600473.429374] RPC:   437 call_start nfs4 proc LOOKUP_ROOT (sync)
Oct 20 23:47:51 genie kernel: [600473.429408] RPC:   437 call_reserve (status 0)
Oct 20 23:47:51 genie kernel: [600473.429428] RPC:   437 reserved req d6911000 xid 674da781
Oct 20 23:47:51 genie kernel: [600473.429446] RPC:   437 call_reserveresult (status 0)
Oct 20 23:47:51 genie kernel: [600473.429462] RPC:   437 call_allocate (status 0)
Oct 20 23:47:51 genie kernel: [600473.429480] RPC:   437 allocated buffer of size 3712 at d6915000
Oct 20 23:47:51 genie kernel: [600473.429499] RPC:   437 call_bind (status 0)
Oct 20 23:47:51 genie kernel: [600473.429514] RPC:   437 call_connect xprt c3966000 is connected
Oct 20 23:47:51 genie kernel: [600473.429533] RPC:   437 call_transmit (status 0)
Oct 20 23:47:51 genie kernel: [600473.429548] RPC:   437 xprt_prepare_transmit
Oct 20 23:47:51 genie kernel: [600473.429564] RPC:   437 rpc_xdr_encode (status 0)
Oct 20 23:47:51 genie kernel: [600473.429581] RPC:   437 marshaling RPCSEC_GSS cred df1f9300
Oct 20 23:47:51 genie kernel: [600473.429598] RPC:   437 gss_marshal
Oct 20 23:47:51 genie kernel: [600473.429612] RPC:       gss_krb5_seal
Oct 20 23:47:51 genie kernel: [600473.429669] RPC:       krb5_encrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.429702] RPC:       krb5_encrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.429723] RPC:   437 using AUTH_GSS cred df1f9300 to wrap rpc data
Oct 20 23:47:51 genie kernel: [600473.429742] RPC:   437 gss_wrap_req
Oct 20 23:47:51 genie kernel: [600473.429756] encode_compound: tag=
Oct 20 23:47:51 genie kernel: [600473.429772] RPC:   437 gss_wrap_req returning 0
Oct 20 23:47:51 genie kernel: [600473.429788] RPC:   437 xprt_transmit(144)
Oct 20 23:47:51 genie kernel: [600473.429863] svc: socket df94a880 TCP data ready (svsk de825400)
Oct 20 23:47:51 genie kernel: [600473.429890] svc: transport de825400 served by daemon c0f0b000
Oct 20 23:47:51 genie kernel: [600473.429926] RPC:       xs_tcp_send_request(144) = 144
Oct 20 23:47:51 genie kernel: [600473.429944] RPC:   437 xmit complete
Oct 20 23:47:51 genie kernel: [600473.429961] RPC:   437 sleep_on(queue "xprt_pending" time 60015194)
Oct 20 23:47:51 genie kernel: [600473.429981] RPC:   437 added to queue c39661d0 "xprt_pending"
Oct 20 23:47:51 genie kernel: [600473.429999] RPC:   437 setting alarm for 60000 ms
Oct 20 23:47:51 genie kernel: [600473.430018] RPC:       wake_up_next(c396616c "xprt_resend")
Oct 20 23:47:51 genie kernel: [600473.430036] RPC:       wake_up_next(c3966108 "xprt_sending")
Oct 20 23:47:51 genie kernel: [600473.430054] RPC:   437 sync task going to sleep
Oct 20 23:47:51 genie kernel: [600473.430134] svc: server c0f0b000, pool 0, transport de825400, inuse=2
Oct 20 23:47:51 genie kernel: [600473.430161] svc: tcp_recv de825400 data 1 conn 0 close 0
Oct 20 23:47:51 genie kernel: [600473.430187] svc: socket de825400 recvfrom(de8255c8, 0) = 4
Oct 20 23:47:51 genie kernel: [600473.430204] svc: TCP record, 140 bytes
Oct 20 23:47:51 genie kernel: [600473.430225] svc: socket de825400 recvfrom(c39f7008, 4088) = 8
Oct 20 23:47:51 genie kernel: [600473.430249] svc: socket de825400 recvfrom(c39f708c, 3956) = 132
Oct 20 23:47:51 genie kernel: [600473.430267] svc: TCP complete record (140 bytes)
Oct 20 23:47:51 genie kernel: [600473.430286] svc: transport de825400 served by daemon dee34000
Oct 20 23:47:51 genie kernel: [600473.430309] svc: got len=140
Oct 20 23:47:51 genie kernel: [600473.430326] svc: svc_authenticate (6)
Oct 20 23:47:51 genie kernel: [600473.430341] RPC:       svcauth_gss: argv->iov_len = 112
Oct 20 23:47:51 genie kernel: [600473.430365] RPC:       krb5_read_token
Oct 20 23:47:51 genie kernel: [600473.430411] RPC:       krb5_encrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.430429] RPC:       krb5_get_seq_num:
Oct 20 23:47:51 genie kernel: [600473.430451] RPC:       gss_k5decrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.430469] RPC:       gss_krb5_seal
Oct 20 23:47:51 genie kernel: [600473.430505] RPC:       krb5_encrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.430533] RPC:       krb5_encrypt returns 0
Oct 20 23:47:51 genie kernel: [600473.430583] svc: svc_process dropit
Oct 20 23:47:51 genie kernel: [600473.430599] svc: xprt de825400 dropped request
Oct 20 23:47:51 genie kernel: [600473.430618] svc: transport de825400 busy, not enqueued
Oct 20 23:47:51 genie kernel: [600473.430637] svc: server c0f0b000 waiting for data (to = 360000)
Oct 20 23:47:51 genie kernel: [600473.430672] svc: server dee34000, pool 0, transport de825400, inuse=3
Oct 20 23:47:51 genie kernel: [600473.430694] svc: tcp_recv de825400 data 1 conn 0 close 0
Oct 20 23:47:51 genie kernel: [600473.430717] svc: socket de825400 recvfrom(de8255c4, 4) = -11
Oct 20 23:47:51 genie kernel: [600473.430733] RPC: TCP recv_record got EAGAIN
Oct 20 23:47:51 genie kernel: [600473.430748] svc: got len=-11
Oct 20 23:47:51 genie kernel: [600473.430762] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:51 genie kernel: [600473.431850] svc: socket df948900 TCP (connected) state change 8 (svsk deda1a00)
Oct 20 23:47:51 genie kernel: [600473.431887] svc: transport deda1a00 served by daemon dee34000
Oct 20 23:47:51 genie kernel: [600473.431912] svc: socket df948900 TCP data ready (svsk deda1a00)
Oct 20 23:47:51 genie kernel: [600473.431931] svc: transport deda1a00 busy, not enqueued
Oct 20 23:47:51 genie kernel: [600473.431966] svc_recv: found XPT_CLOSE
Oct 20 23:47:51 genie kernel: [600473.431982] svc: svc_delete_xprt(deda1a00)
Oct 20 23:47:51 genie kernel: [600473.431997] svc: svc_tcp_sock_detach(deda1a00)
Oct 20 23:47:51 genie kernel: [600473.432013] svc: svc_sock_detach(deda1a00)
Oct 20 23:47:51 genie kernel: [600473.432114] svc: transport deda1a00 is dead, not enqueued
Oct 20 23:47:51 genie kernel: [600473.432136] svc: svc_sock_free(deda1a00)
Oct 20 23:47:51 genie kernel: [600473.432165] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:58 genie kernel: [600480.250341] svc: socket df948d80 TCP data ready (svsk de4ac000)
Oct 20 23:47:58 genie kernel: [600480.250379] svc: transport de4ac000 served by daemon dee34000
Oct 20 23:47:58 genie kernel: [600480.250432] svc: server dee34000, pool 0, transport de4ac000, inuse=2
Oct 20 23:47:58 genie kernel: [600480.250456] svc: tcp_recv de4ac000 data 1 conn 0 close 0
Oct 20 23:47:58 genie kernel: [600480.250484] svc: socket de4ac000 recvfrom(de4ac1c8, 0) = 4
Oct 20 23:47:58 genie kernel: [600480.250502] svc: TCP record, 152 bytes
Oct 20 23:47:58 genie kernel: [600480.250523] svc: socket de4ac000 recvfrom(c3953008, 4088) = 8
Oct 20 23:47:58 genie kernel: [600480.250549] svc: socket de4ac000 recvfrom(c3953098, 3944) = 144
Oct 20 23:47:58 genie kernel: [600480.250567] svc: TCP complete record (152 bytes)
Oct 20 23:47:58 genie kernel: [600480.250586] svc: transport de4ac000 served by daemon c0f0b000
Oct 20 23:47:58 genie kernel: [600480.250609] svc: got len=152
Oct 20 23:47:58 genie kernel: [600480.250627] svc: svc_authenticate (1)
Oct 20 23:47:58 genie kernel: [600480.250653] svc: calling dispatcher
Oct 20 23:47:58 genie kernel: [600480.250749] svc: socket de4ac000 sendto([c3845000 48... ], 48) = 48 (addr 172.22.21.203, port=706)
Oct 20 23:47:58 genie kernel: [600480.250783] svc: transport de4ac000 busy, not enqueued
Oct 20 23:47:58 genie kernel: [600480.250804] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:47:58 genie kernel: [600480.250839] svc: server c0f0b000, pool 0, transport de4ac000, inuse=2
Oct 20 23:47:58 genie kernel: [600480.250862] svc: tcp_recv de4ac000 data 1 conn 0 close 0
Oct 20 23:47:58 genie kernel: [600480.250884] svc: socket de4ac000 recvfrom(de4ac1c4, 4) = -11
Oct 20 23:47:58 genie kernel: [600480.250900] RPC: TCP recv_record got EAGAIN
Oct 20 23:47:58 genie kernel: [600480.250956] svc: got len=-11
Oct 20 23:47:58 genie kernel: [600480.250975] svc: server c0f0b000 waiting for data (to = 360000)
Oct 20 23:48:03 genie kernel: [600485.902454] RPC:       unx_free_cred deecb900
Oct 20 23:48:18 genie kernel: [600500.662413] RPC:   437 got signal
Oct 20 23:48:18 genie kernel: [600500.662441] RPC:   437 __rpc_wake_up_task (now 60017918)
Oct 20 23:48:18 genie kernel: [600500.662457] RPC:   437 disabling timer
Oct 20 23:48:18 genie kernel: [600500.662475] RPC:   437 removed from queue c39661d0 "xprt_pending"
Oct 20 23:48:18 genie kernel: [600500.662493] RPC:       __rpc_wake_up_task done
Oct 20 23:48:18 genie kernel: [600500.662508] RPC:   437 sync task resuming
Oct 20 23:48:18 genie kernel: [600500.662524] RPC:   437 return -512, status -512
Oct 20 23:48:18 genie kernel: [600500.662539] RPC:   437 release task
Oct 20 23:48:18 genie kernel: [600500.662558] RPC:       freeing buffer of size 3712 at d6915000
Oct 20 23:48:18 genie kernel: [600500.662578] RPC:   437 release request d6911000
Oct 20 23:48:18 genie kernel: [600500.662594] RPC:       wake_up_next(c3966234 "xprt_backlog")
Oct 20 23:48:18 genie kernel: [600500.662613] RPC:   437 releasing RPCSEC_GSS cred df1f9300
Oct 20 23:48:18 genie kernel: [600500.662631] RPC:       rpc_release_client(de639e00)
Oct 20 23:48:18 genie kernel: [600500.662648] RPC:   437 freeing task
Oct 20 23:48:18 genie kernel: [600500.662664] nfs4_get_root: getroot error = 512
Oct 20 23:48:18 genie kernel: [600500.662679] --> nfs_free_server()
Oct 20 23:48:18 genie kernel: [600500.662694] RPC:       shutting down nfs client for genie
Oct 20 23:48:18 genie kernel: [600500.662710] RPC:       rpc_release_client(de639e00)
Oct 20 23:48:18 genie kernel: [600500.662726] RPC:       destroying nfs client for genie
Oct 20 23:48:18 genie kernel: [600500.662793] RPC:       rpc_release_client(de639900)
Oct 20 23:48:18 genie kernel: [600500.662815] --> nfs_put_client({1})
Oct 20 23:48:18 genie kernel: [600500.662830] --> nfs_free_client(4)
Oct 20 23:48:18 genie kernel: [600500.664081] svc: server d6913000, no data yet
Oct 20 23:48:18 genie kernel: [600500.666814] svc: svc_destroy(NFSv4 callback, 1)
Oct 20 23:48:18 genie kernel: [600500.666845] svc: svc_delete_xprt(df930a00)
Oct 20 23:48:18 genie kernel: [600500.666860] svc: svc_tcp_sock_detach(df930a00)
Oct 20 23:48:18 genie kernel: [600500.666875] svc: svc_sock_detach(df930a00)
Oct 20 23:48:18 genie kernel: [600500.666891] svc: svc_sock_free(df930a00)
Oct 20 23:48:18 genie kernel: [600500.666928] svc: svc_delete_xprt(df930e00)
Oct 20 23:48:18 genie kernel: [600500.666943] svc: svc_tcp_sock_detach(df930e00)
Oct 20 23:48:18 genie kernel: [600500.666958] svc: svc_sock_detach(df930e00)
Oct 20 23:48:18 genie kernel: [600500.666973] svc: svc_sock_free(df930e00)
Oct 20 23:48:18 genie kernel: [600500.667001] RPC:       unregistering [1073741824, 1, ''] with local rpcbind
Oct 20 23:48:18 genie kernel: [600500.667044] RPC:       set up xprt to 127.0.0.1 (port 111) via udp
Oct 20 23:48:18 genie kernel: [600500.667068] RPC:       created transport c39c4000 with 16 slots
Oct 20 23:48:18 genie kernel: [600500.667088] RPC:       creating rpcbind client for localhost (xprt c39c4000)
Oct 20 23:48:18 genie kernel: [600500.667114] RPC:       creating UNIX authenticator for client de639e00
Oct 20 23:48:18 genie kernel: [600500.667138] RPC:     0 looking up UNIX cred
Oct 20 23:48:18 genie kernel: [600500.667152] RPC:       looking up UNIX cred
Oct 20 23:48:18 genie kernel: [600500.667169] RPC:       new task initialized, procpid 26217
Oct 20 23:48:18 genie kernel: [600500.667186] RPC:       allocated task c0cc6500
Oct 20 23:48:18 genie kernel: [600500.667202] RPC:   438 __rpc_execute flags=0x280
Oct 20 23:48:18 genie kernel: [600500.667219] RPC:   438 call_start rpcbind4 proc UNSET (sync)
Oct 20 23:48:18 genie kernel: [600500.667237] RPC:   438 call_reserve (status 0)
Oct 20 23:48:18 genie kernel: [600500.667255] RPC:   438 reserved req df957000 xid 0d86ad6c
Oct 20 23:48:18 genie kernel: [600500.667272] RPC:   438 call_reserveresult (status 0)
Oct 20 23:48:18 genie kernel: [600500.667289] RPC:   438 call_allocate (status 0)
Oct 20 23:48:18 genie kernel: [600500.667307] RPC:   438 allocated buffer of size 484 at de7a7000
Oct 20 23:48:18 genie kernel: [600500.667326] RPC:   438 call_bind (status 0)
Oct 20 23:48:18 genie kernel: [600500.667342] RPC:   438 call_connect xprt c39c4000 is not connected
Oct 20 23:48:18 genie kernel: [600500.667361] RPC:   438 xprt_connect xprt c39c4000 is not connected
Oct 20 23:48:18 genie kernel: [600500.667381] RPC:   438 xprt_cwnd_limited cong = 0 cwnd = 256
Oct 20 23:48:18 genie kernel: [600500.667400] RPC:   438 sleep_on(queue "xprt_pending" time 60017918)
Oct 20 23:48:18 genie kernel: [600500.667420] RPC:   438 added to queue c39c41d0 "xprt_pending"
Oct 20 23:48:18 genie kernel: [600500.667438] RPC:   438 setting alarm for 5000 ms
Oct 20 23:48:18 genie kernel: [600500.667455] RPC:       xs_connect scheduled xprt c39c4000
Oct 20 23:48:18 genie kernel: [600500.667480] RPC:   438 sync task going to sleep
Oct 20 23:48:18 genie kernel: [600500.667529] RPC:       xs_bind4 0.0.0.0:949: ok (0)
Oct 20 23:48:18 genie kernel: [600500.667550] RPC:       worker connecting xprt c39c4000 via udp to 127.0.0.1 (port 111)
Oct 20 23:48:18 genie kernel: [600500.667576] RPC:   438 __rpc_wake_up_task (now 60017918)
Oct 20 23:48:18 genie kernel: [600500.667593] RPC:   438 disabling timer
Oct 20 23:48:18 genie kernel: [600500.667609] RPC:   438 removed from queue c39c41d0 "xprt_pending"
Oct 20 23:48:18 genie kernel: [600500.667630] RPC:       __rpc_wake_up_task done
Oct 20 23:48:18 genie kernel: [600500.668293] RPC:   438 sync task resuming
Oct 20 23:48:18 genie kernel: [600500.668317] RPC:   438 xprt_connect_status: connection established
Oct 20 23:48:18 genie kernel: [600500.668406] RPC:   438 call_connect_status (status 0)
Oct 20 23:48:18 genie kernel: [600500.668433] RPC:   438 call_transmit (status 0)
Oct 20 23:48:18 genie kernel: [600500.668450] RPC:   438 xprt_prepare_transmit
Oct 20 23:48:18 genie kernel: [600500.668467] RPC:   438 rpc_xdr_encode (status 0)
Oct 20 23:48:18 genie kernel: [600500.668485] RPC:   438 marshaling UNIX cred deee8280
Oct 20 23:48:18 genie kernel: [600500.668505] RPC:   438 using AUTH_UNIX cred deee8280 to wrap rpc data
Oct 20 23:48:18 genie kernel: [600500.668527] RPC:   438 encoding RPCB_UNSET call (1073741824, 1, '', '')
Oct 20 23:48:18 genie kernel: [600500.668548] RPC:   438 xprt_transmit(96)
Oct 20 23:48:18 genie kernel: [600500.668614] RPC:       xs_udp_send_request(96) = 96
Oct 20 23:48:18 genie kernel: [600500.668634] RPC:   438 xmit complete
Oct 20 23:48:18 genie kernel: [600500.668650] RPC:   438 sleep_on(queue "xprt_pending" time 60017918)
Oct 20 23:48:18 genie kernel: [600500.668670] RPC:   438 added to queue c39c41d0 "xprt_pending"
Oct 20 23:48:18 genie kernel: [600500.668688] RPC:   438 setting alarm for 5000 ms
Oct 20 23:48:18 genie kernel: [600500.668706] RPC:   438 sync task going to sleep
Oct 20 23:48:18 genie kernel: [600500.669141] RPC:       xs_udp_data_ready...
Oct 20 23:48:18 genie kernel: [600500.669174] RPC:       cong 256, cwnd was 256, now 512
Oct 20 23:48:18 genie kernel: [600500.669194] RPC:       wake_up_next(c39c416c "xprt_resend")
Oct 20 23:48:18 genie kernel: [600500.669213] RPC:       wake_up_next(c39c4108 "xprt_sending")
Oct 20 23:48:18 genie kernel: [600500.669233] RPC:   438 xid 0d86ad6c complete (28 bytes received)
Oct 20 23:48:18 genie kernel: [600500.669251] RPC:   438 __rpc_wake_up_task (now 60017918)
Oct 20 23:48:18 genie kernel: [600500.669267] RPC:   438 disabling timer
Oct 20 23:48:18 genie kernel: [600500.669283] RPC:   438 removed from queue c39c41d0 "xprt_pending"
Oct 20 23:48:18 genie kernel: [600500.669307] RPC:       __rpc_wake_up_task done
Oct 20 23:48:18 genie kernel: [600500.669374] RPC:   438 sync task resuming
Oct 20 23:48:18 genie kernel: [600500.669395] RPC:   438 call_status (status 28)
Oct 20 23:48:18 genie kernel: [600500.669410] RPC:   438 call_decode (status 28)
Oct 20 23:48:18 genie kernel: [600500.669428] RPC:   438 validating UNIX cred deee8280
Oct 20 23:48:18 genie kernel: [600500.669446] RPC:   438 using AUTH_UNIX cred deee8280 to unwrap rpc data
Oct 20 23:48:18 genie kernel: [600500.669467] RPC:   438 RPCB_UNSET call succeeded
Oct 20 23:48:18 genie kernel: [600500.669482] RPC:   438 call_decode result 0
Oct 20 23:48:18 genie kernel: [600500.669498] RPC:   438 return 0, status 0
Oct 20 23:48:18 genie kernel: [600500.669511] RPC:   438 release task
Oct 20 23:48:18 genie kernel: [600500.669530] RPC:       freeing buffer of size 484 at de7a7000
Oct 20 23:48:18 genie kernel: [600500.669549] RPC:   438 release request df957000
Oct 20 23:48:18 genie kernel: [600500.669565] RPC:       wake_up_next(c39c4234 "xprt_backlog")
Oct 20 23:48:18 genie kernel: [600500.669584] RPC:   438 releasing UNIX cred deee8280
Oct 20 23:48:18 genie kernel: [600500.669601] RPC:       rpc_release_client(de639e00)
Oct 20 23:48:18 genie kernel: [600500.669617] RPC:   438 freeing task
Oct 20 23:48:18 genie kernel: [600500.669632] RPC:       shutting down rpcbind client for localhost
Oct 20 23:48:18 genie kernel: [600500.669650] RPC:       rpc_release_client(de639e00)
Oct 20 23:48:18 genie kernel: [600500.669666] RPC:       destroying rpcbind client for localhost
Oct 20 23:48:18 genie kernel: [600500.669685] RPC:       destroying transport c39c4000
Oct 20 23:48:18 genie kernel: [600500.669702] RPC:       xs_destroy xprt c39c4000
Oct 20 23:48:18 genie kernel: [600500.669718] RPC:       xs_close xprt c39c4000
Oct 20 23:48:18 genie kernel: [600500.669746] RPC:       disconnected transport c39c4000
Oct 20 23:48:18 genie kernel: [600500.669769] svc: __svc_unregister(NFSv4 callbackv1), error 0
Oct 20 23:48:18 genie kernel: [600500.669825] RPC:       shutting down nfs client for genie
Oct 20 23:48:18 genie kernel: [600500.669845] RPC:       rpc_release_client(de639900)
Oct 20 23:48:18 genie kernel: [600500.669863] RPC:       destroying GSS authenticator c3a33544 flavor 390003
Oct 20 23:48:18 genie kernel: [600500.669889] RPC:     0 holding RPCSEC_GSS cred df1f9300
Oct 20 23:48:18 genie kernel: [600500.669906] RPC:       new task initialized, procpid 26217
Oct 20 23:48:18 genie kernel: [600500.669922] RPC:       allocated task c0cc6500
Oct 20 23:48:18 genie kernel: [600500.669938] RPC:   439 __rpc_execute flags=0x281
Oct 20 23:48:18 genie kernel: [600500.669955] RPC:   439 call_start nfs4 proc NULL (async)
Oct 20 23:48:18 genie kernel: [600500.669973] RPC:   439 call_reserve (status 0)
Oct 20 23:48:18 genie kernel: [600500.669991] RPC:   439 reserved req d6911000 xid 684da781
Oct 20 23:48:18 genie kernel: [600500.670008] RPC:   439 call_reserveresult (status 0)
Oct 20 23:48:18 genie kernel: [600500.670024] RPC:   439 call_allocate (status 0)
Oct 20 23:48:18 genie kernel: [600500.670042] RPC:   439 allocated buffer of size 3116 at df957000
Oct 20 23:48:18 genie kernel: [600500.670060] RPC:   439 call_bind (status 0)
Oct 20 23:48:18 genie kernel: [600500.670076] RPC:   439 call_connect xprt c3966000 is connected
Oct 20 23:48:18 genie kernel: [600500.670094] RPC:   439 call_transmit (status 0)
Oct 20 23:48:18 genie kernel: [600500.670109] RPC:   439 xprt_prepare_transmit
Oct 20 23:48:18 genie kernel: [600500.670125] RPC:   439 rpc_xdr_encode (status 0)
Oct 20 23:48:18 genie kernel: [600500.670143] RPC:   439 marshaling RPCSEC_GSS cred df1f9300
Oct 20 23:48:18 genie kernel: [600500.670160] RPC:   439 gss_marshal
Oct 20 23:48:18 genie kernel: [600500.670174] RPC:       gss_krb5_seal
Oct 20 23:48:18 genie kernel: [600500.670235] RPC:       krb5_encrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.670266] RPC:       krb5_encrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.670288] RPC:   439 using AUTH_GSS cred df1f9300 to wrap rpc data
Oct 20 23:48:18 genie kernel: [600500.670307] RPC:   439 gss_wrap_req
Oct 20 23:48:18 genie kernel: [600500.670321] RPC:   439 gss_wrap_req returning 0
Oct 20 23:48:18 genie kernel: [600500.670336] RPC:   439 xprt_transmit(108)
Oct 20 23:48:18 genie kernel: [600500.670412] svc: socket df94a880 TCP data ready (svsk de825400)
Oct 20 23:48:18 genie kernel: [600500.670438] svc: transport de825400 served by daemon c0f0b000
Oct 20 23:48:18 genie kernel: [600500.670495] svc: server c0f0b000, pool 0, transport de825400, inuse=3
Oct 20 23:48:18 genie kernel: [600500.670520] svc: tcp_recv de825400 data 1 conn 0 close 0
Oct 20 23:48:18 genie kernel: [600500.670546] svc: socket de825400 recvfrom(de8255c8, 0) = 4
Oct 20 23:48:18 genie kernel: [600500.670563] svc: TCP record, 104 bytes
Oct 20 23:48:18 genie kernel: [600500.670584] svc: socket de825400 recvfrom(c39f7008, 4088) = 8
Oct 20 23:48:18 genie kernel: [600500.670609] svc: socket de825400 recvfrom(c39f7068, 3992) = 96
Oct 20 23:48:18 genie kernel: [600500.670627] svc: TCP complete record (104 bytes)
Oct 20 23:48:18 genie kernel: [600500.670646] svc: transport de825400 served by daemon dee34000
Oct 20 23:48:18 genie kernel: [600500.670668] svc: got len=104
Oct 20 23:48:18 genie kernel: [600500.670685] svc: svc_authenticate (6)
Oct 20 23:48:18 genie kernel: [600500.670700] RPC:       svcauth_gss: argv->iov_len = 76
Oct 20 23:48:18 genie kernel: [600500.670724] RPC:       krb5_read_token
Oct 20 23:48:18 genie kernel: [600500.670768] RPC:       krb5_encrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.670786] RPC:       krb5_get_seq_num:
Oct 20 23:48:18 genie kernel: [600500.670809] RPC:       gss_k5decrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.670828] RPC:       gss_krb5_seal
Oct 20 23:48:18 genie kernel: [600500.670863] RPC:       krb5_encrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.670890] RPC:       krb5_encrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.670954] svc: socket de825400 sendto([c393d000 68... ], 68) = 68 (addr 172.22.21.8, port=935)
Oct 20 23:48:18 genie kernel: [600500.670986] svc: transport de825400 busy, not enqueued
Oct 20 23:48:18 genie kernel: [600500.671006] svc: server c0f0b000 waiting for data (to = 360000)
Oct 20 23:48:18 genie kernel: [600500.671041] svc: server dee34000, pool 0, transport de825400, inuse=3
Oct 20 23:48:18 genie kernel: [600500.671063] svc: tcp_recv de825400 data 1 conn 0 close 0
Oct 20 23:48:18 genie kernel: [600500.671085] svc: socket de825400 recvfrom(de8255c4, 4) = -11
Oct 20 23:48:18 genie kernel: [600500.671102] RPC: TCP recv_record got EAGAIN
Oct 20 23:48:18 genie kernel: [600500.671117] svc: got len=-11
Oct 20 23:48:18 genie kernel: [600500.671131] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:48:18 genie kernel: [600500.682781] RPC:       xs_tcp_data_ready...
Oct 20 23:48:18 genie kernel: [600500.682813] RPC:       xs_tcp_data_recv started
Oct 20 23:48:18 genie kernel: [600500.682831] RPC:       reading TCP record fragment of length 64
Oct 20 23:48:18 genie kernel: [600500.682849] RPC:       reading XID (4 bytes)
Oct 20 23:48:18 genie kernel: [600500.682865] RPC:       reading reply for XID 684da781
Oct 20 23:48:18 genie kernel: [600500.682881] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 20 23:48:18 genie kernel: [600500.682897] RPC:       read reply XID 684da781
Oct 20 23:48:18 genie kernel: [600500.682915] RPC:       XID 684da781 read 56 bytes
Oct 20 23:48:18 genie kernel: [600500.682933] RPC:       xprt = c3966000, tcp_copied = 64, tcp_offset = 64, tcp_reclen = 64
Oct 20 23:48:18 genie kernel: [600500.682959] RPC:   439 xid 684da781 complete (64 bytes received)
Oct 20 23:48:18 genie kernel: [600500.682977] RPC:       xs_tcp_data_recv done
Oct 20 23:48:18 genie kernel: [600500.683023] RPC:       xs_tcp_send_request(108) = 108
Oct 20 23:48:18 genie kernel: [600500.683042] RPC:   439 xmit complete
Oct 20 23:48:18 genie kernel: [600500.683060] RPC:       wake_up_next(c396616c "xprt_resend")
Oct 20 23:48:18 genie kernel: [600500.683079] RPC:       wake_up_next(c3966108 "xprt_sending")
Oct 20 23:48:18 genie kernel: [600500.683099] RPC:   439 call_status (status 64)
Oct 20 23:48:18 genie kernel: [600500.683114] RPC:   439 call_decode (status 64)
Oct 20 23:48:18 genie kernel: [600500.683132] RPC:   439 validating RPCSEC_GSS cred df1f9300
Oct 20 23:48:18 genie kernel: [600500.683149] RPC:   439 gss_validate
Oct 20 23:48:18 genie kernel: [600500.683163] RPC:       krb5_read_token
Oct 20 23:48:18 genie kernel: [600500.683220] RPC:       krb5_encrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.683238] RPC:       krb5_get_seq_num:
Oct 20 23:48:18 genie kernel: [600500.683261] RPC:       gss_k5decrypt returns 0
Oct 20 23:48:18 genie kernel: [600500.683279] RPC:   439 gss_validate: gss_verify_mic succeeded.
Oct 20 23:48:18 genie kernel: [600500.683299] RPC:   439 using AUTH_GSS cred df1f9300 to unwrap rpc data
Oct 20 23:48:18 genie kernel: [600500.683319] RPC:   439 gss_unwrap_resp returning 0
Oct 20 23:48:18 genie kernel: [600500.683335] RPC:   439 call_decode result 0
Oct 20 23:48:18 genie kernel: [600500.683350] RPC:   439 return 0, status 0
Oct 20 23:48:18 genie kernel: [600500.683364] RPC:   439 release task
Oct 20 23:48:18 genie kernel: [600500.683383] RPC:       freeing buffer of size 3116 at df957000
Oct 20 23:48:18 genie kernel: [600500.683403] RPC:   439 release request d6911000
Oct 20 23:48:18 genie kernel: [600500.683419] RPC:       wake_up_next(c3966234 "xprt_backlog")
Oct 20 23:48:18 genie kernel: [600500.683438] RPC:   439 releasing RPCSEC_GSS cred df1f9300
Oct 20 23:48:18 genie kernel: [600500.683455] RPC:       rpc_release_client(de639900)
Oct 20 23:48:18 genie kernel: [600500.683472] RPC:   439 freeing task
Oct 20 23:48:18 genie kernel: [600500.683487] RPC:       gss_delete_sec_context deleting d697da40
Oct 20 23:48:18 genie kernel: [600500.685720] RPC:       destroying nfs client for genie
Oct 20 23:48:18 genie kernel: [600500.685777] RPC:       destroying transport c3966000
Oct 20 23:48:18 genie kernel: [600500.685796] RPC:       xs_destroy xprt c3966000
Oct 20 23:48:18 genie kernel: [600500.686301] RPC:       xs_close xprt c3966000
Oct 20 23:48:18 genie kernel: [600500.686377] svc: socket df94a880 TCP (connected) state change 8 (svsk de825400)
Oct 20 23:48:18 genie kernel: [600500.686406] svc: transport de825400 served by daemon dee34000
Oct 20 23:48:18 genie kernel: [600500.686433] svc: socket df94a880 TCP data ready (svsk de825400)
Oct 20 23:48:18 genie kernel: [600500.686452] svc: transport de825400 busy, not enqueued
Oct 20 23:48:18 genie kernel: [600500.686485] svc_recv: found XPT_CLOSE
Oct 20 23:48:18 genie kernel: [600500.686501] svc: svc_delete_xprt(de825400)
Oct 20 23:48:18 genie kernel: [600500.686516] svc: svc_tcp_sock_detach(de825400)
Oct 20 23:48:18 genie kernel: [600500.686531] svc: svc_sock_detach(de825400)
Oct 20 23:48:18 genie kernel: [600500.686629] svc: transport de825400 is dead, not enqueued
Oct 20 23:48:18 genie kernel: [600500.686653] svc: server dee34000 waiting for data (to = 360000)
Oct 20 23:48:18 genie kernel: [600500.686686] RPC:       disconnected transport c3966000
Oct 20 23:48:18 genie kernel: [600500.686709] <-- nfs_free_client()
Oct 20 23:48:18 genie kernel: [600500.686725] <-- nfs_free_server()
Oct 20 23:48:18 genie kernel: [600500.686739] <-- nfs4_create_server() = error -512
Oct 20 23:48:18 genie kernel: [600500.686760] <-- nfs4_get_sb() = -512 [error]
Oct 20 23:48:18 genie kernel: [600500.702377] RPC:       gss_free_cred df1f9300
Oct 20 23:48:18 genie kernel: [600500.702405] RPC:       gss_free_ctx

--MP_/SKurn4=OsfkSnMu/_AT+z1w--
