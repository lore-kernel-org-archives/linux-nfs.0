From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 003 of 5] nfsd4: fix open seqid incrementing in lock
Date: Mon, 12 Sep 2005 16:25:40 +1000
Message-ID: <1050912062540.3990@cse.unsw.edu.au>
References: <20050912162037.1825.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EEhlU-0005NE-V8
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:26:04 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EEhlT-0000V1-Dk
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:26:04 -0700
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


In the case of a lock which introduces a new lockowner, the openowner's
sequence id should be incremented, even when the operation fails, if the error
is a sequence-id-mutating error.  The current code fails to do that in some
cases.  Fix this by using the same sequence-id-incrementing mechanism that
all other such operations use.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-09-12 16:11:48.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-09-12 16:12:02.000000000 +1000
@@ -2629,7 +2629,9 @@ alloc_init_lock_stateowner(unsigned int 
 	sop->so_is_open_owner = 0;
 	sop->so_id = current_ownerid++;
 	sop->so_client = clp;
-	sop->so_seqid = lock->lk_new_lock_seqid;
+	/* It is the openowner seqid that will be incremented in encode in the
+	 * case of new lockowners; so increment the lock seqid manually: */
+	sop->so_seqid = lock->lk_new_lock_seqid + 1;
 	sop->so_confirmed = 1;
 	rp = &sop->so_replay;
 	rp->rp_status = NFSERR_SERVERFAULT;
@@ -2684,6 +2686,7 @@ int
 nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock *lock, struct nfs4_stateowner **replay_owner)
 {
 	struct nfs4_stateowner *open_sop = NULL;
+	struct nfs4_stateowner *lock_sop = NULL;
 	struct nfs4_stateid *lock_stp;
 	struct file *filp;
 	struct file_lock file_lock;
@@ -2718,9 +2721,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
 		                        CHECK_FH | OPEN_STATE,
-		                        &open_sop, &open_stp, lock);
+		                        &lock->lk_stateowner, &open_stp,
+					lock);
 		if (status)
 			goto out;
+		open_sop = lock->lk_stateowner;
 		/* create lockowner and lock stateid */
 		fp = open_stp->st_file;
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
@@ -2730,16 +2735,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		 * the same file, or should they just be allowed (and
 		 * create new stateids)? */
 		status = nfserr_resource;
-		if (!(lock->lk_stateowner = alloc_init_lock_stateowner(strhashval, open_sop->so_client, open_stp, lock)))
+		lock_sop = alloc_init_lock_stateowner(strhashval,
+				open_sop->so_client, open_stp, lock);
+		if (lock_sop == NULL)
 			goto out;
-		if ((lock_stp = alloc_init_lock_stateid(lock->lk_stateowner, 
-						fp, open_stp)) == NULL) {
-			release_stateowner(lock->lk_stateowner);
-			lock->lk_stateowner = NULL;
+		lock_stp = alloc_init_lock_stateid(lock_sop, fp, open_stp);
+		if (lock_stp == NULL) {
+			release_stateowner(lock_sop);
 			goto out;
 		}
-		/* bump the open seqid used to create the lock */
-		open_sop->so_seqid++;
 	} else {
 		/* lock (lock owner + lock stateid) already exists */
 		status = nfs4_preprocess_seqid_op(current_fh,
@@ -2749,6 +2753,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 				       &lock->lk_stateowner, &lock_stp, lock);
 		if (status)
 			goto out;
+		lock_sop = lock->lk_stateowner;
 	}
 	/* lock->lk_stateowner and lock_stp have been created or found */
 	filp = lock_stp->st_vfs_file;
@@ -2779,7 +2784,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 			status = nfserr_inval;
 		goto out;
 	}
-	file_lock.fl_owner = (fl_owner_t) lock->lk_stateowner;
+	file_lock.fl_owner = (fl_owner_t)lock_sop;
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
 	file_lock.fl_flags = FL_POSIX;
@@ -2835,9 +2840,6 @@ out_destroy_new_stateid:
 		 * An error encountered after instantiation of the new
 		 * stateid has forced us to destroy it.
 		 */
-		if (!seqid_mutating_err(status))
-			open_sop->so_seqid--;
-
 		release_state_owner(lock_stp, LOCK_STATE);
 	}
 out:


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
