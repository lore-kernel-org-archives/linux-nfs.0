Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:49953 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756449Ab3BUS2p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 13:28:45 -0500
Received: by mail-qa0-f53.google.com with SMTP id z4so3168166qan.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2013 10:28:45 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/5] nfsd: break out comparator into separate function
Date: Thu, 21 Feb 2013 13:28:34 -0500
Message-Id: <1361471318-17971-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1361471318-17971-1-git-send-email-jlayton@redhat.com>
References: <1361471318-17971-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Break out the function that compares the rqstp and checksum against a
reply cache entry. While we're at it, track the efficacy of the checksum
over the NFS data by tracking the cases where we would have incorrectly
matched a DRC entry if we had not tracked it or the length.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index ca43664..8986568 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -25,6 +25,7 @@ static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
 static unsigned int		num_drc_entries;
 static unsigned int		max_drc_entries;
+static unsigned int		csum_misses;
 
 /*
  * Calculate the hash index from an XID.
@@ -272,6 +273,26 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
 	return csum;
 }
 
+static bool
+nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
+{
+	/* Check RPC header info first */
+	if (rqstp->rq_xid != rp->c_xid || rqstp->rq_proc != rp->c_proc ||
+	    rqstp->rq_prot != rp->c_prot || rqstp->rq_vers != rp->c_vers ||
+	    rqstp->rq_arg.len != rp->c_len ||
+	    !rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
+	    rpc_get_port(svc_addr(rqstp)) != rpc_get_port((struct sockaddr *)&rp->c_addr))
+		return false;
+
+	/* compare checksum of NFS data */
+	if (csum != rp->c_csum) {
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
@@ -283,18 +304,10 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
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

