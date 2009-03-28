From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 02/47] nfsd: embed nfsd4_current_state in nfsd4_compoundres
Date: Sat, 28 Mar 2009 11:30:52 +0300
Message-ID: <1238229052-7600-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16819 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753309AbZC1Ia6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:30:58 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Remove the allocation of struct nfsd4_compound_state.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   40 +++++++++-------------------------------
 include/linux/nfsd/xdr4.h |    9 +++++----
 2 files changed, 14 insertions(+), 35 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7839654..c8e1ad0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -809,29 +809,6 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 		nfsdstats.nfs4_opcount[opnum]++;
 }
 
-static void cstate_free(struct nfsd4_compound_state *cstate)
-{
-	if (cstate == NULL)
-		return;
-	fh_put(&cstate->current_fh);
-	fh_put(&cstate->save_fh);
-	BUG_ON(cstate->replay_owner);
-	kfree(cstate);
-}
-
-static struct nfsd4_compound_state *cstate_alloc(void)
-{
-	struct nfsd4_compound_state *cstate;
-
-	cstate = kmalloc(sizeof(struct nfsd4_compound_state), GFP_KERNEL);
-	if (cstate == NULL)
-		return NULL;
-	fh_init(&cstate->current_fh, NFS4_FHSIZE);
-	fh_init(&cstate->save_fh, NFS4_FHSIZE);
-	cstate->replay_owner = NULL;
-	return cstate;
-}
-
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
 
@@ -859,12 +836,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 {
 	struct nfsd4_op	*op;
 	struct nfsd4_operation *opdesc;
-	struct nfsd4_compound_state *cstate = NULL;
+	struct nfsd4_compound_state *cstate = &resp->cstate;
 	int		slack_bytes;
 	__be32		status;
 
 	resp->xbuf = &rqstp->rq_res;
-	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
+	resp->p = rqstp->rq_res.head[0].iov_base +
+						rqstp->rq_res.head[0].iov_len;
 	resp->tagp = resp->p;
 	/* reserve space for: taglen, tag, and opcnt */
 	resp->p += 2 + XDR_QUADLEN(args->taglen);
@@ -873,6 +851,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	resp->tag = args->tag;
 	resp->opcnt = 0;
 	resp->rqstp = rqstp;
+	resp->cstate.replay_owner = NULL;
+	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
+	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
 	/* Use the deferral mechanism only for NFSv4.0 compounds */
 	rqstp->rq_usedeferral = (args->minorversion == 0);
 
@@ -883,11 +864,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	if (args->minorversion > NFSD_SUPPORTED_MINOR_VERSION)
 		goto out;
 
-	status = nfserr_resource;
-	cstate = cstate_alloc();
-	if (cstate == NULL)
-		goto out;
-
 	status = nfs_ok;
 	while (!status && resp->opcnt < args->opcnt) {
 		op = &args->ops[resp->opcnt++];
@@ -964,7 +940,9 @@ encode_op:
 		status = nfserr_jukebox;
 	}
 
-	cstate_free(cstate);
+	fh_put(&resp->cstate.current_fh);
+	fh_put(&resp->cstate.save_fh);
+	BUG_ON(resp->cstate.replay_owner);
 out:
 	nfsd4_release_compoundargs(args);
 	/* Reset deferral mechanism for RPC deferrals */
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 27bd3e3..fd15ddc 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -45,9 +45,9 @@
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
 
 struct nfsd4_compound_state {
-	struct svc_fh current_fh;
-	struct svc_fh save_fh;
-	struct nfs4_stateowner *replay_owner;
+	struct svc_fh		current_fh;
+	struct svc_fh		save_fh;
+	struct nfs4_stateowner	*replay_owner;
 };
 
 struct nfsd4_change_info {
@@ -416,7 +416,8 @@ struct nfsd4_compoundres {
 	u32				taglen;
 	char *				tag;
 	u32				opcnt;
-	__be32 *			tagp; /* where to encode tag and  opcount */
+	__be32 *			tagp; /* tag, opcount encode location */
+	struct nfsd4_compound_state	cstate;
 };
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
-- 
1.6.2.1

