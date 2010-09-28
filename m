Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753802Ab0I1NOD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 09:14:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: fengguang.wu@gmail.com, linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: don't use FLUSH_SYNC on WB_SYNC_NONE COMMIT calls (try #2)
Date: Tue, 28 Sep 2010 09:14:01 -0400
Message-Id: <1285679641-19763-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

WB_SYNC_NONE is supposed to mean "don't wait on anything". That should
also include not waiting for COMMIT calls to complete.

WB_SYNC_NONE is also implied when wbc->nonblocking and
wbc->for_background are set, so we can replace those checks in
nfs_commit_unstable_pages with a check for WB_SYNC_NONE.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4d6d35d..605e292 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1431,15 +1431,17 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 	int flags = FLUSH_SYNC;
 	int ret = 0;
 
-	/* Don't commit yet if this is a non-blocking flush and there are
-	 * lots of outstanding writes for this mapping.
-	 */
-	if (wbc->sync_mode == WB_SYNC_NONE &&
-	    nfsi->ncommit <= (nfsi->npages >> 1))
-		goto out_mark_dirty;
+	if (wbc->sync_mode == WB_SYNC_NONE) {
+		/* Don't commit yet if this is a non-blocking flush and there
+		 * are a lot of outstanding writes for this mapping.
+		 */
+		if (nfsi->ncommit <= (nfsi->npages >> 1))
+			goto out_mark_dirty;
 
-	if (wbc->nonblocking || wbc->for_background)
+		/* don't wait for the COMMIT response */
 		flags = 0;
+	}
+
 	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0) {
 		if (wbc->sync_mode == WB_SYNC_NONE) {
-- 
1.7.1

