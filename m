Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:59863 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017Ab3KOWbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Nov 2013 17:31:00 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Fix kbuild errors due to missing symbols
Date: Fri, 15 Nov 2013 17:30:36 -0500
Message-ID: <1384554636-25330-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My recent patch 644aa303: "NFS: Enabling v4.2 should not recompile nfsd
and lockd" caused build errors when CONFIG_NFS_USE_LEGACY_DNS=y and when
CONFIG_NFS_V4=n.  This patch fixes those errors.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4_fs.h | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e916e86..dc1c915 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -9,21 +9,20 @@
 #ifndef __LINUX_FS_NFS_NFS4_FS_H
 #define __LINUX_FS_NFS_NFS4_FS_H
 
-#if IS_ENABLED(CONFIG_NFS_V4)
-
-#define NFS4_MAX_LOOP_ON_RECOVER (10)
-
-#include <linux/seqlock.h>
-
 #if defined(CONFIG_NFS_V4_2)
 #define NFS4_MAX_MINOR_VERSION 2
-#else
-#if defined(CONFIG_NFS_V4_1)
+#elif defined(CONFIG_NFS_V4_1)
 #define NFS4_MAX_MINOR_VERSION 1
 #else
 #define NFS4_MAX_MINOR_VERSION 0
-#endif /* CONFIG_NFS_V4_1 */
-#endif /* CONFIG_NFS_V4_2 */
+#endif
+
+#if IS_ENABLED(CONFIG_NFS_V4)
+
+#define NFS4_MAX_LOOP_ON_RECOVER (10)
+
+#include <linux/seqlock.h>
+#include <linux/nfs_fs.h>
 
 struct idmap;
 
-- 
1.8.4.2

