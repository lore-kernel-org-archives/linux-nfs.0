Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59741 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbaKCUTv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2014 15:19:51 -0500
Received: by mail-ie0-f172.google.com with SMTP id at20so6032885iec.31
        for <linux-nfs@vger.kernel.org>; Mon, 03 Nov 2014 12:19:50 -0800 (PST)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] nfs: remove spurious WARN_ON_ONCE in write path
Date: Mon,  3 Nov 2014 15:19:45 -0500
Message-Id: <1415045985-60963-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This WARN_ON_ONCE was supposed to catch reference counting bugs, but can
trigger in inappropriate situations.

This was reproducible using NFSv2 on an architecture with 64K pages -- we
verified that it was not a reference counting bug and the warning was
safe to ignore.

Reported-by: Will Deacon <will.deacon@arm.com>
Tested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/write.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 12493846a2d3..f83b02dc9166 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -715,8 +715,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 
 	if (test_and_clear_bit(PG_INODE_REF, &req->wb_flags))
 		nfs_release_request(req);
-	else
-		WARN_ON_ONCE(1);
 }
 
 static void
-- 
1.9.3 (Apple Git-50)

