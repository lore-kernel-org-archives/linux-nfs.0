From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 002 of 5] nfsd4: move replay_owner
Date: Mon, 12 Sep 2005 16:25:39 +1000
Message-ID: <1050912062539.3974@cse.unsw.edu.au>
References: <20050912162037.1825.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EEhlU-0005N9-7C
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:26:04 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EEhlT-0000V5-DO
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


It seems more natural to move the setting of the replay_owner into the relevant
procedure instead of doing it in nfsv4_proc_compound.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c        |   24 ++++++++++--------------
 ./fs/nfsd/nfs4state.c       |   30 ++++++++++++++++++++----------
 ./include/linux/nfsd/xdr4.h |   15 ++++++++++-----
 3 files changed, 40 insertions(+), 29 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-09-12 16:11:48.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2005-09-12 16:11:48.000000000 +1000
@@ -162,7 +162,7 @@ do_open_fhandle(struct svc_rqst *rqstp, 
 
 
 static inline int
-nfsd4_open(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
+nfsd4_open(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open, struct nfs4_stateowner **replay_owner)
 {
 	int status;
 	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
@@ -238,8 +238,10 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	 */
 	status = nfsd4_process_open2(rqstp, current_fh, open);
 out:
-	if (open->op_stateowner)
+	if (open->op_stateowner) {
 		nfs4_get_stateowner(open->op_stateowner);
+		*replay_owner = open->op_stateowner;
+	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -809,8 +811,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			op->status = nfsd4_access(rqstp, current_fh, &op->u.access);
 			break;
 		case OP_CLOSE:
-			op->status = nfsd4_close(rqstp, current_fh, &op->u.close);
-			replay_owner = op->u.close.cl_stateowner;
+			op->status = nfsd4_close(rqstp, current_fh, &op->u.close, &replay_owner);
 			break;
 		case OP_COMMIT:
 			op->status = nfsd4_commit(rqstp, current_fh, &op->u.commit);
@@ -831,15 +832,13 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			op->status = nfsd4_link(rqstp, current_fh, save_fh, &op->u.link);
 			break;
 		case OP_LOCK:
-			op->status = nfsd4_lock(rqstp, current_fh, &op->u.lock);
-			replay_owner = op->u.lock.lk_stateowner;
+			op->status = nfsd4_lock(rqstp, current_fh, &op->u.lock, &replay_owner);
 			break;
 		case OP_LOCKT:
 			op->status = nfsd4_lockt(rqstp, current_fh, &op->u.lockt);
 			break;
 		case OP_LOCKU:
-			op->status = nfsd4_locku(rqstp, current_fh, &op->u.locku);
-			replay_owner = op->u.locku.lu_stateowner;
+			op->status = nfsd4_locku(rqstp, current_fh, &op->u.locku, &replay_owner);
 			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_lookup(rqstp, current_fh, &op->u.lookup);
@@ -853,16 +852,13 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 				op->status = nfs_ok;
 			break;
 		case OP_OPEN:
-			op->status = nfsd4_open(rqstp, current_fh, &op->u.open);
-			replay_owner = op->u.open.op_stateowner;
+			op->status = nfsd4_open(rqstp, current_fh, &op->u.open, &replay_owner);
 			break;
 		case OP_OPEN_CONFIRM:
-			op->status = nfsd4_open_confirm(rqstp, current_fh, &op->u.open_confirm);
-			replay_owner = op->u.open_confirm.oc_stateowner;
+			op->status = nfsd4_open_confirm(rqstp, current_fh, &op->u.open_confirm, &replay_owner);
 			break;
 		case OP_OPEN_DOWNGRADE:
-			op->status = nfsd4_open_downgrade(rqstp, current_fh, &op->u.open_downgrade);
-			replay_owner = op->u.open_downgrade.od_stateowner;
+			op->status = nfsd4_open_downgrade(rqstp, current_fh, &op->u.open_downgrade, &replay_owner);
 			break;
 		case OP_PUTFH:
 			op->status = nfsd4_putfh(rqstp, current_fh, &op->u.putfh);

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-09-12 16:11:33.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-09-12 16:11:48.000000000 +1000
@@ -2286,7 +2286,7 @@ check_replay:
 }
 
 int
-nfsd4_open_confirm(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_confirm *oc)
+nfsd4_open_confirm(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_confirm *oc, struct nfs4_stateowner **replay_owner)
 {
 	int status;
 	struct nfs4_stateowner *sop;
@@ -2320,8 +2320,10 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 
 	nfsd4_create_clid_dir(sop->so_client);
 out:
-	if (oc->oc_stateowner)
+	if (oc->oc_stateowner) {
 		nfs4_get_stateowner(oc->oc_stateowner);
+		*replay_owner = oc->oc_stateowner;
+	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -2352,7 +2354,7 @@ reset_union_bmap_deny(unsigned long deny
 }
 
 int
-nfsd4_open_downgrade(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_downgrade *od)
+nfsd4_open_downgrade(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_downgrade *od, struct nfs4_stateowner **replay_owner)
 {
 	int status;
 	struct nfs4_stateid *stp;
@@ -2394,8 +2396,10 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
-	if (od->od_stateowner)
+	if (od->od_stateowner) {
 		nfs4_get_stateowner(od->od_stateowner);
+		*replay_owner = od->od_stateowner;
+	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -2404,7 +2408,7 @@ out:
  * nfs4_unlock_state() called after encode
  */
 int
-nfsd4_close(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_close *close)
+nfsd4_close(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_close *close, struct nfs4_stateowner **replay_owner)
 {
 	int status;
 	struct nfs4_stateid *stp;
@@ -2430,8 +2434,10 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	/* release_state_owner() calls nfsd_close() if needed */
 	release_state_owner(stp, OPEN_STATE);
 out:
-	if (close->cl_stateowner)
+	if (close->cl_stateowner) {
 		nfs4_get_stateowner(close->cl_stateowner);
+		*replay_owner = close->cl_stateowner;
+	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -2675,7 +2681,7 @@ check_lock_length(u64 offset, u64 length
  *  LOCK operation 
  */
 int
-nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock *lock)
+nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock *lock, struct nfs4_stateowner **replay_owner)
 {
 	struct nfs4_stateowner *open_sop = NULL;
 	struct nfs4_stateid *lock_stp;
@@ -2835,8 +2841,10 @@ out_destroy_new_stateid:
 		release_state_owner(lock_stp, LOCK_STATE);
 	}
 out:
-	if (lock->lk_stateowner)
+	if (lock->lk_stateowner) {
 		nfs4_get_stateowner(lock->lk_stateowner);
+		*replay_owner = lock->lk_stateowner;
+	}
 	nfs4_unlock_state();
 	return status;
 }
@@ -2925,7 +2933,7 @@ out:
 }
 
 int
-nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_locku *locku)
+nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_locku *locku, struct nfs4_stateowner **replay_owner)
 {
 	struct nfs4_stateid *stp;
 	struct file *filp = NULL;
@@ -2981,8 +2989,10 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	memcpy(&locku->lu_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 out:
-	if (locku->lu_stateowner)
+	if (locku->lu_stateowner) {
 		nfs4_get_stateowner(locku->lu_stateowner);
+		*replay_owner = locku->lu_stateowner;
+	}
 	nfs4_unlock_state();
 	return status;
 

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2005-09-12 16:11:48.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2005-09-12 16:11:48.000000000 +1000
@@ -438,17 +438,22 @@ extern int nfsd4_process_open1(struct nf
 extern int nfsd4_process_open2(struct svc_rqst *rqstp, 
 		struct svc_fh *current_fh, struct nfsd4_open *open);
 extern int nfsd4_open_confirm(struct svc_rqst *rqstp, 
-		struct svc_fh *current_fh, struct nfsd4_open_confirm *oc);
+		struct svc_fh *current_fh, struct nfsd4_open_confirm *oc,
+		struct nfs4_stateowner **);
 extern  int nfsd4_close(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
-		struct nfsd4_close *close);
+		struct nfsd4_close *close,
+		struct nfs4_stateowner **replay_owner);
 extern int nfsd4_open_downgrade(struct svc_rqst *rqstp, 
-		struct svc_fh *current_fh, struct nfsd4_open_downgrade *od);
+		struct svc_fh *current_fh, struct nfsd4_open_downgrade *od,
+		struct nfs4_stateowner **replay_owner);
 extern int nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
-		struct nfsd4_lock *lock);
+		struct nfsd4_lock *lock,
+		struct nfs4_stateowner **replay_owner);
 extern int nfsd4_lockt(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
 		struct nfsd4_lockt *lockt);
 extern int nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, 
-		struct nfsd4_locku *locku);
+		struct nfsd4_locku *locku,
+		struct nfs4_stateowner **replay_owner);
 extern int
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		struct nfsd4_release_lockowner *rlockowner);


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
