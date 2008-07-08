From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH V2] make "noac" and "actimeo=0" work correctly
Date: Tue, 08 Jul 2008 12:08:12 -0400
Message-ID: <487390EC.7080403@redhat.com>
References: <484EE994.5030907@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050404000502030505000508"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519AbYGHQIa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2008 12:08:30 -0400
In-Reply-To: <484EE994.5030907@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050404000502030505000508
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

While I was there, I addressed a problem with the jiffies
overflowing on 32 bit systems.  When overflow occurs, the
value of read_cache_jiffies + attrtimeo can be less then the
value of read_cache_jiffies.  This would cause an unnecessary
GETATTR over the wire.

Thoughts and/or comments?  This is an updated patch which includes
the previous support which was added to correct the noac/actimeo=0
handling.

  Thanx...

     ps

Signed-off-by: Peter Staubach <staubach@redhat.com>


--------------050404000502030505000508
Content-Type: text/plain;
 name="attrtimeo.devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="attrtimeo.devel"

--- linux-2.6.25.i686/fs/nfs/dir.c.org
+++ linux-2.6.25.i686/fs/nfs/dir.c
@@ -1808,7 +1808,7 @@ static int nfs_access_get_cached(struct 
 	cache = nfs_access_search_rbtree(inode, cred);
 	if (cache == NULL)
 		goto out;
-	if (!time_in_range(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
+	if (!nfs_time_in_range_open(jiffies, cache->jiffies, cache->jiffies + nfsi->attrtimeo))
 		goto out_stale;
 	res->jiffies = cache->jiffies;
 	res->cred = cache->cred;
--- linux-2.6.25.i686/fs/nfs/inode.c.org
+++ linux-2.6.25.i686/fs/nfs/inode.c
@@ -706,14 +706,7 @@ int nfs_attribute_timeout(struct inode *
 
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
+	return !nfs_time_in_range_open(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
 }
 
 /**
@@ -1098,7 +1091,7 @@ static int nfs_update_inode(struct inode
 		nfsi->attrtimeo_timestamp = now;
 		nfsi->last_updated = now;
 	} else {
-		if (!time_in_range(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
+		if (!nfs_time_in_range_open(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo_timestamp + nfsi->attrtimeo)) {
 			if ((nfsi->attrtimeo <<= 1) > NFS_MAXATTRTIMEO(inode))
 				nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
 			nfsi->attrtimeo_timestamp = now;
--- linux-2.6.25.i686/include/linux/nfs_fs.h.org
+++ linux-2.6.25.i686/include/linux/nfs_fs.h
@@ -121,7 +121,7 @@ struct nfs_inode {
 	 *
 	 * We need to revalidate the cached attrs for this inode if
 	 *
-	 *	jiffies - read_cache_jiffies > attrtimeo
+	 *	jiffies - read_cache_jiffies >= attrtimeo
 	 */
 	unsigned long		read_cache_jiffies;
 	unsigned long		attrtimeo;
@@ -244,6 +244,22 @@ static inline unsigned NFS_MAXATTRTIMEO(
 	return S_ISDIR(inode->i_mode) ? nfss->acdirmax : nfss->acregmax;
 }
 
+static inline int nfs_time_in_range_open(unsigned long a,
+				unsigned long b, unsigned long c)
+{
+	/*
+	 * If c is less then b, then the jiffies have wrapped.
+	 * If so, then check to see if a is between b and the
+	 * max jiffies value or between 0 and the value of c.
+	 * This is the range between b and c.
+	 *
+	 * Otherwise, just check to see whether a is in [b, c).
+	 */
+	if (c < b)
+		return time_after_eq(a, b) || time_before(a, c);
+	return time_after_eq(a, b) && time_before(a, c);
+}
+
 static inline int NFS_STALE(const struct inode *inode)
 {
 	return test_bit(NFS_INO_STALE, &NFS_I(inode)->flags);

--------------050404000502030505000508--
