Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f182.google.com ([209.85.161.182]:59766 "EHLO
	mail-gg0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759303Ab3BGUdl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 15:33:41 -0500
Received: by mail-gg0-f182.google.com with SMTP id d1so352532ggn.41
        for <linux-nfs@vger.kernel.org>; Thu, 07 Feb 2013 12:33:40 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, rees@umich.edu, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH RFC] nfsd: change to using IP-style checksums for DRC entries
Date: Thu,  7 Feb 2013 15:33:35 -0500
Message-Id: <1360269215-32037-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck and Jim pointed out that crc32 is probably more heavyweight
than we really need for generating these checksums, and recommended
looking at using the same routines that are used to generate
checksums for IP packets.

This patch converts the code to use csum_partial instead of crc32.
Unfortunately, I don't have a great way to verify the overhead of
calculating the checksum here, so I don't know of a good way to
verify that this is significantly cheaper than crc32...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/cache.h    |  2 +-
 fs/nfsd/nfscache.c | 33 +++++++++++++++------------------
 2 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 4822db3..87fd141 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -30,7 +30,7 @@ struct svc_cacherep {
 	u32			c_proc;
 	u32			c_vers;
 	unsigned int		c_len;
-	u32			c_crc;
+	__wsum			c_csum;
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index bd3d8e2..40db57e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -11,7 +11,7 @@
 #include <linux/slab.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/highmem.h>
-#include <linux/crc32.h>
+#include <net/checksum.h>
 
 #include "nfsd.h"
 #include "cache.h"
@@ -25,7 +25,6 @@ static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
 static unsigned int		num_drc_entries;
 static unsigned int		max_drc_entries;
-static u32			crc_seed;
 
 /*
  * Calculate the hash index from an XID.
@@ -133,8 +132,6 @@ int nfsd_reply_cache_init(void)
 	max_drc_entries = nfsd_cache_size_limit();
 	num_drc_entries = 0;
 
-	/* Is a random seed any better than some well-defined constant? */
-	get_random_bytes(&crc_seed, sizeof(crc_seed));
 	return 0;
 out_nomem:
 	printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
@@ -245,12 +242,12 @@ nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
 /*
  * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
  */
-static u32
-nfsd_cache_crc(struct svc_rqst *rqstp)
+static __wsum
+nfsd_cache_csum(struct svc_rqst *rqstp)
 {
 	int idx;
 	unsigned int base;
-	u32 crc;
+	__wsum csum;
 	struct xdr_buf *buf = &rqstp->rq_arg;
 	const unsigned char *p = buf->head[0].iov_base;
 	size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
@@ -258,7 +255,7 @@ nfsd_cache_crc(struct svc_rqst *rqstp)
 	size_t len = min(buf->head[0].iov_len, csum_len);
 
 	/* rq_arg.head first */
-	crc = crc32(crc_seed, p, len);
+	csum = csum_partial(p, len, 0);
 	csum_len -= len;
 
 	/* Continue into page array */
@@ -267,12 +264,12 @@ nfsd_cache_crc(struct svc_rqst *rqstp)
 	while (csum_len) {
 		p = page_address(buf->pages[idx]) + base;
 		len = min(PAGE_SIZE - base, csum_len);
-		crc = crc32(crc, p, len);
+		csum = csum_partial(p, len, csum);
 		csum_len -= len;
 		base = 0;
 		++idx;
 	}
-	return crc;
+	return csum;
 }
 
 /*
@@ -281,7 +278,7 @@ nfsd_cache_crc(struct svc_rqst *rqstp)
  * NULL on failure.
  */
 static struct svc_cacherep *
-nfsd_cache_search(struct svc_rqst *rqstp, u32 crc)
+nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 {
 	struct svc_cacherep	*rp;
 	struct hlist_node	*hn;
@@ -295,7 +292,7 @@ nfsd_cache_search(struct svc_rqst *rqstp, u32 crc)
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
-		    rqstp->rq_arg.len == rp->c_len && crc == rp->c_crc &&
+		    rqstp->rq_arg.len == rp->c_len && csum == rp->c_csum &&
 		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
 		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
 			return rp;
@@ -315,8 +312,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	__be32			xid = rqstp->rq_xid;
 	u32			proto =  rqstp->rq_prot,
 				vers = rqstp->rq_vers,
-				proc = rqstp->rq_proc,
-				crc;
+				proc = rqstp->rq_proc;
+	__wsum			csum;
 	unsigned long		age;
 	int type = rqstp->rq_cachetype;
 	int rtn;
@@ -327,12 +324,12 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		return RC_DOIT;
 	}
 
-	crc = nfsd_cache_crc(rqstp);
+	csum = nfsd_cache_csum(rqstp);
 
 	spin_lock(&cache_lock);
 	rtn = RC_DOIT;
 
-	rp = nfsd_cache_search(rqstp, crc);
+	rp = nfsd_cache_search(rqstp, csum);
 	if (rp)
 		goto found_entry;
 
@@ -360,7 +357,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	 * Must search again just in case someone inserted one
 	 * after we dropped the lock above.
 	 */
-	found = nfsd_cache_search(rqstp, crc);
+	found = nfsd_cache_search(rqstp, csum);
 	if (found) {
 		nfsd_reply_cache_free_locked(rp);
 		rp = found;
@@ -387,7 +384,7 @@ setup_entry:
 	rp->c_prot = proto;
 	rp->c_vers = vers;
 	rp->c_len = rqstp->rq_arg.len;
-	rp->c_crc = crc;
+	rp->c_csum = csum;
 
 	hash_refile(rp);
 	lru_put_end(rp);
-- 
1.7.11.7

