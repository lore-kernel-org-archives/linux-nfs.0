From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd fixes for 2.6.27
Date: Mon, 1 Sep 2008 14:46:13 -0400
Message-ID: <20080901184613.GB8598@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43820 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbYIASqP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Sep 2008 14:46:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following nfsd bugfixes are available in for-2.6.27 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.27

--b.

Andy Adamson (1):
      nfsd: fix compound state allocation error handling

Cyrill Gorcunov (1):
      sunrpc: fix possible overrun on read of /proc/sys/sunrpc/transports

J. Bruce Fields (1):
      nfsd: fix buffer overrun decoding NFSv4 acl

Tom Tucker (1):
      svcrdma: Fix race between svc_rdma_recvfrom thread and the dto_tasklet

 fs/nfsd/nfs4acl.c                        |    2 +-
 fs/nfsd/nfs4proc.c                       |   12 ++++++------
 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/sysctl.c                      |   18 ++++--------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    8 ++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 ++---
 6 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index b6ed383..54b8b41 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -443,7 +443,7 @@ init_state(struct posix_acl_state *state, int cnt)
 	 * enough space for either:
 	 */
 	alloc = sizeof(struct posix_ace_state_array)
-		+ cnt*sizeof(struct posix_ace_state);
+		+ cnt*sizeof(struct posix_user_ace_state);
 	state->users = kzalloc(alloc, GFP_KERNEL);
 	if (!state->users)
 		return -ENOMEM;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2e51ada..e5b51ff 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -867,11 +867,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	int		slack_bytes;
 	__be32		status;
 
-	status = nfserr_resource;
-	cstate = cstate_alloc();
-	if (cstate == NULL)
-		goto out;
-
 	resp->xbuf = &rqstp->rq_res;
 	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
 	resp->tagp = resp->p;
@@ -890,6 +885,11 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (args->minorversion > NFSD_SUPPORTED_MINOR_VERSION)
 		goto out;
 
+	status = nfserr_resource;
+	cstate = cstate_alloc();
+	if (cstate == NULL)
+		goto out;
+
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
@@ -957,9 +957,9 @@ encode_op:
 		nfsd4_increment_op_stats(op->opnum);
 	}
 
+	cstate_free(cstate);
 out:
 	nfsd4_release_compoundargs(args);
-	cstate_free(cstate);
 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
 	return status;
 }
diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index ef2e3a2..dc05b54 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -143,7 +143,6 @@ struct svcxprt_rdma {
 	unsigned long	     sc_flags;
 	struct list_head     sc_dto_q;		/* DTO tasklet I/O pending Q */
 	struct list_head     sc_read_complete_q;
-	spinlock_t           sc_read_complete_lock;
 	struct work_struct   sc_work;
 };
 /* sc_flags */
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 0f8c439..5231f7a 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -60,24 +60,14 @@ static int proc_do_xprt(ctl_table *table, int write, struct file *file,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char tmpbuf[256];
-	int len;
+	size_t len;
+
 	if ((*ppos && !write) || !*lenp) {
 		*lenp = 0;
 		return 0;
 	}
-	if (write)
-		return -EINVAL;
-	else {
-		len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
-		if (!access_ok(VERIFY_WRITE, buffer, len))
-			return -EFAULT;
-
-		if (__copy_to_user(buffer, tmpbuf, len))
-			return -EFAULT;
-	}
-	*lenp -= len;
-	*ppos += len;
-	return 0;
+	len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
+	return simple_read_from_buffer(buffer, *lenp, ppos, tmpbuf, len);
 }
 
 static int
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index b4b17f4..74de31a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -443,18 +443,18 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 	dprintk("svcrdma: rqstp=%p\n", rqstp);
 
-	spin_lock_bh(&rdma_xprt->sc_read_complete_lock);
+	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
 	if (!list_empty(&rdma_xprt->sc_read_complete_q)) {
 		ctxt = list_entry(rdma_xprt->sc_read_complete_q.next,
 				  struct svc_rdma_op_ctxt,
 				  dto_q);
 		list_del_init(&ctxt->dto_q);
 	}
-	spin_unlock_bh(&rdma_xprt->sc_read_complete_lock);
-	if (ctxt)
+	if (ctxt) {
+		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
 		return rdma_read_complete(rqstp, ctxt);
+	}
 
-	spin_lock_bh(&rdma_xprt->sc_rq_dto_lock);
 	if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
 		ctxt = list_entry(rdma_xprt->sc_rq_dto_q.next,
 				  struct svc_rdma_op_ctxt,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 19ddc38..900cb69 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -359,11 +359,11 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
 			if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
 				struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
 				BUG_ON(!read_hdr);
+				spin_lock_bh(&xprt->sc_rq_dto_lock);
 				set_bit(XPT_DATA, &xprt->sc_xprt.xpt_flags);
-				spin_lock_bh(&xprt->sc_read_complete_lock);
 				list_add_tail(&read_hdr->dto_q,
 					      &xprt->sc_read_complete_q);
-				spin_unlock_bh(&xprt->sc_read_complete_lock);
+				spin_unlock_bh(&xprt->sc_rq_dto_lock);
 				svc_xprt_enqueue(&xprt->sc_xprt);
 			}
 			svc_rdma_put_context(ctxt, 0);
@@ -428,7 +428,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 
 	spin_lock_init(&cma_xprt->sc_lock);
-	spin_lock_init(&cma_xprt->sc_read_complete_lock);
 	spin_lock_init(&cma_xprt->sc_rq_dto_lock);
 
 	cma_xprt->sc_ord = svcrdma_ord;
