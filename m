Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:45783 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754717Ab1FLXpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:45:09 -0400
Message-Id: <6097a43894b0daf545a235ad3f074f627d897987.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:45:07 -0400
Subject: [PATCH 32/34] pnfsblock: Implement release_inval_marks
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>

Leaving it unimplemented will cause memory leak.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 242c232..f201191 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -525,10 +525,15 @@ release_extents(struct pnfs_block_layout *bl,
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

