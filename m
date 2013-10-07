Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35841 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab3JGPu2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Oct 2013 11:50:28 -0400
Received: by mail-wi0-f171.google.com with SMTP id hm2so5045893wib.4
        for <linux-nfs@vger.kernel.org>; Mon, 07 Oct 2013 08:50:27 -0700 (PDT)
Message-ID: <5252D83D.5060504@primarydata.com>
Date: Mon, 07 Oct 2013 18:50:21 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Christoph Hellwig <hch@infradead.org>,
        Nadav Shemer <nadav@primarydata.com>
Subject: [PATCH v2 3/4] SQUASHME: pnfsd: no need for find_file in layout commit/return
References: <5251140B.4000203@primarydata.com> <1381045472-30717-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <1381045472-30717-1-git-send-email-bhalevy@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the nfs4_file can be found via the layout stateid.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 64 ++++++++++++++++++++++-------------------------------
 1 file changed, 26 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 52fd2d1..474c183 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -259,7 +259,7 @@ struct sbid_tracker {
  * Returns zero and the layout state in *lsp, or error.
  */
 static __be32
-nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
+nfs4_process_layout_stateid(struct nfs4_client *clp,
 			    stateid_t *stateid, unsigned char typemask,
 			    struct nfs4_layout_state **lsp)
 {
@@ -267,8 +267,8 @@ struct sbid_tracker {
 	__be32 status;
 	struct nfs4_stid *stid;

-	dprintk("--> %s clp %p fp %p operation stateid=" STATEID_FMT "\n",
-		__func__, clp, fp, STATEID_VAL(stateid));
+	dprintk("--> %s clp %p operation stateid=" STATEID_FMT "\n",
+		__func__, clp, STATEID_VAL(stateid));

 	nfs4_assert_state_locked();
 	status = nfsd4_lookup_stateid(stateid, typemask, &stid, true,
@@ -295,10 +295,7 @@ struct sbid_tracker {
 	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
 		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));

-	if (lsp)
-		*lsp = ls;
-	else
-		put_layout_state(ls);
+	*lsp = ls;
 out:
 	dprintk("<-- %s status %d\n", __func__, htonl(status));

@@ -920,30 +917,31 @@ struct super_block *
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
@@ -980,8 +978,11 @@ struct super_block *
 	}

 out:
-	if (fp)
-		put_nfs4_file(fp);
+	if (ls) {
+		nfs4_lock_state();
+		put_layout_state(ls);
+		nfs4_unlock_state();
+	}

 	return cpu_to_be32(nfserr);
 }
@@ -1255,26 +1256,15 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
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
@@ -1283,20 +1273,14 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,
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
@@ -1316,10 +1300,14 @@ int nfs4_pnfs_return_layout(struct svc_rqst *rqstp,

 	layoutrecall_list_done_put(&lo_destroy_list);

-out:
-	if (fp)
-		put_nfs4_file(fp);
+	/* put_layout_state here as we need to keep a reference on ls_file */
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

