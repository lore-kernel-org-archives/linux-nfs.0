From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: eliminate struct nfs4_cb_recall
Date: Sun,  3 May 2009 14:16:36 -0400
Message-ID: <1241374599-20348-11-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
 <1241374599-20348-7-git-send-email-bfields@fieldses.org>
 <1241374599-20348-8-git-send-email-bfields@fieldses.org>
 <1241374599-20348-9-git-send-email-bfields@fieldses.org>
 <1241374599-20348-10-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58613 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-10-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The nfs4_cb_recall struct is used only in nfs4_delegation, so its
pointer to the containing delegation is unnecessary--we could just use
container_of().

But there's no real reason to have this a separate struct at all--just
move these fields to nfs4_delegation.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c     |   24 +++++++++++-------------
 fs/nfsd/nfs4state.c        |    5 ++---
 include/linux/nfsd/state.h |   18 +++++-------------
 3 files changed, 18 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index ed860d7..2509305 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -215,18 +215,18 @@ encode_cb_compound_hdr(struct xdr_stream *xdr, struct nfs4_cb_compound_hdr *hdr)
 }
 
 static int
-encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec)
+encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp)
 {
 	__be32 *p;
-	int len = cb_rec->cbr_fh.fh_size;
+	int len = dp->dl_fh.fh_size;
 
-	RESERVE_SPACE(12+sizeof(cb_rec->cbr_stateid) + len);
+	RESERVE_SPACE(12+sizeof(dp->dl_stateid) + len);
 	WRITE32(OP_CB_RECALL);
-	WRITE32(cb_rec->cbr_stateid.si_generation);
-	WRITEMEM(&cb_rec->cbr_stateid.si_opaque, sizeof(stateid_opaque_t));
-	WRITE32(cb_rec->cbr_trunc);
+	WRITE32(dp->dl_stateid.si_generation);
+	WRITEMEM(&dp->dl_stateid.si_opaque, sizeof(stateid_opaque_t));
+	WRITE32(dp->dl_trunc);
 	WRITE32(len);
-	WRITEMEM(&cb_rec->cbr_fh.fh_base, len);
+	WRITEMEM(&dp->dl_fh.fh_base, len);
 	return 0;
 }
 
@@ -241,11 +241,11 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_cb_recall *args)
+nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_delegation *args)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr = {
-		.ident = args->cbr_ident,
+		.ident = args->dl_ident,
 		.nops   = 1,
 	};
 
@@ -502,17 +502,15 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
 	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
-	struct nfs4_cb_recall *cbr = &dp->dl_recall;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
-		.rpc_argp = cbr,
+		.rpc_argp = dp,
 		.rpc_cred = clp->cl_cb_conn.cb_cred
 	};
 	int retries = 1;
 	int status = 0;
 
-	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
-	cbr->cbr_dp = dp;
+	dp->dl_trunc = 0; /* XXX need to implement truncate optimization */
 
 	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
 	while (retries--) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d7b5e6b..3e5345e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -203,9 +203,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	get_file(stp->st_vfs_file);
 	dp->dl_vfs_file = stp->st_vfs_file;
 	dp->dl_type = type;
-	dp->dl_recall.cbr_dp = NULL;
-	dp->dl_recall.cbr_ident = cb->cb_ident;
-	dp->dl_recall.cbr_trunc = 0;
+	dp->dl_ident = cb->cb_ident;
+	dp->dl_trunc = 0;
 	dp->dl_stateid.si_boot = get_seconds();
 	dp->dl_stateid.si_stateownerid = current_delegid++;
 	dp->dl_stateid.si_fileid = 0;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 563c367..233b60d 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -61,15 +61,6 @@ typedef struct {
 #define si_stateownerid   si_opaque.so_stateownerid
 #define si_fileid         si_opaque.so_fileid
 
-
-struct nfs4_cb_recall {
-	u32			cbr_ident;
-	int			cbr_trunc;
-	stateid_t		cbr_stateid;
-	struct knfsd_fh		cbr_fh;
-	struct nfs4_delegation	*cbr_dp;
-};
-
 struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
@@ -81,12 +72,13 @@ struct nfs4_delegation {
 	struct file		*dl_vfs_file;
 	u32			dl_type;
 	time_t			dl_time;
-	struct nfs4_cb_recall	dl_recall;
+/* For recall: */
+	u32			dl_ident;
+	int			dl_trunc;
+	stateid_t		dl_stateid;
+	struct knfsd_fh		dl_fh;
 };
 
-#define dl_stateid      dl_recall.cbr_stateid
-#define dl_fh           dl_recall.cbr_fh
-
 /* client delegation callback info */
 struct nfs4_cb_conn {
 	/* SETCLIENTID info */
-- 
1.6.0.4

