From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 016 of 19] nfsd4: clarify close_lru handling
Date: Mon, 04 Jul 2005 11:01:44 +1000
Message-ID: <E1DpFLE-0007H2-8U@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFLk-0001k9-10
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:16 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFLh-0006Ih-5l
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:15 -0700
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


The handling of close_lru in preprocess_stateid_op was a source of some
confusion here recently.  Try to make the logic a little clearer, by renaming
find_openstateowner_id to make its purpose clearer and untangling some
unnecessarily complicated goto's.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   40 ++++++++++++++--------------------------
 1 files changed, 14 insertions(+), 26 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:53.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:53.000000000 +1000
@@ -1988,14 +1988,11 @@ laundromat_main(void *not_used)
 	queue_delayed_work(laundry_wq, &laundromat_work, t*HZ);
 }
 
-/* search ownerid_hashtbl[] and close_lru for stateid owner
- * (stateid->si_stateownerid)
- */
 static struct nfs4_stateowner *
-find_openstateowner_id(u32 st_id, int flags) {
+search_close_lru(u32 st_id, int flags)
+{
 	struct nfs4_stateowner *local = NULL;
 
-	dprintk("NFSD: find_openstateowner_id %d\n", st_id);
 	if (flags & CLOSE_STATE) {
 		list_for_each_entry(local, &close_lru, so_close_lru) {
 			if (local->so_id == st_id)
@@ -2193,13 +2190,19 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 	* We return BAD_STATEID if filehandle doesn't match stateid, 
 	* the confirmed flag is incorrecly set, or the generation 
 	* number is incorrect.  
-	* If there is no entry in the openfile table for this id, 
-	* we can't always return BAD_STATEID;
-	* this might be a retransmitted CLOSE which has arrived after 
-	* the openfile has been released.
 	*/
-	if (!(stp = find_stateid(stateid, flags)))
-		goto no_nfs4_stateid;
+	stp = find_stateid(stateid, flags);
+	if (stp == NULL) {
+		/*
+		 * Also, we should make sure this isn't just the result of
+		 * a replayed close:
+		 */
+		sop = search_close_lru(stateid->si_stateownerid, flags);
+		if (sop == NULL)
+			return nfserr_bad_stateid;
+		*sopp = sop;
+		goto check_replay;
+	}
 
 	status = nfserr_bad_stateid;
 
@@ -2263,21 +2266,6 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 
 out:
 	return status;
-
-no_nfs4_stateid:
-
-	/*
-	* We determine whether this is a bad stateid or a replay, 
-	* starting by trying to look up the stateowner.
-	* If stateowner is not found - stateid is bad.
-	*/
-	if (!(sop = find_openstateowner_id(stateid->si_stateownerid, flags))) {
-		printk("NFSD: preprocess_seqid_op: no stateowner or nfs4_stateid!\n");
-		status = nfserr_bad_stateid;
-		goto out;
-	}
-	*sopp = sop;
-
 check_replay:
 	if (seqid == sop->so_seqid - 1) {
 		printk("NFSD: preprocess_seqid_op: retransmission?\n");


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
