Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FB3C5275B2;
	Thu, 15 Oct 2026 12:21:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792066879; cv=none; b=Kl65voyMA5gaaJkhf7n4i5sby3QCs6YQsr1JkGz5f71GbofsMIjd2oeR1cYZPt2VMtaTq35lreG1Z5genbVbJ3iVaL8jOxTPcNHLZ+2nE3vQrFibYAzvBZ5b36Cqu3lfzw08LZ30GRs8j5r9Pa6NMUGh10HDIZ7RXacCyjGClaI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792066879; c=relaxed/simple;
	bh=FLFyRRHhJi6tZU18s+v2YoKZn2fIoW7LNdezj0jo31A=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=iv1QuBRVqLULYOHQRPaKkcpTC/kNxSzv4oXnWyv2UCfHLGAphhYT1kx7NzmzmFnaHnt91f0R4s/N0NZwXk45eRkEWk5QUDrL0PhE1pJs+xKbSQ2e5UUREkGzlkhMtwQ1qYjW4GiAKVHcPa+I0M+MHJb8wneR0tB5EfIUn+y462k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=wNSiwWKR; arc=none smtp.client-ip=113.46.200.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="wNSiwWKR"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=VESGW3TkU2bTfPpPgP4UR7E6JTjX0tkAQhUuZU9C/tM=;
	b=wNSiwWKRvOV1fjcErXNkqErXQUmQG3eZuwQkj3Zu6VFMiHhxXORXqjDrFe8LUISRsPYsZW2e2
	XQPGavZQkQgiZRnvDs0uHkrRCuZtCv9Ii/3WQe+SgmFIlieaRlAE3u38ZstYmsJIs87/e1uCN43
	22ZWBtq2ZdGrbDeJX79IZTo=
Received: from mail.maildlp.com (unknown [172.19.163.104])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4j56LH4HWVz1prLV;
	Thu, 15 Oct 2026 20:08:55 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id E96A04056E;
	Thu, 15 Oct 2026 20:21:15 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 15 Oct 2026 20:21:10 +0800
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
Subject: [PATCH v2 -next 18/18] Documentation: Update landlock doc for metadata rights
Date: Thu, 15 Oct 2026 20:54:24 +0800
Message-ID: <20261015125425.3246251-19-caixinchen1@huawei.com>
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

Update the user space documentation for the new
LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights: add them to the
example ruleset attributes, extend the ABI version fallback switch
to remove them for ABI < 13, and document their semantics in a new
"File metadata" section, including the fact that only explicit
metadata changes requested by user space are restricted.

The new section also warns that most of the time,
LANDLOCK_ACCESS_FS_READ_METADATA should be granted together with
LANDLOCK_ACCESS_FS_READ_FILE and LANDLOCK_ACCESS_FS_READ_DIR:
programs commonly read metadata alongside file contents and
directory listings (e.g. with stat(2)) and do not expect such calls
to fail, while denying only READ_FILE or READ_DIR does not hide
metadata.

Assisted-by: opencode: glm-5.3
Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 Documentation/userspace-api/landlock.rst | 47 +++++++++++++++++++++++-
 1 file changed, 46 insertions(+), 1 deletion(-)

diff --git a/Documentation/userspace-api/landlock.rst b/Documentation/userspace-api/landlock.rst
index 3d45b956b640..62fe39a8b61e 100644
--- a/Documentation/userspace-api/landlock.rst
+++ b/Documentation/userspace-api/landlock.rst
@@ -87,7 +87,9 @@ to be explicit about the denied-by-default access rights.
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
@@ -159,6 +161,10 @@ version, and only use the available subset of access rights:
         ruleset_attr.handled_permissions &=
             ~(LANDLOCK_PERMISSION_NAMESPACE_USE |
               LANDLOCK_PERMISSION_CAPABILITY_USE);
+        /* Removes metadata rights for ABI < 13 */
+        ruleset_attr.handled_access_fs &=
+            ~(LANDLOCK_ACCESS_FS_READ_METADATA |
+              LANDLOCK_ACCESS_FS_WRITE_METADATA);
     }
 
 This enables the creation of an inclusive ruleset that will contain our rules.
@@ -669,6 +675,45 @@ for writing, sidestepping the ``LANDLOCK_ACCESS_FS_TRUNCATE`` right.
 
 The truncate right is associated with the opened file (see below).
 
+File metadata
+-------------
+
+The ``LANDLOCK_ACCESS_FS_READ_METADATA`` right governs reading file and
+directory metadata: :manpage:`stat(2)` and friends,
+:manpage:`getxattr(2)`, :manpage:`listxattr(2)` and friends, and POSIX ACL
+reads.
+
+The ``LANDLOCK_ACCESS_FS_WRITE_METADATA`` right governs explicit changes to
+file and directory metadata: :manpage:`chmod(2)` and friends,
+:manpage:`chown(2)` and friends, :manpage:`utimensat(2)`,
+:manpage:`setxattr(2)`, :manpage:`removexattr(2)` and friends, and POSIX ACL
+changes.  Both rights apply to files and directories alike.
+
+Implicit metadata changes performed by the kernel are not restricted by
+``LANDLOCK_ACCESS_FS_WRITE_METADATA``: reading a file may update its access
+time, writing a file updates its modification and change times and may change
+the file size, and writing to or truncating a file with a set-user-ID or
+set-group-ID bit clears these bits.  File size changes through
+:manpage:`truncate(2)` and friends are governed by
+``LANDLOCK_ACCESS_FS_TRUNCATE`` instead.  Metadata change requests that do
+not change any attribute (e.g. :manpage:`chown(2)` with owner and group
+``-1``) are not restricted either.
+
+.. warning::
+
+   Many programs read metadata as part of reading file contents or listing
+   directories (e.g. calling :manpage:`stat(2)` before or after
+   :manpage:`open(2)`), and do not expect such calls to fail with
+   ``EACCES``.  Most of the time, ``LANDLOCK_ACCESS_FS_READ_METADATA``
+   should therefore be granted together with
+   ``LANDLOCK_ACCESS_FS_READ_FILE`` and ``LANDLOCK_ACCESS_FS_READ_DIR``.
+   Conversely, denying only ``LANDLOCK_ACCESS_FS_READ_FILE`` or
+   ``LANDLOCK_ACCESS_FS_READ_DIR`` does not hide metadata: it remains
+   readable through :manpage:`stat(2)` and friends unless
+   ``LANDLOCK_ACCESS_FS_READ_METADATA`` is denied as well.  Tailored
+   programs that do not read metadata at all can still deny this right to
+   further restrict their sandbox.
+
 Rights associated with file descriptors
 ---------------------------------------
 
-- 
2.18.0.huawei.25

