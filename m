Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:11591 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772Ab3LFJay (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2013 04:30:54 -0500
From: Rui Xiang <rui.xiang@huawei.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Rui Xiang <rui.xiang@huawei.com>
Subject: [PATCH 1/2] nfs/nfsd: return err directly while malloc failing
Date: Fri, 6 Dec 2013 17:30:16 +0800
Message-ID: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

while nthreads malloc fails, return err value directory
without kfree.

And the same issue arises in nfs_lookup, so return res
directly without freeing fh and fattr.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 fs/nfs/dir.c     | 4 ++--
 fs/nfsd/nfsctl.c | 7 ++++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 812154a..2518865 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1278,7 +1278,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 
 	res = ERR_PTR(-ENAMETOOLONG);
 	if (dentry->d_name.len > NFS_SERVER(dir)->namelen)
-		goto out;
+		return res;
 
 	/*
 	 * If we're doing an exclusive create, optimize away the lookup
@@ -1287,7 +1287,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 	if (nfs_is_exclusive_create(dir, flags)) {
 		d_instantiate(dentry, NULL);
 		res = NULL;
-		goto out;
+		return res;
 	}
 
 	res = ERR_PTR(-ENOMEM);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f55517..3c5e748 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -491,9 +491,10 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	}
 
 	nthreads = kcalloc(npools, sizeof(int), GFP_KERNEL);
-	rv = -ENOMEM;
-	if (nthreads == NULL)
-		goto out_free;
+	if (nthreads == NULL) {
+		mutex_unlock(&nfsd_mutex);
+		return -ENOENT;
+	}
 
 	if (size > 0) {
 		for (i = 0; i < npools; i++) {
-- 
1.8.2.2


