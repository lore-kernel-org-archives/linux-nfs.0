From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 7 of 18] nfsd4: revert awkward extension of state lock over xdr for replay encoding
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000kG-EY@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7C-000894-W6
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7B-0006BW-Om
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:26 -0700
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



With the addition of a reference count, we no longer need the code that
conditionally extended the nfs4 state lock over the xdr encode stage.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c  |    5 +----
 ./fs/nfsd/nfs4state.c |   25 ++++++-------------------
 ./fs/nfsd/nfs4xdr.c   |   23 ++++++++---------------
 3 files changed, 15 insertions(+), 38 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-09-24 14:48:38.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-09-24 14:48:38.000000000 +1000
@@ -161,9 +161,6 @@ do_open_fhandle(struct svc_rqst *rqstp, 
 }
 
 
-/*
- * nfs4_unlock_state() called in encode
- */
 static inline int
 nfsd4_open(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
@@ -182,7 +179,6 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
-	open->op_stateowner = NULL;
 	nfs4_lock_state();
 
 	/* check seqid for replay. set nfs4_owner */
@@ -236,6 +232,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 out:
 	if (open->op_stateowner)
 		nfs4_get_stateowner(open->op_stateowner);
+	nfs4_unlock_state();
 	return status;
 }
 

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:38.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:38.000000000 +1000
@@ -93,9 +93,6 @@ nfs4_lock_state(void)
 	down(&client_sema);
 }
 
-/*
- * nfs4_unlock_state(); called in encode
- */
 void
 nfs4_unlock_state(void)
 {
@@ -1710,9 +1707,6 @@ first_state(struct nfs4_client *clp)
 		clp->cl_first_state = get_seconds();
 }
 
-/*
- * nfs4_unlock_state(); called in encode
- */
 int
 nfsd4_open_confirm(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_confirm *oc)
 {
@@ -1727,7 +1721,6 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 	if ((status = fh_verify(rqstp, current_fh, S_IFREG, 0)))
 		goto out;
 
-	oc->oc_stateowner = NULL;
 	nfs4_lock_state();
 
 	if ((status = nfs4_preprocess_seqid_op(current_fh, oc->oc_seqid,
@@ -1751,6 +1744,7 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 out:
 	if (oc->oc_stateowner)
 		nfs4_get_stateowner(oc->oc_stateowner);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -1779,10 +1773,6 @@ reset_union_bmap_deny(unsigned long deny
 	}
 }
 
-/*
- * nfs4_unlock_state(); called in encode
- */
-
 int
 nfsd4_open_downgrade(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open_downgrade *od)
 {
@@ -1794,10 +1784,8 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
-	od->od_stateowner = NULL;
-	status = nfserr_inval;
 	if (!TEST_ACCESS(od->od_share_access) || !TEST_DENY(od->od_share_deny))
-		goto out;
+		return nfserr_inval;
 
 	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(current_fh, od->od_seqid, 
@@ -1830,6 +1818,7 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 out:
 	if (od->od_stateowner)
 		nfs4_get_stateowner(od->od_stateowner);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -1846,7 +1835,6 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
-	close->cl_stateowner = NULL;
 	nfs4_lock_state();
 	/* check close_lru for replay */
 	if ((status = nfs4_preprocess_seqid_op(current_fh, close->cl_seqid, 
@@ -1866,6 +1854,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 out:
 	if (close->cl_stateowner)
 		nfs4_get_stateowner(close->cl_stateowner);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -2084,8 +2073,6 @@ check_lock_length(u64 offset, u64 length
 
 /*
  *  LOCK operation 
- *
- * nfs4_unlock_state(); called in encode
  */
 int
 nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock *lock)
@@ -2110,7 +2097,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	if (check_lock_length(lock->lk_offset, lock->lk_length))
 		 return nfserr_inval;
 
-	lock->lk_stateowner = NULL;
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
@@ -2267,6 +2253,7 @@ out_destroy_new_stateid:
 out:
 	if (lock->lk_stateowner)
 		nfs4_get_stateowner(lock->lk_stateowner);
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -2375,7 +2362,6 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	if (check_lock_length(locku->lu_offset, locku->lu_length))
 		 return nfserr_inval;
 
-	locku->lu_stateowner = NULL;
 	nfs4_lock_state();
 									        
 	if ((status = nfs4_preprocess_seqid_op(current_fh, 
@@ -2420,6 +2406,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 out:
 	if (locku->lu_stateowner)
 		nfs4_get_stateowner(locku->lu_stateowner);
+	nfs4_unlock_state();
 	return status;
 
 out_nfserr:

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-09-24 14:47:18.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-09-24 14:48:38.000000000 +1000
@@ -545,14 +545,12 @@ nfsd4_decode_access(struct nfsd4_compoun
 	DECODE_TAIL;
 }
 
-#define NFS4_STATE_NOT_LOCKED	((void *)-1)
-
 static int
 nfsd4_decode_close(struct nfsd4_compoundargs *argp, struct nfsd4_close *close)
 {
 	DECODE_HEAD;
 
-	close->cl_stateowner = NFS4_STATE_NOT_LOCKED;
+	close->cl_stateowner = NULL;
 	READ_BUF(4 + sizeof(stateid_t));
 	READ32(close->cl_seqid);
 	READ32(close->cl_stateid.si_generation);
@@ -642,7 +640,7 @@ nfsd4_decode_lock(struct nfsd4_compounda
 {
 	DECODE_HEAD;
 
-	lock->lk_stateowner = NFS4_STATE_NOT_LOCKED;
+	lock->lk_stateowner = NULL;
 	/*
 	* type, reclaim(boolean), offset, length, new_lock_owner(boolean)
 	*/
@@ -700,7 +698,7 @@ nfsd4_decode_locku(struct nfsd4_compound
 {
 	DECODE_HEAD;
 
-	locku->lu_stateowner = NFS4_STATE_NOT_LOCKED;
+	locku->lu_stateowner = NULL;
 	READ_BUF(24 + sizeof(stateid_t));
 	READ32(locku->lu_type);
 	if ((locku->lu_type < NFS4_READ_LT) || (locku->lu_type > NFS4_WRITEW_LT))
@@ -736,7 +734,7 @@ nfsd4_decode_open(struct nfsd4_compounda
 
 	memset(open->op_bmval, 0, sizeof(open->op_bmval));
 	open->op_iattr.ia_valid = 0;
-	open->op_stateowner = NFS4_STATE_NOT_LOCKED;
+	open->op_stateowner = NULL;
 
 	/* seqid, share_access, share_deny, clientid, ownerlen */
 	READ_BUF(16 + sizeof(clientid_t));
@@ -812,7 +810,7 @@ nfsd4_decode_open_confirm(struct nfsd4_c
 {
 	DECODE_HEAD;
 		    
-	open_conf->oc_stateowner = NFS4_STATE_NOT_LOCKED;
+	open_conf->oc_stateowner = NULL;
 	READ_BUF(4 + sizeof(stateid_t));
 	READ32(open_conf->oc_req_stateid.si_generation);
 	COPYMEM(&open_conf->oc_req_stateid.si_opaque, sizeof(stateid_opaque_t));
@@ -826,7 +824,7 @@ nfsd4_decode_open_downgrade(struct nfsd4
 {
 	DECODE_HEAD;
 		    
-	open_down->od_stateowner = NFS4_STATE_NOT_LOCKED;
+	open_down->od_stateowner = NULL;
 	READ_BUF(4 + sizeof(stateid_t));
 	READ32(open_down->od_stateid.si_generation);
 	COPYMEM(&open_down->od_stateid.si_opaque, sizeof(stateid_opaque_t));
@@ -1327,8 +1325,7 @@ nfsd4_decode_compound(struct nfsd4_compo
  */
 
 #define ENCODE_SEQID_OP_TAIL(stateowner) do {			\
-	if (seqid_mutating_err(nfserr) && stateowner		\
-	    && (stateowner != NFS4_STATE_NOT_LOCKED)) { 	\
+	if (seqid_mutating_err(nfserr) && stateowner) { 	\
 		if (stateowner->so_confirmed)			\
 			stateowner->so_seqid++;			\
 		stateowner->so_replay.rp_status = nfserr;   	\
@@ -1336,10 +1333,7 @@ nfsd4_decode_compound(struct nfsd4_compo
 			  (((char *)(resp)->p - (char *)save)); \
 		memcpy(stateowner->so_replay.rp_buf, save,      \
  			stateowner->so_replay.rp_buflen); 	\
-	}							\
-	if (stateowner != NFS4_STATE_NOT_LOCKED)		\
-		nfs4_unlock_state();				\
-	} while (0);
+	} } while (0);
 
 
 static u32 nfs4_ftypes[16] = {
@@ -2573,7 +2567,6 @@ nfsd4_encode_replay(struct nfsd4_compoun
 	RESERVE_SPACE(rp->rp_buflen);
 	WRITEMEM(rp->rp_buf, rp->rp_buflen);
 	ADJUST_ARGS();
-	nfs4_unlock_state();
 }
 
 /*


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
