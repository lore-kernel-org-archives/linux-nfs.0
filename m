From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 6 of 18] nfsd4: take a reference to preserve stateowner through xdr replay code
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000kC-Cw@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi6v-00084z-D1
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi6u-00069b-DD
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:09 -0700
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



Take a reference to preserve the stateowner through the xdr replay code, and
simplify nfsd4_proc_compound a little.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c  |   46 +++++++++++++++++++++-------------------------
 ./fs/nfsd/nfs4state.c |   11 +++++++++++
 2 files changed, 32 insertions(+), 25 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-09-24 14:48:38.000000000 +1000
@@ -201,7 +201,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 			status = NFSERR_REPLAY_ME;
 	}
 	if (status)
-		return status;
+		goto out;
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_NULL) {
 	/*
 	 * This block of code will (1) set CURRENT_FH to the file being opened,
@@ -211,7 +211,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	 */
 		status = do_open_lookup(rqstp, current_fh, open);
 		if (status)
-			return status;
+			goto out;
 	} else if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
 	/*
 	* The CURRENT_FH is already set to the file being opened. This
@@ -221,10 +221,11 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	*/
 		status = do_open_fhandle(rqstp, current_fh, open);
 		if (status)
-			return status;
+			goto out;
 	} else {
 		printk("NFSD: unsupported OPEN claim type\n");
-		return nfserr_inval;
+		status = nfserr_inval;
+		goto out;
 	}
 	/*
 	 * nfsd4_process_open2() does the actual opening of the file.  If
@@ -232,9 +233,10 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	 * set, (2) sets open->op_stateid, (3) sets open->op_delegation.
 	 */
 	status = nfsd4_process_open2(rqstp, current_fh, open);
-	if (status)
-		return status;
-	return 0;
+out:
+	if (open->op_stateowner)
+		nfs4_get_stateowner(open->op_stateowner);
+	return status;
 }
 
 /*
@@ -785,6 +787,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 	struct nfsd4_op	*op;
 	struct svc_fh	*current_fh = NULL;
 	struct svc_fh	*save_fh = NULL;
+	struct nfs4_stateowner *replay_owner = NULL;
 	int		slack_space;    /* in words, not bytes! */
 	int		status;
 
@@ -864,9 +867,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_CLOSE:
 			op->status = nfsd4_close(rqstp, current_fh, &op->u.close);
-			if (op->u.close.cl_stateowner)
-				op->replay =
-					&op->u.close.cl_stateowner->so_replay;
+			replay_owner = op->u.close.cl_stateowner;
 			break;
 		case OP_COMMIT:
 			op->status = nfsd4_commit(rqstp, current_fh, &op->u.commit);
@@ -885,18 +886,14 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_LOCK:
 			op->status = nfsd4_lock(rqstp, current_fh, &op->u.lock);
-			if (op->u.lock.lk_stateowner)
-				op->replay =
-					&op->u.lock.lk_stateowner->so_replay;
+			replay_owner = op->u.lock.lk_stateowner;
 			break;
 		case OP_LOCKT:
 			op->status = nfsd4_lockt(rqstp, current_fh, &op->u.lockt);
 			break;
 		case OP_LOCKU:
 			op->status = nfsd4_locku(rqstp, current_fh, &op->u.locku);
-			if (op->u.locku.lu_stateowner)
-				op->replay =
-					&op->u.locku.lu_stateowner->so_replay;
+			replay_owner = op->u.locku.lu_stateowner;
 			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_lookup(rqstp, current_fh, &op->u.lookup);
@@ -911,21 +908,15 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_OPEN:
 			op->status = nfsd4_open(rqstp, current_fh, &op->u.open);
-			if (op->u.open.op_stateowner)
-				op->replay =
-					&op->u.open.op_stateowner->so_replay;
+			replay_owner = op->u.open.op_stateowner;
 			break;
 		case OP_OPEN_CONFIRM:
 			op->status = nfsd4_open_confirm(rqstp, current_fh, &op->u.open_confirm);
-			if (op->u.open_confirm.oc_stateowner)
-				op->replay =
-					&op->u.open_confirm.oc_stateowner->so_replay;
+			replay_owner = op->u.open_confirm.oc_stateowner;
 			break;
 		case OP_OPEN_DOWNGRADE:
 			op->status = nfsd4_open_downgrade(rqstp, current_fh, &op->u.open_downgrade);
-			if (op->u.open_downgrade.od_stateowner)
-				op->replay =
-					&op->u.open_downgrade.od_stateowner->so_replay;
+			replay_owner = op->u.open_downgrade.od_stateowner;
 			break;
 		case OP_PUTFH:
 			op->status = nfsd4_putfh(rqstp, current_fh, &op->u.putfh);
@@ -984,12 +975,17 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 
 encode_op:
 		if (op->status == NFSERR_REPLAY_ME) {
+			op->replay = &replay_owner->so_replay;
 			nfsd4_encode_replay(resp, op);
 			status = op->status = op->replay->rp_status;
 		} else {
 			nfsd4_encode_operation(resp, op);
 			status = op->status;
 		}
+		if (replay_owner && (replay_owner != (void *)(-1))) {
+			nfs4_put_stateowner(replay_owner);
+			replay_owner = NULL;
+		}
 	}
 
 out:

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:38.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:38.000000000 +1000
@@ -1749,6 +1749,8 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 	status = nfs_ok;
 	first_state(sop->so_client);
 out:
+	if (oc->oc_stateowner)
+		nfs4_get_stateowner(oc->oc_stateowner);
 	return status;
 }
 
@@ -1826,6 +1828,8 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
+	if (od->od_stateowner)
+		nfs4_get_stateowner(od->od_stateowner);
 	return status;
 }
 
@@ -1860,6 +1864,8 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	/* release_state_owner() calls nfsd_close() if needed */
 	release_state_owner(stp, &close->cl_stateowner, OPEN_STATE);
 out:
+	if (close->cl_stateowner)
+		nfs4_get_stateowner(close->cl_stateowner);
 	return status;
 }
 
@@ -2160,6 +2166,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		if ((lock_stp = alloc_init_lock_stateid(lock->lk_stateowner, 
 						fp, open_stp)) == NULL) {
 			release_stateowner(lock->lk_stateowner);
+			lock->lk_stateowner = NULL;
 			goto out;
 		}
 		/* bump the open seqid used to create the lock */
@@ -2258,6 +2265,8 @@ out_destroy_new_stateid:
 		release_state_owner(lock_stp, &lock->lk_stateowner, LOCK_STATE);
 	}
 out:
+	if (lock->lk_stateowner)
+		nfs4_get_stateowner(lock->lk_stateowner);
 	return status;
 }
 
@@ -2409,6 +2418,8 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	memcpy(&locku->lu_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 out:
+	if (locku->lu_stateowner)
+		nfs4_get_stateowner(locku->lu_stateowner);
 	return status;
 
 out_nfserr:


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
