From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 5] nfsd4: printk reduction
Date: Mon, 12 Sep 2005 16:25:39 +1000
Message-ID: <1050912062539.3956@cse.unsw.edu.au>
References: <20050912162037.1825.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EEhlG-0005M9-HB
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:50 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EEhlF-0007ly-VI
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:50 -0700
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


Demote some printk's that look like they could be triggered by non-buggy
clients to dprintk's.  (For example, stale clientid's are normal occurrences on
reboot, and on a server with a lot of clients these messages could become
annoying.)

Also remove some redundant dprintk's (e.g. no need for both STALE_CLIENTID
and its callers to do dprintks).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-09-12 16:11:33.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-09-12 16:11:33.000000000 +1000
@@ -624,7 +624,7 @@ gen_callback(struct nfs4_client *clp, st
 	cb->cb_ident = se->se_callback_ident;
 	return;
 out_err:
-	printk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
+	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
 		"will not receive delegations\n",
 		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
 
@@ -2014,7 +2014,7 @@ STALE_STATEID(stateid_t *stateid)
 {
 	if (stateid->si_boot == boot_time)
 		return 0;
-	printk("NFSD: stale stateid (%08x/%08x/%08x/%08x)!\n",
+	dprintk("NFSD: stale stateid (%08x/%08x/%08x/%08x)!\n",
 		stateid->si_boot, stateid->si_stateownerid, stateid->si_fileid,
 		stateid->si_generation);
 	return 1;
@@ -2275,7 +2275,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 
 check_replay:
 	if (seqid == sop->so_seqid - 1) {
-		printk("NFSD: preprocess_seqid_op: retransmission?\n");
+		dprintk("NFSD: preprocess_seqid_op: retransmission?\n");
 		/* indicate replay to calling function */
 		return NFSERR_REPLAY_ME;
 	}
@@ -2500,8 +2500,7 @@ find_stateid(stateid_t *stid, int flags)
 			    (local->st_stateid.si_fileid == f_id))
 				return local;
 		}
-	} else
-		printk("NFSD: find_stateid: ERROR: no state flag\n");
+	}
 	return NULL;
 }
 
@@ -2705,10 +2704,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		struct nfs4_file *fp;
 		
 		status = nfserr_stale_clientid;
-		if (STALE_CLIENTID(&lock->lk_new_clientid)) {
-			printk("NFSD: nfsd4_lock: clientid is stale!\n");
+		if (STALE_CLIENTID(&lock->lk_new_clientid))
 			goto out;
-		}
 
 		/* validate and update open stateid and open seqid */
 		status = nfs4_preprocess_seqid_op(current_fh, 
@@ -2751,7 +2748,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	filp = lock_stp->st_vfs_file;
 
 	if ((status = fh_verify(rqstp, current_fh, S_IFREG, MAY_LOCK))) {
-		printk("NFSD: nfsd4_lock: permission denied!\n");
+		dprintk("NFSD: nfsd4_lock: permission denied!\n");
 		goto out;
 	}
 
@@ -2866,13 +2863,11 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	nfs4_lock_state();
 
 	status = nfserr_stale_clientid;
-	if (STALE_CLIENTID(&lockt->lt_clientid)) {
-		printk("NFSD: nfsd4_lockt: clientid is stale!\n");
+	if (STALE_CLIENTID(&lockt->lt_clientid))
 		goto out;
-	}
 
 	if ((status = fh_verify(rqstp, current_fh, S_IFREG, 0))) {
-		printk("NFSD: nfsd4_lockt: fh_verify() failed!\n");
+		dprintk("NFSD: nfsd4_lockt: fh_verify() failed!\n");
 		if (status == nfserr_symlink)
 			status = nfserr_inval;
 		goto out;
@@ -2976,7 +2971,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
 		file_lock.fl_ops->fl_release_private(&file_lock);
 	if (status) {
-		printk("NFSD: nfs4_locku: posix_lock_file failed!\n");
+		dprintk("NFSD: nfs4_locku: posix_lock_file failed!\n");
 		goto out_nfserr;
 	}
 	/*
@@ -3036,10 +3031,8 @@ nfsd4_release_lockowner(struct svc_rqst 
 	/* XXX check for lease expiration */
 
 	status = nfserr_stale_clientid;
-	if (STALE_CLIENTID(clid)) {
-		printk("NFSD: nfsd4_release_lockowner: clientid is stale!\n");
+	if (STALE_CLIENTID(clid))
 		return status;
-	}
 
 	nfs4_lock_state();
 


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
