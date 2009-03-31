From: Greg Banks <gnb@sgi.com>
Subject: [patch 01/29] knfsd: Add infrastructure for measuring RPC service times.
Date: Wed, 01 Apr 2009 07:28:01 +1100
Message-ID: <20090331202937.980076000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22592 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762572AbZCaVCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two new functions; svc_time_mark() remembers the current time
in a struct svc_time; svc_time_elapsed() calculates and returns
the time since a svc_time was marked.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/sunrpc/svc.h |   12 ++++++++++++
 net/sunrpc/svc.c           |   25 +++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -18,6 +18,16 @@
 #include <linux/sunrpc/svcauth.h>
 #include <linux/wait.h>
 #include <linux/mm.h>
+#include <linux/time.h>
+
+/*
+ * Structure used to implement a fast lockless elapsed time measure.
+ */
+struct svc_time
+{
+	struct timespec	st_spec;
+};
+
 
 /*
  * This is the RPC server thread function prototype
@@ -419,6 +429,8 @@ int		   svc_register(const struct svc_se
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
 struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
+void		   svc_time_mark(struct svc_time *);
+int		   svc_time_elapsed(const struct svc_time *, struct timespec *);
 char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
Index: bfields/net/sunrpc/svc.c
===================================================================
--- bfields.orig/net/sunrpc/svc.c
+++ bfields/net/sunrpc/svc.c
@@ -1232,3 +1232,28 @@ u32 svc_max_payload(const struct svc_rqs
 	return max;
 }
 EXPORT_SYMBOL_GPL(svc_max_payload);
+
+
+void
+svc_time_mark(struct svc_time *st)
+{
+	getnstimeofday(&st->st_spec);
+}
+EXPORT_SYMBOL(svc_time_mark);
+
+int
+svc_time_elapsed(const struct svc_time *mark, struct timespec *ts)
+{
+	struct svc_time now;
+
+	svc_time_mark(&now);
+
+	if (now.st_spec.tv_sec < mark->st_spec.tv_sec)
+		return -EINVAL;	/* time going backwards */
+
+	*ts = timespec_sub(now.st_spec, mark->st_spec);
+
+	return 0;
+}
+EXPORT_SYMBOL(svc_time_elapsed);
+

--
Greg
