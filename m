Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:51352 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932991Ab1JRPf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:35:29 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 22/26] vfs: Cache richacl in struct inode
Date: Tue, 18 Oct 2011 21:02:57 +0530
Message-Id: <1318951981-5508-23-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Cache richacls in struct inode so that this doesn't have to be done
individually in each filesystem.

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/inode.c              |   25 +++++++++++++++++----
 include/linux/fs.h      |   12 ++++++++-
 include/linux/richacl.h |   53 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index ec79246..1b442cf 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -26,6 +26,7 @@
 #include <linux/ima.h>
 #include <linux/cred.h>
 #include <linux/buffer_head.h> /* for inode_has_buffers */
+#include <linux/richacl.h>
 #include "internal.h"
 
 /*
@@ -192,7 +193,12 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_private = NULL;
 	inode->i_mapping = mapping;
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
@@ -242,10 +248,19 @@ void __destroy_inode(struct inode *inode)
 	security_inode_free(inode);
 	fsnotify_inode_delete(inode);
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
index ac1d8e5..771955c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -755,6 +755,7 @@ static inline int mapping_writably_mapped(struct address_space *mapping)
 #endif
 
 struct posix_acl;
+struct richacl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
 #define IOP_FASTPERM	0x0001
@@ -773,10 +774,17 @@ struct inode {
 	gid_t			i_gid;
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
index 761585a..694b7dc 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -189,6 +189,59 @@ richacl_put(struct richacl *acl)
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
1.7.5.4

