From: Greg Banks <gnb@sgi.com>
Subject: [RFC, PATCH 3/5] knfsd: remove nfsrdma defer and revisit code
Date: Thu, 24 May 2007 00:33:39 +1000
Message-ID: <20070523143339.GK14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqruI-00052X-R1
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:33:49 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HqruL-0002IL-C1
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:33:45 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Remove the NFS/RDMA code which handles deferring and revisiting
calls.  This is redundant now as the generic code handles it.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svc_rdma.h |    1 
 net/sunrpc/svc_rdma_marshal.c   |   56 --------------------
 net/sunrpc/svc_rdma_recvfrom.c  |   71 -------------------------
 net/sunrpc/svc_rdma_transport.c |   81 -----------------------------
 4 files changed, 209 deletions(-)

Index: linux-2.6.16/net/sunrpc/svc_rdma_recvfrom.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svc_rdma_recvfrom.c	2007-04-12 14:45:37.608880224 +1000
+++ linux-2.6.16/net/sunrpc/svc_rdma_recvfrom.c	2007-05-23 22:58:53.739474316 +1000
@@ -394,74 +394,6 @@ static int rdma_read_xdr(struct svcxprt_
 	return ret;
 }
 
-static struct svc_deferred_req *
-svc_rdma_deferred_dequeue(struct svc_sock *xprt)
-{
-	struct svc_deferred_req *dr = NULL;
-	spin_lock_bh(&xprt->sk_server->sv_lock);
-	clear_bit(SK_DEFERRED, &xprt->sk_flags);
-	if (!list_empty(&xprt->sk_deferred)) {
-		dr = list_entry(xprt->sk_deferred.next,
-				struct svc_deferred_req,
-				handle.recent);
-		list_del_init(&dr->handle.recent);
-		set_bit(SK_DEFERRED, &xprt->sk_flags);
-	}
-	spin_unlock_bh(&xprt->sk_server->sv_lock);
-	return dr;
-}
-
-static int svc_rdma_deferred_recv(struct svc_rqst *rqstp)
-{
-	struct svc_sock *xprt = rqstp->rq_sock;
-	struct svcxprt_rdma *rdma_xprt = (struct svcxprt_rdma*)xprt;
-	struct svc_rdma_deferred_req *dr =
-		(struct svc_rdma_deferred_req *)rqstp->rq_deferred;
-	void *page_va;
-	int ret;
-	int len;
-
-	page_va = page_address(dr->arg_page);
-	dprintk("svcrdma: satisfying receive from deferred req=%p\n"
-		"\tpage=%p, page va=%p\n\targ_len=%d\n",
-		dr, dr->arg_page, page_va,
-		dr->arg_len);
-	DBG_DUMP_RDMAHDR(__FUNCTION__, page_va);
-
-	/* Rebuild the thread context */
-	rqstp->rq_prot = IPPROTO_MAX;
-	memcpy(&rqstp->rq_addr,
-	       &rdma_xprt->sc_cm_id->route.addr.dst_addr,
-	       sizeof(rqstp->rq_addr));
-	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
-
-	rqstp->rq_argused = 1;
-	put_page(rqstp->rq_argpages[0]);
-	rqstp->rq_argpages[0] = dr->arg_page;
-	rqstp->rq_arg.head[0].iov_base = page_va;
-	rqstp->rq_arg.head[0].iov_len = dr->arg_len;
-	rqstp->rq_arg.tail[0].iov_base = NULL;
-	rqstp->rq_arg.tail[0].iov_len = 0;
-	rqstp->rq_arg.pages = NULL;
-	rqstp->rq_arg.page_base = 0;
-	rqstp->rq_arg.page_len = 0;
-	rqstp->rq_arg.len = dr->arg_len;
-
-	len = svc_rdma_xdr_decode_deferred_req(rqstp);
-	DBG_DUMP_XDR(__FUNCTION__, &rqstp->rq_arg);
-
-	ret = rqstp->rq_arg.head[0].iov_len
-		+ rqstp->rq_arg.page_len
-		+ rqstp->rq_arg.tail[0].iov_len;
-
-	rqstp->rq_deferred = NULL;
-	kfree(dr);
-
-	clear_bit(SK_BUSY, &xprt->sk_flags);
-	svc_sock_enqueue(xprt);
-	return ret;
-}
-
 /*
  * Set up the rqstp thread context to point to the RQ buffer. If necessary,
  * pull additional data from the client with an RDMA_READ request.
@@ -478,9 +410,6 @@ int svc_rdma_recvfrom(struct svc_rqst *r
 	unsigned long flags;
 
 	dprintk("svcrdma: rqstp=%p\n", rqstp);
-	if (unlikely(test_bit(SK_DEFERRED, &xprt->sk_flags)))
-		if ((rqstp->rq_deferred = svc_rdma_deferred_dequeue(xprt)))
-			return svc_rdma_deferred_recv(rqstp);
 
  poll_dto_q:
 	/*
Index: linux-2.6.16/net/sunrpc/svc_rdma_transport.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svc_rdma_transport.c	2007-04-12 14:45:37.596881800 +1000
+++ linux-2.6.16/net/sunrpc/svc_rdma_transport.c	2007-05-23 22:58:53.827463011 +1000
@@ -64,8 +64,6 @@ static int svc_rdma_accept(struct svc_so
 static void rdma_destroy_xprt(struct svcxprt_rdma *xprt);
 static int svc_rdma_prepare_reply(struct svc_rqst *rqstp);
 static void dto_tasklet_func(unsigned long data);
-static struct cache_deferred_req *svc_rdma_defer(struct cache_req *req);
-static void svc_rdma_revisit(struct cache_deferred_req *dreq, int too_many);
 
 DECLARE_TASKLET(dto_tasklet, dto_tasklet_func, 0UL);
 static spinlock_t dto_lock = SPIN_LOCK_UNLOCKED;
@@ -1059,82 +1057,3 @@ static int svc_rdma_prepare_reply(struct
 	return 0;
 }
 
-/*
- * This request cannot be handled right now. Allocate a structure to
- * keep it's state pending completion processing. To accomplish this, the
- * function creates an svc_rdma_op_ctxt that looks like a receive completion and
- * enqueues it on the svc_sock's deferred request list.  When*
- * svc_rdma_recvfrom is subsequently called, it first checks if there is a
- * deferred RPC and if there is:
- * - Takes the deferred request off the deferred request queue
- * - Extracts the svc_rdma_op_ctxt from the deferred request structure
- * - Frees the deferred request structure
- * - Skips the ib_cq_poll call and processes the svc_rdma_op_ctxt as if it had
- *   just come out of an WR pulled from the CQ.
- */
-static struct cache_deferred_req *
-svc_rdma_defer(struct cache_req *req)
-{
-	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
-	struct svcxprt_rdma *xprt;
-	struct svc_rdma_deferred_req *dr;
-
-	dprintk("svcrdma: deferring request on rqstp=%p\n", rqstp);
-
-	/* if more than a page, give up FIXME */
-	if (rqstp->rq_arg.page_len)
-		return NULL;
-	BUG_ON(rqstp->rq_deferred);
-	xprt = (struct svcxprt_rdma*)rqstp->rq_sock;
- retry:
-	dr = kmalloc(sizeof(struct svc_rdma_deferred_req), GFP_KERNEL);
-	if (!dr) {
-		printk(KERN_INFO "svcrdma: sleeping waiting for memory\n");
-		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
-		goto retry;
-	}
-	dr->req.handle.owner = rqstp->rq_server;
-	dr->req.prot = rqstp->rq_prot;
-	memcpy(&dr->req.addr, &rqstp->rq_addr, rqstp->rq_addrlen);
-	dr->req.daddr = rqstp->rq_daddr;
-	dr->arg_page = rqstp->rq_argpages[0];
-	dr->arg_len = rqstp->rq_arg.len;
-	rqstp->rq_argpages[0] = svc_rdma_get_page();
-
-	spin_lock_bh(&rqstp->rq_server->sv_lock);
-// 	rqstp->rq_sock->sk_inuse++;
-	dr->req.svsk = rqstp->rq_sock;
-// 	dr->req.handle.revisit = svc_revisit;
-	spin_unlock_bh(&rqstp->rq_server->sv_lock);
-
-	return &dr->req.handle;
-}
-
-/*
- * This is called by the cache code when it either gets an answer from
- * a user-mode daemon or gives up...as indicated by 'too_many'
- */
-static void svc_rdma_revisit(struct cache_deferred_req *dreq, int too_many)
-{
-	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
-	struct svc_serv *serv = dreq->owner;
-	struct svc_sock *svsk;
-
-	if (unlikely(too_many)) {
-		printk(KERN_INFO "svcrdma: giving up on deferred request "
-		       "on svc_sock=%p, too many outstanding\n",dr->svsk);
-		svc_sock_put(dr->svsk);
-		kfree(dr);
-		return;
-	}
-	svsk = dr->svsk;
-	dprintk("svcrdma: revisit deferred RPC on xprt=%p\n", svsk);
-	dr->svsk = NULL;
-	spin_lock_bh(&serv->sv_lock);
-	list_add(&dr->handle.recent, &svsk->sk_deferred);
-	spin_unlock_bh(&serv->sv_lock);
-	set_bit(SK_DEFERRED, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
-	svc_sock_put(svsk);
-}
-
Index: linux-2.6.16/include/linux/sunrpc/svc_rdma.h
===================================================================
--- linux-2.6.16.orig/include/linux/sunrpc/svc_rdma.h	2007-05-23 22:58:53.000000000 +1000
+++ linux-2.6.16/include/linux/sunrpc/svc_rdma.h	2007-05-23 23:01:01.927002977 +1000
@@ -140,7 +140,6 @@ struct svcxprt_rdma {
 /* svc_rdma_marshal.c */
 extern void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *, int *, int *);
 extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg**, struct svc_rqst *);
-extern int svc_rdma_xdr_decode_deferred_req(struct svc_rqst *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma*, struct rpcrdma_msg*,
 				     enum rpcrdma_errcode, u32*);
 extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
Index: linux-2.6.16/net/sunrpc/svc_rdma_marshal.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svc_rdma_marshal.c	2007-05-23 22:58:41.000000000 +1000
+++ linux-2.6.16/net/sunrpc/svc_rdma_marshal.c	2007-05-23 22:59:39.697569530 +1000
@@ -266,62 +266,6 @@ int svc_rdma_xdr_decode_req(struct rpcrd
 	return hdr_len;
 }
 
-int svc_rdma_xdr_decode_deferred_req(struct svc_rqst *rqstp)
-{
-	struct rpcrdma_msg *rmsgp = NULL;
-	struct rpcrdma_read_chunk *ch;
-	struct rpcrdma_write_array *ary;
-	u32 *va;
-	u32 hdrlen;
-
-	dprintk("svcrdma: processing deferred RDMA header on rqstp=%p\n",
-		rqstp);
-	rmsgp = (struct rpcrdma_msg*)rqstp->rq_arg.head[0].iov_base;
-
-	/* Pull in the extra for the padded case and bump our pointer */
-	if (rmsgp->rm_type == RDMA_MSGP) {
-		va = &rmsgp->rm_body.rm_padded.rm_pempty[4];
-		rqstp->rq_arg.head[0].iov_base = va;
-		hdrlen = (u32)((unsigned long)va - (unsigned long)rmsgp);
-		rqstp->rq_arg.head[0].iov_len -= hdrlen;
-		return hdrlen;
-	}
-
-	/*
-	 * Skip all chunks to find RPC msg. These were previously processed
-	 */
-	va = &rmsgp->rm_body.rm_chunks[0];
-
-	/* Skip read-list */
-	for (ch = (struct rpcrdma_read_chunk*)va;
-	     ch->rc_discrim != xdr_zero; ch++);
-	va = (u32*)&ch->rc_position;
-
-	/* Skip write-list */
-	ary = (struct rpcrdma_write_array*)va;
-	if (ary->wc_discrim == xdr_zero)
-		va = (u32*)&ary->wc_nchunks;
-	else
-		/*
-		 * rs_length is the 2nd 4B field in wc_target and taking its
-		 * address skips the list terminator
-		 */
-		va = (u32*)&ary->wc_array[ary->wc_nchunks].wc_target.rs_length;
-
-	/* Skip reply-array */
-	ary = (struct rpcrdma_write_array*)va;
-	if (ary->wc_discrim == xdr_zero)
-		va = (u32*)&ary->wc_nchunks;
-	else
-		va = (u32*)&ary->wc_array[ary->wc_nchunks];
-
-	rqstp->rq_arg.head[0].iov_base = va;
-	hdrlen = (unsigned long)va - (unsigned long)rmsgp;
-	rqstp->rq_arg.head[0].iov_len -= hdrlen;
-
-	return hdrlen;
-}
-
 int svc_rdma_xdr_encode_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 			  enum rpcrdma_errcode err, u32 *va)
 {
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
