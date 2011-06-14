Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:48238 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab1FNCdZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:33:25 -0400
Message-Id: <599083a2408045d79d8ef4fb453d5a892f5e9d83.1308017750.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 33/33] pnfsblock DEVONLY: Add configurable prefetch size for layoutget
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:33:23 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <peng_tao@emc.com>

Do not send upstream.  Only for dealing with servers that return small
layouts.

pnfs_layout_prefetch_kb can be modified via sysctl.
default to 0 so no effect if not set via sysctl.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c   |   17 +++++++++++++++++
 fs/nfs/pnfs.h   |    1 +
 fs/nfs/sysctl.c |   10 ++++++++++
 3 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7912635..4f63ebd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -46,6 +46,11 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
  */
 static LIST_HEAD(pnfs_modules_tbl);
 
+/*
+ * layoutget prefetch size
+ */
+unsigned int pnfs_layout_prefetch_kb;
+
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
 find_pnfs_driver_locked(u32 id)
@@ -909,6 +914,16 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 }
 
 /*
+ * Set layout prefetch length.
+ */
+static void
+pnfs_set_layout_prefetch(struct pnfs_layout_range *range)
+{
+	if (range->length < (pnfs_layout_prefetch_kb << 10))
+		range->length = pnfs_layout_prefetch_kb << 10;
+}
+
+/*
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
@@ -959,6 +974,8 @@ pnfs_update_layout(struct inode *ino,
 
 	if (pnfs_layoutgets_blocked(lo, NULL, 0))
 		goto out_unlock;
+
+	pnfs_set_layout_prefetch(&arg);
 	atomic_inc(&lo->plh_outstanding);
 
 	get_layout_hdr(lo);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d7f203b..6718053 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -180,6 +180,7 @@ extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 
 /* pnfs.c */
+extern unsigned int pnfs_layout_prefetch_kb;
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 978aaeb..79a5134 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -14,6 +14,7 @@
 #include <linux/nfs_fs.h>
 
 #include "callback.h"
+#include "pnfs.h"
 
 #ifdef CONFIG_NFS_V4
 static const int nfs_set_port_min = 0;
@@ -42,6 +43,15 @@ static ctl_table nfs_cb_sysctls[] = {
 	},
 #endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
 #endif
+#ifdef CONFIG_NFS_V4_1
+	{
+		.procname	= "pnfs_layout_prefetch_kb",
+		.data		= &pnfs_layout_prefetch_kb,
+		.maxlen		= sizeof(pnfs_layout_prefetch_kb),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{
 		.procname	= "nfs_mountpoint_timeout",
 		.data		= &nfs_mountpoint_expiry_timeout,
-- 
1.7.4.1

