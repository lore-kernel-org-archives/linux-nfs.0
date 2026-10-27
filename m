Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.216
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101156;
	b=EsmWmTeeanEspkkTGcQQNJGEjMnZ4XLxsBWFmWHtUjkVjC2KS3gyze5nKmSAqSZeBHcf
	 UlPnjo/Kk2AICtWkYyJs9fYaD3oY2/JUpS9XnhRnXDot34jw9louc0AyDrnYLs7u/spB0
	 LPzeERJqvA5taxBPMCUwoz2pt7ipQMbVaBHK5As2WwykKVPyXuYUaUGj2rpJKPEuVl5t2
	 Hl14RIsQupxBU+O2icsVt/9KBcQLr/wXOJJ98LLkHQVV0CHwElkvO09SGAxrKHdoNYCdN
	 qUD77+614i7JkMIyna00+CedUQY0bm6IlY9fyi6pgbb1jDuLfPGStkJfToLVmEXzBTg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101156;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=pbtF9rHOBMB76Zrz7Y2+clA84G2qSGU1yDHvsoJ3Byk=;
	b=umJg8ZdOVTE/iT2nsnDMOobKMsBoSc00fvHTO3mY/zWu8lDopFmA3xf3g0HKAXtxaIZz
	 2LwdEjin0iLsZxMUJ+5cw8tRHURC9adV52VtYsoAkJ4xLAPQ01IfRf9FOuaIctCCJzt1t
	 iBtGo1g9TtmZh2rB1R02v/9J8szakuipdjczpaCd7lx8cNjvh5DoKD+eZnvZIrw7jnkcT
	 ZuaPtNqsNuOGokF4Z6c+I71MGJ7hTehqWS0g+ZJy3dBehyw+PHAIOqD5jxs6Acohe6qpR
	 uh0lg1JLVhwxwLlw53Fur8ZgBVDcCyqpIqh9MSjHPKs1TAU9eiVno9u3a2r7peS2zvw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=iGtuxZLm;
	arc=none smtp.remote-ip=113.46.200.216
Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A44C1606A329;
	Tue, 27 Oct 2026 11:39:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A44C1606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=iGtuxZLm
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=pbtF9rHOBMB76Zrz7Y2+clA84G2qSGU1yDHvsoJ3Byk=;
	b=iGtuxZLm4EpMl/0QJL+e3PpLOHmpOizN9lihGl/Ajtg2/cG20t9R7s0iT6wOd+U6aqa65BWDp
	/Q90U+dHJyViooI3rOWF/ZEGJq1Hd+sEnoXkX7l6d5ZE3YuUF8F15ysI7w57ahz3SVLmqyA+Mws
	/TXMFA+SkiNNl2Y0Wl0QGwc=
Received: from mail.maildlp.com (unknown [172.19.162.197])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4jDT6J5k81z1T4G1;
	Tue, 27 Oct 2026 19:39:04 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 276E24057D;
	Tue, 27 Oct 2026 19:39:13 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:39:07 +0800
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
Subject: [PATCH v3 -next 14/18] LSM: rename inode_setsecctx to path_setsecctx
Date: Tue, 27 Oct 2026 20:11:47 +0800
Message-ID: <20261027121151.1887650-15-caixinchen1@huawei.com>
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

The inode_setsecctx hook receives a struct path, so rename it to
path_setsecctx to follow the path_* naming convention used for the
other hooks that take a struct path (path_chmod, path_chown, ...).
Rename the security_inode_setsecctx() inline wrapper to
security_path_setsecctx() and the SELinux and Smack implementations
accordingly.

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
index 870756842882..3362ac3e1a41 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -628,7 +628,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			break;
 	}
 	if (attr->na_seclabel && attr->na_seclabel->len)
-		attr->na_labelerr = security_inode_setsecctx(&path,
+		attr->na_labelerr = security_path_setsecctx(&path,
 			attr->na_seclabel->data, attr->na_seclabel->len);
 	if (IS_ENABLED(CONFIG_FS_POSIX_ACL) && attr->na_dpacl) {
 		if (!S_ISDIR(inode->i_mode))
diff --git a/include/linux/lsm_hook_defs.h b/include/linux/lsm_hook_defs.h
index 683c4d7a8024..5b25077d17e5 100644
--- a/include/linux/lsm_hook_defs.h
+++ b/include/linux/lsm_hook_defs.h
@@ -334,7 +334,7 @@ LSM_HOOK(int, 0, inode_notifysecctx, struct inode *inode, void *ctx, u32 ctxlen)
  * taking a struct path; the VFS makes no guarantees with regard to
  * @path->mnt.
  */
-LSM_HOOK(int, 0, inode_setsecctx, const struct path *path, void *ctx, u32 ctxlen)
+LSM_HOOK(int, 0, path_setsecctx, const struct path *path, void *ctx, u32 ctxlen)
 LSM_HOOK(int, -EOPNOTSUPP, inode_getsecctx, struct inode *inode,
 	 struct lsm_context *cp)
 
diff --git a/include/linux/security.h b/include/linux/security.h
index edba134db8f6..cf683b89737b 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -597,7 +597,7 @@ int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(struct lsm_context *cp);
 void security_inode_invalidate_secctx(struct inode *inode);
 int security_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen);
-int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen);
+int security_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen);
 int security_inode_getsecctx(struct inode *inode, struct lsm_context *cp);
 int security_locked_down(enum lockdown_reason what);
 int lsm_fill_user_ctx(struct lsm_ctx __user *uctx, u32 *uctx_len,
@@ -1649,7 +1649,7 @@ static inline int security_inode_notifysecctx(struct inode *inode, void *ctx, u3
 {
 	return -EOPNOTSUPP;
 }
-static inline int security_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
+static inline int security_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/security/security.c b/security/security.c
index 919763c61994..fa14bf5dd036 100644
--- a/security/security.c
+++ b/security/security.c
@@ -4131,7 +4131,7 @@ int security_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen)
 EXPORT_SYMBOL(security_inode_notifysecctx);
 
 /**
- * security_inode_setsecctx() - Change the security label of an inode
+ * security_path_setsecctx() - Change the security label of an inode
  * @path: inode (the VFS makes no guarantees with regard to @path->mnt)
  * @ctx: secctx
  * @ctxlen: length of secctx
@@ -4146,11 +4146,11 @@ EXPORT_SYMBOL(security_inode_notifysecctx);
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
index 8bafa530806e..cd04b09a8a7d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -7157,7 +7157,7 @@ static int selinux_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen
 /*
  *	called with inode->i_mutex locked
  */
-static int selinux_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
+static int selinux_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
 	return __vfs_setxattr_locked(&nop_mnt_idmap, path, XATTR_NAME_SELINUX,
 				     ctx, ctxlen, 0, NULL, NULL);
@@ -7831,7 +7831,7 @@ static struct security_hook_list selinux_hooks[] __ro_after_init = {
 	LSM_HOOK_INIT(release_secctx, selinux_release_secctx),
 	LSM_HOOK_INIT(inode_invalidate_secctx, selinux_inode_invalidate_secctx),
 	LSM_HOOK_INIT(inode_notifysecctx, selinux_inode_notifysecctx),
-	LSM_HOOK_INIT(inode_setsecctx, selinux_inode_setsecctx),
+	LSM_HOOK_INIT(path_setsecctx, selinux_path_setsecctx),
 
 	LSM_HOOK_INIT(unix_stream_connect, selinux_socket_unix_stream_connect),
 	LSM_HOOK_INIT(unix_may_send, selinux_socket_unix_may_send),
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 95a048bcf3a6..b3475253e879 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -4998,7 +4998,7 @@ static int smack_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen)
 				       ctxlen, 0);
 }
 
-static int smack_inode_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
+static int smack_path_setsecctx(const struct path *path, void *ctx, u32 ctxlen)
 {
 	return __vfs_setxattr_locked(&nop_mnt_idmap, path, XATTR_NAME_SMACK,
 				     ctx, ctxlen, 0, NULL, NULL);
@@ -5323,7 +5323,7 @@ static struct security_hook_list smack_hooks[] __ro_after_init = {
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

