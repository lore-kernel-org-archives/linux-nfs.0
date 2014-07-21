Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:61056 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181AbaGUPDC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:02 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so5054205qae.20
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 01/40] nfsd4: use cl_lock to synchronize all stateid idr calls
Date: Mon, 21 Jul 2014 11:02:13 -0400
Message-Id: <1405954972-28904-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
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
index 3946a5a9459c..3e55df0d7504 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -455,7 +455,6 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
 kmem_cache *slab)
 {
-	struct idr *stateids = &cl->cl_stateids;
 	struct nfs4_stid *stid;
 	int new_id;
 
@@ -463,7 +462,11 @@ kmem_cache *slab)
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
@@ -603,9 +606,11 @@ out_dec:
 
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
@@ -1421,7 +1426,9 @@ free_client(struct nfs4_client *clp)
 	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
 	free_svc_cred(&clp->cl_cred);
 	kfree(clp->cl_name.data);
+	spin_lock(&clp->cl_lock);
 	idr_destroy(&clp->cl_stateids);
+	spin_unlock(&clp->cl_lock);
 	kfree(clp);
 }
 
@@ -1647,7 +1654,9 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
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

