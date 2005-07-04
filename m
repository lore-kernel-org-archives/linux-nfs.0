From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 008 of 19] nfsd4: stop overusing RECLAIM_BAD
Date: Mon, 04 Jul 2005 11:01:43 +1000
Message-ID: <E1DpFLD-0007GW-OZ@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM7-0001kz-Nh
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:39 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFM7-0007Zs-1A
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:39 -0700
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


A misreading of the spec lead us to convert all errors on open and lock
reclaims to RECLAIM_BAD.  This causes problems--for example, a reboot within
the grace period could lead to reclaims with stale stateid's, and we'd like to
return STALE errors in those cases.

What rfc3530 actually says about RECLAIM_BAD: "The reclaim provided by the
client does not match any of the server's state consistency checks and is bad."
I'm assuming that "state consistency checks" refers to checks for consistency
with the state recorded to stable storage, and that the error should be
reserved for that case.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   25 +++++++------------------
 1 files changed, 7 insertions(+), 18 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:52.000000000 +1000
@@ -1531,8 +1531,6 @@ renew:
 	status = nfs_ok;
 	renew_client(sop->so_client);
 out:
-	if (status && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
-		status = nfserr_reclaim_bad;
 	return status;
 }
 
@@ -1688,17 +1686,11 @@ nfs4_upgrade_open(struct svc_rqst *rqstp
 
 /* decrement seqid on successful reclaim, it will be bumped in encode_open */
 static void
-nfs4_set_claim_prev(struct nfsd4_open *open, int *status)
+nfs4_set_claim_prev(struct nfsd4_open *open)
 {
-	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
-		if (*status)
-			*status = nfserr_reclaim_bad;
-		else {
-			open->op_stateowner->so_confirmed = 1;
-			open->op_stateowner->so_client->cl_firststate = 1;
-			open->op_stateowner->so_seqid--;
-		}
-	}
+	open->op_stateowner->so_confirmed = 1;
+	open->op_stateowner->so_client->cl_firststate = 1;
+	open->op_stateowner->so_seqid--;
 }
 
 /*
@@ -1863,8 +1855,8 @@ nfsd4_process_open2(struct svc_rqst *rqs
 out:
 	if (fp)
 		put_nfs4_file(fp);
-	/* CLAIM_PREVIOUS has different error returns */
-	nfs4_set_claim_prev(open, &status);
+	if (status == 0 && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+		nfs4_set_claim_prev(open);
 	/*
 	* To finish the open response, we just need to set the rflags.
 	*/
@@ -2738,11 +2730,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		                        CHECK_FH | OPEN_STATE,
 		                        &open_sop, &open_stp,
 					&lock->v.new.clientid);
-		if (status) {
-			if (lock->lk_reclaim)
-				status = nfserr_reclaim_bad;
+		if (status)
 			goto out;
-		}
 		/* create lockowner and lock stateid */
 		fp = open_stp->st_file;
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
