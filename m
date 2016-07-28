Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241AbcG1SlM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2016 14:41:12 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "hch@infradead.org" <hch@infradead.org>
Subject: [PATCH 1/2] pnfs/blocklayout: update last_write_offset in prepare_layoutcommit
Date: Thu, 28 Jul 2016 14:41:09 -0400
Message-Id: <973de15d7e14e23d6945ad03713384c97a6a0087.1469730653.git.bcodding@redhat.com>
In-Reply-To: <cover.1469730653.git.bcodding@redhat.com>
References: <cover.1469730653.git.bcodding@redhat.com>
In-Reply-To: <cover.1469730653.git.bcodding@redhat.com>
References: <cover.1469730653.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Block/SCSI layout write completion may add committable extents to the
extent tree before updating the layout's last-written byte under the inode
lock.  If a sync happens before this value is updated, then
prepare_layoutcommit may find and encode these extents which would produce
a LAYOUTCOMMIT request whose encoded extents are larger than the request's
loca_length.

Fix this by updating the last_write_offset to match the currently encoded
extents.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/extent_tree.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 992bcb19c11e..18ae1fd2175e 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -518,7 +518,7 @@ static __be32 *encode_scsi_range(struct pnfs_block_extent *be, __be32 *p)
 }
 
 static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
-		size_t buffer_size, size_t *count)
+		size_t buffer_size, size_t *count, __u64 *lastbyte)
 {
 	struct pnfs_block_extent *be;
 	int ret = 0;
@@ -541,6 +541,8 @@ static int ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
 		else
 			p = encode_block_extent(be, p);
 		be->be_tag = EXTENT_COMMITTING;
+		if ((ext_f_end(be) << SECTOR_SHIFT) - 1 > *lastbyte)
+			*lastbyte = (ext_f_end(be) << SECTOR_SHIFT) - 1;
 	}
 	spin_unlock(&bl->bl_ext_lock);
 
@@ -564,7 +566,7 @@ ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg)
 	arg->layoutupdate_pages = &arg->layoutupdate_page;
 
 retry:
-	ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count);
+	ret = ext_tree_encode_commit(bl, start_p + 1, buffer_size, &count, &arg->lastbytewritten);
 	if (unlikely(ret)) {
 		ext_tree_free_commitdata(arg, buffer_size);
 
-- 
2.5.5

