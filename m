From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: DEBUG: pnfs-submit: define and use BUG_ON_UNLOCKED_INO
Date: Tue, 13 Jul 2010 12:17:32 +0300
Message-ID: <1279012652-3318-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61311 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751207Ab0GMJRk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 05:17:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

in pnfs_alloc_layout there's no layout yet so we can't use
BUG_ON_UNLOCKED_LO. Checking spin_is_lock does not work well too
as it always returns false for uni-processors with no DEBUG_SPINLOCK.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8b26104..6382cc6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -310,9 +310,12 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
  * pNFS client layout cache
  */
 #if defined(CONFIG_SMP)
+#define BUG_ON_UNLOCKED_INO(ino) \
+	BUG_ON(!spin_is_locked(&ino->i_lock))
 #define BUG_ON_UNLOCKED_LO(lo) \
-	BUG_ON(!spin_is_locked(&PNFS_INODE(lo)->i_lock))
+	BUG_ON_UNLOCKED_INO(PNFS_INODE(lo))
 #else /* CONFIG_SMP */
+#define BUG_ON_UNLOCKED_INO(lo) do {} while (0)
 #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
 #endif /* CONFIG_SMP */
 
@@ -871,7 +874,7 @@ pnfs_alloc_layout(struct inode *ino)
 
 	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
-	BUG_ON(!spin_is_locked(&ino->i_lock));
+	BUG_ON_UNLOCKED_INO(ino);
 	if (likely(nfsi->layout))
 		return nfsi->layout;
 
-- 
1.7.1.1

