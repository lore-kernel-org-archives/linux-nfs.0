From: vishal <vishal@endace.com>
Subject: nfsmount: input/output error
Date: Wed, 27 Dec 2006 18:30:40 +1300
Message-ID: <1167197440.5552.20.camel@julia.et.endace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-mAD+Mo6RWfmurb+UKPnl"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GzRNM-00077F-Mz
	for nfs@lists.sourceforge.net; Tue, 26 Dec 2006 21:30:52 -0800
Received: from endace.smrn.com ([209.234.97.14] helo=www.endace.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GzRNO-0007vD-42
	for nfs@lists.sourceforge.net; Tue, 26 Dec 2006 21:30:54 -0800
Received: from et.endace.com (203-97-51-114.dsl.clear.net.nz [203.97.51.114])
	by www.endace.com (8.13.4/8.12.10) with ESMTP id kBR5UfDH092957
	for <nfs@lists.sourceforge.net>; Tue, 26 Dec 2006 21:30:41 -0800 (PST)
Received: from julia.et.endace.com (julia.et.endace.com [192.168.64.33])
	(authenticated bits=0)
	by et.endace.com (8.13.5/8.12.11) with ESMTP id kBR5UcS2048338
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 27 Dec 2006 18:30:38 +1300 (NZDT)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-mAD+Mo6RWfmurb+UKPnl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

     I am trying to get nfs-rdma working over Infiniband, and got an
input/output error when I tried to mount a remote directory. Before the
details, I don't have rpc.statd running on the machines (nfs-utils has
been installed, but rpc.statd wasn't there..)Following are the details:-

The exact error:-
./nfsrdmamount -d -o rdma=10.0.0.1 10.0.0.1:/data /mnt
Doing nfs/rdma mount to 10.0.0.1, mount protocol to 10.0.0.1
nfsmount: Input/output error

The export file on the server:-
/data   192.168.64.118(rw,async)
10.0.0.2(rw,async,insecure,no_root_squash)

I have attached the relevant section from dmesg on the client side..Is
it because rpc.statd is missing, or something else ?
Thanks a lot for your time!

Vishal

--=-mAD+Mo6RWfmurb+UKPnl
Content-Disposition: attachment; filename=dmesg.txt
Content-Type: text/plain; name=dmesg.txt; charset=UTF-8
Content-Transfer-Encoding: 7bit

RPC:       rpciod_up: users 1
RPC:       xprt_setup_rdma: 10.0.0.1:2050
RPC:       rpcrdma_ep_create: requested max: dtos: send 50 recv 50; iovs: send 2 recv 1
RPC:       rpcrdma_buffer_create: max_requests 50
RPC:       created transport ffff810158e8e000 with 50 slots
RPC:       creating nfs client for 10.0.0.1 (xprt ffff810158e8e000)
RPC: creating nfs client for 10.0.0.1 (xprt ffff810158e8e000)
RPC:       creating UNIX authenticator for client ffff810157a87200
RPC:    54 new task procpid 6402
RPC:    54 allocated task
RPC:    54 holding UNIX cred ffffffff807285a0
RPC:    54 rpc_execute flgs 680
RPC:    54 call_start nfs3 proc 0 (sync)
RPC:    54 call_reserve
RPC:    54 reserved req ffff810152190000 xid 8e40bd13
RPC:    54 call_reserveresult (status 0)
RPC:    54 call_allocate (status 0)
RPC:       xprt_rdma_allocate: size 2048, request 0xffff810156564000
RPC:    54 call_bind (status 0)
RPC:    54 call_connect xprt ffff810158e8e000 is not connected
RPC:    54 xprt_connect xprt ffff810158e8e000 is not connected
RPC:       xprt_rdma_reserve_xprt: cwndscale 256
RPC:    54 xprt_cwnd_limited cong = 0 cwnd = 256
RPC:    54 sleep_on(queue "xprt_pending" time 4296176728)
RPC:    54 added to queue ffff810158e8e1c8 "xprt_pending"
RPC:    54 setting alarm for 60000 ms
RPC:       xprt_rdma_connect_worker: connect
RPC:       rpcrdma_conn_upcall: rejected: 10.0.0.1:2050 (ep 0xffff810158e8e400 event 0x8)
RPC:       rpcrdma_conn_upcall: disconnected
RPC:       rpcrdma_ep_connect: non-peer_reject, retry
RPC:       rpcrdma_ep_connect: rdma_connect() failed with -22
RPC:    54 __rpc_wake_up_task (now 4296176729)
RPC:    54 disabling timer
RPC:    54 removed from queue ffff810158e8e1c8 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xprt_rdma_connect_worker: exit
RPC:    54 deleting timer
RPC:    54 xprt_connect_status: error 22 connecting to server 10.0.0.1
RPC:    54 call_connect_status (status -5)
RPC:    54 return 0, status -5
RPC:    54 release task
RPC:       wake_up_next(ffff810158e8e178 "xprt_resend")
RPC:       wake_up_next(ffff810158e8e128 "xprt_sending")
RPC:       xprt_rdma_free: called on 0xffff810155ea8000
RPC:    54 release request ffff810152190000
RPC:       wake_up_next(ffff810158e8e218 "xprt_backlog")
RPC:    54 releasing UNIX cred ffffffff807285a0
RPC:       rpc_release_client(ffff810157a87200, 1)
RPC:    54 freeing task
RPC:       shutting down nfs client for 10.0.0.1, tasks=0
RPC:       destroying nfs client for 10.0.0.1
RPC:       destroying UNIX authenticator ffffffff80728720
RPC:       destroying transport ffff810158e8e000
RPC:       xprt_rdma_destroy: called
RPC:       rpcrdma_buffer_destroy: entering
RPC:       rpcrdma_ep_destroy: entering, connected is -22
RPC:       rpcrdma_ep_disconnect: after wait, disconnected
RPC:       rpcrdma_ia_close: entering
RPC:       rpcrdma_ia_close: ib_dereg_mr returned 0
RPC:       rpcrdma_ia_close: ib_dealloc_pd returned 0
RPC:       xprt_rdma_destroy: returning
nfs_create_client: cannot create RPC client. Error = -5
RPC:       rpciod_down sema 2

--=-mAD+Mo6RWfmurb+UKPnl
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-mAD+Mo6RWfmurb+UKPnl
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-mAD+Mo6RWfmurb+UKPnl--
