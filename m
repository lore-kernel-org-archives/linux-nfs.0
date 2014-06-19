Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:64560 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757948AbaFSOvS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:18 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so2017720qac.21
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 014/104] NFSd: NFSv4 lock-owners are not associated to a specific file
Date: Thu, 19 Jun 2014 10:49:20 -0400
Message-Id: <1403189450-18729-15-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Just like open-owners, lock-owners are associated with a name, a clientid
and, in the case of minor version 0, a sequence id. There is no association
to a file.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/netns.h     |  4 ----
 fs/nfsd/nfs4state.c | 66 ++++++++++++-----------------------------------------
 fs/nfsd/state.h     |  1 -
 3 files changed, 14 insertions(+), 57 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index d32b3aa6600d..beaceac90ad3 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -29,9 +29,6 @@
 #define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
 #define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
 
-#define LOCKOWNER_INO_HASH_BITS		8
-#define LOCKOWNER_INO_HASH_SIZE		(1 << LOCKOWNER_INO_HASH_BITS)
-
 #define SESSION_HASH_SIZE	512
 
 struct cld_net;
@@ -67,7 +64,6 @@ struct nfsd_net {
 	struct list_head *unconf_id_hashtbl;
 	struct rb_root unconf_name_tree;
 	struct list_head *ownerstr_hashtbl;
-	struct list_head *lockowner_ino_hashtbl;
 	struct list_head *sessionid_hashtbl;
 	/*
 	 * client_lru holds client queue ordered by nfs4_client.cl_time
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 77c1b62db4fd..b1e833d22207 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -759,7 +759,6 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 	struct nfs4_ol_stateid *stp;
 
 	list_del(&lo->lo_owner.so_strhash);
-	list_del(&lo->lo_owner_ino_hash);
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
@@ -4336,8 +4335,6 @@ out:
 
 #define LOFF_OVERFLOW(start, len)      ((u64)(len) > ~(u64)(start))
 
-#define LOCKOWNER_INO_HASH_MASK (LOCKOWNER_INO_HASH_SIZE - 1)
-
 static inline u64
 end_offset(u64 start, u64 len)
 {
@@ -4358,13 +4355,6 @@ last_byte_offset(u64 start, u64 len)
 	return end > start ? end - 1: NFS4_MAX_UINT64;
 }
 
-static unsigned int lockowner_ino_hashval(struct inode *inode, u32 cl_id, struct xdr_netobj *ownername)
-{
-	return (file_hashval(inode) + cl_id
-			+ opaque_hashval(ownername->data, ownername->len))
-		& LOCKOWNER_INO_HASH_MASK;
-}
-
 /*
  * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that
  * we can't properly handle lock requests that go beyond the (2^63 - 1)-th
@@ -4417,44 +4407,28 @@ nevermind:
 		deny->ld_type = NFS4_WRITE_LT;
 }
 
-static bool same_lockowner_ino(struct nfs4_lockowner *lo, struct inode *inode, clientid_t *clid, struct xdr_netobj *owner)
-{
-	struct nfs4_ol_stateid *lst;
-
-	if (!same_owner_str(&lo->lo_owner, owner, clid))
-		return false;
-	if (list_empty(&lo->lo_owner.so_stateids)) {
-		WARN_ON_ONCE(1);
-		return false;
-	}
-	lst = list_first_entry(&lo->lo_owner.so_stateids,
-			       struct nfs4_ol_stateid, st_perstateowner);
-	return lst->st_file->fi_inode == inode;
-}
-
 static struct nfs4_lockowner *
-find_lockowner_str(struct inode *inode, clientid_t *clid,
-		   struct xdr_netobj *owner, struct nfsd_net *nn)
+find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
+		struct nfsd_net *nn)
 {
-	unsigned int hashval = lockowner_ino_hashval(inode, clid->cl_id, owner);
-	struct nfs4_lockowner *lo;
+	unsigned int strhashval = ownerstr_hashval(clid->cl_id, owner);
+	struct nfs4_stateowner *so;
 
-	list_for_each_entry(lo, &nn->lockowner_ino_hashtbl[hashval], lo_owner_ino_hash) {
-		if (same_lockowner_ino(lo, inode, clid, owner))
-			return lo;
+	list_for_each_entry(so, &nn->ownerstr_hashtbl[strhashval], so_strhash) {
+		if (so->so_is_open_owner)
+			continue;
+		if (!same_owner_str(so, owner, clid))
+			continue;
+		return lockowner(so);
 	}
 	return NULL;
 }
 
-static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp)
+static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp)
 {
-	struct inode *inode = open_stp->st_file->fi_inode;
-	unsigned int inohash = lockowner_ino_hashval(inode,
-			clp->cl_clientid.cl_id, &lo->lo_owner.so_owner);
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
-	list_add(&lo->lo_owner_ino_hash, &nn->lockowner_ino_hashtbl[inohash]);
 }
 
 /*
@@ -4477,7 +4451,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	/* It is the openowner seqid that will be incremented in encode in the
 	 * case of new lockowners; so increment the lock seqid manually: */
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
-	hash_lockowner(lo, strhashval, clp, open_stp);
+	hash_lockowner(lo, strhashval, clp);
 	return lo;
 }
 
@@ -4544,8 +4518,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 	unsigned int strhashval;
 	struct nfsd_net *nn = net_generic(cl->net, nfsd_net_id);
 
-	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid,
-				&lock->v.new.owner, nn);
+	lo = find_lockowner_str(&cl->cl_clientid, &lock->v.new.owner, nn);
 	if (!lo) {
 		strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
 				&lock->v.new.owner);
@@ -4760,7 +4733,6 @@ __be32
 nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_lockt *lockt)
 {
-	struct inode *inode;
 	struct file_lock *file_lock = NULL;
 	struct nfs4_lockowner *lo;
 	__be32 status;
@@ -4783,7 +4755,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		goto out;
 
-	inode = cstate->current_fh.fh_dentry->d_inode;
 	file_lock = locks_alloc_lock();
 	if (!file_lock) {
 		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
@@ -4806,7 +4777,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	lo = find_lockowner_str(inode, &lockt->lt_clientid, &lockt->lt_owner, nn);
+	lo = find_lockowner_str(&lockt->lt_clientid, &lockt->lt_owner, nn);
 	if (lo)
 		file_lock->fl_owner = (fl_owner_t)lo;
 	file_lock->fl_pid = current->tgid;
@@ -5297,10 +5268,6 @@ static int nfs4_state_create_net(struct net *net)
 			OWNER_HASH_SIZE, GFP_KERNEL);
 	if (!nn->ownerstr_hashtbl)
 		goto err_ownerstr;
-	nn->lockowner_ino_hashtbl = kmalloc(sizeof(struct list_head) *
-			LOCKOWNER_INO_HASH_SIZE, GFP_KERNEL);
-	if (!nn->lockowner_ino_hashtbl)
-		goto err_lockowner_ino;
 	nn->sessionid_hashtbl = kmalloc(sizeof(struct list_head) *
 			SESSION_HASH_SIZE, GFP_KERNEL);
 	if (!nn->sessionid_hashtbl)
@@ -5312,8 +5279,6 @@ static int nfs4_state_create_net(struct net *net)
 	}
 	for (i = 0; i < OWNER_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->ownerstr_hashtbl[i]);
-	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&nn->lockowner_ino_hashtbl[i]);
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 	nn->conf_name_tree = RB_ROOT;
@@ -5329,8 +5294,6 @@ static int nfs4_state_create_net(struct net *net)
 	return 0;
 
 err_sessionid:
-	kfree(nn->lockowner_ino_hashtbl);
-err_lockowner_ino:
 	kfree(nn->ownerstr_hashtbl);
 err_ownerstr:
 	kfree(nn->unconf_id_hashtbl);
@@ -5362,7 +5325,6 @@ nfs4_state_destroy_net(struct net *net)
 	}
 
 	kfree(nn->sessionid_hashtbl);
-	kfree(nn->lockowner_ino_hashtbl);
 	kfree(nn->ownerstr_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c28e1ac87549..c6b2bd11896d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -365,7 +365,6 @@ struct nfs4_openowner {
 
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
-	struct list_head	lo_owner_ino_hash; /* hash by owner,file */
 	struct list_head	lo_list; /* for temporary uses */
 };
 
-- 
1.9.3

