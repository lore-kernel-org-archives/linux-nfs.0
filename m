From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 6 of 9] nfsd4 lockowner fixes
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Lq-Qj@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8n-00024T-KU
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:13 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8m-0005fO-Vp
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:13 -0700
To: Andrew Morton <akpm@osdl.org>
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



Insist that the first time a client presents a new lockowner, the seqid should
be 0.  (RFC 3530 section 8.1.5)

Also, return an error if the client presents a previously-used lockowner as
if it were new.

>From Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>         
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-06-23 14:37:30.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-06-23 14:37:44.000000000 +1000
@@ -1510,10 +1510,12 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 
 	status = nfserr_bad_stateid;
 
-	/* for new lock stateowners, check that the lock->v.new.open_stateid
-	 * refers to an open stateowner, and that the lockclid
-	 * (nfs4_lock->v.new.clientid) is the same as the
-	 * open_stateid->st_stateowner->so_client->clientid
+	/* for new lock stateowners: 
+	 * check that the lock->v.new.open_stateid
+	 * refers to an open stateowner
+	 * 
+	 * check that the lockclid (nfs4_lock->v.new.clientid) is the same 
+	 * as the open_stateid->st_stateowner->so_client->clientid
 	 */
 	if (lockclid) {
 		struct nfs4_stateowner *sop = stp->st_stateowner;
@@ -2007,7 +2009,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 			printk("NFSD: nfsd4_lock: clientid is stale!\n");
 			goto out;
 		}
-		/* does the clientid in the lock owner own the open stateid? */
+
+		/* is the new lock seqid presented by the client zero? */
+		status = nfserr_bad_seqid;
+		if (lock->v.new.lock_seqid != 0)
+			goto out;
 
 		/* validate and update open stateid and open seqid */
 		status = nfs4_preprocess_seqid_op(current_fh, 
@@ -2026,15 +2032,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
 				open_sop->so_client->cl_clientid.cl_id, 
 				lock->v.new.owner);
-
 		/* 
 		 * If we already have this lock owner, the client is in 
 		 * error (or our bookeeping is wrong!) 
 		 * for asking for a 'new lock'.
 		 */
 		status = nfserr_bad_stateid;
-		if (find_lockstateowner_str(strhashval, &lock->v.new.owner,
-					&lock->v.new.clientid, &lock_sop))
+		lock_sop = find_lockstateowner(&lock->v.new.owner,
+						&lock->v.new.clientid);
+		if (lock_sop)
 			goto out;
 		status = nfserr_resource;
 		if (!(lock->lk_stateowner = alloc_init_lock_stateowner(strhashval, open_sop->so_client, open_stp, lock)))


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
