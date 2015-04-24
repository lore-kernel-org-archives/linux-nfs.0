Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33624 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbbDXLFO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:14 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 16/45] vfs: Cache richacl in struct inode
Date: Fri, 24 Apr 2015 13:04:13 +0200
Message-Id: <e710721f3376c23f4bfeac41cf29dc9f576b88a3.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cache richacls in struct inode so that this doesn't have to be done
individually in each filesystem.  This is similar to POSIX ACLs.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/inode.c              | 11 ++++++--
 fs/posix_acl.c          |  2 +-
 fs/richacl_base.c       |  8 ++++--
 fs/richacl_inode.c      | 73 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h      |  6 +++-
 include/linux/richacl.h | 15 ++++++----
 6 files changed, 102 insertions(+), 13 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 555fe9c..5272412 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -175,8 +175,11 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
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
@@ -231,11 +234,13 @@ void __destroy_inode(struct inode *inode)
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
index 2fbfec8..ebf96b2 100644
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
index 261ddd2..5273ccb 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -29,11 +29,13 @@ MODULE_LICENSE("GPL");
 struct richacl *
 richacl_alloc(int count, gfp_t gfp)
 {
-	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	size_t size = max(sizeof(struct rcu_head),
+		sizeof(struct richacl) +
+		count * sizeof(struct richace));
 	struct richacl *acl = kzalloc(size, gfp);
 
 	if (acl) {
-		atomic_set(&acl->a_refcount, 1);
+		atomic_set(&acl->a_base.ba_refcount, 1);
 		acl->a_count = count;
 	}
 	return acl;
@@ -52,7 +54,7 @@ richacl_clone(const struct richacl *acl, gfp_t gfp)
 
 	if (dup) {
 		memcpy(dup, acl, size);
-		atomic_set(&dup->a_refcount, 1);
+		atomic_set(&dup->a_base.ba_refcount, 1);
 	}
 	return dup;
 }
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
index 33e591a..b421f68 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -20,6 +20,79 @@
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
index 6e0da10..7584a63 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -551,6 +551,7 @@ struct base_acl {
 	atomic_t ba_refcount;
 };
 struct posix_acl;
+struct richacl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
 #define IOP_FASTPERM	0x0001
@@ -569,9 +570,11 @@ struct inode {
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
@@ -1587,6 +1590,7 @@ struct inode_operations {
 	void * (*follow_link) (struct dentry *, struct nameidata *);
 	int (*permission) (struct inode *, int);
 	struct posix_acl * (*get_acl)(struct inode *, int);
+	struct richacl * (*get_richacl)(struct inode *);
 
 	int (*readlink) (struct dentry *, char __user *,int);
 	void (*put_link) (struct dentry *, struct nameidata *, void *);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 5eb198d..6d88ee9 100644
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
@@ -167,8 +167,7 @@ struct richacl {
 static inline struct richacl *
 richacl_get(struct richacl *acl)
 {
-	if (acl)
-		atomic_inc(&acl->a_base.ba_refcount);
+	get_base_acl(&acl->a_base);
 	return acl;
 }
 
@@ -178,10 +177,16 @@ richacl_get(struct richacl *acl)
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
2.1.0

