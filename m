From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 01/47] nfsd: don't use the deferral service, return NFS4ERR_DELAY
Date: Sat, 28 Mar 2009 11:30:44 +0300
Message-ID: <1238229044-7001-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14865 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752853AbZC1Iat (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:30:49 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

On an NFSv4.1 server cache miss that causes an upcall, NFS4ERR_DELAY will be
returned. It is up to the NFSv4.1 client to resend only the operations that
have not been processed.

Initialize rq_usedeferral to 1 in svc_process(). It sill be turned off in
nfsd4_proc_compound() only when NFSv4.1 Sessions are used.

Note: this isn't an adequate solution on its own. It's acceptable as a way
to get some minimal 4.1 up and working, but we're going to have to find a
way to avoid returning DELAY in all common cases before 4.1 can really be
considered ready.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: reverse rq_nodeferral negative logic]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[sunrpc: initialize rq_usedeferral]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c         |    8 ++++++++
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    2 ++
 net/sunrpc/svc_xprt.c      |    2 +-
 4 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f156b85..7839654 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -873,6 +873,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	resp->tag = args->tag;
 	resp->opcnt = 0;
 	resp->rqstp = rqstp;
+	/* Use the deferral mechanism only for NFSv4.0 compounds */
+	rqstp->rq_usedeferral = (args->minorversion == 0);
 
 	/*
 	 * According to RFC3010, this takes precedence over all other errors.
@@ -957,10 +959,16 @@ encode_op:
 
 		nfsd4_increment_op_stats(op->opnum);
 	}
+	if (!rqstp->rq_usedeferral && status == nfserr_dropit) {
+		dprintk("%s Dropit - send NFS4ERR_DELAY\n", __func__);
+		status = nfserr_jukebox;
+	}
 
 	cstate_free(cstate);
 out:
 	nfsd4_release_compoundargs(args);
+	/* Reset deferral mechanism for RPC deferrals */
+	rqstp->rq_usedeferral = 1;
 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
 	return status;
 }
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 9f9f699..815dd58 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -230,6 +230,7 @@ struct svc_rqst {
 	struct svc_cred		rq_cred;	/* auth info */
 	void *			rq_xprt_ctxt;	/* transport specific context ptr */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
+	int			rq_usedeferral;	/* use deferral */
 
 	size_t			rq_xprt_hlen;	/* xprt header len */
 	struct xdr_buf		rq_arg;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index fff09a2..45984cb 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1023,6 +1023,8 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.tail[0].iov_len = 0;
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_splice_ok = 1;
+	/* Will be turned off only when NFSv4 Sessions are used */
+	rqstp->rq_usedeferral = 1;
 
 	/* Setup reply header */
 	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 1e66f24..600d091 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -974,7 +974,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
 	struct svc_deferred_req *dr;
 
-	if (rqstp->rq_arg.page_len)
+	if (rqstp->rq_arg.page_len || !rqstp->rq_usedeferral)
 		return NULL; /* if more than a page, give up FIXME */
 	if (rqstp->rq_deferred) {
 		dr = rqstp->rq_deferred;
-- 
1.6.2.1

