From: Greg Banks <gnb@sgi.com>
Subject: [patch 28/29] knfsd: introduce NFSD_INC_STAT()
Date: Wed, 01 Apr 2009 07:28:28 +1100
Message-ID: <20090331202948.630464000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22589 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762712AbZCaVCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace direct adds and increments of counters in the global nfsdstats
structure with the two macros NFSD_INC_STAT() and NFSD_ADD_STAT().
This doesn't change any functionality but prepares for a subsequent
patch which changes the definitions of those macros to make the
nfsdstats counters per-cpu for performance.

This is a preliminary step towards making the NFS server statistics
be gathered per-CPU.

Signed-off-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: David Chinner <dgc@sgi.com>
Reviewed-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

 fs/nfsd/nfs4proc.c         |    2 +-
 fs/nfsd/nfsfh.c            |    2 +-
 fs/nfsd/vfs.c              |    4 ++--
 include/linux/nfsd/stats.h |    5 +++++
 4 files changed, 9 insertions(+), 4 deletions(-)

Index: bfields/fs/nfsd/nfs4proc.c
===================================================================
--- bfields.orig/fs/nfsd/nfs4proc.c
+++ bfields/fs/nfsd/nfs4proc.c
@@ -872,7 +872,7 @@ nfsd4_proc_null(struct svc_rqst *rqstp, 
 static inline void nfsd4_increment_op_stats(u32 opnum)
 {
 	if (opnum >= FIRST_NFS4_OP && opnum <= LAST_NFS4_OP)
-		nfsdstats.nfs4_opcount[opnum]++;
+		NFSD_INC_STAT(nfs4_opcount[opnum]);
 }
 
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
Index: bfields/fs/nfsd/nfsfh.c
===================================================================
--- bfields.orig/fs/nfsd/nfsfh.c
+++ bfields/fs/nfsd/nfsfh.c
@@ -354,7 +354,7 @@ skip_pseudoflavor_check:
 	}
 out:
 	if (error == nfserr_stale)
-		nfsdstats.fh_stale++;
+		NFSD_INC_STAT(fh_stale);
 	return error;
 }
 
Index: bfields/fs/nfsd/vfs.c
===================================================================
--- bfields.orig/fs/nfsd/vfs.c
+++ bfields/fs/nfsd/vfs.c
@@ -87,6 +87,7 @@ struct raparm_hbucket {
 #define RAPARM_HASH_SIZE	(1<<RAPARM_HASH_BITS)
 #define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
 static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
+static int raparm_cache_size;
 
 /* 
  * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
@@ -809,7 +810,7 @@ nfsd_get_raparms(dev_t dev, ino_t ino)
 		if (ra->p_count == 0)
 			frap = rap;
 	}
-	depth = nfsdstats.ra_size*11/10;
+	depth = raparm_cache_size*11/10;
 	if (!frap) {	
 		spin_unlock(&rab->pb_lock);
 		return NULL;
@@ -827,7 +828,7 @@ found:
 		rab->pb_head = ra;
 	}
 	ra->p_count++;
-	nfsdstats.ra_depth[depth*10/nfsdstats.ra_size]++;
+	NFSD_INC_STAT(ra_depth[depth*10/raparm_cache_size]);
 	spin_unlock(&rab->pb_lock);
 	return ra;
 }
@@ -938,7 +939,7 @@ nfsd_vfs_read(struct svc_rqst *rqstp, st
 	}
 
 	if (host_err >= 0) {
-		nfsdstats.io_read += host_err;
+		NFSD_ADD_STAT(io_read, host_err);
 		*count = host_err;
 		err = 0;
 		fsnotify_access(file->f_path.dentry);
@@ -1010,7 +1011,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, s
 	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
 	set_fs(oldfs);
 	if (host_err >= 0) {
-		nfsdstats.io_write += host_err;
+		NFSD_ADD_STAT(io_write, host_err);
 		fsnotify_modify(file->f_path.dentry);
 	}
 
@@ -2111,6 +2112,7 @@ nfsd_racache_init(int cache_size)
 	int	nperbucket;
 	struct raparms **raparm = NULL;
 
+	raparm_cache_size = cache_size;
 
 	if (raparm_hash[0].pb_head)
 		return 0;
@@ -2134,7 +2136,7 @@ nfsd_racache_init(int cache_size)
 		*raparm = NULL;
 	}
 
-	nfsdstats.ra_size = cache_size;
+	NFSD_SET_STAT(ra_size, cache_size);
 	return 0;
 
 out_nomem:
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -47,6 +47,13 @@ struct nfsd_stats {
 	unsigned int    rcage;          /* instant: age in milliseconds of last
 					 * entry reused from the LRU list */
 };
+#define NFSD_INC_STAT(field) \
+	(nfsdstats.field++)
+#define NFSD_ADD_STAT(field, v) \
+	(nfsdstats.field += (v))
+#define NFSD_SET_STAT(field, v) \
+	(nfsdstats.field = (v))
+
 
 struct nfsd_op_stats {
 #define NFSD_STATS_OP_FSINFO	0	/* includes NULLPROC,FSSTAT,FSINFO,
Index: bfields/fs/nfsd/nfscache.c
===================================================================
--- bfields.orig/fs/nfsd/nfscache.c
+++ bfields/fs/nfsd/nfscache.c
@@ -155,8 +155,8 @@ static int nfsd_cache_bucket_expand(stru
 	spin_lock(&b->lock);
 
 	b->size += increment;
-	nfsdstats.rcentries += increment;
-	nfsdstats.rcmem += increment * sizeof(struct svc_cacherep);
+	NFSD_ADD_STAT(rcentries, increment);
+	NFSD_ADD_STAT(rcmem, increment * sizeof(struct svc_cacherep));
 	list_splice(&lru, &b->lru);
 
 	spin_unlock(&b->lock);
@@ -188,10 +188,10 @@ int nfsd_reply_cache_init(void)
 		if (!b->hash)
 			goto out_nomem;
 
-		nfsdstats.rcmem += HASHSIZE * sizeof(struct hlist_head);
+		NFSD_ADD_STAT(rcmem, HASHSIZE * sizeof(struct hlist_head));
 	}
 
-	nfsdstats.rchashsize = HASHSIZE;
+	NFSD_SET_STAT(rchashsize, HASHSIZE);
 	cache_disabled = 0;
 	return 0;
 out_nomem:
@@ -275,7 +275,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 
 	rqstp->rq_cacherep = NULL;
 	if (cache_disabled || type == RC_NOCACHE) {
-		nfsdstats.rcnocache++;
+		NFSD_INC_STAT(rcnocache);
 		return RC_DOIT;
 	}
 	h = request_hash(xid, svc_addr_in(rqstp));
@@ -295,13 +295,13 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 		    proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
 		    time_after(rp->c_timestamp, age)) {
-			nfsdstats.rchits++;
-			nfsdstats.rcprobes += nprobes;
+			NFSD_INC_STAT(rchits);
+			NFSD_ADD_STAT(rcprobes, nprobes);
 			goto found_entry;
 		}
 	}
-	nfsdstats.rcmisses++;
-	nfsdstats.rcprobes += nprobes;
+	NFSD_INC_STAT(rcmisses);
+	NFSD_ADD_STAT(rcprobes, nprobes);
 
 	/* This loop shouldn't take more than a few iterations normally */
 	{
@@ -332,14 +332,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	if (rp->c_state != RC_UNUSED) {
 		/* reusing an existing cache entry */
 		age = jiffies - rp->c_timestamp;
-		nfsdstats.rcage = age;
+		NFSD_SET_STAT(rcage, age);
 		if (age < CACHE_THRESH_AGE &&
 		    b->size < CACHE_BUCKET_MAX_SIZE &&
 		    nfsd_cache_expand_ratelimit(b)) {
 			expand = CACHE_BUCKET_INCREMENT;
 			if (b->size + expand > CACHE_BUCKET_MAX_SIZE)
 				expand = CACHE_BUCKET_MAX_SIZE - b->size;
-			nfsdstats.rcexpands++;
+			NFSD_INC_STAT(rcexpands);
 		}
 	}
 
@@ -360,7 +360,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	if (rp->c_type == RC_REPLBUFF) {
 		kfree(rp->c_replvec.iov_base);
 		rp->c_replvec.iov_base = NULL;
-		nfsdstats.rcmem -= rp->c_replvec.iov_len;
+		NFSD_ADD_STAT(rcmem, -rp->c_replvec.iov_len);
 	}
 	rp->c_type = RC_NOCACHE;
  out:
@@ -473,7 +473,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	rp->c_state = RC_DONE;
 	rp->c_timestamp = jiffies;
 	if (moremem)
-		nfsdstats.rcmem += moremem;
+		NFSD_ADD_STAT(rcmem, moremem);
 	spin_unlock(&b->lock);
 	return;
 }
Index: bfields/fs/nfsd/nfssvc.c
===================================================================
--- bfields.orig/fs/nfsd/nfssvc.c
+++ bfields/fs/nfsd/nfssvc.c
@@ -425,7 +425,7 @@ nfsd(void *vrqstp)
 	allow_signal(SIGINT);
 	allow_signal(SIGQUIT);
 
-	nfsdstats.th_cnt++;
+	NFSD_INC_STAT(th_cnt);
 	mutex_unlock(&nfsd_mutex);
 
 	/*
@@ -476,7 +476,7 @@ nfsd(void *vrqstp)
 	flush_signals(current);
 
 	mutex_lock(&nfsd_mutex);
-	nfsdstats.th_cnt --;
+	NFSD_ADD_STAT(th_cnt, -1);
 
 out:
 	/* Release the thread */

--
Greg
