From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 8 of 10 - Improve how locking copes with replays
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001Qz-Lw@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCZ-0007ng-56
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:31 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCV-00025Q-9L
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:27 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:21 +1000
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


From: "J. Bruce Fields" <bfields@fieldses.org>

>From Andros: Hold state_lock longer so the stateowner doesn't diseappear out
from under us before we get the chance to encode the replay.  Don't attempt to
save replay if we failed to find a stateowner.


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c  |   35 +++++++++++++++++++++++++++--------
 ./fs/nfsd/nfs4state.c |   35 ++++++++++++++++++++++++-----------
 ./fs/nfsd/nfs4xdr.c   |   33 +++++++++++++++++++++------------
 3 files changed, 72 insertions(+), 31 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-04-08 10:56:52.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-04-08 10:57:00.000000000 +1000
@@ -113,17 +113,24 @@ do_open_lookup(struct svc_rqst *rqstp, s
 	return status;
 }
 
+/*
+ * nfs4_unlock_state() called in encode
+ */
 static inline int
 nfsd4_open(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
 	int status;
-	dprintk("NFSD: nfsd4_open filename %.*s\n",
-		(int)open->op_fname.len, open->op_fname.data);
+	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
+		(int)open->op_fname.len, open->op_fname.data,
+		open->op_stateowner);
 
 	/* This check required by spec. */
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
+	open->op_stateowner = NULL;
+	nfs4_lock_state();
+
 	/* check seqid for replay. set nfs4_owner */
 	status = nfsd4_process_open1(open);
 	if (status == NFSERR_REPLAY_ME) {
@@ -763,7 +770,9 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_CLOSE:
 			op->status = nfsd4_close(rqstp, &current_fh, &op->u.close);
-			op->replay = &op->u.close.cl_stateowner->so_replay;
+			if (op->u.close.cl_stateowner)
+				op->replay = 
+					&op->u.close.cl_stateowner->so_replay;
 			break;
 		case OP_COMMIT:
 			op->status = nfsd4_commit(rqstp, &current_fh, &op->u.commit);
@@ -782,14 +791,18 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_LOCK:
 			op->status = nfsd4_lock(rqstp, &current_fh, &op->u.lock);
-			op->replay = &op->u.lock.lk_stateowner->so_replay;
+			if (op->u.lock.lk_stateowner)
+				op->replay = 
+					&op->u.lock.lk_stateowner->so_replay;
 			break;
 		case OP_LOCKT:
 			op->status = nfsd4_lockt(rqstp, &current_fh, &op->u.lockt);
 			break;
 		case OP_LOCKU:
 			op->status = nfsd4_locku(rqstp, &current_fh, &op->u.locku);
-			op->replay = &op->u.locku.lu_stateowner->so_replay;
+			if (op->u.locku.lu_stateowner)
+				op->replay = 
+					&op->u.locku.lu_stateowner->so_replay;
 			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_lookup(rqstp, &current_fh, &op->u.lookup);
@@ -804,15 +817,21 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_OPEN:
 			op->status = nfsd4_open(rqstp, &current_fh, &op->u.open);
-			op->replay = &op->u.open.op_stateowner->so_replay;
+			if (op->u.open.op_stateowner)
+				op->replay = 
+					&op->u.open.op_stateowner->so_replay;
 			break;
 		case OP_OPEN_CONFIRM:
 			op->status = nfsd4_open_confirm(rqstp, &current_fh, &op->u.open_confirm);
-			op->replay = &op->u.open_confirm.oc_stateowner->so_replay;
+			if (op->u.open_confirm.oc_stateowner)
+				op->replay = 
+					&op->u.open_confirm.oc_stateowner->so_replay;
 			break;
 		case OP_OPEN_DOWNGRADE:
 			op->status = nfsd4_open_downgrade(rqstp, &current_fh, &op->u.open_downgrade);
-			op->replay = &op->u.open_downgrade.od_stateowner->so_replay;
+			if (op->u.open_downgrade.od_stateowner)
+				op->replay = 
+					&op->u.open_downgrade.od_stateowner->so_replay;
 			break;
 		case OP_PUTFH:
 			op->status = nfsd4_putfh(rqstp, &current_fh, &op->u.putfh);

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-04-08 10:56:23.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-04-08 10:57:00.000000000 +1000
@@ -89,6 +89,9 @@ nfs4_lock_state(void)
 	down(&client_sema);
 }
 
+/*
+ * nfs4_unlock_state(); called in encode
+ */
 void
 nfs4_unlock_state(void)
 {
@@ -1083,6 +1086,8 @@ nfs4_file_downgrade(struct file *filp, u
  * 		notfound:
  * 			verify clientid
  * 			create new owner
+ *
+ * called with nfs4_lock_state() held.
  */
 int
 nfsd4_process_open1(struct nfsd4_open *open)
@@ -1101,7 +1106,6 @@ nfsd4_process_open1(struct nfsd4_open *o
 	if (STALE_CLIENTID(&open->op_clientid))
 		goto out;
 
-	nfs4_lock_state();
 	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
 	if (find_openstateowner_str(strhashval, open, &sop)) {
 		open->op_stateowner = sop;
@@ -1159,10 +1163,11 @@ instantiate_new_owner:
 renew:
 	renew_client(sop->so_client);
 out:
-	nfs4_unlock_state();
 	return status;
 }
-
+/*
+ * called with nfs4_lock_state() held.
+ */
 int
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
@@ -1185,7 +1190,6 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
 		goto out;
 
-	nfs4_lock_state();
 	fi_hashval = file_hashval(ino);
 	if (find_file(fi_hashval, ino, &fp)) {
 		/* Search for conflicting share reservations */
@@ -1277,7 +1281,6 @@ out:
 	if (!open->op_stateowner->so_confirmed)
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 
-	nfs4_unlock_state();
 	return status;
 out_free:
 	kfree(stp);
@@ -1598,11 +1601,15 @@ check_replay:
 	} else  {
 		printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d\n", sop->so_seqid +1, seqid);
 
+		*sopp = NULL;
 		status = nfserr_bad_seqid;
 	}
 	goto out;
 }
 
+/*
+ * nfs4_unlock_state(); called in encode
+ */
 int
 nfsd4_open_confirm(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_confirm *oc)
 {
@@ -1638,7 +1645,6 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 		         stp->st_stateid.si_generation);
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -1667,6 +1673,9 @@ reset_union_bmap_deny(unsigned long deny
 	}
 }
 
+/* 
+ * nfs4_unlock_state(); called in encode
+ */
 
 int
 nfsd4_open_downgrade(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_downgrade *od)
@@ -1679,6 +1688,7 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
+	od->od_stateowner = NULL;
 	status = nfserr_inval;
 	if (!TEST_ACCESS(od->od_share_access) || !TEST_DENY(od->od_share_deny))
 		goto out;
@@ -1712,10 +1722,12 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
+/* 
+ * nfs4_unlock_state() called after encode
+ */
 int
 nfsd4_close(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_close *close)
 {
@@ -1726,6 +1738,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
+	close->cl_stateowner = NULL;
 	nfs4_lock_state();
 	/* check close_lru for replay */
 	if ((status = nfs4_preprocess_seqid_op(current_fh, close->cl_seqid, 
@@ -1743,7 +1756,6 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	/* release_state_owner() calls nfsd_close() if needed */
 	release_state_owner(stp, &close->cl_stateowner, OPEN_STATE);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -1953,6 +1965,8 @@ check_lock_length(u64 offset, u64 length
 
 /*
  *  LOCK operation 
+ *  
+ * nfs4_unlock_state(); called in encode
  */
 int
 nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock *lock)
@@ -2117,7 +2131,6 @@ out_destroy_new_stateid:
 		release_state_owner(lock_stp, &lock->lk_stateowner, LOCK_STATE);
 	}
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -2212,7 +2225,7 @@ out:
 	nfs4_unlock_state();
 	return status;
 }
-
+	
 int
 nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_locku *locku)
 {
@@ -2228,6 +2241,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	if (check_lock_length(locku->lu_offset, locku->lu_length))
 		 return nfserr_inval;
 
+	locku->lu_stateowner = NULL;
 	nfs4_lock_state();
 									        
 	if ((status = nfs4_preprocess_seqid_op(current_fh, 
@@ -2270,7 +2284,6 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	memcpy(&locku->lu_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 out:
-	nfs4_unlock_state();
 	return status;
 
 out_nfserr:

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-04-08 10:56:00.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-04-08 10:57:00.000000000 +1000
@@ -484,11 +484,14 @@ nfsd4_decode_access(struct nfsd4_compoun
 	DECODE_TAIL;
 }
 
+#define NFS4_STATE_NOT_LOCKED	((void *)-1)
+
 static int
 nfsd4_decode_close(struct nfsd4_compoundargs *argp, struct nfsd4_close *close)
 {
 	DECODE_HEAD;
 
+	close->cl_stateowner = NFS4_STATE_NOT_LOCKED;
 	READ_BUF(4 + sizeof(stateid_t));
 	READ32(close->cl_seqid);
 	READ32(close->cl_stateid.si_generation);
@@ -579,6 +582,7 @@ nfsd4_decode_lock(struct nfsd4_compounda
 {
 	DECODE_HEAD;
 
+	lock->lk_stateowner = NFS4_STATE_NOT_LOCKED;
 	/*
 	* type, reclaim(boolean), offset, length, new_lock_owner(boolean)
 	*/
@@ -636,6 +640,7 @@ nfsd4_decode_locku(struct nfsd4_compound
 {
 	DECODE_HEAD;
 
+	locku->lu_stateowner = NFS4_STATE_NOT_LOCKED;
 	READ_BUF(24 + sizeof(stateid_t));
 	READ32(locku->lu_type);
 	if ((locku->lu_type < NFS4_READ_LT) || (locku->lu_type > NFS4_WRITEW_LT))
@@ -671,6 +676,7 @@ nfsd4_decode_open(struct nfsd4_compounda
 
 	memset(open->op_bmval, 0, sizeof(open->op_bmval));
 	open->op_iattr.ia_valid = 0;
+	open->op_stateowner = NFS4_STATE_NOT_LOCKED;
 
 	/* seqid, share_access, share_deny, clientid, ownerlen */
 	READ_BUF(16 + sizeof(clientid_t));
@@ -746,6 +752,7 @@ nfsd4_decode_open_confirm(struct nfsd4_c
 {
 	DECODE_HEAD;
 		    
+	open_conf->oc_stateowner = NFS4_STATE_NOT_LOCKED;
 	READ_BUF(4 + sizeof(stateid_t));
 	READ32(open_conf->oc_req_stateid.si_generation);
 	COPYMEM(&open_conf->oc_req_stateid.si_opaque, sizeof(stateid_opaque_t));
@@ -759,6 +766,7 @@ nfsd4_decode_open_downgrade(struct nfsd4
 {
 	DECODE_HEAD;
 		    
+	open_down->od_stateowner = NFS4_STATE_NOT_LOCKED;
 	READ_BUF(4 + sizeof(stateid_t));
 	READ32(open_down->od_stateid.si_generation);
 	COPYMEM(&open_down->od_stateid.si_opaque, sizeof(stateid_opaque_t));
@@ -1259,7 +1267,8 @@ nfsd4_decode_compound(struct nfsd4_compo
  */
 
 #define ENCODE_SEQID_OP_TAIL(stateowner) do {			\
-	if (seqid_mutating_err(nfserr) && stateowner) {		\
+	if (seqid_mutating_err(nfserr) && stateowner		\
+	    && (stateowner != NFS4_STATE_NOT_LOCKED)) { 	\
 		if (stateowner->so_confirmed)			\
 			stateowner->so_seqid++;			\
 		stateowner->so_replay.rp_status = nfserr;   	\
@@ -1267,7 +1276,10 @@ nfsd4_decode_compound(struct nfsd4_compo
 			  (((char *)(resp)->p - (char *)save)); \
 		memcpy(stateowner->so_replay.rp_buf, save,      \
  			stateowner->so_replay.rp_buflen); 	\
-	} } while(0)
+	}							\
+	if (stateowner != NFS4_STATE_NOT_LOCKED)		\
+		nfs4_unlock_state();				\
+	} while (0);
 
 
 static u32 nfs4_ftypes[16] = {
@@ -1917,7 +1929,7 @@ nfsd4_encode_open(struct nfsd4_compoundr
 	ENCODE_SEQID_OP_HEAD;
 
 	if (nfserr)
-		return;
+		goto out;
 
 	RESERVE_SPACE(36 + sizeof(stateid_t));
 	WRITE32(open->op_stateid.si_generation);
@@ -1972,7 +1984,7 @@ nfsd4_encode_open(struct nfsd4_compoundr
 		BUG();
 	}
 	/* XXX save filehandle here */
-
+out:
 	ENCODE_SEQID_OP_TAIL(open->op_stateowner);
 }
 
@@ -2297,14 +2309,8 @@ nfsd4_encode_operation(struct nfsd4_comp
 
 	RESERVE_SPACE(8);
 	WRITE32(op->opnum);
-	if ((op->opnum != OP_SETATTR) && (op->opnum != OP_LOCK) && (op->opnum != OP_LOCKT) && (op->opnum != OP_SETCLIENTID) && (op->status)) {
-		*p++ = op->status;
-		ADJUST_ARGS();
-		return;
-	} else {
-		statp = p++;        /* to be backfilled at the end */
-		ADJUST_ARGS();
-	}
+	statp = p++;	/* to be backfilled at the end */
+	ADJUST_ARGS();
 
 	switch (op->opnum) {
 	case OP_ACCESS:
@@ -2408,6 +2414,8 @@ nfsd4_encode_operation(struct nfsd4_comp
  * 
  * XDR note: do not encode rp->rp_buflen: the buffer contains the
  * previously sent already encoded operation.
+ *
+ * called with nfs4_lock_state() held
  */
 void
 nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
@@ -2425,6 +2433,7 @@ nfsd4_encode_replay(struct nfsd4_compoun
 	RESERVE_SPACE(rp->rp_buflen);
 	WRITEMEM(rp->rp_buf, rp->rp_buflen);
 	ADJUST_ARGS();
+	nfs4_unlock_state();
 }
 
 /*


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
