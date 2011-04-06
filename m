Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39849 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756967Ab1DFXGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] svcrpc: copy cb reply instead of pages
Date: Wed,  6 Apr 2011 19:06:24 -0400
Message-Id: <1302131186-6578-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1302131186-6578-1-git-send-email-bfields@redhat.com>
References: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

It's much simpler just to copy the cb reply data than to play tricks
with pages.  Callback replies will typically be very small (at least
until we implement cb_getattr, in which case files with very long ACLs
could pose a problem), so there's no loss in efficiency.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |  122 +++++++++++++++++++++++---------------------------
 1 files changed, 56 insertions(+), 66 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 9d72a79..f248bd4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -975,57 +975,58 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	return -EAGAIN;
 }
 
-static int svc_process_calldir(struct svc_sock *svsk, struct svc_rqst *rqstp,
-			       struct rpc_rqst **reqpp, struct kvec *vec)
+static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 {
+	struct rpc_xprt *bc_xprt = svsk->sk_xprt.xpt_bc_xprt;
 	struct rpc_rqst *req = NULL;
-	__be32 *p;
+	struct kvec *src, *dst;
+	__be32 *p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	__be32 xid;
 	__be32 calldir;
-	int len;
-
-	len = svc_recvfrom(rqstp, vec, 1, 8);
-	if (len < 0)
-		goto error;
 
-	p = (u32 *)rqstp->rq_arg.head[0].iov_base;
 	xid = *p++;
 	calldir = *p;
 
-	if (calldir == 0) {
-		/* REQUEST is the most common case */
-		vec[0] = rqstp->rq_arg.head[0];
-	} else {
-		/* REPLY */
-		struct rpc_xprt *bc_xprt = svsk->sk_xprt.xpt_bc_xprt;
-
-		if (bc_xprt)
-			req = xprt_lookup_rqst(bc_xprt, xid);
-
-		if (!req) {
-			printk(KERN_NOTICE
-				"%s: Got unrecognized reply: "
-				"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
-				__func__, ntohl(calldir),
-				bc_xprt, xid);
-			vec[0] = rqstp->rq_arg.head[0];
-			goto out;
-		}
+	if (bc_xprt)
+		req = xprt_lookup_rqst(bc_xprt, xid);
 
-		memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
-		       sizeof(struct xdr_buf));
-		/* copy the xid and call direction */
-		memcpy(req->rq_private_buf.head[0].iov_base,
-		       rqstp->rq_arg.head[0].iov_base, 8);
-		vec[0] = req->rq_private_buf.head[0];
+	if (!req) {
+		printk(KERN_NOTICE
+			"%s: Got unrecognized reply: "
+			"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
+			__func__, ntohl(calldir),
+			bc_xprt, xid);
+		return -EAGAIN;
 	}
- out:
-	vec[0].iov_base += 8;
-	vec[0].iov_len -= 8;
-	len = svsk->sk_reclen - 8;
- error:
-	*reqpp = req;
-	return len;
+
+	memcpy(&req->rq_private_buf, &req->rq_rcv_buf, sizeof(struct xdr_buf));
+	/*
+	 * XXX!: cheating for now!  Only copying HEAD.
+	 * But we know this is good enough for now (in fact, for any
+	 * callback reply in the forseeable future).
+	 */
+	dst = &req->rq_private_buf.head[0];
+	src = &rqstp->rq_arg.head[0];
+	if (dst->iov_len < src->iov_len)
+		return -EAGAIN; /* whatever; just giving up. */
+	memcpy(dst->iov_base, src->iov_base, src->iov_len);
+	xprt_complete_rqst(req->rq_task, svsk->sk_reclen);
+	rqstp->rq_arg.len = 0;
+	return 0;
+}
+
+static int copy_pages_to_kvecs(struct kvec *vec, struct page **pages, int len)
+{
+	int i = 0;
+	int t = 0;
+
+	while (t < len) {
+		vec[i].iov_base = page_address(pages[i]);
+		vec[i].iov_len = PAGE_SIZE;
+		i++;
+		t += PAGE_SIZE;
+	}
+	return i;
 }
 
 /*
@@ -1038,8 +1039,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
-	struct rpc_rqst *req = NULL;
-	unsigned int vlen;
+	__be32 *p;
+	__be32 calldir;
 	int pnum;
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
@@ -1052,35 +1053,17 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		goto error;
 
 	vec = rqstp->rq_vec;
-	vec[0] = rqstp->rq_arg.head[0];
-	vlen = PAGE_SIZE;
 
-	len = svc_process_calldir(svsk, rqstp, &req, vec);
-	if (len < 0)
-		goto err_again;
-	vlen -= 8;
-
-	pnum = 1;
-	while (vlen < svsk->sk_reclen - 8) {
-		vec[pnum].iov_base = (req) ?
-			page_address(req->rq_private_buf.pages[pnum - 1]) :
-			page_address(rqstp->rq_pages[pnum]);
-		vec[pnum].iov_len = PAGE_SIZE;
-		pnum++;
-		vlen += PAGE_SIZE;
-	}
+	pnum = copy_pages_to_kvecs(&vec[0], &rqstp->rq_pages[0],
+						svsk->sk_reclen);
+
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
 
 	/* Now receive data */
-	len = svc_recvfrom(rqstp, vec, pnum, svsk->sk_reclen - 8);
+	len = svc_recvfrom(rqstp, vec, pnum, svsk->sk_reclen);
 	if (len < 0)
 		goto err_again;
 
-	if (req) {
-		xprt_complete_rqst(req->rq_task, svsk->sk_reclen);
-		rqstp->rq_arg.len = 0;
-		goto out;
-	}
 	dprintk("svc: TCP complete record (%d bytes)\n", svsk->sk_reclen);
 	rqstp->rq_arg.len = svsk->sk_reclen;
 	rqstp->rq_arg.page_base = 0;
@@ -1093,7 +1076,14 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
-out:
+	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
+	calldir = p[1];
+	if (calldir) {
+		len = receive_cb_reply(svsk, rqstp);
+		if (len < 0)
+			goto err_again;
+	}
+
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
-- 
1.7.1

