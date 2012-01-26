Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61212 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879Ab2AZVy2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 16:54:28 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/3] NFS: Keep idmapper include files in one place
Date: Thu, 26 Jan 2012 16:54:24 -0500
Message-Id: <1327614865-29322-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c |   64 ++++++++++++++++++++++++++-----------------------------
 1 files changed, 30 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 56b1104..fbbc77e 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -39,6 +39,36 @@
 #include <linux/slab.h>
 #include <linux/nfs_idmap.h>
 #include <linux/nfs_fs.h>
+#include <linux/cred.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_fs_sb.h>
+#include <linux/keyctl.h>
+#include <linux/key-type.h>
+#include <linux/rcupdate.h>
+#include <linux/err.h>
+#include <keys/user-type.h>
+
+/* include files needed by legacy idmapper */
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/init.h>
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/sched.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/workqueue.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
+#include <linux/nfs_fs.h>
+#include "nfs4_fs.h"
+
+#define NFS_UINT_MAXLEN 11
+#define IDMAP_HASH_SZ          128
+
+/* Default cache timeout is 10 minutes */
+unsigned int nfs_idmap_cache_timeout = 600 * HZ;
+const struct cred *id_resolver_cache;
+
 
 /**
  * nfs_fattr_init_names - initialise the nfs_fattr owner_name/group_name fields
@@ -142,21 +172,6 @@ static int nfs_map_numeric_to_string(__u32 id, char *buf, size_t buflen)
 	return snprintf(buf, buflen, "%u", id);
 }
 
-#include <linux/cred.h>
-#include <linux/sunrpc/sched.h>
-#include <linux/nfs4.h>
-#include <linux/nfs_fs_sb.h>
-#include <linux/keyctl.h>
-#include <linux/key-type.h>
-#include <linux/rcupdate.h>
-#include <linux/err.h>
-
-#include <keys/user-type.h>
-
-#define NFS_UINT_MAXLEN 11
-
-const struct cred *id_resolver_cache;
-
 struct key_type key_type_id_resolver = {
 	.name		= "id_resolver",
 	.instantiate	= user_instantiate,
@@ -326,25 +341,6 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen,
 }
 
 /* idmap classic begins here */
-#include <linux/module.h>
-#include <linux/mutex.h>
-#include <linux/init.h>
-#include <linux/socket.h>
-#include <linux/in.h>
-#include <linux/sched.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/workqueue.h>
-#include <linux/sunrpc/rpc_pipe_fs.h>
-
-#include <linux/nfs_fs.h>
-
-#include "nfs4_fs.h"
-
-#define IDMAP_HASH_SZ          128
-
-/* Default cache timeout is 10 minutes */
-unsigned int nfs_idmap_cache_timeout = 600 * HZ;
-
 static int param_set_idmap_timeout(const char *val, struct kernel_param *kp)
 {
 	char *endp;
-- 
1.7.8.4

