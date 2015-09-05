Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbbIEK2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Sep 2015 06:28:00 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: [RFC v7 11/41] vfs: Cache base_acl objects in inodes
Date: Sat,  5 Sep 2015 12:27:06 +0200
Message-Id: <1441448856-13478-12-git-send-email-agruenba@redhat.com>
In-Reply-To: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

POSIX ACLs and richacls are both objects allocated by kmalloc() with a
reference count which are freed by kfree_rcu().  An inode can either
cache an access and a default POSIX ACL, or a richacl (richacls do not
have default acls).  To allow an inode to cache either of the two kinds
of acls, introduce a new base_acl type and convert i_acl and
i_default_acl to that type. In most cases, the vfs then doesn't have to
care which kind of acl an inode caches (if any).

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |  2 +-
 fs/f2fs/acl.c                                   |  4 ++--
 fs/inode.c                                      |  4 ++--
 fs/jffs2/acl.c                                  |  6 ++++--
 fs/posix_acl.c                                  | 18 +++++++++---------
 include/linux/fs.h                              | 25 ++++++++++++++++++++++---
 include/linux/posix_acl.h                       | 12 ++++--------
 include/linux/richacl.h                         |  2 +-
 8 files changed, 45 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 2513988..e198f63 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1130,7 +1130,7 @@ void ll_clear_inode(struct inode *inode)
 	}
 #ifdef CONFIG_FS_POSIX_ACL
 	else if (lli->lli_posix_acl) {
-		LASSERT(atomic_read(&lli->lli_posix_acl->a_refcount) == 1);
+		LASSERT(atomic_read(&lli->lli_posix_acl->a_base.ba_refcount) == 1);
 		LASSERT(lli->lli_remote_perms == NULL);
 		posix_acl_release(lli->lli_posix_acl);
 		lli->lli_posix_acl = NULL;
diff --git a/fs/f2fs/acl.c b/fs/f2fs/acl.c
index c8f25f7..a4207de 100644
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
index d30640f..00b442d 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -235,9 +235,9 @@ void __destroy_inode(struct inode *inode)
 
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
diff --git a/fs/jffs2/acl.c b/fs/jffs2/acl.c
index 2f7a3c0..04a5836 100644
--- a/fs/jffs2/acl.c
+++ b/fs/jffs2/acl.c
@@ -294,13 +294,15 @@ int jffs2_init_acl_post(struct inode *inode)
 	int rc;
 
 	if (inode->i_default_acl) {
-		rc = __jffs2_set_acl(inode, JFFS2_XPREFIX_ACL_DEFAULT, inode->i_default_acl);
+		rc = __jffs2_set_acl(inode, JFFS2_XPREFIX_ACL_DEFAULT,
+				     *acl_by_type(inode, ACL_TYPE_DEFAULT));
 		if (rc)
 			return rc;
 	}
 
 	if (inode->i_acl) {
-		rc = __jffs2_set_acl(inode, JFFS2_XPREFIX_ACL_ACCESS, inode->i_acl);
+		rc = __jffs2_set_acl(inode, JFFS2_XPREFIX_ACL_ACCESS,
+				     *acl_by_type(inode, ACL_TYPE_ACCESS));
 		if (rc)
 			return rc;
 	}
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 4fb17de..b3b2265 100644
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
@@ -162,7 +162,7 @@ posix_acl_clone(const struct posix_acl *acl, gfp_t flags)
 		           sizeof(struct posix_acl_entry);
 		clone = kmemdup(acl, size, flags);
 		if (clone)
-			atomic_set(&clone->a_refcount, 1);
+			atomic_set(&clone->a_base.ba_refcount, 1);
 	}
 	return clone;
 }
@@ -384,7 +384,7 @@ static int posix_acl_create_masq(struct posix_acl *acl, umode_t *mode_p)
 	umode_t mode = *mode_p;
 	int not_equiv = 0;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
                 switch(pa->e_tag) {
@@ -439,7 +439,7 @@ static int __posix_acl_chmod_masq(struct posix_acl *acl, umode_t mode)
 	struct posix_acl_entry *group_obj = NULL, *mask_obj = NULL;
 	struct posix_acl_entry *pa, *pe;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
 		switch(pa->e_tag) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index add0a02..04dddfa 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -576,6 +576,12 @@ static inline void mapping_allow_writable(struct address_space *mapping)
 #define i_size_ordered_init(inode) do { } while (0)
 #endif
 
+struct base_acl {
+	union {
+		atomic_t ba_refcount;
+		struct rcu_head ba_rcu;
+	};
+};
 struct posix_acl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
@@ -595,9 +601,9 @@ struct inode {
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
@@ -3060,4 +3066,17 @@ static inline bool dir_relax(struct inode *inode)
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
+		kfree_rcu(acl, ba_rcu);
+}
+
 #endif /* _LINUX_FS_H */
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 3e96a6a..2c46441 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -43,10 +43,7 @@ struct posix_acl_entry {
 };
 
 struct posix_acl {
-	union {
-		atomic_t		a_refcount;
-		struct rcu_head		a_rcu;
-	};
+	struct base_acl		a_base;
 	unsigned int		a_count;
 	struct posix_acl_entry	a_entries[0];
 };
@@ -61,8 +58,7 @@ struct posix_acl {
 static inline struct posix_acl *
 posix_acl_dup(struct posix_acl *acl)
 {
-	if (acl)
-		atomic_inc(&acl->a_refcount);
+	get_base_acl(&acl->a_base);
 	return acl;
 }
 
@@ -72,8 +68,8 @@ posix_acl_dup(struct posix_acl *acl)
 static inline void
 posix_acl_release(struct posix_acl *acl)
 {
-	if (acl && atomic_dec_and_test(&acl->a_refcount))
-		kfree_rcu(acl, a_rcu);
+	BUILD_BUG_ON(offsetof(struct posix_acl, a_base) != 0);
+	put_base_acl(&acl->a_base);
 }
 
 
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 9768eeb..61836f1 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -176,7 +176,7 @@ static inline struct richacl *
 richacl_get(struct richacl *acl)
 {
 	if (acl)
-		atomic_inc(&acl->a_refcount);
+		atomic_inc(&acl->a_base.ba_refcount);
 	return acl;
 }
 
-- 
2.4.3

