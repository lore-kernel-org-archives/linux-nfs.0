From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 024 of 28] nfsd4: allow multiple lockowners
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006iu-Qv@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3Z-0005yW-2y
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:25 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3W-0002Sj-Hv
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:24 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


>From the language of rfc3530 section 8.1.3 (e.g., the suggestion that a
"process id" might be a reasonable lockowner value) it's conceivable that a
client might want to use the same lockowner string on multiple files, so we may
as well allow that.  We expect each use of open_to_lockowner to create a
distinct seqid stream, though.

For now we're also allowing multiple uses of open_to_lockowner with the same
open, though it seems unlikely clients would actually do that.

Also add a comment reminding myself of some very non-scalable data structures.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   76 +++++++++++++++++++++-----------------------------
 1 files changed, 33 insertions(+), 43 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:06.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:06.000000000 +1000
@@ -2584,22 +2584,6 @@ nfs4_set_lock_denied(struct file_lock *f
 }
 
 static struct nfs4_stateowner *
-find_lockstateowner(struct xdr_netobj *owner, clientid_t *clid)
-{
-	struct nfs4_stateowner *local = NULL;
-	int i;
-
-	for (i = 0; i < LOCK_HASH_SIZE; i++) {
-		list_for_each_entry(local, &lock_ownerid_hashtbl[i], so_idhash) {
-			if (!cmp_owner_str(local, owner, clid))
-				continue;
-			return local;
-		}
-	}
-	return NULL;
-}
-
-static struct nfs4_stateowner *
 find_lockstateowner_str(struct inode *inode, clientid_t *clid,
 		struct xdr_netobj *owner)
 {
@@ -2697,7 +2681,7 @@ check_lock_length(u64 offset, u64 length
 int
 nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock *lock)
 {
-	struct nfs4_stateowner *lock_sop = NULL, *open_sop = NULL;
+	struct nfs4_stateowner *open_sop = NULL;
 	struct nfs4_stateid *lock_stp;
 	struct file *filp;
 	struct file_lock file_lock;
@@ -2756,16 +2740,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
 				open_sop->so_client->cl_clientid.cl_id, 
 				&lock->v.new.owner);
-		/* 
-		 * If we already have this lock owner, the client is in 
-		 * error (or our bookeeping is wrong!) 
-		 * for asking for a 'new lock'.
-		 */
-		status = nfserr_bad_stateid;
-		lock_sop = find_lockstateowner(&lock->v.new.owner,
-						&lock->v.new.clientid);
-		if (lock_sop)
-			goto out;
+		/* XXX: Do we need to check for duplicate stateowners on
+		 * the same file, or should they just be allowed (and
+		 * create new stateids)? */
 		status = nfserr_resource;
 		if (!(lock->lk_stateowner = alloc_init_lock_stateowner(strhashval, open_sop->so_client, open_stp, lock)))
 			goto out;
@@ -3056,8 +3033,11 @@ int
 nfsd4_release_lockowner(struct svc_rqst *rqstp, struct nfsd4_release_lockowner *rlockowner)
 {
 	clientid_t *clid = &rlockowner->rl_clientid;
-	struct nfs4_stateowner *local = NULL;
+	struct nfs4_stateowner *sop;
+	struct nfs4_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
+	struct list_head matches;
+	int i;
 	int status;
 
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
@@ -3073,22 +3053,32 @@ nfsd4_release_lockowner(struct svc_rqst 
 
 	nfs4_lock_state();
 
-	status = nfs_ok;
-	local = find_lockstateowner(owner, clid);
-	if (local) {
-		struct nfs4_stateid *stp;
-
-		/* check for any locks held by any stateid
-		 * associated with the (lock) stateowner */
-		status = nfserr_locks_held;
-		list_for_each_entry(stp, &local->so_stateids,
-				st_perstateowner) {
-			if (check_for_locks(stp->st_vfs_file, local))
-				goto out;
+	status = nfserr_locks_held;
+	/* XXX: we're doing a linear search through all the lockowners.
+	 * Yipes!  For now we'll just hope clients aren't really using
+	 * release_lockowner much, but eventually we have to fix these
+	 * data structures. */
+	INIT_LIST_HEAD(&matches);
+	for (i = 0; i < LOCK_HASH_SIZE; i++) {
+		list_for_each_entry(sop, &lock_ownerid_hashtbl[i], so_idhash) {
+			if (!cmp_owner_str(sop, owner, clid))
+				continue;
+			list_for_each_entry(stp, &sop->so_stateids,
+					st_perstateowner) {
+				if (check_for_locks(stp->st_vfs_file, sop))
+					goto out;
+				/* Note: so_perclient unused for lockowners,
+				 * so it's OK to fool with here. */
+				list_add(&sop->so_perclient, &matches);
+			}
 		}
-		/* no locks held by (lock) stateowner */
-		status = nfs_ok;
-		release_stateowner(local);
+	}
+	/* Clients probably won't expect us to return with some (but not all)
+	 * of the lockowner state released; so don't release any until all
+	 * have been checked. */
+	status = nfs_ok;
+	list_for_each_entry(sop, &matches, so_perclient) {
+		release_stateowner(sop);
 	}
 out:
 	nfs4_unlock_state();


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
