Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:34223 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767Ab0JaQVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Oct 2010 12:21:08 -0400
From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH v2] Regression: fix mounting NFS when NFSv3 support is not
	compiled
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Sun, 31 Oct 2010 18:21:05 +0200
Message-ID: <20101031162105.23213.60220.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trying to mount NFS (root partition in my case) fails if CONFIG_NFS_V3
is not selected. nfs_validate_mount_data() returns EPROTONOSUPPORT,
because of this check:

#ifndef CONFIG_NFS_V3
	if (args->version == 3)
		goto out_v3_not_compiled;
#endif /* !CONFIG_NFS_V3 */

and args->version was always initialized to 3.

It was working in 2.6.36

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
---

 fs/nfs/super.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0a42e8f..9587506 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -67,6 +67,12 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+#ifdef CONFIG_NFS_V3
+#define NFS_DEFAULT_VERSION 3
+#else
+#define NFS_DEFAULT_VERSION 2
+#endif
+
 enum {
 	/* Mount options that take no arguments */
 	Opt_soft, Opt_hard,
@@ -2277,7 +2283,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	};
 	int error = -ENOMEM;
 
-	data = nfs_alloc_parsed_mount_data(3);
+	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
 	mntfh = nfs_alloc_fhandle();
 	if (data == NULL || mntfh == NULL)
 		goto out_free_fh;

