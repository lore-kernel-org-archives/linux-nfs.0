Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.222
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101093;
	b=DyJKlSxvIziavoT/oBcumFXTcWzJY0YRP8oqT9pkg4H6FPd3xqsLhQQ36Hqogk8/O6eQ
	 Y53CT4ajJmFw5AaFJRzm45iaocLyixLHUFzsR1s2nQBZ++otoO6RCh3AB6bjfWruqiNJN
	 9R9pzkUQ0fCIDhvd0UeJMI0DPItk/ntDsc+6oimYyEs4BfMP3oxs0DNNuskNvgG+ltjwy
	 VZFNJCyf83xWKtT8nYUOfuLbniF3voyWljs6Eyx79HGZYrfo+4b7Dzh4AHXVafMLvGjqc
	 MfpOD1Acg92MTrtT6Qy3LOwMPsdwTU2X2bbs5ibQuk306mgsAt2e/xXd26L+pRcRd2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101093;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=uAOcN1LcskuRbgaMclCWuwOteHecX2U/xvOnleYVofo=;
	b=LIgjeq93EFyiR8k6wpVdNmKh9I9vWg0JOJK613yM7gZn6V/4bbNS/gBb9DrU1l8qmbKJ
	 628aksUy3a3hO9IGAo1euH4pFCftU2Fr4dBpgBB55Pm5elETl7BpvkC3jyYCpGOXsWUNh
	 8fv6PkGCaxOo4OAbpT9SHv8RFEWELT89Cfee79vHe27ahLksGR8O9MgNvYcWF6A53GeSk
	 +53XUcT7vZ5Ydsp/40ozBPu4uynVDmeJTHIfciajQWSn1KsuNhzR/0+Z6yjSUrWfL4Jm6
	 QDifOgf5tbqi35NgydHWL3Yg4+yq5p2MMSBMRUhG5uq+FPpcWTQh7r2Z7tIbDn/B/DQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=J75jMg8h;
	arc=none smtp.remote-ip=113.46.200.222
Received: from canpmsgout07.his.huawei.com (canpmsgout07.his.huawei.com [113.46.200.222])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C128F606A31D;
	Tue, 27 Oct 2026 11:38:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C128F606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=J75jMg8h
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=uAOcN1LcskuRbgaMclCWuwOteHecX2U/xvOnleYVofo=;
	b=J75jMg8hZVy2GAZ4D2kNOmck3kpIf5S9zVxkocG76YdJoJYsALBYmXy9r4pWO4P5eiDLqV8tI
	ghC0nU14goKo5/1SHQv9tVtAE4wLkf7n13A9x+w1hNH+lqQEq+bO6+dpEzYooPSprUqBKheNJYf
	u91C5jjYkhFpmCFWgX0pWKQ=
Received: from mail.maildlp.com (unknown [172.19.162.92])
	by canpmsgout07.his.huawei.com (SkyGuard) with ESMTPS id 4jDT541JmJzLlVS;
	Tue, 27 Oct 2026 19:38:00 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 032B240565;
	Tue, 27 Oct 2026 19:38:06 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:38:00 +0800
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
Subject: [PATCH v3 -next 01/18] fs: pass struct path to notify_change()
Date: Tue, 27 Oct 2026 20:11:34 +0800
Message-ID: <20261027121151.1887650-2-caixinchen1@huawei.com>
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

notify_change() takes a struct mnt_idmap and a struct dentry even though
all of its callers either already hold a struct path (or a struct file)
or have to pass &nop_mnt_idmap because no idmapped mount is involved.
Switch the helper and its declaration to take a struct path instead of
the dentry, next to the idmap: the dentry is taken from the path, while
the idmap remains a separate argument, as it must be taken from the
mount at the time the path is checked and passed down unchanged, so
that the VFS and the filesystem are guaranteed to see the same idmap.

The ntfs named stream support applies metadata changes shared with a
stream to the base inode's anonymous dentry, for which no struct path
exists.  Add a __notify_change() variant without the LSM hook call,
following the __vfs_setxattr_noperm() and __vfs_fileattr_set()
precedents, and use it for that internal forward: the user-facing
operation on the stream was already checked by the surrounding
notify_change() call, so the base inode does not need a second
security_inode_setattr() check.

The security_inode_setattr() call within notify_change() keeps taking
the idmap and dentry for now; it will be converted together with
the LSM hook itself in a separate patch.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 drivers/base/devtmpfs.c  |   6 ++-
 fs/attr.c                | 109 +++++++++++++++++++++++++++------------
 fs/coredump.c            |   2 +-
 fs/ecryptfs/inode.c      |  15 +++---
 fs/inode.c               |   7 +--
 fs/namei.c               |   5 +-
 fs/nfsd/nfs4state.c      |  14 ++---
 fs/nfsd/nfs4xdr.c        |   2 +-
 fs/nfsd/state.h          |   2 +-
 fs/nfsd/vfs.c            |  15 ++++--
 fs/ntfs/named_stream.c   |   2 +-
 fs/open.c                |  17 +++---
 fs/overlayfs/overlayfs.h |   7 ++-
 fs/smb/server/smb2pdu.c  |   2 +-
 fs/smb/server/smbacl.c   |   2 +-
 fs/utimes.c              |   2 +-
 include/linux/fs.h       |   8 +--
 17 files changed, 141 insertions(+), 76 deletions(-)

diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index 11c70888f38b..410906a66ee9 100644
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
+		notify_change(&nop_mnt_idmap, &attr_path, &newattrs, NULL);
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
+		notify_change(&nop_mnt_idmap, &attr_path, &newattrs, NULL);
 		inode_unlock(d_inode(dentry));
 		err = vfs_unlink(&nop_mnt_idmap, d_inode(parent.dentry),
 				 dentry, NULL);
diff --git a/fs/attr.c b/fs/attr.c
index 9706d370f34a..cc06fd676e6b 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -397,35 +397,10 @@ int may_setattr(const struct mnt_idmap *idmap, struct inode *inode,
 }
 EXPORT_SYMBOL(may_setattr);
 
-/**
- * notify_change - modify attributes of a filesystem object
- * @idmap:	idmap of the mount the inode was found from
- * @dentry:	object affected
- * @attr:	new attributes
- * @delegated_inode: returns inode, if the inode is delegated
- *
- * The caller must hold the i_rwsem exclusively on the affected object.
- *
- * If notify_change discovers a delegation in need of breaking,
- * it will return -EWOULDBLOCK and return a reference to the inode in
- * delegated_inode.  The caller should then break the delegation and
- * retry.  Because breaking a delegation may take a long time, the
- * caller should drop the i_rwsem before doing so.
- *
- * Alternatively, a caller may pass NULL for delegated_inode.  This may
- * be appropriate for callers that expect the underlying filesystem not
- * to be NFS exported.  Also, passing NULL is fine for callers holding
- * the file open for write, as there can be no conflicting delegation in
- * that case.
- *
- * If the inode has been found through an idmapped mount the idmap of
- * the vfsmount must be passed through @idmap. This function will then
- * take care to map the inode according to @idmap before checking
- * permissions. On non-idmapped mounts or if permission checking is to be
- * performed on the raw inode simply pass @nop_mnt_idmap.
- */
-int notify_change(const struct mnt_idmap *idmap, struct dentry *dentry,
-		  struct iattr *attr, struct delegated_inode *delegated_inode)
+static int do_notify_change(const struct path *const path,
+			    const struct mnt_idmap *const idmap,
+			    struct dentry *const dentry, struct iattr *attr,
+			    struct delegated_inode *delegated_inode)
 {
 	struct inode *inode = dentry->d_inode;
 	umode_t mode = inode->i_mode;
@@ -537,9 +512,16 @@ int notify_change(const struct mnt_idmap *idmap, struct dentry *dentry,
 	    !vfsgid_valid(i_gid_into_vfsgid(idmap, inode)))
 		return -EOVERFLOW;
 
-	error = security_inode_setattr(idmap, dentry, attr);
-	if (error)
-		return error;
+	/*
+	 * The LSM checks are only performed for user-facing calls (i.e.
+	 * when @path is set): internal forwards, e.g. from a stacking
+	 * filesystem, were already checked on the user-facing path.
+	 */
+	if (path) {
+		error = security_inode_setattr(idmap, dentry, attr);
+		if (error)
+			return error;
+	}
 
 	/*
 	 * If ATTR_DELEG is set, then these attributes are being set on
@@ -564,4 +546,67 @@ int notify_change(const struct mnt_idmap *idmap, struct dentry *dentry,
 
 	return error;
 }
+
+/**
+ * __notify_change - modify attributes of a filesystem object, without
+ *                   the LSM check
+ * @idmap:	idmap of the mount the inode was found from
+ * @dentry:	object affected
+ * @attr:	new attributes
+ * @delegated_inode: returns inode, if the inode is delegated
+ *
+ * Like notify_change(), but no security_inode_setattr() hook is called:
+ * this is the variant to use for internal forwards, where the LSM
+ * checks were already performed on the user-facing path.
+ *
+ * The caller must hold the i_rwsem exclusively on the affected object.
+ *
+ * If the inode has been found through an idmapped mount, permission
+ * checking is performed based on @idmap.  This function will take care
+ * to map the inode according to the idmap before checking permissions.
+ *
+ * Return: 0 on success, or a negative error on failure.
+ */
+int __notify_change(const struct mnt_idmap *idmap, struct dentry *dentry,
+		    struct iattr *attr, struct delegated_inode *delegated_inode)
+{
+	return do_notify_change(NULL, idmap, dentry, attr, delegated_inode);
+}
+EXPORT_SYMBOL(__notify_change);
+
+/**
+ * notify_change - modify attributes of a filesystem object
+ * @idmap:	idmap of the mount the inode was found from
+ * @path:	object affected
+ * @attr:	new attributes
+ * @delegated_inode: returns inode, if the inode is delegated
+ *
+ * The caller must hold the i_rwsem exclusively on the affected object.
+ *
+ * If notify_change discovers a delegation in need of breaking,
+ * it will return -EWOULDBLOCK and return a reference to the inode in
+ * delegated_inode.  The caller should then break the delegation and
+ * retry.  Because breaking a delegation may take a long time, the
+ * caller should drop the i_rwsem before doing so.
+ *
+ * Alternatively, a caller may pass NULL for delegated_inode.  This may
+ * be appropriate for callers that expect the underlying filesystem not
+ * to be NFS exported.  Also, passing NULL is fine for callers holding
+ * the file open for write, as there can be no conflicting delegation in
+ * that case.
+ *
+ * If the inode has been found through an idmapped mount the idmap of
+ * the vfsmount must be passed through @idmap. This function will then
+ * take care to map the inode according to @idmap before checking
+ * permissions. On non-idmapped mounts or if permission checking is to
+ * be performed on the raw inode simply pass @nop_mnt_idmap.
+ *
+ * Return: 0 on success, or a negative error on failure.
+ */
+int notify_change(const struct mnt_idmap *idmap, const struct path *path,
+		  struct iattr *attr, struct delegated_inode *delegated_inode)
+{
+	return do_notify_change(path, idmap, path->dentry, attr,
+				delegated_inode);
+}
 EXPORT_SYMBOL(notify_change);
diff --git a/fs/coredump.c b/fs/coredump.c
index b25ef2ffbdee..6ade29cf7d06 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -1060,7 +1060,7 @@ static bool coredump_file(struct core_name *cn, struct coredump_params *cprm,
 	}
 	if (!(file->f_mode & FMODE_CAN_WRITE))
 		return false;
-	if (do_truncate(idmap, file->f_path.dentry, 0, 0, file))
+	if (do_truncate(idmap, &file->f_path, 0, 0, file))
 		return false;
 
 	cprm->file = no_free_ptr(file);
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 48e520960d66..26967e4e4660 100644
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
+	rc = notify_change(&nop_mnt_idmap, &lower_path, &lower_ia, NULL);
 	inode_unlock(d_inode(lower_dentry));
 out:
 	ecryptfs_put_lower_file(inode);
@@ -873,7 +874,6 @@ static int ecryptfs_setattr(const struct mnt_idmap *idmap,
 			    struct dentry *dentry, struct iattr *ia)
 {
 	struct inode *inode = d_inode(dentry);
-	struct dentry *lower_dentry = ecryptfs_dentry_to_lower(dentry);
 	struct inode *lower_inode = ecryptfs_inode_to_lower(inode);
 	struct ecryptfs_crypt_stat *crypt_stat;
 	int rc;
@@ -925,14 +925,15 @@ static int ecryptfs_setattr(const struct mnt_idmap *idmap,
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
+		rc = notify_change(&nop_mnt_idmap, &lower_path, &lower_ia,
+				   NULL);
+		inode_unlock(d_inode(lower_path.dentry));
 	}
 out:
 	fsstack_copy_attr_all(inode, lower_inode);
diff --git a/fs/inode.c b/fs/inode.c
index 702f2d5ef459..fe176293fd36 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2357,7 +2357,7 @@ int dentry_needs_remove_privs(const struct mnt_idmap *idmap,
 }
 
 static int __remove_privs(const struct mnt_idmap *idmap,
-			  struct dentry *dentry, int kill)
+			  const struct path *path, int kill)
 {
 	struct iattr newattrs;
 
@@ -2366,7 +2366,7 @@ static int __remove_privs(const struct mnt_idmap *idmap,
 	 * Note we call this on write, so notify_change will not
 	 * encounter any conflicting delegations:
 	 */
-	return notify_change(idmap, dentry, &newattrs, NULL);
+	return notify_change(idmap, path, &newattrs, NULL);
 }
 
 static int file_remove_privs_flags(struct file *file, unsigned int flags)
@@ -2387,7 +2387,8 @@ static int file_remove_privs_flags(struct file *file, unsigned int flags)
 		if (flags & IOCB_NOWAIT)
 			return -EAGAIN;
 
-		error = __remove_privs(file_mnt_idmap(file), dentry, kill);
+		error = __remove_privs(file_mnt_idmap(file), &file->f_path,
+				       kill);
 	}
 
 	if (!error)
diff --git a/fs/namei.c b/fs/namei.c
index 96c65940391a..e3961bc336c9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4297,9 +4297,8 @@ static int handle_truncate(const struct mnt_idmap *idmap, struct file *filp)
 
 	error = security_file_truncate(filp);
 	if (!error) {
-		error = do_truncate(idmap, path->dentry, 0,
-				    ATTR_MTIME|ATTR_CTIME|ATTR_OPEN,
-				    filp);
+		error = do_truncate(idmap, path, 0,
+				    ATTR_MTIME|ATTR_CTIME|ATTR_OPEN, filp);
 	}
 	put_write_access(inode);
 	return error;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1de6c6d757c3..3a08c56a27c6 100644
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
+	ret = notify_change(&nop_mnt_idmap, path, &attrs, NULL);
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
+	ret = notify_change(&nop_mnt_idmap, &f->f_path, &attr, NULL);
 	inode_unlock(inode);
 	if (ret)
 		pr_notice_ratelimited("nfsd: Unable to update timestamps on "
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 84161dbecd1c..2a86b69b2ae9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4083,7 +4083,7 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
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
index 56c49b5bc5bb..54440029c235 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -455,7 +455,7 @@ nfsd_get_write_access(struct svc_fh *fhp)
 	return nfserrno(get_write_access(d_inode(fhp->fh_dentry)));
 }
 
-static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
+static int __nfsd_setattr(const struct path *path, struct iattr *iap)
 {
 	int host_err;
 
@@ -475,7 +475,8 @@ static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
 		if (iap->ia_size < 0)
 			return -EFBIG;
 
-		host_err = notify_change(&nop_mnt_idmap, dentry, &size_attr, NULL);
+		host_err = notify_change(&nop_mnt_idmap, path, &size_attr,
+					  NULL);
 		if (host_err)
 			return host_err;
 		iap->ia_valid &= ~ATTR_SIZE;
@@ -501,7 +502,7 @@ static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
 	if (!(iap->ia_valid & ATTR_DELEG))
 		iap->ia_valid |= ATTR_CTIME;
 
-	return notify_change(&nop_mnt_idmap, dentry, iap, NULL);
+	return notify_change(&nop_mnt_idmap, path, iap, NULL);
 }
 
 /**
@@ -524,6 +525,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	struct dentry	*dentry;
 	struct inode	*inode;
+	struct path	path;
 	struct iattr	*iap = attr->na_iattr;
 	int		accmode = NFSD_MAY_SATTR;
 	umode_t		ftype = 0;
@@ -569,6 +571,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	dentry = fhp->fh_dentry;
 	inode = d_inode(dentry);
 
+	path = (struct path){
+		.mnt	= fhp->fh_export->ex_path.mnt,
+		.dentry	= dentry,
+	};
+
 	nfsd_sanitize_attrs(inode, iap);
 
 	/*
@@ -612,7 +619,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 * copy for every loop iteration.
 		 */
 		attrs = *iap;
-		host_err = __nfsd_setattr(dentry, &attrs);
+		host_err = __nfsd_setattr(&path, &attrs);
 		if (host_err != -EAGAIN || !retries--)
 			break;
 		if (!nfsd_wait_for_delegreturn(rqstp, inode))
diff --git a/fs/ntfs/named_stream.c b/fs/ntfs/named_stream.c
index 95a3c05f9821..f0b577a6f7c3 100644
--- a/fs/ntfs/named_stream.c
+++ b/fs/ntfs/named_stream.c
@@ -897,7 +897,7 @@ static int ntfs_stream_setattr_common(const struct mnt_idmap *idmap,
 			goto out;
 		}
 		if (base_attr.ia_valid)
-			err = notify_change(idmap, base_dentry, &base_attr,
+			err = __notify_change(idmap, base_dentry, &base_attr,
 					NULL);
 		else
 			err = 0;
diff --git a/fs/open.c b/fs/open.c
index bf398105f03a..294d0ea7488e 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -36,10 +36,11 @@
 
 #include "internal.h"
 
-int do_truncate(const struct mnt_idmap *idmap, struct dentry *dentry,
+int do_truncate(const struct mnt_idmap *idmap, const struct path *path,
 		loff_t length, unsigned int time_attrs, struct file *filp)
 {
 	int ret;
+	struct dentry *dentry = path->dentry;
 	struct iattr newattrs;
 
 	/* Not pretty: "inode->i_size" shouldn't really be signed. But it is. */
@@ -65,7 +66,7 @@ int do_truncate(const struct mnt_idmap *idmap, struct dentry *dentry,
 		return ret;
 
 	/* Note any delegations or leases have already been broken: */
-	ret = notify_change(idmap, dentry, &newattrs, NULL);
+	ret = notify_change(idmap, path, &newattrs, NULL);
 	inode_unlock(dentry->d_inode);
 	return ret;
 }
@@ -115,7 +116,7 @@ int vfs_truncate(const struct path *path, loff_t length)
 
 	error = security_path_truncate(path);
 	if (!error)
-		error = do_truncate(idmap, path->dentry, length, 0, NULL);
+		error = do_truncate(idmap, path, length, 0, NULL);
 
 put_write_and_out:
 	put_write_access(inode);
@@ -191,8 +192,8 @@ int do_ftruncate(struct file *file, loff_t length, unsigned int flags)
 		return error;
 
 	scoped_guard(super_write, inode->i_sb)
-		return do_truncate(file_mnt_idmap(file), dentry, length,
-				   ATTR_MTIME | ATTR_CTIME, file);
+		return do_truncate(file_mnt_idmap(file), &file->f_path,
+				   length, ATTR_MTIME | ATTR_CTIME, file);
 }
 
 int ksys_ftruncate(unsigned int fd, loff_t length, unsigned int flags)
@@ -683,8 +684,8 @@ int chmod_common(const struct path *path, umode_t mode)
 		goto out_unlock;
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
-	error = notify_change(mnt_idmap(path->mnt), path->dentry,
-			      &newattrs, &delegated_inode);
+	error = notify_change(mnt_idmap(path->mnt), path, &newattrs,
+			      &delegated_inode);
 out_unlock:
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
@@ -822,7 +823,7 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 		from_vfsuid(idmap, fs_userns, newattrs.ia_vfsuid),
 		from_vfsgid(idmap, fs_userns, newattrs.ia_vfsgid));
 	if (!error)
-		error = notify_change(idmap, path->dentry, &newattrs,
+		error = notify_change(idmap, path, &newattrs,
 				      &delegated_inode);
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index 92da556598da..0d5699ffadea 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -208,7 +208,12 @@ static inline int ovl_do_notify_change(struct ovl_fs *ofs,
 				       struct dentry *upperdentry,
 				       struct iattr *attr)
 {
-	return notify_change(ovl_upper_mnt_idmap(ofs), upperdentry, attr, NULL);
+	struct path path = {
+		.mnt = ovl_upper_mnt(ofs),
+		.dentry = upperdentry,
+	};
+
+	return notify_change(ovl_upper_mnt_idmap(ofs), &path, attr, NULL);
 }
 
 static inline int ovl_do_rmdir(struct ovl_fs *ofs,
diff --git a/fs/smb/server/smb2pdu.c b/fs/smb/server/smb2pdu.c
index f5fe3cf8ba32..45275b8f23b6 100644
--- a/fs/smb/server/smb2pdu.c
+++ b/fs/smb/server/smb2pdu.c
@@ -8780,7 +8780,7 @@ static int set_file_basic_info(struct ksmbd_file *fp,
 			return -EACCES;
 
 		inode_lock(inode);
-		rc = notify_change(idmap, dentry, &attrs, NULL);
+		rc = notify_change(idmap, &filp->f_path, &attrs, NULL);
 		inode_unlock(inode);
 	}
 	return rc;
diff --git a/fs/smb/server/smbacl.c b/fs/smb/server/smbacl.c
index 664f01263611..c79aa9863c85 100644
--- a/fs/smb/server/smbacl.c
+++ b/fs/smb/server/smbacl.c
@@ -1749,7 +1749,7 @@ int set_info_sec(struct ksmbd_conn *conn, struct ksmbd_tree_connect *tcon,
 	}
 
 	inode_lock(inode);
-	rc = notify_change(idmap, path->dentry, &newattrs, NULL);
+	rc = notify_change(idmap, path, &newattrs, NULL);
 	inode_unlock(inode);
 	if (rc)
 		goto out;
diff --git a/fs/utimes.c b/fs/utimes.c
index e22664e4115f..5193d504d289 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -64,7 +64,7 @@ int vfs_utimes(const struct path *path, struct timespec64 *times)
 	}
 retry_deleg:
 	inode_lock(inode);
-	error = notify_change(mnt_idmap(path->mnt), path->dentry, &newattrs,
+	error = notify_change(mnt_idmap(path->mnt), path, &newattrs,
 			      &delegated_inode);
 	inode_unlock(inode);
 	if (is_delegated(&delegated_inode)) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3e240579e2b5..960334128b83 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2490,8 +2490,8 @@ static inline bool is_idmapped_mnt(const struct vfsmount *mnt)
 }
 
 int vfs_truncate(const struct path *, loff_t);
-int do_truncate(const struct mnt_idmap *, struct dentry *, loff_t start,
-		unsigned int time_attrs, struct file *filp);
+int do_truncate(const struct mnt_idmap *, const struct path *,
+		loff_t length, unsigned int time_attrs, struct file *filp);
 extern int vfs_fallocate(struct file *file, int mode, loff_t offset,
 			loff_t len);
 int do_sys_open(int dfd, const char __user *filename, int flags,
@@ -2714,7 +2714,9 @@ static inline int bmap(struct inode *inode,  sector_t *block)
 }
 #endif
 
-int notify_change(const struct mnt_idmap *, struct dentry *,
+int __notify_change(const struct mnt_idmap *, struct dentry *,
+		    struct iattr *, struct delegated_inode *);
+int notify_change(const struct mnt_idmap *, const struct path *,
 		  struct iattr *, struct delegated_inode *);
 int inode_permission(const struct mnt_idmap *, struct inode *, int);
 int generic_permission(const struct mnt_idmap *, struct inode *, int);
-- 
2.18.0.huawei.25

