From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 7 - Subject: PATCH - nfsv4 - 1 of 1 idempotent replay cache for OPEN state
Date: Tue, 23 Sep 2003 09:33:14 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A1aB8-0004Dt-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1aBX-0008UE-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 16:33:39 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1aBV-0003hE-Qn
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 16:33:38 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 23 Sep 2003 09:33:27 +1000
To: Linus Torvalds <torvalds@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

this patch implements the idempotent replay cache need for NFSv4 OPEN state. 
each state owner (open owner or lock owner) is required to store the last 
sequence number mutating operation, and retransmit it when replayed sequence 
number is presented for the operation. i've implemented the cache as a static 
buffer of size 112 bytes (NFSD4_REPLAY_ISIZE) which is large enough to hold 
the OPEN, the largest of the sequence mutation operations. this patch 
implements the cache for OPEN, OPEN_CONFIRM, OPEN_DOWNGRADE, and CLOSE. LOCK 
and UNLOCK will be added when byte-range locking is done (soon!).


-->Andy

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |   13 +++++++-
 ./fs/nfsd/nfs4state.c        |   35 ++++++++++++++++-------
 ./fs/nfsd/nfs4xdr.c          |   65 +++++++++++++++++++++++++++++++++----------
 ./include/linux/nfsd/state.h |   22 ++++++++++++++
 ./include/linux/nfsd/xdr4.h  |    2 +
 5 files changed, 111 insertions(+), 26 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-09-23 09:08:07.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-09-23 09:11:39.000000000 +1000
@@ -664,6 +664,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_CLOSE:
 			op->status = nfsd4_close(rqstp, &current_fh, &op->u.close);
+			op->replay = &op->u.close.cl_stateowner->so_replay;
 			break;
 		case OP_COMMIT:
 			op->status = nfsd4_commit(rqstp, &current_fh, &op->u.commit);
@@ -693,12 +694,15 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_OPEN:
 			op->status = nfsd4_open(rqstp, &current_fh, &op->u.open);
+			op->replay = &op->u.open.op_stateowner->so_replay;
 			break;
 		case OP_OPEN_CONFIRM:
 			op->status = nfsd4_open_confirm(rqstp, &current_fh, &op->u.open_confirm);
+			op->replay = &op->u.open_confirm.oc_stateowner->so_replay;
 			break;
 		case OP_OPEN_DOWNGRADE:
 			op->status = nfsd4_open_downgrade(rqstp, &current_fh, &op->u.open_downgrade);
+			op->replay = &op->u.open_downgrade.od_stateowner->so_replay;
 			break;
 		case OP_PUTFH:
 			op->status = nfsd4_putfh(rqstp, &current_fh, &op->u.putfh);
@@ -753,8 +757,13 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		}
 
 encode_op:
-		nfsd4_encode_operation(resp, op);
-		status = op->status;
+		if (op->status == NFSERR_REPLAY_ME) {
+			nfsd4_encode_replay(resp, op);
+			status = op->status = NFS_OK;
+		} else {
+			nfsd4_encode_operation(resp, op);
+			status = op->status;
+		}
 	}
 
 out:

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-09-23 09:08:07.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-09-23 09:11:39.000000000 +1000
@@ -759,6 +759,7 @@ free_stateowner(struct nfs4_stateowner *
 static struct nfs4_stateowner *
 alloc_init_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
 	struct nfs4_stateowner *sop;
+	struct nfs4_replay *rp;
 	unsigned int idhashval;
 
 	if (!(sop = alloc_stateowner(&open->op_owner)))
@@ -776,6 +777,10 @@ alloc_init_stateowner(unsigned int strha
 	sop->so_client = clp;
 	sop->so_seqid = open->op_seqid;
 	sop->so_confirmed = 0;
+	rp = &sop->so_replay;
+	rp->rp_status = NFSERR_SERVERFAULT;
+	rp->rp_buflen = 0;
+	rp->rp_buf = rp->rp_ibuf;
 	alloc_sowner++;
 	return sop;
 }
@@ -1019,9 +1024,22 @@ nfsd4_process_open1(struct nfsd4_open *o
 	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
 	if (find_stateowner_str(strhashval, open, &sop)) {
 		open->op_stateowner = sop;
+		/* check for replay */
 		if (open->op_seqid == sop->so_seqid){
-			/* XXX retplay: for now, return bad seqid */
-			status = nfserr_bad_seqid;
+			if (!sop->so_replay.rp_buflen) {
+			/*
+			* The original OPEN failed in so spectacularly that we
+			* don't even have replay data saved!  Therefore, we
+			* have no choice but to continue processing
+			* this OPEN; presumably, we'll fail again for the same
+			* reason.
+			*/
+				dprintk("nfsd4_process_open1: replay with no replay cache\n");
+				status = NFS_OK;
+				goto renew;
+			}
+			/* replay: indicate to calling function */
+			status = NFSERR_REPLAY_ME;
 			goto out;
 		}
 		if (sop->so_confirmed) {
@@ -1033,9 +1051,8 @@ nfsd4_process_open1(struct nfsd4_open *o
 			goto out;
 		}
 		/* If we get here, we received and OPEN for an unconfirmed
-		 * nfs4_stateowner. If seqid's are the same then this 
-		 * is a replay.
-		 * If the sequid's are different, then purge the 
+		 * nfs4_stateowner. 
+		 * Since the sequid's are different, purge the 
 		 * existing nfs4_stateowner, and instantiate a new one.
 		 */
 		clp = sop->so_client;
@@ -1367,8 +1384,6 @@ out:
 
 /* 
  * Checks for sequence id mutating operations. 
- *
- * XXX need to code replay cache logic
  */
 int
 nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp)
@@ -1466,13 +1481,14 @@ no_nfs4_stateid:
 	}
 
 check_replay:
-	status = nfserr_bad_seqid;
 	if (seqid == sop->so_seqid) {
 		printk("NFSD: preprocess_seqid_op: retransmission?\n");
-		/* XXX will need to indicate replay to calling function here */
+		/* indicate replay to calling function */
+		status = NFSERR_REPLAY_ME;
 	} else 
 		printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d\n", sop->so_seqid +1, seqid);
 
+		status = nfserr_bad_seqid;
 	goto out;
 }
 
@@ -1499,7 +1515,6 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 	sop->so_confirmed = 1;
 	update_stateid(&stp->st_stateid);
 	memcpy(&oc->oc_resp_stateid, &stp->st_stateid, sizeof(stateid_t));
-	/* XXX renew the client lease here */
 	dprintk("NFSD: nfsd4_open_confirm: success, seqid=%d " 
 		"stateid=(%08x/%08x/%08x/%08x)\n", oc->oc_seqid,
 		         stp->st_stateid.si_boot,

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-09-23 09:11:28.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-09-23 09:11:39.000000000 +1000
@@ -932,6 +932,7 @@ nfsd4_decode_compound(struct nfsd4_compo
 
 	for (i = 0; i < argp->opcnt; i++) {
 		op = &argp->ops[i];
+		op->replay = NULL;
 
 		/*
 		 * We can't use READ_BUF() here because we need to handle
@@ -1111,18 +1112,31 @@ nfsd4_decode_compound(struct nfsd4_compo
 #define ADJUST_ARGS()		resp->p = p
 
 /*
+ * Header routine to setup seqid operation replay cache
+ */
+#define ENCODE_SEQID_OP_HEAD					\
+	u32 *p;							\
+	u32 *save;						\
+								\
+	save = resp->p;
+
+/*
  * Routine for encoding the result of a
  * "seqid-mutating" NFSv4 operation.  This is
- * where seqids are incremented
+ * where seqids are incremented, and the
+ * replay cache is filled.
  */
 
-#define ENCODE_SEQID_OP_TAIL(stateowner) do {		\
-	BUG_ON(!stateowner);				\
-	if (seqid_mutating_err(nfserr) && stateowner) {	\
-		if (stateowner->so_confirmed)		\
-			stateowner->so_seqid++;		\
-	}						\
-} while(0)
+#define ENCODE_SEQID_OP_TAIL(stateowner) do {			\
+	if (seqid_mutating_err(nfserr) && stateowner) {		\
+		if (stateowner->so_confirmed)			\
+			stateowner->so_seqid++;			\
+		stateowner->so_replay.rp_status = nfserr;   	\
+		stateowner->so_replay.rp_buflen = 		\
+			  (((char *)(resp)->p - (char *)save)); \
+		memcpy(stateowner->so_replay.rp_buf, save,      \
+ 			stateowner->so_replay.rp_buflen); 	\
+	} } while(0)
 
 
 static u32 nfs4_ftypes[16] = {
@@ -1623,7 +1637,7 @@ nfsd4_encode_access(struct nfsd4_compoun
 static void
 nfsd4_encode_close(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_close *close)
 {
-	ENCODE_HEAD;
+	ENCODE_SEQID_OP_HEAD;
 
 	if (!nfserr) {
 		RESERVE_SPACE(sizeof(stateid_t));
@@ -1631,8 +1645,7 @@ nfsd4_encode_close(struct nfsd4_compound
 		WRITEMEM(&close->cl_stateid.si_opaque, sizeof(stateid_opaque_t));
 		ADJUST_ARGS();
 	}
-	if ((close->cl_stateowner) && (close->cl_stateowner->so_confirmed))
-		close->cl_stateowner->so_seqid++;
+	ENCODE_SEQID_OP_TAIL(close->cl_stateowner);
 }
 
 
@@ -1712,7 +1725,7 @@ nfsd4_encode_link(struct nfsd4_compoundr
 static void
 nfsd4_encode_open(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_open *open)
 {
-	ENCODE_HEAD;
+	ENCODE_SEQID_OP_HEAD;
 
 	if (nfserr)
 		return;
@@ -1776,7 +1789,7 @@ nfsd4_encode_open(struct nfsd4_compoundr
 static void
 nfsd4_encode_open_confirm(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_open_confirm *oc)
 {
-	ENCODE_HEAD;
+	ENCODE_SEQID_OP_HEAD;
 				        
 	if (!nfserr) {
 		RESERVE_SPACE(sizeof(stateid_t));
@@ -1791,7 +1804,7 @@ nfsd4_encode_open_confirm(struct nfsd4_c
 static void
 nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_open_downgrade *od)
 {
-	ENCODE_HEAD;
+	ENCODE_SEQID_OP_HEAD;
 				        
 	if (!nfserr) {
 		RESERVE_SPACE(sizeof(stateid_t));
@@ -2170,6 +2183,30 @@ nfsd4_encode_operation(struct nfsd4_comp
 	*statp = op->status;
 }
 
+/* 
+ * Encode the reply stored in the stateowner reply cache 
+ * 
+ * XDR note: do not encode rp->rp_buflen: the buffer contains the
+ * previously sent already encoded operation.
+ */
+void
+nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
+{
+	ENCODE_HEAD;
+	struct nfs4_replay *rp = op->replay;
+
+	BUG_ON(!rp);
+
+	RESERVE_SPACE(8);
+	WRITE32(op->opnum);
+	WRITE32(NFS_OK);
+	ADJUST_ARGS();
+
+	RESERVE_SPACE(rp->rp_buflen);
+	WRITEMEM(rp->rp_buf, rp->rp_buflen);
+	ADJUST_ARGS();
+}
+
 /*
  * END OF "GENERIC" ENCODE ROUTINES.
  */

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2003-09-23 09:08:07.000000000 +1000
+++ ./include/linux/nfsd/state.h	2003-09-23 09:11:39.000000000 +1000
@@ -95,6 +95,27 @@ update_stateid(stateid_t *stateid)
 	stateid->si_generation++;
 }
 
+/* A reasonable value for REPLAY_ISIZE was estimated as follows:  
+ * The OPEN response, typically the largest, requires 
+ *   4(status) + 8(stateid) + 20(changeinfo) + 4(rflags) +  8(verifier) + 
+ *   4(deleg. type) + 8(deleg. stateid) + 4(deleg. recall flag) + 
+ *   20(deleg. space limit) + ~32(deleg. ace) = 112 bytes 
+ */
+
+#define NFSD4_REPLAY_ISIZE       112 
+
+/*
+ * Replay buffer, where the result of the last seqid-mutating operation 
+ * is cached. 
+ */
+struct nfs4_replay {
+	u32			rp_status;
+	unsigned int		rp_buflen;
+	char			*rp_buf;
+	unsigned		intrp_allocated;
+	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
+};
+
 /*
 * nfs4_stateowner can either be an open_owner, or (eventually) a lock_owner
 *
@@ -111,6 +132,7 @@ struct nfs4_stateowner {
 	u32                     so_seqid;    
 	struct xdr_netobj       so_owner;     /* open owner name */
 	int                     so_confirmed; /* successful OPEN_CONFIRM? */
+	struct nfs4_replay	so_replay;
 };
 
 /*

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2003-09-23 09:08:07.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2003-09-23 09:11:39.000000000 +1000
@@ -284,6 +284,7 @@ struct nfsd4_op {
 		struct nfsd4_verify		verify;
 		struct nfsd4_write		write;
 	} u;
+	struct nfs4_replay *			replay;
 };
 
 struct nfsd4_compoundargs {
@@ -339,6 +340,7 @@ int nfs4svc_decode_compoundargs(struct s
 int nfs4svc_encode_compoundres(struct svc_rqst *, u32 *, 
 		struct nfsd4_compoundres *);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
+void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 int nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		       struct dentry *dentry, u32 *buffer, int *countp, 
 		       u32 *bmval);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
