Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:37164 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727575AbeIEX4s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:48 -0400
Received: by mail-it0-f68.google.com with SMTP id h20-v6so10970611itf.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:25:14 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.25.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:25:12 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] NFS: Simplify internal check for whether file is open for write
Date: Wed,  5 Sep 2018 15:23:57 -0400
Message-Id: <20180905192400.107485-5-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905192400.107485-4-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com>
 <20180905192400.107485-3-trond.myklebust@hammerspace.com>
 <20180905192400.107485-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 09b3b7146ff4..052db41a7f80 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1328,19 +1328,11 @@ static bool nfs_file_has_writers(struct nfs_inode *nfsi)
 {
 	struct inode *inode = &nfsi->vfs_inode;
 
-	assert_spin_locked(&inode->i_lock);
-
 	if (!S_ISREG(inode->i_mode))
 		return false;
 	if (list_empty(&nfsi->open_files))
 		return false;
-	/* Note: This relies on nfsi->open_files being ordered with writers
-	 *       being placed at the head of the list.
-	 *       See nfs_inode_attach_open_context()
-	 */
-	return (list_first_entry(&nfsi->open_files,
-			struct nfs_open_context,
-			list)->mode & FMODE_WRITE) == FMODE_WRITE;
+	return inode_is_open_for_write(inode);
 }
 
 static bool nfs_file_has_buffered_writers(struct nfs_inode *nfsi)
-- 
2.17.1
