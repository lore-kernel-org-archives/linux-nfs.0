Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f181.google.com ([209.85.160.181]:59547 "EHLO
	mail-gh0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176Ab3A1Tsf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:48:35 -0500
Received: by mail-gh0-f181.google.com with SMTP id y8so477244ghb.40
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:48:34 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 08/16] nfsd: break out hashtable search into separate function
Date: Mon, 28 Jan 2013 14:41:14 -0500
Message-Id: <1359402082-29195-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Later, we'll need more than one call site for this, so break it out
into a new function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 46 +++++++++++++++++++++++++++++++++-------------
 1 file changed, 33 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 634b856..b89e7c8 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -150,6 +150,35 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
 }
 
 /*
+ * Search the request hash for an entry that matches the given rqstp.
+ * Must be called with cache_lock held. Returns the found entry or
+ * NULL on failure.
+ */
+static struct svc_cacherep *
+nfsd_cache_search(struct svc_rqst *rqstp)
+{
+	struct svc_cacherep	*rp;
+	struct hlist_node	*hn;
+	struct hlist_head 	*rh;
+	__be32			xid = rqstp->rq_xid;
+	u32			proto =  rqstp->rq_prot,
+				vers = rqstp->rq_vers,
+				proc = rqstp->rq_proc;
+
+	rh = &cache_hash[request_hash(xid)];
+	hlist_for_each_entry(rp, hn, rh, c_hash) {
+		if (rp->c_state != RC_UNUSED &&
+		    xid == rp->c_xid && proc == rp->c_proc &&
+		    proto == rp->c_prot && vers == rp->c_vers &&
+		    !nfsd_cache_entry_expired(rp) &&
+		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
+		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr))
+			return rp;
+	}
+	return NULL;
+}
+
+/*
  * Try to find an entry matching the current call in the cache. When none
  * is found, we grab the oldest unlocked entry off the LRU list.
  * Note that no operation within the loop may sleep.
@@ -157,8 +186,6 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
 int
 nfsd_cache_lookup(struct svc_rqst *rqstp)
 {
-	struct hlist_node	*hn;
-	struct hlist_head 	*rh;
 	struct svc_cacherep	*rp;
 	__be32			xid = rqstp->rq_xid;
 	u32			proto =  rqstp->rq_prot,
@@ -177,17 +204,10 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	spin_lock(&cache_lock);
 	rtn = RC_DOIT;
 
-	rh = &cache_hash[request_hash(xid)];
-	hlist_for_each_entry(rp, hn, rh, c_hash) {
-		if (rp->c_state != RC_UNUSED &&
-		    xid == rp->c_xid && proc == rp->c_proc &&
-		    proto == rp->c_prot && vers == rp->c_vers &&
-		    !nfsd_cache_entry_expired(rp) &&
-		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
-		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr)) {
-			nfsdstats.rchits++;
-			goto found_entry;
-		}
+	rp = nfsd_cache_search(rqstp);
+	if (rp) {
+		nfsdstats.rchits++;
+		goto found_entry;
 	}
 	nfsdstats.rcmisses++;
 
-- 
1.7.11.7

