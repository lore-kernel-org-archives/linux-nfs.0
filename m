Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35226 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbcFZA0i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jun 2016 20:26:38 -0400
Received: by mail-it0-f66.google.com with SMTP id g127so6551457ith.2
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jun 2016 17:26:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFS: Do not aggressively cache file attributes in the case of O_DIRECT
Date: Sat, 25 Jun 2016 20:25:50 -0400
Message-Id: <1466900754-29584-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A file that is open for O_DIRECT is not guaranteed to obey close-to-open
cache consistency semantics, so let's not cache attributes aggressively.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c    | 9 +++++++--
 fs/nfs/internal.h | 5 +++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b3404b676946..b729f7b972d3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1207,6 +1207,11 @@ static bool nfs_file_has_writers(struct nfs_inode *nfsi)
 			list)->mode & FMODE_WRITE) == FMODE_WRITE;
 }
 
+static bool nfs_file_has_buffered_writers(struct nfs_inode *nfsi)
+{
+	return nfs_file_has_writers(nfsi) && nfs_file_io_is_buffered(nfsi);
+}
+
 static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1271,7 +1276,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
 		return -EIO;
 
-	if (!nfs_file_has_writers(nfsi)) {
+	if (!nfs_file_has_buffered_writers(nfsi)) {
 		/* Verify a few of the more important attributes */
 		if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 && inode->i_version != fattr->change_attr)
 			invalid |= NFS_INO_INVALID_ATTR | NFS_INO_REVAL_PAGECACHE;
@@ -1669,7 +1674,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long invalid = 0;
 	unsigned long now = jiffies;
 	unsigned long save_cache_validity;
-	bool have_writers = nfs_file_has_writers(nfsi);
+	bool have_writers = nfs_file_has_buffered_writers(nfsi);
 	bool cache_revalidated = true;
 
 	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 159b64ede82a..01dccf18da0a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -419,6 +419,11 @@ extern void nfs_end_io_write(struct inode *inode);
 extern void nfs_start_io_direct(struct inode *inode);
 extern void nfs_end_io_direct(struct inode *inode);
 
+static inline bool nfs_file_io_is_buffered(struct nfs_inode *nfsi)
+{
+	return test_bit(NFS_INO_ODIRECT, &nfsi->flags) == 0;
+}
+
 /* namespace.c */
 #define NFS_PATH_CANONICAL 1
 extern char *nfs_path(char **p, struct dentry *dentry,
-- 
2.7.4

