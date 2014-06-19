Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:62283 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758054AbaFSOwI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:08 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2283894qcz.14
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:07 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 048/104] nfsd: add an operation for unhashing a stateowner
Date: Thu, 19 Jun 2014 10:49:54 -0400
Message-Id: <1403189450-18729-49-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
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
index e40b8e92b65d..086decc72fcc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -817,9 +817,13 @@ static void __release_lock_stateid(struct nfs4_lockowner *lo,
 
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
@@ -830,6 +834,7 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
 	unhash_lockowner(lo);
+	release_lockowner_stateids(lo);
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
@@ -879,15 +884,8 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 
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
@@ -900,9 +898,21 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
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
@@ -2878,6 +2888,7 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 {
 	if (!atomic_dec_and_test(&sop->so_count))
 		return;
+	sop->so_unhash(sop);
 	sop->so_free(sop);
 }
 
@@ -2889,6 +2900,13 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
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
@@ -2905,6 +2923,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	if (!oo)
 		return NULL;
 	oo->oo_owner.so_free = nfs4_free_openowner;
+	oo->oo_owner.so_unhash = nfs4_unhash_openowner;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = NFS4_OO_NEW;
@@ -4621,6 +4640,11 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 }
 
+static void nfs4_unhash_lockowner(struct nfs4_stateowner *sop)
+{
+	unhash_lockowner(lockowner(sop));
+}
+
 static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
 {
 	struct nfs4_lockowner *lo = lockowner(sop);
@@ -4648,6 +4672,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
 	hash_lockowner(lo, strhashval, clp);
 	lo->lo_owner.so_free = nfs4_free_lockowner;
+	lo->lo_owner.so_unhash = nfs4_unhash_lockowner;
 	return lo;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ebd3d302a572..147d0c91b819 100644
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

