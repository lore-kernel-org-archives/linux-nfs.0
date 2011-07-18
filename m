Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58868 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab1GRNkn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2011 09:40:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd4: call nfsd4_release_compoundargs from pc_release
Date: Mon, 18 Jul 2011 09:40:38 -0400
Message-Id: <1310996439-14640-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This simplifies cleanup a bit.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/nfs4xdr.c  |   14 ++++++--------
 fs/nfsd/xdr4.h     |    2 +-
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 121fd84..7ef1b27 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1218,7 +1218,6 @@ encode_op:
 	fh_put(&resp->cstate.save_fh);
 	BUG_ON(resp->cstate.replay_owner);
 out:
-	nfsd4_release_compoundargs(args);
 	/* Reset deferral mechanism for RPC deferrals */
 	rqstp->rq_usedeferral = 1;
 	dprintk("nfsv4 compound returned %d\n", ntohl(status));
@@ -1473,6 +1472,7 @@ static struct svc_procedure		nfsd_procedures4[2] = {
 		.pc_encode = (kxdrproc_t) nfs4svc_encode_compoundres,
 		.pc_argsize = sizeof(struct nfsd4_compoundargs),
 		.pc_ressize = sizeof(struct nfsd4_compoundres),
+		.pc_release = nfsd4_release_compoundargs,
 		.pc_cachetype = RC_NOCACHE,
 		.pc_xdrressize = NFSD_BUFSIZE/4,
 	},
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a8d83bd..c43f560 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3428,8 +3428,11 @@ nfs4svc_encode_voidres(struct svc_rqst *rqstp, __be32 *p, void *dummy)
         return xdr_ressize_check(rqstp, p);
 }
 
-void nfsd4_release_compoundargs(struct nfsd4_compoundargs *args)
+int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
 {
+	struct svc_rqst *rqstp = rq;
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+
 	if (args->ops != args->iops) {
 		kfree(args->ops);
 		args->ops = args->iops;
@@ -3442,13 +3445,12 @@ void nfsd4_release_compoundargs(struct nfsd4_compoundargs *args)
 		tb->release(tb->buf);
 		kfree(tb);
 	}
+	return 1;
 }
 
 int
 nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compoundargs *args)
 {
-	__be32 status;
-
 	args->p = p;
 	args->end = rqstp->rq_arg.head[0].iov_base + rqstp->rq_arg.head[0].iov_len;
 	args->pagelist = rqstp->rq_arg.pages;
@@ -3458,11 +3460,7 @@ nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_comp
 	args->ops = args->iops;
 	args->rqstp = rqstp;
 
-	status = nfsd4_decode_compound(args);
-	if (status) {
-		nfsd4_release_compoundargs(args);
-	}
-	return !status;
+	return !nfsd4_decode_compound(args);
 }
 
 int
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 02fb0e0..351348c 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -580,7 +580,7 @@ extern __be32
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_release_lockowner *rlockowner);
-extern void nfsd4_release_compoundargs(struct nfsd4_compoundargs *);
+extern int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp);
 extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
 extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
-- 
1.7.4.1

