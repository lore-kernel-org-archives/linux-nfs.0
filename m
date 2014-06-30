Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:33063 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbaF3PwI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:08 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so6580345qac.27
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:07 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 067/114] nfsd: Protect adding/removing open state owners using client_lock
Date: Mon, 30 Jun 2014 11:49:36 -0400
Message-Id: <1404143423-24381-68-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Once we remove client mutex protection, we'll need to ensure that
stateowner lookup and creation are atomic between concurrent compounds.
Ensure that alloc_init_open_stateowner checks the hashtable under the
client_lock before adding a new element.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 63 +++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 54 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4d504c83d8d8..661af4bf0296 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -72,6 +72,9 @@ static u64 current_sessionid = 1;
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
+static struct nfs4_openowner *find_openstateowner_str_locked(
+		unsigned int hashval, struct nfsd4_open *open,
+		bool sessions, struct nfsd_net *nn);
 static void nfs4_put_stateowner(struct nfs4_stateowner *sop);
 
 /* Locking: */
@@ -976,8 +979,13 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 	put_generic_stateid(stp);
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
@@ -996,18 +1004,29 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
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
@@ -2986,8 +3005,11 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
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
@@ -3003,7 +3025,8 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
 {
 	struct nfs4_client *clp = cstate->clp;
-	struct nfs4_openowner *oo;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfs4_openowner *oo, *ret;
 
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
 	if (!oo)
@@ -3018,7 +3041,15 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
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
 
@@ -3092,13 +3123,15 @@ same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
 }
 
 static struct nfs4_openowner *
-find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
+find_openstateowner_str_locked(unsigned int hashval, struct nfsd4_open *open,
 			bool sessions, struct nfsd_net *nn)
 {
 	struct nfs4_stateowner *so;
 	struct nfs4_openowner *oo;
 	struct nfs4_client *clp;
 
+	lockdep_assert_held(&nn->client_lock);
+
 	list_for_each_entry(so, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (!so->so_is_open_owner)
 			continue;
@@ -3106,15 +3139,27 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
 			oo = openowner(so);
 			clp = oo->oo_owner.so_client;
 			if ((bool)clp->cl_minorversion != sessions)
-				return NULL;
-			renew_client(oo->oo_owner.so_client);
-			atomic_inc(&oo->oo_owner.so_count);
+				break;
+			renew_client_locked(clp);
+			atomic_inc(&so->so_count);
 			return oo;
 		}
 	}
 	return NULL;
 }
 
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
 /* search file_hashtbl[] for file */
 static struct nfs4_file *
 find_file_locked(struct inode *ino)
-- 
1.9.3

