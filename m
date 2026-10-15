Received: from canpmsgout02.his.huawei.com (canpmsgout02.his.huawei.com [113.46.200.217])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C5A45237B8;
	Thu, 15 Oct 2026 12:20:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.217
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066803; cv=none; b=u6scgVcCgl+ZfeeolHKdyvphZypK0Bz++bteFl8hG3FOReoLuZ+dAZYywDbV2uEmZDxMeHIowbLHfnX1ipJ5rOJraqJGBVrAYyVFb03Hh7YjGsG/iwRYDC/ei69aZlA1ft4wn7PgDH16B/3TqCGf9MlO0i/v8xmGxEJYUe+JgXk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066803; c=relaxed/simple;
	bh=iFEcXFem0S4ag3aIGbrWkgNqpMw0zdOUsTcEJKTsypo=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=SHZ9H2AZgZDxRvxiZS3xVkWBFzTM5gkUgaAVSLnf65OoHE0YNGBsSNSc2v6seKRxFAU1T3ibUQJXqr/g3c2IuW39JzF30XtOT4Kn8gPJxfQDeeUW9L6wOUrrW6rwuD/J3GhBPrZ3NsFTEQXpvAkv8fZfKPE8cVkt8taJs1Aq6Cw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=JyA8Bv8d; arc=none smtp.client-ip=113.46.200.217
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="JyA8Bv8d"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=JkcMfObppTOh4/0LOfM0qmt1OEdloAWmtAWhxMp42dc=;
	b=JyA8Bv8dsXMWkmFSAyc4A3KN2taXu1ljZ9WEgfbZZxT5d6OsKNu9kDlNsvlJ/mJmr6fVDjcIO
	mRfC6ZduA9cq+nutxruGBZcNJZc9f33gEryYeYgnaiSH6mNzW/5OKAjUHzJx8/D9NVFjpj1QZ8/
	JWiVwOPPdUP7rN4/Purb3uw=
Received: from mail.maildlp.com (unknown [172.19.163.104])
	by canpmsgout02.his.huawei.com (SkyGuard) with ESMTPS id 4j56K40HlKzcZxr;
	Thu, 15 Oct 2026 20:07:52 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id C1EE34056E;
	Thu, 15 Oct 2026 20:19:56 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:19:51 +0800
From: Cai Xinchen <caixinchen1@huawei.com>
To: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>
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
	<chenxiaosong@chenxiaosong.com>, <kpsingh@kernel.org>, <matt@bobrowski.net>,
	<rostedt@goodmis.org>, <mhiramat@kernel.org>,
	<mathieu.desnoyers@efficios.com>, <john.johansen@canonical.com>,
	<georgia.garcia@canonical.com>, <zohar@linux.ibm.com>,
	<roberto.sassu@huawei.com>, <dmitry.kasatkin@gmail.com>,
	<eric.snowberg@oracle.com>, <stephen.smalley.work@gmail.com>,
	<omosnacek@gmail.com>, <casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@I-love.SAKURA.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
Subject: [PATCH v2 -next 02/18] LSM: pass struct path to the inode_setsecctx hook
Date: Thu, 15 Oct 2026 20:54:08 +0800
Message-ID: <20261015125425.3246251-3-caixinchen1@huawei.com>
X-Mailer: git-send-email 2.18.0.huawei.25
In-Reply-To: <20261015125425.3246251-1-caixinchen1@huawei.com>
References: <20261015125425.3246251-1-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 whupemk100010.china.huawei.com (7.152.184.41)

The inode_setsecctx hook and its security_inode_setsecctx() caller
in fs/nfsd operate on a dentry even though both have a struct path
available.  The SELinux and Smack implementations write the label
through __vfs_setxattr_locked(), whose idmap argument they hardcode
to &nop_mnt_idmap.

Switch the hook to take a const struct path so that the upcoming
conversion of the xattr helpers to struct path can be reflected
directly in the implementations.  For now the implementations keep
passing &nop_mnt_idmap together with path->dentry to
__vfs_setxattr_locked(), preserving the current behavior; they will
be switched to pass the path itself once the xattr helpers take one.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/nfsd/vfs.c                 | 2 +-
 include/linux/lsm_hook_defs.h | 2 +-
 include/linux/security.h      | 4 ++--
 security/security.c           | 6 +++---
 security/selinux/hooks.c      | 6 +++---
 security/smack/smack_lsm.c    | 6 +++---
 6 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0897b132aa74..4598962b397c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -625,7 +625,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			break;
 	}
 	if (attr->na_seclabel && attr->na_seclabel->len)
-		attr->na_labelerr = security_inode_setsecctx(dentry,
+		attr->na_labelerr = security_inode_setsecctx(&path,
 			attr->na_seclabel->data, attr->na_seclabel->len);
 	if (IS_ENABLED(CONFIG_FS_POSIX_ACL) && attr->na_dpacl) {
 		if (!S_ISDIR(inode->i_mode))
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index ef16e5343e09..98ce7c814f01 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -314,7 +314,7 @@ LSM_HOOK(int, 0, secctx_to_secid, const char *secdata, u32 seclen, u32 *secid)
 LSM_HOOK(void, LSM_RET_VOID, release_secctx, struct lsm_context *cp)
 LSM_HOOK(void, LSM_RET_VOID, inode_invalidate_secctx, struct inode *inode)
 LSM_HOOK(int, 0, inode_notifysecctx, struct inode *inode, void *ctx, u32 ctxlen)
-LSM_HOOK(int, 0, inode_setsecctx, struct dentry *dentry, void *ctx, u32 ctxlen)
+LSM_HOOK(int, 0, inode_setsecctx, const struct path *path, void *ctx, u32 ctxlen)
 LSM_HOOK(int, -EOPNOTSUPP, inode_getsecctx, struct inode *inode,
 	 struct lsm_context *cp)
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 8b8d6b8b802f..26996f546ab2 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -589,7 +589,7 @@ int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(struct lsm_context *cp);
 void security_inode_invalidate_secctx(struct inode *inode);
 int security_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen);
-int security_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen);
+int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen);
 int security_inode_getsecctx(struct inode *inode, struct lsm_context *cp);
 int security_locked_down(enum lockdown_reason what);
 int lsm_fill_user_ctx(struct lsm_ctx __user *uctx, u32 *uctx_len,
@@ -1637,7 +1637,7 @@ static inline int security_inode_notifysecctx(struct inode *inode, void *ctx, u3
 {
 	return -EOPNOTSUPP;
 }
-static inline int security_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen)
+static inline int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/security/security.c b/security/security.c
index da8d48cd0a2a..c9fb7c3380ad 100644
--- a/security/security.c
+++ b/security/security.c
@@ -4134,7 +4134,7 @@ EXPORT_SYMBOL(security_inode_notifysecctx);
 
 /**
  * security_inode_setsecctx() - Change the security label of an inode
- * @dentry: inode
+ * @path: inode
  * @ctx: secctx
  * @ctxlen: length of secctx
  *
@@ -4148,9 +4148,9 @@ EXPORT_SYMBOL(security_inode_notifysecctx);
  *
  * Return: Returns 0 on success, error on failure.
  */
-int security_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen)
+int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
-	return call_int_hook(inode_setsecctx, dentry, ctx, ctxlen);
+	return call_int_hook(inode_setsecctx, path, ctx, ctxlen);
 }
 EXPORT_SYMBOL(security_inode_setsecctx);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 51454c411a03..015fc0c01105 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -7173,10 +7173,10 @@ static int selinux_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen
 /*
  *	called with inode->i_mutex locked
  */
-static int selinux_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen)
+static int selinux_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
-	return __vfs_setxattr_locked(&nop_mnt_idmap, dentry, XATTR_NAME_SELINUX,
-				     ctx, ctxlen, 0, NULL);
+	return __vfs_setxattr_locked(&nop_mnt_idmap, path->dentry,
+				     XATTR_NAME_SELINUX, ctx, ctxlen, 0, NULL);
 }
 
 static int selinux_inode_getsecctx(struct inode *inode, struct lsm_context *cp)
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 3524649f402d..953461571026 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -4978,10 +4978,10 @@ static int smack_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen)
 				       ctxlen, 0);
 }
 
-static int smack_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen)
+static int smack_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
-	return __vfs_setxattr_locked(&nop_mnt_idmap, dentry, XATTR_NAME_SMACK,
-				     ctx, ctxlen, 0, NULL);
+	return __vfs_setxattr_locked(&nop_mnt_idmap, path->dentry,
+				     XATTR_NAME_SMACK, ctx, ctxlen, 0, NULL);
 }
 
 static int smack_inode_getsecctx(struct inode *inode, struct lsm_context *cp)
-- 
2.18.0.huawei.25

