From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 3/8] knfsd: repcache: inline hash_refile
Date: Wed, 11 Oct 2006 21:26:51 +1000
Message-ID: <1160566010.8530.11.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcEi-0001Kb-1j
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:26:56 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcEi-0006yU-RA
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:26:57 -0700
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

knfsd: Explicitly inline the duplicate request cache's hash_refile()
function, it's only used in one place anyway.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-10 16:37:37.316411743 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-10 16:37:52.170497220 +1000
@@ -121,16 +121,6 @@ lru_put_end(struct svc_cacherep *rp)
 }
 
 /*
- * Move a cache entry from one hash list to another
- */
-static void
-hash_refile(struct svc_cacherep *rp)
-{
-	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, hash_list + request_hash(rp->c_xid));
-}
-
-/*
  * Try to find an entry matching the current call in the cache. When none
  * is found, we grab the oldest unlocked entry off the LRU list.
  * Note that no operation within the loop may sleep.
@@ -203,7 +193,9 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rp->c_vers = vers;
 	rp->c_timestamp = jiffies;
 
-	hash_refile(rp);
+ 	/* Move the cache entry from one hash list to another */
+	hlist_del_init(&rp->c_hash);
+	hlist_add_head(&rp->c_hash, hash_list + request_hash(rp->c_xid));
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {

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
