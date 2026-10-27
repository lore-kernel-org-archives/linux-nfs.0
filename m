Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101126;
	b=egjDb9xgL/1MfA1zsbHyfLfV4+gnT4d+xuTj87bbG2g1mOoDqDZza3HBN6DdepdMea6h
	 q/lJ2tjjMW69upUidY0EUx1TI9ABVPuiBCF1x1MlGAwfOTkteWPNqi+15YKoWVNN6Y1zn
	 DPDEXy5sr9JYcrMbgJTSFReP+6wSEqjYwZSjitvMHCHe2f72KMgjRXSlnsZVhbuUIIFKU
	 YP1RM359Exsqu2IFE0JhbPa0GzN/7X1k2ydr/fIvroBjAO88NtM5BmUYxbNcd5+RG41TF
	 nkq0BZXzpObDlP/t2zM/s3D5/JgtptvX9Uv7b757k3fmcPpFQr8pnnB2Na9qyzSkqDg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101126;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=b+kWFEB0BqAmN5k/w2RsgzKjmz0g4+hcbcMVEIz4N2s=;
	b=0ch13wQBtoZs9j+bAbBJKBK0SGRGQ+tMmOVxhSxVxiupQN/gs2BL0mDEn/LzF6TAFhry
	 qO1q2gvb7hLoNIAC1YTtNNGJge2KG1Nyqo+/Nmf/ajAj9HhO9QSQAK6kcfdGFEYvqU/+i
	 K8e3aMkQwRu7m7CwaXioD6gBXyDh/cqdQm1UdRWgjmpMR2xxWdls4sJDNGGfOsGmPJx7w
	 bZBdSz9sy22MGAsCiUpxyK+mV2V46Pn1vC0ogbQ6uGDN3t/uR+pJyk5O94qtix6DQ/16b
	 yr+DocFoGVqORUrjOryqqx/wDT0FUoIENJZhAT99Qpcy6AkYfBzF/Ad0O/wmNn2ka7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=PISY696t;
	arc=none smtp.remote-ip=113.46.200.226
Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2DDFB60A3814;
	Tue, 27 Oct 2026 11:38:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2DDFB60A3814
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=PISY696t
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=b+kWFEB0BqAmN5k/w2RsgzKjmz0g4+hcbcMVEIz4N2s=;
	b=PISY696tJ5migM74CnceoCKIrRzeaxnS9SAY1CylKnSJsY5ZPEC+ADygft38fXhIFA4peFjQW
	yquz+AUgWVfKJuTpNMT3vDU53tOZCPbSZA5TGfTz7v+76llZKDGdQsrDKaP+MOw4k3yx4n6EuBK
	0bGH5tbeQpn1vGzPVCiHszk=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4jDT5c4gKqzKmZQ;
	Tue, 27 Oct 2026 19:38:28 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 0E3424055B;
	Tue, 27 Oct 2026 19:38:37 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:31 +0800
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
Subject: [PATCH v3 -next 07/18] LSM: pass struct path and struct file to the inode posix acl hooks
Date: Tue, 27 Oct 2026 20:11:40 +0800
Message-ID: <20261027121151.1887650-8-caixinchen1@huawei.com>
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

The inode_set_acl, inode_get_acl and inode_remove_acl hooks are
called from fs/posix_acl.c, whose helpers now hold a struct path and
used to derive the dentry from it just for the hook calls.

Convert the hooks and their SELinux, Smack, EVM and IMA
implementations to take a const struct path, keeping the idmap as a
separate argument.  The implementations derive the dentry they still
need from the path, so this is a purely mechanical change with no
behavior change.

Also pass the struct file through which a posix acl operation is
requested, when there is one, so that LSMs can later authorize
file descriptor-based operations (fsetxattr(2), fgetxattr(2) and
fremovexattr(2) on the system.posix_acl_access and
system.posix_acl_default names, the *xattrat(2) syscalls with
AT_EMPTY_PATH, and io_uring's IORING_OP_FSETXATTR and
IORING_OP_FGETXATTR) with the rights available at open(2) time.
The file is threaded through vfs_set_acl(), vfs_get_acl(),
vfs_remove_acl(), do_set_acl() and do_get_acl(), and set to NULL
for path-based operations and for in-kernel users: overlayfs,
ecryptfs and the SMB server.  No implementation uses the file yet,
so this part is a purely mechanical change with no behavior change
either.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/ecryptfs/inode.c                   |  5 ++--
 fs/internal.h                         | 11 +++++---
 fs/overlayfs/inode.c                  |  4 +--
 fs/overlayfs/overlayfs.h              |  6 +++--
 fs/posix_acl.c                        | 26 +++++++++++-------
 fs/smb/server/vfs.c                   |  2 +-
 fs/xattr.c                            |  7 ++---
 include/linux/lsm_hook_defs.h         |  9 ++++---
 include/linux/posix_acl.h             | 14 +++++-----
 include/linux/security.h              | 25 +++++++++++-------
 security/integrity/evm/evm_main.c     | 22 ++++++++++------
 security/integrity/ima/ima_appraise.c | 15 ++++++-----
 security/security.c                   | 32 +++++++++++++---------
 security/selinux/hooks.c              | 17 +++++++-----
 security/smack/smack_lsm.c            | 38 ++++++++++++++++-----------
 15 files changed, 140 insertions(+), 93 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 782bcca83874..fcb5b4de897e 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1097,7 +1097,8 @@ static struct posix_acl *ecryptfs_get_acl(const struct mnt_idmap *idmap,
 {
 	struct path lower_path = ecryptfs_lower_path(dentry);
 
-	return vfs_get_acl(idmap, &lower_path, posix_acl_xattr_name(type));
+	return vfs_get_acl(idmap, &lower_path, posix_acl_xattr_name(type),
+			   NULL);
 }
 
 static int ecryptfs_set_acl(const struct mnt_idmap *idmap,
@@ -1109,7 +1110,7 @@ static int ecryptfs_set_acl(const struct mnt_idmap *idmap,
 	struct inode *lower_inode = d_inode(lower_path.dentry);
 
 	rc = vfs_set_acl(&nop_mnt_idmap, &lower_path,
-			 posix_acl_xattr_name(type), acl);
+			 posix_acl_xattr_name(type), acl, NULL);
 	if (!rc)
 		fsstack_copy_attr_all(d_inode(dentry), lower_inode);
 	return rc;
diff --git a/fs/internal.h b/fs/internal.h
index e90de99de5ea..4ba895665889 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -307,20 +307,23 @@ int may_write_xattr(const struct mnt_idmap *idmap, struct inode *inode);
 
 #ifdef CONFIG_FS_POSIX_ACL
 int do_set_acl(const struct mnt_idmap *idmap, const struct path *path,
-	       const char *acl_name, const void *kvalue, size_t size);
+	       const char *acl_name, const void *kvalue, size_t size,
+	       struct file *file);
 ssize_t do_get_acl(const struct mnt_idmap *idmap, const struct path *path,
-		   const char *acl_name, void *kvalue, size_t size);
+		   const char *acl_name, void *kvalue, size_t size,
+		   struct file *file);
 #else
 static inline int do_set_acl(const struct mnt_idmap *idmap,
 			     const struct path *path, const char *acl_name,
-			     const void *kvalue, size_t size)
+			     const void *kvalue, size_t size,
+			     struct file *file)
 {
 	return -EOPNOTSUPP;
 }
 static inline ssize_t do_get_acl(const struct mnt_idmap *idmap,
 				 const struct path *path,
 				 const char *acl_name, void *kvalue,
-				 size_t size)
+				 size_t size, struct file *file)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/fs/overlayfs/inode.c b/fs/overlayfs/inode.c
index c50c9899ab09..eb408284df08 100644
--- a/fs/overlayfs/inode.c
+++ b/fs/overlayfs/inode.c
@@ -414,7 +414,7 @@ struct posix_acl *ovl_get_acl_path(const struct path *path,
 	if (noperm)
 		real_acl = get_inode_acl(realinode, posix_acl_type(acl_name));
 	else
-		real_acl = vfs_get_acl(idmap, path, acl_name);
+		real_acl = vfs_get_acl(idmap, path, acl_name, NULL);
 	if (IS_ERR_OR_NULL(real_acl))
 		return real_acl;
 
@@ -503,7 +503,7 @@ static int ovl_set_or_remove_acl(struct dentry *dentry, struct inode *inode,
 		ovl_path_lower(dentry, &realpath);
 		with_ovl_creds(dentry->d_sb)
 			real_acl = vfs_get_acl(mnt_idmap(realpath.mnt),
-					       &realpath, acl_name);
+					       &realpath, acl_name, NULL);
 		if (IS_ERR(real_acl)) {
 			err = PTR_ERR(real_acl);
 			goto out;
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index 9ffa985fe8f2..9e969ab6ec40 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -378,7 +378,8 @@ static inline int ovl_do_set_acl(struct ovl_fs *ofs, struct dentry *dentry,
 		.dentry = dentry,
 	};
 
-	return vfs_set_acl(ovl_upper_mnt_idmap(ofs), &path, acl_name, acl);
+	return vfs_set_acl(ovl_upper_mnt_idmap(ofs), &path, acl_name, acl,
+		   NULL);
 }
 
 static inline int ovl_do_remove_acl(struct ovl_fs *ofs, struct dentry *dentry,
@@ -389,7 +390,8 @@ static inline int ovl_do_remove_acl(struct ovl_fs *ofs, struct dentry *dentry,
 		.dentry = dentry,
 	};
 
-	return vfs_remove_acl(ovl_upper_mnt_idmap(ofs), &path, acl_name);
+	return vfs_remove_acl(ovl_upper_mnt_idmap(ofs), &path, acl_name,
+			 NULL);
 }
 
 static inline int ovl_do_rename_rd(struct renamedata *rd)
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 1dbc59f50932..487e17e91e2b 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -1085,6 +1085,7 @@ static int vfs_set_acl_idmapped_mnt(const struct mnt_idmap *idmap,
  * @path: the path based on which to set the posix acls
  * @acl_name: the name of the posix acl
  * @kacl: the posix acls in the appropriate VFS format
+ * @file: file through which the posix acls are set, or NULL
  *
  * This function sets @kacl. The caller must all posix_acl_release() on @kacl
  * afterwards.
@@ -1092,7 +1093,8 @@ static int vfs_set_acl_idmapped_mnt(const struct mnt_idmap *idmap,
  * Return: On success 0, on error negative errno.
  */
 int vfs_set_acl(const struct mnt_idmap *idmap, const struct path *path,
-		const char *acl_name, struct posix_acl *kacl)
+		const char *acl_name, struct posix_acl *kacl,
+		struct file *file)
 {
 	struct dentry *dentry = path->dentry;
 	int acl_type;
@@ -1128,7 +1130,7 @@ int vfs_set_acl(const struct mnt_idmap *idmap, const struct path *path,
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_set_acl(idmap, dentry, acl_name, kacl);
+	error = security_inode_set_acl(idmap, path, acl_name, kacl, file);
 	if (error)
 		goto out_inode_unlock;
 
@@ -1163,6 +1165,7 @@ EXPORT_SYMBOL_GPL(vfs_set_acl);
  * @idmap: idmap of the mount the posix acls are retrieved through
  * @path: the path based on which to retrieve the posix acls
  * @acl_name: the name of the posix acl
+ * @file: file through which the posix acls are retrieved, or NULL
  *
  * This function retrieves @kacl from the filesystem. The caller must all
  * posix_acl_release() on @kacl.
@@ -1171,7 +1174,7 @@ EXPORT_SYMBOL_GPL(vfs_set_acl);
  */
 struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
 			      const struct path *path,
-			      const char *acl_name)
+			      const char *acl_name, struct file *file)
 {
 	struct dentry *dentry = path->dentry;
 	struct inode *inode = d_inode(dentry);
@@ -1186,7 +1189,7 @@ struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
 	 * The VFS has no restrictions on reading POSIX ACLs so calling
 	 * something like xattr_permission() isn't needed. Only LSMs get a say.
 	 */
-	error = security_inode_get_acl(idmap, dentry, acl_name);
+	error = security_inode_get_acl(idmap, path, acl_name, file);
 	if (error)
 		return ERR_PTR(error);
 
@@ -1210,13 +1213,14 @@ EXPORT_SYMBOL_GPL(vfs_get_acl);
  * @idmap: idmap of the mount the posix acls are removed through
  * @path: the path based on which to retrieve the posix acls
  * @acl_name: the name of the posix acl
+ * @file: file through which the posix acls are removed, or NULL
  *
  * This function removes posix acls.
  *
  * Return: On success 0, on error negative errno.
  */
 int vfs_remove_acl(const struct mnt_idmap *idmap, const struct path *path,
-		   const char *acl_name)
+		   const char *acl_name, struct file *file)
 {
 	struct dentry *dentry = path->dentry;
 	int acl_type;
@@ -1239,7 +1243,7 @@ int vfs_remove_acl(const struct mnt_idmap *idmap, const struct path *path,
 	if (error)
 		goto out_inode_unlock;
 
-	error = security_inode_remove_acl(idmap, dentry, acl_name);
+	error = security_inode_remove_acl(idmap, path, acl_name, file);
 	if (error)
 		goto out_inode_unlock;
 
@@ -1270,7 +1274,8 @@ int vfs_remove_acl(const struct mnt_idmap *idmap, const struct path *path,
 EXPORT_SYMBOL_GPL(vfs_remove_acl);
 
 int do_set_acl(const struct mnt_idmap *idmap, const struct path *path,
-	       const char *acl_name, const void *kvalue, size_t size)
+	       const char *acl_name, const void *kvalue, size_t size,
+	       struct file *file)
 {
 	int error;
 	struct posix_acl *acl = NULL;
@@ -1285,18 +1290,19 @@ int do_set_acl(const struct mnt_idmap *idmap, const struct path *path,
 			return PTR_ERR(acl);
 	}
 
-	error = vfs_set_acl(idmap, path, acl_name, acl);
+	error = vfs_set_acl(idmap, path, acl_name, acl, file);
 	posix_acl_release(acl);
 	return error;
 }
 
 ssize_t do_get_acl(const struct mnt_idmap *idmap, const struct path *path,
-		   const char *acl_name, void *kvalue, size_t size)
+		   const char *acl_name, void *kvalue, size_t size,
+		   struct file *file)
 {
 	ssize_t error;
 	struct posix_acl *acl;
 
-	acl = vfs_get_acl(idmap, path, acl_name);
+	acl = vfs_get_acl(idmap, path, acl_name, file);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 
diff --git a/fs/smb/server/vfs.c b/fs/smb/server/vfs.c
index cfb9a811363e..54b5f17995c3 100644
--- a/fs/smb/server/vfs.c
+++ b/fs/smb/server/vfs.c
@@ -1564,7 +1564,7 @@ int ksmbd_vfs_remove_acl_xattrs(const struct mnt_idmap *idmap,
 			     sizeof(XATTR_NAME_POSIX_ACL_ACCESS) - 1) ||
 		    !strncmp(name, XATTR_NAME_POSIX_ACL_DEFAULT,
 			     sizeof(XATTR_NAME_POSIX_ACL_DEFAULT) - 1)) {
-			err = vfs_remove_acl(idmap, path, name);
+			err = vfs_remove_acl(idmap, path, name, NULL);
 			if (err)
 				ksmbd_debug(SMB,
 					    "remove acl xattr failed : %s\n", name);
diff --git a/fs/xattr.c b/fs/xattr.c
index 747c041e66fa..7ef3d28e5979 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -670,7 +670,7 @@ static int do_setxattr(const struct mnt_idmap *idmap, const struct path *path,
 {
 	if (is_posix_acl_xattr(ctx->kname->name))
 		return do_set_acl(idmap, path, ctx->kname->name,
-				  ctx->kvalue, ctx->size);
+				  ctx->kvalue, ctx->size, file);
 
 	return vfs_setxattr(idmap, path, ctx->kname->name,
 			ctx->kvalue, ctx->size, ctx->flags, file);
@@ -816,7 +816,8 @@ do_getxattr(const struct mnt_idmap *idmap, const struct path *path,
 	}
 
 	if (is_posix_acl_xattr(kname))
-		error = do_get_acl(idmap, path, kname, kvalue, ctx->size);
+		error = do_get_acl(idmap, path, kname, kvalue,
+				   ctx->size, file);
 	else
 		error = vfs_getxattr(idmap, path, kname, kvalue,
 				     ctx->size, file);
@@ -1048,7 +1049,7 @@ removexattr(const struct mnt_idmap *idmap, const struct path *path,
 	    const char *name, struct file *file)
 {
 	if (is_posix_acl_xattr(name))
-		return vfs_remove_acl(idmap, path, name);
+		return vfs_remove_acl(idmap, path, name, file);
 	return vfs_removexattr(idmap, path, name, file);
 }
 
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 2315961b6d71..8b191df5b169 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -171,13 +171,16 @@ LSM_HOOK(void, LSM_RET_VOID, inode_post_removexattr, struct dentry *dentry,
 LSM_HOOK(int, 0, inode_file_setattr, struct dentry *dentry, struct file_kattr *fa)
 LSM_HOOK(int, 0, inode_file_getattr, struct dentry *dentry, struct file_kattr *fa)
 LSM_HOOK(int, 0, inode_set_acl, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *acl_name, struct posix_acl *kacl)
+	 const struct path *path, const char *acl_name,
+	 struct posix_acl *kacl, struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_set_acl, struct dentry *dentry,
 	 const char *acl_name, struct posix_acl *kacl)
 LSM_HOOK(int, 0, inode_get_acl, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *acl_name)
+	 const struct path *path, const char *acl_name,
+	 struct file *file)
 LSM_HOOK(int, 0, inode_remove_acl, const struct mnt_idmap *idmap,
-	 struct dentry *dentry, const char *acl_name)
+	 const struct path *path, const char *acl_name,
+	 struct file *file)
 LSM_HOOK(void, LSM_RET_VOID, inode_post_remove_acl, const struct mnt_idmap *idmap,
 	 struct dentry *dentry, const char *acl_name)
 LSM_HOOK(int, 0, inode_need_killpriv, struct dentry *dentry)
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 4bd2ed8378c9..f5e381553fee 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -106,12 +106,13 @@ static inline void cache_no_acl(struct inode *inode)
 }
 
 int vfs_set_acl(const struct mnt_idmap *idmap, const struct path *path,
-		const char *acl_name, struct posix_acl *kacl);
+		const char *acl_name, struct posix_acl *kacl,
+		struct file *file);
 struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
 			      const struct path *path,
-			      const char *acl_name);
+			      const char *acl_name, struct file *file);
 int vfs_remove_acl(const struct mnt_idmap *idmap, const struct path *path,
-		   const char *acl_name);
+		   const char *acl_name, struct file *file);
 int posix_acl_listxattr(struct inode *inode, char **buffer,
 			ssize_t *remaining_size);
 #else
@@ -144,21 +145,22 @@ static inline void forget_all_cached_acls(struct inode *inode)
 
 static inline int vfs_set_acl(const struct mnt_idmap *idmap,
 			      const struct path *path, const char *name,
-			      struct posix_acl *acl)
+			      struct posix_acl *acl, struct file *file)
 {
 	return -EOPNOTSUPP;
 }
 
 static inline struct posix_acl *vfs_get_acl(const struct mnt_idmap *idmap,
 					    const struct path *path,
-					    const char *acl_name)
+					    const char *acl_name,
+					    struct file *file)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
 static inline int vfs_remove_acl(const struct mnt_idmap *idmap,
 				 const struct path *path,
-				 const char *acl_name)
+				 const char *acl_name, struct file *file)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/include/linux/security.h b/include/linux/security.h
index 35693bc328d3..27291542a7e2 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -441,14 +441,16 @@ int security_inode_setxattr(const struct mnt_idmap *idmap,
 			    const void *value, size_t size, int flags,
 			    struct file *file);
 int security_inode_set_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name,
-			   struct posix_acl *kacl);
+			   const struct path *path, const char *acl_name,
+			   struct posix_acl *kacl, struct file *file);
 void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 				 struct posix_acl *kacl);
 int security_inode_get_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name);
+			   const struct path *path, const char *acl_name,
+			   struct file *file);
 int security_inode_remove_acl(const struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name);
+			      const struct path *path, const char *acl_name,
+			      struct file *file);
 void security_inode_post_remove_acl(const struct mnt_idmap *idmap,
 				    struct dentry *dentry,
 				    const char *acl_name);
@@ -1028,9 +1030,10 @@ static inline int security_inode_setxattr(const struct mnt_idmap *idmap,
 }
 
 static inline int security_inode_set_acl(const struct mnt_idmap *idmap,
-					 struct dentry *dentry,
+					 const struct path *path,
 					 const char *acl_name,
-					 struct posix_acl *kacl)
+					 struct posix_acl *kacl,
+					 struct file *file)
 {
 	return 0;
 }
@@ -1041,15 +1044,17 @@ static inline void security_inode_post_set_acl(struct dentry *dentry,
 { }
 
 static inline int security_inode_get_acl(const struct mnt_idmap *idmap,
-					 struct dentry *dentry,
-					 const char *acl_name)
+					 const struct path *path,
+					 const char *acl_name,
+					 struct file *file)
 {
 	return 0;
 }
 
 static inline int security_inode_remove_acl(const struct mnt_idmap *idmap,
-					    struct dentry *dentry,
-					    const char *acl_name)
+					    const struct path *path,
+					    const char *acl_name,
+					    struct file *file)
 {
 	return 0;
 }
diff --git a/security/integrity/evm/evm_main.c b/security/integrity/evm/evm_main.c
index 2e1978cbe369..5c24111a9ba7 100644
--- a/security/integrity/evm/evm_main.c
+++ b/security/integrity/evm/evm_main.c
@@ -690,10 +690,11 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
 
 /**
  * evm_inode_set_acl - protect the EVM extended attribute from posix acls
- * @idmap: idmap of the idmapped mount
- * @dentry: pointer to the affected dentry
+ * @idmap: idmap of the mount
+ * @path: pointer to the affected object
  * @acl_name: name of the posix acl
  * @kacl: pointer to the posix acls
+ * @file: file through which the posix acls are set, if any
  *
  * Prevent modifying posix acls causing the EVM HMAC to be re-calculated
  * and 'security.evm' xattr updated, unless the existing 'security.evm' is
@@ -701,10 +702,13 @@ static inline int evm_inode_set_acl_change(const struct mnt_idmap *idmap,
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
-			     const char *acl_name, struct posix_acl *kacl)
+static int evm_inode_set_acl(const struct mnt_idmap *idmap,
+			     const struct path *path,
+			     const char *acl_name, struct posix_acl *kacl,
+			     struct file *file)
 {
 	enum integrity_status evm_status;
+	struct dentry *dentry = path->dentry;
 
 	/* Policy permits modification of the protected xattrs even though
 	 * there's no HMAC key loaded
@@ -744,8 +748,9 @@ static int evm_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentr
 /**
  * evm_inode_remove_acl - Protect the EVM extended attribute from posix acls
  * @idmap: idmap of the mount
- * @dentry: pointer to the affected dentry
+ * @path: pointer to the affected object
  * @acl_name: name of the posix acl
+ * @file: file through which the posix acls are removed, if any
  *
  * Prevent removing posix acls causing the EVM HMAC to be re-calculated
  * and 'security.evm' xattr updated, unless the existing 'security.evm' is
@@ -753,10 +758,11 @@ static int evm_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentr
  *
  * Return: zero on success, -EPERM on failure.
  */
-static int evm_inode_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
-				const char *acl_name)
+static int evm_inode_remove_acl(const struct mnt_idmap *idmap,
+				const struct path *path,
+				const char *acl_name, struct file *file)
 {
-	return evm_inode_set_acl(idmap, dentry, acl_name, NULL);
+	return evm_inode_set_acl(idmap, path, acl_name, NULL, file);
 }
 
 static void evm_reset_status(struct inode *inode)
diff --git a/security/integrity/ima/ima_appraise.c b/security/integrity/ima/ima_appraise.c
index ebf050195cf0..a231f1f419f7 100644
--- a/security/integrity/ima/ima_appraise.c
+++ b/security/integrity/ima/ima_appraise.c
@@ -795,11 +795,13 @@ static int ima_inode_setxattr(const struct mnt_idmap *idmap,
 	return result;
 }
 
-static int ima_inode_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
-			     const char *acl_name, struct posix_acl *kacl)
+static int ima_inode_set_acl(const struct mnt_idmap *idmap,
+			     const struct path *path,
+			     const char *acl_name, struct posix_acl *kacl,
+			     struct file *file)
 {
 	if (evm_revalidate_status(acl_name))
-		ima_reset_appraise_flags(d_backing_inode(dentry), -1);
+		ima_reset_appraise_flags(d_backing_inode(path->dentry), -1);
 
 	return 0;
 }
@@ -821,10 +823,11 @@ static int ima_inode_removexattr(const struct mnt_idmap *idmap,
 	return result;
 }
 
-static int ima_inode_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
-				const char *acl_name)
+static int ima_inode_remove_acl(const struct mnt_idmap *idmap,
+				 const struct path *path,
+				 const char *acl_name, struct file *file)
 {
-	return ima_inode_set_acl(idmap, dentry, acl_name, NULL);
+	return ima_inode_set_acl(idmap, path, acl_name, NULL, file);
 }
 
 static struct security_hook_list ima_appraise_hooks[] __ro_after_init = {
diff --git a/security/security.c b/security/security.c
index 83132d40cc9c..af1777f2aa5e 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1970,9 +1970,10 @@ int security_inode_setxattr(const struct mnt_idmap *idmap,
 /**
  * security_inode_set_acl() - Check if setting posix acls is allowed
  * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @acl_name: acl name
  * @kacl: acl struct
+ * @file: file through which the posix acls are set, if any
  *
  * Check permission before setting posix acls, the posix acls in @kacl are
  * identified by @acl_name.
@@ -1980,12 +1981,13 @@ int security_inode_setxattr(const struct mnt_idmap *idmap,
  * Return: Returns 0 if permission is granted.
  */
 int security_inode_set_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name,
-			   struct posix_acl *kacl)
+			   const struct path *path, const char *acl_name,
+			   struct posix_acl *kacl, struct file *file)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_set_acl, idmap, dentry, acl_name, kacl);
+	return call_int_hook(inode_set_acl, idmap, path, acl_name, kacl,
+			       file);
 }
 
 /**
@@ -2008,8 +2010,9 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
 /**
  * security_inode_get_acl() - Check if reading posix acls is allowed
  * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @acl_name: acl name
+ * @file: file through which the posix acls are retrieved, if any
  *
  * Check permission before getting osix acls, the posix acls are identified by
  * @acl_name.
@@ -2017,18 +2020,20 @@ void security_inode_post_set_acl(struct dentry *dentry, const char *acl_name,
  * Return: Returns 0 if permission is granted.
  */
 int security_inode_get_acl(const struct mnt_idmap *idmap,
-			   struct dentry *dentry, const char *acl_name)
+			   const struct path *path, const char *acl_name,
+			   struct file *file)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_get_acl, idmap, dentry, acl_name);
+	return call_int_hook(inode_get_acl, idmap, path, acl_name, file);
 }
 
 /**
  * security_inode_remove_acl() - Check if removing a posix acl is allowed
  * @idmap: idmap of the mount
- * @dentry: file
+ * @path: file (the VFS makes no guarantees with regard to @path->mnt)
  * @acl_name: acl name
+ * @file: file through which the posix acls are removed, if any
  *
  * Check permission before removing posix acls, the posix acls are identified
  * by @acl_name.
@@ -2036,11 +2041,12 @@ int security_inode_get_acl(const struct mnt_idmap *idmap,
  * Return: Returns 0 if permission is granted.
  */
 int security_inode_remove_acl(const struct mnt_idmap *idmap,
-			      struct dentry *dentry, const char *acl_name)
+			      const struct path *path, const char *acl_name,
+			      struct file *file)
 {
-	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
+	if (unlikely(IS_PRIVATE(d_backing_inode(path->dentry))))
 		return 0;
-	return call_int_hook(inode_remove_acl, idmap, dentry, acl_name);
+	return call_int_hook(inode_remove_acl, idmap, path, acl_name, file);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 4a88bcdbd99a..2b5efe041bc1 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3477,22 +3477,25 @@ static int selinux_inode_setxattr(const struct mnt_idmap *idmap,
 }
 
 static int selinux_inode_set_acl(const struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name,
-				 struct posix_acl *kacl)
+				 const struct path *path,
+				 const char *acl_name, struct posix_acl *kacl,
+				 struct file *file)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
 static int selinux_inode_get_acl(const struct mnt_idmap *idmap,
-				 struct dentry *dentry, const char *acl_name)
+				 const struct path *path,
+				 const char *acl_name, struct file *file)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__GETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__GETATTR);
 }
 
 static int selinux_inode_remove_acl(const struct mnt_idmap *idmap,
-				    struct dentry *dentry, const char *acl_name)
+				    const struct path *path,
+				    const char *acl_name, struct file *file)
 {
-	return dentry_has_perm(current_cred(), dentry, FILE__SETATTR);
+	return dentry_has_perm(current_cred(), path->dentry, FILE__SETATTR);
 }
 
 static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index f739756acb3e..e3445a4f6a45 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1551,68 +1551,74 @@ static int smack_inode_removexattr(const struct mnt_idmap *idmap,
 /**
  * smack_inode_set_acl - Smack check for setting posix acls
  * @idmap: idmap of the mnt this request came from
- * @dentry: the object
+ * @path: the object
  * @acl_name: name of the posix acl
  * @kacl: the posix acls
+ * @file: file through which the posix acls are set, if any
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
 static int smack_inode_set_acl(const struct mnt_idmap *idmap,
-			       struct dentry *dentry, const char *acl_name,
-			       struct posix_acl *kacl)
+			       const struct path *path,
+			       const char *acl_name, struct posix_acl *kacl,
+			       struct file *file)
 {
 	struct smk_audit_info ad;
 	int rc;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
-	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
+	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
 
-	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_WRITE, &ad);
-	rc = smk_bu_inode(d_backing_inode(dentry), MAY_WRITE, rc);
+	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_WRITE, &ad);
+	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_WRITE, rc);
 	return rc;
 }
 
 /**
  * smack_inode_get_acl - Smack check for getting posix acls
  * @idmap: idmap of the mnt this request came from
- * @dentry: the object
+ * @path: the object
  * @acl_name: name of the posix acl
+ * @file: file through which the posix acls are retrieved, if any
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
 static int smack_inode_get_acl(const struct mnt_idmap *idmap,
-			       struct dentry *dentry, const char *acl_name)
+			       const struct path *path,
+			       const char *acl_name, struct file *file)
 {
 	struct smk_audit_info ad;
 	int rc;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
-	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
+	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
 
-	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_READ, &ad);
-	rc = smk_bu_inode(d_backing_inode(dentry), MAY_READ, rc);
+	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_READ, &ad);
+	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_READ, rc);
 	return rc;
 }
 
 /**
  * smack_inode_remove_acl - Smack check for getting posix acls
  * @idmap: idmap of the mnt this request came from
- * @dentry: the object
+ * @path: the object
  * @acl_name: name of the posix acl
+ * @file: file through which the posix acls are removed, if any
  *
  * Returns 0 if access is permitted, an error code otherwise
  */
 static int smack_inode_remove_acl(const struct mnt_idmap *idmap,
-				  struct dentry *dentry, const char *acl_name)
+				  const struct path *path,
+				  const char *acl_name, struct file *file)
 {
 	struct smk_audit_info ad;
 	int rc;
 
 	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_DENTRY);
-	smk_ad_setfield_u_fs_path_dentry(&ad, dentry);
+	smk_ad_setfield_u_fs_path_dentry(&ad, path->dentry);
 
-	rc = smk_curacc(smk_of_inode(d_backing_inode(dentry)), MAY_WRITE, &ad);
-	rc = smk_bu_inode(d_backing_inode(dentry), MAY_WRITE, rc);
+	rc = smk_curacc(smk_of_inode(d_backing_inode(path->dentry)), MAY_WRITE, &ad);
+	rc = smk_bu_inode(d_backing_inode(path->dentry), MAY_WRITE, rc);
 	return rc;
 }
 
-- 
2.18.0.huawei.25

