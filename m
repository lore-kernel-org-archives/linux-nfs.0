Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:50311 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbaGUPDi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:38 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so5418429qgd.37
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:38 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 27/40] nfsd: add an operation for unhashing a stateowner
Date: Mon, 21 Jul 2014 11:02:39 -0400
Message-Id: <1405954972-28904-28-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow stateowners to be unhashed and destroyed when the last reference
is put. The unhashing must be idempotent. In a future patch, we'll add
some locking around it, but for now it's only protected by the
client_mutex.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 45 +++++++++++++++++++++++++++++++++++----------
 fs/nfsd/state.h     |  1 +
 2 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f2e843b471f2..14ae8d5d7312 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -946,9 +946,13 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 
 static void unhash_lockowner(struct nfs4_lockowner *lo)
 {
+	list_del_init(&lo->lo_owner.so_strhash);
+}
+
+static void release_lockowner_stateids(struct nfs4_lockowner *lo)
+{
 	struct nfs4_ol_stateid *stp;
 
-	list_del(&lo->lo_owner.so_strhash);
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
@@ -959,6 +963,7 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
 	unhash_lockowner(lo);
+	release_lockowner_stateids(lo);
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
@@ -1008,15 +1013,8 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 
 static void unhash_openowner(struct nfs4_openowner *oo)
 {
-	struct nfs4_ol_stateid *stp;
-
-	list_del(&oo->oo_owner.so_strhash);
-	list_del(&oo->oo_perclient);
-	while (!list_empty(&oo->oo_owner.so_stateids)) {
-		stp = list_first_entry(&oo->oo_owner.so_stateids,
-				struct nfs4_ol_stateid, st_perstateowner);
-		release_open_stateid(stp);
-	}
+	list_del_init(&oo->oo_owner.so_strhash);
+	list_del_init(&oo->oo_perclient);
 }
 
 static void release_last_closed_stateid(struct nfs4_openowner *oo)
@@ -1029,9 +1027,21 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	}
 }
 
+static void release_openowner_stateids(struct nfs4_openowner *oo)
+{
+	struct nfs4_ol_stateid *stp;
+
+	while (!list_empty(&oo->oo_owner.so_stateids)) {
+		stp = list_first_entry(&oo->oo_owner.so_stateids,
+				struct nfs4_ol_stateid, st_perstateowner);
+		release_open_stateid(stp);
+	}
+}
+
 static void release_openowner(struct nfs4_openowner *oo)
 {
 	unhash_openowner(oo);
+	release_openowner_stateids(oo);
 	list_del(&oo->oo_close_lru);
 	release_last_closed_stateid(oo);
 	nfs4_put_stateowner(&oo->oo_owner);
@@ -2998,6 +3008,7 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 {
 	if (!atomic_dec_and_test(&sop->so_count))
 		return;
+	sop->so_unhash(sop);
 	sop->so_free(sop);
 }
 
@@ -3009,6 +3020,13 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
 
+static void nfs4_unhash_openowner(struct nfs4_stateowner *so)
+{
+	struct nfs4_openowner *oo = openowner(so);
+
+	unhash_openowner(oo);
+}
+
 static void nfs4_free_openowner(struct nfs4_stateowner *so)
 {
 	struct nfs4_openowner *oo = openowner(so);
@@ -3028,6 +3046,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	if (!oo)
 		return NULL;
 	oo->oo_owner.so_free = nfs4_free_openowner;
+	oo->oo_owner.so_unhash = nfs4_unhash_openowner;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = NFS4_OO_NEW;
@@ -4774,6 +4793,11 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 	return NULL;
 }
 
+static void nfs4_unhash_lockowner(struct nfs4_stateowner *sop)
+{
+	unhash_lockowner(lockowner(sop));
+}
+
 static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
 {
 	struct nfs4_lockowner *lo = lockowner(sop);
@@ -4801,6 +4825,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	lo->lo_owner.so_is_open_owner = 0;
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
 	lo->lo_owner.so_free = nfs4_free_lockowner;
+	lo->lo_owner.so_unhash = nfs4_unhash_lockowner;
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	return lo;
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 945f38c0f3a9..f011a76b7196 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -347,6 +347,7 @@ struct nfs4_stateowner {
 	bool			so_is_open_owner;
 
 	void (*so_free)(struct nfs4_stateowner *);
+	void (*so_unhash)(struct nfs4_stateowner *);
 };
 
 struct nfs4_openowner {
-- 
1.9.3

