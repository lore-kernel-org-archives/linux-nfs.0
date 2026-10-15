Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7FD6153F6BB;
	Thu, 15 Oct 2026 12:21:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.224
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066865; cv=none; b=TEO/5q8CVDalVgZpbSzLZw9e0gJfiDLhxijtR8B4HVi2yPeqXCpmRg7yoBQ1GZ6ih2KAyOY852E8ZRoGijErazfs46PMb3VnwUc3RJWw2ETunz1pWbJsNKAlztaWZLbKSJXSPiPIQi7w5ymFNr55ybSngHeyZEBERJVnZ19+5u0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066865; c=relaxed/simple;
	bh=vzSk1hkCBB2Si5bKndDTPtCeBP9TM323K5gVS9xwlHw=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=eaD3NBc8ootol04OYTPx7S1Fv3yKOE77SFvbO4CTSbttInfz/mfPVk520cy0Fz1n1Nd/fzvCs4s8axjKkh0qd0mV569a5MVuHUEi5weGdfJhVE4xJM2el+7PrEhZO1B6FskNHJqfL3jS5SVaCaa7CAVprz+jvpmux/z1SdVxFpY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=o0Tunk7h; arc=none smtp.client-ip=113.46.200.224
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="o0Tunk7h"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=sJY89/HYXvFn1NYtcEsFWVfGcjoXxbX7WoUsKZic8+Q=;
	b=o0Tunk7hSnUi5PDhZAG65lVnaxeXAxUzEYhozW1ObDAwMgWzpL5wDDGIfqLLirHXm6YojQksd
	Eipzp/Se1Db1ak8ocfkKrq7Ef9pktnT1l9EagT/D2eMevIvNACUfWo0wvmKF7pHx/llgsVx3G5h
	zyky8NR1cg23r59xfO5jXRE=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4j56MF1878z1cyS5;
	Thu, 15 Oct 2026 20:09:45 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 1D44940572;
	Thu, 15 Oct 2026 20:21:01 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:20:55 +0800
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
Subject: [PATCH v2 -next 15/18] LSM: rename inode_setsecctx to path_setsecctx
Date: Thu, 15 Oct 2026 20:54:21 +0800
Message-ID: <20261015125425.3246251-16-caixinchen1@huawei.com>
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

The inode_setsecctx hook receives a struct path, so rename it to
path_setsecctx to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_setsecctx() inline wrapper to
security_path_setsecctx() and the SELinux and Smack implementations
accordingly.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 fs/nfsd/vfs.c                 | 2 +-
 include/linux/lsm_hook_defs.h | 2 +-
 include/linux/security.h      | 4 ++--
 security/security.c           | 8 ++++----
 security/selinux/hooks.c      | 4 ++--
 security/smack/smack_lsm.c    | 4 ++--
 6 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5ae540bf0b9a..eb7dee641612 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -627,7 +627,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			break;
 	}
 	if (attr->na_seclabel && attr->na_seclabel->len)
-		attr->na_labelerr = security_inode_setsecctx(&path,
+		attr->na_labelerr = security_path_setsecctx(&path,
 			attr->na_seclabel->data, attr->na_seclabel->len);
 	if (IS_ENABLED(CONFIG_FS_POSIX_ACL) && attr->na_dpacl) {
 		if (!S_ISDIR(inode->i_mode))
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index da490923cdcd..9ea096505ef1 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -315,7 +315,7 @@ LSM_HOOK(int, 0, secctx_to_secid, const char *secdata, u32 seclen, u32 *secid)
 LSM_HOOK(void, LSM_RET_VOID, release_secctx, struct lsm_context *cp)
 LSM_HOOK(void, LSM_RET_VOID, inode_invalidate_secctx, struct inode *inode)
 LSM_HOOK(int, 0, inode_notifysecctx, struct inode *inode, void *ctx, u32 ctxlen)
-LSM_HOOK(int, 0, inode_setsecctx, const struct path *path, void *ctx, u32 ctxlen)
+LSM_HOOK(int, 0, path_setsecctx, const struct path *path, void *ctx, u32 ctxlen)
 LSM_HOOK(int, -EOPNOTSUPP, inode_getsecctx, struct inode *inode,
 	 struct lsm_context *cp)
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 4f1c26c75093..c99a050595c5 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -584,7 +584,7 @@ int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(struct lsm_context *cp);
 void security_inode_invalidate_secctx(struct inode *inode);
 int security_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen);
-int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen);
+int security_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen);
 int security_inode_getsecctx(struct inode *inode, struct lsm_context *cp);
 int security_locked_down(enum lockdown_reason what);
 int lsm_fill_user_ctx(struct lsm_ctx __user *uctx, u32 *uctx_len,
@@ -1626,7 +1626,7 @@ static inline int security_inode_notifysecctx(struct inode *inode, void *ctx, u3
 {
 	return -EOPNOTSUPP;
 }
-static inline int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
+static inline int security_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/security/security.c b/security/security.c
index f04a7bb311ea..7c17300989b6 100644
--- a/security/security.c
+++ b/security/security.c
@@ -4122,7 +4122,7 @@ int security_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen)
 EXPORT_SYMBOL(security_inode_notifysecctx);
 
 /**
- * security_inode_setsecctx() - Change the security label of an inode
+ * security_path_setsecctx() - Change the security label of an inode
  * @path: inode
  * @ctx: secctx
  * @ctxlen: length of secctx
@@ -4137,11 +4137,11 @@ EXPORT_SYMBOL(security_inode_notifysecctx);
  *
  * Return: Returns 0 on success, error on failure.
  */
-int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
+int security_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
-	return call_int_hook(inode_setsecctx, path, ctx, ctxlen);
+	return call_int_hook(path_setsecctx, path, ctx, ctxlen);
 }
-EXPORT_SYMBOL(security_inode_setsecctx);
+EXPORT_SYMBOL(security_path_setsecctx);
 
 /**
  * security_inode_getsecctx() - Get the security label of an inode
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index ee0d6c12de37..81b7be7181e7 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -7176,7 +7176,7 @@ static int selinux_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen
 /*
  *	called with inode->i_mutex locked
  */
-static int selinux_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
+static int selinux_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
 	return __vfs_setxattr_locked(path, XATTR_NAME_SELINUX,
 				     ctx, ctxlen, 0, NULL);
@@ -7851,7 +7851,7 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(release_secctx, selinux_release_secctx),
 	LSM_HOOK_INIT(inode_invalidate_secctx, selinux_inode_invalidate_secctx),
 	LSM_HOOK_INIT(inode_notifysecctx, selinux_inode_notifysecctx),
-	LSM_HOOK_INIT(inode_setsecctx, selinux_inode_setsecctx),
+	LSM_HOOK_INIT(path_setsecctx, selinux_path_setsecctx),
 
 	LSM_HOOK_INIT(unix_stream_connect, selinux_socket_unix_stream_connect),
 	LSM_HOOK_INIT(unix_may_send, selinux_socket_unix_may_send),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 1a1e9f11939e..43f407ae007f 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -4978,7 +4978,7 @@ static int smack_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen)
 				       ctxlen, 0);
 }
 
-static int smack_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
+static int smack_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
 	return __vfs_setxattr_locked(path, XATTR_NAME_SMACK,
 				     ctx, ctxlen, 0, NULL);
@@ -5303,7 +5303,7 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(lsmprop_to_secctx, smack_lsmprop_to_secctx),
 	LSM_HOOK_INIT(secctx_to_secid, smack_secctx_to_secid),
 	LSM_HOOK_INIT(inode_notifysecctx, smack_inode_notifysecctx),
-	LSM_HOOK_INIT(inode_setsecctx, smack_inode_setsecctx),
+	LSM_HOOK_INIT(path_setsecctx, smack_path_setsecctx),
 	LSM_HOOK_INIT(inode_getsecctx, smack_inode_getsecctx),
 	LSM_HOOK_INIT(inode_copy_up, smack_inode_copy_up),
 	LSM_HOOK_INIT(inode_copy_up_xattr, smack_inode_copy_up_xattr),
-- 
2.18.0.huawei.25

