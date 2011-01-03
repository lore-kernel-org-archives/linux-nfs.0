Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56797 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab1ACSbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 13:31:00 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: simpler request dropping
Date: Mon,  3 Jan 2011 13:30:52 -0500
Message-Id: <1294079454-17891-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1294079454-17891-1-git-send-email-bfields@redhat.com>
References: <1294079454-17891-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Currently we use -EAGAIN returns to determine when to drop a deferred
request.  On its own, that is error-prone, as it makes us treat -EAGAIN
returns from other functions specially to prevent inadvertent dropping.

So, use a flag on the request instead.

Returning an error on request deferral is still required, to prevent
further processing, but we no longer need worry that an error return on
its own could result in a drop.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c           |    2 +-
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    3 ++-
 net/sunrpc/svc_xprt.c      |    1 +
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2bae1d8..18743c4 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -608,7 +608,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
-	if (nfserr == nfserr_dropit) {
+	if (nfserr == nfserr_dropit || rqstp->rq_dropme) {
 		dprintk("nfsd: Dropping request; may be revisited later\n");
 		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
 		return 0;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..d45c482 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -269,6 +269,7 @@ struct svc_rqst {
 	struct cache_req	rq_chandle;	/* handle passed to caches for 
 						 * request delaying 
 						 */
+	bool			rq_dropme;
 	/* Catering to nfsd */
 	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct auth_domain *	rq_gssclient;	/* "gss/"-style peer info */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6359c42..df1931f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1005,6 +1005,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	rqstp->rq_splice_ok = 1;
 	/* Will be turned off only when NFSv4 Sessions are used */
 	rqstp->rq_usedeferral = 1;
+	rqstp->rq_dropme = false;
 
 	/* Setup reply header */
 	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
@@ -1106,7 +1107,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 
 		/* Encode reply */
-		if (*statp == rpc_drop_reply) {
+		if (rqstp->rq_dropme) {
 			if (procp->pc_release)
 				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5eae53b..173f3b9 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1019,6 +1019,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	}
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
+	rqstp->rq_dropme = true;
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
-- 
1.7.1

