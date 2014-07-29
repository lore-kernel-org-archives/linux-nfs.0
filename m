Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:55033 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366AbaG2Uei (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:38 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so279353qgd.33
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:37 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 05/38] nfsd4: use cl_lock to synchronize all stateid idr calls
Date: Tue, 29 Jul 2014 16:33:48 -0400
Message-Id: <1406666061-14175-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, this is serialized by the client_mutex, which is slated for
removal. Add finer-grained locking here. Also, do some cleanup around
find_stateid to prepare for taking references.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3c8f45f18186..e45a45d12954 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -467,7 +467,6 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
 					 struct kmem_cache *slab)
 {
-	struct idr *stateids = &cl->cl_stateids;
 	struct nfs4_stid *stid;
 	int new_id;
 
@@ -475,7 +474,11 @@ static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
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
@@ -635,9 +638,12 @@ nfs4_put_stid(struct nfs4_stid *s)
 	struct nfs4_file *fp = s->sc_file;
 	struct nfs4_client *clp = s->sc_client;
 
-	if (!atomic_dec_and_test(&s->sc_count))
+	might_lock(&clp->cl_lock);
+
+	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock))
 		return;
 	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
+	spin_unlock(&clp->cl_lock);
 	s->sc_free(s);
 	if (fp)
 		put_nfs4_file(fp);
@@ -1652,7 +1658,8 @@ static void gen_confirm(struct nfs4_client *clp)
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
-static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
+static struct nfs4_stid *
+find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
 
@@ -1662,16 +1669,28 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 	return ret;
 }
 
-static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
+static struct nfs4_stid *
+find_stateid(struct nfs4_client *cl, stateid_t *t)
+{
+	struct nfs4_stid *ret;
+
+	spin_lock(&cl->cl_lock);
+	ret = find_stateid_locked(cl, t);
+	spin_unlock(&cl->cl_lock);
+	return ret;
+}
+
+static struct nfs4_stid *
+find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
 
-	s = find_stateid(cl, t);
-	if (!s)
-		return NULL;
-	if (typemask & s->sc_type)
-		return s;
-	return NULL;
+	spin_lock(&cl->cl_lock);
+	s = find_stateid_locked(cl, t);
+	if (s != NULL && !(typemask & s->sc_type))
+		s = NULL;
+	spin_unlock(&cl->cl_lock);
+	return s;
 }
 
 static struct nfs4_client *create_client(struct xdr_netobj name,
-- 
1.9.3

