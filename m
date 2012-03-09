Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36573 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754597Ab2CIWOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:14:09 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd4: reduce do_open_lookup() stack usage
Date: Fri,  9 Mar 2012 17:14:06 -0500
Message-Id: <1331331247-22343-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1331331247-22343-1-git-send-email-bfields@redhat.com>
References: <1331331247-22343-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I get 320 bytes for struct svc_fh on x86_64, really a little large to be
putting on the stack; kmalloc() instead.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bdb71a5..abe808a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -193,10 +193,13 @@ static __be32 nfsd_check_obj_isreg(struct svc_fh *fh)
 static __be32
 do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
-	struct svc_fh resfh;
+	struct svc_fh *resfh;
 	__be32 status;
 
-	fh_init(&resfh, NFS4_FHSIZE);
+	resfh = kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
+	if (!resfh)
+		return nfserr_jukebox;
+	fh_init(resfh, NFS4_FHSIZE);
 	open->op_truncate = 0;
 
 	if (open->op_create) {
@@ -221,7 +224,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 		 */
 		status = do_nfsd_create(rqstp, current_fh, open->op_fname.data,
 					open->op_fname.len, &open->op_iattr,
-					&resfh, open->op_createmode,
+					resfh, open->op_createmode,
 					(u32 *)open->op_verf.data,
 					&open->op_truncate, &open->op_created);
 
@@ -235,28 +238,29 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 						FATTR4_WORD1_TIME_MODIFY);
 	} else {
 		status = nfsd_lookup(rqstp, current_fh,
-				     open->op_fname.data, open->op_fname.len, &resfh);
+				     open->op_fname.data, open->op_fname.len, resfh);
 		fh_unlock(current_fh);
 		if (status)
 			goto out;
-		status = nfsd_check_obj_isreg(&resfh);
+		status = nfsd_check_obj_isreg(resfh);
 	}
 	if (status)
 		goto out;
 
 	if (is_create_with_attrs(open) && open->op_acl != NULL)
-		do_set_nfs4_acl(rqstp, &resfh, open->op_acl, open->op_bmval);
+		do_set_nfs4_acl(rqstp, resfh, open->op_acl, open->op_bmval);
 
 	/* set reply cache */
 	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
-			&resfh.fh_handle);
+			&resfh->fh_handle);
 	if (!open->op_created)
-		status = do_open_permission(rqstp, &resfh, open,
+		status = do_open_permission(rqstp, resfh, open,
 					    NFSD_MAY_NOP);
 	set_change_info(&open->op_cinfo, current_fh);
-	fh_dup2(current_fh, &resfh);
+	fh_dup2(current_fh, resfh);
 out:
-	fh_put(&resfh);
+	fh_put(resfh);
+	kfree(resfh);
 	return status;
 }
 
-- 
1.7.5.4

