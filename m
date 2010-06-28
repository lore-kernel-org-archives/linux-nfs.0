From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Issues mounting nfsv4
Date: Mon, 28 Jun 2010 11:08:15 -0400
Message-ID: <1277737695.30923.46.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:56142 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083Ab0F1PZu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2010 11:25:50 -0400
Received: from tarius.tycho.ncsc.mil (localhost [127.0.0.1])
	by msux-gh1-uea02.nsa.gov (8.12.10/8.12.10) with ESMTP id o5SFGAJA004710
	for <linux-nfs@vger.kernel.org>; Mon, 28 Jun 2010 15:16:10 GMT
Received: from [144.51.25.2] (moss-terrapins [144.51.25.2])
	by tarius.tycho.ncsc.mil (8.13.1/8.13.1) with ESMTP id o5SFEP8f017411
	for <linux-nfs@vger.kernel.org>; Mon, 28 Jun 2010 11:14:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,
   I am working on rebasing the labeled-nfs patches on a newer kernel
version and readding the label translation code in. I don't believe that
I have touched anything related to the rpc client creation code. When I
try to mount my nfsv4 share I am getting this error

svc: 127.0.0.1, port=717: unknown version (4 for prog 100003, nfsd)

This gives me the indication that whatever is throwing off that message
doesn't recognize nfsv4 as a valid version for NFS.

I've pasted the output of a mount attempt with rpcdebug -m
{rpc,nfs,nfsd} all set to all.

NFS: nfs mount opts='clientaddr=127.0.0.1,addr=127.0.0.1'
NFS:   parsing nfs mount option 'clientaddr=127.0.0.1'
NFS:   parsing nfs mount option 'addr=127.0.0.1'
NFS: MNTPATH: '/'
--> nfs4_try_mount()
--> nfs4_create_server()
--> nfs4_init_server()
--> nfs4_set_client()
--> nfs_get_client(localhost,v4)
RPC:       looking up machine cred
--> nfs_get_client() = ffff880129a48400 [new]
RPC:       set up xprt to 127.0.0.1 (port 2049) via tcp
RPC:       created transport ffff880126d0b000 with 16 slots
RPC:       creating nfs client for localhost (xprt ffff880126d0b000)
RPC:       creating UNIX authenticator for client ffff88012905aa00
RPC:     0 holding NULL cred ffffffffa0263cb0
RPC:       new task initialized, procpid 10133
RPC:       allocated task ffff880121808f00
RPC:    64 __rpc_execute flags=0x680
RPC:    64 call_start nfs4 proc NULL (sync)
RPC:    64 call_reserve (status 0)
RPC:    64 reserved req ffff880128be6000 xid 58bf3f2b
RPC:    64 call_reserveresult (status 0)
RPC:    64 call_allocate (status 0)
RPC:    64 allocated buffer of size 96 at ffff880126d0c800
RPC:    64 call_bind (status 0)
RPC:    64 call_connect xprt ffff880126d0b000 is not connected
RPC:    64 xprt_connect xprt ffff880126d0b000 is not connected
RPC:    64 sleep_on(queue "xprt_pending" time 4296522262)
RPC:    64 added to queue ffff880126d0b320 "xprt_pending"
RPC:    64 setting alarm for 60000 ms
RPC:       xs_connect scheduled xprt ffff880126d0b000
RPC:    64 sync task going to sleep
RPC:       xs_bind4 0.0.0.0:877: ok (0)
RPC:       worker connecting xprt ffff880126d0b000 via tcp to 127.0.0.1 (port 2049)
RPC:       xs_tcp_state_change client ffff880126d0b000...
RPC:       state 1 conn 0 dead 0 zapped 1
RPC:    64 __rpc_wake_up_task (now 4296522263)
RPC:    64 disabling timer
RPC:    64 removed from queue ffff880126d0b320 "xprt_pending"
RPC:       __rpc_wake_up_task done
svc: socket ffff880126f59380 TCP (listen) state change 10
svc: transport ffff88012995b000 served by daemon ffff880128be4000
RPC:       ffff880126d0b000 connect status 115 connected 1 sock state 1
svc: tcp_accept ffff88012995b000 sock ffff880126bd3180
nfsd: connect from 127.0.0.1, port=877
svc: svc_setup_socket ffff880126bd2680
setting up TCP socket for reading
svc: socket ffff880129de6400(inet ffff880126f5c100), write_space busy=1
svc: svc_setup_socket created ffff880129de6400 (inet ffff880126f5c100)
svc: transport ffff880129de6400 served by daemon ffff880128be2000
svc: transport ffff88012995b000 served by daemon ffff880128be0000
svc: transport ffff88012995b000 busy, not enqueued
svc: server ffff880128be4000 waiting for data (to = 3600000)
svc: server ffff880128be2000, pool 0, transport ffff880129de6400, inuse=2
svc: tcp_recv ffff880129de6400 data 1 conn 0 close 0
svc: socket ffff880129de6400(inet ffff880126f5c100), write_space busy=1
svc: transport ffff880129de6400 busy, not enqueued
svc: tcp_accept ffff88012995b000 sock ffff880126bd3180
svc: server ffff880128be0000 waiting for data (to = 3600000)
RPC:    64 sync task resuming
RPC:    64 xprt_connect_status: retrying
RPC:    64 call_connect_status (status -11)
RPC:    64 call_transmit (status 0)
RPC:    64 xprt_prepare_transmit
RPC:    64 rpc_xdr_encode (status 0)
RPC:    64 marshaling NULL cred ffffffffa0263cb0
RPC:    64 using AUTH_NULL cred ffffffffa0263cb0 to wrap rpc data
RPC:    64 xprt_transmit(44)
svc: socket ffff880126f5c100 TCP data ready (svsk ffff880129de6400)
svc: transport ffff880129de6400 busy, not enqueued
RPC:       xs_tcp_send_request(44) = 44
RPC:    64 xmit complete
RPC:    64 sleep_on(queue "xprt_pending" time 4296522263)
RPC:    64 added to queue ffff880126d0b320 "xprt_pending"
RPC:    64 setting alarm for 60000 ms
RPC:       wake_up_next(ffff880126d0b258 "xprt_resend")
RPC:       wake_up_next(ffff880126d0b190 "xprt_sending")
RPC:    64 sync task going to sleep
svc: socket ffff880129de6400 recvfrom(ffff880129de669c, 0) = 4
svc: TCP record, 40 bytes
svc: socket ffff880129de6400 recvfrom(ffff880126d4e008, 4088) = 8
svc: socket ffff880129de6400 recvfrom(ffff880126d4e028, 4056) = 32
svc: TCP complete record (40 bytes)
svc: transport ffff880129de6400 served by daemon ffff880128be0000
svc: got len=40
svc: svc_authenticate (0)
svc: 127.0.0.1, port=877: unknown version (4 for prog 100003, nfsd)
svc: server ffff880128be0000, pool 0, transport ffff880129de6400, inuse=3
svc: tcp_recv ffff880129de6400 data 1 conn 0 close 0
RPC:       xs_tcp_data_ready...
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 32
RPC:       reading XID (4 bytes)
RPC:       reading request with XID 58bf3f2b
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       reading reply for CALL/REPLY flag 01000000
RPC:       read reply XID 58bf3f2b
RPC:       XID 58bf3f2b read 24 bytes
RPC:       xprt = ffff880126d0b000, tcp_copied = 32, tcp_offset = 32, tcp_reclen = 32
RPC:    64 xid 58bf3f2b complete (32 bytes received)
RPC:    64 __rpc_wake_up_task (now 4296522264)
RPC:    64 disabling timer
RPC:    64 removed from queue ffff880126d0b320 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
svc: socket ffff880129de6400 sendto([ffff880126d4f000 36... ], 36) = 36 (addr 127.0.0.1, port=877)
svc: socket ffff880129de6400 recvfrom(ffff880129de6698, 4) = -11
svc: server ffff880128be2000 waiting for data (to = 3600000)
RPC: TCP recv_record got EAGAIN
svc: got len=-11
svc: server ffff880128be0000 waiting for data (to = 3600000)
RPC:    64 sync task resuming
RPC:    64 call_status (status 32)
RPC:    64 call_decode (status 32)
RPC:    64 validating NULL cred ffffffffa0263cb0
RPC:    64 rpc_verify_header: program 100003, version 4 unsupported by server localhost
RPC:    64 rpc_verify_header: call failed with error -93
RPC:    64 return 0, status -93
RPC:    64 release task
RPC:       freeing buffer of size 96 at ffff880126d0c800
RPC:    64 release request ffff880128be6000
RPC:       wake_up_next(ffff880126d0b3e8 "xprt_backlog")
RPC:    64 releasing NULL cred ffffffffa0263cb0
RPC:       rpc_release_client(ffff88012905aa00)
RPC:    64 freeing task
RPC:       shutting down nfs client for localhost
RPC:       rpc_release_client(ffff88012905aa00)
RPC:       destroying nfs client for localhost
RPC:       destroying transport ffff880126d0b000
RPC:       xs_destroy xprt ffff880126d0b000
RPC:       xs_close xprt ffff880126d0b000
svc: socket ffff880126f5c100 TCP (connected) state change 8 (svsk ffff880129de6400)
svc: transport ffff880129de6400 served by daemon ffff880128be0000
svc: socket ffff880126f5c100 TCP data ready (svsk ffff880129de6400)
svc_recv: found XPT_CLOSE
svc: transport ffff880129de6400 busy, not enqueued
svc: svc_delete_xprt(ffff880129de6400)
svc: svc_tcp_sock_detach(ffff880129de6400)
svc: svc_sock_detach(ffff880129de6400)
RPC:       disconnected transport ffff880126d0b000
nfs_create_rpc_client: cannot create RPC client. Error = -93
<-- nfs4_init_client() = xerror -93
--> nfs_put_client({1})
--> nfs_free_client(4)
<-- nfs_free_client()
<-- nfs4_set_client() = xerror -93
<-- nfs4_init_server() = -93
--> nfs_free_server()
<-- nfs_free_server()
<-- nfs4_create_server() = error -93
<-- nfs4_try_mount() = -93 [error]
<-- nfs4_get_sb() = -93 [error]
svc: transport ffff880129de6400 is dead, not enqueued
svc: svc_sock_free(ffff880129de6400)
svc: server ffff880128be0000 waiting for data (to = 3600000)


