From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 018 of 19] nfsd4: check lock type against openmode.
Date: Mon, 04 Jul 2005 11:01:44 +1000
Message-ID: <E1DpFLE-0007HA-HF@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFMA-0001li-OW
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:42 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFMA-0007aU-0Y
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:42 -0700
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


We shouldn't be allowing, e.g., write locks on files not open for read.
To enforce this, we add a pointer from the lock stateid back to the
open stateid it came from, so that the check will continue to be correct
even after the open is upgraded or downgraded.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   49 ++++++++++++++++++++++++++++---------------
 ./include/linux/nfsd/state.h |    5 ++++
 2 files changed, 38 insertions(+), 16 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:53.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:53.000000000 +1000
@@ -1160,6 +1160,7 @@ init_stateid(struct nfs4_stateid *stp, s
 	stp->st_deny_bmap = 0;
 	__set_bit(open->op_share_access, &stp->st_access_bmap);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
+	stp->st_openstp = NULL;
 }
 
 static void
@@ -2158,12 +2159,18 @@ out:
 	return status;
 }
 
+static inline int
+setlkflg (int type)
+{
+	return (type == NFS4_READW_LT || type == NFS4_READ_LT) ?
+		RD_STATE : WR_STATE;
+}
 
 /* 
  * Checks for sequence id mutating operations. 
  */
 static int
-nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp, clientid_t *lockclid)
+nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp, struct nfsd4_lock *lock)
 {
 	struct nfs4_stateid *stp;
 	struct nfs4_stateowner *sop;
@@ -2201,21 +2208,31 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 		goto check_replay;
 	}
 
-	/* for new lock stateowners:
-	 * check that the lock->v.new.open_stateid
-	 * refers to an open stateowner
-	 *
-	 * check that the lockclid (nfs4_lock->v.new.clientid) is the same
-	 * as the open_stateid->st_stateowner->so_client->clientid
-	 */
-	if (lockclid) {
+	if (lock) {
 		struct nfs4_stateowner *sop = stp->st_stateowner;
+		clientid_t *lockclid = &lock->v.new.clientid;
 		struct nfs4_client *clp = sop->so_client;
+		int lkflg = 0;
+		int status;
+
+		lkflg = setlkflg(lock->lk_type);
+
+		if (lock->lk_is_new) {
+                       if (!sop->so_is_open_owner)
+			       return nfserr_bad_stateid;
+                       if (!cmp_clid(&clp->cl_clientid, lockclid))
+			       return nfserr_bad_stateid;
+                       /* stp is the open stateid */
+                       status = nfs4_check_openmode(stp, lkflg);
+                       if (status)
+			       return status;
+               } else {
+                       /* stp is the lock stateid */
+                       status = nfs4_check_openmode(stp->st_openstp, lkflg);
+                       if (status)
+			       return status;
+               }
 
-		if (!sop->so_is_open_owner)
-			return nfserr_bad_stateid;
-		if (!cmp_clid(&clp->cl_clientid, lockclid))
-			return nfserr_bad_stateid;
 	}
 
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
@@ -2642,6 +2659,7 @@ alloc_init_lock_stateid(struct nfs4_stat
 	stp->st_vfs_file = open_stp->st_vfs_file; /* FIXME refcount?? */
 	stp->st_access_bmap = open_stp->st_access_bmap;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
+	stp->st_openstp = open_stp;
 
 out:
 	return stp;
@@ -2697,8 +2715,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
 		                        CHECK_FH | OPEN_STATE,
-		                        &open_sop, &open_stp,
-					&lock->v.new.clientid);
+		                        &open_sop, &open_stp, lock);
 		if (status)
 			goto out;
 		/* create lockowner and lock stateid */
@@ -2726,7 +2743,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
 				       CHECK_FH | LOCK_STATE, 
-				       &lock->lk_stateowner, &lock_stp, NULL);
+				       &lock->lk_stateowner, &lock_stp, lock);
 		if (status)
 			goto out;
 	}

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-07-04 10:57:53.000000000 +1000
@@ -237,6 +237,10 @@ struct nfs4_file {
 *       st_perlockowner: (open stateid) list of lock nfs4_stateowners
 * 	st_access_bmap: used only for open stateid
 * 	st_deny_bmap: used only for open stateid
+*	st_openstp: open stateid lock stateid was derived from
+*
+* XXX: open stateids and lock stateids have diverged sufficiently that
+* we should consider defining separate structs for the two cases.
 */
 
 struct nfs4_stateid {
@@ -250,6 +254,7 @@ struct nfs4_stateid {
 	struct file                 * st_vfs_file;
 	unsigned long                 st_access_bmap;
 	unsigned long                 st_deny_bmap;
+	struct nfs4_stateid         * st_openstp;
 };
 
 /* flags for preprocess_seqid_op() */


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
