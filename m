Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.216
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101177;
	b=kKiLNrsKyon5lu7BdAdON+O2NidCt5VHtxZdbtHlGVltODSDrTYlNwUhNsH0NXakcma0
	 FTX2Su4NfYzy6BwOWHD4EDiJ7FIITsr4osSDu4/39Gdn7us3gOAqkG6cVE1eZSSGq1feQ
	 nw0zHOaoRfE8kPqC7ovC+8gCsUQtuIfdyvr0JnOU+2SJ8oI6zh9uWJj7L9OWLPmVnhcFX
	 Z/S0v1tAmJ3rX+9coYhLzAmH+qmOJHvOAYsNeZCI1Wy/Mufs+kQWpZNxXCyZSnFYk6lQR
	 64Ew7d2g+UektBy1wOcsE6qD9jKO0kTmMjCrRfwIWhqtRBrCxvjJvuCVxPizq5YD0Zg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101177;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:X-Originating-IP:X-ClientProxiedBy;
	bh=+4h+LosMEKQAOXs4e0h/oSVn5K7clxVAvpe79xJ2Y28=;
	b=wR/VwIdXMIHlOSNZujtMYYsMdeeM+n1W9tUxO0DZYLC2tqgWuiAmlTcdWWqX40tPT5DP
	 tRBafxwk9wEQN5IuWMg2dhnPsaFsgHrah/ZSgT3o4eJWU9gvR2RxizYQRbv8L8G1tIX3b
	 AchWy3kFMUmUMh9HWL8eZU1zHPCK6G6e+22snP7/uf4MJB3opY5nkN0vUoazSMp+714j0
	 osGjfHYXNVxB8Ge4fD/v3clvWH1psAHPtOx0oiYJ5SQZzd1gn1SJixu8B85/GsglgGvRb
	 R8f6gd3sxD2Yj6SFlyFqq5ezPb9wIhi2ZYPDqahYUMdY8wdtjzhfGDx3vgAaNSdttBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=FJiGDug6;
	arc=none smtp.remote-ip=113.46.200.216
Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4710606A9C6;
	Tue, 27 Oct 2026 11:39:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C4710606A9C6
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=FJiGDug6
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=+4h+LosMEKQAOXs4e0h/oSVn5K7clxVAvpe79xJ2Y28=;
	b=FJiGDug68WjNx0xWDIzzod6vppyeMsZslGo8cml9EB76SuctefkJ1J7l0uWFKlc3YKPxW95A0
	Bi33/6VwmJN6lAx71JiANxrC22DyaCsZCZaCobac9XLQmXSkIwoHQMC8HwTUXdA6AEouF8htbgB
	4K7LxD9HDjrnfxGspaDKDWw=
Received: from mail.maildlp.com (unknown [172.19.162.197])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4jDT6j2ylBz1T4G1;
	Tue, 27 Oct 2026 19:39:25 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id BCEA64057D;
	Tue, 27 Oct 2026 19:39:33 +0800 (CST)
Received: from octopus.huawei.com (10.67.174.191) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Tue, 27 Oct 2026 19:39:28 +0800
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
Subject: [PATCH v3 -next 18/18] Documentation: Update landlock doc for metadata rights
Date: Tue, 27 Oct 2026 20:11:51 +0800
Message-ID: <20261027121151.1887650-19-caixinchen1@huawei.com>
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

Update the user space documentation for the new
LANDLOCK_ACCESS_FS_READ_METADATA and
LANDLOCK_ACCESS_FS_WRITE_METADATA access rights: add them to the
example ruleset attributes, extend the ABI version fallback switch
to remove them for ABI < 13, and document their semantics in a new
"File metadata" section, including the fact that only explicit
metadata changes requested by user space are restricted.

The new section also documents the open-time semantic of both
rights: metadata accesses requested through an already opened file
descriptor are granted according to the rights available at open(2)
time, like for LANDLOCK_ACCESS_FS_TRUNCATE, whereas path-based
accesses and O_PATH file descriptors are always checked against the
rights of the calling thread.  The "Rights associated with
file descriptors" section is updated accordingly.

Finally, the new section warns that most of the time,
LANDLOCK_ACCESS_FS_READ_METADATA should be granted together with
LANDLOCK_ACCESS_FS_READ_FILE and LANDLOCK_ACCESS_FS_READ_DIR:
programs commonly read metadata alongside file contents and
directory listings (e.g. with stat(2)) and do not expect such calls
to fail, while denying only READ_FILE or READ_DIR does not hide
metadata.

Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
---
 Documentation/userspace-api/landlock.rst | 92 ++++++++++++++++++++++--
 1 file changed, 86 insertions(+), 6 deletions(-)

diff --git a/Documentation/userspace-api/landlock.rst b/Documentation/userspace-api/landlock.rst
index 3d45b956b640..489306ab0da8 100644
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
@@ -159,6 +161,12 @@ version, and only use the available subset of access rights:
         ruleset_attr.handled_permissions &=
             ~(LANDLOCK_PERMISSION_NAMESPACE_USE |
               LANDLOCK_PERMISSION_CAPABILITY_USE);
+        __attribute__((fallthrough));
+    case 12:
+        /* Removes metadata rights for ABI < 13 */
+        ruleset_attr.handled_access_fs &=
+            ~(LANDLOCK_ACCESS_FS_READ_METADATA |
+              LANDLOCK_ACCESS_FS_WRITE_METADATA);
     }
 
 This enables the creation of an inclusive ruleset that will contain our rules.
@@ -669,14 +677,73 @@ for writing, sidestepping the ``LANDLOCK_ACCESS_FS_TRUNCATE`` right.
 
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
+``LANDLOCK_ACCESS_FS_TRUNCATE`` instead.  An explicit metadata change request
+that changes nothing, e.g. :manpage:`chown(2)` with owner and group ``-1`` on
+a file without a set-user-ID or set-group-ID bit, is not restricted either;
+the same :manpage:`chown(2)` on a file carrying such a bit explicitly
+requests clearing it, and therefore requires
+``LANDLOCK_ACCESS_FS_WRITE_METADATA``.
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
+Both metadata rights are associated with opened files, like
+``LANDLOCK_ACCESS_FS_TRUNCATE`` (see below): metadata accesses and changes
+requested through an already opened file descriptor, e.g. with
+:manpage:`fchmod(2)`, :manpage:`fchown(2)`, :manpage:`utimensat(2)` on an
+empty path, :manpage:`fstat(2)`, :manpage:`fgetxattr(2)`,
+:manpage:`fsetxattr(2)`, :manpage:`ioctl(2)` with ``FS_IOC_GETFLAGS`` or
+``FS_IOC_SETFLAGS``, or ``file_getattr(2)`` and ``file_setattr(2)`` with
+``AT_EMPTY_PATH``, are granted according to the rights available at
+:manpage:`open(2)` time, not according to the rights of the calling thread.
+Metadata accesses requested through a path (e.g. :manpage:`chmod(2)`,
+:manpage:`stat(2)`) are always checked against the rights of the calling
+thread.  ``O_PATH`` file descriptors are not opened through the open
+permission checks: metadata accesses through them are checked against the
+rights of the calling thread as well.
+
 Rights associated with file descriptors
 ---------------------------------------
 
-When opening a file, the availability of the ``LANDLOCK_ACCESS_FS_TRUNCATE`` and
-``LANDLOCK_ACCESS_FS_IOCTL_DEV`` rights is associated with the newly created
-file descriptor and will be used for subsequent truncation and ioctl attempts
-using :manpage:`ftruncate(2)` and :manpage:`ioctl(2)`.  The behavior is similar
-to opening a file for reading or writing, where permissions are checked during
+When opening a file, the availability of the ``LANDLOCK_ACCESS_FS_TRUNCATE``,
+``LANDLOCK_ACCESS_FS_IOCTL_DEV``, ``LANDLOCK_ACCESS_FS_READ_METADATA`` and
+``LANDLOCK_ACCESS_FS_WRITE_METADATA`` rights is associated with the newly
+created file descriptor and will be used for subsequent truncation, ioctl
+and metadata attempts using :manpage:`ftruncate(2)`, :manpage:`ioctl(2)` and
+the file descriptor-based metadata system calls.  The behavior is similar to
+opening a file for reading or writing, where permissions are checked during
 :manpage:`open(2)`, but not during the subsequent :manpage:`read(2)` and
 :manpage:`write(2)` calls.
 
@@ -1051,6 +1118,19 @@ fd-reference acquisition (:manpage:`open_tree(2)`, :manpage:`fsmount(2)`) with
 the new ``LANDLOCK_PERMISSION_NAMESPACE_USE`` permission flag and
 ``LANDLOCK_RULE_NAMESPACE`` rule type.
 
+File metadata (ABI < 13)
+------------------------
+
+Starting with the Landlock ABI version 13, it is possible to restrict
+file metadata access with the new ``LANDLOCK_ACCESS_FS_READ_METADATA``
+and ``LANDLOCK_ACCESS_FS_WRITE_METADATA`` access rights, which control
+reading file and directory metadata (e.g. with :manpage:`stat(2)` and
+:manpage:`getxattr(2)`) and changing it (e.g. with :manpage:`chmod(2)`
+and :manpage:`setxattr(2)`).  As with ``LANDLOCK_ACCESS_FS_TRUNCATE``,
+these rights are tied to opened files: metadata accesses through an
+already opened file descriptor are granted according to the rights
+available at :manpage:`open(2)` time.
+
 .. _kernel_support:
 
 Kernel support
-- 
2.18.0.huawei.25

