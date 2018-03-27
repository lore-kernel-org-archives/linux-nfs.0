Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34120 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbeC0VLM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 17:11:12 -0400
Received: by mail-it0-f66.google.com with SMTP id z7-v6so17292793iti.1
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 14:11:12 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Declare the size up to date after it was set.
Date: Tue, 27 Mar 2018 17:10:42 -0400
Message-Id: <20180327211042.44050-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we've changed the file size, then ensure we declare it to be
up to date in the inode attributes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 1 +
 fs/nfs/write.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a2c5d4ad4535..ba73eda0600e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -646,6 +646,7 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 	/* Optimisation */
 	if (offset == 0)
 		NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_DATA;
+	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_SIZE;
 
 	spin_unlock(&inode->i_lock);
 	truncate_pagecache(inode, offset);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 485ce488eb0b..f3426a2d01de 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -231,6 +231,7 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 	if (i_size >= end)
 		goto out;
 	i_size_write(inode, end);
+	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_SIZE;
 	nfs_inc_stats(inode, NFSIOS_EXTENDWRITE);
 out:
 	spin_unlock(&inode->i_lock);
-- 
2.14.3

