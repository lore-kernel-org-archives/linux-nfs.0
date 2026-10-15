Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E21B2525A90;
	Thu, 15 Oct 2026 12:21:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066874; cv=none; b=SjigudkazrO6whQn5OvsPVKNCROdEf6c7w+1MoRqROiEJ1gqe4TeEUmpnjNTXUGoi5mCeiietrQkkAP4wKgbD2tZyoZL2SoZ9GUNXAeORNi/P0Ggrjow0RgEUVLK4U53xMv7XwDEssQWmrOGDhiJ5rMwVd6U0iy3xJcIXarvcH4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066874; c=relaxed/simple;
	bh=xjcDyawFWud+Vcc8yV+UONarnoGB9ypDEuQc6z86+fI=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=aF+KUrk6tO+bVFxNSRD55ruUBzHIg+qxNTbqQv6+Wv40fUsneNVhOF9IUeqfPilFqxkHeEQB6rlKjR6mYn8NYXkusInb/+jOWtt3VpPAaXh5wTN4pxL8kovgfGAmIQilvj8cPnia1UpKWl93rU1NtxquNTwqfvmkP/BzPD/XtGI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=vjZmeLIo; arc=none smtp.client-ip=113.46.200.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="vjZmeLIo"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=Rf8NNOfqBth7RsLUDhhENrebseSUT7uxHB537si5AaI=;
	b=vjZmeLIodL5W+WPZYeyN/cX5Clnn2pIAnOAzkRNYi8cbCot3/t4JCKFSXiLpgRAvHsUJA6ge0
	VYJCLDiNQbvqEQV3Nela8YbresUw5bJC+YUdEPIxYxBSKw5KIMWFm8/BLwazD0MAnnhADx5GDGY
	bBjL3hRq15ze0NmW6CTIPig=
Received: from mail.maildlp.com (unknown [172.19.162.140])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4j56LB4ssMz1prlG;
	Thu, 15 Oct 2026 20:08:50 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 037F4202E6;
	Thu, 15 Oct 2026 20:21:11 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:21:05 +0800
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
Subject: [PATCH v2 -next 17/18] samples/landlock: Add metadata rights to sandboxer
Date: Thu, 15 Oct 2026 20:54:23 +0800
Message-ID: <20261015125425.3246251-18-caixinchen1@huawei.com>
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

Handle the new LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights in the sandboxer:
READ_METADATA is added to the read-only set, WRITE_METADATA to the
read-write set, and both to ACCESS_FILE.

Update the ABI version fallback switch to remove the metadata rights
for ABI < 13, and bump LANDLOCK_ABI_LAST to 13.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 samples/landlock/sandboxer.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/samples/landlock/sandboxer.c b/samples/landlock/sandboxer.c
index 1362f08ff14b..29965ef90bed 100644
--- a/samples/landlock/sandboxer.c
+++ b/samples/landlock/sandboxer.c
@@ -137,6 +137,8 @@ static int parse_path(char *env_path, const char ***const path_list)
 	LANDLOCK_ACCESS_FS_EXECUTE | \
 	LANDLOCK_ACCESS_FS_WRITE_FILE | \
 	LANDLOCK_ACCESS_FS_READ_FILE | \
+	LANDLOCK_ACCESS_FS_READ_METADATA | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA | \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
 	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
 	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
@@ -487,7 +489,8 @@ static bool check_ruleset_scope(const char *const env_var,
 #define ACCESS_FS_ROUGHLY_READ ( \
 	LANDLOCK_ACCESS_FS_EXECUTE | \
 	LANDLOCK_ACCESS_FS_READ_FILE | \
-	LANDLOCK_ACCESS_FS_READ_DIR)
+	LANDLOCK_ACCESS_FS_READ_DIR | \
+	LANDLOCK_ACCESS_FS_READ_METADATA)
 
 #define ACCESS_FS_ROUGHLY_WRITE ( \
 	LANDLOCK_ACCESS_FS_WRITE_FILE | \
@@ -503,7 +506,8 @@ static bool check_ruleset_scope(const char *const env_var,
 	LANDLOCK_ACCESS_FS_REFER | \
 	LANDLOCK_ACCESS_FS_TRUNCATE | \
 	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
-	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
+	LANDLOCK_ACCESS_FS_RESOLVE_UNIX | \
+	LANDLOCK_ACCESS_FS_WRITE_METADATA)
 
 /* clang-format on */
 
@@ -570,7 +574,7 @@ static int add_quiet_access(const char *const env_var,
 	return 0;
 }
 
-#define LANDLOCK_ABI_LAST 12
+#define LANDLOCK_ABI_LAST 13
 
 #define XSTR(s) #s
 #define STR(s) XSTR(s)
@@ -780,6 +784,12 @@ int main(const int argc, char *const argv[], char *const *const envp)
 		ruleset_attr.handled_permissions &=
 			~(LANDLOCK_PERMISSION_NAMESPACE_USE |
 			  LANDLOCK_PERMISSION_CAPABILITY_USE);
+		__attribute__((fallthrough));
+	case 12:
+		/* Removes metadata rights for ABI < 13 */
+		ruleset_attr.handled_access_fs &=
+			~(LANDLOCK_ACCESS_FS_READ_METADATA |
+			  LANDLOCK_ACCESS_FS_WRITE_METADATA);
 		/* Must be printed for any ABI < LANDLOCK_ABI_LAST. */
 		fprintf(stderr,
 			"Hint: You should update the running kernel "
-- 
2.18.0.huawei.25

