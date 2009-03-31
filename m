From: Greg Banks <gnb@sgi.com>
Subject: [patch 07/29] knfsd: Prefetch the per-export stats entry
Date: Wed, 01 Apr 2009 07:28:07 +1100
Message-ID: <20090331202940.423639000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22574 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757726AbZCaVCe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On most large NFS servers, there are very few per-export stats
entries and each one will be used on multiple CPUs.  This tends to
make them a contention point on high call rate workloads (which is
why the per-export and per-client stats are designed to be disabled
at runtime).  Experiment showed that prefetching the stats entry had
a small positive benefit on this contention.

If I was to do this properly, the per-export stats objects would
be stored per-cpu and stitched together on demand for export to
userspace.  However, that would make the reference counting and
pruning semantics....interesting.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/stats.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -33,6 +33,7 @@
 #include <linux/list.h>
 #include <linux/swap.h>
 #include <linux/log2.h>
+#include <linux/prefetch.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/stats.h>
@@ -44,6 +45,15 @@
 #define hentry_from_hnode(hn) \
 	hlist_entry((hn), nfsd_stats_hentry_t, se_node)
 
+static inline void nfsd_stats_prefetch(nfsd_stats_hentry_t *se)
+{
+	unsigned int i;
+
+	for (i = 0 ; i < sizeof(nfsd_stats_hentry_t) ; i += PREFETCH_STRIDE)
+		prefetch((char *)se+i);
+}
+
+
 struct nfsd_stats	nfsdstats;
 struct svc_stat		nfsd_svcstats = {
 	.program	= &nfsd_program,
@@ -395,6 +405,7 @@ void nfsd_stats_update_op(struct svc_rqs
 	    fh->fh_export != NULL &&
 	    (se = fh->fh_export->ex_stats) != NULL &&
 	    rqstp->rq_export_stats == NULL) {
+	    	nfsd_stats_prefetch(se);
 		/*
 		 * We want the stats to survive fh_put() of the filehandle
 		 * so we can update os_bytes_out and service time in

--
Greg
