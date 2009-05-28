From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd fixes for 2.6.30
Date: Thu, 28 May 2009 17:52:45 -0400
Message-ID: <20090528215245.GA17249@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	Jim Rees <rees@umich.edu>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50706 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbZE1VxN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 17:53:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd bugfixes from the for-2.6.30 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.30

(Note also the reverted patch addresses the regression tracked by Bug
#13323.)

--b.

J. Bruce Fields (1):
      nfsd: Revert "svcrpc: take advantage of tcp autotuning"

Steve Wise (1):
      svcrdma: dma unmap the correct length for the RPCRDMA header page.

Wei Yongjun (1):
      nfsd: fix hung up of nfs client while sync write data to nfs server

 fs/nfsd/vfs.c                            |    6 ++--
 net/sunrpc/svcsock.c                     |   35 ++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   12 +++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 ++++----
 4 files changed, 42 insertions(+), 21 deletions(-)

commit 98779be861a05c4cb75bed916df72ec0cba8b53d
Author: Steve Wise <swise@opengridcomputing.com>
Date:   Thu May 14 16:34:28 2009 -0500

    svcrdma: dma unmap the correct length for the RPCRDMA header page.
    
    The svcrdma module was incorrectly unmapping the RPCRDMA header page.
    On IBM pserver systems this causes a resource leak that results in
    running out of bus address space (10 cthon iterations will reproduce it).
    The code was mapping the full page but only unmapping the actual header
    length.  The fix is to only map the header length.
    
    I also cleaned up the use of ib_dma_map_page() calls since the unmap
    logic always uses ib_dma_unmap_single().  I made these symmetrical.
    
    Signed-off-by: Steve Wise <swise@opengridcomputing.com>
    Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 8b510c5..f11be72 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -128,7 +128,8 @@ static int fast_reg_xdr(struct svcxprt_rdma *xprt,
 		page_bytes -= sge_bytes;
 
 		frmr->page_list->page_list[page_no] =
-			ib_dma_map_page(xprt->sc_cm_id->device, page, 0,
+			ib_dma_map_single(xprt->sc_cm_id->device,
+					  page_address(page),
 					  PAGE_SIZE, DMA_TO_DEVICE);
 		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
 					 frmr->page_list->page_list[page_no]))
@@ -532,18 +533,17 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		clear_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
 
 	/* Prepare the SGE for the RPCRDMA Header */
+	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
+	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
 	ctxt->sge[0].addr =
-		ib_dma_map_page(rdma->sc_cm_id->device,
-				page, 0, PAGE_SIZE, DMA_TO_DEVICE);
+		ib_dma_map_single(rdma->sc_cm_id->device, page_address(page),
+				  ctxt->sge[0].length, DMA_TO_DEVICE);
 	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr))
 		goto err;
 	atomic_inc(&rdma->sc_dma_used);
 
 	ctxt->direction = DMA_TO_DEVICE;
 
-	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
-	ctxt->sge[0].lkey = rdma->sc_dma_lkey;
-
 	/* Determine how many of our SGE are to be transmitted */
 	for (sge_no = 1; byte_count && sge_no < vec->count; sge_no++) {
 		sge_bytes = min_t(size_t, vec->sge[sge_no].iov_len, byte_count);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4b0c2fa..5151f9f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -500,8 +500,8 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt)
 		BUG_ON(sge_no >= xprt->sc_max_sge);
 		page = svc_rdma_get_page();
 		ctxt->pages[sge_no] = page;
-		pa = ib_dma_map_page(xprt->sc_cm_id->device,
-				     page, 0, PAGE_SIZE,
+		pa = ib_dma_map_single(xprt->sc_cm_id->device,
+				     page_address(page), PAGE_SIZE,
 				     DMA_FROM_DEVICE);
 		if (ib_dma_mapping_error(xprt->sc_cm_id->device, pa))
 			goto err_put_ctxt;
@@ -1315,8 +1315,8 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	length = svc_rdma_xdr_encode_error(xprt, rmsgp, err, va);
 
 	/* Prepare SGE for local address */
-	sge.addr = ib_dma_map_page(xprt->sc_cm_id->device,
-				   p, 0, PAGE_SIZE, DMA_FROM_DEVICE);
+	sge.addr = ib_dma_map_single(xprt->sc_cm_id->device,
+				   page_address(p), PAGE_SIZE, DMA_FROM_DEVICE);
 	if (ib_dma_mapping_error(xprt->sc_cm_id->device, sge.addr)) {
 		put_page(p);
 		return;
@@ -1343,7 +1343,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	if (ret) {
 		dprintk("svcrdma: Error %d posting send for protocol error\n",
 			ret);
-		ib_dma_unmap_page(xprt->sc_cm_id->device,
+		ib_dma_unmap_single(xprt->sc_cm_id->device,
 				  sge.addr, PAGE_SIZE,
 				  DMA_FROM_DEVICE);
 		svc_rdma_put_context(ctxt, 1);

commit 7f4218354fe312b327af06c3d8c95ed5f214c8ca
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed May 27 18:51:06 2009 -0400

    nfsd: Revert "svcrpc: take advantage of tcp autotuning"
    
    This reverts commit 47a14ef1af48c696b214ac168f056ddc79793d0e "svcrpc:
    take advantage of tcp autotuning", which uncovered some further problems
    in the server rpc code, causing significant performance regressions in
    common cases.
    
    We will likely reinstate this patch after releasing 2.6.30 and applying
    some work on the underlying fixes to the problem (developed by Trond).
    
    Reported-by: Jeff Moyer <jmoyer@redhat.com>
    Cc: Olga Kornievskaia <aglo@citi.umich.edu>
    Cc: Jim Rees <rees@umich.edu>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index af31988..9d50423 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -345,6 +345,7 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;
+	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
 	release_sock(sock->sk);
 #endif
 }
@@ -796,6 +797,23 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags),
 		test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags));
 
+	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
+		/* sndbuf needs to have room for one request
+		 * per thread, otherwise we can stall even when the
+		 * network isn't a bottleneck.
+		 *
+		 * We count all threads rather than threads in a
+		 * particular pool, which provides an upper bound
+		 * on the number of threads which will access the socket.
+		 *
+		 * rcvbuf just needs to be able to hold a few requests.
+		 * Normally they will be removed from the queue
+		 * as soon a a complete request arrives.
+		 */
+		svc_sock_setbufsize(svsk->sk_sock,
+				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
+				    3 * serv->sv_max_mesg);
+
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
 	/* Receive data. If we haven't got the record length yet, get
@@ -1043,6 +1061,15 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
+		/* initialise setting must have enough space to
+		 * receive and respond to one request.
+		 * svc_tcp_recvfrom will re-adjust if necessary
+		 */
+		svc_sock_setbufsize(svsk->sk_sock,
+				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
+				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
+
+		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		if (sk->sk_state != TCP_ESTABLISHED)
 			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
@@ -1112,14 +1139,8 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
 		svc_udp_init(svsk, serv);
-	else {
-		/* initialise setting must have enough space to
-		 * receive and respond to one request.
-		 */
-		svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
-					4 * serv->sv_max_mesg);
+	else
 		svc_tcp_init(svsk, serv);
-	}
 
 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
 				svsk, svsk->sk_sk);

commit a0d24b295aed7a9daf4ca36bd4784e4d40f82303
Author: Wei Yongjun <yjwei@cn.fujitsu.com>
Date:   Tue May 19 12:03:15 2009 +0800

    nfsd: fix hung up of nfs client while sync write data to nfs server
    
    Commit 'Short write in nfsd becomes a full write to the client'
    (31dec2538e45e9fff2007ea1f4c6bae9f78db724) broken the sync write.
    With the following commands to reproduce:
    
      $ mount -t nfs -o sync 192.168.0.21:/nfsroot /mnt
      $ cd /mnt
      $ echo aaaa > temp.txt
    
    Then nfs client is hung up.
    
    In SYNC mode the server alaways return the write count 0 to the
    client. This is because the value of host_err in nfsd_vfs_write()
    will be overwrite in SYNC mode by 'host_err=nfsd_sync(file);',
    and then we return host_err(which is now 0) as write count.
    
    This patch fixed the problem.
    
    Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6c68ffd..b660435 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1015,6 +1015,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
 	set_fs(oldfs);
 	if (host_err >= 0) {
+		*cnt = host_err;
 		nfsdstats.io_write += host_err;
 		fsnotify_modify(file->f_path.dentry);
 	}
@@ -1060,10 +1061,9 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	}
 
 	dprintk("nfsd: write complete host_err=%d\n", host_err);
-	if (host_err >= 0) {
+	if (host_err >= 0)
 		err = 0;
-		*cnt = host_err;
-	} else
+	else
 		err = nfserrno(host_err);
 out:
 	return err;
