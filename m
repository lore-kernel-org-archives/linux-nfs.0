Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:42539 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760033Ab3HNXZL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 19:25:11 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 02/13] NFS: refactor code for calculating the crc32 hash of a filehandle
Date: Wed, 14 Aug 2013 19:24:47 -0400
Message-ID: <1376522698-44596-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376522698-44596-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1376522698-44596-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to be able to display the crc32 hash of the filehandle in
tracepoints.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c    |  3 +--
 fs/nfs/internal.h | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index af6e806..9a98b04 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -38,7 +38,6 @@
 #include <linux/slab.h>
 #include <linux/compat.h>
 #include <linux/freezer.h>
-#include <linux/crc32.h>
 
 #include <asm/uaccess.h>
 
@@ -1190,7 +1189,7 @@ u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh)
 {
 	/* wireshark uses 32-bit AUTODIN crc and does a bitwise
 	 * not on the result */
-	return ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
+	return nfs_fhandle_hash(fh);
 }
 
 /*
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9b694f1..50f7068 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -5,6 +5,7 @@
 #include "nfs4_fs.h"
 #include <linux/mount.h>
 #include <linux/security.h>
+#include <linux/crc32.h>
 
 #define NFS_MS_MASK (MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
 
@@ -574,3 +575,22 @@ u64 nfs_timespec_to_change_attr(const struct timespec *ts)
 {
 	return ((u64)ts->tv_sec << 30) + ts->tv_nsec;
 }
+
+#ifdef CONFIG_CRC32
+/**
+ * nfs_fhandle_hash - calculate the crc32 hash for the filehandle
+ * @fh - pointer to filehandle
+ *
+ * returns a crc32 hash for the filehandle that is compatible with
+ * the one displayed by "wireshark".
+ */
+static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
+{
+	return ~crc32_le(0xFFFFFFFF, &fh->data[0], fh->size);
+}
+#else
+static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
+{
+	return 0;
+}
+#endif
-- 
1.8.3.1

