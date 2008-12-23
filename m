From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 44/69] optimize attribute timeouts for "noac" and
 "actimeo=0"
Date: Tue, 23 Dec 2008 18:02:18 -0500
Message-ID: <20081223230218.13743.52902.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbYLWXYl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:41 -0500
Received: from sacrsexc1-prd.hq.netapp.com ([10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOc0V006400
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peter Staubach <staubach@redhat.com>

Hi.

I've been looking at a bugzilla which describes a problem where
a customer was advised to use either the "noac" or "actimeo=0"
mount options to solve a consistency problem that they were
seeing in the file attributes.  It turned out that this solution
did not work reliably for them because sometimes, the local
attribute cache was believed to be valid and not timed out.
(With an attribute cache timeout of 0, the cache should always
appear to be timed out.)

In looking at this situation, it appears to me that the problem
is that the attribute cache timeout code has an off-by-one
error in it.  It is assuming that the cache is valid in the
region, [read_cache_jiffies, read_cache_jiffies + attrtimeo].  The
cache should be considered valid only in the region,
[read_cache_jiffies, read_cache_jiffies + attrtimeo).  With this
change, the options, "noac" and "actimeo=0", work as originally
expected.

This problem was previously addressed by special casing the
attrtimeo == 0 case.  However, since the problem is only an off-
by-one error, the cleaner solution is address the off-by-one
error and thus, not require the special case.

    Thanx...

        ps

Signed-off-by: Peter Staubach <staubach@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c            |    2 +-
 fs/nfs/inode.c          |   11 ++---------
 include/linux/jiffies.h |   10 ++++++++++
 include/linux/nfs_fs.h  |    5 ++++-
 net/sunrpc/auth.c       |    2 +-
 5 files changed, 18 insertions(+), 12 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ed7024c..e35c819 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1798,7 +1798,7 @@ static int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, str
 	if (cache == NULL)
 		goto out;
 	if (!nfs_have_delegation(inode, FMODE_READ) &&
-	    !time_in_range(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
+	    !time_in_range_open(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
 		goto out_stale;
 	res->jiffies = cache->jiffies;
 	res->cred = cache->cred;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1cf3920..0c38168 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -712,14 +712,7 @@ int nfs_attribute_timeout(struct inode *inode)
 
 	if (nfs_have_delegation(inode, FMODE_READ))
 		return 0;
-	/*
-	 * Special case: if the attribute timeout is set to 0, then always
-	 * 		 treat the cache as having expired (unless holding
-	 * 		 a delegation).
-	 */
-	if (nfsi->attrtimeo == 0)
-		return 1;
-	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
+	return !time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
 }
 
 /**
@@ -1182,7 +1175,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		nfsi->attrtimeo_timestamp = now;
 		nfsi->attr_gencount = nfs_inc_attr_generation_counter();
 	} else {
-		if (!time_in_range(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
+		if (!time_in_range_open(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
 			if ((nfsi->attrtimeo <<= 1) > NFS_MAXATTRTIMEO(inode))
 				nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
 			nfsi->attrtimeo_timestamp = now;
diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index abb6ac6..1a9cf78 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -115,10 +115,20 @@ static inline u64 get_jiffies_64(void)
 	 ((long)(a) - (long)(b) >= 0))
 #define time_before_eq(a,b)	time_after_eq(b,a)
 
+/*
+ * Calculate whether a is in the range of [b, c].
+ */
 #define time_in_range(a,b,c) \
 	(time_after_eq(a,b) && \
 	 time_before_eq(a,c))
 
+/*
+ * Calculate whether a is in the range of [b, c).
+ */
+#define time_in_range_open(a,b,c) \
+	(time_after_eq(a,b) && \
+	 time_before(a,c))
+
 /* Same as above, but does so with platform independent 64bit types.
  * These must be used when utilizing jiffies_64 (i.e. return value of
  * get_jiffies_64() */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b8d9c6d..db867b0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -130,7 +130,10 @@ struct nfs_inode {
 	 *
 	 * We need to revalidate the cached attrs for this inode if
 	 *
-	 *	jiffies - read_cache_jiffies > attrtimeo
+	 *	jiffies - read_cache_jiffies >= attrtimeo
+	 *
+	 * Please note the comparison is greater than or equal
+	 * so that zero timeout values can be specified.
 	 */
 	unsigned long		read_cache_jiffies;
 	unsigned long		attrtimeo;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 6e28744..050e4e8 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -234,7 +234,7 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
 
 		/* Enforce a 60 second garbage collection moratorium */
-		if (time_in_range(cred->cr_expire, expired, jiffies) &&
+		if (time_in_range_open(cred->cr_expire, expired, jiffies) &&
 		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
 			continue;
 

