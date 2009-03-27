From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 21/47] nfsd41: hard page limit for DRC
Date: Fri, 27 Mar 2009 06:16:16 +0300
Message-ID: <1238123776-7606-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25343 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755812AbZC0DQV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:16:21 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use no more than 1/128th of the number of free pages at nfsd startup for the
v4.1 DRC.

This is an arbitrary default which should probably end up under the control
of an administrator.

Signed-off-by: Andy Adamson <andros@netapp.com>
[moved added fields in struct svc_serv under CONFIG_NFSD_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[fix set_max_drc calculation of sv_drc_max_pages]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfssvc.c           |   25 +++++++++++++++++++++++++
 include/linux/nfsd/nfsd.h  |    7 +++++++
 include/linux/sunrpc/svc.h |    4 ++++
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b5168d1..ab60320 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -22,6 +22,7 @@
 #include <linux/freezer.h>
 #include <linux/fs_struct.h>
 #include <linux/kthread.h>
+#include <linux/swap.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/stats.h>
@@ -197,6 +198,28 @@ void nfsd_reset_versions(void)
 	}
 }
 
+/*
+ * Each session guarantees a negotiated per slot memory cache for replies
+ * which in turn consumes memory beyond the v2/v3/v4.0 server. A dedicated
+ * NFSv4.1 server might want to use more memory for a DRC than a machine
+ * with mutiple services.
+ *
+ * Impose a hard limit on the number of pages for the DRC which varies
+ * according to the machines free pages. This is of course only a default.
+ *
+ * For now this is a #defined shift which could be under admin control
+ * in the future.
+ */
+static void set_max_drc(void)
+{
+#ifdef CONFIG_NFSD_V4_1
+	nfsd_serv->sv_drc_max_pages = nr_free_buffer_pages()
+						>> NFSD_DRC_SIZE_SHIFT;
+	nfsd_serv->sv_drc_pages_used = 0;
+	dprintk("%s svc_drc_max_pages %u\n", __func__,
+		nfsd_serv->sv_drc_max_pages);
+#endif /* CONFIG_NFSD_V4_1 */
+}
 
 int nfsd_create_serv(void)
 {
@@ -229,6 +252,8 @@ int nfsd_create_serv(void)
 				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
+	else
+		set_max_drc();
 
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index ab9616d..3bccec3 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -361,6 +361,13 @@ extern struct timeval	nfssvc_boot;
  | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
  | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
 
+#if defined(CONFIG_NFSD_V4_1)
+
+/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
+#define NFSD_DRC_SIZE_SHIFT	7
+
+#endif /* CONFIG_NFSD_V4_1 */
+
 /* These will return ERR_INVAL if specified in GETATTR or READDIR. */
 #define NFSD_WRITEONLY_ATTRS_WORD1							    \
 (FATTR4_WORD1_TIME_ACCESS_SET   | FATTR4_WORD1_TIME_MODIFY_SET)
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 815dd58..c4f0e1e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -95,6 +95,10 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
+#if defined(CONFIG_NFSD_V4_1)
+	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
+	unsigned int		sv_drc_pages_used;/* DRC pages used */
+#endif /* CONFIG_NFSD_V4_1 */
 };
 
 /*
-- 
1.6.2.1

