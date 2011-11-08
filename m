Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52020 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756460Ab1KHW7J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 17:59:09 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd4: add a separate (lockowner, inode) lookup
Date: Tue,  8 Nov 2011 17:59:05 -0500
Message-Id: <1320793145-29070-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20111108225751.GD27413@fieldses.org>
References: <20111108225751.GD27413@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Address the possible performance regression mentioned in "nfsd4: hash
lockowners to simplify RELEASE_LOCKOWNER" by providing a separate
(lockowner, inode) hash.

Really, I doubt this matters much, but I think it's likely we'll change
these data structures here and I'd rather that the need for (owner,
inode) lookups be well-documented.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   29 +++++++++++++++++++++++------
 fs/nfsd/state.h     |    1 +
 2 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dcbe7f3..d4bd698 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -514,6 +514,7 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 
 	list_del(&lo->lo_owner.so_strhash);
 	list_del(&lo->lo_perstateid);
+	list_del(&lo->lo_owner_ino_hash);
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
@@ -3722,6 +3723,10 @@ out:
 
 #define LOFF_OVERFLOW(start, len)      ((u64)(len) > ~(u64)(start))
 
+#define LOCKOWNER_INO_HASH_BITS 8
+#define LOCKOWNER_INO_HASH_SIZE (1 << LOCKOWNER_INO_HASH_BITS)
+#define LOCKOWNER_INO_HASH_MASK (LOCKOWNER_INO_HASH_SIZE - 1)
+
 static inline u64
 end_offset(u64 start, u64 len)
 {
@@ -3742,6 +3747,15 @@ last_byte_offset(u64 start, u64 len)
 	return end > start ? end - 1: NFS4_MAX_UINT64;
 }
 
+static unsigned int lockowner_ino_hashval(struct inode *inode, u32 cl_id, struct xdr_netobj *ownername)
+{
+	return (file_hashval(inode) + cl_id
+			+ opaque_hashval(ownername->data, ownername->len))
+		& LOCKOWNER_INO_HASH_MASK;
+}
+
+static struct list_head lockowner_ino_hashtbl[LOCKOWNER_INO_HASH_SIZE];
+
 /*
  * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that
  * we can't properly handle lock requests that go beyond the (2^63 - 1)-th
@@ -3809,14 +3823,10 @@ static struct nfs4_lockowner *
 find_lockowner_str(struct inode *inode, clientid_t *clid,
 		struct xdr_netobj *owner)
 {
-	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
+	unsigned int hashval = lockowner_ino_hashval(inode, clid->cl_id, owner);
 	struct nfs4_lockowner *lo;
-	struct nfs4_stateowner *op;
 
-	list_for_each_entry(op, &ownerstr_hashtbl[hashval], so_strhash) {
-		if (op->so_is_open_owner)
-			continue;
-		lo = lockowner(op);
+	list_for_each_entry(lo, &lockowner_ino_hashtbl[hashval], lo_owner_ino_hash) {
 		if (same_lockowner_ino(lo, inode, clid, owner))
 			return lo;
 	}
@@ -3825,7 +3835,12 @@ find_lockowner_str(struct inode *inode, clientid_t *clid,
 
 static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp)
 {
+	struct inode *inode = open_stp->st_file->fi_inode;
+	unsigned int inohash = lockowner_ino_hashval(inode,
+			clp->cl_clientid.cl_id, &lo->lo_owner.so_owner);
+
 	list_add(&lo->lo_owner.so_strhash, &ownerstr_hashtbl[strhashval]);
+	list_add(&lo->lo_owner_ino_hash, &lockowner_ino_hashtbl[inohash]);
 	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
 }
 
@@ -4548,6 +4563,8 @@ nfs4_state_init(void)
 	for (i = 0; i < OWNER_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&ownerstr_hashtbl[i]);
 	}
+	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&lockowner_ino_hashtbl[i]);
 	memset(&onestateid, ~0, sizeof(stateid_t));
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index a3cf384..89c2cd8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -366,6 +366,7 @@ struct nfs4_openowner {
 
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
+	struct list_head	lo_owner_ino_hash; /* hash by owner,file */
 	struct list_head        lo_perstateid; /* for lockowners only */
 	struct list_head	lo_list; /* for temporary uses */
 };
-- 
1.7.5.4

