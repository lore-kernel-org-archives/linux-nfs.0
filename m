From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [PATCH 3/3] Modify nfs's DRC to use sunrpc's common DRC
Date: Mon, 02 Nov 2009 17:45:40 +0800
Message-ID: <4AEEAA44.2030600@cn.fujitsu.com>
References: <4AEEA622.6000705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, bfields@fieldses.org,
	mingo@elte.hu
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59729 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754152AbZKBJof (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 04:44:35 -0500
In-Reply-To: <4AEEA622.6000705@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1. define a global variable nfsd_dc to record the request;
2. modify the nfsd_dispatch() to using sunrpc's DRC;
3. delete file "fs/nfsd/nfscache.c" which will not be used;
4. modify file "include/linux/nfsd/cache.h", only hold the 
   declared of function nfsd4_set_statp();
5. modify those file which include "include/linux/nfsd/cache.h"
   to include "linux/sunrpc/drc.h", because they are same almost;
6. delete rchits, rcmisses, rcnocache from "struct nfsd_stats", 
   which be save at "struct drc_cache".

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 arch/parisc/kernel/sys_parisc32.c |    2 +-
 arch/s390/kernel/compat_linux.c   |    2 +-
 arch/sparc/kernel/sys_sparc32.c   |    2 +-
 fs/nfsd/Makefile                  |    2 +-
 fs/nfsd/nfs2acl.c                 |    2 +-
 fs/nfsd/nfs3acl.c                 |    2 +-
 fs/nfsd/nfs3proc.c                |    2 +-
 fs/nfsd/nfs4proc.c                |    2 +-
 fs/nfsd/nfs4state.c               |    2 +-
 fs/nfsd/nfscache.c                |  330 -------------------------------------
 fs/nfsd/nfsctl.c                  |   10 +-
 fs/nfsd/nfsproc.c                 |    2 +-
 fs/nfsd/nfssvc.c                  |   13 +-
 fs/nfsd/stats.c                   |    9 +-
 include/linux/nfsd/cache.h        |   62 -------
 include/linux/nfsd/stats.h        |    3 -
 16 files changed, 30 insertions(+), 417 deletions(-)
 delete mode 100644 fs/nfsd/nfscache.c

diff --git a/arch/parisc/kernel/sys_parisc32.c b/arch/parisc/kernel/sys_parisc32.c
index 561388b..3c7498e 100644
--- a/arch/parisc/kernel/sys_parisc32.c
+++ b/arch/parisc/kernel/sys_parisc32.c
@@ -29,8 +29,8 @@
 #include <linux/nfs_fs.h>
 #include <linux/ncp_fs.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/poll.h>
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 0debcec..d441e48 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -35,8 +35,8 @@
 #include <linux/quota.h>
 #include <linux/module.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/poll.h>
diff --git a/arch/sparc/kernel/sys_sparc32.c b/arch/sparc/kernel/sys_sparc32.c
index 04e28b2..dca7244 100644
--- a/arch/sparc/kernel/sys_sparc32.c
+++ b/arch/sparc/kernel/sys_sparc32.c
@@ -27,8 +27,8 @@
 #include <linux/quota.h>
 #include <linux/module.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/poll.h>
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 9b118ee..fdddb23 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -5,7 +5,7 @@
 obj-$(CONFIG_NFSD)	+= nfsd.o
 
 nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
-			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
+			   export.o auth.o lockd.o nfsxdr.o stats.o
 nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 4e3219e..06c7293 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -7,9 +7,9 @@
  */
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfs.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/xdr3.h>
 #include <linux/posix_acl.h>
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 9981dbb..f6527d3 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -7,9 +7,9 @@
  */
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfs3.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr3.h>
 #include <linux/posix_acl.h>
 #include <linux/nfsacl.h>
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index a713c41..932a343 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -21,8 +21,8 @@
 #include <linux/magic.h>
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr3.h>
 #include <linux/nfs3.h>
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bebc0c2..5ad2212 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -41,8 +41,8 @@
 #include <linux/file.h>
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2153f9b..efde9c8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -39,8 +39,8 @@
 #include <linux/slab.h>
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/workqueue.h>
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
deleted file mode 100644
index 4638635..0000000
--- a/fs/nfsd/nfscache.c
+++ /dev/null
@@ -1,330 +0,0 @@
-/*
- * linux/fs/nfsd/nfscache.c
- *
- * Request reply cache. This is currently a global cache, but this may
- * change in the future and be a per-client cache.
- *
- * This code is heavily inspired by the 44BSD implementation, although
- * it does things a bit differently.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
- */
-
-#include <linux/kernel.h>
-#include <linux/time.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/spinlock.h>
-#include <linux/list.h>
-
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
-
-/* Size of reply cache. Common values are:
- * 4.3BSD:	128
- * 4.4BSD:	256
- * Solaris2:	1024
- * DEC Unix:	512-4096
- */
-#define CACHESIZE		1024
-#define HASHSIZE		64
-
-static struct hlist_head *	cache_hash;
-static struct list_head 	lru_head;
-static int			cache_disabled = 1;
-
-/*
- * Calculate the hash index from an XID.
- */
-static inline u32 request_hash(u32 xid)
-{
-	u32 h = xid;
-	h ^= (xid >> 24);
-	return h & (HASHSIZE-1);
-}
-
-static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
-
-/*
- * locking for the reply cache:
- * A cache entry is "single use" if c_state == RC_INPROG
- * Otherwise, it when accessing _prev or _next, the lock must be held.
- */
-static DEFINE_SPINLOCK(cache_lock);
-
-int nfsd_reply_cache_init(void)
-{
-	struct svc_cacherep	*rp;
-	int			i;
-
-	INIT_LIST_HEAD(&lru_head);
-	i = CACHESIZE;
-	while (i) {
-		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-		if (!rp)
-			goto out_nomem;
-		list_add(&rp->c_lru, &lru_head);
-		rp->c_state = RC_UNUSED;
-		rp->c_type = RC_NOCACHE;
-		INIT_HLIST_NODE(&rp->c_hash);
-		i--;
-	}
-
-	cache_hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
-	if (!cache_hash)
-		goto out_nomem;
-
-	cache_disabled = 0;
-	return 0;
-out_nomem:
-	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
-	nfsd_reply_cache_shutdown();
-	return -ENOMEM;
-}
-
-void nfsd_reply_cache_shutdown(void)
-{
-	struct svc_cacherep	*rp;
-
-	while (!list_empty(&lru_head)) {
-		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
-		if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
-			kfree(rp->c_replvec.iov_base);
-		list_del(&rp->c_lru);
-		kfree(rp);
-	}
-
-	cache_disabled = 1;
-
-	kfree (cache_hash);
-	cache_hash = NULL;
-}
-
-/*
- * Move cache entry to end of LRU list
- */
-static void
-lru_put_end(struct svc_cacherep *rp)
-{
-	list_move_tail(&rp->c_lru, &lru_head);
-}
-
-/*
- * Move a cache entry from one hash list to another
- */
-static void
-hash_refile(struct svc_cacherep *rp)
-{
-	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, cache_hash + request_hash(rp->c_xid));
-}
-
-/*
- * Try to find an entry matching the current call in the cache. When none
- * is found, we grab the oldest unlocked entry off the LRU list.
- * Note that no operation within the loop may sleep.
- */
-int
-nfsd_cache_lookup(struct svc_rqst *rqstp, int type)
-{
-	struct hlist_node	*hn;
-	struct hlist_head 	*rh;
-	struct svc_cacherep	*rp;
-	__be32			xid = rqstp->rq_xid;
-	u32			proto =  rqstp->rq_prot,
-				vers = rqstp->rq_vers,
-				proc = rqstp->rq_proc;
-	unsigned long		age;
-	int rtn;
-
-	rqstp->rq_cacherep = NULL;
-	if (cache_disabled || type == RC_NOCACHE) {
-		nfsdstats.rcnocache++;
-		return RC_DOIT;
-	}
-
-	spin_lock(&cache_lock);
-	rtn = RC_DOIT;
-
-	rh = &cache_hash[request_hash(xid)];
-	hlist_for_each_entry(rp, hn, rh, c_hash) {
-		if (rp->c_state != RC_UNUSED &&
-		    xid == rp->c_xid && proc == rp->c_proc &&
-		    proto == rp->c_prot && vers == rp->c_vers &&
-		    time_before(jiffies, rp->c_timestamp + 120*HZ) &&
-		    memcmp((char*)&rqstp->rq_addr, (char*)&rp->c_addr, sizeof(rp->c_addr))==0) {
-			nfsdstats.rchits++;
-			goto found_entry;
-		}
-	}
-	nfsdstats.rcmisses++;
-
-	/* This loop shouldn't take more than a few iterations normally */
-	{
-	int	safe = 0;
-	list_for_each_entry(rp, &lru_head, c_lru) {
-		if (rp->c_state != RC_INPROG)
-			break;
-		if (safe++ > CACHESIZE) {
-			printk("nfsd: loop in repcache LRU list\n");
-			cache_disabled = 1;
-			goto out;
-		}
-	}
-	}
-
-	/* All entries on the LRU are in-progress. This should not happen */
-	if (&rp->c_lru == &lru_head) {
-		static int	complaints;
-
-		printk(KERN_WARNING "nfsd: all repcache entries locked!\n");
-		if (++complaints > 5) {
-			printk(KERN_WARNING "nfsd: disabling repcache.\n");
-			cache_disabled = 1;
-		}
-		goto out;
-	}
-
-	rqstp->rq_cacherep = rp;
-	rp->c_state = RC_INPROG;
-	rp->c_xid = xid;
-	rp->c_proc = proc;
-	memcpy(&rp->c_addr, svc_addr_in(rqstp), sizeof(rp->c_addr));
-	rp->c_prot = proto;
-	rp->c_vers = vers;
-	rp->c_timestamp = jiffies;
-
-	hash_refile(rp);
-
-	/* release any buffer */
-	if (rp->c_type == RC_REPLBUFF) {
-		kfree(rp->c_replvec.iov_base);
-		rp->c_replvec.iov_base = NULL;
-	}
-	rp->c_type = RC_NOCACHE;
- out:
-	spin_unlock(&cache_lock);
-	return rtn;
-
-found_entry:
-	/* We found a matching entry which is either in progress or done. */
-	age = jiffies - rp->c_timestamp;
-	rp->c_timestamp = jiffies;
-	lru_put_end(rp);
-
-	rtn = RC_DROPIT;
-	/* Request being processed or excessive rexmits */
-	if (rp->c_state == RC_INPROG || age < RC_DELAY)
-		goto out;
-
-	/* From the hall of fame of impractical attacks:
-	 * Is this a user who tries to snoop on the cache? */
-	rtn = RC_DOIT;
-	if (!rqstp->rq_secure && rp->c_secure)
-		goto out;
-
-	/* Compose RPC reply header */
-	switch (rp->c_type) {
-	case RC_NOCACHE:
-		break;
-	case RC_REPLSTAT:
-		svc_putu32(&rqstp->rq_res.head[0], rp->c_replstat);
-		rtn = RC_REPLY;
-		break;
-	case RC_REPLBUFF:
-		if (!nfsd_cache_append(rqstp, &rp->c_replvec))
-			goto out;	/* should not happen */
-		rtn = RC_REPLY;
-		break;
-	default:
-		printk(KERN_WARNING "nfsd: bad repcache type %d\n", rp->c_type);
-		rp->c_state = RC_UNUSED;
-	}
-
-	goto out;
-}
-
-/*
- * Update a cache entry. This is called from nfsd_dispatch when
- * the procedure has been executed and the complete reply is in
- * rqstp->rq_res.
- *
- * We're copying around data here rather than swapping buffers because
- * the toplevel loop requires max-sized buffers, which would be a waste
- * of memory for a cache with a max reply size of 100 bytes (diropokres).
- *
- * If we should start to use different types of cache entries tailored
- * specifically for attrstat and fh's, we may save even more space.
- *
- * Also note that a cachetype of RC_NOCACHE can legally be passed when
- * nfsd failed to encode a reply that otherwise would have been cached.
- * In this case, nfsd_cache_update is called with statp == NULL.
- */
-void
-nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
-{
-	struct svc_cacherep *rp;
-	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
-	int		len;
-
-	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
-		return;
-
-	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
-	len >>= 2;
-
-	/* Don't cache excessive amounts of data and XDR failures */
-	if (!statp || len > (256 >> 2)) {
-		rp->c_state = RC_UNUSED;
-		return;
-	}
-
-	switch (cachetype) {
-	case RC_REPLSTAT:
-		if (len != 1)
-			printk("nfsd: RC_REPLSTAT/reply len %d!\n",len);
-		rp->c_replstat = *statp;
-		break;
-	case RC_REPLBUFF:
-		cachv = &rp->c_replvec;
-		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
-		if (!cachv->iov_base) {
-			spin_lock(&cache_lock);
-			rp->c_state = RC_UNUSED;
-			spin_unlock(&cache_lock);
-			return;
-		}
-		cachv->iov_len = len << 2;
-		memcpy(cachv->iov_base, statp, len << 2);
-		break;
-	}
-	spin_lock(&cache_lock);
-	lru_put_end(rp);
-	rp->c_secure = rqstp->rq_secure;
-	rp->c_type = cachetype;
-	rp->c_state = RC_DONE;
-	rp->c_timestamp = jiffies;
-	spin_unlock(&cache_lock);
-	return;
-}
-
-/*
- * Copy cached reply to current reply buffer. Should always fit.
- * FIXME as reply is in a page, we should just attach the page, and
- * keep a refcount....
- */
-static int
-nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
-{
-	struct kvec	*vec = &rqstp->rq_res.head[0];
-
-	if (vec->iov_len + data->iov_len > PAGE_SIZE) {
-		printk(KERN_WARNING "nfsd: cached reply too large (%Zd).\n",
-				data->iov_len);
-		return 0;
-	}
-	memcpy((char*)vec->iov_base + vec->iov_len, data->iov_base, data->iov_len);
-	vec->iov_len += data->iov_len;
-	return 1;
-}
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5c01fc1..100bb9f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -31,9 +31,9 @@
 #include <linux/nfsd_idmap.h>
 #include <linux/lockd/bind.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
@@ -42,6 +42,8 @@
 #include <asm/uaccess.h>
 #include <net/ipv6.h>
 
+struct drc_cache nfsd_dc;
+
 /*
  *	We have a single directory with 9 nodes in it.
  */
@@ -1392,7 +1394,7 @@ static int __init init_nfsd(void)
 	if (retval)
 		return retval;
 	nfsd_stat_init();	/* Statistics */
-	retval = nfsd_reply_cache_init();
+	retval = drc_reply_cache_init(&nfsd_dc);
 	if (retval)
 		goto out_free_stat;
 	retval = nfsd_export_init();
@@ -1418,7 +1420,7 @@ out_free_lockd:
 	nfsd_lockd_shutdown();
 	nfsd_export_shutdown();
 out_free_cache:
-	nfsd_reply_cache_shutdown();
+	drc_reply_cache_shutdown(&nfsd_dc);
 out_free_stat:
 	nfsd_stat_shutdown();
 	nfsd4_free_slabs();
@@ -1428,7 +1430,7 @@ out_free_stat:
 static void __exit exit_nfsd(void)
 {
 	nfsd_export_shutdown();
-	nfsd_reply_cache_shutdown();
+	drc_reply_cache_shutdown(&nfsd_dc);
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0eb9c82..4be2996 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -21,8 +21,8 @@
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 
 typedef struct svc_rqst	svc_rqst;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 67ea83e..6206018 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -26,6 +26,7 @@
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/nfsd/nfsd.h>
@@ -42,6 +43,8 @@ extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 struct timeval			nfssvc_boot;
 
+extern struct drc_cache nfsd_dc;
+
 /*
  * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
  * of the svc_serv struct. In particular, ->sv_nrthreads but also to some
@@ -554,7 +557,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	proc = rqstp->rq_procinfo;
 
 	/* Check whether we have this call in the cache. */
-	switch (nfsd_cache_lookup(rqstp, proc->pc_cachetype)) {
+	switch (drc_cache_lookup(rqstp, proc->pc_cachetype, &nfsd_dc)) {
 	case RC_INTR:
 	case RC_DROPIT:
 		return 0;
@@ -569,7 +572,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	if (xdr && !xdr(rqstp, (__be32*)rqstp->rq_arg.head[0].iov_base,
 			rqstp->rq_argp)) {
 		dprintk("nfsd: failed to decode arguments!\n");
-		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
+		drc_cache_update(rqstp, RC_NOCACHE, NULL, &nfsd_dc);
 		*statp = rpc_garbage_args;
 		return 1;
 	}
@@ -586,7 +589,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
 	if (nfserr == nfserr_dropit) {
 		dprintk("nfsd: Dropping request; may be revisited later\n");
-		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
+		drc_cache_update(rqstp, RC_NOCACHE, NULL, &nfsd_dc);
 		return 0;
 	}
 
@@ -602,14 +605,14 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 				rqstp->rq_resp)) {
 			/* Failed to encode result. Release cache entry */
 			dprintk("nfsd: failed to encode result!\n");
-			nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
+			drc_cache_update(rqstp, RC_NOCACHE, NULL, &nfsd_dc);
 			*statp = rpc_system_err;
 			return 1;
 		}
 	}
 
 	/* Store reply in cache. */
-	nfsd_cache_update(rqstp, proc->pc_cachetype, statp + 1);
+	drc_cache_update(rqstp, proc->pc_cachetype, statp + 1, &nfsd_dc);
 	return 1;
 }
 
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index 71944cd..c671a1e 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -31,10 +31,13 @@
 #include <linux/module.h>
 
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 
+extern struct drc_cache nfsd_dc;
+
 struct nfsd_stats	nfsdstats;
 struct svc_stat		nfsd_svcstats = {
 	.program	= &nfsd_program,
@@ -45,9 +48,9 @@ static int nfsd_proc_show(struct seq_file *seq, void *v)
 	int i;
 
 	seq_printf(seq, "rc %u %u %u\nfh %u %u %u %u %u\nio %u %u\n",
-		      nfsdstats.rchits,
-		      nfsdstats.rcmisses,
-		      nfsdstats.rcnocache,
+		      nfsd_dc.rchits,
+		      nfsd_dc.rcmisses,
+		      nfsd_dc.rcnocache,
 		      nfsdstats.fh_stale,
 		      nfsdstats.fh_lookup,
 		      nfsdstats.fh_anon,
diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 3a3f589..a8cbcde 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -13,68 +13,6 @@
 #include <linux/in.h>
 #include <linux/uio.h>
 
-/*
- * Representation of a reply cache entry.
- */
-struct svc_cacherep {
-	struct hlist_node	c_hash;
-	struct list_head	c_lru;
-
-	unsigned char		c_state,	/* unused, inprog, done */
-				c_type,		/* status, buffer */
-				c_secure : 1;	/* req came from port < 1024 */
-	struct sockaddr_in	c_addr;
-	__be32			c_xid;
-	u32			c_prot;
-	u32			c_proc;
-	u32			c_vers;
-	unsigned long		c_timestamp;
-	union {
-		struct kvec	u_vec;
-		__be32		u_status;
-	}			c_u;
-};
-
-#define c_replvec		c_u.u_vec
-#define c_replstat		c_u.u_status
-
-/* cache entry states */
-enum {
-	RC_UNUSED,
-	RC_INPROG,
-	RC_DONE
-};
-
-/* return values */
-enum {
-	RC_DROPIT,
-	RC_REPLY,
-	RC_DOIT,
-	RC_INTR
-};
-
-/*
- * Cache types.
- * We may want to add more types one day, e.g. for diropres and
- * attrstat replies. Using cache entries with fixed length instead
- * of buffer pointers may be more efficient.
- */
-enum {
-	RC_NOCACHE,
-	RC_REPLSTAT,
-	RC_REPLBUFF,
-};
-
-/*
- * If requests are retransmitted within this interval, they're dropped.
- */
-#define RC_DELAY		(HZ/5)
-
-int	nfsd_reply_cache_init(void);
-void	nfsd_reply_cache_shutdown(void);
-int	nfsd_cache_lookup(struct svc_rqst *, int);
-void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
-
 #ifdef CONFIG_NFSD_V4
 void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
 #else  /* CONFIG_NFSD_V4 */
diff --git a/include/linux/nfsd/stats.h b/include/linux/nfsd/stats.h
index 2693ef6..7c5bf0e 100644
--- a/include/linux/nfsd/stats.h
+++ b/include/linux/nfsd/stats.h
@@ -17,9 +17,6 @@
 #ifdef __KERNEL__
 
 struct nfsd_stats {
-	unsigned int	rchits;		/* repcache hits */
-	unsigned int	rcmisses;	/* repcache hits */
-	unsigned int	rcnocache;	/* uncached reqs */
 	unsigned int	fh_stale;	/* FH stale error */
 	unsigned int	fh_lookup;	/* dentry cached */
 	unsigned int	fh_anon;	/* anon file dentry returned */
-- 
1.6.2



