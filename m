Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38262 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937AbaAZU7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jan 2014 15:59:24 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd4: delay setting current_fh in open
Date: Sun, 26 Jan 2014 15:59:20 -0500
Message-Id: <1390769961-30898-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1390769961-30898-1-git-send-email-bfields@redhat.com>
References: <1390769961-30898-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is basically a no-op, to simplify a following patch.

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   37 ++++++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index dadff09..844813a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -230,17 +230,16 @@ static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state *cstate
 }
 
 static __be32
-do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
+do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_open *open, struct svc_fh **resfh)
 {
 	struct svc_fh *current_fh = &cstate->current_fh;
-	struct svc_fh *resfh;
 	int accmode;
 	__be32 status;
 
-	resfh = kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
-	if (!resfh)
+	*resfh = kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
+	if (!*resfh)
 		return nfserr_jukebox;
-	fh_init(resfh, NFS4_FHSIZE);
+	fh_init(*resfh, NFS4_FHSIZE);
 	open->op_truncate = 0;
 
 	if (open->op_create) {
@@ -265,12 +264,12 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 		 */
 		status = do_nfsd_create(rqstp, current_fh, open->op_fname.data,
 					open->op_fname.len, &open->op_iattr,
-					resfh, open->op_createmode,
+					*resfh, open->op_createmode,
 					(u32 *)open->op_verf.data,
 					&open->op_truncate, &open->op_created);
 
 		if (!status && open->op_label.len)
-			nfsd4_security_inode_setsecctx(resfh, &open->op_label, open->op_bmval);
+			nfsd4_security_inode_setsecctx(*resfh, &open->op_label, open->op_bmval);
 
 		/*
 		 * Following rfc 3530 14.2.16, use the returned bitmask
@@ -282,29 +281,26 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 							FATTR4_WORD1_TIME_MODIFY);
 	} else {
 		status = nfsd_lookup(rqstp, current_fh,
-				     open->op_fname.data, open->op_fname.len, resfh);
+				     open->op_fname.data, open->op_fname.len, *resfh);
 		fh_unlock(current_fh);
 	}
 	if (status)
 		goto out;
-	status = nfsd_check_obj_isreg(resfh);
+	status = nfsd_check_obj_isreg(*resfh);
 	if (status)
 		goto out;
 
 	if (is_create_with_attrs(open) && open->op_acl != NULL)
-		do_set_nfs4_acl(rqstp, resfh, open->op_acl, open->op_bmval);
+		do_set_nfs4_acl(rqstp, *resfh, open->op_acl, open->op_bmval);
 
-	nfsd4_set_open_owner_reply_cache(cstate, open, resfh);
+	nfsd4_set_open_owner_reply_cache(cstate, open, *resfh);
 	accmode = NFSD_MAY_NOP;
 	if (open->op_created ||
 			open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR)
 		accmode |= NFSD_MAY_OWNER_OVERRIDE;
-	status = do_open_permission(rqstp, resfh, open, accmode);
+	status = do_open_permission(rqstp, *resfh, open, accmode);
 	set_change_info(&open->op_cinfo, current_fh);
-	fh_dup2(current_fh, resfh);
 out:
-	fh_put(resfh);
-	kfree(resfh);
 	return status;
 }
 
@@ -357,6 +353,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_open *open)
 {
 	__be32 status;
+	struct svc_fh *resfh = NULL;
 	struct nfsd4_compoundres *resp;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -423,7 +420,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
 		case NFS4_OPEN_CLAIM_NULL:
-			status = do_open_lookup(rqstp, cstate, open);
+			status = do_open_lookup(rqstp, cstate, open, &resfh);
 			if (status)
 				goto out;
 			break;
@@ -439,6 +436,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			status = do_open_fhandle(rqstp, cstate, open);
 			if (status)
 				goto out;
+			resfh = &cstate->current_fh;
 			break;
 		case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
              	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
@@ -458,9 +456,14 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * successful, it (1) truncates the file if open->op_truncate was
 	 * set, (2) sets open->op_stateid, (3) sets open->op_delegation.
 	 */
-	status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
+	status = nfsd4_process_open2(rqstp, resfh, open);
 	WARN_ON(status && open->op_created);
 out:
+	if (resfh && resfh != &cstate->current_fh) {
+		fh_dup2(&cstate->current_fh, resfh);
+		fh_put(resfh);
+		kfree(resfh);
+	}
 	nfsd4_cleanup_open_state(open, status);
 	if (open->op_openowner && !nfsd4_has_session(cstate))
 		cstate->replay_owner = &open->op_openowner->oo_owner;
-- 
1.7.9.5

