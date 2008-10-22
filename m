From: andros@netapp.com
Subject: [PATCH 1/3] SUNRPC add deferral processing callbacks
Date: Wed, 22 Oct 2008 14:12:04 -0400
Message-ID: <1224699126-3762-2-git-send-email-andros@netapp.com>
References: <>
 <1224699126-3762-1-git-send-email-andros@netapp.com>
Cc: androsadamson@gmail.com, Andy Adamson <andros@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341AbYJVSMR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 14:12:17 -0400
In-Reply-To: <1224699126-3762-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For EOS, NFSD compound RPC deferred processing should restart operation which
caused the deferral.

Add a callback and a defer_data pointer in svc_rqst to enable svc_defer to
save partial result state in the deferral request.

Dynamically allocate page pointers in the save state callback.
A failure to save state will free the deferred request and
return NULL which signals the cache to return -ETIMEDOUT (NFSERR_DELAY).

Add page pointer storage to svc_deferred_req to cache the pages holding the
partially processed request.

Add callbacks and a defer_data pointer in svc_deferred_request to enable
svc_deferred_recv to restore and release the partial result state.

Signed-off-by: Andy Adamson<andros@netapp.com>
---
 include/linux/sunrpc/svc.h |   10 ++++++++++
 net/sunrpc/svc.c           |    4 ++++
 net/sunrpc/svc_xprt.c      |   10 +++++++++-
 3 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 3afe7fb..8cc8a74 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -216,6 +216,9 @@ struct svc_rqst {
 	struct svc_cred		rq_cred;	/* auth info */
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
+	/* callback to save deferred request state */
+	int (*rq_save_state)(struct svc_rqst *, struct svc_deferred_req *);
+	void			*rq_defer_data; /* defer state data to save */
 
 	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
@@ -324,6 +327,13 @@ struct svc_deferred_req {
 	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	size_t			xprt_hlen;
+	/* callbacks to restore and release deferred request state
+	 * set in rq_save_state */
+	void (*restore_state)(struct svc_rqst *, struct svc_deferred_req *);
+	void (*release_state)(struct svc_deferred_req *);
+	void			*defer_data; /* defer state data */
+	struct page		**respages;
+	int			respages_used;
 	int			argslen;
 	__be32			args[0];
 };
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 54c98d8..8a6c69c 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1024,6 +1024,10 @@ svc_process(struct svc_rqst *rqstp)
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_splice_ok = 1;
 
+	/* Reset deferred processing */
+	rqstp->rq_defer_data = NULL;
+	rqstp->rq_save_state = NULL;
+
 	/* Setup reply header */
 	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bf5b5cd..0a8d6ab 100644
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
@@ -941,7 +943,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		size_t size;
 		/* FIXME maybe discard if size too large */
 		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
-		dr = kmalloc(size, GFP_KERNEL);
+		dr = kzalloc(size, GFP_KERNEL);
 		if (dr == NULL)
 			return NULL;
 
@@ -958,6 +960,10 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
 		       dr->argslen << 2);
 	}
+	if (rqstp->rq_save_state && !rqstp->rq_save_state(rqstp, dr)) {
+		kfree(dr);
+		return NULL;
+	}
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
 
@@ -986,6 +992,8 @@ static int svc_deferred_recv(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_hlen   = dr->xprt_hlen;
 	rqstp->rq_daddr       = dr->daddr;
 	rqstp->rq_respages    = rqstp->rq_pages;
+	if (dr->restore_state)
+		dr->restore_state(rqstp, dr);
 	return (dr->argslen<<2) - dr->xprt_hlen;
 }
 
-- 
1.5.4.3

