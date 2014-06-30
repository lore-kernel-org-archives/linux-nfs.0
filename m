Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:53557 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315AbaF3PwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:12 -0400
Received: by mail-qg0-f44.google.com with SMTP id j107so2176222qga.17
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:12 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 069/114] nfsd: Move the open owner hash table into struct nfs4_client
Date: Mon, 30 Jun 2014 11:49:38 -0400
Message-Id: <1404143423-24381-70-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Preparation for removing the client_mutex.

Convert the open owner hash table into a per-client table and protect it
using the nfs4_client->cl_lock spin lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/netns.h     |   1 -
 fs/nfsd/nfs4state.c | 188 ++++++++++++++++++++++++----------------------------
 fs/nfsd/state.h     |   1 +
 3 files changed, 87 insertions(+), 103 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index beaceac90ad3..f89042ae0056 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -63,7 +63,6 @@ struct nfsd_net {
 	struct rb_root conf_name_tree;
 	struct list_head *unconf_id_hashtbl;
 	struct rb_root unconf_name_tree;
-	struct list_head *ownerstr_hashtbl;
 	struct list_head *sessionid_hashtbl;
 	/*
 	 * client_lru holds client queue ordered by nfs4_client.cl_time
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 41800f2ddd01..1bd7b2b0a4b1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -74,7 +74,7 @@ static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner
 static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
 static struct nfs4_openowner *find_openstateowner_str_locked(
 		unsigned int hashval, struct nfsd4_open *open,
-		bool sessions, struct nfsd_net *nn);
+		struct nfs4_client *clp);
 static void nfs4_put_stateowner(struct nfs4_stateowner *sop);
 
 /* Locking: */
@@ -335,12 +335,11 @@ unsigned long max_delegations;
 #define OWNER_HASH_SIZE             (1 << OWNER_HASH_BITS)
 #define OWNER_HASH_MASK             (OWNER_HASH_SIZE - 1)
 
-static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
+static unsigned int ownerstr_hashval(struct xdr_netobj *ownername)
 {
 	unsigned int ret;
 
 	ret = opaque_hashval(ownername->data, ownername->len);
-	ret += clientid;
 	return ret & OWNER_HASH_MASK;
 }
 
@@ -929,40 +928,37 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 
 static void unhash_lockowner_locked(struct nfs4_lockowner *lo)
 {
-	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
-						nfsd_net_id);
+	struct nfs4_client *clp = lo->lo_owner.so_client;
 
-	lockdep_assert_held(&nn->client_lock);
+	lockdep_assert_held(&clp->cl_lock);
 
 	list_del_init(&lo->lo_owner.so_strhash);
 }
 
 static void release_lockowner_stateids(struct nfs4_lockowner *lo)
 {
-	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
-						nfsd_net_id);
+	struct nfs4_client *clp = lo->lo_owner.so_client;
 	struct nfs4_ol_stateid *stp;
 
-	lockdep_assert_held(&nn->client_lock);
+	lockdep_assert_held(&clp->cl_lock);
 
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		spin_unlock(&nn->client_lock);
+		spin_unlock(&clp->cl_lock);
 		release_lock_stateid(stp);
-		spin_lock(&nn->client_lock);
+		spin_lock(&clp->cl_lock);
 	}
 }
 
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
-	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
-						nfsd_net_id);
+	struct nfs4_client *clp = lo->lo_owner.so_client;
 
-	spin_lock(&nn->client_lock);
+	spin_lock(&clp->cl_lock);
 	unhash_lockowner_locked(lo);
 	release_lockowner_stateids(lo);
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&clp->cl_lock);
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
@@ -997,10 +993,9 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 
 static void unhash_openowner_locked(struct nfs4_openowner *oo)
 {
-	struct nfsd_net *nn = net_generic(oo->oo_owner.so_client->net,
-						nfsd_net_id);
+	struct nfs4_client *clp = oo->oo_owner.so_client;
 
-	lockdep_assert_held(&nn->client_lock);
+	lockdep_assert_held(&clp->cl_lock);
 
 	list_del_init(&oo->oo_owner.so_strhash);
 	list_del_init(&oo->oo_perclient);
@@ -1020,29 +1015,27 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 static void release_openowner_stateids(struct nfs4_openowner *oo)
 {
 	struct nfs4_ol_stateid *stp;
-	struct nfsd_net *nn = net_generic(oo->oo_owner.so_client->net,
-						nfsd_net_id);
+	struct nfs4_client *clp = oo->oo_owner.so_client;
 
-	lockdep_assert_held(&nn->client_lock);
+	lockdep_assert_held(&clp->cl_lock);
 
 	while (!list_empty(&oo->oo_owner.so_stateids)) {
 		stp = list_first_entry(&oo->oo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		spin_unlock(&nn->client_lock);
+		spin_unlock(&clp->cl_lock);
 		release_open_stateid(stp);
-		spin_lock(&nn->client_lock);
+		spin_lock(&clp->cl_lock);
 	}
 }
 
 static void release_openowner(struct nfs4_openowner *oo)
 {
-	struct nfsd_net *nn = net_generic(oo->oo_owner.so_client->net,
-						nfsd_net_id);
+	struct nfs4_client *clp = oo->oo_owner.so_client;
 
-	spin_lock(&nn->client_lock);
+	spin_lock(&clp->cl_lock);
 	unhash_openowner_locked(oo);
 	release_openowner_stateids(oo);
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&clp->cl_lock);
 	release_last_closed_stateid(oo);
 	nfs4_put_stateowner(&oo->oo_owner);
 }
@@ -1426,15 +1419,20 @@ STALE_CLIENTID(clientid_t *clid, struct nfsd_net *nn)
 static struct nfs4_client *alloc_client(struct xdr_netobj name)
 {
 	struct nfs4_client *clp;
+	int i;
 
 	clp = kzalloc(sizeof(struct nfs4_client), GFP_KERNEL);
 	if (clp == NULL)
 		return NULL;
 	clp->cl_name.data = kmemdup(name.data, name.len, GFP_KERNEL);
-	if (clp->cl_name.data == NULL) {
-		kfree(clp);
-		return NULL;
-	}
+	if (clp->cl_name.data == NULL)
+		goto err_no_name;
+	clp->cl_ownerstr_hashtbl = kmalloc(sizeof(struct list_head) *
+			OWNER_HASH_SIZE, GFP_KERNEL);
+	if (!clp->cl_ownerstr_hashtbl)
+		goto err_no_hashtbl;
+	for (i = 0; i < OWNER_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&clp->cl_ownerstr_hashtbl[i]);
 	clp->cl_name.len = name.len;
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	idr_init(&clp->cl_stateids);
@@ -1449,6 +1447,11 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 	spin_lock_init(&clp->cl_lock);
 	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
 	return clp;
+err_no_hashtbl:
+	kfree(clp->cl_name.data);
+err_no_name:
+	kfree(clp);
+	return NULL;
 }
 
 static void
@@ -1467,6 +1470,7 @@ free_client(struct nfs4_client *clp)
 	}
 	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
 	free_svc_cred(&clp->cl_cred);
+	kfree(clp->cl_ownerstr_hashtbl);
 	kfree(clp->cl_name.data);
 	spin_lock(&clp->cl_lock);
 	idr_destroy(&clp->cl_stateids);
@@ -3012,20 +3016,20 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 
 static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, unsigned int strhashval)
 {
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	lockdep_assert_held(&clp->cl_lock);
 
-	list_add(&oo->oo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
+	list_add(&oo->oo_owner.so_strhash,
+		 &clp->cl_ownerstr_hashtbl[strhashval]);
 	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
 
 static void nfs4_unhash_openowner(struct nfs4_stateowner *so)
 {
-	struct nfs4_openowner *oo = openowner(so);
-	struct nfsd_net *nn = net_generic(so->so_client->net, nfsd_net_id);
+	struct nfs4_client *clp = so->so_client;
 
-	spin_lock(&nn->client_lock);
-	unhash_openowner_locked(oo);
-	spin_unlock(&nn->client_lock);
+	spin_lock(&clp->cl_lock);
+	unhash_openowner_locked(openowner(so));
+	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_openowner(struct nfs4_stateowner *so)
@@ -3041,7 +3045,6 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
 {
 	struct nfs4_client *clp = cstate->clp;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfs4_openowner *oo, *ret;
 
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
@@ -3057,15 +3060,14 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	oo->oo_time = 0;
 	oo->oo_last_closed_stid = NULL;
 	INIT_LIST_HEAD(&oo->oo_close_lru);
-	spin_lock(&nn->client_lock);
-	ret = find_openstateowner_str_locked(strhashval,
-			open, clp->cl_minorversion, nn);
+	spin_lock(&clp->cl_lock);
+	ret = find_openstateowner_str_locked(strhashval, open, clp);
 	if (ret == NULL) {
 		hash_openowner(oo, clp, strhashval);
 		ret = oo;
 	} else
 		nfs4_free_openowner(&oo->oo_owner);
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&clp->cl_lock);
 	return oo;
 }
 
@@ -3130,35 +3132,27 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 }
 
 static int
-same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
-							clientid_t *clid)
+same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner)
 {
 	return (sop->so_owner.len == owner->len) &&
-		0 == memcmp(sop->so_owner.data, owner->data, owner->len) &&
-		(sop->so_client->cl_clientid.cl_id == clid->cl_id);
+		0 == memcmp(sop->so_owner.data, owner->data, owner->len);
 }
 
 static struct nfs4_openowner *
 find_openstateowner_str_locked(unsigned int hashval, struct nfsd4_open *open,
-			bool sessions, struct nfsd_net *nn)
+			struct nfs4_client *clp)
 {
 	struct nfs4_stateowner *so;
-	struct nfs4_openowner *oo;
-	struct nfs4_client *clp;
 
-	lockdep_assert_held(&nn->client_lock);
+	lockdep_assert_held(&clp->cl_lock);
 
-	list_for_each_entry(so, &nn->ownerstr_hashtbl[hashval], so_strhash) {
+	list_for_each_entry(so, &clp->cl_ownerstr_hashtbl[hashval],
+			    so_strhash) {
 		if (!so->so_is_open_owner)
 			continue;
-		if (same_owner_str(so, &open->op_owner, &open->op_clientid)) {
-			oo = openowner(so);
-			clp = oo->oo_owner.so_client;
-			if ((bool)clp->cl_minorversion != sessions)
-				break;
-			renew_client_locked(clp);
+		if (same_owner_str(so, &open->op_owner)) {
 			atomic_inc(&so->so_count);
-			return oo;
+			return openowner(so);
 		}
 	}
 	return NULL;
@@ -3166,13 +3160,13 @@ find_openstateowner_str_locked(unsigned int hashval, struct nfsd4_open *open,
 
 static struct nfs4_openowner *
 find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open,
-			bool sessions, struct nfsd_net *nn)
+			struct nfs4_client *clp)
 {
 	struct nfs4_openowner *oo;
 
-	spin_lock(&nn->client_lock);
-	oo = find_openstateowner_str_locked(hashval, open, sessions, nn);
-	spin_unlock(&nn->client_lock);
+	spin_lock(&clp->cl_lock);
+	oo = find_openstateowner_str_locked(hashval, open, clp);
+	spin_unlock(&clp->cl_lock);
 	return oo;
 }
 
@@ -3384,8 +3378,8 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		return status;
 	clp = cstate->clp;
 
-	strhashval = ownerstr_hashval(clientid->cl_id, &open->op_owner);
-	oo = find_openstateowner_str(strhashval, open, cstate->minorversion, nn);
+	strhashval = ownerstr_hashval(&open->op_owner);
+	oo = find_openstateowner_str(strhashval, open, clp);
 	open->op_openowner = oo;
 	if (!oo) {
 		goto new_owner;
@@ -4770,15 +4764,16 @@ nevermind:
 
 static struct nfs4_lockowner *
 find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
-		struct nfsd_net *nn)
+		struct nfs4_client *clp)
 {
-	unsigned int strhashval = ownerstr_hashval(clid->cl_id, owner);
+	unsigned int strhashval = ownerstr_hashval(owner);
 	struct nfs4_stateowner *so;
 
-	list_for_each_entry(so, &nn->ownerstr_hashtbl[strhashval], so_strhash) {
+	list_for_each_entry(so, &clp->cl_ownerstr_hashtbl[strhashval],
+			    so_strhash) {
 		if (so->so_is_open_owner)
 			continue;
-		if (!same_owner_str(so, owner, clid))
+		if (!same_owner_str(so, owner))
 			continue;
 		atomic_inc(&so->so_count);
 		return lockowner(so);
@@ -4788,23 +4783,23 @@ find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
 
 static struct nfs4_lockowner *
 find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
-		struct nfsd_net *nn)
+		struct nfs4_client *clp)
 {
 	struct nfs4_lockowner *lo;
 
-	spin_lock(&nn->client_lock);
-	lo = find_lockowner_str_locked(clid, owner, nn);
-	spin_unlock(&nn->client_lock);
+	spin_lock(&clp->cl_lock);
+	lo = find_lockowner_str_locked(clid, owner, clp);
+	spin_unlock(&clp->cl_lock);
 	return lo;
 }
 
 static void nfs4_unhash_lockowner(struct nfs4_stateowner *sop)
 {
-	struct nfsd_net *nn = net_generic(sop->so_client->net, nfsd_net_id);
+	struct nfs4_client *clp = sop->so_client;
 
-	spin_lock(&nn->client_lock);
+	spin_lock(&clp->cl_lock);
 	unhash_lockowner_locked(lockowner(sop));
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
@@ -4827,7 +4822,6 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
 			   struct nfs4_ol_stateid *open_stp,
 			   struct nfsd4_lock *lock)
 {
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfs4_lockowner *lo, *ret;
 
 	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
@@ -4838,16 +4832,16 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
 	lo->lo_owner.so_free = nfs4_free_lockowner;
 	lo->lo_owner.so_unhash = nfs4_unhash_lockowner;
-	spin_lock(&nn->client_lock);
+	spin_lock(&clp->cl_lock);
 	ret = find_lockowner_str_locked(&clp->cl_clientid,
-			&lock->lk_new_owner, nn);
+			&lock->lk_new_owner, clp);
 	if (ret == NULL) {
 		list_add(&lo->lo_owner.so_strhash,
-			 &nn->ownerstr_hashtbl[strhashval]);
+			 &clp->cl_ownerstr_hashtbl[strhashval]);
 		ret = lo;
 	} else
 		nfs4_free_lockowner(&lo->lo_owner);
-	spin_unlock(&nn->client_lock);
+	spin_unlock(&clp->cl_lock);
 	return lo;
 }
 
@@ -4959,12 +4953,10 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct nfs4_lockowner *lo;
 	unsigned int strhashval;
-	struct nfsd_net *nn = net_generic(cl->net, nfsd_net_id);
 
-	lo = find_lockowner_str(&cl->cl_clientid, &lock->v.new.owner, nn);
+	lo = find_lockowner_str(&cl->cl_clientid, &lock->v.new.owner, cl);
 	if (!lo) {
-		strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
-				&lock->v.new.owner);
+		strhashval = ownerstr_hashval(&lock->v.new.owner);
 		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 		if (lo == NULL)
 			return nfserr_jukebox;
@@ -5236,7 +5228,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	lo = find_lockowner_str(&lockt->lt_clientid, &lockt->lt_owner, nn);
+	lo = find_lockowner_str(&lockt->lt_clientid, &lockt->lt_owner,
+				cstate->clp);
 	if (lo)
 		file_lock->fl_owner = (fl_owner_t)lo;
 	file_lock->fl_pid = current->tgid;
@@ -5370,7 +5363,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	struct nfs4_lockowner *lo;
 	struct nfs4_ol_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
-	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
+	unsigned int hashval = ownerstr_hashval(owner);
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct nfs4_client *clp;
@@ -5386,29 +5379,29 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 
 	status = nfserr_locks_held;
 
+	clp = cstate->clp;
 	/* Find the matching lock stateowner */
-	spin_lock(&nn->client_lock);
-	list_for_each_entry(tmp, &nn->ownerstr_hashtbl[hashval], so_strhash) {
+	spin_lock(&clp->cl_lock);
+	list_for_each_entry(tmp, &clp->cl_ownerstr_hashtbl[hashval],
+			    so_strhash) {
 		if (tmp->so_is_open_owner)
 			continue;
-		if (same_owner_str(tmp, owner, clid)) {
+		if (same_owner_str(tmp, owner)) {
 			sop = tmp;
 			atomic_inc(&sop->so_count);
 			break;
 		}
 	}
-	spin_unlock(&nn->client_lock);
 
 	/* No matching owner found, maybe a replay? Just declare victory... */
 	if (!sop) {
+		spin_unlock(&clp->cl_lock);
 		status = nfs_ok;
 		goto out;
 	}
 
 	lo = lockowner(sop);
 	/* see if there are still any locks associated with it */
-	clp = cstate->clp;
-	spin_lock(&clp->cl_lock);
 	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
 		if (check_for_locks(stp->st_stid.sc_file, lo)) {
 			spin_unlock(&clp->cl_lock);
@@ -5747,10 +5740,6 @@ static int nfs4_state_create_net(struct net *net)
 			CLIENT_HASH_SIZE, GFP_KERNEL);
 	if (!nn->unconf_id_hashtbl)
 		goto err_unconf_id;
-	nn->ownerstr_hashtbl = kmalloc(sizeof(struct list_head) *
-			OWNER_HASH_SIZE, GFP_KERNEL);
-	if (!nn->ownerstr_hashtbl)
-		goto err_ownerstr;
 	nn->sessionid_hashtbl = kmalloc(sizeof(struct list_head) *
 			SESSION_HASH_SIZE, GFP_KERNEL);
 	if (!nn->sessionid_hashtbl)
@@ -5760,8 +5749,6 @@ static int nfs4_state_create_net(struct net *net)
 		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&nn->unconf_id_hashtbl[i]);
 	}
-	for (i = 0; i < OWNER_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&nn->ownerstr_hashtbl[i]);
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 	nn->conf_name_tree = RB_ROOT;
@@ -5777,8 +5764,6 @@ static int nfs4_state_create_net(struct net *net)
 	return 0;
 
 err_sessionid:
-	kfree(nn->ownerstr_hashtbl);
-err_ownerstr:
 	kfree(nn->unconf_id_hashtbl);
 err_unconf_id:
 	kfree(nn->conf_id_hashtbl);
@@ -5808,7 +5793,6 @@ nfs4_state_destroy_net(struct net *net)
 	}
 
 	kfree(nn->sessionid_hashtbl);
-	kfree(nn->ownerstr_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);
 	put_net(net);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9e9e45278b40..7e395f665b0f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -237,6 +237,7 @@ struct nfsd4_sessionid {
 struct nfs4_client {
 	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
 	struct rb_node		cl_namenode;	/* link into by-name trees */
+	struct list_head	*cl_ownerstr_hashtbl;
 	struct list_head	cl_openowners;
 	struct idr		cl_stateids;	/* stateid lookup */
 	struct list_head	cl_delegations;
-- 
1.9.3

