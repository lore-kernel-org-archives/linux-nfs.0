From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 7/8] knfsd: repcache: faster hash chain probe
Date: Wed, 11 Oct 2006 21:29:38 +1000
Message-ID: <1160566178.8530.19.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcHP-0001cN-Eu
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:29:43 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcHQ-0007eP-76
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:29:44 -0700
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

knfsd: Squeeze some small performance improvements out of the duplicate
request cache's lookup function by reducing the number of instructions
to compare each entry during hash chain probing.

Comparisons such as the RPC protocol number and version which are going
to be the same for almost all entries are now done last.  Comparisons
such as xid and client IP address which are more likely to differ
between entries are done first.  The client IP address comparison
is fixed not to compare 8 bytes of zeroes and to do comparisons as
32b quantities.  Finally, a 32b addition for the timestamp is removed
from the loop by taking advantage of a loop invariant.

On a 4 cpu Altix A350, running at circa 80,000 nonidempotent calls
per second, this change reduced CPU usage in nfsd_cache_lookup()
from 28.1% to 27.1% (out of 400%).

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/nfscache.c |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

Index: linux-git-20061009/fs/nfsd/nfscache.c
===================================================================
--- linux-git-20061009.orig/fs/nfsd/nfscache.c	2006-10-10 16:41:49.107949488 +1000
+++ linux-git-20061009/fs/nfsd/nfscache.c	2006-10-10 16:42:21.727742579 +1000
@@ -108,6 +108,23 @@ request_hash(u32 xid, const struct socka
 	return h;
 }
 
+
+/*
+ * Fast compare of two sockaddr_in's.  Ignore the zero padding at
+ * the end of a sockaddr_in; compares sin_family and sin_port in
+ * one comparison.  Returns 1 if identical, 0 otherwise.
+ *
+ * Alignment issues prevent us from comparing all the relevant
+ * fields in a single 64b comparison on 64b platforms: the most
+ * we can assume is that sin_addr is 32b-aligned.
+ */
+static inline int
+compare_sockaddr_in(const struct sockaddr_in *sina, const struct sockaddr_in *sinb)
+{
+	return ((*(u32 *)&sina->sin_family == *(u32 *)&sinb->sin_family) &&
+		(sina->sin_addr.s_addr == sinb->sin_addr.s_addr));
+}
+
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 
 /*
@@ -267,12 +284,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rtn = RC_DOIT;
 
 	rh = &b->hash[h];
+	age = jiffies - 120*HZ;
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (rp->c_state != RC_UNUSED &&
-		    xid == rp->c_xid && proc == rp->c_proc &&
+		    xid == rp->c_xid &&
+		    compare_sockaddr_in(&rqstp->rq_addr, &rp->c_addr) &&
+		    proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
-		    time_before(jiffies, rp->c_timestamp + 120*HZ) &&
-		    memcmp((char*)&rqstp->rq_addr, (char*)&rp->c_addr, sizeof(rp->c_addr))==0) {
+		    time_after(rp->c_timestamp, age)) {
 			nfsdstats.rchits++;
 			goto found_entry;
 		}

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
