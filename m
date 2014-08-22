Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:40019 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbaHVWtc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 18:49:32 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so7300857ier.27
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2014 15:49:32 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 2/2] NFS: Ensure that rpciod does not trigger reclaim writebacks
Date: Fri, 22 Aug 2014 18:49:32 -0400
Message-Id: <1408747772-37938-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
References: <53F6F772.6020708@oracle.com>
 <1408747772-37938-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The same rpciod codepaths that can trigger GFP_KERNEL allocations
are still able to initiate writeback of NFS pages. Avoid this by
adding an explicit test for PF_FSTRANS in nfs_writepage().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 175d5d073ccf..b87f681c0e84 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -14,6 +14,7 @@
 #include <linux/writeback.h>
 #include <linux/swap.h>
 #include <linux/migrate.h>
+#include <linux/sched.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
@@ -633,9 +634,14 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 
 int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
-	int ret;
+	int ret = 0;
 
+	if (unlikely(current->flags & PF_FSTRANS)) {
+		redirty_page_for_writepage(wbc, page);
+		goto unlock;
+	}
 	ret = nfs_writepage_locked(page, wbc);
+unlock:
 	unlock_page(page);
 	return ret;
 }
-- 
1.9.3

