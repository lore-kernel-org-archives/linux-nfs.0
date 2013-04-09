Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50141 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935537Ab3DIX6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:21 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/10] nfsd4: more sessions/open-owner-replay cleanup
Date: Tue,  9 Apr 2013 19:58:08 -0400
Message-Id: <1365551896-6936-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

More logic that's unnecessary in the 4.1 case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c97bb42..5dee811 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -191,9 +191,18 @@ static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
 	return nfserr_symlink;
 }
 
+static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state *cstate, struct nfsd4_open *open, struct svc_fh *resfh)
+{
+	if (nfsd4_has_session(cstate))
+		return;
+	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
+			&resfh->fh_handle);
+}
+
 static __be32
-do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
+do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
 {
+	struct svc_fh *current_fh = &cstate->current_fh;
 	struct svc_fh *resfh;
 	int accmode;
 	__be32 status;
@@ -252,9 +261,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 	if (is_create_with_attrs(open) && open->op_acl != NULL)
 		do_set_nfs4_acl(rqstp, resfh, open->op_acl, open->op_bmval);
 
-	/* set reply cache */
-	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
-			&resfh->fh_handle);
+	nfsd4_set_open_owner_reply_cache(cstate, open, resfh);
 	accmode = NFSD_MAY_NOP;
 	if (open->op_created)
 		accmode |= NFSD_MAY_OWNER_OVERRIDE;
@@ -268,8 +275,9 @@ out:
 }
 
 static __be32
-do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
+do_open_fhandle(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
 {
+	struct svc_fh *current_fh = &cstate->current_fh;
 	__be32 status;
 
 	/* We don't know the target directory, and therefore can not
@@ -278,9 +286,7 @@ do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_
 
 	memset(&open->op_cinfo, 0, sizeof(struct nfsd4_change_info));
 
-	/* set replay cache */
-	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
-			&current_fh->fh_handle);
+	nfsd4_set_open_owner_reply_cache(cstate, open, current_fh);
 
 	open->op_truncate = (open->op_iattr.ia_valid & ATTR_SIZE) &&
 		(open->op_iattr.ia_size == 0);
@@ -372,8 +378,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
 		case NFS4_OPEN_CLAIM_NULL:
-			status = do_open_lookup(rqstp, &cstate->current_fh,
-						open);
+			status = do_open_lookup(rqstp, cstate, open);
 			if (status)
 				goto out;
 			break;
@@ -386,8 +391,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				goto out;
 		case NFS4_OPEN_CLAIM_FH:
 		case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
-			status = do_open_fhandle(rqstp, &cstate->current_fh,
-						 open);
+			status = do_open_fhandle(rqstp, cstate, open);
 			if (status)
 				goto out;
 			break;
-- 
1.7.9.5

