Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f176.google.com ([209.85.213.176]:54842 "EHLO
	mail-ye0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1TmO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:42:14 -0500
Received: by mail-ye0-f176.google.com with SMTP id m1so456740yen.7
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:42:14 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 16/16] nfsd: keep a checksum of the first 256 bytes of request
Date: Mon, 28 Jan 2013 14:41:22 -0500
Message-Id: <1359402082-29195-17-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we're dynamically allocating these entries, it becomes a lot
easier to hit problems with XID collisions. In order to mitigate those,
checksum up to the first 256 bytes of each request coming in and store
those in the cache entry, along with the total length of the request.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/cache.h    |  5 +++++
 fs/nfsd/nfscache.c | 44 ++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 9c7232b..4822db3 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -29,6 +29,8 @@ struct svc_cacherep {
 	u32			c_prot;
 	u32			c_proc;
 	u32			c_vers;
+	unsigned int		c_len;
+	u32			c_crc;
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
@@ -73,6 +75,9 @@ enum {
 /* Cache entries expire after this time period */
 #define RC_EXPIRE		(120 * HZ)
 
+/* Checksum this amount of the request */
+#define RC_CSUMLEN		(256U)
+
 int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *);
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 27edd47..abbf956 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -10,6 +10,7 @@
 
 #include <linux/slab.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/crc32.h>
 
 #include "nfsd.h"
 #include "cache.h"
@@ -22,6 +23,7 @@ static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
 static unsigned int		num_drc_entries;
+static u32			crc_seed;
 
 /*
  * Calculate the hash index from an XID.
@@ -103,6 +105,9 @@ int nfsd_reply_cache_init(void)
 		goto out_nomem;
 
 	INIT_LIST_HEAD(&lru_head);
+
+	/* Is a random seed any better than some well-defined constant? */
+	get_random_bytes(&crc_seed, sizeof(crc_seed));
 	num_drc_entries = 0;
 	return 0;
 out_nomem:
@@ -236,12 +241,37 @@ out:
 }
 
 /*
+ * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
+ */
+static u32
+nfsd_cache_crc(struct xdr_buf *buf)
+{
+	u32 crc;
+	const unsigned char *p = buf->head[0].iov_base;
+	size_t total_len = min(buf->len, RC_CSUMLEN);
+	size_t len = min(buf->head[0].iov_len, total_len);
+
+	/* rq_arg.head first */
+	crc = crc32(crc_seed, p, len);
+	total_len -= len;
+
+	/* Nothing left */
+	if (!total_len)
+		return crc;
+
+	/* checksum the rest from the page_array */
+	p = page_address(buf->pages[0]) + buf->page_base;
+	len = min(buf->len - len, total_len);
+	return crc32(crc, p, len);
+}
+
+/*
  * Search the request hash for an entry that matches the given rqstp.
  * Must be called with cache_lock held. Returns the found entry or
  * NULL on failure.
  */
 static struct svc_cacherep *
-nfsd_cache_search(struct svc_rqst *rqstp)
+nfsd_cache_search(struct svc_rqst *rqstp, u32 crc)
 {
 	struct svc_cacherep	*rp;
 	struct hlist_node	*hn;
@@ -255,6 +285,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
+		    rqstp->rq_arg.len == rp->c_len && crc == rp->c_crc &&
 		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
 		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
 			return rp;
@@ -274,7 +305,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	__be32			xid = rqstp->rq_xid;
 	u32			proto =  rqstp->rq_prot,
 				vers = rqstp->rq_vers,
-				proc = rqstp->rq_proc;
+				proc = rqstp->rq_proc,
+				crc;
 	unsigned long		age;
 	int type = rqstp->rq_cachetype;
 	int rtn;
@@ -285,10 +317,12 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		return RC_DOIT;
 	}
 
+	crc = nfsd_cache_crc(&rqstp->rq_arg);
+
 	spin_lock(&cache_lock);
 	rtn = RC_DOIT;
 
-	rp = nfsd_cache_search(rqstp);
+	rp = nfsd_cache_search(rqstp, crc);
 	if (rp)
 		goto found_entry;
 
@@ -318,7 +352,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	 * Must search again just in case someone inserted one
 	 * after we dropped the lock above.
 	 */
-	found = nfsd_cache_search(rqstp);
+	found = nfsd_cache_search(rqstp, crc);
 	if (found) {
 		nfsd_reply_cache_free_locked(rp);
 		rp = found;
@@ -335,6 +369,8 @@ setup_entry:
 	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
 	rp->c_prot = proto;
 	rp->c_vers = vers;
+	rp->c_len = rqstp->rq_arg.len;
+	rp->c_crc = crc;
 
 	hash_refile(rp);
 	lru_put_end(rp);
-- 
1.7.11.7

