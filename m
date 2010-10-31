Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:40149 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767Ab0JaP6o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Oct 2010 11:58:44 -0400
From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH] Regression: fix mounting NFS when NFSv3 support is not
	compiled
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Sun, 31 Oct 2010 17:58:40 +0200
Message-ID: <20101031155840.21196.49014.stgit@localhost.localdomain>
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

 fs/nfs/super.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0a42e8f..8737017 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2277,7 +2277,11 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	};
 	int error = -ENOMEM;
 
+#ifdef CONFIG_NFS_V3
 	data = nfs_alloc_parsed_mount_data(3);
+#else
+	data = nfs_alloc_parsed_mount_data(2);
+#endif
 	mntfh = nfs_alloc_fhandle();
 	if (data == NULL || mntfh == NULL)
 		goto out_free_fh;

