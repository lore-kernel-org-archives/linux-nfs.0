Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36013 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab2IMXfJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:35:09 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 03/10] SQUASHME: pnfsd: Pass less arguments to init_layout()
Date: Fri, 14 Sep 2012 02:34:57 +0300
Message-ID: <1347579297-21513-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of passing all parameters individually, of which
one was unused. Pass the structures these originate from.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 509b260..f0e193a 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -301,9 +301,8 @@ init_layout(struct nfs4_layout *lp,
 	    struct nfs4_layout_state *ls,
 	    struct nfs4_file *fp,
 	    struct nfs4_client *clp,
-	    struct svc_fh *current_fh,
-	    struct nfsd4_layout_seg *seg,
-	    stateid_t *stateid)
+	    struct nfsd4_pnfs_layoutget *lgp,
+	    struct nfsd4_pnfs_layoutget_res *res)
 {
 	dprintk("pNFS %s: lp %p ls %p clp %p fp %p ino %p\n", __func__,
 		lp, ls, clp, fp, fp->fi_inode);
@@ -311,10 +310,10 @@ init_layout(struct nfs4_layout *lp,
 	get_nfs4_file(fp);
 	lp->lo_client = clp;
 	lp->lo_file = fp;
-	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
+	memcpy(&lp->lo_seg, &res->lg_seg, sizeof(lp->lo_seg));
 	get_layout_state(ls);		/* put on destroy_layout */
 	lp->lo_state = ls;
-	update_layout_stateid(ls, stateid);
+	update_layout_stateid(ls, &lgp->lg_sid);
 	list_add_tail(&lp->lo_perclnt, &clp->cl_layouts);
 	list_add_tail(&lp->lo_perfile, &fp->fi_layouts);
 	dprintk("pNFS %s end\n", __func__);
@@ -829,7 +828,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 		goto out_freelayout;
 
 	/* Can't merge, so let's initialize this new layout */
-	init_layout(lp, ls, fp, clp, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
+	init_layout(lp, ls, fp, clp, lgp, &res);
 out_unlock:
 	if (ls)
 		put_layout_state(ls);
-- 
1.7.10.2.677.gb6bc67f

