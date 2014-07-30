Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:62820 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbaG3Bfe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:34 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so659268qgf.7
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:33 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 29/38] nfsd: Protect adding/removing open state owners using client_lock
Date: Tue, 29 Jul 2014 21:34:34 -0400
Message-Id: <1406684083-19736-30-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Once we remove client mutex protection, we'll need to ensure that
stateowner lookup and creation are atomic between concurrent compounds.
Ensure that alloc_init_open_stateowner checks the hashtable under the
client_lock before adding a new element.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 118 +++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 80 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6d26d26751f5..c4bb7f2b29d9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -239,6 +239,53 @@ static void nfsd4_put_session(struct nfsd4_session *ses)
 	spin_unlock(&nn->client_lock);
 }
 
+static int
+same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
+							clientid_t *clid)
+{
+	return (sop->so_owner.len == owner->len) &&
+		0 == memcmp(sop->so_owner.data, owner->data, owner->len) &&
+		(sop->so_client->cl_clientid.cl_id == clid->cl_id);
+}
+
+static struct nfs4_openowner *
+find_openstateowner_str_locked(unsigned int hashval, struct nfsd4_open *open,
+			bool sessions, struct nfsd_net *nn)
+{
+	struct nfs4_stateowner *so;
+	struct nfs4_openowner *oo;
+	struct nfs4_client *clp;
+
+	lockdep_assert_held(&nn->client_lock);
+
+	list_for_each_entry(so, &nn->ownerstr_hashtbl[hashval], so_strhash) {
+		if (!so->so_is_open_owner)
+			continue;
+		if (same_owner_str(so, &open->op_owner, &open->op_clientid)) {
+			oo = openowner(so);
+			clp = oo->oo_owner.so_client;
+			if ((bool)clp->cl_minorversion != sessions)
+				break;
+			renew_client_locked(clp);
+			atomic_inc(&so->so_count);
+			return oo;
+		}
+	}
+	return NULL;
+}
+
+static struct nfs4_openowner *
+find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
+			bool sessions, struct nfsd_net *nn)
+{
+	struct nfs4_openowner *oo;
+
+	spin_lock(&nn->client_lock);
+	oo = find_openstateowner_str_locked(hashval, open, sessions, nn);
+	spin_unlock(&nn->client_lock);
+	return oo;
+}
+
 
 static inline u32
 opaque_hashval(const void *ptr, int nbytes)
@@ -1005,8 +1052,13 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 	nfs4_put_stid(&stp->st_stid);
 }
 
-static void unhash_openowner(struct nfs4_openowner *oo)
+static void unhash_openowner_locked(struct nfs4_openowner *oo)
 {
+	struct nfsd_net *nn = net_generic(oo->oo_owner.so_client->net,
+						nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
+
 	list_del_init(&oo->oo_owner.so_strhash);
 	list_del_init(&oo->oo_perclient);
 }
@@ -1025,18 +1077,29 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 static void release_openowner_stateids(struct nfs4_openowner *oo)
 {
 	struct nfs4_ol_stateid *stp;
+	struct nfsd_net *nn = net_generic(oo->oo_owner.so_client->net,
+						nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
 
 	while (!list_empty(&oo->oo_owner.so_stateids)) {
 		stp = list_first_entry(&oo->oo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
+		spin_unlock(&nn->client_lock);
 		release_open_stateid(stp);
+		spin_lock(&nn->client_lock);
 	}
 }
 
 static void release_openowner(struct nfs4_openowner *oo)
 {
-	unhash_openowner(oo);
+	struct nfsd_net *nn = net_generic(oo->oo_owner.so_client->net,
+						nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	unhash_openowner_locked(oo);
 	release_openowner_stateids(oo);
+	spin_unlock(&nn->client_lock);
 	release_last_closed_stateid(oo);
 	nfs4_put_stateowner(&oo->oo_owner);
 }
@@ -3004,8 +3067,11 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 static void nfs4_unhash_openowner(struct nfs4_stateowner *so)
 {
 	struct nfs4_openowner *oo = openowner(so);
+	struct nfsd_net *nn = net_generic(so->so_client->net, nfsd_net_id);
 
-	unhash_openowner(oo);
+	spin_lock(&nn->client_lock);
+	unhash_openowner_locked(oo);
+	spin_unlock(&nn->client_lock);
 }
 
 static void nfs4_free_openowner(struct nfs4_stateowner *so)
@@ -3025,7 +3091,8 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
 {
 	struct nfs4_client *clp = cstate->clp;
-	struct nfs4_openowner *oo;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfs4_openowner *oo, *ret;
 
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
 	if (!oo)
@@ -3039,7 +3106,15 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	oo->oo_time = 0;
 	oo->oo_last_closed_stid = NULL;
 	INIT_LIST_HEAD(&oo->oo_close_lru);
-	hash_openowner(oo, clp, strhashval);
+	spin_lock(&nn->client_lock);
+	ret = find_openstateowner_str_locked(strhashval,
+			open, clp->cl_minorversion, nn);
+	if (ret == NULL) {
+		hash_openowner(oo, clp, strhashval);
+		ret = oo;
+	} else
+		nfs4_free_openowner(&oo->oo_owner);
+	spin_unlock(&nn->client_lock);
 	return oo;
 }
 
@@ -3100,39 +3175,6 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 	oo->oo_time = get_seconds();
 }
 
-static int
-same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
-							clientid_t *clid)
-{
-	return (sop->so_owner.len == owner->len) &&
-		0 == memcmp(sop->so_owner.data, owner->data, owner->len) &&
-		(sop->so_client->cl_clientid.cl_id == clid->cl_id);
-}
-
-static struct nfs4_openowner *
-find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
-			bool sessions, struct nfsd_net *nn)
-{
-	struct nfs4_stateowner *so;
-	struct nfs4_openowner *oo;
-	struct nfs4_client *clp;
-
-	list_for_each_entry(so, &nn->ownerstr_hashtbl[hashval], so_strhash) {
-		if (!so->so_is_open_owner)
-			continue;
-		if (same_owner_str(so, &open->op_owner, &open->op_clientid)) {
-			oo = openowner(so);
-			clp = oo->oo_owner.so_client;
-			if ((bool)clp->cl_minorversion != sessions)
-				return NULL;
-			renew_client(oo->oo_owner.so_client);
-			atomic_inc(&oo->oo_owner.so_count);
-			return oo;
-		}
-	}
-	return NULL;
-}
-
 /* search file_hashtbl[] for file */
 static struct nfs4_file *
 find_file_locked(struct knfsd_fh *fh)
-- 
1.9.3

