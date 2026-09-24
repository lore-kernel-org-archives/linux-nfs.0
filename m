Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B294A47F3C8;
	Thu, 24 Sep 2026 10:23:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245391; cv=none; b=CV5uDKGTf21FK0Wo2lgEIs0oOBKhC3eCOryMOIhvOCEqZE8Bist+ew2LGkZjvmmT8Nm+CvBW1cnQa1+UOS76vdk6ArqVkT3EUnBCUNvsbujOvZMMhCdHH52xd3gb88MERIqAWpTjops2FaLZ+lUw5GEpuP/aZmKsAnGA+vYUpNM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245391; c=relaxed/simple;
	bh=kPZ7kSV7h3PbnyJjDNNBC436auNtiwgx9wgf/yL9eBo=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=MU/5PQyA+mUf80KUpmf3Ses/QJqyKteEFmaBcRODcwbEWgD1pKJYavTfOSS0D3Dp/lRFgeIP/QS52CkM7dAERIRzLku7B4dzpIHfnWBLfPWjC1NXMkOxLlO3cxfBvDp3Pn1Jr9Tf3HHzJjXSp+06g+9Qg+qFR6mX0zfFzTpvMV4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=bdk57RtK; arc=none smtp.client-ip=113.46.200.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="bdk57RtK"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=MZ1uULpIvXaxZi3vnTnjSUlgREhcBScDIx/J/VNziJE=;
	b=bdk57RtKGpe9cc8Vfy/o2gf5H3AWR8a+RFsoHm5d5onmfgOclSgOsrhdppbEitCUN6xgu8ge6
	DQeuQ4gFZ4HrCpMrIuI3gn0gBtlCeW2M/DmCuPVoGCU1taKQuI8DSUpd5WFkfC62yoSSNVFUPzW
	Pj3wUTGhX9E3HOZpaTHWrBo=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4hr8jy2yXtznTWP;
	Thu, 24 Sep 2026 18:11:02 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 375CC40561;
	Thu, 24 Sep 2026 18:23:06 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:23:01 +0800
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
Subject: [PATCH RFC -next 09/12] landlock: Implement metadata access hooks
Date: Thu, 24 Sep 2026 18:48:28 +0800
Message-ID: <20260924104831.1081137-10-caixinchen1@huawei.com>
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

Implement the LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights by hooking the
inode_getattr, inode_setattr, inode_setxattr, inode_getxattr,
inode_listxattr, inode_removexattr, inode_set_acl, inode_get_acl and
inode_remove_acl LSM hooks, which now receive a struct path thanks to
the preceding VFS and LSM refactoring.

The following system calls are now controlled:

- stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
  friends, listxattr(2) and friends, and POSIX ACL reads via
  inode_getattr, inode_getxattr, inode_listxattr and inode_get_acl
  (READ_METADATA)
- chmod(2), fchmod(2), fchmodat(2), fchmodat2(2), chown(2), fchown(2),
  lchown(2), fchownat(2), chgrp(2), utimensat(2), futimens(2),
  utime(2), setxattr(2) and friends, removexattr(2) and friends, and
  POSIX ACL set and remove via inode_setattr, inode_setxattr,
  inode_removexattr, inode_set_acl and inode_remove_acl
  (WRITE_METADATA)

Both new rights are added to ACCESS_FILE as they apply to both files
and directories.

hook_inode_setattr only restricts explicit metadata changes, i.e. it
checks WRITE_METADATA only when the ia_valid mask contains
ATTR_MODE, ATTR_UID, ATTR_GID, ATTR_TIMES_SET or ATTR_TOUCH.
Metadata changes that the kernel performs implicitly, such as
timestamp updates on write(2) or size changes on truncate(2), are
therefore not restricted, and neither are chmod(2)/chown(2) calls
that do not change any attribute (e.g. chown(2) with -1/-1, which is
a no-op that never reaches the hook), matching the behavior of the
SELinux inode_setattr hook.

Kernel-internal accesses performed with override_creds() (e.g.
overlayfs and cachefiles) are not affected because Landlock domains
are attached to credentials, and kernel threads without a Landlock
domain (e.g. nfsd and ksmbd) are not restricted either.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 security/landlock/fs.c | 86 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 86 insertions(+)

diff --git a/security/landlock/fs.c b/security/landlock/fs.c
index cab43892ec2f..e58b2aa0da65 100644
--- a/security/landlock/fs.c
+++ b/security/landlock/fs.c
@@ -318,6 +318,8 @@ static struct landlock_object *get_inode_object(struct inode *const inode)
 	LANDLOCK_ACCESS_FS_EXECUTE | \
 	LANDLOCK_ACCESS_FS_WRITE_FILE | \
 	LANDLOCK_ACCESS_FS_READ_FILE | \
+	LANDLOCK_ACCESS_FS_READ_METADATA | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA | \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
 	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
 	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
@@ -1676,6 +1678,81 @@ static int hook_path_truncate(const struct path *const path)
 	return current_check_access_path(path, LANDLOCK_ACCESS_FS_TRUNCATE);
 }
 
+static int hook_inode_getattr(const struct path *const path)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_setattr(const struct path *const path,
+			      struct iattr *const attr)
+{
+	/*
+	 * Explicit metadata changes (i.e. mode, ownership, and timestamps
+	 * set with utimes() and friends) require
+	 * LANDLOCK_ACCESS_FS_WRITE_METADATA.  Implicit timestamp updates
+	 * (e.g. ATTR_CTIME set for a write) and size changes (handled by
+	 * the truncate hooks) are not restricted.
+	 */
+	if (!(attr->ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID |
+				ATTR_TIMES_SET | ATTR_TOUCH)))
+		return 0;
+
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_setxattr(const struct path *const path,
+			       const char *const name,
+			       const void *const value, const size_t size,
+			       const int flags)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_getxattr(const struct path *const path,
+			       const char *const name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_listxattr(const struct path *const path)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_removexattr(const struct path *const path,
+				  const char *const name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_set_acl(const struct path *const path,
+			      const char *const acl_name,
+			      struct posix_acl *const kacl)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
+static int hook_inode_get_acl(const struct path *const path,
+			      const char *const acl_name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_READ_METADATA);
+}
+
+static int hook_inode_remove_acl(const struct path *const path,
+				 const char *const acl_name)
+{
+	return current_check_access_path(path,
+					LANDLOCK_ACCESS_FS_WRITE_METADATA);
+}
+
 /**
  * unmask_scoped_access - Remove access right bits in @masks in all layers
  *                        where @client and @server have the same domain
@@ -2100,6 +2177,15 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(path_unlink, hook_path_unlink),
 	LSM_HOOK_INIT(path_rmdir, hook_path_rmdir),
 	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
+	LSM_HOOK_INIT(inode_getattr, hook_inode_getattr),
+	LSM_HOOK_INIT(inode_setattr, hook_inode_setattr),
+	LSM_HOOK_INIT(inode_setxattr, hook_inode_setxattr),
+	LSM_HOOK_INIT(inode_getxattr, hook_inode_getxattr),
+	LSM_HOOK_INIT(inode_listxattr, hook_inode_listxattr),
+	LSM_HOOK_INIT(inode_removexattr, hook_inode_removexattr),
+	LSM_HOOK_INIT(inode_set_acl, hook_inode_set_acl),
+	LSM_HOOK_INIT(inode_get_acl, hook_inode_get_acl),
+	LSM_HOOK_INIT(inode_remove_acl, hook_inode_remove_acl),
 	LSM_HOOK_INIT(unix_find, hook_unix_find),
 
 	LSM_HOOK_INIT(file_alloc_security, hook_file_alloc_security),
-- 
2.18.0.huawei.25

