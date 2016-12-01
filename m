Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33024 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757914AbcLAWTh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:37 -0500
Received: by mail-io0-f195.google.com with SMTP id j92so3935394ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:37 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/26] pNFS: Skip checking for return-on-close if the layout is invalid
Date: Thu,  1 Dec 2016 17:19:08 -0500
Message-Id: <20161201221922.15657-13-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-12-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a64d1e40dba9..330f3a012f8e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1190,7 +1190,8 @@ bool pnfs_roc(struct inode *ino)
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (!lo || test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
+	if (!lo || !pnfs_layout_is_valid(lo) ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 		goto out_noroc;
 
 	/* no roc if we hold a delegation */
-- 
2.9.3

