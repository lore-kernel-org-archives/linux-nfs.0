Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:50993 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaIJPVV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 11:21:21 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRjhw-00006k-DX
	for linux-nfs@vger.kernel.org; Wed, 10 Sep 2014 15:21:20 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] pnfs: force a layout commit when encountering busy segments during recall
Date: Wed, 10 Sep 2014 08:23:29 -0700
Message-Id: <1410362617-28018-2-git-send-email-hch@lst.de>
In-Reply-To: <1410362617-28018-1-git-send-email-hch@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Expedite layout recall processing by forcing a layout commit when
we see busy segments.  Without it the layout recall might have to wait
until the VM decided to start writeback for the file, which can introduce
long delays.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/callback_proc.c | 8 +++++++-
 fs/nfs/pnfs.c          | 3 +++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 41db525..0d26951 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -171,6 +171,13 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto out;
 
 	ino = lo->plh_inode;
+
+	spin_lock(&ino->i_lock);
+	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
+	spin_unlock(&ino->i_lock);
+
+	pnfs_layoutcommit_inode(ino, false);
+
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
@@ -178,7 +185,6 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		rv = NFS4ERR_DELAY;
 	else
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
-	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8827ab1..ce5d1ea 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -594,6 +594,9 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 		dprintk("%s freeing layout for inode %lu\n", __func__,
 			lo->plh_inode->i_ino);
 		inode = lo->plh_inode;
+
+		pnfs_layoutcommit_inode(inode, false);
+
 		spin_lock(&inode->i_lock);
 		list_del_init(&lo->plh_bulk_destroy);
 		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
-- 
1.9.1

