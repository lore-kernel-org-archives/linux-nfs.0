Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33184 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbaDRSph (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:37 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so939242igq.13
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 21/70] NFSd: Get rid of the lockowner_ino_hashtbl
Date: Fri, 18 Apr 2014 14:44:15 -0400
Message-Id: <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is no longer used.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/netns.h     |  4 ----
 fs/nfsd/nfs4state.c | 26 ++------------------------
 fs/nfsd/state.h     |  1 -
 3 files changed, 2 insertions(+), 29 deletions(-)

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
index be48dbc32f97..38ca008c3d41 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -724,7 +724,6 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 	struct nfs4_ol_stateid *stp;
 
 	list_del(&lo->lo_owner.so_strhash);
-	list_del(&lo->lo_owner_ino_hash);
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
@@ -4225,8 +4224,6 @@ out:
 
 #define LOFF_OVERFLOW(start, len)      ((u64)(len) > ~(u64)(start))
 
-#define LOCKOWNER_INO_HASH_MASK (LOCKOWNER_INO_HASH_SIZE - 1)
-
 static inline u64
 end_offset(u64 start, u64 len)
 {
@@ -4247,12 +4244,6 @@ last_byte_offset(u64 start, u64 len)
 	return end > start ? end - 1: NFS4_MAX_UINT64;
 }
 
-static unsigned int lockowner_ino_hashval(struct inode *inode, u32 cl_id, struct xdr_netobj *ownername)
-{
-	return (cl_id + opaque_hashval(ownername->data, ownername->len))
-		& LOCKOWNER_INO_HASH_MASK;
-}
-
 /*
  * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that
  * we can't properly handle lock requests that go beyond the (2^63 - 1)-th
@@ -4322,15 +4313,11 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
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
@@ -4353,7 +4340,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	/* It is the openowner seqid that will be incremented in encode in the
 	 * case of new lockowners; so increment the lock seqid manually: */
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
-	hash_lockowner(lo, strhashval, clp, open_stp);
+	hash_lockowner(lo, strhashval, clp);
 	return lo;
 }
 
@@ -5174,10 +5161,6 @@ static int nfs4_state_create_net(struct net *net)
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
@@ -5189,8 +5172,6 @@ static int nfs4_state_create_net(struct net *net)
 	}
 	for (i = 0; i < OWNER_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->ownerstr_hashtbl[i]);
-	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&nn->lockowner_ino_hashtbl[i]);
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 	nn->conf_name_tree = RB_ROOT;
@@ -5206,8 +5187,6 @@ static int nfs4_state_create_net(struct net *net)
 	return 0;
 
 err_sessionid:
-	kfree(nn->lockowner_ino_hashtbl);
-err_lockowner_ino:
 	kfree(nn->ownerstr_hashtbl);
 err_ownerstr:
 	kfree(nn->unconf_id_hashtbl);
@@ -5239,7 +5218,6 @@ nfs4_state_destroy_net(struct net *net)
 	}
 
 	kfree(nn->sessionid_hashtbl);
-	kfree(nn->lockowner_ino_hashtbl);
 	kfree(nn->ownerstr_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 51df8df04d6a..02fc6685ab3f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -366,7 +366,6 @@ struct nfs4_openowner {
 
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
-	struct list_head	lo_owner_ino_hash; /* hash by owner,file */
 	struct list_head	lo_list; /* for temporary uses */
 };
 
-- 
1.9.0

