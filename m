Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.218
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101105;
	b=j270lKziEMeMw9TG7wluvJ7x05dUXbzQR6ohr0zV/xiSO2cQN3jdySjiuSUWdWKBMbhJ
	 yyxXEe2dTXEHp5xJ6FzAy+tPQziZL+4bz1qR2djVtRy64tfGpA9xspG8cdwusj0L/0Xx0
	 3za9Du2H7ugxCiezvtLcWQ1rx2rFUbeiDW+zwHIvgT1FcD/pwB3QPj4CDv8A63dX6irDm
	 JdzWCrnVYaTmQp5NMzAi45ddF4DNquaxEvt2byU1IihOkAaQgR0atOTDvvV8794uR19L4
	 pcVOpAh97wXVsM6/KnTyRo9U4TUOltc6lQhNTo8U9oRSvJbNOa3TPQys7bNi1XrIRFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101105;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=E5utlAjvaUIBII7HrWKaBnE34AeLqYM1weyI1eopKOQ=;
	b=YheVtaG7cdj/ANWvHzSJnKFVmGqZO4F2sY1jzyzDAFbSVpdPBEOO83tyb86PPgtXJe9s
	 tTgPN1nfTQKG2lYbGJH3awH/iVWSEaZ2TK2l0G8jAumQaaDjWo010wH2FltCBvTIYXfo+
	 1C+R4AGO0Y4mZ6eotl/9PqHVv5cXtowfRPCM5dEgbeImXqGGU3UkYkXyH40gjUP/G7Mhl
	 PiJ8o4jviH5zX8Z0jg9KEXOFYj9ZkYscqvTgsVeFpwFfmnhEmpAmAl7mu1LqlLT/dQF9V
	 jP+RIU0a/Z2pWrrAAFdJzarlkbMH+/XcBBRs72RHK+64TJ0+p5iS1/jhKcs5JdrM+Ug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=awZCpeR2;
	arc=none smtp.remote-ip=113.46.200.218
Received: from canpmsgout03.his.huawei.com (canpmsgout03.his.huawei.com [113.46.200.218])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4E5960A2612;
	Tue, 27 Oct 2026 11:38:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D4E5960A2612
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=awZCpeR2
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=E5utlAjvaUIBII7HrWKaBnE34AeLqYM1weyI1eopKOQ=;
	b=awZCpeR2ZUTL+KDgNqpxKgMoL9bVyKYsOmR9ZWr+RxRDG61p5jmtNFaVPfkDQkKpaEeY3G4rK
	akF6GeseEYhiQyXo9DMs6I/6Zn6+hwWrNtPmxZpyCbptxjJSEeFhC96Ga2fzQrCm3kp5H5iIAq3
	Mfr/XNuRlg/bW7Tfct3FwaI=
Received: from mail.maildlp.com (unknown [172.19.162.140])
	by canpmsgout03.his.huawei.com (SkyGuard) with ESMTPS id 4jDT5G4rnQzpSt7;
	Tue, 27 Oct 2026 19:38:10 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 86322202E6;
	Tue, 27 Oct 2026 19:38:21 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:16 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>, <utilityemal77@gmail.com>,
	<caixinchen1@huawei.com>
CC: <ast@kernel.org>, <daniel@iogearbox.net>, <andrii@kernel.org>,
	<eddyz87@gmail.com>, <memxor@gmail.com>, <martin.lau@linux.dev>,
	<song@kernel.org>, <yonghong.song@linux.dev>, <jolsa@kernel.org>,
	<emil@etsalapatis.com>, <ihor.solodrai@linux.dev>, <rdunlap@infradead.org>,
	<gregkh@linuxfoundation.org>, <rafael@kernel.org>, <dakr@kernel.org>,
	<johan@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>, <axboe@kernel.dk>,
	<viro@zeniv.linux.org.uk>, <brauner@kernel.org>, <jack@suse.cz>,
	<dhowells@redhat.com>, <code@tyhicks.com>, <linkinjeon@kernel.org>,
	<sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <hyc.lee@gmail.com>, <miklos@szeredi.hu>,
	<amir73il@gmail.com>, <senozhatsky@chromium.org>,
	<chenxiaosong@chenxiaosong.com>, <dsterba@suse.com>, <mason@kernel.org>,
	<kpsingh@kernel.org>, <matt@bobrowski.net>, <rostedt@goodmis.org>,
	<mhiramat@kernel.org>, <mathieu.desnoyers@efficios.com>,
	<john.johansen@canonical.com>, <georgia.garcia@canonical.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@I-love.SAKURA.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<netfs@lists.linux.dev>, <ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
Subject: [PATCH v3 -next 04/18] fs: pass struct path to POSIX ACL helpers
Date: Tue, 27 Oct 2026 20:11:37 +0800
Message-ID: <20261027121151.1887650-5-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
In-Reply-To: <20261027121151.1887650-1-caixinchen1@huawei.com>
References: <20261027121151.1887650-1-caixinchen1@huawei.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems500002.china.huawei.com (7.221.188.17) To
 whupemk100010.china.huawei.com (7.152.184.41)

vfs_set_acl(), vfs_get_acl() and vfs_remove_acl() together with the
do_set_acl()/do_get_acl() syscall helpers take a struct dentry even
though their callers either already hold a struct path (or a struct
file).  Switch them all to take a struct path instead of the dentry.

The struct mnt_idmap stays a separate argument, now consistently in
first position: it is taken from the mount at the time the path is
checked and must be passed down unchanged so that the VFS and the
filesystem are guaranteed to see the same idmap, so it cannot be
derived from the path inside the helpers.  A stacking filesystem may
need to decouple the idmap from the path it forwards to the lower
filesystem: ecryptfs_set_acl() is invoked with ACLs that have already
been translated into global filesystem ids, so it must keep passing
&nop_mnt_idmap just like it does for the other vfs_* helpers it
calls, while ecryptfs_get_acl() threads the idmap of the upper mount
through to the lower filesystem.

set_posix_acl() keeps taking the idmap and dentry as it is called
from inode_operations->set_acl, which operates on a bare dentry.

The security_inode_*_acl() hooks invoked from fs/posix_acl.c keep
taking the idmap and dentry for now; they will be converted together
with the LSM hooks themselves in separate patches.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/ecryptfs/inode.c       | 11 ++++++-----
 fs/internal.h             | 11 ++++++-----
 fs/overlayfs/inode.c      |  5 +++--
 fs/overlayfs/overlayfs.h  | 14 ++++++++++++--
 fs/posix_acl.c            | 32 ++++++++++++++++++--------------
 fs/smb/server/vfs.c       |  2 +-
 fs/xattr.c                |  9 ++++-----
 include/linux/posix_acl.h | 14 ++++++++------
 8 files changed, 58 insertions(+), 40 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index c1be27e1f7eb..7db6fa6e5274 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1095,8 +1095,9 @@ static int ecryptfs_fileattr_set(const struct mnt_idmap *idmap,
 static struct posix_acl *ecryptfs_get_acl(const struct mnt_idmap *idmap,
 					  struct dentry *dentry, int type)
 {
-	return vfs_get_acl(idmap, ecryptfs_dentry_to_lower(dentry),
-			   posix_acl_xattr_name(type));
+	struct path lower_path = ecryptfs_lower_path(dentry);
+
+	return vfs_get_acl(idmap, &lower_path, posix_acl_xattr_name(type));
 }
 
 static int ecryptfs_set_acl(const struct mnt_idmap *idmap,
@@ -1104,10 +1105,10 @@ static int ecryptfs_set_acl(const struct mnt_idmap *idmap,
 			    int type)
 {
 	int rc;
-	struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
-	struct inode *lower_inode = d_inode(lower_dentry);
+	struct path lower_path = ecryptfs_lower_path(dentry);
+	struct inode *lower_inode = d_inode(lower_path.dentry);
 
-	rc = vfs_set_acl(&nop_mnt_idmap, lower_dentry,
+	rc = vfs_set_acl(&nop_mnt_idmap, &lower_path,
 			 posix_acl_xattr_name(type), acl);
 	if (!rc)
 		fsstack_copy_attr_all(d_inode(dentry), lower_inode);
diff --git a/fs/internal.h b/fs/internal.h
index e833c7e6e14f..dcbc54f9803c 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -304,20 +304,21 @@ int import_xattr_name(struct xattr_name *kname, const char __user *name);
 int may_write_xattr(const struct mnt_idmap *idmap, struct inode *inode);
 
 #ifdef CONFIG_FS_POSIX_ACL
-int do_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+int do_set_acl(const struct mnt_idmap *idmap, const struct path *path,
 	       const char *acl_name, const void *kvalue, size_t size);
-ssize_t do_get_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+ssize_t do_get_acl(const struct mnt_idmap *idmap, const struct path *path,
 		   const char *acl_name, void *kvalue, size_t size);
 #else
 static inline int do_set_acl(const struct mnt_idmap *idmap,
-			     struct dentry *dentry, const char *acl_name,
+			     const struct path *path, const char *acl_name,
 			     const void *kvalue, size_t size)
 {
 	return -EOPNOTSUPP;
 }
 static inline ssize_t do_get_acl(const struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name,
-				 void *kvalue, size_t size)
+				 const struct path *path,
+				 const char *acl_name, void *kvalue,
+				 size_t size)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index 63906b3dafcb..c50c9899ab09 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -414,7 +414,7 @@ struct posix_acl *ovl_get_acl_path(const struct path *path,
 	if (noperm)
 		real_acl = get_inode_acl(realinode, posix_acl_type(acl_name));
 	else
-		real_acl = vfs_get_acl(idmap, path->dentry, acl_name);
+		real_acl = vfs_get_acl(idmap, path, acl_name);
 	if (IS_ERR_OR_NULL(real_acl))
 		return real_acl;
 
@@ -502,7 +502,8 @@ static int ovl_set_or_remove_acl(struct dentry *dentry, struct inode *inode,
 
 		ovl_path_lower(dentry, &realpath);
 		with_ovl_creds(dentry->d_sb)
-			real_acl = vfs_get_acl(mnt_idmap(realpath.mnt), realdentry, acl_name);
+			real_acl = vfs_get_acl(mnt_idmap(realpath.mnt),
+					       &realpath, acl_name);
 		if (IS_ERR(real_acl)) {
 			err = PTR_ERR(real_acl);
 			goto out;
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index bf3fa54ee27a..fc5e7accc1f0 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -371,13 +371,23 @@ static inline int ovl_removexattr(struct ovl_fs *ofs, struct dentry *dentry,
 static inline int ovl_do_set_acl(struct ovl_fs *ofs, struct dentry *dentry,
 				 const char *acl_name, struct posix_acl *acl)
 {
-	return vfs_set_acl(ovl_upper_mnt_idmap(ofs), dentry, acl_name, acl);
+	struct path path = {
+		.mnt = ovl_upper_mnt(ofs),
+		.dentry = dentry,
+	};
+
+	return vfs_set_acl(ovl_upper_mnt_idmap(ofs), &path, acl_name, acl);
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
+	return vfs_remove_acl(ovl_upper_mnt_idmap(ofs), &path, acl_name);
 }
 
 static inline int ovl_do_rename_rd(struct renamedata *rd)
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index fe77934ea8f2..1dbc59f50932 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -1081,8 +1081,8 @@ static int vfs_set_acl_idmapped_mnt(const struct mnt_idmap *idmap,
 
 /**
  * vfs_set_acl - set posix acls
- * @idmap: idmap of the mount
- * @dentry: the dentry based on which to set the posix acls
+ * @idmap: idmap of the mount the posix acls are set through
+ * @path: the path based on which to set the posix acls
  * @acl_name: the name of the posix acl
  * @kacl: the posix acls in the appropriate VFS format
  *
@@ -1091,9 +1091,10 @@ static int vfs_set_acl_idmapped_mnt(const struct mnt_idmap *idmap,
  *
  * Return: On success 0, on error negative errno.
  */
-int vfs_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+int vfs_set_acl(const struct mnt_idmap *idmap, const struct path *path,
 		const char *acl_name, struct posix_acl *kacl)
 {
+	struct dentry *dentry = path->dentry;
 	int acl_type;
 	int error;
 	struct inode *inode = d_inode(dentry);
@@ -1159,8 +1160,8 @@ EXPORT_SYMBOL_GPL(vfs_set_acl);
 
 /**
  * vfs_get_acl - get posix acls
- * @idmap: idmap of the mount
- * @dentry: the dentry based on which to retrieve the posix acls
+ * @idmap: idmap of the mount the posix acls are retrieved through
+ * @path: the path based on which to retrieve the posix acls
  * @acl_name: the name of the posix acl
  *
  * This function retrieves @kacl from the filesystem. The caller must all
@@ -1169,8 +1170,10 @@ EXPORT_SYMBOL_GPL(vfs_set_acl);
  * Return: On success POSIX ACLs in VFS format, on error negative errno.
  */
 struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name)
+			      const struct path *path,
+			      const char *acl_name)
 {
+	struct dentry *dentry = path->dentry;
 	struct inode *inode = d_inode(dentry);
 	struct posix_acl *acl;
 	int acl_type, error;
@@ -1204,17 +1207,18 @@ EXPORT_SYMBOL_GPL(vfs_get_acl);
 
 /**
  * vfs_remove_acl - remove posix acls
- * @idmap: idmap of the mount
- * @dentry: the dentry based on which to retrieve the posix acls
+ * @idmap: idmap of the mount the posix acls are removed through
+ * @path: the path based on which to retrieve the posix acls
  * @acl_name: the name of the posix acl
  *
  * This function removes posix acls.
  *
  * Return: On success 0, on error negative errno.
  */
-int vfs_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+int vfs_remove_acl(const struct mnt_idmap *idmap, const struct path *path,
 		   const char *acl_name)
 {
+	struct dentry *dentry = path->dentry;
 	int acl_type;
 	int error;
 	struct inode *inode = d_inode(dentry);
@@ -1265,7 +1269,7 @@ int vfs_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
 }
 EXPORT_SYMBOL_GPL(vfs_remove_acl);
 
-int do_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+int do_set_acl(const struct mnt_idmap *idmap, const struct path *path,
 	       const char *acl_name, const void *kvalue, size_t size)
 {
 	int error;
@@ -1281,22 +1285,22 @@ int do_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
 			return PTR_ERR(acl);
 	}
 
-	error = vfs_set_acl(idmap, dentry, acl_name, acl);
+	error = vfs_set_acl(idmap, path, acl_name, acl);
 	posix_acl_release(acl);
 	return error;
 }
 
-ssize_t do_get_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+ssize_t do_get_acl(const struct mnt_idmap *idmap, const struct path *path,
 		   const char *acl_name, void *kvalue, size_t size)
 {
 	ssize_t error;
 	struct posix_acl *acl;
 
-	acl = vfs_get_acl(idmap, dentry, acl_name);
+	acl = vfs_get_acl(idmap, path, acl_name);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 
-	error = vfs_posix_acl_to_xattr(idmap, d_inode(dentry),
+	error = vfs_posix_acl_to_xattr(idmap, d_inode(path->dentry),
 				       acl, kvalue, size);
 	posix_acl_release(acl);
 	return error;
diff --git a/fs/smb/server/vfs.c b/fs/smb/server/vfs.c
index 96aca3e659e9..63af977d8767 100644
--- a/fs/smb/server/vfs.c
+++ b/fs/smb/server/vfs.c
@@ -1564,7 +1564,7 @@ int ksmbd_vfs_remove_acl_xattrs(const struct mnt_idmap *idmap,
 			     sizeof(XATTR_NAME_POSIX_ACL_ACCESS) - 1) ||
 		    !strncmp(name, XATTR_NAME_POSIX_ACL_DEFAULT,
 			     sizeof(XATTR_NAME_POSIX_ACL_DEFAULT) - 1)) {
-			err = vfs_remove_acl(idmap, path->dentry, name);
+			err = vfs_remove_acl(idmap, path, name);
 			if (err)
 				ksmbd_debug(SMB,
 					    "remove acl xattr failed : %s\n", name);
diff --git a/fs/xattr.c b/fs/xattr.c
index 6234ca550982..ad0d0cc1cca8 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -661,8 +661,8 @@ static int do_setxattr(const struct mnt_idmap *idmap, const struct path *path,
 		       struct kernel_xattr_ctx *ctx)
 {
 	if (is_posix_acl_xattr(ctx->kname->name))
-		return do_set_acl(idmap, path->dentry,
-				  ctx->kname->name, ctx->kvalue, ctx->size);
+		return do_set_acl(idmap, path, ctx->kname->name,
+				  ctx->kvalue, ctx->size);
 
 	return vfs_setxattr(idmap, path, ctx->kname->name,
 			ctx->kvalue, ctx->size, ctx->flags);
@@ -808,8 +808,7 @@ do_getxattr(const struct mnt_idmap *idmap, const struct path *path,
 	}
 
 	if (is_posix_acl_xattr(kname))
-		error = do_get_acl(idmap, path->dentry,
-				   kname, kvalue, ctx->size);
+		error = do_get_acl(idmap, path, kname, kvalue, ctx->size);
 	else
 		error = vfs_getxattr(idmap, path, kname, kvalue, ctx->size);
 	if (error > 0) {
@@ -1039,7 +1038,7 @@ removexattr(const struct mnt_idmap *idmap, const struct path *path,
 	    const char *name)
 {
 	if (is_posix_acl_xattr(name))
-		return vfs_remove_acl(idmap, path->dentry, name);
+		return vfs_remove_acl(idmap, path, name);
 	return vfs_removexattr(idmap, path, name);
 }
 
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index caf500bed993..4bd2ed8378c9 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -105,11 +105,12 @@ static inline void cache_no_acl(struct inode *inode)
 	inode->i_default_acl = NULL;
 }
 
-int vfs_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+int vfs_set_acl(const struct mnt_idmap *idmap, const struct path *path,
 		const char *acl_name, struct posix_acl *kacl);
 struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name);
-int vfs_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
+			      const struct path *path,
+			      const char *acl_name);
+int vfs_remove_acl(const struct mnt_idmap *idmap, const struct path *path,
 		   const char *acl_name);
 int posix_acl_listxattr(struct inode *inode, char **buffer,
 			ssize_t *remaining_size);
@@ -142,21 +143,22 @@ static inline void forget_all_cached_acls(struct inode *inode)
 }
 
 static inline int vfs_set_acl(const struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *name,
+			      const struct path *path, const char *name,
 			      struct posix_acl *acl)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
-					    struct dentry *dentry,
+					    const struct path *path,
 					    const char *acl_name)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
 static inline int vfs_remove_acl(const struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name)
+				 const struct path *path,
+				 const char *acl_name)
 {
 	return -EOPNOTSUPP;
 }
-- 
2.18.0.huawei.25

