Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54502 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932822Ab3LTNZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Dec 2013 08:25:24 -0500
Message-Id: <20131220132521.164507154@bombadil.infradead.org>
Date: Fri, 20 Dec 2013 05:16:36 -0800
From: Christoph Hellwig <hch@infradead.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>,
        Jan Kara <jack@suse.cz>
Subject: [PATCH 01/21] reiserfs: prefix ACL symbols with reiserfs_
References: <20131220131635.650823732@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/reiserfs/xattr_acl.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/reiserfs/xattr_acl.c b/fs/reiserfs/xattr_acl.c
index 06c04f7..6f721ea 100644
--- a/fs/reiserfs/xattr_acl.c
+++ b/fs/reiserfs/xattr_acl.c
@@ -16,7 +16,7 @@ static int reiserfs_set_acl(struct reiserfs_transaction_handle *th,
 			    struct posix_acl *acl);
 
 static int
-posix_acl_set(struct dentry *dentry, const char *name, const void *value,
+reiserfs_posix_acl_set(struct dentry *dentry, const char *name, const void *value,
 		size_t size, int flags, int type)
 {
 	struct inode *inode = dentry->d_inode;
@@ -65,7 +65,7 @@ posix_acl_set(struct dentry *dentry, const char *name, const void *value,
 }
 
 static int
-posix_acl_get(struct dentry *dentry, const char *name, void *buffer,
+reiserfs_posix_acl_get(struct dentry *dentry, const char *name, void *buffer,
 		size_t size, int type)
 {
 	struct posix_acl *acl;
@@ -88,7 +88,7 @@ posix_acl_get(struct dentry *dentry, const char *name, void *buffer,
 /*
  * Convert from filesystem to in-memory representation.
  */
-static struct posix_acl *posix_acl_from_disk(const void *value, size_t size)
+static struct posix_acl *reiserfs_posix_acl_from_disk(const void *value, size_t size)
 {
 	const char *end = (char *)value + size;
 	int n, count;
@@ -158,7 +158,7 @@ static struct posix_acl *posix_acl_from_disk(const void *value, size_t size)
 /*
  * Convert from in-memory to filesystem representation.
  */
-static void *posix_acl_to_disk(const struct posix_acl *acl, size_t * size)
+static void *reiserfs_posix_acl_to_disk(const struct posix_acl *acl, size_t * size)
 {
 	reiserfs_acl_header *ext_acl;
 	char *e;
@@ -257,7 +257,7 @@ struct posix_acl *reiserfs_get_acl(struct inode *inode, int type)
 	} else if (retval < 0) {
 		acl = ERR_PTR(retval);
 	} else {
-		acl = posix_acl_from_disk(value, retval);
+		acl = reiserfs_posix_acl_from_disk(value, retval);
 	}
 	if (!IS_ERR(acl))
 		set_cached_acl(inode, type, acl);
@@ -307,7 +307,7 @@ reiserfs_set_acl(struct reiserfs_transaction_handle *th, struct inode *inode,
 	}
 
 	if (acl) {
-		value = posix_acl_to_disk(acl, &size);
+		value = reiserfs_posix_acl_to_disk(acl, &size);
 		if (IS_ERR(value))
 			return (int)PTR_ERR(value);
 	}
@@ -499,8 +499,8 @@ static size_t posix_acl_access_list(struct dentry *dentry, char *list,
 const struct xattr_handler reiserfs_posix_acl_access_handler = {
 	.prefix = POSIX_ACL_XATTR_ACCESS,
 	.flags = ACL_TYPE_ACCESS,
-	.get = posix_acl_get,
-	.set = posix_acl_set,
+	.get = reiserfs_posix_acl_get,
+	.set = reiserfs_posix_acl_set,
 	.list = posix_acl_access_list,
 };
 
@@ -519,7 +519,7 @@ static size_t posix_acl_default_list(struct dentry *dentry, char *list,
 const struct xattr_handler reiserfs_posix_acl_default_handler = {
 	.prefix = POSIX_ACL_XATTR_DEFAULT,
 	.flags = ACL_TYPE_DEFAULT,
-	.get = posix_acl_get,
-	.set = posix_acl_set,
+	.get = reiserfs_posix_acl_get,
+	.set = reiserfs_posix_acl_set,
 	.list = posix_acl_default_list,
 };
-- 
1.7.10.4


