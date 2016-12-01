Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35038 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757511AbcLAWTb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:31 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so4680525ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:31 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/26] pNFS: Fix race in pnfs_wait_on_layoutreturn
Date: Thu,  1 Dec 2016 17:19:02 -0500
Message-Id: <20161201221922.15657-7-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-6-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must put the task to sleep while holding the inode->i_lock in order
to ensure atomicity with the test for NFS_LAYOUT_RETURN.

Fixes: 500d701f336b ("NFS41: make close wait for layoutreturn")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 06bfcd277006..e17d9ec82ca7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1257,13 +1257,11 @@ bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
 	 * i_lock */
         spin_lock(&ino->i_lock);
         lo = nfsi->layout;
-        if (lo && test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+        if (lo && test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags)) {
+                rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
                 sleep = true;
+	}
         spin_unlock(&ino->i_lock);
-
-        if (sleep)
-                rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
-
         return sleep;
 }
 
-- 
2.9.3

