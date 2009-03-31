From: Greg Banks <gnb@sgi.com>
Subject: [patch 20/29] knfsd: add extended reply cache stats
Date: Wed, 01 Apr 2009 07:28:20 +1100
Message-ID: <20090331202945.083092000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22577 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758821AbZCaVCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add more statistics to /proc/net/rpc/nfsd which track the behaviour
of the reply cache, in particular hashing efficiency and memory usage.
A new line starting with the keyword "rc2" is added.

Note: the nfsdstats structure is currently a global contention point
in heavy multiprocessor NFS workloads, so this patch will actually
slow down the reply cache slightly.  That problem is addressed in a
later patch.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfscache.c         |   17 +++++++++++++++++
 fs/nfsd/stats.c            |   10 ++++++++++
 include/linux/nfsd/stats.h |   10 +++++++++-
 3 files changed, 36 insertions(+), 1 deletion(-)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -107,6 +107,16 @@ static int nfsd_proc_show(struct seq_fil
 	seq_putc(seq, '\n');
 #endif
 
+	/* extended repcache stats */
+	seq_printf(seq, "rc2 %u %u %u %u %u %u %u\n",
+			nfsdstats.rcprobes,
+			nfsdstats.rcexpands,
+			nfsdstats.rcrehash,
+			nfsdstats.rcentries,
+			nfsdstats.rcmem,
+			nfsdstats.rchashsize,
+			nfsdstats.rcage);
+
 	return 0;
 }
 
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -37,7 +37,15 @@ struct nfsd_stats {
 #ifdef CONFIG_NFSD_V4
 	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfsv4 operations */
 #endif
-
+	/* extended repcache stats */
+	unsigned int    rcprobes;       /* counter: walks down hash chains */
+	unsigned int    rcexpands;      /* counter: when the cache is expanded */
+	unsigned int    rcrehash;       /* counter: when the cache index is expanded */
+	unsigned int    rcentries;      /* instant: # entries */
+	unsigned int    rcmem;          /* instant: bytes of memory used */
+	unsigned int    rchashsize;     /* instant: # chains in index */
+	unsigned int    rcage;          /* instant: age in milliseconds of last
+					 * entry reused from the LRU list */
 };
 
 struct nfsd_op_stats {
Index: bfields/fs/nfsd/nfscache.c
===================================================================
--- bfields.orig/fs/nfsd/nfscache.c
+++ bfields/fs/nfsd/nfscache.c
@@ -155,6 +155,8 @@ static int nfsd_cache_bucket_expand(stru
 	spin_lock(&b->lock);
 
 	b->size += increment;
+	nfsdstats.rcentries += increment;
+	nfsdstats.rcmem += increment * sizeof(struct svc_cacherep);
 	list_splice(&lru, &b->lru);
 
 	spin_unlock(&b->lock);
@@ -185,8 +187,11 @@ int nfsd_reply_cache_init(void)
 		b->hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
 		if (!b->hash)
 			goto out_nomem;
+
+		nfsdstats.rcmem += HASHSIZE * sizeof(struct hlist_head);
 	}
 
+	nfsdstats.rchashsize = HASHSIZE;
 	cache_disabled = 0;
 	return 0;
 out_nomem:
@@ -266,6 +271,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	unsigned long		age;
 	int			rtn;
 	int			expand = 0;
+	unsigned int		nprobes = 0;
 
 	rqstp->rq_cacherep = NULL;
 	if (cache_disabled || type == RC_NOCACHE) {
@@ -282,6 +288,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rh = &b->hash[h];
 	age = jiffies - 120*HZ;
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
+		nprobes++;
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid &&
 		    compare_sockaddr_in(svc_addr_in(rqstp), &rp->c_addr) &&
@@ -289,10 +296,12 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 		    proto == rp->c_prot && vers == rp->c_vers &&
 		    time_after(rp->c_timestamp, age)) {
 			nfsdstats.rchits++;
+			nfsdstats.rcprobes += nprobes;
 			goto found_entry;
 		}
 	}
 	nfsdstats.rcmisses++;
+	nfsdstats.rcprobes += nprobes;
 
 	/* This loop shouldn't take more than a few iterations normally */
 	{
@@ -323,12 +332,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	if (rp->c_state != RC_UNUSED) {
 		/* reusing an existing cache entry */
 		age = jiffies - rp->c_timestamp;
+		nfsdstats.rcage = age;
 		if (age < CACHE_THRESH_AGE &&
 		    b->size < CACHE_BUCKET_MAX_SIZE &&
 		    nfsd_cache_expand_ratelimit(b)) {
 			expand = CACHE_BUCKET_INCREMENT;
 			if (b->size + expand > CACHE_BUCKET_MAX_SIZE)
 				expand = CACHE_BUCKET_MAX_SIZE - b->size;
+			nfsdstats.rcexpands++;
 		}
 	}
 
@@ -349,6 +360,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	if (rp->c_type == RC_REPLBUFF) {
 		kfree(rp->c_replvec.iov_base);
 		rp->c_replvec.iov_base = NULL;
+		nfsdstats.rcmem -= rp->c_replvec.iov_len;
 	}
 	rp->c_type = RC_NOCACHE;
  out:
@@ -418,6 +430,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
 	struct svc_cache_bucket *b;
+	unsigned int	moremem = 0;
 
 	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
 		return;
@@ -450,6 +463,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 		}
 		cachv->iov_len = len << 2;
 		memcpy(cachv->iov_base, statp, len << 2);
+		moremem = len << 2;
 		break;
 	}
 	spin_lock(&b->lock);
@@ -458,6 +472,8 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
 	rp->c_timestamp = jiffies;
+	if (moremem)
+		nfsdstats.rcmem += moremem;
 	spin_unlock(&b->lock);
 	return;
 }
@@ -481,3 +497,4 @@ nfsd_cache_append(struct svc_rqst *rqstp
 	vec->iov_len += data->iov_len;
 	return 1;
 }
+

--
Greg
