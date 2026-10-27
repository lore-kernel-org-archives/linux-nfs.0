Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101172;
	b=NYLOH0CUUFVlw7dSAPEiWPApLJkOGS444tootSDNwYcNtbBnEmeYlgNaJFK0RUbX8LrD
	 4CZDRR6SFGpHjTy8R/CHi5BI7Ck5Lb7WKD7isGwPRn8fp4VbYZ9RCp60DE49jx2lcPQjx
	 IdNOqtT6B2nmPvB8E/hi5kkW5Go0VEQHvPQ62/ed6TcLn9xzRc7KdRklEk78wf75gdQFJ
	 vgbiZrb2UFGhM9ry1AJBzyqSGsigUQ7WSkPZ3i03mkeBjPsY2nAMbCCJkHM+6r2woVsnu
	 KbOO0joN4X1dHs30lflvmXYZpbtYKeBkedg+moSpgid3rzT5R9u1mTPgyCJK0JwYsvg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101172;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=4gnQWBth/c177Bb08YOlMXVK4RtND6n6IeYO3twMeyU=;
	b=XOZDy4W0pK9L9C5znw4HKXNBnd+uBjEdq5Bt5/3RNkMjX+goV2MjdmQJSvwIXZy9lqcs
	 iZ1ezqffof3Bk/GLmDC8VgA4t8UbgQ8Oy4V3/bOPB9T6zZLJtNKXXYaXzaGmFXEqaxMPH
	 bKl+iXKLKmUZjIM9ASQtk+bDqcBCyuh+DWhPHVprtjZjbiddpxRKWpzTnVipPP3gaWgdT
	 /C6kRoD+BTqjCzd3u8CkHVDOY2UlcNaMsBxIRTI09hm1FPiLjzaosYjXK17USNVwChr+v
	 0COAud3cqUoej3crRONL/T3OwgzDSXRdg7xCkpdAapGWWjJW0ClSk2FnVbnrXXPFBdQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=G1SVNDWK;
	arc=none smtp.remote-ip=113.46.200.227
Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3C1860A6F6A;
	Tue, 27 Oct 2026 11:39:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A3C1860A6F6A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=G1SVNDWK
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=4gnQWBth/c177Bb08YOlMXVK4RtND6n6IeYO3twMeyU=;
	b=G1SVNDWKcr2QNUjgbDuLk2jxeAvYkuwkX30tA9oqTeZ9bxwp8KDbS69GSj1q9vmV4sEvUVlQJ
	exZ/ffSO072HZRgGFDNZn4Cz6xPeMgbwA5WACDIBNiJxd63MLTs9hqd7q7iB8W9AF+yFvmrW9c1
	OfYeTX7VY/CksdLR+h2BeMI=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4jDT6s6LwDznTZW;
	Tue, 27 Oct 2026 19:39:33 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 9DBE64055B;
	Tue, 27 Oct 2026 19:39:28 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:39:23 +0800
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
Subject: [PATCH v3 -next 17/18] samples/landlock: Add metadata rights to sandboxer
Date: Tue, 27 Oct 2026 20:11:50 +0800
Message-ID: <20261027121151.1887650-18-caixinchen1@huawei.com>
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

Handle the new LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights in the sandboxer:
READ_METADATA is added to the read-only set, WRITE_METADATA to the
read-write set, and both to ACCESS_FILE.

Update the ABI version fallback switch to remove the metadata rights
for ABI < 13, and bump LANDLOCK_ABI_LAST to 13.

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

