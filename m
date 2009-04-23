From: andros@netapp.com
Subject: [PATCH 10/29] nfsd41: change from page to memory based drc limits
Date: Thu, 23 Apr 2009 12:42:49 -0400
Message-ID: <1240504988-9572-11-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754467AbZDWQnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:20 -0400
In-Reply-To: <1240504988-9572-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSD_SLOT_CACHE_SIZE is the size of all encoded operation responses (excluding
the sequence operation) that we want to cache.

As an estimate, use the same size as the v3 DRC upper limit.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   13 +++++++------
 fs/nfsd/nfssvc.c           |   11 ++++++-----
 include/linux/nfsd/state.h |    2 ++
 include/linux/sunrpc/svc.h |    4 ++--
 4 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d570472..6bcf494 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -425,24 +425,25 @@ gen_sessionid(struct nfsd4_session *ses)
  */
 static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
 {
-	int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
+	int status = 0, mem;
 
 	if (fchan->maxreqs < 1)
 		return nfserr_inval;
 	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
 		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
 
+	mem = fchan->maxreqs * NFSD_SLOT_CACHE_SIZE;
 	spin_lock(&nfsd_serv->sv_drc_lock);
-	if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
-		np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
-	nfsd_serv->sv_drc_pages_used += np;
+	if (mem + nfsd_serv->sv_drc_mem_used > nfsd_serv->sv_drc_max_mem)
+		mem = nfsd_serv->sv_drc_max_mem - nfsd_serv->sv_drc_mem_used;
+	nfsd_serv->sv_drc_mem_used += mem;
 	spin_unlock(&nfsd_serv->sv_drc_lock);
 
-	if (np <= 0) {
+	if (mem < NFSD_SLOT_CACHE_SIZE) {
 		status = nfserr_resource;
 		fchan->maxreqs = 0;
 	} else
-		fchan->maxreqs = np / NFSD_PAGES_PER_SLOT;
+		fchan->maxreqs = mem / NFSD_SLOT_CACHE_SIZE;
 
 	return status;
 }
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cbba4a9..125f2ef 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -238,11 +238,12 @@ static void set_max_drc(void)
 {
 	/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
 	#define NFSD_DRC_SIZE_SHIFT	7
-	nfsd_serv->sv_drc_max_pages = nr_free_buffer_pages()
-						>> NFSD_DRC_SIZE_SHIFT;
-	nfsd_serv->sv_drc_pages_used = 0;
-	dprintk("%s svc_drc_max_pages %u\n", __func__,
-		nfsd_serv->sv_drc_max_pages);
+	nfsd_serv->sv_drc_max_mem = (nr_free_buffer_pages()
+					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
+	nfsd_serv->sv_drc_mem_used = 0;
+	dprintk("%s svc_drc_max_mem %u [in pages %lu]\n", __func__,
+		nfsd_serv->sv_drc_max_mem,
+		nfsd_serv->sv_drc_max_mem / PAGE_SIZE);
 }
 
 int nfsd_create_serv(void)
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 87f3eaa..473eb0d 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -109,6 +109,8 @@ struct nfs4_callback {
 #define NFSD_MAX_SLOTS_PER_SESSION	128
 /* Maximum number of pages per slot cache entry */
 #define NFSD_PAGES_PER_SLOT	1
+/* Size of each slot cache entry */
+#define NFSD_SLOT_CACHE_SIZE           1024
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 0d2315c..dc21169 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -95,8 +95,8 @@ struct svc_serv {
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
 	spinlock_t              sv_drc_lock;
-	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
-	unsigned int		sv_drc_pages_used;/* DRC pages used */
+	unsigned int		sv_drc_max_mem; /* Total memory for DRC */
+	unsigned int		sv_drc_mem_used;/* DRC memory used */
 };
 
 /*
-- 
1.5.4.3

