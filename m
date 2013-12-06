Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:12165 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab3LFJbg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2013 04:31:36 -0500
From: Rui Xiang <rui.xiang@huawei.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Rui Xiang <rui.xiang@huawei.com>
Subject: [PATCH 2/2] nfs: fix return err if inode exiting in nfs_instantiate
Date: Fri, 6 Dec 2013 17:30:17 +0800
Message-ID: <1386322217-27436-2-git-send-email-rui.xiang@huawei.com>
In-Reply-To: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com>
References: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In common function nfs_instantiate to create, mkdir, and mknod,
if dentry->d_inode exits, it should return -EEXIST instead of
-EACCES.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2518865..e570b37 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1547,7 +1547,7 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
 	struct dentry *parent = dget_parent(dentry);
 	struct inode *dir = parent->d_inode;
 	struct inode *inode;
-	int error = -EACCES;
+	int error = -EEXIST;
 
 	d_drop(dentry);
 
-- 
1.8.2.2


