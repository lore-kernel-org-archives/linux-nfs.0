Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:52100 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab1FNCdX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:33:23 -0400
Message-Id: <688262b5d76534c6e5848894718b3e0f832f8102.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 32/33] pnfsblock: Implement release_inval_marks
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:33:21 -0400
From: Jim Rees <rees@umich.edu>
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
index 6de800f..3187c4f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -523,10 +523,15 @@ release_extents(struct pnfs_block_layout *bl, struct pnfs_layout_range *range)
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

