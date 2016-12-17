Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34639 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752554AbcLQS1V (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:21 -0500
Received: by mail-it0-f65.google.com with SMTP id 75so6187398ite.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:21 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] NFS: Only look at the change attribute cache state in nfs_weak_revalidate()
Date: Sat, 17 Dec 2016 13:27:08 -0500
Message-Id: <20161217182711.10643-7-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-6-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <20161217182711.10643-3-trond.myklebust@primarydata.com>
 <20161217182711.10643-4-trond.myklebust@primarydata.com>
 <20161217182711.10643-5-trond.myklebust@primarydata.com>
 <20161217182711.10643-6-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just like in nfs_check_verifier(), we want to use
nfs_mapping_need_revalidate_inode() to check our knowledge of the
change attribute is up to date.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cb22a9f9ae7e..8f706f3e5c05 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1273,8 +1273,8 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
  */
 static int nfs_weak_revalidate(struct dentry *dentry, unsigned int flags)
 {
-	int error;
 	struct inode *inode = d_inode(dentry);
+	int error = 0;
 
 	/*
 	 * I believe we can only get a negative dentry here in the case of a
@@ -1293,7 +1293,8 @@ static int nfs_weak_revalidate(struct dentry *dentry, unsigned int flags)
 		return 0;
 	}
 
-	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (nfs_mapping_need_revalidate_inode(inode))
+		error = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	dfprintk(LOOKUPCACHE, "NFS: %s: inode %lu is %s\n",
 			__func__, inode->i_ino, error ? "invalid" : "valid");
 	return !error;
-- 
2.9.3

