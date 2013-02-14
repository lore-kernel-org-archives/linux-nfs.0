Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f176.google.com ([209.85.160.176]:50186 "EHLO
	mail-gh0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602Ab3BNVpX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 16:45:23 -0500
Received: by mail-gh0-f176.google.com with SMTP id f16so4596ghb.7
        for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2013 13:45:22 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfsd: break out comparator into separate function
Date: Thu, 14 Feb 2013 16:45:14 -0500
Message-Id: <1360878315-21578-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
References: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Break the function that compares the rqstp and checksum against a reply
cache entry. While we're at it, track the efficacy of the checksum over
the NFS data by tracking the cases where we would have incorrectly
matched a DRC entry if we had not tracked it or the length.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 37 +++++++++++++++++++++++++++----------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 2f9c2d2..bccf74f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -25,6 +25,7 @@ static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
 static unsigned int		num_drc_entries;
 static unsigned int		max_drc_entries;
+static unsigned int		csum_misses;
 
 /*
  * Calculate the hash index from an XID.
@@ -272,6 +273,30 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
 	return csum;
 }
 
+static bool
+nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
+{
+	__be32			xid = rqstp->rq_xid;
+	u32			proto =  rqstp->rq_prot,
+				vers = rqstp->rq_vers,
+				proc = rqstp->rq_proc;
+
+	/* Check RPC header info first */
+	if (xid != rp->c_xid || proc != rp->c_proc ||
+	    proto != rp->c_prot || vers != rp->c_vers ||
+	    !rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
+	    rpc_get_port(svc_addr(rqstp)) != rpc_get_port((struct sockaddr *)&rp->c_addr))
+		return false;
+
+	/* check contents of the NFS data */
+	if (rqstp->rq_arg.len != rp->c_len || csum != rp->c_csum) {
+		++csum_misses;
+		return false;
+	}
+
+	return true;
+}
+
 /*
  * Search the request hash for an entry that matches the given rqstp.
  * Must be called with cache_lock held. Returns the found entry or
@@ -283,18 +308,10 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 	struct svc_cacherep	*rp;
 	struct hlist_node	*hn;
 	struct hlist_head 	*rh;
-	__be32			xid = rqstp->rq_xid;
-	u32			proto =  rqstp->rq_prot,
-				vers = rqstp->rq_vers,
-				proc = rqstp->rq_proc;
 
-	rh = &cache_hash[request_hash(xid)];
+	rh = &cache_hash[request_hash(rqstp->rq_xid)];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
-		if (xid == rp->c_xid && proc == rp->c_proc &&
-		    proto == rp->c_prot && vers == rp->c_vers &&
-		    rqstp->rq_arg.len == rp->c_len && csum == rp->c_csum &&
-		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
-		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
+		if (nfsd_cache_match(rqstp, csum, rp))
 			return rp;
 	}
 	return NULL;
-- 
1.7.11.7

