From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: fail module init on reply cache init failure
Date: Thu, 15 Nov 2007 16:56:58 -0500
Message-ID: <1195163823-24609-4-git-send-email-bfields@citi.umich.edu>
References: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-2-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <1195163823-24609-3-git-send-email-bfields@citi.umich.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
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
1.5.3.5.561.g140d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
