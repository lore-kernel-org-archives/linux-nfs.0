Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60187 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932248Ab1INLp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 20/25] nfsd4: add common dl_stid field to delegation
Date: Wed, 14 Sep 2011 07:45:16 -0400
Message-Id: <1316000721-3289-21-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4state.c    |   20 ++++++++++----------
 fs/nfsd/state.h        |   20 +++++++++++---------
 3 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 02eb4ed..93b5e40 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -351,7 +351,7 @@ static void encode_cb_recall4args(struct xdr_stream *xdr,
 	__be32 *p;
 
 	encode_nfs_cb_opnum4(xdr, OP_CB_RECALL);
-	encode_stateid4(xdr, &dp->dl_stateid);
+	encode_stateid4(xdr, &dp->dl_stid.sc_stateid);
 
 	p = xdr_reserve_space(xdr, 4);
 	*p++ = xdr_zero;			/* truncate */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d0bb5a5..3e3d605 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -247,10 +247,10 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	get_nfs4_file(fp);
 	dp->dl_file = fp;
 	dp->dl_type = type;
-	dp->dl_stateid.si_boot = boot_time;
-	dp->dl_stateid.si_stateownerid = current_delegid++;
-	dp->dl_stateid.si_fileid = 0;
-	dp->dl_stateid.si_generation = 1;
+	dp->dl_stid.sc_stateid.si_boot = boot_time;
+	dp->dl_stid.sc_stateid.si_stateownerid = current_delegid++;
+	dp->dl_stid.sc_stateid.si_fileid = 0;
+	dp->dl_stid.sc_stateid.si_generation = 1;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
@@ -2572,7 +2572,7 @@ find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 
 	spin_lock(&recall_lock);
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
-		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid) {
+		if (dp->dl_stid.sc_stateid.si_stateownerid == stid->si_stateownerid) {
 			spin_unlock(&recall_lock);
 			return dp;
 		}
@@ -2861,10 +2861,10 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_ol_
 	if (status)
 		goto out_free;
 
-	memcpy(&open->op_delegate_stateid, &dp->dl_stateid, sizeof(dp->dl_stateid));
+	memcpy(&open->op_delegate_stateid, &dp->dl_stid.sc_stateid, sizeof(dp->dl_stid.sc_stateid));
 
 	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
-		STATEID_VAL(&dp->dl_stateid));
+		STATEID_VAL(&dp->dl_stid.sc_stateid));
 out:
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS
 			&& flag == NFS4_OPEN_DELEGATE_NONE
@@ -3296,7 +3296,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		dp = find_delegation_stateid(ino, stateid);
 		if (!dp)
 			goto out;
-		status = check_stateid_generation(stateid, &dp->dl_stateid, nfsd4_has_session(cstate));
+		status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 		if (status)
 			goto out;
 		status = nfs4_check_delegmode(dp, flags);
@@ -3667,7 +3667,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dp = find_delegation_stateid(inode, stateid);
 	if (!dp)
 		goto out;
-	status = check_stateid_generation(stateid, &dp->dl_stateid, nfsd4_has_session(cstate));
+	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
 	renew_client(dp->dl_client);
@@ -3737,7 +3737,7 @@ search_for_delegation(stateid_t *stid)
 		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
 			list_for_each(pos, &fp->fi_delegations) {
 				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
-				if (same_stateid(&dp->dl_stateid, stid))
+				if (same_stateid(&dp->dl_stid.sc_stateid, stid))
 					return dp;
 			}
 		}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d7fffab..e3ff7c9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -76,6 +76,15 @@ struct nfsd4_callback {
 	bool cb_done;
 };
 
+struct nfs4_stid {
+#define NFS4_OPEN_STID 1
+#define NFS4_LOCK_STID 2
+#define NFS4_DELEG_STID 4
+	char sc_type;
+	struct list_head sc_hash;
+	stateid_t sc_stateid;
+};
+
 struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
@@ -86,7 +95,7 @@ struct nfs4_delegation {
 	u32			dl_type;
 	time_t			dl_time;
 /* For recall: */
-	stateid_t		dl_stateid;
+	struct nfs4_stid	dl_stid;
 	struct knfsd_fh		dl_fh;
 	int			dl_retries;
 	struct nfsd4_callback	dl_recall;
@@ -446,14 +455,7 @@ static inline struct file *find_any_file(struct nfs4_file *f)
 * we should consider defining separate structs for the two cases.
 */
 
-struct nfs4_stid {
-#define NFS4_OPEN_STID 1
-#define NFS4_LOCK_STID 2
-	char sc_type;
-	struct list_head sc_hash;
-	stateid_t sc_stateid;
-};
-
+/* "ol" stands for "Open or Lock".  Better suggestions welcome. */
 struct nfs4_ol_stateid {
 	struct nfs4_stid    st_stid;
 	struct list_head              st_perfile;
-- 
1.7.4.1

