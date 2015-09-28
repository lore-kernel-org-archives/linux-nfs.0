Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:44481 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933794AbbI1Of4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2015 10:35:56 -0400
From: Yaowei Bai <bywxiaobai@163.com>
To: viro@zeniv.linux.org.uk, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 13/17] fs/nfs: remove unnecessary new_valid_dev check
Date: Mon, 28 Sep 2015 22:30:32 +0800
Message-Id: <1443450632-5647-1-git-send-email-bywxiaobai@163.com>
In-Reply-To: <1443446807-4838-1-git-send-email-bywxiaobai@163.com>
References: <1443446807-4838-1-git-send-email-bywxiaobai@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As new_valid_dev always returns 1, so !new_valid_dev check is not
needed, remove it.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 fs/nfs/dir.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3d8e4ff..ce5a218 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1714,9 +1714,6 @@ nfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t rdev)
 	dfprintk(VFS, "NFS: mknod(%s/%lu), %pd\n",
 			dir->i_sb->s_id, dir->i_ino, dentry);
 
-	if (!new_valid_dev(rdev))
-		return -EINVAL;
-
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
-- 
1.9.1


