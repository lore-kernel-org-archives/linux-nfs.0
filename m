Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34973 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752428AbdFTXgP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jun 2017 19:36:15 -0400
Received: by mail-it0-f68.google.com with SMTP id f20so17157667itb.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jun 2017 16:36:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RESEND 3/3] NFS: Fix commit policy for non-blocking calls to nfs_write_inode()
Date: Tue, 20 Jun 2017 19:35:38 -0400
Message-Id: <20170620233539.22417-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170620233539.22417-3-trond.myklebust@primarydata.com>
References: <20170620233539.22417-1-trond.myklebust@primarydata.com>
 <20170620233539.22417-2-trond.myklebust@primarydata.com>
 <20170620233539.22417-3-trond.myklebust@primarydata.com>
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

