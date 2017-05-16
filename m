Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34958 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753074AbdEPNgl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 May 2017 09:36:41 -0400
Received: by mail-io0-f193.google.com with SMTP id o12so14460641iod.2
        for <linux-nfs@vger.kernel.org>; Tue, 16 May 2017 06:36:41 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Fix commit policy for non-blocking calls to nfs_write_inode()
Date: Tue, 16 May 2017 09:36:28 -0400
Message-Id: <20170516133628.16525-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170516133628.16525-3-trond.myklebust@primarydata.com>
References: <20170516133628.16525-1-trond.myklebust@primarydata.com>
 <20170516133628.16525-2-trond.myklebust@primarydata.com>
 <20170516133628.16525-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the writes will schedule a commit on their own, we don't
need nfs_write_inode() to schedule one if there are outstanding
writes, and we're being called in non-blocking mode.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 051197cb9195..b1af5dee5e0a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1941,7 +1941,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 		/* Don't commit yet if this is a non-blocking flush and there
 		 * are a lot of outstanding writes for this mapping.
 		 */
-		if (nfsi->commit_info.ncommit <= (nfsi->nrequests >> 1))
+		if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_WRITEBACK))
 			goto out_mark_dirty;
 
 		/* don't wait for the COMMIT response */
-- 
2.9.4

