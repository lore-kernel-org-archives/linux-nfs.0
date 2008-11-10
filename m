From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 41/51] sunrpc: Add deferral save and restore state callback
Date: Mon, 10 Nov 2008 22:54:46 +0200
Message-ID: <1226350486-11655-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57445 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbYKJUy7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:54:59 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSv4 needs to restart deferred processing at the operation which caused the
deferral.

Add a callback and a defer_data pointer in svc_rqst to enable svc_defer to
save partial result state in the deferral request.

Add page pointer storage and resused fields to svc_deferred_req to store
the pointers to the partially processed request.

Add callbacks and a defer_data pointer in svc_deferred_request to enable
svc_deferred_recv to restore and release the partial result state.

The rq_save_state callback sets the deferral request restore_state callback and
defer_data.

The svc_deferred_req defer_data and result pages survive multiple deferral
processing caveat resetting in the save and restore callbacks.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/svc.h |   10 ++++++++++
 net/sunrpc/svc_xprt.c      |   19 +++++++++++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 7653dd3..d86111f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -227,6 +227,9 @@ struct svc_rqst {
 	struct svc_cred		rq_cred;	/* auth info */
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
+	/* callback to save deferred request state */
+	void (*rq_save_state)(struct svc_rqst *, struct svc_deferred_req *);
+	void			*rq_defer_data; /* defer state data to save */
 
 	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
@@ -335,6 +338,13 @@ struct svc_deferred_req {
 	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	size_t			xprt_hlen;
+	/* callbacks to restore and release deferred request state
+	 * set in rq_save_state */
+	void (*restore_state)(struct svc_rqst *, struct svc_deferred_req *);
+	void (*release_state)(struct svc_deferred_req *);
+	void			*defer_data; /* defer state data */
+	struct page		*respages[RPCSVC_MAXPAGES];
+	short			resused;
 	int			argslen;
 	__be32			args[0];
 };
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bf5b5cd..bf12475 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -903,6 +903,8 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 	struct svc_xprt *xprt = dr->xprt;
 
 	if (too_many) {
+		if (dr->release_state)
+			dr->release_state(dr);
 		svc_xprt_put(xprt);
 		kfree(dr);
 		return;
@@ -941,10 +943,9 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		size_t size;
 		/* FIXME maybe discard if size too large */
 		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
-		dr = kmalloc(size, GFP_KERNEL);
+		dr = kzalloc(size, GFP_KERNEL);
 		if (dr == NULL)
-			return NULL;
-
+			goto out;
 		dr->handle.owner = rqstp->rq_server;
 		dr->prot = rqstp->rq_prot;
 		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
@@ -958,6 +959,15 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
 		       dr->argslen << 2);
 	}
+	if (rqstp->rq_save_state)
+		rqstp->rq_save_state(rqstp, dr);
+out:
+	/* reset for each deferral */
+	rqstp->rq_defer_data = NULL;
+	rqstp->rq_save_state = NULL;
+	if (dr == NULL)
+		return NULL;
+
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
 
@@ -986,10 +996,11 @@ static int svc_deferred_recv(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_hlen   = dr->xprt_hlen;
 	rqstp->rq_daddr       = dr->daddr;
 	rqstp->rq_respages    = rqstp->rq_pages;
+	if (dr->restore_state)
+		dr->restore_state(rqstp, dr);
 	return (dr->argslen<<2) - dr->xprt_hlen;
 }
 
-
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 {
 	struct svc_deferred_req *dr = NULL;
-- 
1.6.0.2

