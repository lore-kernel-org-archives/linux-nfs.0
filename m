Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44767 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755666Ab1JQV4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/8] nfsd4: preallocate open stateid in process_open1()
Date: Mon, 17 Oct 2011 17:55:56 -0400
Message-Id: <1318888557-14719-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As with the nfs4_file, we'd prefer to find out about any failure before
creating a new file rather than after.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   49 ++++++++++++++++++++-----------------------------
 fs/nfsd/xdr4.h      |    1 +
 2 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1f8c781..3e1d4e0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -268,6 +268,11 @@ static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cac
 	return kmem_cache_alloc(slab, GFP_KERNEL);
 }
 
+static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
+{
+	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
+}
+
 static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh, u32 type)
 {
@@ -2511,6 +2516,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
 	struct nfs4_openowner *oo = NULL;
+	__be32 status;
 
 	if (STALE_CLIENTID(&open->op_clientid))
 		return nfserr_stale_clientid;
@@ -2538,12 +2544,20 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		open->op_openowner = NULL;
 		goto new_owner;
 	}
-	return nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
+	status = nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
+	if (status)
+		return status;
+	clp = oo->oo_owner.so_client;
+	goto alloc_stateid;
 new_owner:
 	oo = alloc_init_open_stateowner(strhashval, clp, open);
 	if (oo == NULL)
 		return nfserr_jukebox;
 	open->op_openowner = oo;
+alloc_stateid:
+	open->op_stp = nfs4_alloc_stateid(clp);
+	if (!open->op_stp)
+		return nfserr_jukebox;
 	return nfs_ok;
 }
 
@@ -2616,11 +2630,6 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 	return nfs_ok;
 }
 
-static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
-{
-	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
-}
-
 static void nfs4_free_stateid(struct nfs4_ol_stateid *s)
 {
 	kmem_cache_free(stateid_slab, s);
@@ -2661,28 +2670,6 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	return nfs_ok;
 }
 
-static __be32
-nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_ol_stateid **stpp,
-		struct nfs4_file *fp, struct svc_fh *cur_fh,
-		struct nfsd4_open *open)
-{
-	struct nfs4_ol_stateid *stp;
-	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
-	__be32 status;
-
-	stp = nfs4_alloc_stateid(cl);
-	if (stp == NULL)
-		return nfserr_jukebox;
-
-	status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
-	if (status) {
-		nfs4_free_stateid(stp);
-		return status;
-	}
-	*stpp = stp;
-	return 0;
-}
-
 static inline __be32
 nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 		struct nfsd4_open *open)
@@ -2916,9 +2903,11 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (status)
 			goto out;
 	} else {
-		status = nfs4_new_open(rqstp, &stp, fp, current_fh, open);
+		status = nfs4_get_vfs_file(rqstp, fp, current_fh, open);
 		if (status)
 			goto out;
+		stp = open->op_stp;
+		open->op_stp = NULL;
 		init_open_stateid(stp, fp, open);
 		status = nfsd4_truncate(rqstp, current_fh, open);
 		if (status) {
@@ -2975,6 +2964,8 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 	}
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
+	if (open->op_stp)
+		nfs4_free_stateid(open->op_stp);
 }
 
 __be32
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 502dd43..ce8c591 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -229,6 +229,7 @@ struct nfsd4_open {
 	int		op_truncate;        /* used during processing */
 	struct nfs4_openowner *op_openowner; /* used during processing */
 	struct nfs4_file *op_file;          /* used during processing */
+	struct nfs4_ol_stateid *op_stp;	    /* used during processing */
 	struct nfs4_acl *op_acl;
 };
 #define op_iattr	iattr
-- 
1.7.5.4

