Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C861D471408;
	Thu, 24 Sep 2026 10:23:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.224
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790245410; cv=none; b=LTgZPvkeN30iMar9Af9nLKyjrXU5eH1JtmU0w9d0ub0wFiC42DB2R+KOgAR3p3PF8gThJJkUXlGdg/+QQqLJgFN27vRXa91Rp1rzS3UveM21pVh8FOhALQQwiYgk6gJHT7paOwVQqHfJBqx1AQ5Nh4E1AL74wSgBN2ua3+GufCg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790245410; c=relaxed/simple;
	bh=N9GNT5Gr77tnZpa1DIFKdP6tlc1V/iDCYmqnSrwJd4M=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ZBdF5QZ4BvHzjcyQFfMtjg4F9ch2JTA/RYD6T8xrgPwaLG5W78hl/GpRBquLhG8jTcHAGSmZDXGjTd8im3bp2yvt1ElkYAkpe1OzTHUa2AVnaabvCvvv61UN6IvQGg+rEILcF02v7RBPrKXVJXIt5Bjz0XO2xmhUTaFnXRmVmYw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=KojgF+/C; arc=none smtp.client-ip=113.46.200.224
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="KojgF+/C"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=WplCFr0Ls1VpRS9r4EdhOkQGGZvquUDe0yNKbhY/NCY=;
	b=KojgF+/CS9kWlkRdNlF4xuRQ5V2F3k2F35yAWV4kuAlG5XZVUZIVOkLhqZC9+Fw+ibeb6Xuxz
	wFGRVGNp/ebDt4Ncc3JLEUvjx1y/flsc3RltibM0z6jU4VDvmIsIlJFHfoHKT7GXRM3IWlraVyc
	pHCciaYm2G1G4Z9Sf1aw0Mo=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4hr8lM6LmWz1cyPY;
	Thu, 24 Sep 2026 18:12:15 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id D49BB4057C;
	Thu, 24 Sep 2026 18:23:18 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 24 Sep 2026 18:23:14 +0800
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
Subject: [PATCH RFC -next 12/12] Documentation: Update landlock doc for metadata rights
Date: Thu, 24 Sep 2026 18:48:31 +0800
Message-ID: <20260924104831.1081137-13-caixinchen1@huawei.com>
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

Update the user space documentation to include the new
LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights in the example
ruleset attributes, and extend the ABI version fallback switch to
remove them for ABI < 12.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 Documentation/userspace-api/landlock.rst | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/Documentation/userspace-api/landlock.rst b/Documentation/userspace-api/landlock.rst
index 84cb7bf6b3ed..f6389b9668b4 100644
--- a/Documentation/userspace-api/landlock.rst
+++ b/Documentation/userspace-api/landlock.rst
@@ -78,7 +78,9 @@ to be explicit about the denied-by-default access rights.
             LANDLOCK_ACCESS_FS_REFER |
             LANDLOCK_ACCESS_FS_TRUNCATE |
             LANDLOCK_ACCESS_FS_IOCTL_DEV |
-            LANDLOCK_ACCESS_FS_RESOLVE_UNIX,
+            LANDLOCK_ACCESS_FS_RESOLVE_UNIX |
+            LANDLOCK_ACCESS_FS_READ_METADATA |
+            LANDLOCK_ACCESS_FS_WRITE_METADATA,
         .handled_access_net =
             LANDLOCK_ACCESS_NET_BIND_TCP |
             LANDLOCK_ACCESS_NET_CONNECT_TCP |
@@ -140,6 +142,13 @@ version, and only use the available subset of access rights:
         ruleset_attr.handled_access_net &=
             ~(LANDLOCK_ACCESS_NET_BIND_UDP |
               LANDLOCK_ACCESS_NET_CONNECT_SEND_UDP);
+        __attribute__((fallthrough));
+    case 10:
+    case 11:
+        /* Removes metadata rights for ABI < 12 */
+        ruleset_attr.handled_access_fs &=
+            ~(LANDLOCK_ACCESS_FS_READ_METADATA |
+              LANDLOCK_ACCESS_FS_WRITE_METADATA);
     }
 
 This enables the creation of an inclusive ruleset that will contain our rules.
-- 
2.18.0.huawei.25

