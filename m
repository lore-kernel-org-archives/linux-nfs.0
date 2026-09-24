Received: from canpmsgout07.his.huawei.com (canpmsgout07.his.huawei.com [113.46.200.222])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8CB5472F6D;
	Thu, 24 Sep 2026 10:22:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.222
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245353; cv=none; b=G9c9W1rHSrTXq4WlyZ8q6FMXndh0+TB645YwvSLEw3SMuF5c7Q8KKYIAhJInjU1sTu7D1DPKcNHPfK2YAZ22BrkVtiKmL7y/qnG4qX9srOUT3C0gTJquAQolpaQ9fQwPlNg03SbIQmO4fR0pqFFBtzj821h062SoTFjNXIqKDNo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245353; c=relaxed/simple;
	bh=+/K32wSGNGSAy0GrTSnSyHO9Gs60FXZ4iCxsm/7PpGQ=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Rri9rVgIJLlVzFxRXzLlUL5chdFW0xAa0a7Ee6JYtStMZwMrzyQJhoiW10MWNB+WCMeFHgetYQOWS6ZGzvHlMJYHtt7L8RcBtlgg/JLmUuS5Kqley/2ljT+grwUV42xJbhT5Oh+f7IoW9G+mIg97++vmAVaRBvGWlQyJvyl9rdU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=NISgf/f7; arc=none smtp.client-ip=113.46.200.222
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="NISgf/f7"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=GjTyQQ3XH1N9dXXvR9VUiYk5fhOnR7Gu5J01S1rOywY=;
	b=NISgf/f7+aB1wq2z+3DmTajbAV9wWbIWCsw8K8eK9NBCnecy/QAG9zdGh6pmlMd3DK8JuY5aC
	i+OEQkJJVc8YTbTFcjkgn3RUZ6tVF/30wAYVGMyw25pi7E6xZWCI+hJ5Mp0ZnFwHOAB0XfieInB
	aTpUEnrk9JfiBwo4EPQOApg=
Received: from mail.maildlp.com (unknown [172.19.163.15])
	by canpmsgout07.his.huawei.com (SkyGuard) with ESMTPS id 4hr8j80tCQzLlTm;
	Thu, 24 Sep 2026 18:10:20 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 2286D40578;
	Thu, 24 Sep 2026 18:22:26 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:22:21 +0800
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
Subject: [PATCH RFC -next 01/12] fs: pass struct path to notify_change()
Date: Thu, 24 Sep 2026 18:48:20 +0800
Message-ID: <20260924104831.1081137-2-caixinchen1@huawei.com>
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

notify_change() takes a struct mnt_idmap and a struct dentry even
though all of its callers either already hold a struct path (or a
struct file) or have to pass &nop_mnt_idmap because no idmapped
mount is involved.  Switch the helper and its declaration to take a
struct path instead and derive the idmap and dentry from it.

This is a purely mechanical change with no behavior change.  The
security_inode_setattr() call within notify_change() keeps taking
the idmap and dentry for now; it will be converted together with
the LSM hook itself in a separate patch.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 drivers/base/devtmpfs.c   |  6 ++++--
 fs/attr.c                 | 18 +++++++++---------
 fs/cachefiles/interface.c |  6 ++----
 fs/coredump.c             |  2 +-
 fs/ecryptfs/inode.c       | 14 +++++++-------
 fs/inode.c                |  7 +++----
 fs/namei.c                |  7 +++----
 fs/nfsd/nfs4state.c       | 14 ++++++++------
 fs/nfsd/nfs4xdr.c         |  2 +-
 fs/nfsd/state.h           |  2 +-
 fs/nfsd/vfs.c             | 14 ++++++++++----
 fs/open.c                 | 18 +++++++++---------
 fs/overlayfs/overlayfs.h  |  7 ++++++-
 fs/smb/server/smb2pdu.c   |  2 +-
 fs/smb/server/smbacl.c    |  2 +-
 fs/utimes.c               |  3 +--
 include/linux/fs.h        |  6 +++---
 17 files changed, 70 insertions(+), 60 deletions(-)

diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index 11c70888f38b..71da9235ed49 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -284,13 +284,14 @@ static int handle_create(const char *nodename, umode_t mode, kuid_t uid,
 			dev->devt, NULL);
 	if (!err) {
 		struct iattr newattrs;
+		struct path attr_path = { .mnt = path.mnt, .dentry = dentry };
 
 		newattrs.ia_mode = mode;
 		newattrs.ia_uid = uid;
 		newattrs.ia_gid = gid;
 		newattrs.ia_valid = ATTR_MODE|ATTR_UID|ATTR_GID;
 		inode_lock(d_inode(dentry));
-		notify_change(&nop_mnt_idmap, dentry, &newattrs, NULL);
+		notify_change(&attr_path, &newattrs, NULL);
 		inode_unlock(d_inode(dentry));
 
 		/* mark as kernel-created inode */
@@ -380,6 +381,7 @@ static int handle_remove(const char *nodename, struct device *dev)
 	inode = d_inode(dentry);
 	if (dev_mynode(dev, inode)) {
 		struct iattr newattrs;
+		struct path attr_path = { .mnt = parent.mnt, .dentry = dentry };
 		/*
 		 * before unlinking this node, reset permissions
 		 * of possible references like hardlinks
@@ -390,7 +392,7 @@ static int handle_remove(const char *nodename, struct device *dev)
 		newattrs.ia_valid =
 			ATTR_UID|ATTR_GID|ATTR_MODE;
 		inode_lock(d_inode(dentry));
-		notify_change(&nop_mnt_idmap, dentry, &newattrs, NULL);
+		notify_change(&attr_path, &newattrs, NULL);
 		inode_unlock(d_inode(dentry));
 		err = vfs_unlink(&nop_mnt_idmap, d_inode(parent.dentry),
 				 dentry, NULL);
diff --git a/fs/attr.c b/fs/attr.c
index 71888ac903c2..ea91e4471faa 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -399,8 +399,7 @@ EXPORT_SYMBOL(may_setattr);
 
 /**
  * notify_change - modify attributes of a filesystem object
- * @idmap:	idmap of the mount the inode was found from
- * @dentry:	object affected
+ * @path:	object affected
  * @attr:	new attributes
  * @delegated_inode: returns inode, if the inode is delegated
  *
@@ -418,15 +417,16 @@ EXPORT_SYMBOL(may_setattr);
  * the file open for write, as there can be no conflicting delegation in
  * that case.
  *
- * If the inode has been found through an idmapped mount the idmap of
- * the vfsmount must be passed through @idmap. This function will then
- * take care to map the inode according to @idmap before checking
- * permissions. On non-idmapped mounts or if permission checking is to be
- * performed on the raw inode simply pass @nop_mnt_idmap.
+ * If the inode has been found through an idmapped mount, permission
+ * checking is performed based on the idmap of @path->mnt. This function
+ * will take care to map the inode according to the idmap before
+ * checking permissions.
  */
-int notify_change(struct mnt_idmap *idmap, struct dentry *dentry,
-		  struct iattr *attr, struct delegated_inode *delegated_inode)
+int notify_change(const struct path *path, struct iattr *attr,
+		  struct delegated_inode *delegated_inode)
 {
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
+	struct dentry *dentry = path->dentry;
 	struct inode *inode = dentry->d_inode;
 	umode_t mode = inode->i_mode;
 	int error;
diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index a160d5c3e74c..bbaba93015cd 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -138,8 +138,7 @@ static int cachefiles_adjust_size(struct cachefiles_object *object)
 		newattrs.ia_size = oi_size & PAGE_MASK;
 		ret = cachefiles_inject_remove_error();
 		if (ret == 0)
-			ret = notify_change(&nop_mnt_idmap, file->f_path.dentry,
-					    &newattrs, NULL);
+			ret = notify_change(&file->f_path, &newattrs, NULL);
 		if (ret < 0)
 			goto truncate_failed;
 	}
@@ -148,8 +147,7 @@ static int cachefiles_adjust_size(struct cachefiles_object *object)
 	newattrs.ia_size = ni_size;
 	ret = cachefiles_inject_write_error();
 	if (ret == 0)
-		ret = notify_change(&nop_mnt_idmap, file->f_path.dentry,
-				    &newattrs, NULL);
+		ret = notify_change(&file->f_path, &newattrs, NULL);
 
 truncate_failed:
 	inode_unlock(file_inode(file));
diff --git a/fs/coredump.c b/fs/coredump.c
index f809e3fb4ba2..2e9903da7011 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -1049,7 +1049,7 @@ static bool coredump_file(struct core_name *cn, struct coredump_params *cprm,
 	}
 	if (!(file->f_mode & FMODE_CAN_WRITE))
 		return false;
-	if (do_truncate(idmap, file->f_path.dentry, 0, 0, file))
+	if (do_truncate(&file->f_path, 0, 0, file))
 		return false;
 
 	cprm->file = no_free_ptr(file);
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 525297c7ebd8..627d456f9c38 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -732,7 +732,8 @@ upper_size_to_lower_size(struct ecryptfs_crypt_stat *crypt_stat,
  */
 static int __ecryptfs_truncate(struct dentry *dentry, const struct iattr *ia)
 {
-	struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
+	struct path lower_path = ecryptfs_lower_path(dentry);
+	struct dentry *lower_dentry = lower_path.dentry;
 	struct inode *inode = d_inode(dentry);
 	struct ecryptfs_crypt_stat *crypt_stat;
 	loff_t i_size = i_size_read(inode);
@@ -821,7 +822,7 @@ static int __ecryptfs_truncate(struct dentry *dentry, const struct iattr *ia)
 set_size:
 	lower_ia.ia_valid |= ATTR_SIZE;
 	inode_lock(d_inode(lower_dentry));
-	rc = notify_change(&nop_mnt_idmap, lower_dentry, &lower_ia, NULL);
+	rc = notify_change(&lower_path, &lower_ia, NULL);
 	inode_unlock(d_inode(lower_dentry));
 out:
 	ecryptfs_put_lower_file(inode);
@@ -873,7 +874,6 @@ static int ecryptfs_setattr(struct mnt_idmap *idmap,
 			    struct dentry *dentry, struct iattr *ia)
 {
 	struct inode *inode = d_inode(dentry);
-	struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
 	struct inode *lower_inode = ecryptfs_inode_to_lower(inode);
 	struct ecryptfs_crypt_stat *crypt_stat;
 	int rc;
@@ -925,14 +925,14 @@ static int ecryptfs_setattr(struct mnt_idmap *idmap,
 	if (ia->ia_valid & ATTR_SIZE) {
 		rc = __ecryptfs_truncate(dentry, ia);
 	} else {
+		struct path lower_path = ecryptfs_lower_path(dentry);
 		struct iattr lower_ia;
 
 		ecryptfs_iattr_to_lower(&lower_ia, ia);
 
-		inode_lock(d_inode(lower_dentry));
-		rc = notify_change(&nop_mnt_idmap, lower_dentry, &lower_ia,
-				NULL);
-		inode_unlock(d_inode(lower_dentry));
+		inode_lock(d_inode(lower_path.dentry));
+		rc = notify_change(&lower_path, &lower_ia, NULL);
+		inode_unlock(d_inode(lower_path.dentry));
 	}
 out:
 	fsstack_copy_attr_all(inode, lower_inode);
diff --git a/fs/inode.c b/fs/inode.c
index 8cfbc11c2b1f..e1e9eb268803 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2356,8 +2356,7 @@ int dentry_needs_remove_privs(struct mnt_idmap *idmap,
 	return mask;
 }
 
-static int __remove_privs(struct mnt_idmap *idmap,
-			  struct dentry *dentry, int kill)
+static int __remove_privs(const struct path *path, int kill)
 {
 	struct iattr newattrs;
 
@@ -2366,7 +2365,7 @@ static int __remove_privs(struct mnt_idmap *idmap,
 	 * Note we call this on write, so notify_change will not
 	 * encounter any conflicting delegations:
 	 */
-	return notify_change(idmap, dentry, &newattrs, NULL);
+	return notify_change(path, &newattrs, NULL);
 }
 
 static int file_remove_privs_flags(struct file *file, unsigned int flags)
@@ -2387,7 +2386,7 @@ static int file_remove_privs_flags(struct file *file, unsigned int flags)
 		if (flags & IOCB_NOWAIT)
 			return -EAGAIN;
 
-		error = __remove_privs(file_mnt_idmap(file), dentry, kill);
+		error = __remove_privs(&file->f_path, kill);
 	}
 
 	if (!error)
diff --git a/fs/namei.c b/fs/namei.c
index 1dd4ec7d0e62..909da4078eb7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4321,7 +4321,7 @@ static int may_open(struct mnt_idmap *idmap, const struct path *path,
 	return 0;
 }
 
-static int handle_truncate(struct mnt_idmap *idmap, struct file *filp)
+static int handle_truncate(struct file *filp)
 {
 	const struct path *path = &filp->f_path;
 	struct inode *inode = path->dentry->d_inode;
@@ -4331,8 +4331,7 @@ static int handle_truncate(struct mnt_idmap *idmap, struct file *filp)
 
 	error = security_file_truncate(filp);
 	if (!error) {
-		error = do_truncate(idmap, path->dentry, 0,
-				    ATTR_MTIME|ATTR_CTIME|ATTR_OPEN,
+		error = do_truncate(path, 0, ATTR_MTIME|ATTR_CTIME|ATTR_OPEN,
 				    filp);
 	}
 	put_write_access(inode);
@@ -4914,7 +4913,7 @@ static int do_open(struct nameidata *nd,
 	if (!error)
 		error = security_file_post_open(file, op->acc_mode);
 	if (!error && do_truncate)
-		error = handle_truncate(idmap, file);
+		error = handle_truncate(file);
 	if (unlikely(error > 0)) {
 		WARN_ON(1);
 		error = -EINVAL;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1de6c6d757c3..400a42941879 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10477,8 +10477,10 @@ bool nfsd4_vet_deleg_time(struct timespec64 *req, const struct timespec64 *orig,
 	return true;
 }
 
-static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation *dp)
+static int cb_getattr_update_times(const struct path *path,
+				   struct nfs4_delegation *dp)
 {
+	struct dentry *dentry = path->dentry;
 	struct inode *inode = d_inode(dentry);
 	struct nfs4_cb_fattr *ncf = &dp->dl_cb_fattr;
 	struct iattr attrs = { };
@@ -10508,7 +10510,7 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 
 	attrs.ia_valid |= ATTR_DELEG;
 	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, dentry, &attrs, NULL);
+	ret = notify_change(path, &attrs, NULL);
 	inode_unlock(inode);
 	return ret;
 }
@@ -10531,7 +10533,7 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
  * caller must put the reference.
  */
 __be32
-nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
+nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, const struct path *path,
 			     struct nfs4_delegation **pdp)
 {
 	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
@@ -10539,7 +10541,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 	struct nfs4_delegation *dp = NULL;
 	struct file_lease *fl;
 	struct nfs4_cb_fattr *ncf;
-	struct inode *inode = d_inode(dentry);
+	struct inode *inode = d_inode(path->dentry);
 	__be32 status;
 
 	ctx = locks_inode_context(inode);
@@ -10603,7 +10605,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 		 * not update the file's metadata with the client's
 		 * modified size
 		 */
-		err = cb_getattr_update_times(dentry, dp);
+		err = cb_getattr_update_times(path, dp);
 		if (err) {
 			status = nfserrno(err);
 			goto out_status;
@@ -10789,7 +10791,7 @@ void nfsd_update_cmtime_attr(struct file *f, unsigned int flags)
 	};
 
 	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, f->f_path.dentry, &attr, NULL);
+	ret = notify_change(&f->f_path, &attr, NULL);
 	inode_unlock(inode);
 	if (ret)
 		pr_notice_ratelimited("nfsd: Unable to update timestamps on "
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 00ddaac499c6..73bb099ec0f0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4096,7 +4096,7 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	    (attrmask[1] & (FATTR4_WORD1_TIME_ACCESS |
 			    FATTR4_WORD1_TIME_MODIFY |
 			    FATTR4_WORD1_TIME_METADATA))) {
-		status = nfsd4_deleg_getattr_conflict(rqstp, dentry, &dp);
+		status = nfsd4_deleg_getattr_conflict(rqstp, &path, &dp);
 		if (status)
 			goto out;
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cd9294f024bb..183123f0b91f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -1018,7 +1018,7 @@ static inline bool try_to_expire_client(struct nfs4_client *clp)
 }
 
 extern __be32 nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp,
-		struct dentry *dentry, struct nfs4_delegation **pdp);
+		const struct path *path, struct nfs4_delegation **pdp);
 
 struct nfsd4_get_dir_delegation;
 struct nfs4_delegation *nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4789f2ec2078..ed8e04cc794e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -455,7 +455,7 @@ nfsd_get_write_access(struct svc_fh *fhp)
 	return nfserrno(get_write_access(d_inode(fhp->fh_dentry)));
 }
 
-static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
+static int __nfsd_setattr(const struct path *path, struct iattr *iap)
 {
 	int host_err;
 
@@ -475,7 +475,7 @@ static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
 		if (iap->ia_size < 0)
 			return -EFBIG;
 
-		host_err = notify_change(&nop_mnt_idmap, dentry, &size_attr, NULL);
+		host_err = notify_change(path, &size_attr, NULL);
 		if (host_err)
 			return host_err;
 		iap->ia_valid &= ~ATTR_SIZE;
@@ -501,7 +501,7 @@ static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
 	if (!(iap->ia_valid & ATTR_DELEG))
 		iap->ia_valid |= ATTR_CTIME;
 
-	return notify_change(&nop_mnt_idmap, dentry, iap, NULL);
+	return notify_change(path, iap, NULL);
 }
 
 /**
@@ -524,6 +524,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	struct dentry	*dentry;
 	struct inode	*inode;
+	struct path	path;
 	struct iattr	*iap = attr->na_iattr;
 	int		accmode = NFSD_MAY_SATTR;
 	umode_t		ftype = 0;
@@ -569,6 +570,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	dentry = fhp->fh_dentry;
 	inode = d_inode(dentry);
 
+	path = (struct path){
+		.mnt	= fhp->fh_export->ex_path.mnt,
+		.dentry	= dentry,
+	};
+
 	nfsd_sanitize_attrs(inode, iap);
 
 	/*
@@ -612,7 +618,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 * copy for every loop iteration.
 		 */
 		attrs = *iap;
-		host_err = __nfsd_setattr(dentry, &attrs);
+		host_err = __nfsd_setattr(&path, &attrs);
 		if (host_err != -EAGAIN || !retries--)
 			break;
 		if (!nfsd_wait_for_delegreturn(rqstp, inode))
diff --git a/fs/open.c b/fs/open.c
index 6069abe49664..41eb76798a23 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -36,10 +36,12 @@
 
 #include "internal.h"
 
-int do_truncate(struct mnt_idmap *idmap, struct dentry *dentry,
-		loff_t length, unsigned int time_attrs, struct file *filp)
+int do_truncate(const struct path *path, loff_t length,
+		unsigned int time_attrs, struct file *filp)
 {
 	int ret;
+	struct mnt_idmap *idmap = mnt_idmap(path->mnt);
+	struct dentry *dentry = path->dentry;
 	struct iattr newattrs;
 
 	/* Not pretty: "inode->i_size" shouldn't really be signed. But it is. */
@@ -65,7 +67,7 @@ int do_truncate(struct mnt_idmap *idmap, struct dentry *dentry,
 		return ret;
 
 	/* Note any delegations or leases have already been broken: */
-	ret = notify_change(idmap, dentry, &newattrs, NULL);
+	ret = notify_change(path, &newattrs, NULL);
 	inode_unlock(dentry->d_inode);
 	return ret;
 }
@@ -115,7 +117,7 @@ int vfs_truncate(const struct path *path, loff_t length)
 
 	error = security_path_truncate(path);
 	if (!error)
-		error = do_truncate(idmap, path->dentry, length, 0, NULL);
+		error = do_truncate(path, length, 0, NULL);
 
 put_write_and_out:
 	put_write_access(inode);
@@ -191,7 +193,7 @@ int do_ftruncate(struct file *file, loff_t length, unsigned int flags)
 		return error;
 
 	scoped_guard(super_write, inode->i_sb)
-		return do_truncate(file_mnt_idmap(file), dentry, length,
+		return do_truncate(&file->f_path, length,
 				   ATTR_MTIME | ATTR_CTIME, file);
 }
 
@@ -683,8 +685,7 @@ int chmod_common(const struct path *path, umode_t mode)
 		goto out_unlock;
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
-	error = notify_change(mnt_idmap(path->mnt), path->dentry,
-			      &newattrs, &delegated_inode);
+	error = notify_change(path, &newattrs, &delegated_inode);
 out_unlock:
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
@@ -822,8 +823,7 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 		from_vfsuid(idmap, fs_userns, newattrs.ia_vfsuid),
 		from_vfsgid(idmap, fs_userns, newattrs.ia_vfsgid));
 	if (!error)
-		error = notify_change(idmap, path->dentry, &newattrs,
-				      &delegated_inode);
+		error = notify_change(path, &newattrs, &delegated_inode);
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
 		error = break_deleg_wait(&delegated_inode);
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index e0d8c6152e9f..d915b87c0b06 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -206,7 +206,12 @@ static inline int ovl_do_notify_change(struct ovl_fs *ofs,
 				       struct dentry *upperdentry,
 				       struct iattr *attr)
 {
-	return notify_change(ovl_upper_mnt_idmap(ofs), upperdentry, attr, NULL);
+	struct path path = {
+		.mnt = ovl_upper_mnt(ofs),
+		.dentry = upperdentry,
+	};
+
+	return notify_change(&path, attr, NULL);
 }
 
 static inline int ovl_do_rmdir(struct ovl_fs *ofs,
diff --git a/fs/smb/server/smb2pdu.c b/fs/smb/server/smb2pdu.c
index 15e2801a8ce1..fb3ee170db3c 100644
--- a/fs/smb/server/smb2pdu.c
+++ b/fs/smb/server/smb2pdu.c
@@ -8243,7 +8243,7 @@ static int set_file_basic_info(struct ksmbd_file *fp,
 			return -EACCES;
 
 		inode_lock(inode);
-		rc = notify_change(idmap, dentry, &attrs, NULL);
+		rc = notify_change(&filp->f_path, &attrs, NULL);
 		inode_unlock(inode);
 	}
 	return rc;
diff --git a/fs/smb/server/smbacl.c b/fs/smb/server/smbacl.c
index e75247915c87..fcace71b0a29 100644
--- a/fs/smb/server/smbacl.c
+++ b/fs/smb/server/smbacl.c
@@ -1721,7 +1721,7 @@ int set_info_sec(struct ksmbd_conn *conn, struct ksmbd_tree_connect *tcon,
 	}
 
 	inode_lock(inode);
-	rc = notify_change(idmap, path->dentry, &newattrs, NULL);
+	rc = notify_change(path, &newattrs, NULL);
 	inode_unlock(inode);
 	if (rc)
 		goto out;
diff --git a/fs/utimes.c b/fs/utimes.c
index e22664e4115f..5de794587147 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -64,8 +64,7 @@ int vfs_utimes(const struct path *path, struct timespec64 *times)
 	}
 retry_deleg:
 	inode_lock(inode);
-	error = notify_change(mnt_idmap(path->mnt), path->dentry, &newattrs,
-			      &delegated_inode);
+	error = notify_change(path, &newattrs, &delegated_inode);
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
 		error = break_deleg_wait(&delegated_inode);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 05d05bb9c951..4087c45d88d5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2483,7 +2483,7 @@ static inline bool is_idmapped_mnt(const struct vfsmount *mnt)
 }
 
 int vfs_truncate(const struct path *, loff_t);
-int do_truncate(struct mnt_idmap *, struct dentry *, loff_t start,
+int do_truncate(const struct path *path, loff_t length,
 		unsigned int time_attrs, struct file *filp);
 extern int vfs_fallocate(struct file *file, int mode, loff_t offset,
 			loff_t len);
@@ -2707,8 +2707,8 @@ static inline int bmap(struct inode *inode,  sector_t *block)
 }
 #endif
 
-int notify_change(struct mnt_idmap *, struct dentry *,
-		  struct iattr *, struct delegated_inode *);
+int notify_change(const struct path *path, struct iattr *attr,
+		  struct delegated_inode *delegated_inode);
 int inode_permission(struct mnt_idmap *, struct inode *, int);
 int generic_permission(struct mnt_idmap *, struct inode *, int);
 static inline int file_permission(struct file *file, int mask)
-- 
2.18.0.huawei.25

