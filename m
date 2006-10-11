From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 8/8] knfsd: repcache: add statistics
Date: Wed, 11 Oct 2006 21:30:26 +1000
Message-ID: <1160566226.8530.21.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcIE-0001i8-9s
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:30:34 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcIC-00067n-Qh
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:30:35 -0700
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

knfsd: Add more statistics to the duplicate request cache; we now track
the memory usage of the data structure, the age of evicted entries,
and probes along hash chains.

Also, reduce contention for the cachelines of the global nfsdstats
structure by keeping repcache stats per-bucket and aggregating them
on demand when userspace reads /proc.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c         |   72 ++++++++++++++++++++++++++++++++--
 fs/nfsd/stats.c            |   11 +++++
 include/linux/nfsd/cache.h |    1 
 include/linux/nfsd/stats.h |    7 +++
 4 files changed, 88 insertions(+), 3 deletions(-)

Index: linux-git-20061009/fs/nfsd/stats.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/stats.c	2006-10-11 14:07:49.459633262 +1000
+++ linux-git-20061009/fs/nfsd/stats.c	2006-10-11 14:21:56.653517425 +1000
@@ -34,6 +34,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
+#include <linux/nfsd/cache.h>
 
 struct nfsd_stats	nfsdstats;
 struct svc_stat		nfsd_svcstats = {
@@ -44,6 +45,8 @@ static int nfsd_proc_show(struct seq_fil
 {
 	int i;
 
+	nfsd_cache_update_stats();
+
 	seq_printf(seq, "rc %u %u %u\nfh %u %u %u %u %u\nio %u %u\n",
 		      nfsdstats.rchits,
 		      nfsdstats.rcmisses,
@@ -72,6 +75,14 @@ static int nfsd_proc_show(struct seq_fil
 	/* show my rpc info */
 	svc_seq_show(seq, &nfsd_svcstats);
 
+	/* extended repcache stats */
+	seq_printf(seq, "rc2 %u %u %u %u %u\n",
+			nfsdstats.rcprobes,
+			nfsdstats.rcexpands,
+			nfsdstats.rcentries,
+			nfsdstats.rcmem,
+			(1000 * nfsdstats.rcage) / HZ);
+
 #ifdef CONFIG_NFSD_V4
 	/* Show count for individual nfsv4 operations */
 	/* Writing operation numbers 0 1 2 also for maintaining uniformity */
Index: linux-git-20061009/include/linux/nfsd/stats.h
===================================================================
--- linux-git-20061009.orig/include/linux/nfsd/stats.h	2006-10-11 14:07:49.563619730 +1000
+++ linux-git-20061009/include/linux/nfsd/stats.h	2006-10-11 14:08:07.581275049 +1000
@@ -29,6 +29,13 @@ struct nfsd_stats {
 	unsigned int	ra_size;	/* size of ra cache */
 	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
 					 * in the cache (10percentiles). [10] = not found */
+	/* extended repcache stats */
+	unsigned int	rcprobes;	/* counter: walks down hash chains */
+	unsigned int	rcexpands;	/* counter: when the cache is expanded */
+	unsigned int	rcentries;	/* instant: # entries */
+	unsigned int	rcmem;		/* instant: bytes of memory used */
+	unsigned int	rcage;		/* instant: age in milliseconds of last
+					 * entry reused from the LRU list */
 #ifdef CONFIG_NFSD_V4
 	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfsv4 operations */
 #endif
Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-11 14:08:07.533281294 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-11 14:08:07.581275049 +1000
@@ -83,6 +83,21 @@ struct svc_cache_bucket
 	/* parameters for expand rate limiting */
 	unsigned long last;
 	unsigned long nhits;
+	/* stats, stored per-bucket and accumulated on demand */
+	struct
+	{
+		unsigned int	rchits;		/* repcache hits */
+		unsigned int	rcmisses;	/* repcache hits */
+		unsigned int	rcnocache;	/* uncached reqs */
+
+		/* extended repcache stats */
+		unsigned int	rcprobes;	/* counter: walks down hash chains */
+		unsigned int	rcexpands;	/* counter: when the cache is expanded */
+		unsigned int	rcentries;	/* instant: # entries */
+		unsigned int	rcmem;		/* instant: bytes of memory used */
+		unsigned int	rcage;		/* instant: age in milliseconds of last
+						 * entry reused from the LRU list */
+	} stats;
 } ____cacheline_aligned_in_smp;
 
 static struct svc_cache_bucket	cache_buckets[CACHE_NUM_BUCKETS];
@@ -161,6 +176,8 @@ nfsd_cache_bucket_expand(struct svc_cach
 	spin_lock(&b->lock);
 
 	b->size += (nrecs-i);
+	b->stats.rcentries += (nrecs-i);
+	b->stats.rcmem += (nrecs-i) * sizeof(struct svc_cacherep);
 	list_splice(&lru, &b->lru);
 
 	spin_unlock(&b->lock);
@@ -187,6 +204,8 @@ nfsd_cache_init(void)
 			return;
 		}
 		memset(b->hash, 0, HASHSIZE * sizeof(struct hlist_head));
+
+		b->stats.rcmem += HASHSIZE * sizeof(struct hlist_head);
 	}
 
 	cache_disabled = 0;
@@ -269,6 +288,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	int			rtn;
 	int			safe = 0;
 	int			expand = 0;
+	unsigned int		nprobes = 0;
 
 	h = request_hash(xid, &rqstp->rq_addr);
 	b = bucket_for_hash(h);
@@ -276,7 +296,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 
 	rqstp->rq_cacherep = NULL;
 	if (cache_disabled || type == RC_NOCACHE) {
-		nfsdstats.rcnocache++;
+		b->stats.rcnocache++;
 		return RC_DOIT;
 	}
 
@@ -286,17 +306,20 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rh = &b->hash[h];
 	age = jiffies - 120*HZ;
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
+		nprobes++;
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid &&
 		    compare_sockaddr_in(&rqstp->rq_addr, &rp->c_addr) &&
 		    proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
 		    time_after(rp->c_timestamp, age)) {
-			nfsdstats.rchits++;
+			b->stats.rchits++;
+			b->stats.rcprobes += nprobes;
 			goto found_entry;
 		}
 	}
-	nfsdstats.rcmisses++;
+	b->stats.rcmisses++;
+	b->stats.rcprobes += nprobes;
 
 	/* This loop shouldn't take more than a few iterations normally */
 	list_for_each_entry(rp, &b->lru, c_lru) {
@@ -324,12 +347,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	if (rp->c_state != RC_UNUSED) {
 		/* reusing an existing cache entry */
 		age = jiffies - rp->c_timestamp;
+		b->stats.rcage = age;
 		if (age < CACHE_THRESH_AGE &&
 		    b->size < CACHE_BUCKET_MAX_SIZE &&
 		    nfsd_cache_expand_ratelimit(b)) {
 			expand = CACHE_BUCKET_INCREMENT;
 			if (b->size + expand > CACHE_BUCKET_MAX_SIZE)
 				expand = CACHE_BUCKET_MAX_SIZE - b->size;
+			b->stats.rcexpands++;
 		}
 	}
 
@@ -350,6 +375,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	if (rp->c_type == RC_REPLBUFF) {
 		kfree(rp->c_replvec.iov_base);
 		rp->c_replvec.iov_base = NULL;
+		b->stats.rcmem -= rp->c_replvec.iov_len;
 	}
 	rp->c_type = RC_NOCACHE;
  out:
@@ -419,6 +445,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
 	struct svc_cache_bucket *b;
+	unsigned int	moremem = 0;
 
 	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
 		return;
@@ -451,6 +478,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 		}
 		cachv->iov_len = len << 2;
 		memcpy(cachv->iov_base, statp, len << 2);
+		moremem = len << 2;
 		break;
 	}
 	spin_lock(&b->lock);
@@ -459,6 +487,8 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
 	rp->c_timestamp = jiffies;
+	if (moremem)
+		b->stats.rcmem += moremem;
 	spin_unlock(&b->lock);
 	return;
 }
@@ -482,3 +512,39 @@ nfsd_cache_append(struct svc_rqst *rqstp
 	vec->iov_len += data->iov_len;
 	return 1;
 }
+
+void
+nfsd_cache_update_stats(void)
+{
+	unsigned int bucket;
+	unsigned int i;
+	struct svc_cache_bucket totbucket;
+	unsigned int *totp = (unsigned int *)&totbucket.stats;
+	unsigned int *bp;
+	unsigned int minage = ~0;
+
+	memset(&totbucket, 0, sizeof(totbucket));
+
+	for (bucket = 0 ; bucket < CACHE_NUM_BUCKETS ; bucket++)
+	{
+		struct svc_cache_bucket *b = &cache_buckets[bucket];
+
+		/* stats are accumulated across buckets unlocked,
+		 * but who cares they're only stats anyway */
+		bp = (unsigned int *)&b->stats;
+		for (i = 0 ; i < sizeof(b->stats)/sizeof(unsigned int) ; i++) {
+			totp[i] += bp[i];
+		}
+		if (b->stats.rcage < minage)
+			minage = b->stats.rcage;
+	}
+	nfsdstats.rchits = totbucket.stats.rchits;
+	nfsdstats.rcmisses = totbucket.stats.rcmisses;
+	nfsdstats.rcnocache = totbucket.stats.rcnocache;
+	nfsdstats.rcprobes = totbucket.stats.rcprobes;
+	nfsdstats.rcexpands = totbucket.stats.rcexpands;
+	nfsdstats.rcentries = totbucket.stats.rcentries;
+	nfsdstats.rcmem = totbucket.stats.rcmem;
+	nfsdstats.rcage = minage;
+}
+
Index: linux-git-20061009/include/linux/nfsd/cache.h
===================================================================
--- linux-git-20061009.orig/include/linux/nfsd/cache.h	2006-10-11 14:08:07.185326575 +1000
+++ linux-git-20061009/include/linux/nfsd/cache.h	2006-10-11 14:08:07.585274528 +1000
@@ -75,6 +75,7 @@ void	nfsd_cache_init(void);
 void	nfsd_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *, int);
 void	nfsd_cache_update(struct svc_rqst *, int, u32 *);
+void	nfsd_cache_update_stats(void);
 
 #endif /* __KERNEL__ */
 #endif /* NFSCACHE_H */

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
