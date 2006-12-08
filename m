From: NeilBrown <neilb@suse.de>
Subject: [PATCH 011 of 18] knfsd: nfsd4: move replay_owner to cstate
Date: Fri, 8 Dec 2006 12:14:19 +1100
Message-ID: <1061208011419.30689@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJU-0003Df-Ji
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:08 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJU-0001EI-GG
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:09 -0800
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J.Bruce Fields <bfields@fieldses.org>

Tuck away the replay_owner in the cstate while we're at it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c        |   31 ++++++++++++++-----------------
 ./fs/nfsd/nfs4state.c       |   22 ++++++++++------------
 ./include/linux/nfsd/xdr4.h |   17 +++++++----------
 3 files changed, 31 insertions(+), 39 deletions(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-12-08 12:09:27.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-12-08 12:09:27.000000000 +1100
@@ -163,7 +163,7 @@ do_open_fhandle(struct svc_rqst *rqstp, 
 
 static inline __be32
 nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	   struct nfsd4_open *open, struct nfs4_stateowner **replay_owner)
+	   struct nfsd4_open *open)
 {
 	__be32 status;
 	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
@@ -255,7 +255,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 out:
 	if (open->op_stateowner) {
 		nfs4_get_stateowner(open->op_stateowner);
-		*replay_owner = open->op_stateowner;
+		cstate->replay_owner = open->op_stateowner;
 	}
 	nfs4_unlock_state();
 	return status;
@@ -761,6 +761,7 @@ static void cstate_free(struct nfsd4_com
 		return;
 	fh_put(&cstate->current_fh);
 	fh_put(&cstate->save_fh);
+	BUG_ON(cstate->replay_owner);
 	kfree(cstate);
 }
 
@@ -773,6 +774,7 @@ static struct nfsd4_compound_state *csta
 		return NULL;
 	fh_init(&cstate->current_fh, NFS4_FHSIZE);
 	fh_init(&cstate->save_fh, NFS4_FHSIZE);
+	cstate->replay_owner = NULL;
 	return cstate;
 }
 
@@ -786,7 +788,6 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 {
 	struct nfsd4_op	*op;
 	struct nfsd4_compound_state *cstate = NULL;
-	struct nfs4_stateowner *replay_owner = NULL;
 	int		slack_bytes;
 	__be32		status;
 
@@ -876,7 +877,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_CLOSE:
 			op->status = nfsd4_close(rqstp, cstate,
-						 &op->u.close, &replay_owner);
+						 &op->u.close);
 			break;
 		case OP_COMMIT:
 			op->status = nfsd4_commit(rqstp, cstate,
@@ -901,15 +902,13 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			op->status = nfsd4_link(rqstp, cstate, &op->u.link);
 			break;
 		case OP_LOCK:
-			op->status = nfsd4_lock(rqstp, cstate, &op->u.lock,
-						&replay_owner);
+			op->status = nfsd4_lock(rqstp, cstate, &op->u.lock);
 			break;
 		case OP_LOCKT:
 			op->status = nfsd4_lockt(rqstp, cstate, &op->u.lockt);
 			break;
 		case OP_LOCKU:
-			op->status = nfsd4_locku(rqstp, cstate, &op->u.locku,
-						 &replay_owner);
+			op->status = nfsd4_locku(rqstp, cstate, &op->u.locku);
 			break;
 		case OP_LOOKUP:
 			op->status = nfsd4_lookup(rqstp, cstate,
@@ -926,17 +925,15 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_OPEN:
 			op->status = nfsd4_open(rqstp, cstate,
-						&op->u.open, &replay_owner);
+						&op->u.open);
 			break;
 		case OP_OPEN_CONFIRM:
 			op->status = nfsd4_open_confirm(rqstp, cstate,
-							&op->u.open_confirm,
-							&replay_owner);
+							&op->u.open_confirm);
 			break;
 		case OP_OPEN_DOWNGRADE:
 			op->status = nfsd4_open_downgrade(rqstp, cstate,
-							 &op->u.open_downgrade,
-							 &replay_owner);
+							&op->u.open_downgrade);
 			break;
 		case OP_PUTFH:
 			op->status = nfsd4_putfh(rqstp, cstate, &op->u.putfh);
@@ -1001,16 +998,16 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 
 encode_op:
 		if (op->status == nfserr_replay_me) {
-			op->replay = &replay_owner->so_replay;
+			op->replay = &cstate->replay_owner->so_replay;
 			nfsd4_encode_replay(resp, op);
 			status = op->status = op->replay->rp_status;
 		} else {
 			nfsd4_encode_operation(resp, op);
 			status = op->status;
 		}
-		if (replay_owner) {
-			nfs4_put_stateowner(replay_owner);
-			replay_owner = NULL;
+		if (cstate->replay_owner) {
+			nfs4_put_stateowner(cstate->replay_owner);
+			cstate->replay_owner = NULL;
 		}
 		/* XXX Ugh, we need to get rid of this kind of special case: */
 		if (op->opnum == OP_READ && op->u.read.rd_filp)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2006-12-08 12:09:27.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-12-08 12:09:27.000000000 +1100
@@ -2243,8 +2243,7 @@ check_replay:
 
 __be32
 nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		   struct nfsd4_open_confirm *oc,
-		   struct nfs4_stateowner **replay_owner)
+		   struct nfsd4_open_confirm *oc)
 {
 	__be32 status;
 	struct nfs4_stateowner *sop;
@@ -2281,7 +2280,7 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 out:
 	if (oc->oc_stateowner) {
 		nfs4_get_stateowner(oc->oc_stateowner);
-		*replay_owner = oc->oc_stateowner;
+		cstate->replay_owner = oc->oc_stateowner;
 	}
 	nfs4_unlock_state();
 	return status;
@@ -2315,8 +2314,7 @@ reset_union_bmap_deny(unsigned long deny
 __be32
 nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
-		     struct nfsd4_open_downgrade *od,
-		     struct nfs4_stateowner **replay_owner)
+		     struct nfsd4_open_downgrade *od)
 {
 	__be32 status;
 	struct nfs4_stateid *stp;
@@ -2362,7 +2360,7 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 out:
 	if (od->od_stateowner) {
 		nfs4_get_stateowner(od->od_stateowner);
-		*replay_owner = od->od_stateowner;
+		cstate->replay_owner = od->od_stateowner;
 	}
 	nfs4_unlock_state();
 	return status;
@@ -2373,7 +2371,7 @@ out:
  */
 __be32
 nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct nfsd4_close *close, struct nfs4_stateowner **replay_owner)
+	    struct nfsd4_close *close)
 {
 	__be32 status;
 	struct nfs4_stateid *stp;
@@ -2406,7 +2404,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 out:
 	if (close->cl_stateowner) {
 		nfs4_get_stateowner(close->cl_stateowner);
-		*replay_owner = close->cl_stateowner;
+		cstate->replay_owner = close->cl_stateowner;
 	}
 	nfs4_unlock_state();
 	return status;
@@ -2647,7 +2645,7 @@ check_lock_length(u64 offset, u64 length
  */
 __be32
 nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	   struct nfsd4_lock *lock, struct nfs4_stateowner **replay_owner)
+	   struct nfsd4_lock *lock)
 {
 	struct nfs4_stateowner *open_sop = NULL;
 	struct nfs4_stateowner *lock_sop = NULL;
@@ -2797,7 +2795,7 @@ out:
 		release_stateowner(lock_sop);
 	if (lock->lk_replay_owner) {
 		nfs4_get_stateowner(lock->lk_replay_owner);
-		*replay_owner = lock->lk_replay_owner;
+		cstate->replay_owner = lock->lk_replay_owner;
 	}
 	nfs4_unlock_state();
 	return status;
@@ -2889,7 +2887,7 @@ out:
 
 __be32
 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-	    struct nfsd4_locku *locku, struct nfs4_stateowner **replay_owner)
+	    struct nfsd4_locku *locku)
 {
 	struct nfs4_stateid *stp;
 	struct file *filp = NULL;
@@ -2947,7 +2945,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 out:
 	if (locku->lu_stateowner) {
 		nfs4_get_stateowner(locku->lu_stateowner);
-		*replay_owner = locku->lu_stateowner;
+		cstate->replay_owner = locku->lu_stateowner;
 	}
 	nfs4_unlock_state();
 	return status;

diff .prev/include/linux/nfsd/xdr4.h ./include/linux/nfsd/xdr4.h
--- .prev/include/linux/nfsd/xdr4.h	2006-12-08 12:09:27.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2006-12-08 12:09:27.000000000 +1100
@@ -47,6 +47,7 @@
 struct nfsd4_compound_state {
 	struct svc_fh current_fh;
 	struct svc_fh save_fh;
+	struct nfs4_stateowner *replay_owner;
 };
 
 struct nfsd4_change_info {
@@ -442,25 +443,21 @@ extern __be32 nfsd4_process_open1(struct
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
 extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *, struct nfsd4_open_confirm *oc,
-		struct nfs4_stateowner **);
+		struct nfsd4_compound_state *, struct nfsd4_open_confirm *oc);
 extern __be32 nfsd4_close(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
-		struct nfsd4_close *close,
-		struct nfs4_stateowner **replay_owner);
+		struct nfsd4_close *close);
 extern __be32 nfsd4_open_downgrade(struct svc_rqst *rqstp,
-		struct nfsd4_compound_state *, struct nfsd4_open_downgrade *od,
-		struct nfs4_stateowner **replay_owner);
+		struct nfsd4_compound_state *,
+		struct nfsd4_open_downgrade *od);
 extern __be32 nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
-		struct nfsd4_lock *lock,
-		struct nfs4_stateowner **replay_owner);
+		struct nfsd4_lock *lock);
 extern __be32 nfsd4_lockt(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_lockt *lockt);
 extern __be32 nfsd4_locku(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
-		struct nfsd4_locku *locku,
-		struct nfs4_stateowner **replay_owner);
+		struct nfsd4_locku *locku);
 extern __be32
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		struct nfsd4_release_lockowner *rlockowner);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
