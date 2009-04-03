From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 15/35] nfsd41: hard page limit for DRC
Date: Fri,  3 Apr 2009 08:28:18 +0300
Message-ID: <1238736498-17548-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12217 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755362AbZDCF2X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:23 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
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
[moved NFSD_DRC_SIZE_SHIFT's declaration up in header file]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfssvc.c           |   23 +++++++++++++++++++++++
 include/linux/nfsd/nfsd.h  |    3 +++
 include/linux/sunrpc/svc.h |    2 ++
 3 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b5168d1..b53a098 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -22,6 +22,7 @@
 #include <linux/freezer.h>
 #include <linux/fs_struct.h>
 #include <linux/kthread.h>
+#include <linux/swap.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/stats.h>
@@ -197,6 +198,26 @@ void nfsd_reset_versions(void)
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
+	nfsd_serv->sv_drc_max_pages = nr_free_buffer_pages()
+						>> NFSD_DRC_SIZE_SHIFT;
+	nfsd_serv->sv_drc_pages_used = 0;
+	dprintk("%s svc_drc_max_pages %u\n", __func__,
+		nfsd_serv->sv_drc_max_pages);
+}
 
 int nfsd_create_serv(void)
 {
@@ -229,6 +250,8 @@ int nfsd_create_serv(void)
 				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
+	else
+		set_max_drc();
 
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index ab9616d..1f063d4 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -331,6 +331,9 @@ extern struct timeval	nfssvc_boot;
 #define NFSD_LEASE_TIME                 (nfs4_lease_time())
 #define NFSD_LAUNDROMAT_MINTIMEOUT      10   /* seconds */
 
+/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
+#define NFSD_DRC_SIZE_SHIFT	7
+
 /*
  * The following attributes are currently not supported by the NFSv4 server:
  *    ARCHIVE       (deprecated anyway)
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 815dd58..d209c63 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -95,6 +95,8 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
+	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
+	unsigned int		sv_drc_pages_used;/* DRC pages used */
 };
 
 /*
-- 
1.6.2.1

