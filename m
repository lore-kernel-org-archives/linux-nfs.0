Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46372 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752386AbdLKGEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 01:04:40 -0500
From: NeilBrown <neilb@suse.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Date: Mon, 11 Dec 2017 17:04:05 +1100
Subject: [PATCH 3/4] NFS: allow name_to_handle_at() to work for Amazon EFS.
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Message-ID: <151297224519.7818.13340308932067502368.stgit@noble>
In-Reply-To: <151297214390.7818.7216826079527521005.stgit@noble>
References: <151297214390.7818.7216826079527521005.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Amazon EFS provides an NFSv4.1 filesystem which appears to use
(close to) full length (128 byte) file handles.
This causes the handle reported by name_to_handle_at() to exceed
MAX_HANDLE_SZ, resulting in
  EOVERFLOW if 128 bytes were requested, or
  EINVAL if the size reported by the previous call was requested.

To fix this, increase MAX_HANDLE_SIZE a little, and add a BUILD_BUG
so that this sort of inconsistent error reporting won't happen again.

Link: https://github.com/systemd/systemd/issues/7082#issuecomment-347380436
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/export.c          |    2 ++
 include/linux/exportfs.h |   10 ++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 83fd09fc8f77..23b2fc3ab2bb 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -39,6 +39,8 @@ nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len, struct inode *parent)
 	size_t fh_size = offsetof(struct nfs_fh, data) + server_fh->size;
 	int len = EMBED_FH_OFF + XDR_QUADLEN(fh_size);
 
+	BUILD_BUG_ON_MSG(EMBED_FH_OFF + NFS_MAXFHSIZE > MAX_HANDLE_SZ,
+		"MAX_HANDLE_SZ is too small");
 	dprintk("%s: max fh len %d inode %p parent %p",
 		__func__, *max_len, inode, parent);
 
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 0d3037419bc7..71eb9c2cc2fb 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -11,8 +11,14 @@ struct iomap;
 struct super_block;
 struct vfsmount;
 
-/* limit the handle size to NFSv4 handle size now */
-#define MAX_HANDLE_SZ 128
+/* Must be larger than NFSv4 file handle.
+ * overlayfs doesn't want this too close to 255.
+ * NOTE: This value MUST NOT be exported to user-space.
+ * Applications must only ever see MAX_HANDLE_SZ == 128.
+ * If they try a larger number on older kernels, they
+ * will get -EINVAL which will be confusing.
+ */
+#define MAX_HANDLE_SZ 200
 
 /*
  * The fileid_type identifies how the file within the filesystem is encoded.


