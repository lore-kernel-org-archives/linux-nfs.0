Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754477Ab1JQV4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 8/8] nfsd4: warn on open failure after create
Date: Mon, 17 Oct 2011 17:55:57 -0400
Message-Id: <1318888557-14719-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If we create the object and then return failure to the client, we're
left with an unexpected file in the filesystem.

I'm trying to eliminate such cases but not 100% sure I have so an
assertion might be helpful for now.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    7 ++++---
 fs/nfsd/vfs.c      |    2 +-
 fs/nfsd/vfs.h      |    2 +-
 fs/nfsd/xdr4.h     |    3 ++-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 10b50d7..710b97b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -194,7 +194,6 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 {
 	struct svc_fh resfh;
 	__be32 status;
-	int created = 0;
 
 	fh_init(&resfh, NFS4_FHSIZE);
 	open->op_truncate = 0;
@@ -223,7 +222,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 					open->op_fname.len, &open->op_iattr,
 					&resfh, open->op_createmode,
 					(u32 *)open->op_verf.data,
-					&open->op_truncate, &created);
+					&open->op_truncate, &open->op_created);
 
 		/*
 		 * Following rfc 3530 14.2.16, use the returned bitmask
@@ -253,7 +252,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 	/* set reply cache */
 	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
 			&resfh.fh_handle);
-	if (!created)
+	if (!open->op_created)
 		status = do_open_permission(rqstp, current_fh, open,
 					    NFSD_MAY_NOP);
 
@@ -318,6 +317,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* We don't yet support WANT bits: */
 	open->op_share_access &= NFS4_SHARE_ACCESS_MASK;
 
+	open->op_created = 0;
 	/*
 	 * RFC5661 18.51.3
 	 * Before RECLAIM_COMPLETE done, server should deny new lock
@@ -408,6 +408,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * set, (2) sets open->op_stateid, (3) sets open->op_delegation.
 	 */
 	status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
+	WARN_ON(status && open->op_created);
 out:
 	nfsd4_cleanup_open_state(open, status);
 	if (open->op_openowner)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4dd9128..7a2e442 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1370,7 +1370,7 @@ __be32
 do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		char *fname, int flen, struct iattr *iap,
 		struct svc_fh *resfhp, int createmode, u32 *verifier,
-	        int *truncp, int *created)
+	        bool *truncp, bool *created)
 {
 	struct dentry	*dentry, *dchild = NULL;
 	struct inode	*dirp;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 503f3bf..3f54ad0 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -62,7 +62,7 @@ __be32		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
 __be32		do_nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
 				struct svc_fh *res, int createmode,
-				u32 *verifier, int *truncp, int *created);
+				u32 *verifier, bool *truncp, bool *created);
 __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 				loff_t, unsigned long);
 #endif /* CONFIG_NFSD_V3 */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ce8c591..e305735 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -226,7 +226,8 @@ struct nfsd4_open {
 	u32		op_recall;          /* recall */
 	struct nfsd4_change_info  op_cinfo; /* response */
 	u32		op_rflags;          /* response */
-	int		op_truncate;        /* used during processing */
+	bool		op_truncate;        /* used during processing */
+	bool		op_created;         /* used during processing */
 	struct nfs4_openowner *op_openowner; /* used during processing */
 	struct nfs4_file *op_file;          /* used during processing */
 	struct nfs4_ol_stateid *op_stp;	    /* used during processing */
-- 
1.7.5.4

