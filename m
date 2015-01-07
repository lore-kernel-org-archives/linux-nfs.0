Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:38962 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753638AbbAGA3T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 19:29:19 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so1066001pde.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 16:29:19 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 07/49] nfs41: move file layout macros to generic pnfs
Date: Tue,  6 Jan 2015 16:28:12 -0800
Message-Id: <1420590534-84063-8-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

They can be reused by flexfile layout as well.

Also add a code such that if read fails on one DS and
there are other DSes available to use, don't resend
through MDS but through pNFS so that client can read
from other DSes.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.h | 10 ----------
 fs/nfs/pnfs.h                  | 11 +++++++++++
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.h b/fs/nfs/filelayout/filelayout.h
index f97eea6..2896cb8 100644
--- a/fs/nfs/filelayout/filelayout.h
+++ b/fs/nfs/filelayout/filelayout.h
@@ -33,13 +33,6 @@
 #include "../pnfs.h"
 
 /*
- * Default data server connection timeout and retrans vaules.
- * Set by module paramters dataserver_timeo and dataserver_retrans.
- */
-#define NFS4_DEF_DS_TIMEO   600 /* in tenths of a second */
-#define NFS4_DEF_DS_RETRANS 5
-
-/*
  * Field testing shows we need to support up to 4096 stripe indices.
  * We store each index as a u8 (u32 on the wire) to keep the memory footprint
  * reasonable. This in turn means we support a maximum of 256
@@ -48,9 +41,6 @@
 #define NFS4_PNFS_MAX_STRIPE_CNT 4096
 #define NFS4_PNFS_MAX_MULTI_CNT  256 /* 256 fit into a u8 stripe_index */
 
-/* error codes for internal use */
-#define NFS4ERR_RESET_TO_MDS   12001
-
 enum stripetype4 {
 	STRIPE_SPARSE = 1,
 	STRIPE_DENSE = 2
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index cb666e8..588b2f1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -77,6 +77,17 @@ enum pnfs_try_status {
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
 
+/*
+ * Default data server connection timeout and retrans vaules.
+ * Set by module parameters dataserver_timeo and dataserver_retrans.
+ */
+#define NFS4_DEF_DS_TIMEO   600 /* in tenths of a second */
+#define NFS4_DEF_DS_RETRANS 5
+
+/* error codes for internal use */
+#define NFS4ERR_RESET_TO_MDS   12001
+#define NFS4ERR_RESET_TO_PNFS  12002
+
 enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
-- 
1.9.3

