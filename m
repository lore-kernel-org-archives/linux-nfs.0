Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47802 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752009AbcJKTxX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Oct 2016 15:53:23 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH][RESEND] pnfs/blocklayout: fix last_write_offset incorrectly set to page boundary
Date: Tue, 11 Oct 2016 15:53:21 -0400
Message-Id: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1476215430.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm resending this as the original was buried in a thread and I want to make
sure it gets picked up.  This fixes a bug that went in v4.8.

8<--------------------------------------------------------------------------

Commit 41963c10c47a35185e68cb9049f7a3493c94d2d7 sets the block layout's
last written byte to the offset of the end of the extent rather than the
end of the write which incorrectly updates the inode's size for
partial-page writes.

Fixes: 41963c10c47a ("pnfs/blocklayout: update last_write_offset atomically with extents")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 217847679f0e..2905479f214a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -344,9 +344,10 @@ static void bl_write_cleanup(struct work_struct *work)
 		u64 start = hdr->args.offset & (loff_t)PAGE_MASK;
 		u64 end = (hdr->args.offset + hdr->args.count +
 			PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
+		u64 lwb = hdr->args.offset + hdr->args.count;
 
 		ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
-					(end - start) >> SECTOR_SHIFT, end);
+					(end - start) >> SECTOR_SHIFT, lwb);
 	}
 
 	pnfs_ld_write_done(hdr);
-- 
2.5.5

