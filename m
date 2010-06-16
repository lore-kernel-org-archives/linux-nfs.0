From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: pnfs-submit: handle NULL in pnfs_destroy_layout
Date: Wed, 16 Jun 2010 12:38:18 -0400
Message-ID: <1276706298-20168-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50378 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755881Ab0FPQiO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jun 2010 12:38:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 746b039..414b7dc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -393,8 +393,10 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	};
 
 	lo = get_lock_current_layout(nfsi);
-	pnfs_free_layout(lo, &range);
-	put_unlock_current_layout(lo);
+	if (lo) {
+		pnfs_free_layout(lo, &range);
+		put_unlock_current_layout(lo);
+	}
 }
 
 static inline void
-- 
1.6.4.4

