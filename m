Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53253 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/15] Remove include/linux/nfsd/const.h
Date: Fri, 26 Aug 2011 18:28:23 -0400
Message-Id: <1314397716-18602-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Userspace shouldn't have a use for these constants.  Nothing here is
used outside fs/nfsd.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsd.h             |   26 ++++++++++++++++++++++++++
 include/linux/nfsd/Kbuild  |    1 -
 include/linux/nfsd/const.h |   42 ------------------------------------------
 include/linux/nfsd/nfsfh.h |    7 +++++--
 4 files changed, 31 insertions(+), 45 deletions(-)
 delete mode 100644 include/linux/nfsd/const.h

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 7ecfa24..8da03e1 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -11,13 +11,39 @@
 #include <linux/types.h>
 #include <linux/mount.h>
 
+#include <linux/nfs.h>
+#include <linux/nfs2.h>
+#include <linux/nfs3.h>
+#include <linux/nfs4.h>
+#include <linux/sunrpc/msg_prot.h>
+
 #include <linux/nfsd/debug.h>
 #include <linux/nfsd/export.h>
 #include <linux/nfsd/stats.h>
+
 /*
  * nfsd version
  */
 #define NFSD_SUPPORTED_MINOR_VERSION	1
+/*
+ * Maximum blocksizes supported by daemon under various circumstances.
+ */
+#define NFSSVC_MAXBLKSIZE       RPCSVC_MAXPAYLOAD
+/* NFSv2 is limited by the protocol specification, see RFC 1094 */
+#define NFSSVC_MAXBLKSIZE_V2    (8*1024)
+
+
+/*
+ * Largest number of bytes we need to allocate for an NFS
+ * call or reply.  Used to control buffer sizes.  We use
+ * the length of v3 WRITE, READDIR and READDIR replies
+ * which are an RPC header, up to 26 XDR units of reply
+ * data, and some page data.
+ *
+ * Note that accuracy here doesn't matter too much as the
+ * size is rounded up to a page size when allocating space.
+ */
+#define NFSD_BUFSIZE            ((RPC_MAX_HEADER_WITH_AUTH+26)*XDR_UNIT + NFSSVC_MAXBLKSIZE)
 
 struct readdir_cd {
 	__be32			err;	/* 0, nfserr, or nfserr_eof */
diff --git a/include/linux/nfsd/Kbuild b/include/linux/nfsd/Kbuild
index 55d1467..0e52860 100644
--- a/include/linux/nfsd/Kbuild
+++ b/include/linux/nfsd/Kbuild
@@ -1,4 +1,3 @@
-header-y += const.h
 header-y += debug.h
 header-y += export.h
 header-y += nfsfh.h
diff --git a/include/linux/nfsd/const.h b/include/linux/nfsd/const.h
deleted file mode 100644
index feb3764..0000000
--- a/include/linux/nfsd/const.h
+++ /dev/null
@@ -1,42 +0,0 @@
-/*
- * include/linux/nfsd/const.h
- *
- * Various constants related to NFS.
- *
- * Copyright (C) 1995-1997 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifndef _LINUX_NFSD_CONST_H
-#define _LINUX_NFSD_CONST_H
-
-#include <linux/nfs.h>
-#include <linux/nfs2.h>
-#include <linux/nfs3.h>
-#include <linux/nfs4.h>
-
-/*
- * Maximum blocksizes supported by daemon under various circumstances.
- */
-#define NFSSVC_MAXBLKSIZE	RPCSVC_MAXPAYLOAD
-/* NFSv2 is limited by the protocol specification, see RFC 1094 */
-#define NFSSVC_MAXBLKSIZE_V2	(8*1024)
-
-#ifdef __KERNEL__
-
-#include <linux/sunrpc/msg_prot.h>
-
-/*
- * Largest number of bytes we need to allocate for an NFS
- * call or reply.  Used to control buffer sizes.  We use
- * the length of v3 WRITE, READDIR and READDIR replies
- * which are an RPC header, up to 26 XDR units of reply
- * data, and some page data.
- *
- * Note that accuracy here doesn't matter too much as the
- * size is rounded up to a page size when allocating space.
- */
-#define NFSD_BUFSIZE		((RPC_MAX_HEADER_WITH_AUTH+26)*XDR_UNIT + NFSSVC_MAXBLKSIZE)
-
-#endif /* __KERNEL__ */
-
-#endif /* _LINUX_NFSD_CONST_H */
diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index f76d80c..ce4743a 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -14,11 +14,14 @@
 #ifndef _LINUX_NFSD_FH_H
 #define _LINUX_NFSD_FH_H
 
-# include <linux/types.h>
+#include <linux/types.h>
+#include <linux/nfs.h>
+#include <linux/nfs2.h>
+#include <linux/nfs3.h>
+#include <linux/nfs4.h>
 #ifdef __KERNEL__
 # include <linux/sunrpc/svc.h>
 #endif
-#include <linux/nfsd/const.h>
 
 /*
  * This is the old "dentry style" Linux NFSv2 file handle.
-- 
1.7.4.1

