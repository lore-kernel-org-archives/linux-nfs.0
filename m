Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:55729 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756002AbbDORAM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2015 13:00:12 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 2/3] NFS: Move nfs_idmap.h into fs/nfs/
Date: Wed, 15 Apr 2015 13:00:05 -0400
Message-ID: <1429117206-13671-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1429117206-13671-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1429117206-13671-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This file is only used internally to the NFS v4 module, so it doesn't
need to be in the global include path.  I also renamed it from
nfs_idmap.h to nfs4idmap.h to emphasize that it's an NFSv4-only include
file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c          | 2 +-
 fs/nfs/idmap.c                                  | 2 +-
 fs/nfs/nfs4client.c                             | 2 +-
 include/linux/nfs_idmap.h => fs/nfs/nfs4idmap.h | 2 +-
 fs/nfs/nfs4proc.c                               | 2 +-
 fs/nfs/nfs4state.c                              | 2 +-
 fs/nfs/nfs4super.c                              | 2 +-
 fs/nfs/nfs4sysctl.c                             | 2 +-
 fs/nfs/nfs4xdr.c                                | 2 +-
 include/uapi/linux/nfs_idmap.h                  | 2 +-
 10 files changed, 10 insertions(+), 10 deletions(-)
 rename include/linux/nfs_idmap.h => fs/nfs/nfs4idmap.h (98%)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index edfb27e..55653a1 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -11,10 +11,10 @@
 #include <linux/module.h>
 
 #include <linux/sunrpc/metrics.h>
-#include <linux/nfs_idmap.h>
 
 #include "flexfilelayout.h"
 #include "../nfs4session.h"
+#include "../nfs4idmap.h"
 #include "../internal.h"
 #include "../delegation.h"
 #include "../nfs4trace.h"
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 857e2a9..2e1737c 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -36,7 +36,6 @@
 #include <linux/types.h>
 #include <linux/parser.h>
 #include <linux/fs.h>
-#include <linux/nfs_idmap.h>
 #include <net/net_namespace.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/nfs_fs.h>
@@ -49,6 +48,7 @@
 
 #include "internal.h"
 #include "netns.h"
+#include "nfs4idmap.h"
 #include "nfs4trace.h"
 
 #define NFS_UINT_MAXLEN 11
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 86d6214..43ca5a7 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -4,7 +4,6 @@
  */
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
-#include <linux/nfs_idmap.h>
 #include <linux/nfs_mount.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/auth.h>
@@ -15,6 +14,7 @@
 #include "callback.h"
 #include "delegation.h"
 #include "nfs4session.h"
+#include "nfs4idmap.h"
 #include "pnfs.h"
 #include "netns.h"
 
diff --git a/include/linux/nfs_idmap.h b/fs/nfs/nfs4idmap.h
similarity index 98%
rename from include/linux/nfs_idmap.h
rename to fs/nfs/nfs4idmap.h
index daaf3ea..de44d73 100644
--- a/include/linux/nfs_idmap.h
+++ b/fs/nfs/nfs4idmap.h
@@ -1,5 +1,5 @@
 /*
- * include/linux/nfs_idmap.h
+ * fs/nfs/nfs4idmap.h
  *
  *  UID and GID to name mapping for clients.
  *
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9ff8c63..98ad985 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -51,7 +51,6 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/module.h>
-#include <linux/nfs_idmap.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
 #include <linux/freezer.h>
@@ -63,6 +62,7 @@
 #include "callback.h"
 #include "pnfs.h"
 #include "netns.h"
+#include "nfs4idmap.h"
 #include "nfs4session.h"
 #include "fscache.h"
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f95e3b5..935a6ff 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -42,7 +42,6 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/nfs_fs.h>
-#include <linux/nfs_idmap.h>
 #include <linux/kthread.h>
 #include <linux/module.h>
 #include <linux/random.h>
@@ -57,6 +56,7 @@
 #include "callback.h"
 #include "delegation.h"
 #include "internal.h"
+#include "nfs4idmap.h"
 #include "nfs4session.h"
 #include "pnfs.h"
 #include "netns.h"
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 75090fe..61e2c23 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,12 +3,12 @@
  */
 #include <linux/init.h>
 #include <linux/module.h>
-#include <linux/nfs_idmap.h>
 #include <linux/nfs4_mount.h>
 #include <linux/nfs_fs.h>
 #include "delegation.h"
 #include "internal.h"
 #include "nfs4_fs.h"
+#include "nfs4idmap.h"
 #include "dns_resolve.h"
 #include "pnfs.h"
 #include "nfs.h"
diff --git a/fs/nfs/nfs4sysctl.c b/fs/nfs/nfs4sysctl.c
index b6ebe7e..0fbd3ab 100644
--- a/fs/nfs/nfs4sysctl.c
+++ b/fs/nfs/nfs4sysctl.c
@@ -6,10 +6,10 @@
  * Copyright (c) 2006 Trond Myklebust <Trond.Myklebust@netapp.com>
  */
 #include <linux/sysctl.h>
-#include <linux/nfs_idmap.h>
 #include <linux/nfs_fs.h>
 
 #include "nfs4_fs.h"
+#include "nfs4idmap.h"
 #include "callback.h"
 
 static const int nfs_set_port_min = 0;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a26880c..0aea978 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -52,10 +52,10 @@
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
-#include <linux/nfs_idmap.h>
 
 #include "nfs4_fs.h"
 #include "internal.h"
+#include "nfs4idmap.h"
 #include "nfs4session.h"
 #include "pnfs.h"
 #include "netns.h"
diff --git a/include/uapi/linux/nfs_idmap.h b/include/uapi/linux/nfs_idmap.h
index 8d4b1c7..038e36c 100644
--- a/include/uapi/linux/nfs_idmap.h
+++ b/include/uapi/linux/nfs_idmap.h
@@ -1,5 +1,5 @@
 /*
- * include/linux/nfs_idmap.h
+ * include/uapi/linux/nfs_idmap.h
  *
  *  UID and GID to name mapping for clients.
  *
-- 
2.3.5

