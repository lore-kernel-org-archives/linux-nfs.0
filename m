Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:39142 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936450AbeE2PtE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 11:49:04 -0400
Received: by mail-io0-f193.google.com with SMTP id 200-v6so17126763ioz.6
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 08:49:03 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id y14-v6sm16396515ioc.52.2018.05.29.08.49.02
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 08:49:02 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFS: Ensure we revalidate the inode correctly after remove or rename
Date: Tue, 29 May 2018 11:48:36 -0400
Message-Id: <20180529154838.12903-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180529154838.12903-3-trond.myklebust@hammerspace.com>
References: <20180529154838.12903-1-trond.myklebust@hammerspace.com>
 <20180529154838.12903-2-trond.myklebust@hammerspace.com>
 <20180529154838.12903-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We may need to revalidate the change attribute, ctime and the nlinks count.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ed20ff51f865..8c51083e1456 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1284,11 +1284,13 @@ static void nfs_drop_nlink(struct inode *inode)
 {
 	spin_lock(&inode->i_lock);
 	/* drop the inode if we're reasonably sure this is the last link */
-	if (inode->i_nlink == 1)
-		clear_nlink(inode);
+	if (inode->i_nlink > 0)
+		drop_nlink(inode);
+	NFS_I(inode)->attr_gencount = nfs_inc_attr_generation_counter();
 	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_CHANGE
 		| NFS_INO_INVALID_CTIME
-		| NFS_INO_INVALID_OTHER;
+		| NFS_INO_INVALID_OTHER
+		| NFS_INO_REVAL_FORCED;
 	spin_unlock(&inode->i_lock);
 }
 
@@ -2071,7 +2073,15 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	} else
 		error = task->tk_status;
 	rpc_put_task(task);
-	nfs_mark_for_revalidate(old_inode);
+	/* Ensure the inode attributes are revalidated */
+	if (error == 0) {
+		spin_lock(&old_inode->i_lock);
+		NFS_I(old_inode)->attr_gencount = nfs_inc_attr_generation_counter();
+		NFS_I(old_inode)->cache_validity |= NFS_INO_INVALID_CHANGE
+			| NFS_INO_INVALID_CTIME
+			| NFS_INO_REVAL_FORCED;
+		spin_unlock(&old_inode->i_lock);
+	}
 out:
 	if (rehash)
 		d_rehash(rehash);
-- 
2.17.0

