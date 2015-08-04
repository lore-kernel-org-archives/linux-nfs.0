Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35542 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933600AbbHDLyy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:54:54 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 12/40] vfs: Cache richacl in struct inode
Date: Tue,  4 Aug 2015 13:53:10 +0200
Message-Id: <1438689218-6921-13-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cache richacls in struct inode so that this doesn't have to be done
individually in each filesystem.  This is similar to POSIX ACLs.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/inode.c              | 11 ++++++--
 fs/posix_acl.c          |  2 +-
 fs/richacl_base.c       |  4 +--
 fs/richacl_inode.c      | 75 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h      |  6 +++-
 include/linux/richacl.h | 15 ++++++----
 6 files changed, 101 insertions(+), 12 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 00b442d..3bcd7ee 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -176,8 +176,11 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_private = NULL;
 	inode->i_mapping = mapping;
 	INIT_HLIST_HEAD(&inode->i_dentry);	/* buggered by rcu freeing */
-#ifdef CONFIG_FS_POSIX_ACL
-	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
+#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
+	inode->i_acl = ACL_NOT_CACHED;
+# if defined(CONFIG_FS_POSIX_ACL)
+	inode->i_default_acl = ACL_NOT_CACHED;
+# endif
 #endif
 
 #ifdef CONFIG_FSNOTIFY
@@ -233,11 +236,13 @@ void __destroy_inode(struct inode *inode)
 		atomic_long_dec(&inode->i_sb->s_remove_count);
 	}
 
-#ifdef CONFIG_FS_POSIX_ACL
+#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
 	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
 		put_base_acl(inode->i_acl);
+# if defined(CONFIG_FS_POSIX_ACL)
 	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
 		put_base_acl(inode->i_default_acl);
+# endif
 #endif
 	this_cpu_dec(nr_inodes);
 }
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index b3b2265..1d766a5 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -38,7 +38,7 @@ struct posix_acl *get_cached_acl(struct inode *inode, int type)
 {
 	struct posix_acl **p = acl_by_type(inode, type);
 	struct posix_acl *acl = ACCESS_ONCE(*p);
-	if (acl) {
+	if (acl && IS_POSIXACL(inode)) {
 		spin_lock(&inode->i_lock);
 		acl = *p;
 		if (acl != ACL_NOT_CACHED)
diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index fd81158..e703f7d 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -33,7 +33,7 @@ richacl_alloc(int count, gfp_t gfp)
 	struct richacl *acl = kzalloc(size, gfp);
 
 	if (acl) {
-		atomic_set(&acl->a_refcount, 1);
+		atomic_set(&acl->a_base.ba_refcount, 1);
 		acl->a_count = count;
 	}
 	return acl;
@@ -52,7 +52,7 @@ richacl_clone(const struct richacl *acl, gfp_t gfp)
 
 	if (dup) {
 		memcpy(dup, acl, size);
-		atomic_set(&dup->a_refcount, 1);
+		atomic_set(&dup->a_base.ba_refcount, 1);
 	}
 	return dup;
 }
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
index 6d94e064..48ba7d9 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -20,6 +20,81 @@
 #include <linux/slab.h>
 #include <linux/richacl.h>
 
+struct richacl *get_cached_richacl(struct inode *inode)
+{
+	struct richacl *acl;
+
+	acl = (struct richacl *)ACCESS_ONCE(inode->i_acl);
+	if (acl && IS_RICHACL(inode)) {
+		spin_lock(&inode->i_lock);
+		acl = (struct richacl *)inode->i_acl;
+		if (acl != ACL_NOT_CACHED)
+			acl = richacl_get(acl);
+		spin_unlock(&inode->i_lock);
+	}
+	return acl;
+}
+EXPORT_SYMBOL_GPL(get_cached_richacl);
+
+struct richacl *get_cached_richacl_rcu(struct inode *inode)
+{
+	return (struct richacl *)rcu_dereference(inode->i_acl);
+}
+EXPORT_SYMBOL_GPL(get_cached_richacl_rcu);
+
+void set_cached_richacl(struct inode *inode, struct richacl *acl)
+{
+	struct base_acl *old = NULL;
+
+	spin_lock(&inode->i_lock);
+	old = inode->i_acl;
+	rcu_assign_pointer(inode->i_acl, &richacl_get(acl)->a_base);
+	spin_unlock(&inode->i_lock);
+	if (old != ACL_NOT_CACHED)
+		put_base_acl(old);
+}
+EXPORT_SYMBOL_GPL(set_cached_richacl);
+
+void forget_cached_richacl(struct inode *inode)
+{
+	struct base_acl *old = NULL;
+
+	spin_lock(&inode->i_lock);
+	old = inode->i_acl;
+	inode->i_acl = ACL_NOT_CACHED;
+	spin_unlock(&inode->i_lock);
+	if (old != ACL_NOT_CACHED)
+		put_base_acl(old);
+}
+EXPORT_SYMBOL_GPL(forget_cached_richacl);
+
+struct richacl *get_richacl(struct inode *inode)
+{
+	struct richacl *acl;
+
+	acl = get_cached_richacl(inode);
+	if (acl != ACL_NOT_CACHED)
+		return acl;
+
+	if (!IS_RICHACL(inode))
+		return NULL;
+
+	/*
+	 * A filesystem can force a ACL callback by just never filling the
+	 * ACL cache. But normally you'd fill the cache either at inode
+	 * instantiation time, or on the first ->get_richacl call.
+	 *
+	 * If the filesystem doesn't have a get_richacl() function at all,
+	 * we'll just create the negative cache entry.
+	 */
+	if (!inode->i_op->get_richacl) {
+		set_cached_richacl(inode, NULL);
+		return NULL;
+	}
+	return inode->i_op->get_richacl(inode);
+}
+EXPORT_SYMBOL_GPL(get_richacl);
+
 /**
  * richacl_permission  -  richacl permission check algorithm
  * @inode:	inode to check
diff --git a/include/linux/fs.h b/include/linux/fs.h
index cc5c2d1..00abca5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -582,6 +582,7 @@ struct base_acl {
 	};
 };
 struct posix_acl;
+struct richacl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
 #define IOP_FASTPERM	0x0001
@@ -600,9 +601,11 @@ struct inode {
 	kgid_t			i_gid;
 	unsigned int		i_flags;
 
-#if defined(CONFIG_FS_POSIX_ACL)
+#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
 	struct base_acl *i_acl;
+# if defined(CONFIG_FS_POSIX_ACL)
 	struct base_acl *i_default_acl;
+# endif
 #endif
 
 	const struct inode_operations	*i_op;
@@ -1651,6 +1654,7 @@ struct inode_operations {
 	const char * (*follow_link) (struct dentry *, void **);
 	int (*permission) (struct inode *, int);
 	struct posix_acl * (*get_acl)(struct inode *, int);
+	struct richacl * (*get_richacl)(struct inode *);
 
 	int (*readlink) (struct dentry *, char __user *,int);
 	void (*put_link) (struct inode *, void *);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 3417501..a7b413f 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -33,7 +33,7 @@ struct richace {
 };
 
 struct richacl {
-	atomic_t	a_refcount;
+	struct base_acl	a_base;
 	unsigned int	a_owner_mask;
 	unsigned int	a_group_mask;
 	unsigned int	a_other_mask;
@@ -169,8 +169,7 @@ struct richacl {
 static inline struct richacl *
 richacl_get(struct richacl *acl)
 {
-	if (acl)
-		atomic_inc(&acl->a_base.ba_refcount);
+	get_base_acl(&acl->a_base);
 	return acl;
 }
 
@@ -180,10 +179,16 @@ richacl_get(struct richacl *acl)
 static inline void
 richacl_put(struct richacl *acl)
 {
-	if (acl && atomic_dec_and_test(&acl->a_refcount))
-		kfree(acl);
+	BUILD_BUG_ON(offsetof(struct richacl, a_base) != 0);
+	put_base_acl(&acl->a_base);
 }
 
+extern struct richacl *get_cached_richacl(struct inode *);
+extern struct richacl *get_cached_richacl_rcu(struct inode *);
+extern void set_cached_richacl(struct inode *, struct richacl *);
+extern void forget_cached_richacl(struct inode *);
+extern struct richacl *get_richacl(struct inode *);
+
 /**
  * richace_is_owner  -  check if @ace is an OWNER@ entry
  */
-- 
2.5.0

