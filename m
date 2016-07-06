Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33188 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879AbcGFWar (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:30:47 -0400
Received: by mail-it0-f68.google.com with SMTP id y93so926174ita.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 10/28] pNFS/flexfiles: Clean up calls to pnfs_set_layoutcommit()
Date: Wed,  6 Jul 2016 18:29:47 -0400
Message-Id: <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let's just have one place where we check ff_layout_need_layoutcommit().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 2689c9e9dc3c..14f2ed3f1a5b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1325,15 +1325,16 @@ ff_layout_need_layoutcommit(struct pnfs_layout_segment *lseg)
  * we always send layoutcommit after DS writes.
  */
 static void
-ff_layout_set_layoutcommit(struct nfs_pgio_header *hdr)
+ff_layout_set_layoutcommit(struct inode *inode,
+		struct pnfs_layout_segment *lseg,
+		loff_t end_offset)
 {
-	if (!ff_layout_need_layoutcommit(hdr->lseg))
+	if (!ff_layout_need_layoutcommit(lseg))
 		return;
 
-	pnfs_set_layoutcommit(hdr->inode, hdr->lseg,
-			hdr->mds_offset + hdr->res.count);
-	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
-		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
+	pnfs_set_layoutcommit(inode, lseg, end_offset);
+	dprintk("%s inode %lu pls_end_pos %llu\n", __func__, inode->i_ino,
+		(unsigned long long) NFS_I(inode)->layout->plh_lwb);
 }
 
 static bool
@@ -1494,7 +1495,8 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 
 	if (hdr->res.verf->committed == NFS_FILE_SYNC ||
 	    hdr->res.verf->committed == NFS_DATA_SYNC)
-		ff_layout_set_layoutcommit(hdr);
+		ff_layout_set_layoutcommit(hdr->inode, hdr->lseg,
+				hdr->mds_offset + (loff_t)hdr->res.count);
 
 	/* zero out fattr since we don't care DS attr at all */
 	hdr->fattr.valid = 0;
@@ -1530,8 +1532,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
-	if (ff_layout_need_layoutcommit(data->lseg))
-		pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
+	ff_layout_set_layoutcommit(data->inode, data->lseg, data->lwb);
 
 	return 0;
 }
-- 
2.7.4

