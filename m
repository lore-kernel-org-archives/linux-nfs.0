From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 018/100] nfsd: fail module init on reply cache init failure
Date: Fri, 25 Jan 2008 18:15:58 -0500
Message-ID: <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47336 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758613AbYAYXR0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:26 -0500
In-Reply-To: <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the reply cache initialization fails due to a kmalloc failure,
currently we try to soldier on with a reduced (or nonexistant) reply
cache.

Better to just fail immediately: the failure is then much easier to
understand and debug, and it could save us complexity in some later
code.  (But actually, it doesn't help currently because the cache is
also turned off in some odd failure cases; we should probably find a
better way to handle those failure cases some day.)

Fix some minor style problems while we're at it, and rename
nfsd_cache_init() to remove the need for a comment describing it.

Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfscache.c         |   28 +++++++++++++---------------
 fs/nfsd/nfsctl.c           |   11 +++++++----
 include/linux/nfsd/cache.h |    4 ++--
 3 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 578f2c9..92cb5ae 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -44,17 +44,18 @@ static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
  */
 static DEFINE_SPINLOCK(cache_lock);
 
-void
-nfsd_cache_init(void)
+int
+nfsd_reply_cache_init(void)
 {
 	struct svc_cacherep	*rp;
 	int			i;
 
 	INIT_LIST_HEAD(&lru_head);
 	i = CACHESIZE;
-	while(i) {
+	while (i) {
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-		if (!rp) break;
+		if (!rp)
+			goto out_nomem;
 		list_add(&rp->c_lru, &lru_head);
 		rp->c_state = RC_UNUSED;
 		rp->c_type = RC_NOCACHE;
@@ -62,23 +63,20 @@ nfsd_cache_init(void)
 		i--;
 	}
 
-	if (i)
-		printk (KERN_ERR "nfsd: cannot allocate all %d cache entries, only got %d\n",
-			CACHESIZE, CACHESIZE-i);
-
 	hash_list = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
-	if (!hash_list) {
-		nfsd_cache_shutdown();
-		printk (KERN_ERR "nfsd: cannot allocate %Zd bytes for hash list\n",
-			HASHSIZE * sizeof(struct hlist_head));
-		return;
-	}
+	if (!hash_list)
+		goto out_nomem;
 
 	cache_disabled = 0;
+	return 0;
+out_nomem:
+	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
+	nfsd_reply_cache_shutdown();
+	return -ENOMEM;
 }
 
 void
-nfsd_cache_shutdown(void)
+nfsd_reply_cache_shutdown(void)
 {
 	struct svc_cacherep	*rp;
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index ecf3779..2bfda9b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -683,7 +683,9 @@ static int __init init_nfsd(void)
 	if (retval)
 		return retval;
 	nfsd_stat_init();	/* Statistics */
-	nfsd_cache_init();	/* RPC reply cache */
+	retval = nfsd_reply_cache_init();
+	if (retval)
+		goto out_free_stat;
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
 	nfsd_idmap_init();      /* Name to ID mapping */
@@ -700,11 +702,12 @@ static int __init init_nfsd(void)
 out_free_all:
 	nfsd_idmap_shutdown();
 	nfsd_export_shutdown();
-	nfsd_cache_shutdown();
+	nfsd_reply_cache_shutdown();
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
-	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
+out_free_stat:
+	nfsd_stat_shutdown();
 	nfsd4_free_slabs();
 	return retval;
 }
@@ -712,7 +715,7 @@ out_free_all:
 static void __exit exit_nfsd(void)
 {
 	nfsd_export_shutdown();
-	nfsd_cache_shutdown();
+	nfsd_reply_cache_shutdown();
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 007480c..7b5d784 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -72,8 +72,8 @@ enum {
  */
 #define RC_DELAY		(HZ/5)
 
-void	nfsd_cache_init(void);
-void	nfsd_cache_shutdown(void);
+int	nfsd_reply_cache_init(void);
+void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *, int);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
 
-- 
1.5.4.rc2.60.gb2e62

