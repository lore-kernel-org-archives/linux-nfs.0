Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33238 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaGCFIJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 01:08:09 -0400
Received: by mail-pd0-f176.google.com with SMTP id ft15so13166993pdb.21
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 22:08:09 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>,
        Tom Haynes <Thomas.Haynes@primarydata.com>
Subject: [PATCH 1/2] pnfs/filelayout: fix race between mark_request_commit and scan_commit_lists
Date: Thu,  3 Jul 2014 13:07:45 +0800
Message-Id: <1404364066-13031-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to hold cinfo lock while setting bucket->wlseg and adding req to nwritten
list at the same time. Otherwise there might be a window where nwritten list
is empty yet we set bucket->wlseg, in which case ff_layout_scan_ds_commit_list()
may end up clearing bucket->wlseg incorrectly, casuing client to oops later on.

This was found when testing flexfile layout but filelayout has the same problem.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 43 ++++++++++++++++++++++++------------------
 1 file changed, 25 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 504d58a..a928f92 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1035,18 +1035,22 @@ out:
 	pnfs_put_lseg(freeme);
 }
 
-static struct list_head *
-filelayout_choose_commit_list(struct nfs_page *req,
-			      struct pnfs_layout_segment *lseg,
-			      struct nfs_commit_info *cinfo)
+static void
+filelayout_mark_request_commit(struct nfs_page *req,
+			       struct pnfs_layout_segment *lseg,
+			       struct nfs_commit_info *cinfo)
+
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 	u32 i, j;
 	struct list_head *list;
 	struct pnfs_commit_bucket *buckets;
 
-	if (fl->commit_through_mds)
-		return &cinfo->mds->list;
+	if (fl->commit_through_mds) {
+		list = &cinfo->mds->list;
+		spin_lock(cinfo->lock);
+		goto mds_commit;
+	}
 
 	/* Note that we are calling nfs4_fl_calc_j_index on each page
 	 * that ends up being committed to a data server.  An attractive
@@ -1070,19 +1074,22 @@ filelayout_choose_commit_list(struct nfs_page *req,
 	}
 	set_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 	cinfo->ds->nwritten++;
-	spin_unlock(cinfo->lock);
-	return list;
-}
 
-static void
-filelayout_mark_request_commit(struct nfs_page *req,
-			       struct pnfs_layout_segment *lseg,
-			       struct nfs_commit_info *cinfo)
-{
-	struct list_head *list;
-
-	list = filelayout_choose_commit_list(req, lseg, cinfo);
-	nfs_request_add_commit_list(req, list, cinfo);
+mds_commit:
+	/* nfs_request_add_commit_list(). We need to add req to list without
+	 * dropping cinfo lock.
+	 */
+	set_bit(PG_CLEAN, &(req)->wb_flags);
+	nfs_list_add_request(req, list);
+	cinfo->mds->ncommit++;
+	spin_unlock(cinfo->lock);
+	if (!cinfo->dreq) {
+		inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev_info,
+			     BDI_RECLAIMABLE);
+		__mark_inode_dirty(req->wb_context->dentry->d_inode,
+				   I_DIRTY_DATASYNC);
+	}
 }
 
 static u32 calc_ds_index_from_commit(struct pnfs_layout_segment *lseg, u32 i)
-- 
1.9.1

