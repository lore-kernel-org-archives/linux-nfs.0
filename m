Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6C55483823;
	Thu, 24 Sep 2026 10:23:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.224
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245406; cv=none; b=OpZuNxumm8ZX/jY88Ce9KFZTE76mnv8v0BJbcq8n1P6VJm1+5izeQKsJDfpyXK5DjhTzTQ3xs90RTztpbjQy6s+Md/ZQb8OIBHGL4o6LdBX2wk0+vXOTa/TabH8/qkBbS3ARkfa0FM0Cng0JGOJfobTB+YqKcCaCb65C2aPa7ro=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245406; c=relaxed/simple;
	bh=Ma+7vQ49a/OV6U+OzRcoEE2UvhGUYJLDvCh/irabEzA=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=H6ENKPumIsdz8rG2F/uogr4K1d9+wq1TDkcUC6q1fJ3h5GumXoPi9YjUjUcK8KqyNz1tGthMjIxEQycq23Zq9Rb1wBOMOjMrX3DWYkEYdt6scH9R0+4v+4PJ9D9MyGVH2QC8Es8ej8G6JzZoXf8k0JGb9gSUesC5CEmX3NaFsV8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=3G0G2bcn; arc=none smtp.client-ip=113.46.200.224
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="3G0G2bcn"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=s454HcCeb+dSDfnoAkpf7M/xsIsKD5YvOJGrwmLEfrI=;
	b=3G0G2bcnL+mWyuOQ4kleYffDy7gL7uqE8/bVI772g7BFvep7BMkvVhmGU+42CLzJ8b5AULFs4
	TPEBJ1wZWwHng+pNUNprsSIT0TO9rBlEU+YGOTXKbKcnruSDqmXfNld+v+Eto6U6FVfxjheUXkS
	9ZOMdH13EA6QSRkos5mOux4=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4hr8lH4XQmz1cyVb;
	Thu, 24 Sep 2026 18:12:11 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 94BE04057C;
	Thu, 24 Sep 2026 18:23:14 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:23:10 +0800
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
Subject: [PATCH RFC -next 11/12] samples/landlock: Add metadata rights to sandboxer
Date: Thu, 24 Sep 2026 18:48:30 +0800
Message-ID: <20260924104831.1081137-12-caixinchen1@huawei.com>
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

Handle the new LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights in the sandboxer:
READ_METADATA is added to the read-only set, WRITE_METADATA to the
read-write set, and both to ACCESS_FILE.

Update the ABI version fallback switch to remove the metadata rights
for ABI < 12, and bump LANDLOCK_ABI_LAST to 12.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 samples/landlock/sandboxer.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/samples/landlock/sandboxer.c b/samples/landlock/sandboxer.c
index 030583273f3f..1a77a675f654 100644
--- a/samples/landlock/sandboxer.c
+++ b/samples/landlock/sandboxer.c
@@ -115,6 +115,8 @@ static int parse_path(char *env_path, const char ***const path_list)
 	LANDLOCK_ACCESS_FS_EXECUTE | \
 	LANDLOCK_ACCESS_FS_WRITE_FILE | \
 	LANDLOCK_ACCESS_FS_READ_FILE | \
+	LANDLOCK_ACCESS_FS_READ_METADATA | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA | \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
 	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
 	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
@@ -286,7 +288,8 @@ static bool check_ruleset_scope(const char *const env_var,
 #define ACCESS_FS_ROUGHLY_READ ( \
 	LANDLOCK_ACCESS_FS_EXECUTE | \
 	LANDLOCK_ACCESS_FS_READ_FILE | \
-	LANDLOCK_ACCESS_FS_READ_DIR)
+	LANDLOCK_ACCESS_FS_READ_DIR | \
+	LANDLOCK_ACCESS_FS_READ_METADATA)
 
 #define ACCESS_FS_ROUGHLY_WRITE ( \
 	LANDLOCK_ACCESS_FS_WRITE_FILE | \
@@ -302,7 +305,8 @@ static bool check_ruleset_scope(const char *const env_var,
 	LANDLOCK_ACCESS_FS_REFER | \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
 	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
-	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
+	LANDLOCK_ACCESS_FS_RESOLVE_UNIX | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA)
 
 /* clang-format on */
 
@@ -369,7 +373,7 @@ static int add_quiet_access(const char *const env_var,
 	return 0;
 }
 
-#define LANDLOCK_ABI_LAST 11
+#define LANDLOCK_ABI_LAST 12
 
 #define XSTR(s) #s
 #define STR(s) XSTR(s)
@@ -552,7 +556,12 @@ int main(const int argc, char *const argv[], char *const *const envp)
 		supported_restrict_flags &=
 			~LANDLOCK_RESTRICT_SELF_NO_NEW_PRIVS;
 		set_restrict_flags &= ~LANDLOCK_RESTRICT_SELF_NO_NEW_PRIVS;
-
+		__attribute__((fallthrough));
+	case 11:
+		/* Removes metadata rights for ABI < 12 */
+		ruleset_attr.handled_access_fs &=
+			~(LANDLOCK_ACCESS_FS_READ_METADATA |
+			  LANDLOCK_ACCESS_FS_WRITE_METADATA);
 		/* Must be printed for any ABI < LANDLOCK_ABI_LAST. */
 		fprintf(stderr,
 			"Hint: You should update the running kernel "
-- 
2.18.0.huawei.25

