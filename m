From: andros@netapp.com
Subject: [PATCH 08/30] nfsd41: change from page to memory based drc limits
Date: Mon,  8 Jun 2009 14:20:49 -0400
Message-ID: <1244485271-7461-9-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10001 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbZFHSVV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:21 -0400
In-Reply-To: <1244485271-7461-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSD_SLOT_CACHE_SIZE is the size of all encoded operation responses (excluding
the sequence operation) that we want to cache.

Adjust NFSD_DRC_SIZE_SHIFT to reflect using 512 bytes instead of PAGE_SIZE.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   29 +++++++++++++++--------------
 fs/nfsd/nfssvc.c           |   13 +++++++------
 include/linux/nfsd/state.h |    1 +
 include/linux/sunrpc/svc.h |    4 ++--
 4 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3b05df3..52bd99c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -418,33 +418,34 @@ gen_sessionid(struct nfsd4_session *ses)
  * Give the client the number of slots it requests bound by
  * NFSD_MAX_SLOTS_PER_SESSION and by sv_drc_max_pages.
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
 	spin_lock(&nfsd_serv->sv_lock);
-	if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
-		np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
-	nfsd_serv->sv_drc_pages_used += np;
+	if (mem + nfsd_serv->sv_drc_mem_used > nfsd_serv->sv_drc_max_mem)
+		mem = nfsd_serv->sv_drc_max_mem - nfsd_serv->sv_drc_mem_used;
+	nfsd_serv->sv_drc_mem_used += mem;
 	spin_unlock(&nfsd_serv->sv_lock);
 
-	if (np <= 0) {
-		status = nfserr_resource;
+	if (mem < NFSD_SLOT_CACHE_SIZE) {
 		fchan->maxreqs = 0;
-	} else
-		fchan->maxreqs = np / NFSD_PAGES_PER_SLOT;
-
-	return status;
+		return nfserr_resource;
+	} else {
+		fchan->maxreqs = mem / NFSD_SLOT_CACHE_SIZE;
+		return 0;
+	}
 }
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cbba4a9..80588cc 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -237,12 +237,13 @@ void nfsd_reset_versions(void)
 static void set_max_drc(void)
 {
 	/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
-	#define NFSD_DRC_SIZE_SHIFT	7
-	nfsd_serv->sv_drc_max_pages = nr_free_buffer_pages()
-						>> NFSD_DRC_SIZE_SHIFT;
-	nfsd_serv->sv_drc_pages_used = 0;
-	dprintk("%s svc_drc_max_pages %u\n", __func__,
-		nfsd_serv->sv_drc_max_pages);
+	#define NFSD_DRC_SIZE_SHIFT	10
+	nfsd_serv->sv_drc_max_mem = (nr_free_buffer_pages()
+					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
+	nfsd_serv->sv_drc_mem_used = 0;
+	dprintk("%s svc_drc_max_mem %u [in pages %lu]\n", __func__,
+		nfsd_serv->sv_drc_max_mem,
+		nfsd_serv->sv_drc_max_mem / PAGE_SIZE);
 }
 
 int nfsd_create_serv(void)
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index aeb5e82..28ddb32 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -103,6 +103,7 @@ struct nfs4_callback {
 #define NFSD_MAX_SLOTS_PER_SESSION	128
 /* Maximum number of pages per slot cache entry */
 #define NFSD_PAGES_PER_SLOT	1
+#define NFSD_SLOT_CACHE_SIZE		512
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2a30775..243508e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -94,8 +94,8 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
-	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
-	unsigned int		sv_drc_pages_used;/* DRC pages used */
+	unsigned int		sv_drc_max_mem; /* Total pages for DRC */
+	unsigned int		sv_drc_mem_used;/* DRC pages used */
 };
 
 /*
-- 
1.5.4.3

