From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 010 of 19] nfsd4: fix open_reclaim seqid
Date: Mon, 04 Jul 2005 11:01:43 +1000
Message-ID: <E1DpFLD-0007Ge-S7@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM9-0001lN-0B
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:41 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DpFM8-000714-Fm
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:41 -0700
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


The sequence number we store in the sequence id is the last one we received
from the client.  So on the next operation we'll check that the client gives us
the next higher number.

We increment sequence id's at the last moment, in encode, so that we're sure of
knowing the right error return.  (The decision to increment the sequence id
depends on the exact error returned.)

However on the *first* use of a sequence number, if we set the sequence number
to the one received from the client and then let the increment happen on
encode, we'll be left with a sequence number one to high.

For that reason, ENCODE_SEQID_OP_TAIL only increments the sequence id on
*confirmed* stateowners.

This creates a problem for open reclaims, which are confirmed on first use.
Therefore the open reclaim code, as a special exception, *decrements* the
sequence id, cancelling out the undesired increment on encode.  But this
prevents the sequence id from ever being incremented in the case where multiple
reclaims are sent with the same openowner.  Yuch!

We could add another exception to the open reclaim code, decrementing the
sequence id only if this is the first use of the open owner.

But it's simpler by far to modify the meaning of the op_seqid field: instead of
representing the previous value sent by the client, we take op_seqid, after
encoding, to represent the *next* sequence id that we expect from the client.
This eliminates the need for special-case handling of the first use of a
stateowner.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   15 ++++++---------
 ./fs/nfsd/nfs4xdr.c   |    3 +--
 2 files changed, 7 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:52.000000000 +1000
@@ -1483,7 +1483,7 @@ nfsd4_process_open1(struct nfsd4_open *o
 	if (sop) {
 		open->op_stateowner = sop;
 		/* check for replay */
-		if (open->op_seqid == sop->so_seqid){
+		if (open->op_seqid == sop->so_seqid - 1){
 			if (sop->so_replay.rp_buflen)
 				return NFSERR_REPLAY_ME;
 			else {
@@ -1498,7 +1498,7 @@ nfsd4_process_open1(struct nfsd4_open *o
 				goto renew;
 			}
 		} else if (sop->so_confirmed) {
-			if (open->op_seqid == sop->so_seqid + 1)
+			if (open->op_seqid == sop->so_seqid)
 				goto renew;
 			status = nfserr_bad_seqid;
 			goto out;
@@ -1684,13 +1684,11 @@ nfs4_upgrade_open(struct svc_rqst *rqstp
 }
 
 
-/* decrement seqid on successful reclaim, it will be bumped in encode_open */
 static void
 nfs4_set_claim_prev(struct nfsd4_open *open)
 {
 	open->op_stateowner->so_confirmed = 1;
 	open->op_stateowner->so_client->cl_firststate = 1;
-	open->op_stateowner->so_seqid--;
 }
 
 /*
@@ -2234,7 +2232,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 	*  For the moment, we ignore the possibility of 
 	*  generation number wraparound.
 	*/
-	if (seqid != sop->so_seqid + 1)
+	if (seqid != sop->so_seqid)
 		goto check_replay;
 
 	if (sop->so_confirmed) {
@@ -2280,12 +2278,12 @@ no_nfs4_stateid:
 	*sopp = sop;
 
 check_replay:
-	if (seqid == sop->so_seqid) {
+	if (seqid == sop->so_seqid - 1) {
 		printk("NFSD: preprocess_seqid_op: retransmission?\n");
 		/* indicate replay to calling function */
 		status = NFSERR_REPLAY_ME;
 	} else  {
-		printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d\n", sop->so_seqid +1, seqid);
+		printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d\n", sop->so_seqid, seqid);
 
 		*sopp = NULL;
 		status = nfserr_bad_seqid;
@@ -2608,7 +2606,6 @@ find_lockstateowner_str(struct inode *in
  * occured. 
  *
  * strhashval = lock_ownerstr_hashval 
- * so_seqid = lock->lk_new_lock_seqid - 1: it gets bumped in encode 
  */
 
 static struct nfs4_stateowner *
@@ -2633,7 +2630,7 @@ alloc_init_lock_stateowner(unsigned int 
 	sop->so_is_open_owner = 0;
 	sop->so_id = current_ownerid++;
 	sop->so_client = clp;
-	sop->so_seqid = lock->lk_new_lock_seqid - 1;
+	sop->so_seqid = lock->lk_new_lock_seqid;
 	sop->so_confirmed = 1;
 	rp = &sop->so_replay;
 	rp->rp_status = NFSERR_SERVERFAULT;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2005-07-04 10:57:52.000000000 +1000
@@ -1218,8 +1218,7 @@ nfsd4_decode_compound(struct nfsd4_compo
 
 #define ENCODE_SEQID_OP_TAIL(stateowner) do {			\
 	if (seqid_mutating_err(nfserr) && stateowner) { 	\
-		if (stateowner->so_confirmed)			\
-			stateowner->so_seqid++;			\
+		stateowner->so_seqid++;				\
 		stateowner->so_replay.rp_status = nfserr;   	\
 		stateowner->so_replay.rp_buflen = 		\
 			  (((char *)(resp)->p - (char *)save)); \


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
