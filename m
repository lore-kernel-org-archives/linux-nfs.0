Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33236 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932470AbcGFWbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 18:31:00 -0400
Received: by mail-it0-f65.google.com with SMTP id y93so926639ita.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 15:30:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 23/28] NFS: Do not aggressively cache file attributes in the case of O_DIRECT
Date: Wed,  6 Jul 2016 18:30:00 -0400
Message-Id: <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
References: <1467844205-76852-1-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-2-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-3-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-4-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-5-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-6-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-7-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-8-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-9-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-10-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-11-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-12-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-13-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-14-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-15-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A file that is open for O_DIRECT is by definition not obeying
close-to-open cache consistency semantics, so let's not cache
the attributes too aggressively either.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c    | 9 +++++++--
 fs/nfs/internal.h | 5 +++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0e0500f2bb6b..7688436b19ba 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1214,6 +1214,11 @@ static bool nfs_file_has_writers(struct nfs_inode *nfsi)
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
@@ -1278,7 +1283,7 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
 		return -EIO;
 
-	if (!nfs_file_has_writers(nfsi)) {
+	if (!nfs_file_has_buffered_writers(nfsi)) {
 		/* Verify a few of the more important attributes */
 		if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 && inode->i_version != fattr->change_attr)
 			invalid |= NFS_INO_INVALID_ATTR | NFS_INO_REVAL_PAGECACHE;
@@ -1660,7 +1665,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
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

