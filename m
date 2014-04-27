Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:39688 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552AbaD0QQM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:16:12 -0400
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:16:10 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 19/22] vfs: Cache richacl in struct inode
Date: Sun, 27 Apr 2014 21:44:50 +0530
Message-Id: <1398615293-22931-20-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Cache richacls in struct inode so that this doesn't have to be done
individually in each filesystem.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/inode.c              | 25 ++++++++++++++++++-----
 include/linux/fs.h      | 12 +++++++++--
 include/linux/richacl.h | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index f96d2a6f88cc..b96a16d5c653 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -18,6 +18,7 @@
 #include <linux/buffer_head.h> /* for inode_has_buffers */
 #include <linux/ratelimit.h>
 #include <linux/list_lru.h>
+#include <linux/richacl.h>
 #include "internal.h"
 
 /*
@@ -185,7 +186,12 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_mapping = mapping;
 	INIT_HLIST_HEAD(&inode->i_dentry);	/* buggered by rcu freeing */
 #ifdef CONFIG_FS_POSIX_ACL
-	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
+	if (IS_POSIXACL(inode))
+		inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
+#endif
+#ifdef CONFIG_FS_RICHACL
+	if (IS_RICHACL(inode))
+		inode->i_richacl = ACL_NOT_CACHED;
 #endif
 
 #ifdef CONFIG_FSNOTIFY
@@ -240,10 +246,19 @@ void __destroy_inode(struct inode *inode)
 	}
 
 #ifdef CONFIG_FS_POSIX_ACL
-	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
-		posix_acl_release(inode->i_acl);
-	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
-		posix_acl_release(inode->i_default_acl);
+	if (IS_POSIXACL(inode)) {
+		if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
+			posix_acl_release(inode->i_acl);
+		if (inode->i_default_acl &&
+		    inode->i_default_acl != ACL_NOT_CACHED)
+			posix_acl_release(inode->i_default_acl);
+	}
+#endif
+#ifdef CONFIG_FS_RICHACL
+	if (IS_RICHACL(inode)) {
+		if (inode->i_richacl && inode->i_richacl != ACL_NOT_CACHED)
+			richacl_put(inode->i_richacl);
+	}
 #endif
 	this_cpu_dec(nr_inodes);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 22d85798b520..95df64d21e55 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -492,6 +492,7 @@ static inline int mapping_writably_mapped(struct address_space *mapping)
 #endif
 
 struct posix_acl;
+struct richacl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
 #define IOP_FASTPERM	0x0001
@@ -510,10 +511,17 @@ struct inode {
 	kgid_t			i_gid;
 	unsigned int		i_flags;
 
+	union {
 #ifdef CONFIG_FS_POSIX_ACL
-	struct posix_acl	*i_acl;
-	struct posix_acl	*i_default_acl;
+		struct {
+			struct posix_acl *i_acl;
+			struct posix_acl *i_default_acl;
+		};
 #endif
+#ifdef CONFIG_FS_RICHACL
+		struct richacl	*i_richacl;
+#endif
+	};
 
 	const struct inode_operations	*i_op;
 	struct super_block	*i_sb;
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 88f95d78b897..a7db341e4ee9 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -191,6 +191,59 @@ richacl_put(struct richacl *acl)
 		kfree(acl);
 }
 
+#ifdef CONFIG_FS_RICHACL
+static inline struct richacl *get_cached_richacl(struct inode *inode)
+{
+	struct richacl **p, *acl;
+
+	p = &inode->i_richacl;
+	acl = ACCESS_ONCE(*p);
+	if (acl) {
+		spin_lock(&inode->i_lock);
+		acl = *p;
+		if (acl != ACL_NOT_CACHED)
+			acl = richacl_get(acl);
+		spin_unlock(&inode->i_lock);
+	}
+	return acl;
+}
+
+static inline void set_cached_richacl(struct inode *inode,
+				      struct richacl *acl)
+{
+	struct richacl *old = NULL;
+	spin_lock(&inode->i_lock);
+	old = inode->i_richacl;
+	inode->i_richacl = richacl_get(acl);
+	spin_unlock(&inode->i_lock);
+	if (old != ACL_NOT_CACHED)
+		richacl_put(old);
+}
+
+static inline void forget_cached_richacl(struct inode *inode)
+{
+	struct richacl *old = NULL;
+	spin_lock(&inode->i_lock);
+	old = inode->i_richacl;
+	inode->i_richacl = ACL_NOT_CACHED;
+	spin_unlock(&inode->i_lock);
+	if (old != ACL_NOT_CACHED)
+		richacl_put(old);
+}
+
+static inline int negative_cached_richacl(struct inode *inode)
+{
+	struct richacl **p, *acl;
+
+	p = &inode->i_richacl;
+	acl = ACCESS_ONCE(*p);
+	if (acl)
+		return 0;
+	return 1;
+}
+
+#endif
+
 static inline int
 richacl_is_auto_inherit(const struct richacl *acl)
 {
-- 
1.9.1

