Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35227 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbL1SiB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 13:38:01 -0500
Received: by mail-io0-f173.google.com with SMTP id 77so1142141ioc.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 10:38:00 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Background flush should not be low priority
Date: Mon, 28 Dec 2015 13:37:28 -0500
Message-Id: <1451327849-40281-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Background flush is needed in order to satisfy the global page limits.
Don't subvert by reducing the priority.
This should also address a write starvation issue that was reported by
Neil Brown.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7b9316406930..7a4fe7d82e65 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -247,8 +247,6 @@ static int wb_priority(struct writeback_control *wbc)
 		return FLUSH_HIGHPRI | FLUSH_STABLE;
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		ret = FLUSH_COND_STABLE;
-	if (wbc->for_kupdate || wbc->for_background)
-		ret |= FLUSH_LOWPRI;
 	return ret;
 }
 
-- 
2.5.0

