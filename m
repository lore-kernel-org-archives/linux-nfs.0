From: andros@netapp.com
Subject: [PATCH 2/5] nfsd41: change from page to memory based drc limits
Date: Wed, 24 Jun 2009 15:37:46 -0400
Message-ID: <1245872278-18743-3-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44047 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbZFXTh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:37:59 -0400
In-Reply-To: <1245872278-18743-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSD_SLOT_CACHE_SIZE is the size of all encoded operation responses (excluding
the sequence operation) that we want to cache.

Adjust NFSD_DRC_SIZE_SHIFT to reflect using 512 bytes instead of PAGE_SIZE.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   30 ++++++++++++++----------------
 fs/nfsd/nfssvc.c           |   17 +++++++++--------
 include/linux/nfsd/nfsd.h  |    4 ++--
 include/linux/nfsd/state.h |    1 +
 4 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e6a44e..b4a536d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -414,35 +414,33 @@ gen_sessionid(struct nfsd4_session *ses)
 
 /*
  * Give the client the number of slots it requests bound by
- * NFSD_MAX_SLOTS_PER_SESSION and by sv_drc_max_pages.
+ * NFSD_MAX_SLOTS_PER_SESSION and by nfsd_drc_max_mem.
  *
- * If we run out of pages (sv_drc_pages_used == sv_drc_max_pages) we
- * should (up to a point) re-negotiate active sessions and reduce their
- * slot usage to make rooom for new connections. For now we just fail the
- * create session.
+ * If we run out of reserved DRC memory we should (up to a point) re-negotiate
+ * active sessions and reduce their slot usage to make rooom for new
+ * connections. For now we just fail the create session.
  */
 static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
 {
-	int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
+	int mem;
 
 	if (fchan->maxreqs < 1)
 		return nfserr_inval;
 	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
 		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
 
+	mem = fchan->maxreqs * NFSD_SLOT_CACHE_SIZE;
+
 	spin_lock(&nfsd_drc_lock);
-	if (np + nfsd_drc_pages_used > nfsd_drc_max_pages)
-		np = nfsd_drc_max_pages - nfsd_drc_pages_used;
-	nfsd_drc_pages_used += np;
+	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem)
+		mem = nfsd_drc_max_mem - nfsd_drc_mem_used;
+	nfsd_drc_mem_used += mem;
 	spin_unlock(&nfsd_drc_lock);
 
-	if (np <= 0) {
-		status = nfserr_resource;
-		fchan->maxreqs = 0;
-	} else
-		fchan->maxreqs = np / NFSD_PAGES_PER_SLOT;
-
-	return status;
+	fchan->maxreqs = mem / NFSD_SLOT_CACHE_SIZE;
+	if (fchan->maxreqs == 0)
+		return nfserr_resource;
+	return 0;
 }
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 78d8fcd..1793dba 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -74,8 +74,8 @@ struct svc_serv 		*nfsd_serv;
  * nfsd_drc_pages_used tracks the current version 4.1 DRC memory usage.
  */
 spinlock_t	nfsd_drc_lock;
-unsigned int	nfsd_drc_max_pages;
-unsigned int	nfsd_drc_pages_used;
+unsigned int	nfsd_drc_max_mem;
+unsigned int	nfsd_drc_mem_used;
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
@@ -247,13 +247,14 @@ void nfsd_reset_versions(void)
 static void set_max_drc(void)
 {
 	/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
-	#define NFSD_DRC_SIZE_SHIFT	7
-	nfsd_drc_max_pages = nr_free_buffer_pages()
-						>> NFSD_DRC_SIZE_SHIFT;
-	nfsd_drc_pages_used = 0;
+	#define NFSD_DRC_SIZE_SHIFT	10
+	nfsd_drc_max_mem = (nr_free_buffer_pages()
+					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
+	nfsd_drc_mem_used = 0;
 	spin_lock_init(&nfsd_drc_lock);
-	dprintk("%s nfsd_drc_max_pages %u\n", __func__,
-		nfsd_drc_max_pages);
+	dprintk("%s nfsd_drc_max_mem %u [in pages %lu]\n", __func__,
+		nfsd_drc_max_mem,
+		nfsd_drc_max_mem / PAGE_SIZE);
 }
 
 int nfsd_create_serv(void)
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2571f85..2812ed5 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -57,8 +57,8 @@ extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern struct svc_serv		*nfsd_serv;
 extern spinlock_t		nfsd_drc_lock;
-extern unsigned int		nfsd_drc_max_pages;
-extern unsigned int		nfsd_drc_pages_used;
+extern unsigned int		nfsd_drc_max_mem;
+extern unsigned int		nfsd_drc_mem_used;
 
 extern struct seq_operations nfs_exports_op;
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index f5a95fd..10b6b30 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -98,6 +98,7 @@ struct nfs4_cb_conn {
 /* Maximum number of pages per slot cache entry */
 #define NFSD_PAGES_PER_SLOT	1
 /* Maximum number of operations per session compound */
+#define NFSD_SLOT_CACHE_SIZE		512
 #define NFSD_MAX_OPS_PER_COMPOUND	16
 
 struct nfsd4_cache_entry {
-- 
1.5.4.3

