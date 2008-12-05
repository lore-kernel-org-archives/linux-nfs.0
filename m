From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH V3] optimize attribute timeouts for "noac" and "actimeo=0"
Date: Fri, 05 Dec 2008 16:37:05 -0500
Message-ID: <49399F01.9090409@redhat.com>
References: <484EE994.5030907@redhat.com> <487390EC.7080403@redhat.com>	 <76bd70e30807100858g58fbf454uc9331035a2bbf264@mail.gmail.com>	 <487649AE.1090909@redhat.com> <1215718184.7126.44.camel@localhost>	 <4877BF39.20102@redhat.com> <1215807540.17983.2.camel@localhost> <4877C17A.7000009@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060900020602090808030803"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51003 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755504AbYLEVhL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2008 16:37:11 -0500
In-Reply-To: <4877C17A.7000009@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060900020602090808030803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

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


--------------060900020602090808030803
Content-Type: text/plain;
 name="attrtimeo.devel.3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="attrtimeo.devel.3"

--- linux-2.6.27.i686/fs/nfs/inode.c.org
+++ linux-2.6.27.i686/fs/nfs/inode.c
@@ -712,14 +735,7 @@ int nfs_attribute_timeout(struct inode *
 
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
@@ -1182,7 +1198,7 @@ static int nfs_update_inode(struct inode
 		nfsi->attrtimeo_timestamp = now;
 		nfsi->attr_gencount = nfs_inc_attr_generation_counter();
 	} else {
-		if (!time_in_range(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
+		if (!time_in_range_open(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
 			if ((nfsi->attrtimeo <<= 1) > NFS_MAXATTRTIMEO(inode))
 				nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
 			nfsi->attrtimeo_timestamp = now;
--- linux-2.6.27.i686/fs/nfs/dir.c.org
+++ linux-2.6.27.i686/fs/nfs/dir.c
@@ -1794,7 +1794,7 @@ static int nfs_access_get_cached(struct 
 	cache = nfs_access_search_rbtree(inode, cred);
 	if (cache == NULL)
 		goto out;
-	if (!time_in_range(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
+	if (!time_in_range_open(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
 		goto out_stale;
 	res->jiffies = cache->jiffies;
 	res->cred = cache->cred;
--- linux-2.6.27.i686/include/linux/nfs_fs.h.org
+++ linux-2.6.27.i686/include/linux/nfs_fs.h
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
--- linux-2.6.27.i686/include/linux/jiffies.h.org
+++ linux-2.6.27.i686/include/linux/jiffies.h
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
--- linux-2.6.27.i686/net/sunrpc/auth.c.org
+++ linux-2.6.27.i686/net/sunrpc/auth.c
@@ -234,7 +234,7 @@ rpcauth_prune_expired(struct list_head *
 	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
 
 		/* Enforce a 60 second garbage collection moratorium */
-		if (time_in_range(cred->cr_expire, expired, jiffies) &&
+		if (time_in_range_open(cred->cr_expire, expired, jiffies) &&
 		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
 			continue;
 

--------------060900020602090808030803--
