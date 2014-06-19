Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34469 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757835AbaFSOvE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:04 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so2165095qga.23
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:03 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 004/104] nfsd4: use cl_lock to synchronize all stateid idr calls
Date: Thu, 19 Jun 2014 10:49:10 -0400
Message-Id: <1403189450-18729-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d18fd8c7691c..8dc1289a7b74 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -326,7 +326,6 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
 kmem_cache *slab)
 {
-	struct idr *stateids = &cl->cl_stateids;
 	struct nfs4_stid *stid;
 	int new_id;
 
@@ -334,7 +333,11 @@ kmem_cache *slab)
 	if (!stid)
 		return NULL;
 
-	new_id = idr_alloc_cyclic(stateids, stid, 0, 0, GFP_KERNEL);
+	idr_preload(GFP_KERNEL);
+	spin_lock(&cl->cl_lock);
+	new_id = idr_alloc_cyclic(&cl->cl_stateids, stid, 0, 0, GFP_NOWAIT);
+	spin_unlock(&cl->cl_lock);
+	idr_preload_end();
 	if (new_id < 0)
 		goto out_free;
 	stid->sc_client = cl;
@@ -396,9 +399,11 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 
 static void remove_stid(struct nfs4_stid *s)
 {
-	struct idr *stateids = &s->sc_client->cl_stateids;
+	struct nfs4_client *clp = s->sc_client;
 
-	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
+	spin_lock(&clp->cl_lock);
+	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
+	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
@@ -1141,7 +1146,9 @@ free_client(struct nfs4_client *clp)
 	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
 	free_svc_cred(&clp->cl_cred);
 	kfree(clp->cl_name.data);
+	spin_lock(&clp->cl_lock);
 	idr_destroy(&clp->cl_stateids);
+	spin_unlock(&clp->cl_lock);
 	kfree(clp);
 }
 
@@ -1364,7 +1371,9 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
 
+	spin_lock(&cl->cl_lock);
 	ret = idr_find(&cl->cl_stateids, t->si_opaque.so_id);
+	spin_unlock(&cl->cl_lock);
 	if (!ret || !ret->sc_type)
 		return NULL;
 	return ret;
-- 
1.9.3

