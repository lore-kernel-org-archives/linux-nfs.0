Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40884 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932265AbcHSBWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Aug 2016 21:22:07 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH] pnfs/blocklayout: update last_write_offset atomically with extents
Date: Thu, 18 Aug 2016 11:55:53 -0400
Message-Id: <a754067b5a8252a10a0bcfa23c4229cf3d7b1adf.1471535578.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Block/SCSI layout write completion may add committable extents to the
extent tree before updating the layout's last-written byte under the inode
lock.  If a sync happens before this value is updated, then
prepare_layoutcommit may find and encode these extents which would produce
a LAYOUTCOMMIT request whose encoded extents are larger than the request's
loca_length.

Fix this by holding the i_lock while marking extents writeable and updating
the value of the last written byte.  Then extending the i_lock over
prepare_layoutcommit in pnfs_layoutcommit_inode() ensures we won't find
extents starting beyond the current last written byte.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 3 +++
 fs/nfs/pnfs.c                    | 4 +---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 17a42e4eb872..36923b55f4f8 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -343,8 +343,11 @@ static void bl_write_cleanup(struct work_struct *work)
 		u64 end = (hdr->args.offset + hdr->args.count +
 			PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
 
+		spin_lock(&hdr->inode->i_lock);
+		bl->bl_layout.plh_lwb = hdr->args.offset + hdr->res.count;
 		ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
 					(end - start) >> SECTOR_SHIFT);
+		spin_unlock(&hdr->inode->i_lock);
 	}
 
 	pnfs_ld_write_done(hdr);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4110c1dc8f68..978df68c498c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2386,7 +2386,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	end_pos = nfsi->layout->plh_lwb;
 
 	nfs4_stateid_copy(&data->args.stateid, &nfsi->layout->plh_stateid);
-	spin_unlock(&inode->i_lock);
 
 	data->args.inode = inode;
 	data->cred = get_rpccred(nfsi->layout->plh_lc_cred);
@@ -2403,14 +2402,13 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 		status = ld->prepare_layoutcommit(&data->args);
 		if (status) {
 			put_rpccred(data->cred);
-			spin_lock(&inode->i_lock);
 			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
 			if (end_pos > nfsi->layout->plh_lwb)
 				nfsi->layout->plh_lwb = end_pos;
 			goto out_unlock;
 		}
 	}
-
+	spin_unlock(&inode->i_lock);
 
 	status = nfs4_proc_layoutcommit(data, sync);
 out:
-- 
2.5.5

