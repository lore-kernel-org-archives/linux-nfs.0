From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [PATCH 1/3] Add a common DRC for sunrpc
Date: Mon, 02 Nov 2009 17:35:43 +0800
Message-ID: <4AEEA7EF.3040103@cn.fujitsu.com>
References: <4AEEA622.6000705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, bfields@fieldses.org,
	mingo@elte.hu
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65274 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753061AbZKBJei (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 04:34:38 -0500
In-Reply-To: <4AEEA622.6000705@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The implemention of the sunrpc's DRC is same as NFS's DRC almost,
so i used file "include/linux/nfsd/cache.h" to create a file named
"include/linux/sunrpc/drc.h". 
The different between drc.h and cache.h are:
 1. add a struct(named: drc_cache) to record the request.
    (the rchits, rcmissed, rcnocache is used to record the
    process status of the requests.)

    struct drc_cache {
	struct hlist_head 	*cache_hash;
	struct list_head	lru_head;
	int 			cache_disabled;

	/* Record the cache */
	unsigned int		rchits;		/* repcache hits */
	unsigned int		rcmisses;	/* repcache misses */
	unsigned int		rcnocache;	/* uncached reqs */

	/*
	 * locking for the reply cache:
	 * A cache entry is "single use" if c_state == RC_INPROG
	 * Otherwise, it when accessing _prev or _next, the lock must be held.
	 */
	spinlock_t		cache_lock;
    };

    It can be used to create a global variable, and will be initialized 
    when corresponding module be load and used to record those request.

 2. drop the nfsd's declared function, modify other declared function name 
    and accept a struct drc_cache argument.

Using file "fs/nfsd/nfscache.c" to create file "net/sunrpc/drc.c".
Modify the function to process the struct drc_cache, and modify the nfsd's
rchits, rcmissed, rcnocache to record at drc_cache.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 include/linux/sunrpc/drc.h |   97 +++++++++++++
 net/sunrpc/Makefile        |    2 +-
 net/sunrpc/drc.c           |  326 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 424 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/sunrpc/drc.h
 create mode 100644 net/sunrpc/drc.c

diff --git a/include/linux/sunrpc/drc.h b/include/linux/sunrpc/drc.h
new file mode 100644
index 0000000..b581a4d
--- /dev/null
+++ b/include/linux/sunrpc/drc.h
@@ -0,0 +1,97 @@
+/*
+ * include/linux/sunrpc/drc.h
+ *
+ * Request reply cache. This was heavily inspired by the
+ * implementation in 4.3BSD/4.4BSD.
+ *
+ * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
+ */
+
+#ifndef DRC_H
+#define DRC_H
+
+#include <linux/in.h>
+#include <linux/uio.h>
+#include <linux/spinlock.h>
+
+/*
+ * Representation of a reply cache entry.
+ */
+struct svc_cacherep {
+	struct hlist_node	c_hash;
+	struct list_head	c_lru;
+
+	unsigned char		c_state,	/* unused, inprog, done */
+				c_type,		/* status, buffer */
+				c_secure : 1;	/* req came from port < 1024 */
+	struct sockaddr_in	c_addr;
+	__be32			c_xid;
+	u32			c_prot;
+	u32			c_proc;
+	u32			c_vers;
+	unsigned long		c_timestamp;
+	union {
+		struct kvec	u_vec;
+		__be32		u_status;
+	}			c_u;
+};
+
+#define c_replvec		c_u.u_vec
+#define c_replstat		c_u.u_status
+
+struct drc_cache {
+	struct hlist_head 	*cache_hash;
+	struct list_head	lru_head;
+	int 			cache_disabled;
+
+	/* Record the cache */
+	unsigned int		rchits;		/* repcache hits */
+	unsigned int		rcmisses;	/* repcache misses */
+	unsigned int		rcnocache;	/* uncached reqs */
+
+	/*
+	 * locking for the reply cache:
+	 * A cache entry is "single use" if c_state == RC_INPROG
+	 * Otherwise, it when accessing _prev or _next, the lock must be held.
+	 */
+	spinlock_t		cache_lock;
+};
+
+/* cache entry states */
+enum {
+	RC_UNUSED,
+	RC_INPROG,
+	RC_DONE
+};
+
+/* return values */
+enum {
+	RC_DROPIT,
+	RC_REPLY,
+	RC_DOIT,
+	RC_INTR
+};
+
+/*
+ * Cache types.
+ * We may want to add more types one day, e.g. for diropres and
+ * attrstat replies. Using cache entries with fixed length instead
+ * of buffer pointers may be more efficient.
+ */
+enum {
+	RC_NOCACHE,
+	RC_REPLSTAT,
+	RC_REPLBUFF,
+};
+
+/*
+ * If requests are retransmitted within this interval, they're dropped.
+ */
+#define RC_DELAY		(HZ/5)
+
+int	drc_reply_cache_init(struct drc_cache *);
+void	drc_reply_cache_shutdown(struct drc_cache *);
+int	drc_cache_lookup(struct svc_rqst *, int, struct drc_cache *);
+void	drc_cache_update(struct svc_rqst *, int, __be32 *, struct drc_cache *);
+
+#endif /* DRC_H */
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 9d2fca5..b3e20e4 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -12,7 +12,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
 	    addr.o rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
-	    svc_xprt.o
+	    svc_xprt.o drc.o
 sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o bc_svc.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/drc.c b/net/sunrpc/drc.c
new file mode 100644
index 0000000..5987e5d
--- /dev/null
+++ b/net/sunrpc/drc.c
@@ -0,0 +1,326 @@
+/*
+ * net/sunrpc/drc.c
+ *
+ * Request reply cache. This is currently a global cache, but this may
+ * change in the future and be a per-client cache.
+ *
+ * This code is heavily inspired by the 44BSD implementation, although
+ * it does things a bit differently.
+ *
+ * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/time.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/list.h>
+
+#include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/drc.h>
+
+/* Size of reply cache. Common values are:
+ * 4.3BSD:	128
+ * 4.4BSD:	256
+ * Solaris2:	1024
+ * DEC Unix:	512-4096
+ */
+#define CACHESIZE		1024
+#define HASHSIZE		64
+
+/*
+ * Calculate the hash index from an XID.
+ */
+static inline u32 request_hash(u32 xid)
+{
+	u32 h = xid;
+	h ^= (xid >> 24);
+	return h & (HASHSIZE-1);
+}
+
+static int	drc_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
+
+int drc_reply_cache_init(struct drc_cache *dc)
+{
+	struct svc_cacherep	*rp;
+	int			i;
+
+	dc->cache_disabled = 1;
+	dc->cache_lock = __SPIN_LOCK_UNLOCKED(dc->cache_lock);
+
+	INIT_LIST_HEAD(&dc->lru_head);
+	i = CACHESIZE;
+	while (i) {
+		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
+		if (!rp)
+			goto out_nomem;
+		list_add(&rp->c_lru, &dc->lru_head);
+		rp->c_state = RC_UNUSED;
+		rp->c_type = RC_NOCACHE;
+		INIT_HLIST_NODE(&rp->c_hash);
+		i--;
+	}
+
+	dc->cache_hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
+	if (!dc->cache_hash)
+		goto out_nomem;
+
+	dc->cache_disabled = 0;
+	return 0;
+out_nomem:
+	printk(KERN_ERR "drc: failed to allocate reply cache\n");
+	drc_reply_cache_shutdown(dc);
+	return -ENOMEM;
+}
+EXPORT_SYMBOL_GPL(drc_reply_cache_init);
+
+void drc_reply_cache_shutdown(struct drc_cache *dc)
+{
+	struct svc_cacherep	*rp;
+
+	while (!list_empty(&dc->lru_head)) {
+		rp = list_entry(dc->lru_head.next, struct svc_cacherep, c_lru);
+		if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
+			kfree(rp->c_replvec.iov_base);
+		list_del(&rp->c_lru);
+		kfree(rp);
+	}
+
+	dc->cache_disabled = 1;
+
+	kfree (dc->cache_hash);
+	dc->cache_hash = NULL;
+}
+EXPORT_SYMBOL_GPL(drc_reply_cache_shutdown);
+
+/*
+ * Move cache entry to end of LRU list
+ */
+static void
+lru_put_end(struct svc_cacherep *rp, struct drc_cache *dc)
+{
+	list_move_tail(&rp->c_lru, &dc->lru_head);
+}
+
+/*
+ * Move a cache entry from one hash list to another
+ */
+static void
+hash_refile(struct svc_cacherep *rp, struct drc_cache *dc)
+{
+	hlist_del_init(&rp->c_hash);
+	hlist_add_head(&rp->c_hash, dc->cache_hash + request_hash(rp->c_xid));
+}
+
+/*
+ * Try to find an entry matching the current call in the cache. When none
+ * is found, we grab the oldest unlocked entry off the LRU list.
+ * Note that no operation within the loop may sleep.
+ */
+int
+drc_cache_lookup(struct svc_rqst *rqstp, int type, struct drc_cache *dc)
+{
+	struct hlist_node	*hn;
+	struct hlist_head 	*rh;
+	struct svc_cacherep	*rp;
+	__be32			xid = rqstp->rq_xid;
+	u32			proto =  rqstp->rq_prot,
+				vers = rqstp->rq_vers,
+				proc = rqstp->rq_proc;
+	unsigned long		age;
+	int rtn;
+
+	rqstp->rq_cacherep = NULL;
+	if (dc->cache_disabled || type == RC_NOCACHE) {
+		dc->rcnocache++;
+		return RC_DOIT;
+	}
+
+	spin_lock(&dc->cache_lock);
+	rtn = RC_DOIT;
+
+	rh = &dc->cache_hash[request_hash(xid)];
+	hlist_for_each_entry(rp, hn, rh, c_hash) {
+		if (rp->c_state != RC_UNUSED &&
+		    xid == rp->c_xid && proc == rp->c_proc &&
+		    proto == rp->c_prot && vers == rp->c_vers &&
+		    time_before(jiffies, rp->c_timestamp + 120*HZ) &&
+		    memcmp((char*)&rqstp->rq_addr, (char*)&rp->c_addr, sizeof(rp->c_addr))==0) {
+			dc->rchits++;
+			goto found_entry;
+		}
+	}
+	dc->rcmisses++;
+
+	/* This loop shouldn't take more than a few iterations normally */
+	{
+	int	safe = 0;
+	list_for_each_entry(rp, &dc->lru_head, c_lru) {
+		if (rp->c_state != RC_INPROG)
+			break;
+		if (safe++ > CACHESIZE) {
+			printk("drc: loop in repcache LRU list\n");
+			dc->cache_disabled = 1;
+			goto out;
+		}
+	}
+	}
+
+	/* All entries on the LRU are in-progress. This should not happen */
+	if (&rp->c_lru == &dc->lru_head) {
+		static int	complaints;
+
+		printk(KERN_WARNING "drc: all repcache entries locked!\n");
+		if (++complaints > 5) {
+			printk(KERN_WARNING "drc: disabling repcache.\n");
+			dc->cache_disabled = 1;
+		}
+		goto out;
+	}
+
+	rqstp->rq_cacherep = rp;
+	rp->c_state = RC_INPROG;
+	rp->c_xid = xid;
+	rp->c_proc = proc;
+	memcpy(&rp->c_addr, svc_addr_in(rqstp), sizeof(rp->c_addr));
+	rp->c_prot = proto;
+	rp->c_vers = vers;
+	rp->c_timestamp = jiffies;
+
+	hash_refile(rp, dc);
+
+	/* release any buffer */
+	if (rp->c_type == RC_REPLBUFF) {
+		kfree(rp->c_replvec.iov_base);
+		rp->c_replvec.iov_base = NULL;
+	}
+	rp->c_type = RC_NOCACHE;
+ out:
+	spin_unlock(&dc->cache_lock);
+	return rtn;
+
+found_entry:
+	/* We found a matching entry which is either in progress or done. */
+	age = jiffies - rp->c_timestamp;
+	rp->c_timestamp = jiffies;
+	lru_put_end(rp, dc);
+
+	rtn = RC_DROPIT;
+	/* Request being processed or excessive rexmits */
+	if (rp->c_state == RC_INPROG || age < RC_DELAY)
+		goto out;
+
+	/* From the hall of fame of impractical attacks:
+	 * Is this a user who tries to snoop on the cache? */
+	rtn = RC_DOIT;
+	if (!rqstp->rq_secure && rp->c_secure)
+		goto out;
+
+	/* Compose RPC reply header */
+	switch (rp->c_type) {
+	case RC_NOCACHE:
+		break;
+	case RC_REPLSTAT:
+		svc_putu32(&rqstp->rq_res.head[0], rp->c_replstat);
+		rtn = RC_REPLY;
+		break;
+	case RC_REPLBUFF:
+		if (!drc_cache_append(rqstp, &rp->c_replvec))
+			goto out;	/* should not happen */
+		rtn = RC_REPLY;
+		break;
+	default:
+		printk(KERN_WARNING "drc: bad repcache type %d\n", rp->c_type);
+		rp->c_state = RC_UNUSED;
+	}
+
+	goto out;
+}
+EXPORT_SYMBOL_GPL(drc_cache_lookup);
+
+/*
+ * Update a cache entry. This is called from XXX_dispatch when
+ * the procedure has been executed and the complete reply is in
+ * rqstp->rq_res.
+ *
+ * We're copying around data here rather than swapping buffers because
+ * the toplevel loop requires max-sized buffers, which would be a waste
+ * of memory for a cache with a max reply size of 100 bytes (diropokres).
+ *
+ * If we should start to use different types of cache entries tailored
+ * specifically for attrstat and fh's, we may save even more space.
+ *
+ * Also note that a cachetype of RC_NOCACHE can legally be passed when
+ * drc failed to encode a reply that otherwise would have been cached.
+ * In this case, drc_cache_update is called with statp == NULL.
+ */
+void
+drc_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp,
+		  struct drc_cache *dc)
+{
+	struct svc_cacherep *rp;
+	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
+	int		len;
+
+	if (!(rp = rqstp->rq_cacherep) || dc->cache_disabled)
+		return;
+
+	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
+	len >>= 2;
+
+	/* Don't cache excessive amounts of data and XDR failures */
+	if (!statp || len > (256 >> 2)) {
+		rp->c_state = RC_UNUSED;
+		return;
+	}
+
+	switch (cachetype) {
+	case RC_REPLSTAT:
+		if (len != 1)
+			printk("drc: RC_REPLSTAT/reply len %d!\n",len);
+		rp->c_replstat = *statp;
+		break;
+	case RC_REPLBUFF:
+		cachv = &rp->c_replvec;
+		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
+		if (!cachv->iov_base) {
+			spin_lock(&dc->cache_lock);
+			rp->c_state = RC_UNUSED;
+			spin_unlock(&dc->cache_lock);
+			return;
+		}
+		cachv->iov_len = len << 2;
+		memcpy(cachv->iov_base, statp, len << 2);
+		break;
+	}
+	spin_lock(&dc->cache_lock);
+	lru_put_end(rp, dc);
+	rp->c_secure = rqstp->rq_secure;
+	rp->c_type = cachetype;
+	rp->c_state = RC_DONE;
+	rp->c_timestamp = jiffies;
+	spin_unlock(&dc->cache_lock);
+	return;
+}
+EXPORT_SYMBOL_GPL(drc_cache_update);
+
+/*
+ * Copy cached reply to current reply buffer. Should always fit.
+ * FIXME as reply is in a page, we should just attach the page, and
+ * keep a refcount....
+ */
+static int
+drc_cache_append(struct svc_rqst *rqstp, struct kvec *data)
+{
+	struct kvec	*vec = &rqstp->rq_res.head[0];
+
+	if (vec->iov_len + data->iov_len > PAGE_SIZE) {
+		printk(KERN_WARNING "drc: cached reply too large (%Zd).\n",
+				data->iov_len);
+		return 0;
+	}
+	memcpy((char*)vec->iov_base + vec->iov_len, data->iov_base, data->iov_len);
+	vec->iov_len += data->iov_len;
+	return 1;
+}
-- 
1.6.2


