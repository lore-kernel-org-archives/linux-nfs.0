Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51176 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaHUQHY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:24 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtX-00009A-2o
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:23 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/19] pnfs: force a layout commit when encountering busy segments during recall
Date: Thu, 21 Aug 2014 11:09:19 -0500
Message-Id: <1408637375-11343-4-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Expedite layout recall processing by forcing a layout commit when
we see busy segments.  Without it the layout recall might have to wait
until the VM decided to start writeback for the file, which can introduce
long delays.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/callback_proc.c | 16 +++++++++++-----
 fs/nfs/pnfs.c          |  3 +++
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 41db525..bf017b0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -164,6 +164,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	struct inode *ino;
 	struct pnfs_layout_hdr *lo;
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
+	bool need_commit = false;
 	LIST_HEAD(free_me_list);
 
 	lo = get_layout_by_fh(clp, &args->cbl_fh, &args->cbl_stateid);
@@ -172,16 +173,21 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 
 	ino = lo->plh_inode;
 	spin_lock(&ino->i_lock);
-	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
-					&args->cbl_range))
+	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
 		rv = NFS4ERR_DELAY;
-	else
-		rv = NFS4ERR_NOMATCHING_LAYOUT;
+	} else if (pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
+			&args->cbl_range)) {
+		need_commit = true;
+		rv = NFS4ERR_DELAY;
+	}
+
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
+
+	if (need_commit)
+		pnfs_layoutcommit_inode(ino, false);
 	iput(ino);
 out:
 	return rv;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6e0fa71..242e73f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -604,6 +604,9 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg_list(&lseg_list);
 		pnfs_put_layout_hdr(lo);
+
+		if (ret)
+			pnfs_layoutcommit_inode(inode, false);
 		iput(inode);
 	}
 	return ret;
-- 
1.9.1

