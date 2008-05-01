From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfs: fix race in nfs_dirty_request
Date: Thu,  1 May 2008 20:03:22 +0300
Message-ID: <1209661402-22736-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57310 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756952AbYEAROb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2008 13:14:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

When called from nfs_flush_incompatible, the req is not locked, so
req->wb_page might be set to NULL before it is used by PageWriteback.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bed6341..04f15c7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -428,7 +428,7 @@ nfs_dirty_request(struct nfs_page *req)
 
 	if (page == NULL || test_bit(PG_NEED_COMMIT, &req->wb_flags))
 		return 0;
-	return !PageWriteback(req->wb_page);
+	return !PageWriteback(page);
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-- 
1.5.3.3

