From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 1/8] knfsd: repcache: minor cleanups
Date: Wed, 11 Oct 2006 21:25:18 +1000
Message-ID: <1160565918.8530.7.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcDG-0001Dd-3e
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:25:26 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcDF-0006hc-Rg
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:25:27 -0700
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

knfsd: Minor whitespace, formatting and comment changes to
the duplicate request cache.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c         |   15 +++++++--------
 include/linux/nfsd/cache.h |    3 +--
 2 files changed, 8 insertions(+), 10 deletions(-)

Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-10 15:50:40.446797369 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-10 16:36:15.534951195 +1000
@@ -37,7 +37,7 @@ static int			cache_disabled = 1;
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 
-/* 
+/*
  * locking for the reply cache:
  * A cache entry is "single use" if c_state == RC_INPROG
  * Otherwise, it when accessing _prev or _next, the lock must be held.
@@ -52,9 +52,10 @@ nfsd_cache_init(void)
 
 	INIT_LIST_HEAD(&lru_head);
 	i = CACHESIZE;
-	while(i) {
+	while (i) {
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-		if (!rp) break;
+		if (!rp)
+			break;
 		list_add(&rp->c_lru, &lru_head);
 		rp->c_state = RC_UNUSED;
 		rp->c_type = RC_NOCACHE;
@@ -132,7 +133,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 				vers = rqstp->rq_vers,
 				proc = rqstp->rq_proc;
 	unsigned long		age;
-	int rtn;
+	int			rtn;
+	int			safe = 0;
 
 	rqstp->rq_cacherep = NULL;
 	if (cache_disabled || type == RC_NOCACHE) {
@@ -157,8 +159,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	nfsdstats.rcmisses++;
 
 	/* This loop shouldn't take more than a few iterations normally */
-	{
-	int	safe = 0;
 	list_for_each_entry(rp, &lru_head, c_lru) {
 		if (rp->c_state != RC_INPROG)
 			break;
@@ -168,7 +168,6 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 			goto out;
 		}
 	}
-	}
 
 	/* This should not happen */
 	if (rp == NULL) {
@@ -269,7 +268,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
 	len >>= 2;
-	
+
 	/* Don't cache excessive amounts of data and XDR failures */
 	if (!statp || len > (256 >> 2)) {
 		rp->c_state = RC_UNUSED;
Index: linux-git-20061009/include/linux/nfsd/cache.h
===================================================================
--- linux-git-20061009.orig/include/linux/nfsd/cache.h	2006-10-10 15:50:40.470794276 +1000
+++ linux-git-20061009/include/linux/nfsd/cache.h	2006-10-10 16:35:26.737238900 +1000
@@ -15,8 +15,7 @@
 #include <linux/uio.h>
 
 /*
- * Representation of a reply cache entry. The first two members *must*
- * be hash_next and hash_prev.
+ * Representation of a reply cache entry.
  */
 struct svc_cacherep {
 	struct hlist_node	c_hash;


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
