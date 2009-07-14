From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd41: use globals for DRC limits
Date: Tue, 14 Jul 2009 18:02:07 -0400
Message-ID: <20090714220207.GJ2551@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51415 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361AbZGNWCK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2009 18:02:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've applied the following for 2.6.32.

--b.

commit 4bd9b0f4afc76cf972578c702e1bc1b6f2d10ba5
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Jun 24 15:37:45 2009 -0400

    nfsd41: use globals for DRC limits
    
    The version 4.1 DRC memory limit and tracking variables are server wide and
    session specific. Replace struct svc_serv fields with globals.
    Stop using the svc_serv sv_lock.
    
    Add a spinlock to serialize access to the DRC limit management variables which
    change on session creation and deletion (usage counter) or (future)
    administrative action to adjust the total DRC memory limit.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 980a216..2e6a44e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -430,11 +430,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
 	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
 		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
 
-	spin_lock(&nfsd_serv->sv_lock);
-	if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
-		np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
-	nfsd_serv->sv_drc_pages_used += np;
-	spin_unlock(&nfsd_serv->sv_lock);
+	spin_lock(&nfsd_drc_lock);
+	if (np + nfsd_drc_pages_used > nfsd_drc_max_pages)
+		np = nfsd_drc_max_pages - nfsd_drc_pages_used;
+	nfsd_drc_pages_used += np;
+	spin_unlock(&nfsd_drc_lock);
 
 	if (np <= 0) {
 		status = nfserr_resource;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d4c9884..78d8fcd 100644
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
+unsigned int	nfsd_drc_max_pages;
+unsigned int	nfsd_drc_pages_used;
+
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
 static struct svc_version *	nfsd_acl_version[] = {
@@ -238,11 +248,12 @@ static void set_max_drc(void)
 {
 	/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
 	#define NFSD_DRC_SIZE_SHIFT	7
-	nfsd_serv->sv_drc_max_pages = nr_free_buffer_pages()
+	nfsd_drc_max_pages = nr_free_buffer_pages()
 						>> NFSD_DRC_SIZE_SHIFT;
-	nfsd_serv->sv_drc_pages_used = 0;
-	dprintk("%s svc_drc_max_pages %u\n", __func__,
-		nfsd_serv->sv_drc_max_pages);
+	nfsd_drc_pages_used = 0;
+	spin_lock_init(&nfsd_drc_lock);
+	dprintk("%s nfsd_drc_max_pages %u\n", __func__,
+		nfsd_drc_max_pages);
 }
 
 int nfsd_create_serv(void)
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2b49d67..2571f85 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -56,6 +56,9 @@ extern struct svc_version	nfsd_version2, nfsd_version3,
 extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern struct svc_serv		*nfsd_serv;
+extern spinlock_t		nfsd_drc_lock;
+extern unsigned int		nfsd_drc_max_pages;
+extern unsigned int		nfsd_drc_pages_used;
 
 extern struct seq_operations nfs_exports_op;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index ea80096..52e8cb0 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -94,8 +94,6 @@ struct svc_serv {
 	struct module *		sv_module;	/* optional module to count when
 						 * adding threads */
 	svc_thread_fn		sv_function;	/* main function for threads */
-	unsigned int		sv_drc_max_pages; /* Total pages for DRC */
-	unsigned int		sv_drc_pages_used;/* DRC pages used */
 #if defined(CONFIG_NFS_V4_1)
 	struct list_head	sv_cb_list;	/* queue for callback requests
 						 * that arrive over the same
