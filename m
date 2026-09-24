Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0E5B46D570;
	Thu, 24 Sep 2026 10:22:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.225
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245374; cv=none; b=R4ciTNTeYdpCtPy4UB4Iawgn24fLdE+rXKpj/1vLuNHORmS5v4WHQsEVfdAsTDtLQHto6p90lovQozUKzJxVDOf01dktVKQ0nLDIOjDLbBvq5eKHnwWh/7zFiQp/ny7QVVq7uCdglvSyOqQIUxt4r1zV/lIDCHWQVqGB5yzxzig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245374; c=relaxed/simple;
	bh=DFGXEJWaaD6Y8LCZ/3X3mwZXj4qQQE/weRspuNxP4VU=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=YdZfMfu2SmURvP0DmsN3uJLFjx4rA2xEyTv1+lI9W6E0Ujom7TYpz5xFz+7dxlyOmPJnGnAawMojSnHSefjLh+zdgB7HlNr9SSTGeI75cNIIY4w4Th4OzLvlOv5DJOQFHH/UPn1bGTtPHJsKdJMNJ4rLekpDctSoA3B8IwybNds=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=gW1nrHpe; arc=none smtp.client-ip=113.46.200.225
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="gW1nrHpe"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=b0eYkrH8lAgXwtPuD9VgCirOAiEk4KJAmS03afZ5hRo=;
	b=gW1nrHpe+HHlau8VCHz/eJNHKdR2CWFxFFGdqv9bRO1VaS5z/zlVm1c7MQP0K2IQ7m1cxOdBk
	cXUxkkerJ+JmL9copgQTYCs/f3+ujTwj02gXeQ/0eOjzq69y2QZDLieds5cwo2QyLVhMVfG0her
	5S3ioKo9Q6yHQWw8Pfndeuc=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4hr8jW0s9Tz1K9WY;
	Thu, 24 Sep 2026 18:10:39 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 4297A40561;
	Thu, 24 Sep 2026 18:22:45 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:22:40 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>
CC: <rdunlap@infradead.org>, <gregkh@linuxfoundation.org>,
	<rafael@kernel.org>, <dakr@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>,
	<axboe@kernel.dk>, <viro@zeniv.linux.org.uk>, <brauner@kernel.org>,
	<jack@suse.cz>, <dhowells@redhat.com>, <code@tyhicks.com>,
	<linkinjeon@kernel.org>, <sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <miklos@szeredi.hu>, <amir73il@gmail.com>,
	<senozhatsky@chromium.org>, <chenxiaosong@chenxiaosong.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <nanx95726@gmail.com>, <djwong@kernel.org>,
	<daniel@iogearbox.net>, <linux-security-module@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <linux-unionfs@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-integrity@vger.kernel.org>,
	<selinux@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
	<xiujianfeng@huawei.com>, <caixinchen1@huawei.com>, <lujialin4@huawei.com>
Subject: [PATCH RFC -next 04/12] fs: pass struct path to POSIX ACL helpers
Date: Thu, 24 Sep 2026 18:48:23 +0800
Message-ID: <20260924104831.1081137-5-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
In-Reply-To: <20260924104831.1081137-1-caixinchen1@huawei.com>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
 whupemk100010.china.huawei.com (7.152.184.41)

vfs_set_acl(), vfs_get_acl() and vfs_remove_acl() together with the
do_set_acl()/do_get_acl() syscall helpers take a struct mnt_idmap and
a struct dentry even though their callers either already hold a
struct path or have to pass &nop_mnt_idmap because no idmapped mount
is involved.  Switch them all to take a struct path instead and
derive the idmap and dentry from it where needed.

set_posix_acl() keeps taking the idmap and dentry as it is called
from inode_operations->set_acl, which operates on a bare dentry.

The security_inode_*_acl() hooks invoked from fs/posix_acl.c keep
taking the idmap and dentry for now; they will be converted together
with the LSM hooks themselves in separate patches.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/ecryptfs/inode.c       | 12 ++++++------
 fs/internal.h             | 17 ++++++++---------
 fs/overlayfs/inode.c      |  4 ++--
 fs/overlayfs/overlayfs.h  | 14 ++++++++++++--
 fs/posix_acl.c            | 40 ++++++++++++++++++++-------------------
 fs/smb/server/vfs.c       |  3 +--
 fs/xattr.c                | 10 ++++------
 include/linux/posix_acl.h | 21 +++++++++-----------
 8 files changed, 63 insertions(+), 58 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 3307cf13b5b4..626341ef1a99 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1093,8 +1093,9 @@ static int ecryptfs_fileattr_set(struct mnt_idmap *idmap,
 static struct posix_acl *ecryptfs_get_acl(struct mnt_idmap *idmap,
 					  struct dentry *dentry, int type)
 {
-	return vfs_get_acl(idmap, ecryptfs_dentry_to_lower(dentry),
-			   posix_acl_xattr_name(type));
+	struct path lower_path = ecryptfs_lower_path(dentry);
+
+	return vfs_get_acl(&lower_path, posix_acl_xattr_name(type));
 }
 
 static int ecryptfs_set_acl(struct mnt_idmap *idmap,
@@ -1102,11 +1103,10 @@ static int ecryptfs_set_acl(struct mnt_idmap *idmap,
 			    int type)
 {
 	int rc;
-	struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
-	struct inode *lower_inode = d_inode(lower_dentry);
+	struct path lower_path = ecryptfs_lower_path(dentry);
+	struct inode *lower_inode = d_inode(lower_path.dentry);
 
-	rc = vfs_set_acl(&nop_mnt_idmap, lower_dentry,
-			 posix_acl_xattr_name(type), acl);
+	rc = vfs_set_acl(&lower_path, posix_acl_xattr_name(type), acl);
 	if (!rc)
 		fsstack_copy_attr_all(d_inode(dentry), lower_inode);
 	return rc;
diff --git a/fs/internal.h b/fs/internal.h
index 71211ef0859f..c2088345462c 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -304,20 +304,19 @@ int import_xattr_name(struct xattr_name *kname, const char __user *name);
 int may_write_xattr(struct mnt_idmap *idmap, struct inode *inode);
 
 #ifdef CONFIG_FS_POSIX_ACL
-int do_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-	       const char *acl_name, const void *kvalue, size_t size);
-ssize_t do_get_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-		   const char *acl_name, void *kvalue, size_t size);
+int do_set_acl(const struct path *path, const char *acl_name,
+	       const void *kvalue, size_t size);
+ssize_t do_get_acl(const struct path *path, const char *acl_name,
+		   void *kvalue, size_t size);
 #else
-static inline int do_set_acl(struct mnt_idmap *idmap,
-			     struct dentry *dentry, const char *acl_name,
+static inline int do_set_acl(const struct path *path, const char *acl_name,
 			     const void *kvalue, size_t size)
 {
 	return -EOPNOTSUPP;
 }
-static inline ssize_t do_get_acl(struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name,
-				 void *kvalue, size_t size)
+static inline ssize_t do_get_acl(const struct path *path,
+				 const char *acl_name, void *kvalue,
+				 size_t size)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index 401cb8c75520..f73556d17d65 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -414,7 +414,7 @@ struct posix_acl *ovl_get_acl_path(const struct path *path,
 	if (noperm)
 		real_acl = get_inode_acl(realinode, posix_acl_type(acl_name));
 	else
-		real_acl = vfs_get_acl(idmap, path->dentry, acl_name);
+		real_acl = vfs_get_acl(path, acl_name);
 	if (IS_ERR_OR_NULL(real_acl))
 		return real_acl;
 
@@ -502,7 +502,7 @@ static int ovl_set_or_remove_acl(struct dentry *dentry, struct inode *inode,
 
 		ovl_path_lower(dentry, &realpath);
 		with_ovl_creds(dentry->d_sb)
-			real_acl = vfs_get_acl(mnt_idmap(realpath.mnt), realdentry, acl_name);
+			real_acl = vfs_get_acl(&realpath, acl_name);
 		if (IS_ERR(real_acl)) {
 			err = PTR_ERR(real_acl);
 			goto out;
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index c13f6b2c915c..5df2adfea13d 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -366,13 +366,23 @@ static inline int ovl_removexattr(struct ovl_fs *ofs, struct dentry *dentry,
 static inline int ovl_do_set_acl(struct ovl_fs *ofs, struct dentry *dentry,
 				 const char *acl_name, struct posix_acl *acl)
 {
-	return vfs_set_acl(ovl_upper_mnt_idmap(ofs), dentry, acl_name, acl);
+	struct path path = {
+		.mnt = ovl_upper_mnt(ofs),
+		.dentry = dentry,
+	};
+
+	return vfs_set_acl(&path, acl_name, acl);
 }
 
 static inline int ovl_do_remove_acl(struct ovl_fs *ofs, struct dentry *dentry,
 				    const char *acl_name)
 {
-	return vfs_remove_acl(ovl_upper_mnt_idmap(ofs), dentry, acl_name);
+	struct path path = {
+		.mnt = ovl_upper_mnt(ofs),
+		.dentry = dentry,
+	};
+
+	return vfs_remove_acl(&path, acl_name);
 }
 
 static inline int ovl_do_rename_rd(struct renamedata *rd)
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 18b302f94174..be1643e18a6a 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -1081,8 +1081,7 @@ static int vfs_set_acl_idmapped_mnt(struct mnt_idmap *idmap,
 
 /**
  * vfs_set_acl - set posix acls
- * @idmap: idmap of the mount
- * @dentry: the dentry based on which to set the posix acls
+ * @path: the path based on which to set the posix acls
  * @acl_name: the name of the posix acl
  * @kacl: the posix acls in the appropriate VFS format
  *
@@ -1091,9 +1090,11 @@ static int vfs_set_acl_idmapped_mnt(struct mnt_idmap *idmap,
  *
  * Return: On success 0, on error negative errno.
  */
-int vfs_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-		const char *acl_name, struct posix_acl *kacl)
+int vfs_set_acl(const struct path *path, const char *acl_name,
+		struct posix_acl *kacl)
 {
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
+	struct dentry *dentry = path->dentry;
 	int acl_type;
 	int error;
 	struct inode *inode = d_inode(dentry);
@@ -1159,8 +1160,7 @@ EXPORT_SYMBOL_GPL(vfs_set_acl);
 
 /**
  * vfs_get_acl - get posix acls
- * @idmap: idmap of the mount
- * @dentry: the dentry based on which to retrieve the posix acls
+ * @path: the path based on which to retrieve the posix acls
  * @acl_name: the name of the posix acl
  *
  * This function retrieves @kacl from the filesystem. The caller must all
@@ -1168,9 +1168,10 @@ EXPORT_SYMBOL_GPL(vfs_set_acl);
  *
  * Return: On success POSIX ACLs in VFS format, on error negative errno.
  */
-struct posix_acl *vfs_get_acl(struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name)
+struct posix_acl *vfs_get_acl(const struct path *path, const char *acl_name)
 {
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
+	struct dentry *dentry = path->dentry;
 	struct inode *inode = d_inode(dentry);
 	struct posix_acl *acl;
 	int acl_type, error;
@@ -1204,17 +1205,17 @@ EXPORT_SYMBOL_GPL(vfs_get_acl);
 
 /**
  * vfs_remove_acl - remove posix acls
- * @idmap: idmap of the mount
- * @dentry: the dentry based on which to retrieve the posix acls
+ * @path: the path based on which to retrieve the posix acls
  * @acl_name: the name of the posix acl
  *
  * This function removes posix acls.
  *
  * Return: On success 0, on error negative errno.
  */
-int vfs_remove_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-		   const char *acl_name)
+int vfs_remove_acl(const struct path *path, const char *acl_name)
 {
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
+	struct dentry *dentry = path->dentry;
 	int acl_type;
 	int error;
 	struct inode *inode = d_inode(dentry);
@@ -1265,8 +1266,8 @@ int vfs_remove_acl(struct mnt_idmap *idmap, struct dentry *dentry,
 }
 EXPORT_SYMBOL_GPL(vfs_remove_acl);
 
-int do_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-	       const char *acl_name, const void *kvalue, size_t size)
+int do_set_acl(const struct path *path, const char *acl_name,
+	       const void *kvalue, size_t size)
 {
 	int error;
 	struct posix_acl *acl = NULL;
@@ -1281,22 +1282,23 @@ int do_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
 			return PTR_ERR(acl);
 	}
 
-	error = vfs_set_acl(idmap, dentry, acl_name, acl);
+	error = vfs_set_acl(path, acl_name, acl);
 	posix_acl_release(acl);
 	return error;
 }
 
-ssize_t do_get_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-		   const char *acl_name, void *kvalue, size_t size)
+ssize_t do_get_acl(const struct path *path, const char *acl_name,
+		   void *kvalue, size_t size)
 {
 	ssize_t error;
 	struct posix_acl *acl;
 
-	acl = vfs_get_acl(idmap, dentry, acl_name);
+	acl = vfs_get_acl(path, acl_name);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 
-	error = vfs_posix_acl_to_xattr(idmap, d_inode(dentry),
+	error = vfs_posix_acl_to_xattr(mnt_idmap(path->mnt),
+				       d_inode(path->dentry),
 				       acl, kvalue, size);
 	posix_acl_release(acl);
 	return error;
diff --git a/fs/smb/server/vfs.c b/fs/smb/server/vfs.c
index eb904cf9ef2d..97497e72fbe9 100644
--- a/fs/smb/server/vfs.c
+++ b/fs/smb/server/vfs.c
@@ -1485,8 +1485,7 @@ int ksmbd_vfs_remove_acl_xattrs(const struct path *path)
 			     sizeof(XATTR_NAME_POSIX_ACL_ACCESS) - 1) ||
 		    !strncmp(name, XATTR_NAME_POSIX_ACL_DEFAULT,
 			     sizeof(XATTR_NAME_POSIX_ACL_DEFAULT) - 1)) {
-			err = vfs_remove_acl(mnt_idmap(path->mnt),
-					     path->dentry, name);
+			err = vfs_remove_acl(path, name);
 			if (err)
 				ksmbd_debug(SMB,
 					    "remove acl xattr failed : %s\n", name);
diff --git a/fs/xattr.c b/fs/xattr.c
index 818d6652b6d9..ee4a5f6d7ef3 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -660,8 +660,8 @@ int setxattr_copy(const char __user *name, struct kernel_xattr_ctx *ctx)
 static int do_setxattr(const struct path *path, struct kernel_xattr_ctx *ctx)
 {
 	if (is_posix_acl_xattr(ctx->kname->name))
-		return do_set_acl(mnt_idmap(path->mnt), path->dentry,
-				  ctx->kname->name, ctx->kvalue, ctx->size);
+		return do_set_acl(path, ctx->kname->name,
+				  ctx->kvalue, ctx->size);
 
 	return vfs_setxattr(path, ctx->kname->name,
 			ctx->kvalue, ctx->size, ctx->flags);
@@ -806,8 +806,7 @@ do_getxattr(const struct path *path, struct kernel_xattr_ctx *ctx)
 	}
 
 	if (is_posix_acl_xattr(kname))
-		error = do_get_acl(mnt_idmap(path->mnt), path->dentry,
-				   kname, kvalue, ctx->size);
+		error = do_get_acl(path, kname, kvalue, ctx->size);
 	else
 		error = vfs_getxattr(path, kname, kvalue, ctx->size);
 	if (error > 0) {
@@ -1036,8 +1035,7 @@ static long
 removexattr(const struct path *path, const char *name)
 {
 	if (is_posix_acl_xattr(name))
-		return vfs_remove_acl(mnt_idmap(path->mnt), path->dentry,
-				      name);
+		return vfs_remove_acl(path, name);
 	return vfs_removexattr(path, name);
 }
 
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 62d497763e25..384111cb6673 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -105,12 +105,11 @@ static inline void cache_no_acl(struct inode *inode)
 	inode->i_default_acl = NULL;
 }
 
-int vfs_set_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-		const char *acl_name, struct posix_acl *kacl);
-struct posix_acl *vfs_get_acl(struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name);
-int vfs_remove_acl(struct mnt_idmap *idmap, struct dentry *dentry,
-		   const char *acl_name);
+int vfs_set_acl(const struct path *path, const char *acl_name,
+		struct posix_acl *kacl);
+struct posix_acl *vfs_get_acl(const struct path *path,
+			      const char *acl_name);
+int vfs_remove_acl(const struct path *path, const char *acl_name);
 int posix_acl_listxattr(struct inode *inode, char **buffer,
 			ssize_t *remaining_size);
 #else
@@ -141,22 +140,20 @@ static inline void forget_all_cached_acls(struct inode *inode)
 {
 }
 
-static inline int vfs_set_acl(struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *name,
+static inline int vfs_set_acl(const struct path *path, const char *name,
 			      struct posix_acl *acl)
 {
 	return -EOPNOTSUPP;
 }
 
-static inline struct posix_acl *vfs_get_acl(struct mnt_idmap *idmap,
-					    struct dentry *dentry,
+static inline struct posix_acl *vfs_get_acl(const struct path *path,
 					    const char *acl_name)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
-static inline int vfs_remove_acl(struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name)
+static inline int vfs_remove_acl(const struct path *path,
+				 const char *acl_name)
 {
 	return -EOPNOTSUPP;
 }
-- 
2.18.0.huawei.25

