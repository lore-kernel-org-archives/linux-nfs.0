Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756461Ab1KHW7J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 17:59:09 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd4: hash lockowners to simplify RELEASE_LOCKOWNER
Date: Tue,  8 Nov 2011 17:59:03 -0500
Message-Id: <1320793145-29070-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20111108225751.GD27413@fieldses.org>
References: <20111108225751.GD27413@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Hash lockowners on just the owner string rather than on (owner, inode).
This makes the owner-string lookup needed for RELEASE_LOCKOWNER simpler
(currently it's doing at a linear search through the entire hash
table!).  That may come at the expense of making (owner, inode) lookups
more expensive if a client reuses the same lockowner across multiple
files.  We might add a separate lookup for that.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   42 ++++++++++++++----------------------------
 1 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1d6812d..eec9900 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3746,15 +3746,6 @@ last_byte_offset(u64 start, u64 len)
 	return end > start ? end - 1: NFS4_MAX_UINT64;
 }
 
-static inline unsigned int
-lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
-		struct xdr_netobj *ownername)
-{
-	return (file_hashval(inode) + cl_id
-			+ opaque_hashval(ownername->data, ownername->len))
-		& LOCK_HASH_MASK;
-}
-
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
 
 /*
@@ -3824,7 +3815,7 @@ static struct nfs4_lockowner *
 find_lockowner_str(struct inode *inode, clientid_t *clid,
 		struct xdr_netobj *owner)
 {
-	unsigned int hashval = lock_ownerstr_hashval(inode, clid->cl_id, owner);
+	unsigned int hashval = open_ownerstr_hashval(clid->cl_id, owner);
 	struct nfs4_lockowner *lo;
 	struct nfs4_stateowner *op;
 
@@ -3847,7 +3838,7 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
  * Called in nfsd4_lock - therefore, OPEN and OPEN_CONFIRM (if needed) has 
  * occurred. 
  *
- * strhashval = lock_ownerstr_hashval 
+ * strhashval = open_ownerstr_hashval
  */
 
 static struct nfs4_lockowner *
@@ -3922,7 +3913,7 @@ __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct n
 				struct nfs4_ol_stateid, st_perstateowner);
 		return nfs_ok;
 	}
-	strhashval = lock_ownerstr_hashval(fi->fi_inode, cl->cl_clientid.cl_id,
+	strhashval = open_ownerstr_hashval(cl->cl_clientid.cl_id,
 			&lock->v.new.owner);
 	lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 	if (lo == NULL)
@@ -4286,7 +4277,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	struct nfs4_ol_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
 	struct list_head matches;
-	int i;
+	unsigned int hashval = open_ownerstr_hashval(clid->cl_id, owner);
 	__be32 status;
 
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
@@ -4301,22 +4292,17 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	nfs4_lock_state();
 
 	status = nfserr_locks_held;
-	/* XXX: we're doing a linear search through all the lockowners.
-	 * Yipes!  For now we'll just hope clients aren't really using
-	 * release_lockowner much, but eventually we have to fix these
-	 * data structures. */
 	INIT_LIST_HEAD(&matches);
-	for (i = 0; i < LOCK_HASH_SIZE; i++) {
-		list_for_each_entry(sop, &lock_ownerstr_hashtbl[i], so_strhash) {
-			if (!same_owner_str(sop, owner, clid))
-				continue;
-			list_for_each_entry(stp, &sop->so_stateids,
-					st_perstateowner) {
-				lo = lockowner(sop);
-				if (check_for_locks(stp->st_file, lo))
-					goto out;
-				list_add(&lo->lo_list, &matches);
-			}
+
+	list_for_each_entry(sop, &lock_ownerstr_hashtbl[hashval], so_strhash) {
+		if (!same_owner_str(sop, owner, clid))
+			continue;
+		list_for_each_entry(stp, &sop->so_stateids,
+				st_perstateowner) {
+			lo = lockowner(sop);
+			if (check_for_locks(stp->st_file, lo))
+				goto out;
+			list_add(&lo->lo_list, &matches);
 		}
 	}
 	/* Clients probably won't expect us to return with some (but not all)
-- 
1.7.5.4

