Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:35460 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910AbbC0Qv6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:51:58 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 14/39] vfs: Cache base_acl objects in inodes
Date: Fri, 27 Mar 2015 17:50:12 +0100
Message-Id: <b38dbab4015c9581560aee8b8c25efc0a44b5670.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

POSIX ACLs and richacls are both objects allocated by kmalloc() with a
reference count which are freed by kfree_rcu().  An inode can either cache an
access and a default POSIX ACL, or a richacl.  (Richacls do not have default
acls).  To allow an inode to cache either of the two kinds of acls, introduce a
new base_acl type and convert i_acl and i_default_acl to that type. In most
cases, the vfs then doesn't have to care which kind of acl an inode caches (if
any).

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |  2 +-
 fs/f2fs/acl.c                                   |  4 ++--
 fs/inode.c                                      |  4 ++--
 fs/posix_acl.c                                  | 18 +++++++++---------
 include/linux/fs.h                              | 22 +++++++++++++++++++---
 include/linux/posix_acl.h                       |  9 ++++-----
 include/linux/richacl.h                         |  2 +-
 7 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 0c1b583..c8cae33 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1145,7 +1145,7 @@ void ll_clear_inode(struct inode *inode)
 	}
 #ifdef CONFIG_FS_POSIX_ACL
 	else if (lli->lli_posix_acl) {
-		LASSERT(atomic_read(&lli->lli_posix_acl->a_refcount) == 1);
+		LASSERT(atomic_read(&lli->lli_posix_acl->a_base.ba_refcount) == 1);
 		LASSERT(lli->lli_remote_perms == NULL);
 		posix_acl_release(lli->lli_posix_acl);
 		lli->lli_posix_acl = NULL;
diff --git a/fs/f2fs/acl.c b/fs/f2fs/acl.c
index 7422027..ccb2c7c 100644
--- a/fs/f2fs/acl.c
+++ b/fs/f2fs/acl.c
@@ -270,7 +270,7 @@ static struct posix_acl *f2fs_acl_clone(const struct posix_acl *acl,
 				sizeof(struct posix_acl_entry);
 		clone = kmemdup(acl, size, flags);
 		if (clone)
-			atomic_set(&clone->a_refcount, 1);
+			atomic_set(&clone->a_base.ba_refcount, 1);
 	}
 	return clone;
 }
@@ -282,7 +282,7 @@ static int f2fs_acl_create_masq(struct posix_acl *acl, umode_t *mode_p)
 	umode_t mode = *mode_p;
 	int not_equiv = 0;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
 		switch(pa->e_tag) {
diff --git a/fs/inode.c b/fs/inode.c
index f00b16f..555fe9c 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -233,9 +233,9 @@ void __destroy_inode(struct inode *inode)
 
 #ifdef CONFIG_FS_POSIX_ACL
 	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
-		posix_acl_release(inode->i_acl);
+		put_base_acl(inode->i_acl);
 	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
-		posix_acl_release(inode->i_default_acl);
+		put_base_acl(inode->i_default_acl);
 #endif
 	this_cpu_dec(nr_inodes);
 }
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index efe983e..2fbfec8 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -25,9 +25,9 @@ struct posix_acl **acl_by_type(struct inode *inode, int type)
 {
 	switch (type) {
 	case ACL_TYPE_ACCESS:
-		return &inode->i_acl;
+		return (struct posix_acl **)&inode->i_acl;
 	case ACL_TYPE_DEFAULT:
-		return &inode->i_default_acl;
+		return (struct posix_acl **)&inode->i_default_acl;
 	default:
 		BUG();
 	}
@@ -83,16 +83,16 @@ EXPORT_SYMBOL(forget_cached_acl);
 
 void forget_all_cached_acls(struct inode *inode)
 {
-	struct posix_acl *old_access, *old_default;
+	struct base_acl *old_access, *old_default;
 	spin_lock(&inode->i_lock);
 	old_access = inode->i_acl;
 	old_default = inode->i_default_acl;
 	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
 	spin_unlock(&inode->i_lock);
 	if (old_access != ACL_NOT_CACHED)
-		posix_acl_release(old_access);
+		put_base_acl(old_access);
 	if (old_default != ACL_NOT_CACHED)
-		posix_acl_release(old_default);
+		put_base_acl(old_default);
 }
 EXPORT_SYMBOL(forget_all_cached_acls);
 
@@ -129,7 +129,7 @@ EXPORT_SYMBOL(get_acl);
 void
 posix_acl_init(struct posix_acl *acl, int count)
 {
-	atomic_set(&acl->a_refcount, 1);
+	atomic_set(&acl->a_base.ba_refcount, 1);
 	acl->a_count = count;
 }
 EXPORT_SYMBOL(posix_acl_init);
@@ -163,7 +163,7 @@ posix_acl_clone(const struct posix_acl *acl, gfp_t flags)
 		           sizeof(struct posix_acl_entry);
 		clone = kmemdup(acl, size, flags);
 		if (clone)
-			atomic_set(&clone->a_refcount, 1);
+			atomic_set(&clone->a_base.ba_refcount, 1);
 	}
 	return clone;
 }
@@ -385,7 +385,7 @@ static int posix_acl_create_masq(struct posix_acl *acl, umode_t *mode_p)
 	umode_t mode = *mode_p;
 	int not_equiv = 0;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
                 switch(pa->e_tag) {
@@ -440,7 +440,7 @@ static int __posix_acl_chmod_masq(struct posix_acl *acl, umode_t mode)
 	struct posix_acl_entry *group_obj = NULL, *mask_obj = NULL;
 	struct posix_acl_entry *pa, *pe;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
 		switch(pa->e_tag) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e3e1e42..518b990 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -547,6 +547,9 @@ static inline void mapping_allow_writable(struct address_space *mapping)
 #define i_size_ordered_init(inode) do { } while (0)
 #endif
 
+struct base_acl {
+	atomic_t ba_refcount;
+};
 struct posix_acl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
@@ -566,9 +569,9 @@ struct inode {
 	kgid_t			i_gid;
 	unsigned int		i_flags;
 
-#ifdef CONFIG_FS_POSIX_ACL
-	struct posix_acl	*i_acl;
-	struct posix_acl	*i_default_acl;
+#if defined(CONFIG_FS_POSIX_ACL)
+	struct base_acl *i_acl;
+	struct base_acl *i_default_acl;
 #endif
 
 	const struct inode_operations	*i_op;
@@ -2936,4 +2939,17 @@ static inline bool dir_relax(struct inode *inode)
 	return !IS_DEADDIR(inode);
 }
 
+static inline struct base_acl *get_base_acl(struct base_acl *acl)
+{
+	if (acl)
+		atomic_inc(&acl->ba_refcount);
+	return acl;
+}
+
+static inline void put_base_acl(struct base_acl *acl)
+{
+	if (acl && atomic_dec_and_test(&acl->ba_refcount))
+		__kfree_rcu((struct rcu_head *)acl, 0);
+}
+
 #endif /* _LINUX_FS_H */
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 66cf477..2c46441 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -43,7 +43,7 @@ struct posix_acl_entry {
 };
 
 struct posix_acl {
-	atomic_t		a_refcount;
+	struct base_acl		a_base;
 	unsigned int		a_count;
 	struct posix_acl_entry	a_entries[0];
 };
@@ -58,8 +58,7 @@ struct posix_acl {
 static inline struct posix_acl *
 posix_acl_dup(struct posix_acl *acl)
 {
-	if (acl)
-		atomic_inc(&acl->a_refcount);
+	get_base_acl(&acl->a_base);
 	return acl;
 }
 
@@ -69,8 +68,8 @@ posix_acl_dup(struct posix_acl *acl)
 static inline void
 posix_acl_release(struct posix_acl *acl)
 {
-	if (acl && atomic_dec_and_test(&acl->a_refcount))
-		__kfree_rcu((struct rcu_head *)acl, 0);
+	BUILD_BUG_ON(offsetof(struct posix_acl, a_base) != 0);
+	put_base_acl(&acl->a_base);
 }
 
 
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 997b885..0611160 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -168,7 +168,7 @@ static inline struct richacl *
 richacl_get(struct richacl *acl)
 {
 	if (acl)
-		atomic_inc(&acl->a_refcount);
+		atomic_inc(&acl->a_base.ba_refcount);
 	return acl;
 }
 
-- 
2.1.0

