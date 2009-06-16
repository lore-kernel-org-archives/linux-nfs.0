From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 11/44] nfsd41: use globals for DRC memory use management
Date: Tue, 16 Jun 2009 04:19:43 +0300
Message-ID: <1245115183-7163-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2676
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754057AbZFPBTn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The version 4.1 DRC memory limit and tracking variables are server wide and
session specific.
Add a spinlock to serialize access to the management variables which change
on session creation and deletion (usage counter) or (future) administrative
action to adjust the total DRC memory limit.

Track DRC memory usage in free session.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   15 +++++++++------
 fs/nfsd/nfssvc.c           |   19 +++++++++++++++----
 include/linux/nfsd/nfsd.h  |    5 +++++
 include/linux/sunrpc/svc.h |    2 --
 4 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6489913..6427f8b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -414,7 +414,7 @@ gen_sessionid(struct nfsd4_session *ses)
 
 /*
  * Give the client the number of slots it requests bound by
- * NFSD_MAX_SLOTS_PER_SESSION and by sv_drc_max_pages.
+ * NFSD_MAX_SLOTS_PER_SESSION and by nfsd_drc_max_mem.
  *
  * If we run out of reserved DRC memory we should (up to a point) re-negotiate
  * active sessions and reduce their slot usage to make rooom for new
@@ -431,11 +431,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
 
 	mem = fchan->maxreqs * NFSD_SLOT_CACHE_SIZE;
 
-	spin_lock(&nfsd_serv->sv_lock);
-	if (mem + nfsd_serv->sv_drc_mem_used > nfsd_serv->sv_drc_max_mem)
-		mem = nfsd_serv->sv_drc_max_mem - nfsd_serv->sv_drc_mem_used;
-	nfsd_serv->sv_drc_mem_used += mem;
-	spin_unlock(&nfsd_serv->sv_lock);
+	spin_lock(&nfsd_drc_lock);
+	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem)
+		mem = nfsd_drc_max_mem - nfsd_drc_mem_used;
+	nfsd_drc_mem_used += mem;
+	spin_unlock(&nfsd_drc_lock);
 
 	if (mem < NFSD_SLOT_CACHE_SIZE) {
 		fchan->maxreqs = 0;
@@ -586,6 +586,9 @@ free_session(struct kref *kref)
 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
 	}
+	spin_lock(&nfsd_drc_lock);
+	nfsd_drc_mem_used -= ses->se_fnumslots * NFSD_SLOT_CACHE_SIZE;
+	spin_unlock(&nfsd_drc_lock);
 	kfree(ses);
 }
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 80588cc..37633f5 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -67,6 +67,16 @@ struct timeval			nfssvc_boot;
 DEFINE_MUTEX(nfsd_mutex);
 struct svc_serv 		*nfsd_serv;
 
+/*
+ * nfsd_drc_lock protects nfsd_drc_max_pages and nfsd_drc_pages_used.
+ * nfsd_drc_max_pages limits the total amount of memory available for
+ * version 4.1 DRC caches.
+ * nfsd_drc_pages_used tracks the current version 4.1 DRC memory usage.
+ */
+spinlock_t	nfsd_drc_lock;
+unsigned int	nfsd_drc_max_mem;
+unsigned int	nfsd_drc_mem_used;
+
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
 static struct svc_version *	nfsd_acl_version[] = {
@@ -238,12 +248,13 @@ static void set_max_drc(void)
 {
 	/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
 	#define NFSD_DRC_SIZE_SHIFT	10
-	nfsd_serv->sv_drc_max_mem = (nr_free_buffer_pages()
+	nfsd_drc_max_mem = (nr_free_buffer_pages()
 					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
-	nfsd_serv->sv_drc_mem_used = 0;
+	nfsd_drc_mem_used = 0;
+	spin_lock_init(&nfsd_drc_lock);
 	dprintk("%s svc_drc_max_mem %u [in pages %lu]\n", __func__,
-		nfsd_serv->sv_drc_max_mem,
-		nfsd_serv->sv_drc_max_mem / PAGE_SIZE);
+		nfsd_drc_max_mem,
+		nfsd_drc_max_mem / PAGE_SIZE);
 }
 
 int nfsd_create_serv(void)
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2b49d67..a0cfb30 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -56,6 +56,11 @@ extern struct svc_version	nfsd_version2, nfsd_version3,
 extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern struct svc_serv		*nfsd_serv;
+extern spinlock_t		nfsd_drc_lock;
+extern unsigned int		nfsd_drc_max_mem;
+extern unsigned int		nfsd_drc_mem_used;
+
+
 
 extern struct seq_operations nfs_exports_op;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 243508e..d0d8bf4 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -94,8 +94,6 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
-	unsigned int		sv_drc_max_mem; /* Total pages for DRC */
-	unsigned int		sv_drc_mem_used;/* DRC pages used */
 };
 
 /*
-- 
1.6.3

