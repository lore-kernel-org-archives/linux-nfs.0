Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:40766 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbeEJT3X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 15:29:23 -0400
Received: by mail-it0-f66.google.com with SMTP id j186-v6so4513445ita.5
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2018 12:29:22 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i12-v6sm713921iod.85.2018.05.10.12.29.21
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 12:29:21 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Optimise away lookups for rename targets
Date: Thu, 10 May 2018 15:28:58 -0400
Message-Id: <20180510192858.18539-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180510192858.18539-2-trond.myklebust@hammerspace.com>
References: <20180510192858.18539-1-trond.myklebust@hammerspace.com>
 <20180510192858.18539-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can optimise away any lookup for a rename target, unless we're
being asked to revalidate a dentry that might be in use.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9dde88334c9c..b315f53b3aec 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1051,13 +1051,15 @@ int nfs_lookup_verify_inode(struct inode *inode, unsigned int flags)
  *
  * If LOOKUP_RCU prevents us from performing a full check, return 1
  * suggesting a reval is needed.
+ *
+ * Note that when creating a new file, or looking up a rename target,
+ * then it shouldn't be necessary to revalidate a negative dentry.
  */
 static inline
 int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 		       unsigned int flags)
 {
-	/* Don't revalidate a negative dentry if we're creating a new file */
-	if (flags & LOOKUP_CREATE)
+	if (flags & (LOOKUP_CREATE | LOOKUP_RENAME_TARGET))
 		return 0;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
 		return 1;
@@ -1347,7 +1349,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	 * If we're doing an exclusive create, optimize away the lookup
 	 * but don't hash the dentry.
 	 */
-	if (nfs_is_exclusive_create(dir, flags))
+	if (nfs_is_exclusive_create(dir, flags) || flags & LOOKUP_RENAME_TARGET)
 		return NULL;
 
 	res = ERR_PTR(-ENOMEM);
-- 
2.17.0

