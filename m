From: Greg Banks <gnb@sgi.com>
Subject: [patch 19/29] knfsd: faster probing in the reply cache
Date: Wed, 01 Apr 2009 07:28:19 +1100
Message-ID: <20090331202944.736093000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22573 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756715AbZCaVCf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Slightly reorganise the CPU-intensive hash chain probing to check
for more commonly varying entry keys first, and to reduce arithmetic
operations by hoisting out an invariant.  This slightly reduces the
CPU time spent in nfsd_cache_lookup() under heavy nonidempotent loads.

This code predates the IPv6 support in the NFS server but should be
harmless with IPv6 clients.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfscache.c |   25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

Index: bfields/fs/nfsd/nfscache.c
===================================================================
--- bfields.orig/fs/nfsd/nfscache.c
+++ bfields/fs/nfsd/nfscache.c
@@ -108,6 +108,23 @@ static inline u32 request_hash(u32 xid, 
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
@@ -263,12 +280,14 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rtn = RC_DOIT;
 
 	rh = &b->hash[h];
+	age = jiffies - 120*HZ;
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (rp->c_state != RC_UNUSED &&
-		    xid == rp->c_xid && proc == rp->c_proc &&
+		    xid == rp->c_xid &&
+		    compare_sockaddr_in(svc_addr_in(rqstp), &rp->c_addr) &&
+		    proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
-		    time_before(jiffies, rp->c_timestamp + 120*HZ) &&
-		    memcmp((char*)&rqstp->rq_addr, (char*)&rp->c_addr, sizeof(rp->c_addr))==0) {
+		    time_after(rp->c_timestamp, age)) {
 			nfsdstats.rchits++;
 			goto found_entry;
 		}

--
Greg
