From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 006 of 26] nfsd4: rename lk_stateowner
Date: Fri, 13 Jan 2006 12:00:53 +1100
Message-ID: <1060113010053.22998@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJN-0002Xw-0h
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:01 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJM-0004lv-IT
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:01 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:56 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:54 +1100
To: nfs@lists.sourceforge.net
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


One of the things that's confusing about nfsd4_lock is that the lk_stateowner
field could be set to either of two different lockowners: the open owner or the
lock owner.  Rename to lk_replay_owner and add a comment to make it clear that
it's used for whichever stateowner has its sequence id bumped for replay
detection.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |   16 ++++++++--------
 ./fs/nfsd/nfs4xdr.c         |    5 ++---
 ./include/linux/nfsd/xdr4.h |    5 +++--
 3 files changed, 13 insertions(+), 13 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:05.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:05.000000000 +1100
@@ -2725,11 +2725,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
 		                        CHECK_FH | OPEN_STATE,
-		                        &lock->lk_stateowner, &open_stp,
+		                        &lock->lk_replay_owner, &open_stp,
 					lock);
 		if (status)
 			goto out;
-		open_sop = lock->lk_stateowner;
+		open_sop = lock->lk_replay_owner;
 		/* create lockowner and lock stateid */
 		fp = open_stp->st_file;
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
@@ -2752,12 +2752,12 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
 				       CHECK_FH | LOCK_STATE, 
-				       &lock->lk_stateowner, &lock_stp, lock);
+				       &lock->lk_replay_owner, &lock_stp, lock);
 		if (status)
 			goto out;
-		lock_sop = lock->lk_stateowner;
+		lock_sop = lock->lk_replay_owner;
 	}
-	/* lock->lk_stateowner and lock_stp have been created or found */
+	/* lock->lk_replay_owner and lock_stp have been created or found */
 	filp = lock_stp->st_vfs_file;
 
 	status = nfserr_grace;
@@ -2830,9 +2830,9 @@ conflicting_lock:
 out:
 	if (status && lock->lk_is_new && lock_sop)
 		release_stateowner(lock_sop);
-	if (lock->lk_stateowner) {
-		nfs4_get_stateowner(lock->lk_stateowner);
-		*replay_owner = lock->lk_stateowner;
+	if (lock->lk_replay_owner) {
+		nfs4_get_stateowner(lock->lk_replay_owner);
+		*replay_owner = lock->lk_replay_owner;
 	}
 	nfs4_unlock_state();
 	return status;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2006-01-13 11:50:54.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2006-01-13 11:51:05.000000000 +1100
@@ -528,7 +528,7 @@ nfsd4_decode_lock(struct nfsd4_compounda
 {
 	DECODE_HEAD;
 
-	lock->lk_stateowner = NULL;
+	lock->lk_replay_owner = NULL;
 	/*
 	* type, reclaim(boolean), offset, length, new_lock_owner(boolean)
 	*/
@@ -1895,7 +1895,6 @@ nfsd4_encode_lock_denied(struct nfsd4_co
 static void
 nfsd4_encode_lock(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_lock *lock)
 {
-
 	ENCODE_SEQID_OP_HEAD;
 
 	if (!nfserr) {
@@ -1906,7 +1905,7 @@ nfsd4_encode_lock(struct nfsd4_compoundr
 	} else if (nfserr == nfserr_denied)
 		nfsd4_encode_lock_denied(resp, &lock->lk_denied);
 
-	ENCODE_SEQID_OP_TAIL(lock->lk_stateowner);
+	ENCODE_SEQID_OP_TAIL(lock->lk_replay_owner);
 }
 
 static void

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2006-01-13 11:50:54.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2006-01-13 11:51:05.000000000 +1100
@@ -145,8 +145,9 @@ struct nfsd4_lock {
 		} ok;
 		struct nfsd4_lock_denied        denied;
 	} u;
-
-	struct nfs4_stateowner *lk_stateowner;
+	/* The lk_replay_owner is the open owner in the open_to_lock_owner
+	 * case and the lock owner otherwise: */
+	struct nfs4_stateowner *lk_replay_owner;
 };
 #define lk_new_open_seqid       v.new.open_seqid
 #define lk_new_open_stateid     v.new.open_stateid


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
