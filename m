Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:49582 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758210Ab3CDS4s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 13:56:48 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so990063vby.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2013 10:56:48 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/5] nfsd: break out comparator into separate function
Date: Mon,  4 Mar 2013 13:56:36 -0500
Message-Id: <1362423400-24380-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
References: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Break out the function that compares the rqstp and checksum against a
reply cache entry. While we're at it, track the efficacy of the checksum
over the NFS data by tracking the cases where we would have incorrectly
matched a DRC entry if we had not tracked it or the length.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 44 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 34 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 62c1ee1..3fba32f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -23,9 +23,21 @@
 static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
+
+/*
+ * Stats and other tracking of on the duplicate reply cache. All of these and
+ * the "rc" fields in nfsdstats are protected by the cache_lock
+ */
+
+/* total number of entries */
 static unsigned int		num_drc_entries;
+
+/* max number of entries allowed in the cache */
 static unsigned int		max_drc_entries;
 
+/* cache misses due only to checksum comparison failures */
+static unsigned int		payload_misses;
+
 /*
  * Calculate the hash index from an XID.
  */
@@ -272,6 +284,26 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
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
+		++payload_misses;
+		return false;
+	}
+
+	return true;
+}
+
 /*
  * Search the request hash for an entry that matches the given rqstp.
  * Must be called with cache_lock held. Returns the found entry or
@@ -282,18 +314,10 @@ nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
 {
 	struct svc_cacherep	*rp;
 	struct hlist_head 	*rh;
-	__be32			xid = rqstp->rq_xid;
-	u32			proto =  rqstp->rq_prot,
-				vers = rqstp->rq_vers,
-				proc = rqstp->rq_proc;
 
-	rh = &cache_hash[request_hash(xid)];
+	rh = &cache_hash[request_hash(rqstp->rq_xid)];
 	hlist_for_each_entry(rp, rh, c_hash) {
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

