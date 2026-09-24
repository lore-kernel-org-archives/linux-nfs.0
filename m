Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F6A74749CB;
	Thu, 24 Sep 2026 10:23:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.226
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245393; cv=none; b=EzgLuf+5nLKbHEGKWqVjzr56LyWek0FACYpMgAeFgNfp5N2FB6fqRsxxk9m6viXmX5VTqTnOrre/HAdBvTvqECyDeYwxXLLiICVDJip1oSzbl40PypaGWc/lELlz82gcT3MNnXaD96/ih4Z/LfDEOZcWAHd4Qj9f5P1gFyaXndI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245393; c=relaxed/simple;
	bh=VeWUWRSnBxHKKDcRUQ550bHJrpkTNvy2BtO+ZCcCH18=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=IjqwZKFZeWtMKlCWAms/ByKzM0NC6yM/L2EKEKsnAf8TwN9kSsHpuGEEtrjrBbksJQwP8mTrUjWxn+ywkINGtKc8eel+6XHTh/gpXSysGEy3msS6AuglKei8T3ySHfP74VOF+iBix5xKrALWi9MwKSjZvKBwf70L+1t3KyoJEuE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=gBApezkF; arc=none smtp.client-ip=113.46.200.226
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="gBApezkF"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=ZwaDNZNV6bX2xJkx/JZuqpyIL+4SAOfyAuv9CJN8pY0=;
	b=gBApezkF4n1I6Dvzs8V8RqXpFsrsvYgGFheQ98U34b/kt9tSLvkq4jWjWQJbWwqbp7Yh3cOph
	kqRtXNnJ3WC4k4JSC7BD7geHHNFNr5BpMcdo2yotihr9e7FPze9onTj4wN85fCps7+/pFJLRW/d
	FENCCFz1puiVjql+cAWaoBI=
Received: from mail.maildlp.com (unknown [172.19.163.163])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4hr8ky578lzKm5t;
	Thu, 24 Sep 2026 18:11:54 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 0468D4048B;
	Thu, 24 Sep 2026 18:23:02 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:22:57 +0800
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
Subject: [PATCH RFC -next 08/12] landlock: Add READ_METADATA and WRITE_METADATA access rights
Date: Thu, 24 Sep 2026 18:48:27 +0800
Message-ID: <20260924104831.1081137-9-caixinchen1@huawei.com>
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

Add two new filesystem access rights to control file metadata access:

- LANDLOCK_ACCESS_FS_READ_METADATA: Read file or directory metadata
  (e.g. inode attributes, extended attributes and POSIX ACLs) through
  stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
  friends, listxattr(2) and friends, and the POSIX ACL read
  operations.
- LANDLOCK_ACCESS_FS_WRITE_METADATA: Change file or directory
  metadata through chmod(2) and friends, chown(2) and friends,
  utimensat(2) and friends, setxattr(2) and friends, removexattr(2)
  and friends, and the POSIX ACL set and remove operations.

This follows the coarse-grained grouping approach discussed in the
mailing list [1], where file metadata operations are grouped by
security relevance rather than by individual syscall.

Remove stat(2), chmod(2), chown(2), setxattr(2) and utime(2) from the
list of file-related actions that cannot be restricted yet, and add
the names of the new rights to _LANDLOCK_ACCESS_FS_NAMES in
include/linux/landlock.h, which is shared by audit records and trace
events, so that denied accesses can be reported with a human-readable
name and the static assertion on fs_access_strings in
security/landlock/audit.c stays valid.

Increment the Landlock ABI version from 11 to 12, and update the ABI
version check in tools/testing/selftests/landlock/base_test.c
accordingly.

[1]
https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 include/linux/landlock.h                     |  4 ++-
 include/uapi/linux/landlock.h                | 26 +++++++++++++++++---
 security/landlock/limits.h                   |  2 +-
 security/landlock/syscalls.c                 |  2 +-
 tools/testing/selftests/landlock/base_test.c |  2 +-
 5 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/include/linux/landlock.h b/include/linux/landlock.h
index 004cbd0b9298..86fc2181ab24 100644
--- a/include/linux/landlock.h
+++ b/include/linux/landlock.h
@@ -39,7 +39,9 @@
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_REFER, "refer"), \
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_TRUNCATE, "truncate"), \
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_IOCTL_DEV, "ioctl_dev"), \
-	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_RESOLVE_UNIX, "resolve_unix")
+	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_RESOLVE_UNIX, "resolve_unix"), \
+	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_READ_METADATA, "read_metadata"), \
+	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_WRITE_METADATA, "write_metadata")
 
 #define _LANDLOCK_ACCESS_NET_NAMES \
 	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_NET_BIND_TCP, "bind_tcp"), \
diff --git a/include/uapi/linux/landlock.h b/include/uapi/linux/landlock.h
index cceda3b3b961..40d64e8b5e2d 100644
--- a/include/uapi/linux/landlock.h
+++ b/include/uapi/linux/landlock.h
@@ -343,6 +343,24 @@ struct landlock_net_port_attr {
  *
  *   The rationale for this design is described in
  *   :ref:`Documentation/security/landlock.rst <scoped-flags-interaction>`.
+ * - %LANDLOCK_ACCESS_FS_READ_METADATA: Read file or directory metadata (e.g.
+ *   inode attributes, extended attributes, and POSIX ACLs) through
+ *   :manpage:`stat(2)`, :manpage:`fstat(2)`, :manpage:`lstat(2)`,
+ *   :manpage:`newfstatat(2)`, :manpage:`getxattr(2)`, and
+ *   :manpage:`listxattr(2)`.
+ *
+ *   This access right is available since the twelfth version of the Landlock
+ *   ABI.
+ * - %LANDLOCK_ACCESS_FS_WRITE_METADATA: Change file or directory metadata
+ *   (e.g. inode attributes, extended attributes, and POSIX ACLs) through
+ *   :manpage:`chmod(2)`, :manpage:`chown(2)`, :manpage:`utimensat(2)`,
+ *   :manpage:`setxattr(2)`, and :manpage:`removexattr(2)`, as well as related
+ *   system calls.  Implicit metadata changes performed by the kernel (e.g.
+ *   timestamp updates with :manpage:`write(2)`) are not restricted by this
+ *   access right.
+ *
+ *   This access right is available since the twelfth version of the Landlock
+ *   ABI.
  *
  * Whether an opened file can be truncated with :manpage:`ftruncate(2)` or used
  * with `ioctl(2)` is determined during :manpage:`open(2)`, in the same way as
@@ -406,10 +424,8 @@ struct landlock_net_port_attr {
  * .. warning::
  *
  *   It is currently not possible to restrict some file-related actions
- *   accessible through these syscall families: :manpage:`chdir(2)`,
- *   :manpage:`stat(2)`, :manpage:`flock(2)`, :manpage:`chmod(2)`,
- *   :manpage:`chown(2)`, :manpage:`setxattr(2)`, :manpage:`utime(2)`,
- *   :manpage:`fcntl(2)`, :manpage:`access(2)`.
+ *   accessible through these syscall families: :manpage:`chdir(2)',
+ *   :manpage:`flock(2)', :manpage:`fcntl(2)', :manpage:`access(2)'.
  *   Future Landlock evolutions will enable to restrict them.
  */
 /* clang-format off */
@@ -430,6 +446,8 @@ struct landlock_net_port_attr {
 #define LANDLOCK_ACCESS_FS_TRUNCATE			(1ULL << 14)
 #define LANDLOCK_ACCESS_FS_IOCTL_DEV			(1ULL << 15)
 #define LANDLOCK_ACCESS_FS_RESOLVE_UNIX			(1ULL << 16)
+#define LANDLOCK_ACCESS_FS_READ_METADATA		(1ULL << 17)
+#define LANDLOCK_ACCESS_FS_WRITE_METADATA		(1ULL << 18)
 /* clang-format on */
 
 /**
diff --git a/security/landlock/limits.h b/security/landlock/limits.h
index 1a7c5fb8f6fd..665ff238bd27 100644
--- a/security/landlock/limits.h
+++ b/security/landlock/limits.h
@@ -19,7 +19,7 @@
 #define LANDLOCK_MAX_NUM_LAYERS		16
 #define LANDLOCK_MAX_NUM_RULES		U32_MAX
 
-#define LANDLOCK_LAST_ACCESS_FS		LANDLOCK_ACCESS_FS_RESOLVE_UNIX
+#define LANDLOCK_LAST_ACCESS_FS		LANDLOCK_ACCESS_FS_WRITE_METADATA
 #define LANDLOCK_MASK_ACCESS_FS		((LANDLOCK_LAST_ACCESS_FS << 1) - 1)
 #define LANDLOCK_NUM_ACCESS_FS		__const_hweight64(LANDLOCK_MASK_ACCESS_FS)
 
diff --git a/security/landlock/syscalls.c b/security/landlock/syscalls.c
index 400a2f928de3..205d64c534d7 100644
--- a/security/landlock/syscalls.c
+++ b/security/landlock/syscalls.c
@@ -172,7 +172,7 @@ static const struct file_operations ruleset_fops = {
  * If the change involves a fix that requires userspace awareness, also update
  * the errata documentation in Documentation/userspace-api/landlock.rst .
  */
-const int landlock_abi_version = 11;
+const int landlock_abi_version = 12;
 
 /**
  * sys_landlock_create_ruleset - Create a new ruleset
diff --git a/tools/testing/selftests/landlock/base_test.c b/tools/testing/selftests/landlock/base_test.c
index d20ab8f0862c..58fe322d8637 100644
--- a/tools/testing/selftests/landlock/base_test.c
+++ b/tools/testing/selftests/landlock/base_test.c
@@ -76,7 +76,7 @@ TEST(abi_version)
 	const struct landlock_ruleset_attr ruleset_attr = {
 		.handled_access_fs = LANDLOCK_ACCESS_FS_READ_FILE,
 	};
-	ASSERT_EQ(11, landlock_create_ruleset(NULL, 0,
+	ASSERT_EQ(12, landlock_create_ruleset(NULL, 0,
 					      LANDLOCK_CREATE_RULESET_VERSION));
 
 	ASSERT_EQ(-1, landlock_create_ruleset(&ruleset_attr, 0,
-- 
2.18.0.huawei.25

