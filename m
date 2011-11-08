Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab1KHW7J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 17:59:09 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd4: share open and lock owner hash tables
Date: Tue,  8 Nov 2011 17:59:04 -0500
Message-Id: <1320793145-29070-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20111108225751.GD27413@fieldses.org>
References: <20111108225751.GD27413@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Now that they're used in the same way, it's a little simpler to put open
and lock owners in the same hash table, and I can't see a reason not to.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   71 +++++++++++++++++++++++----------------------------
 1 files changed, 32 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eec9900..dcbe7f3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -133,21 +133,21 @@ unsigned int max_delegations;
  * Open owner state (share locks)
  */
 
-/* hash tables for open owners */
-#define OPEN_OWNER_HASH_BITS              8
-#define OPEN_OWNER_HASH_SIZE             (1 << OPEN_OWNER_HASH_BITS)
-#define OPEN_OWNER_HASH_MASK             (OPEN_OWNER_HASH_SIZE - 1)
+/* hash tables for lock and open owners */
+#define OWNER_HASH_BITS              8
+#define OWNER_HASH_SIZE             (1 << OWNER_HASH_BITS)
+#define OWNER_HASH_MASK             (OWNER_HASH_SIZE - 1)
 
-static unsigned int open_ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
+static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
 {
 	unsigned int ret;
 
 	ret = opaque_hashval(ownername->data, ownername->len);
 	ret += clientid;
-	return ret & OPEN_OWNER_HASH_MASK;
+	return ret & OWNER_HASH_MASK;
 }
 
-static struct list_head	open_ownerstr_hashtbl[OPEN_OWNER_HASH_SIZE];
+static struct list_head	ownerstr_hashtbl[OWNER_HASH_SIZE];
 
 /* hash table for nfs4_file */
 #define FILE_HASH_BITS                   8
@@ -2373,7 +2373,7 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
 
 static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, unsigned int strhashval)
 {
-	list_add(&oo->oo_owner.so_strhash, &open_ownerstr_hashtbl[strhashval]);
+	list_add(&oo->oo_owner.so_strhash, &ownerstr_hashtbl[strhashval]);
 	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
 
@@ -2436,7 +2436,9 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
 	struct nfs4_stateowner *so;
 	struct nfs4_openowner *oo;
 
-	list_for_each_entry(so, &open_ownerstr_hashtbl[hashval], so_strhash) {
+	list_for_each_entry(so, &ownerstr_hashtbl[hashval], so_strhash) {
+		if (!so->so_is_open_owner)
+			continue;
 		if (same_owner_str(so, &open->op_owner, &open->op_clientid)) {
 			oo = openowner(so);
 			renew_client(oo->oo_owner.so_client);
@@ -2580,7 +2582,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	if (open->op_file == NULL)
 		return nfserr_jukebox;
 
-	strhashval = open_ownerstr_hashval(clientid->cl_id, &open->op_owner);
+	strhashval = ownerstr_hashval(clientid->cl_id, &open->op_owner);
 	oo = find_openstateowner_str(strhashval, open);
 	open->op_openowner = oo;
 	if (!oo) {
@@ -3718,13 +3720,7 @@ out:
 }
 
 
-/* 
- * Lock owner state (byte-range locks)
- */
 #define LOFF_OVERFLOW(start, len)      ((u64)(len) > ~(u64)(start))
-#define LOCK_HASH_BITS              8
-#define LOCK_HASH_SIZE             (1 << LOCK_HASH_BITS)
-#define LOCK_HASH_MASK             (LOCK_HASH_SIZE - 1)
 
 static inline u64
 end_offset(u64 start, u64 len)
@@ -3746,8 +3742,6 @@ last_byte_offset(u64 start, u64 len)
 	return end > start ? end - 1: NFS4_MAX_UINT64;
 }
 
-static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
-
 /*
  * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that
  * we can't properly handle lock requests that go beyond the (2^63 - 1)-th
@@ -3815,11 +3809,13 @@ static struct nfs4_lockowner *
 find_lockowner_str(struct inode *inode, clientid_t *clid,
 		struct xdr_netobj *owner)
 {
-	unsigned int hashval = open_ownerstr_hashval(clid->cl_id, owner);
+	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
 	struct nfs4_lockowner *lo;
 	struct nfs4_stateowner *op;
 
-	list_for_each_entry(op, &lock_ownerstr_hashtbl[hashval], so_strhash) {
+	list_for_each_entry(op, &ownerstr_hashtbl[hashval], so_strhash) {
+		if (op->so_is_open_owner)
+			continue;
 		lo = lockowner(op);
 		if (same_lockowner_ino(lo, inode, clid, owner))
 			return lo;
@@ -3829,7 +3825,7 @@ find_lockowner_str(struct inode *inode, clientid_t *clid,
 
 static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp)
 {
-	list_add(&lo->lo_owner.so_strhash, &lock_ownerstr_hashtbl[strhashval]);
+	list_add(&lo->lo_owner.so_strhash, &ownerstr_hashtbl[strhashval]);
 	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
 }
 
@@ -3838,7 +3834,7 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
  * Called in nfsd4_lock - therefore, OPEN and OPEN_CONFIRM (if needed) has 
  * occurred. 
  *
- * strhashval = open_ownerstr_hashval
+ * strhashval = ownerstr_hashval
  */
 
 static struct nfs4_lockowner *
@@ -3913,7 +3909,7 @@ __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct n
 				struct nfs4_ol_stateid, st_perstateowner);
 		return nfs_ok;
 	}
-	strhashval = open_ownerstr_hashval(cl->cl_clientid.cl_id,
+	strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
 			&lock->v.new.owner);
 	lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 	if (lo == NULL)
@@ -4277,7 +4273,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	struct nfs4_ol_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
 	struct list_head matches;
-	unsigned int hashval = open_ownerstr_hashval(clid->cl_id, owner);
+	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
 	__be32 status;
 
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
@@ -4294,7 +4290,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	status = nfserr_locks_held;
 	INIT_LIST_HEAD(&matches);
 
-	list_for_each_entry(sop, &lock_ownerstr_hashtbl[hashval], so_strhash) {
+	list_for_each_entry(sop, &ownerstr_hashtbl[hashval], so_strhash) {
+		if (sop->so_is_open_owner)
+			continue;
 		if (!same_owner_str(sop, owner, clid))
 			continue;
 		list_for_each_entry(stp, &sop->so_stateids,
@@ -4444,16 +4442,16 @@ static void release_openowner_sop(struct nfs4_stateowner *sop)
 	release_openowner(openowner(sop));
 }
 
-static int nfsd_release_n_owners(u64 num,
-				struct list_head hashtbl[],
-				unsigned int hashtbl_size,
+static int nfsd_release_n_owners(u64 num, bool is_open_owner
 				void (*release_sop)(struct nfs4_stateowner *))
 {
 	int i, count = 0;
 	struct nfs4_stateowner *sop, *next;
 
-	for (i = 0; i < hashtbl_size; i++) {
-		list_for_each_entry_safe(sop, next, &hashtbl[i], so_strhash) {
+	for (i = 0; i < OWNER_HASH_SIZE; i++) {
+		list_for_each_entry_safe(sop, next, &ownerstr_hashtbl[i], so_strhash) {
+			if (sop->so_is_open_owner != is_open_owner)
+				continue;
 			release_sop(sop);
 			if (++count == num)
 				return count;
@@ -4467,8 +4465,7 @@ void nfsd_forget_locks(u64 num)
 	int count;
 
 	nfs4_lock_state();
-	count = nfsd_release_n_owners(num, lock_ownerstr_hashtbl,
-				     LOCK_HASH_SIZE, release_lockowner_sop);
+	count = nfsd_release_n_owners(num, false, release_lockowner_sop);
 	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Forgot %d locks", count);
@@ -4479,8 +4476,7 @@ void nfsd_forget_openowners(u64 num)
 	int count;
 
 	nfs4_lock_state();
-	count = nfsd_release_n_owners(num, open_ownerstr_hashtbl,
-				     OPEN_OWNER_HASH_SIZE, release_openowner_sop);
+	count = nfsd_release_n_owners(num, true, release_openowner_sop);
 	nfs4_unlock_state();
 
 	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
@@ -4549,11 +4545,8 @@ nfs4_state_init(void)
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
-	for (i = 0; i < OPEN_OWNER_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&open_ownerstr_hashtbl[i]);
-	}
-	for (i = 0; i < LOCK_HASH_SIZE; i++) {
-		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
+	for (i = 0; i < OWNER_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&ownerstr_hashtbl[i]);
 	}
 	memset(&onestateid, ~0, sizeof(stateid_t));
 	INIT_LIST_HEAD(&close_lru);
-- 
1.7.5.4

