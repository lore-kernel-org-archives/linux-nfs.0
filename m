From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 005 of 26] nfsd4: fix nfsd4_lock cleanup on failure
Date: Fri, 13 Jan 2006 12:00:52 +1100
Message-ID: <1060113010052.22986@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJO-0002YL-Cy
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:02 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJN-0006il-Mp
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:02 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.18] == smtp-dist-03.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:56 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:53 +1100
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


release_state_owner also puts the lock owner on the close_lru.  There's no need
for that, though; replays of the failed lock would be handled by the openowner
not the lockowner.

Also consolidate the cleanup a bit, fixing leaks that can happen if errors
occur between the time a new lock owner is allocated and the lock is done.

Remove a comment and dprintk that look a little redundant.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:05.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:05.000000000 +1100
@@ -2744,10 +2744,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		if (lock_sop == NULL)
 			goto out;
 		lock_stp = alloc_init_lock_stateid(lock_sop, fp, open_stp);
-		if (lock_stp == NULL) {
-			release_stateowner(lock_sop);
+		if (lock_stp == NULL)
 			goto out;
-		}
 	} else {
 		/* lock (lock owner + lock stateid) already exists */
 		status = nfs4_preprocess_seqid_op(current_fh,
@@ -2815,7 +2813,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		status = nfserr_deadlock;
 	default:        
 		dprintk("NFSD: nfsd4_lock: posix_lock_file() failed! status %d\n",status);
-		goto out_destroy_new_stateid;
+		goto out;
 	}
 
 conflicting_lock:
@@ -2829,17 +2827,9 @@ conflicting_lock:
 		goto out;
 	}
 	nfs4_set_lock_denied(conflock, &lock->lk_denied);
-
-out_destroy_new_stateid:
-	if (lock->lk_is_new) {
-		dprintk("NFSD: nfsd4_lock: destroy new stateid!\n");
-		/*
-		 * An error encountered after instantiation of the new
-		 * stateid has forced us to destroy it.
-		 */
-		release_state_owner(lock_stp, LOCK_STATE);
-	}
 out:
+	if (status && lock->lk_is_new && lock_sop)
+		release_stateowner(lock_sop);
 	if (lock->lk_stateowner) {
 		nfs4_get_stateowner(lock->lk_stateowner);
 		*replay_owner = lock->lk_stateowner;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
