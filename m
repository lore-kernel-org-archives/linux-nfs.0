Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og114.obsmtp.com ([64.18.0.28]:42624 "HELO
	exprod5og114.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754821Ab0J0SW7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:22:59 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] SQUASHME: pnfsd-files: update layout stateid properly
Date: Wed, 27 Oct 2010 20:22:53 +0200
Message-Id: <1288203773-26784-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CC86D96.8020803@panasas.com>
References: <4CC86D96.8020803@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@compute-1-5.palab.panasas.com>

the layout stateid must be updated by layout get only
on success upon changing the actual state, otherwise,
a parallel layout_recall will send the wrong stateid.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 9ce2bf2..fc7f4e5 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -302,7 +302,7 @@ nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
 			if (lsp && ((verify_stateid(fp, stateid)) == 0)) {
 				dprintk("%s parallel initial layout state\n",
 					__func__);
-				goto update;
+				goto verified;
 			}
 
 			dprintk("%s ERROR bad opaque in stateid 1\n", __func__);
@@ -314,14 +314,9 @@ nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
 			dprintk("%s bad stateid 1\n", __func__);
 			goto out_put;
 		}
-update:
-		update_stateid(&ls->ls_stateid);
-		dprintk("%s Updated ls_stateid to %d on layoutstate %p\n",
-			__func__, ls->ls_stateid.si_generation, ls);
 	}
+verified:
 	status = 0;
-	/* Set the stateid to be encoded */
-	memcpy(stateid, &ls->ls_stateid, sizeof(stateid_t));
 
 	/* Return the layout state if requested */
 	if (lsp) {
@@ -351,13 +346,21 @@ free_layout(struct nfs4_layout *lp)
 	kmem_cache_free(pnfs_layout_slab, lp);
 }
 
+#define update_layout_stateid(ls, sid) { \
+	update_stateid(&(ls)->ls_stateid); \
+	dprintk("%s Updated ls_stateid to %d on layoutstate %p\n", \
+		__func__, (ls)->ls_stateid.si_generation, (ls)); \
+	memcpy((sid), &(ls)->ls_stateid, sizeof(stateid_t)); \
+}
+
 static void
 init_layout(struct nfs4_layout_state *ls,
 	    struct nfs4_layout *lp,
 	    struct nfs4_file *fp,
 	    struct nfs4_client *clp,
 	    struct svc_fh *current_fh,
-	    struct nfsd4_layout_seg *seg)
+	    struct nfsd4_layout_seg *seg,
+	    stateid_t *stateid)
 {
 	dprintk("pNFS %s: ls %p lp %p clp %p fp %p ino %p\n", __func__,
 		ls, lp, clp, fp, fp->fi_inode);
@@ -369,6 +372,7 @@ init_layout(struct nfs4_layout_state *ls,
 	lp->lo_state = ls;
 	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
 	spin_lock(&layout_lock);
+	update_layout_stateid(ls, stateid);
 	list_add_tail(&lp->lo_perstate, &ls->ls_layouts);
 	list_add_tail(&lp->lo_perclnt, &clp->cl_layouts);
 	list_add_tail(&lp->lo_perfile, &fp->fi_layouts);
@@ -717,7 +721,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 		goto out_freelayout;
 
 	/* Can't merge, so let's initialize this new layout */
-	init_layout(ls, lp, fp, clp, lgp->lg_fhp, &res.lg_seg);
+	init_layout(ls, lp, fp, clp, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
 out_unlock:
 	if (ls)
 		put_layout_state(ls);
@@ -773,7 +777,8 @@ out:
 
 static int
 pnfs_return_file_layouts(struct nfs4_client *clp, struct nfs4_file *fp,
-			 struct nfsd4_pnfs_layoutreturn *lrp)
+			 struct nfsd4_pnfs_layoutreturn *lrp,
+			 struct nfs4_layout_state *ls)
 {
 	int layouts_found = 0;
 	struct nfs4_layout *lp, *nextlp;
@@ -799,6 +804,8 @@ pnfs_return_file_layouts(struct nfs4_client *clp, struct nfs4_file *fp,
 			destroy_layout(lp);
 		}
 	}
+	if (ls && layouts_found && lrp->lrs_present)
+		update_layout_stateid(ls, &lrp->lr_sid);
 	spin_unlock(&layout_lock);
 
 	return layouts_found;
@@ -838,6 +845,7 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp = NULL;
 	struct nfs4_client *clp;
+	struct nfs4_layout_state *ls = NULL;
 	u64 ex_fsid = current_fh->fh_export->ex_fsid;
 	void *recall_cookie = NULL;
 
@@ -859,13 +867,12 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 
 		/* Check the stateid */
 		dprintk("%s PROCESS LO_STATEID inode %p\n", __func__, ino);
-		status = nfs4_process_layout_stateid(clp, fp, &lrp->lr_sid,
-						     NULL);
+		status = nfs4_process_layout_stateid(clp, fp, &lrp->lr_sid, &ls);
 		if (status)
 			goto out_put_file;
 
 		/* update layouts */
-		layouts_found = pnfs_return_file_layouts(clp, fp, lrp);
+		layouts_found = pnfs_return_file_layouts(clp, fp, lrp, ls);
 		/* optimize for the all-empty case */
 		if (list_empty(&fp->fi_layouts))
 			recall_cookie = PNFS_LAST_LAYOUT_NO_RECALLS;
@@ -884,6 +891,8 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
 out_put_file:
 	if (fp)
 		put_nfs4_file(fp);
+	if (ls)
+		put_layout_state(ls);
 out:
 	nfs4_unlock_state();
 
-- 
1.7.2.3

