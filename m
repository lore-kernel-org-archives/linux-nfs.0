Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:63711 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbaG3Bf0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:26 -0400
Received: by mail-qa0-f50.google.com with SMTP id s7so579920qap.37
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:26 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 24/38] nfsd: add an operation for unhashing a stateowner
Date: Tue, 29 Jul 2014 21:34:29 -0400
Message-Id: <1406684083-19736-25-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow stateowners to be unhashed and destroyed when the last reference
is put. The unhashing must be idempotent. In a future patch, we'll add
some locking around it, but for now it's only protected by the
client_mutex.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 49 +++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/state.h     |  1 +
 2 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eaa5f9ebf444..906c8604de30 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -894,6 +894,7 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 {
 	if (!atomic_dec_and_test(&sop->so_count))
 		return;
+	sop->so_ops->so_unhash(sop);
 	kfree(sop->so_owner.data);
 	sop->so_ops->so_free(sop);
 }
@@ -944,9 +945,13 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 
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
@@ -957,6 +962,7 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
 	unhash_lockowner(lo);
+	release_lockowner_stateids(lo);
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
@@ -1006,15 +1012,8 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 
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
@@ -1027,9 +1026,21 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
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
@@ -2994,6 +3005,13 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
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
@@ -3002,7 +3020,8 @@ static void nfs4_free_openowner(struct nfs4_stateowner *so)
 }
 
 static const struct nfs4_stateowner_operations openowner_ops = {
-	.so_free = nfs4_free_openowner,
+	.so_unhash =	nfs4_unhash_openowner,
+	.so_free =	nfs4_free_openowner,
 };
 
 static struct nfs4_openowner *
@@ -4760,6 +4779,11 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
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
@@ -4768,7 +4792,8 @@ static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
 }
 
 static const struct nfs4_stateowner_operations lockowner_ops = {
-	.so_free = nfs4_free_lockowner,
+	.so_unhash =	nfs4_unhash_lockowner,
+	.so_free =	nfs4_free_lockowner,
 };
 
 /*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9cba295812f6..232246039db0 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -335,6 +335,7 @@ struct nfs4_replay {
 struct nfs4_stateowner;
 
 struct nfs4_stateowner_operations {
+	void (*so_unhash)(struct nfs4_stateowner *);
 	void (*so_free)(struct nfs4_stateowner *);
 };
 
-- 
1.9.3

