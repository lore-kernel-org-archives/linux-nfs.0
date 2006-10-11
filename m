From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 6/8] knfsd: repcache: use client IP address in hash
Date: Wed, 11 Oct 2006 21:28:50 +1000
Message-ID: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcGd-0001Wa-6J
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:28:55 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcGd-0007TA-V5
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:28:56 -0700
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

knfsd: Use the client's IP address in the duplicate request cache
hash function, instead of just the XID.  This avoids contention
on hash buckets when the workload has many clients whose XIDs are
nearly in lockstep, a property seen on compute clusters using NFS
for shared storage.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-10 16:41:07.121363949 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-10 16:41:49.107949488 +1000
@@ -93,13 +93,18 @@ static int			cache_disabled = 1;
  * Calculate the hash index from an XID.  Note, some clients increment
  * their XIDs in host order, which can result in all the variation being
  * in the top bits we see here.  So we fold those bits down.
+ *
+ * Experiment shows that using the Jenkins hash improves the spectral
+ * properties of this hash, but the CPU cost of calculating it outweighs
+ * the advantages.
  */
 static inline u32
-request_hash(u32 xid)
+request_hash(u32 xid, const struct sockaddr_in *sin)
 {
 	u32 h = xid;
 	h ^= (xid >> 24);
 	h ^= ((xid & 0xff0000) >> 8);
+	h ^= sin->sin_addr.s_addr;
 	return h;
 }
 
@@ -248,7 +253,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	int			safe = 0;
 	int			expand = 0;
 
-	h = request_hash(xid);
+	h = request_hash(xid, &rqstp->rq_addr);
 	b = bucket_for_hash(h);
 	h = (h / CACHE_NUM_BUCKETS) & (HASHSIZE-1);
 
@@ -399,7 +404,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
 		return;
 
-	b = bucket_for_hash(request_hash(rp->c_xid));
+	b = bucket_for_hash(request_hash(rp->c_xid, &rp->c_addr));
 
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
 	len >>= 2;

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
