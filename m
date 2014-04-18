Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:62238 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbaDRSpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:14 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so943231igq.7
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/70] nfsd4: use cl_lock to synchronize all stateid idr calls
Date: Fri, 18 Apr 2014 14:44:00 -0400
Message-Id: <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 34273ca482c3..626f310a74a8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -334,7 +334,11 @@ kmem_cache *slab)
 	if (!stid)
 		return NULL;
 
-	new_id = idr_alloc_cyclic(stateids, stid, 0, 0, GFP_KERNEL);
+	idr_preload(GFP_KERNEL);
+	spin_lock(&cl->cl_lock);
+	new_id = idr_alloc_cyclic(stateids, stid, 0, 0, GFP_NOWAIT);
+	spin_unlock(&cl->cl_lock);
+	idr_preload_end();
 	if (new_id < 0)
 		goto out_free;
 	stid->sc_client = cl;
@@ -397,9 +401,12 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 
 static void remove_stid(struct nfs4_stid *s)
 {
-	struct idr *stateids = &s->sc_client->cl_stateids;
+	struct nfs4_client *clp = s->sc_client;
+	struct idr *stateids = &clp->cl_stateids;
 
+	spin_lock(&clp->cl_lock);
 	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
+	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
@@ -1110,7 +1117,9 @@ free_client(struct nfs4_client *clp)
 	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
 	free_svc_cred(&clp->cl_cred);
 	kfree(clp->cl_name.data);
+	spin_lock(&clp->cl_lock);
 	idr_destroy(&clp->cl_stateids);
+	spin_unlock(&clp->cl_lock);
 	kfree(clp);
 }
 
@@ -1329,7 +1338,9 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
 
+	spin_lock(&cl->cl_lock);
 	ret = idr_find(&cl->cl_stateids, t->si_opaque.so_id);
+	spin_unlock(&cl->cl_lock);
 	if (!ret || !ret->sc_type)
 		return NULL;
 	return ret;
-- 
1.9.0

