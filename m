Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f42.google.com ([74.125.83.42]:42916 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab3JFHog (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 03:44:36 -0400
Received: by mail-ee0-f42.google.com with SMTP id b45so2629843eek.1
        for <linux-nfs@vger.kernel.org>; Sun, 06 Oct 2013 00:44:35 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] SQUASHME: pnfsd: no need for find_file in layout commit/return
Date: Sun,  6 Oct 2013 10:44:32 +0300
Message-Id: <1381045472-30717-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <5251140B.4000203@primarydata.com>
References: <5251140B.4000203@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the nfs4_file can be found via the layout stateid.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 78 +++++++++++++++++------------------------------------
 1 file changed, 25 insertions(+), 53 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index c00eb03..a117a5d 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -253,18 +253,13 @@ struct sbid_tracker {
 }
 
 /*
- * We have looked up the nfs4_file corresponding to the current_fh, and
- * confirmed the clientid. Pull the few tests from nfs4_preprocess_stateid_op()
- * that make sense with a layout stateid.
- *
- * If the layout state was found in cache, grab a reference count on it;
- * otherwise, allocate a new layout state if "do_alloc" is set.
+ * If the layout state was found in cache, grab a reference count on it.
  *
  * Called with the state_lock held
- * Returns zero and stateid is updated, or error.
+ * Returns zero and the layout state in *lsp, or error.
  */
 static __be32
-nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
+nfs4_process_layout_stateid(struct nfs4_client *clp,
 			    stateid_t *stateid, unsigned char typemask,
 			    struct nfs4_layout_state **lsp)
 {
@@ -272,8 +267,8 @@ struct sbid_tracker {
 	__be32 status = 0;
 	struct nfs4_stid *stid;
 
-	dprintk("--> %s clp %p fp %p operation stateid=" STATEID_FMT "\n",
-		__func__, clp, fp, STATEID_VAL(stateid));
+	dprintk("--> %s clp %p operation stateid=" STATEID_FMT "\n",
+		__func__, clp, STATEID_VAL(stateid));
 
 	nfs4_assert_state_locked();
 	status = nfsd4_lookup_stateid(stateid, typemask, &stid, true,
@@ -283,17 +278,13 @@ struct sbid_tracker {
 
 	/* Is this the first use of this layout ? */
 	if (stid->sc_type != NFS4_LAYOUT_STID) {
-		ls = alloc_init_layout_state(clp, fp, stateid);
-		if (!ls) {
-			status = nfserr_jukebox;
-			goto out;
-		}
+		status = nfserr_bad_stateid;
+		goto out;
 	} else {
 		ls = container_of(stid, struct nfs4_layout_state, ls_stid);
 
 		/* BAD STATEID */
 		if (stateid->si_generation > ls->ls_stid.sc_stateid.si_generation) {
-			dprintk("%s bad stateid 1\n", __func__);
 			status = nfserr_bad_stateid;
 			goto out;
 		}
@@ -304,10 +295,7 @@ struct sbid_tracker {
 	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
 		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));
 
-	if (lsp)
-		*lsp = ls;
-	else
-		put_layout_state(ls);
+	*lsp = ls;
 out:
 	dprintk("<-- %s status %d\n", __func__, htonl(status));
 
@@ -942,30 +930,31 @@ struct super_block *
 {
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct super_block *sb = ino->i_sb;
-	struct nfs4_file *fp = NULL;
 	struct nfs4_client *clp;
+	struct nfs4_layout_state *ls = NULL;
 	__be32 nfserr = NFS4_OK;
 	int status = 0;
 
 	lcp->res.lc_size_chg = 0;
 
 	nfs4_lock_state();
-	fp = find_file(ino);
 	clp = find_confirmed_client((clientid_t *)&lcp->lc_clientid,
 				    true, net_generic(SVC_NET(rqstp), nfsd_net_id));
-	if (!fp || !clp) {
+	if (!clp) {
 		nfserr = nfserr_inval;
 		nfs4_unlock_state();
 		goto out;
 	}
 
-	nfserr = nfs4_process_layout_stateid(clp, fp, &lcp->lc_sid,
-					     NFS4_LAYOUT_STID, NULL);
+	nfserr = nfs4_process_layout_stateid(clp, &lcp->lc_sid,
+					     NFS4_LAYOUT_STID, &ls);
 	nfs4_unlock_state();
 	if (nfserr)
 		goto out;
 
 	if (sb->s_pnfs_op->layout_commit) {
+		struct nfs4_file *fp = ls->ls_file;
+
 		nfs4_file_lo_lock(fp);
 		status = sb->s_pnfs_op->layout_commit(ino, &lcp->args, &lcp->res);
 		nfs4_file_lo_unlock(fp);
@@ -1002,9 +991,6 @@ struct super_block *
 	}
 
 out:
-	if (fp)
-		put_nfs4_file(fp);
-
 	return cpu_to_be32(nfserr);
 }
 
@@ -1261,9 +1247,9 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 	int status = 0;
 	int layouts_found = 0;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
-	struct nfs4_file *fp = NULL;
 	struct nfs4_layout_state *ls = NULL;
 	struct nfs4_client *clp;
+	struct nfs4_file *fp = NULL;
 	struct nfs4_layoutrecall *clr, *nextclr;
 	u64 ex_fsid = current_fh->fh_export->ex_fsid;
 	LIST_HEAD(lo_destroy_list);
@@ -1277,26 +1263,15 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 		goto out_unlock;
 
 	if (lrp->args.lr_return_type == RETURN_FILE) {
-		fp = find_file(ino);
-		if (!fp) {
-			dprintk("%s: RETURN_FILE: no nfs4_file for ino %p:%lu\n",
-				__func__, ino, ino ? ino->i_ino : 0L);
-			/* If we had a layout on the file the nfs4_file would
-			 * be referenced and we should have found it. Since we
-			 * don't then it means all layouts were ROC and at this
-			 * point we returned all of them on file close.
-			 */
-			goto out_unlock;
-		}
-
 		/* Check the stateid */
 		dprintk("%s PROCESS LO_STATEID inode %p\n", __func__, ino);
-		status = nfs4_process_layout_stateid(clp, fp,
+		status = nfs4_process_layout_stateid(clp,
 						     (stateid_t *)&lrp->args.lr_sid,
 						     NFS4_LAYOUT_STID, &ls);
 		nfs4_unlock_state();
 		if (status)
 			goto out;
+		fp = ls->ls_file;
 		layouts_found = pnfs_return_file_layouts(lrp, ls,
 		                                         0, &lo_destroy_list);
 	} else {
@@ -1305,20 +1280,14 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 		                                           0, &lo_destroy_list);
 	}
 
-	dprintk("pNFS %s: clp %p fp %p layout_type 0x%x iomode %d "
+	dprintk("pNFS %s: clp %p fp %p ino %lu layout_type 0x%x iomode %d "
 		"return_type %d fsid 0x%llx offset %llu length %llu: "
 		"layouts_found %d\n",
-		__func__, clp, fp, lrp->args.lr_seg.layout_type,
+		__func__, clp, fp, ino->i_ino, lrp->args.lr_seg.layout_type,
 		lrp->args.lr_seg.iomode, lrp->args.lr_return_type,
 		ex_fsid,
 		lrp->args.lr_seg.offset, lrp->args.lr_seg.length, layouts_found);
 
-	nfs4_lock_state();
-	if (ls)
-		put_layout_state(ls);
-	destroy_layout_list(&lo_destroy_list);
-	nfs4_unlock_state();
-
 	/* update layoutrecalls
 	 * note: for RETURN_{FSID,ALL}, fp may be NULL
 	 */
@@ -1338,10 +1307,13 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
 
 	layoutrecall_list_done_put(&lo_destroy_list);
 
-out:
-	if (fp)
-		put_nfs4_file(fp);
+	nfs4_lock_state();
+	if (ls)
+		put_layout_state(ls);
+	destroy_layout_list(&lo_destroy_list);
+	nfs4_unlock_state();
 
+out:
 	dprintk("pNFS %s: exit status %d\n", __func__, status);
 	return status;
 out_unlock:
-- 
1.8.3.1

