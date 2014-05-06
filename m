Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:33951 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbaEFRfD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 May 2014 13:35:03 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] nfsd: move <linux/nfsd/stats.h> to fs/nfsd
Date: Tue,  6 May 2014 19:37:15 +0200
Message-Id: <1399397836-31948-4-git-send-email-hch@lst.de>
In-Reply-To: <1399397836-31948-1-git-send-email-hch@lst.de>
References: <1399397836-31948-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are no legitimate users outside of fs/nfsd, so move it there.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfsd.h             |    2 +-
 fs/nfsd/stats.c            |    1 -
 fs/nfsd/stats.h            |   43 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/stats.h |   45 --------------------------------------------
 4 files changed, 44 insertions(+), 47 deletions(-)
 create mode 100644 fs/nfsd/stats.h
 delete mode 100644 include/linux/nfsd/stats.h

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 72004ca..7a07f9c 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -19,8 +19,8 @@
 #include <linux/sunrpc/msg_prot.h>
 
 #include <linux/nfsd/debug.h>
-#include <linux/nfsd/stats.h>
 
+#include "stats.h"
 #include "export.h"
 
 /*
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index 6d4521f..cd90878 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -24,7 +24,6 @@
 #include <linux/seq_file.h>
 #include <linux/module.h>
 #include <linux/sunrpc/stats.h>
-#include <linux/nfsd/stats.h>
 #include <net/net_namespace.h>
 
 #include "nfsd.h"
diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
new file mode 100644
index 0000000..a5c944b
--- /dev/null
+++ b/fs/nfsd/stats.h
@@ -0,0 +1,43 @@
+/*
+ * Statistics for NFS server.
+ *
+ * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
+ */
+#ifndef _NFSD_STATS_H
+#define _NFSD_STATS_H
+
+#include <uapi/linux/nfsd/stats.h>
+
+
+struct nfsd_stats {
+	unsigned int	rchits;		/* repcache hits */
+	unsigned int	rcmisses;	/* repcache hits */
+	unsigned int	rcnocache;	/* uncached reqs */
+	unsigned int	fh_stale;	/* FH stale error */
+	unsigned int	fh_lookup;	/* dentry cached */
+	unsigned int	fh_anon;	/* anon file dentry returned */
+	unsigned int	fh_nocache_dir;	/* filehandle not found in dcache */
+	unsigned int	fh_nocache_nondir;	/* filehandle not found in dcache */
+	unsigned int	io_read;	/* bytes returned to read requests */
+	unsigned int	io_write;	/* bytes passed in write requests */
+	unsigned int	th_cnt;		/* number of available threads */
+	unsigned int	th_usage[10];	/* number of ticks during which n perdeciles
+					 * of available threads were in use */
+	unsigned int	th_fullcnt;	/* number of times last free thread was used */
+	unsigned int	ra_size;	/* size of ra cache */
+	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
+					 * in the cache (10percentiles). [10] = not found */
+#ifdef CONFIG_NFSD_V4
+	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfsv4 operations */
+#endif
+
+};
+
+
+extern struct nfsd_stats	nfsdstats;
+extern struct svc_stat		nfsd_svcstats;
+
+void	nfsd_stat_init(void);
+void	nfsd_stat_shutdown(void);
+
+#endif /* _NFSD_STATS_H */
diff --git a/include/linux/nfsd/stats.h b/include/linux/nfsd/stats.h
deleted file mode 100644
index e75b254..0000000
--- a/include/linux/nfsd/stats.h
+++ /dev/null
@@ -1,45 +0,0 @@
-/*
- * linux/include/linux/nfsd/stats.h
- *
- * Statistics for NFS server.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
- */
-#ifndef LINUX_NFSD_STATS_H
-#define LINUX_NFSD_STATS_H
-
-#include <uapi/linux/nfsd/stats.h>
-
-
-struct nfsd_stats {
-	unsigned int	rchits;		/* repcache hits */
-	unsigned int	rcmisses;	/* repcache hits */
-	unsigned int	rcnocache;	/* uncached reqs */
-	unsigned int	fh_stale;	/* FH stale error */
-	unsigned int	fh_lookup;	/* dentry cached */
-	unsigned int	fh_anon;	/* anon file dentry returned */
-	unsigned int	fh_nocache_dir;	/* filehandle not found in dcache */
-	unsigned int	fh_nocache_nondir;	/* filehandle not found in dcache */
-	unsigned int	io_read;	/* bytes returned to read requests */
-	unsigned int	io_write;	/* bytes passed in write requests */
-	unsigned int	th_cnt;		/* number of available threads */
-	unsigned int	th_usage[10];	/* number of ticks during which n perdeciles
-					 * of available threads were in use */
-	unsigned int	th_fullcnt;	/* number of times last free thread was used */
-	unsigned int	ra_size;	/* size of ra cache */
-	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
-					 * in the cache (10percentiles). [10] = not found */
-#ifdef CONFIG_NFSD_V4
-	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfsv4 operations */
-#endif
-
-};
-
-
-extern struct nfsd_stats	nfsdstats;
-extern struct svc_stat		nfsd_svcstats;
-
-void	nfsd_stat_init(void);
-void	nfsd_stat_shutdown(void);
-
-#endif /* LINUX_NFSD_STATS_H */
-- 
1.7.10.4

