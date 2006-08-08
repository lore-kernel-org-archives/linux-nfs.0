From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 1 of 5] knfsd: make readahead params cache SMP-friendly
Date: Tue, 08 Aug 2006 14:05:51 +1000
Message-ID: <1155009951.29877.231.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAIqs-0001uV-Fz
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:05:58 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIqs-0007J1-Mk
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:05:59 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

knfsd: make the nfsd read-ahead params cache more SMP-friendly by
changing the single global list and lock into a fixed 16-bucket
hashtable with per-bucket locks.  This reduces spinlock contention
in nfsd_read() on read-heavy workloads on multiprocessor servers.

Testing was on a 4 CPU 4 NIC Altix using 4 IRIX clients each doing 1K
streaming reads at full line rate.  The server had 128 nfsd threads,
which sizes the RA cache at 256 entries, of which only a handful
were used.  Flat profiling shows nfsd_read(), including the inlined
nfsd_get_raparms(), taking 10.4% of each CPU.  This patch drops the
contribution from nfsd() to 1.71% for each CPU.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/vfs.c |   60 ++++++++++++++++++++++++++++++++++-------------
 1 files changed, 44 insertions(+), 16 deletions(-)

Index: linux-2.6.18-rc2/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.18-rc2.orig/fs/nfsd/vfs.c	2006-08-01 17:53:32.936177414 +1000
+++ linux-2.6.18-rc2/fs/nfsd/vfs.c	2006-08-04 16:04:59.453416628 +1000
@@ -54,6 +54,7 @@
 #include <linux/nfsd_idmap.h>
 #include <linux/security.h>
 #endif /* CONFIG_NFSD_V4 */
+#include <linux/jhash.h>
 
 #include <asm/uaccess.h>
 
@@ -81,10 +82,19 @@ struct raparms {
 	dev_t			p_dev;
 	int			p_set;
 	struct file_ra_state	p_ra;
+	unsigned int		p_hindex;
 };
 
+struct raparm_hbucket {
+	struct raparms		*pb_head;
+	spinlock_t		pb_lock;
+} ____cacheline_aligned_in_smp;
+
 static struct raparms *		raparml;
-static struct raparms *		raparm_cache;
+#define RAPARM_HASH_BITS	4
+#define RAPARM_HASH_SIZE	(1<<RAPARM_HASH_BITS)
+#define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
+static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
 
 /* 
  * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
@@ -743,16 +753,20 @@ nfsd_sync_dir(struct dentry *dp)
  * Obtain the readahead parameters for the file
  * specified by (dev, ino).
  */
-static DEFINE_SPINLOCK(ra_lock);
 
 static inline struct raparms *
 nfsd_get_raparms(dev_t dev, ino_t ino)
 {
 	struct raparms	*ra, **rap, **frap = NULL;
 	int depth = 0;
+	unsigned int hash;
+	struct raparm_hbucket *rab;
+
+	hash = jhash_2words(dev, ino, 0xfeedbeef) & RAPARM_HASH_MASK;
+	rab = &raparm_hash[hash];
 
-	spin_lock(&ra_lock);
-	for (rap = &raparm_cache; (ra = *rap); rap = &ra->p_next) {
+	spin_lock(&rab->pb_lock);
+	for (rap = &rab->pb_head; (ra = *rap); rap = &ra->p_next) {
 		if (ra->p_ino == ino && ra->p_dev == dev)
 			goto found;
 		depth++;
@@ -761,7 +775,7 @@ nfsd_get_raparms(dev_t dev, ino_t ino)
 	}
 	depth = nfsdstats.ra_size*11/10;
 	if (!frap) {	
-		spin_unlock(&ra_lock);
+		spin_unlock(&rab->pb_lock);
 		return NULL;
 	}
 	rap = frap;
@@ -769,15 +783,16 @@ nfsd_get_raparms(dev_t dev, ino_t ino)
 	ra->p_dev = dev;
 	ra->p_ino = ino;
 	ra->p_set = 0;
+	ra->p_hindex = hash;
 found:
-	if (rap != &raparm_cache) {
+	if (rap != &rab->pb_head) {
 		*rap = ra->p_next;
-		ra->p_next   = raparm_cache;
-		raparm_cache = ra;
+		ra->p_next   = rab->pb_head;
+		rab->pb_head = ra;
 	}
 	ra->p_count++;
 	nfsdstats.ra_depth[depth*10/nfsdstats.ra_size]++;
-	spin_unlock(&ra_lock);
+	spin_unlock(&rab->pb_lock);
 	return ra;
 }
 
@@ -852,11 +867,12 @@ nfsd_vfs_read(struct svc_rqst *rqstp, st
 
 	/* Write back readahead params */
 	if (ra) {
-		spin_lock(&ra_lock);
+		struct raparm_hbucket *rab = &raparm_hash[ra->p_hindex];
+		spin_lock(&rab->pb_lock);
 		ra->p_ra = file->f_ra;
 		ra->p_set = 1;
 		ra->p_count--;
-		spin_unlock(&ra_lock);
+		spin_unlock(&rab->pb_lock);
 	}
 
 	if (err >= 0) {
@@ -1832,11 +1848,11 @@ nfsd_permission(struct svc_export *exp, 
 void
 nfsd_racache_shutdown(void)
 {
-	if (!raparm_cache)
+	if (!raparml)
 		return;
 	dprintk("nfsd: freeing readahead buffers.\n");
 	kfree(raparml);
-	raparm_cache = raparml = NULL;
+	raparml = NULL;
 }
 /*
  * Initialize readahead param cache
@@ -1845,19 +1861,31 @@ int
 nfsd_racache_init(int cache_size)
 {
 	int	i;
+	int	j = 0;
+	int	nperbucket;
 
-	if (raparm_cache)
+
+	if (raparml)
 		return 0;
+	if (cache_size < 2*RAPARM_HASH_SIZE)
+		cache_size = 2*RAPARM_HASH_SIZE;
 	raparml = kmalloc(sizeof(struct raparms) * cache_size, GFP_KERNEL);
 
 	if (raparml != NULL) {
 		dprintk("nfsd: allocating %d readahead buffers.\n",
 			cache_size);
+		for (i = 0 ; i < RAPARM_HASH_SIZE ; i++) {
+			raparm_hash[i].pb_head = NULL;
+			spin_lock_init(&raparm_hash[i].pb_lock);
+		}
+		nperbucket = cache_size >> RAPARM_HASH_BITS;
 		memset(raparml, 0, sizeof(struct raparms) * cache_size);
 		for (i = 0; i < cache_size - 1; i++) {
-			raparml[i].p_next = raparml + i + 1;
+			if (i % nperbucket == 0)
+				raparm_hash[j++].pb_head = raparml + i;
+			if (i % nperbucket < nperbucket-1)
+				raparml[i].p_next = raparml + i + 1;
 		}
-		raparm_cache = raparml;
 	} else {
 		printk(KERN_WARNING
 		       "nfsd: Could not allocate memory read-ahead cache.\n");


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
