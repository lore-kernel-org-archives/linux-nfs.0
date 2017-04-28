Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:5899 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1425769AbdD1Kef (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Apr 2017 06:34:35 -0400
From: Hou Tao <houtao1@huawei.com>
To: <linux-nfs@vger.kernel.org>
CC: <linux-kernel@vger.kernel.org>, <trond.myklebust@primarydata.com>,
        <anna.schumaker@netapp.com>
Subject: [PATCH] NFS: always treat the invocation of nfs_getattr as cache hit when noac is on
Date: Fri, 28 Apr 2017 18:35:19 +0800
Message-ID: <1493375719-47609-1-git-send-email-houtao1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using 'ls -l' to display a large directory, if noac option is used,
in function nfs_getattr() nfs_need_revalidate_inode() will always be true
for NFSv3 and the nfs_entry cache of the directory will be flushed. The
flush will lead to a fully reread of the directory entries from server.

To prevent the unnecessary RPCs, we need to check whether or not the
noac option is used, and always report the invocation of nfs_getattr()
as cache hit instead cache miss when it's on.

Signed-off-by: Hou Tao <houtao1@huawei.com>
---
 fs/nfs/inode.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f489a5a..1de93ba 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -734,7 +734,10 @@ int nfs_getattr(const struct path *path, struct kstat *stat,
 	if (need_atime || nfs_need_revalidate_inode(inode)) {
 		struct nfs_server *server = NFS_SERVER(inode);
 
-		nfs_readdirplus_parent_cache_miss(path->dentry);
+		if (!(server->flags & NFS_MOUNT_NOAC))
+			nfs_readdirplus_parent_cache_miss(path->dentry);
+		else
+			nfs_readdirplus_parent_cache_hit(path->dentry);
 		err = __nfs_revalidate_inode(server, inode);
 	} else
 		nfs_readdirplus_parent_cache_hit(path->dentry);
-- 
2.5.0

