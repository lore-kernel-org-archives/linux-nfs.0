From: Jim Rees <rees@umich.edu>
Subject: [PATCH v1 23/25] pnfsblock: Implement release_inval_marks
Date: Sun, 17 Jul 2011 19:59:10 -0400
Message-ID: <1310947152-12255-24-git-send-email-rees@umich.edu>
References: <1310947152-12255-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:37643 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756426Ab1GQX7u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Jul 2011 19:59:50 -0400
In-Reply-To: <1310947152-12255-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>

Leaving it unimplemented will cause memory leak.

Signed-off-by: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d6ace20..f2ec40e 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -525,10 +525,15 @@ release_extents(struct pnfs_block_layout *bl, struct pnfs_layout_range *range)
 	spin_unlock(&bl->bl_ext_lock);
 }
 
-/* STUB */
 static void
 release_inval_marks(struct pnfs_inval_markings *marks)
 {
+	struct pnfs_inval_tracking *pos, *temp;
+
+	list_for_each_entry_safe(pos, temp, &marks->im_tree.mtt_stub, it_link) {
+		list_del(&pos->it_link);
+		kfree(pos);
+	}
 	return;
 }
 
-- 
1.7.4.1

