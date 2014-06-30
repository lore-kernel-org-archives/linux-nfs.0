Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:33877 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbaF3PvB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:01 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so6646111qac.35
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:01 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH v3 020/114] nfsd4: use cl_lock to synchronize all stateid idr calls
Date: Mon, 30 Jun 2014 11:48:49 -0400
Message-Id: <1404143423-24381-21-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

Currently, this is serialized by the client_mutex, which is slated for
removal. Add finer-grained locking here.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7f81207c3862..993aa196dd9e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -343,7 +343,6 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
 kmem_cache *slab)
 {
-	struct idr *stateids = &cl->cl_stateids;
 	struct nfs4_stid *stid;
 	int new_id;
 
@@ -351,7 +350,11 @@ kmem_cache *slab)
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
@@ -487,9 +490,11 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 
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
@@ -1263,7 +1268,9 @@ free_client(struct nfs4_client *clp)
 	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
 	free_svc_cred(&clp->cl_cred);
 	kfree(clp->cl_name.data);
+	spin_lock(&clp->cl_lock);
 	idr_destroy(&clp->cl_stateids);
+	spin_unlock(&clp->cl_lock);
 	kfree(clp);
 }
 
@@ -1486,7 +1493,9 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
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

