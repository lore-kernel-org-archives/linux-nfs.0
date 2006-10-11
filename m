From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 2/8] knfsd: repcache: make REQHASH a function
Date: Wed, 11 Oct 2006 21:26:08 +1000
Message-ID: <1160565968.8530.9.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcE0-0001JG-R9
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:26:12 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcE1-0006sS-JD
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:26:13 -0700
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

knfsd: Make the REQHASH() macro in the duplicate request cache an inline
function, as interesting things will happen to it soon.  Also, make
sure we get lots of variation in the low bits regardless of which
end of the xid the clients increment.  Finally add a comment.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-10 16:36:15.534951195 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-10 16:37:37.316411743 +1000
@@ -29,12 +29,25 @@
  */
 #define CACHESIZE		1024
 #define HASHSIZE		64
-#define REQHASH(xid)		((((xid) >> 24) ^ (xid)) & (HASHSIZE-1))
 
 static struct hlist_head *	hash_list;
 static struct list_head 	lru_head;
 static int			cache_disabled = 1;
 
+/*
+ * Calculate the hash index from an XID.  Note, some clients increment
+ * their XIDs in host order, which can result in all the variation being
+ * in the top bits we see here.  So we fold those bits down.
+ */
+static inline u32
+request_hash(u32 xid)
+{
+	u32 h = xid;
+	h ^= (xid >> 24);
+	h ^= ((xid & 0xff0000) >> 8);
+	return h & (HASHSIZE-1);
+}
+
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 
 /*
@@ -114,7 +127,7 @@ static void
 hash_refile(struct svc_cacherep *rp)
 {
 	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, hash_list + REQHASH(rp->c_xid));
+	hlist_add_head(&rp->c_hash, hash_list + request_hash(rp->c_xid));
 }
 
 /*
@@ -145,7 +158,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	spin_lock(&cache_lock);
 	rtn = RC_DOIT;
 
-	rh = &hash_list[REQHASH(xid)];
+	rh = &hash_list[request_hash(xid)];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid && proc == rp->c_proc &&


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
