Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:33813 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946Ab1K1R7C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 12:59:02 -0500
From: Stefan Bader <stefan.bader@canonical.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, smb@canonical.com
Subject: [PATCH] nfs: Define nfs4 module alias
Date: Mon, 28 Nov 2011 18:58:58 +0100
Message-Id: <1322503138-3613-1-git-send-email-stefan.bader@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fact that mount.nfs4 does not find the correct modules to load
(as fs type is nfs4 and that gets probed) seems to be a common
pitfall for quite a bit of time now.
It seems like adding an alias for the nfs4 filesystem type would
be a simple and acceptable (at least ext4 conditionally seems to
do the same) way to fix this. I placed the code into the one file
that already had some module stuff in it.
Does this look like an acceptable change?

-Stefan


>From 1351324afb76bc831eb70f0af3f7a9524047cec0 Mon Sep 17 00:00:00 2001
From: Stefan Bader <stefan.bader@canonical.com>
Date: Mon, 28 Nov 2011 15:37:39 +0100
Subject: [PATCH] nfs: Define nfs4 module alias

When NFSv4 is set to be built, the supporting code gets built into the
nfs module. But when trying to mount with fs-type nfs4 the default is
to try to load a module with the same name. Define a module alias to
enable automatic module loading for NFSv4.

Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
---
 fs/nfs/inode.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c07a55a..608069a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1653,6 +1653,9 @@ static void __exit exit_nfs_fs(void)
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
 module_param(enable_ino64, bool, 0644);
+#ifdef CONFIG_NFS_V4
+MODULE_ALIAS("nfs4");
+#endif
 
 module_init(init_nfs_fs)
 module_exit(exit_nfs_fs)
-- 
1.7.5.4

