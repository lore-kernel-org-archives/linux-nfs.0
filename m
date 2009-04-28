From: andros@netapp.com
Subject: [PATCH 10/31] nfsd41: use globals for DRC memory use management
Date: Tue, 28 Apr 2009 12:59:44 -0400
Message-ID: <1240938005-23778-10-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759726AbZD1RAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:43 -0400
In-Reply-To: <1240938005-23778-9-git-send-email-andros@netapp.com>
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
---
 fs/nfsd/nfs4state.c        |   11 +++++++----
 fs/nfsd/nfssvc.c           |   19 +++++++++++++++----
 include/linux/nfsd/nfsd.h  |    5 +++++
 include/linux/sunrpc/svc.h |    2 --
 4 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d12220c..a9e722e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -416,7 +416,7 @@ gen_sessionid(struct nfsd4_session *ses)
 
 /*
  * Give the client the number of slots it requests bound by
- * NFSD_MAX_SLOTS_PER_SESSION and by sv_drc_max_pages.
+ * NFSD_MAX_SLOTS_PER_SESSION and by nfsd_drc_max_mem.
  *
  * If we run out of reserved DRC memory we should (up to a point) re-negotiate
  * active sessions and reduce their slot usage to make rooom for new
@@ -434,9 +434,9 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
 	mem = fchan->maxreqs * NFSD_SLOT_CACHE_SIZE;
 
 	spin_lock(&nfsd_serv->sv_lock);
-	if (mem + nfsd_serv->sv_drc_mem_used > nfsd_serv->sv_drc_max_mem)
-		mem = nfsd_serv->sv_drc_max_mem - nfsd_serv->sv_drc_mem_used;
-	nfsd_serv->sv_drc_mem_used += mem;
+	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem)
+		mem = nfsd_drc_max_mem - nfsd_drc_mem_used;
+	nfsd_drc_mem_used += mem;
 	spin_unlock(&nfsd_serv->sv_lock);
 
 	if (mem < NFSD_SLOT_CACHE_SIZE) {
@@ -588,6 +588,9 @@ free_session(struct kref *kref)
 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
 	}
+	spin_lock(&nfsd_drc_lock);
+	nfsd_drc_mem_used -= ses->se_fchannel.maxreqs * NFSD_SLOT_CACHE_SIZE;
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
index 9cd6399..23ba7bd 100644
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
1.5.4.3

