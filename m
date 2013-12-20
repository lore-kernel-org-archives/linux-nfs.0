Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54505 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826Ab3LTNZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Dec 2013 08:25:24 -0500
Message-Id: <20131220132521.505028482@bombadil.infradead.org>
Date: Fri, 20 Dec 2013 05:16:38 -0800
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
Subject: [PATCH 03/21] fs: add get_acl helper
References: <20131220131635.650823732@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Factor out the code to get an ACL either from the inode or disk from
check_acl, so that it can be used elsewhere later on.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/namei.c                |   24 +++---------------------
 fs/posix_acl.c            |   26 ++++++++++++++++++++++++++
 include/linux/posix_acl.h |    2 ++
 3 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 3531dee..bcb838e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -235,27 +235,9 @@ static int check_acl(struct inode *inode, int mask)
 	        return posix_acl_permission(inode, acl, mask & ~MAY_NOT_BLOCK);
 	}
 
-	acl = get_cached_acl(inode, ACL_TYPE_ACCESS);
-
-	/*
-	 * A filesystem can force a ACL callback by just never filling the
-	 * ACL cache. But normally you'd fill the cache either at inode
-	 * instantiation time, or on the first ->get_acl call.
-	 *
-	 * If the filesystem doesn't have a get_acl() function at all, we'll
-	 * just create the negative cache entry.
-	 */
-	if (acl == ACL_NOT_CACHED) {
-	        if (inode->i_op->get_acl) {
-			acl = inode->i_op->get_acl(inode, ACL_TYPE_ACCESS);
-			if (IS_ERR(acl))
-				return PTR_ERR(acl);
-		} else {
-		        set_cached_acl(inode, ACL_TYPE_ACCESS, NULL);
-		        return -EAGAIN;
-		}
-	}
-
+	acl = get_acl(inode, ACL_TYPE_ACCESS);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
 	if (acl) {
 	        int error = posix_acl_permission(inode, acl, mask);
 	        posix_acl_release(acl);
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 359d70b..e329c21 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -26,6 +26,32 @@ EXPORT_SYMBOL(posix_acl_valid);
 EXPORT_SYMBOL(posix_acl_equiv_mode);
 EXPORT_SYMBOL(posix_acl_from_mode);
 
+struct posix_acl *get_acl(struct inode *inode, int type)
+{
+	struct posix_acl *acl;
+
+	acl = get_cached_acl(inode, type);
+	if (acl != ACL_NOT_CACHED)
+		return acl;
+
+	if (!IS_POSIXACL(inode))
+		return NULL;
+
+	/*
+	 * A filesystem can force a ACL callback by just never filling the
+	 * ACL cache. But normally you'd fill the cache either at inode
+	 * instantiation time, or on the first ->get_acl call.
+	 *
+	 * If the filesystem doesn't have a get_acl() function at all, we'll
+	 * just create the negative cache entry.
+	 */
+	if (!inode->i_op->get_acl) {
+		set_cached_acl(inode, type, NULL);
+		return NULL;
+	}
+	return inode->i_op->get_acl(inode, type);
+}
+
 /*
  * Init a fresh posix_acl
  */
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 7931efe..a8d9918 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -175,4 +175,6 @@ static inline void cache_no_acl(struct inode *inode)
 #endif
 }
 
+struct posix_acl *get_acl(struct inode *inode, int type);
+
 #endif  /* __LINUX_POSIX_ACL_H */
-- 
1.7.10.4


