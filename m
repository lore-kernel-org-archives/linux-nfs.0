From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 007 of 26] nfsd4: remove release_state_owner()
Date: Fri, 13 Jan 2006 12:00:54 +1100
Message-ID: <1060113010054.23010@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJN-0002Xy-Fq
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:01 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJN-0004p9-1V
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:01 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.16] == smtp-dist-01.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:58 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:55 +1100
To: nfs@lists.sourceforge.net
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


It's confusing having both release_stateowner() and release_state_owner().  And
as it turns out, release_state_owner() is short and only called from one place;
so just remove it.

Also note the confirmed check is superfluous there--preprocess_seqid_op
already check this.

And remove a redundant comment and a superfluous line assignment while we're at
it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:05.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:05.000000000 +1100
@@ -1178,7 +1178,6 @@ release_stateid(struct nfs4_stateid *stp
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
 	put_nfs4_file(stp->st_file);
 	kmem_cache_free(stateid_slab, stp);
-	stp = NULL;
 }
 
 static void
@@ -1191,22 +1190,6 @@ move_to_close_lru(struct nfs4_stateowner
 	sop->so_time = get_seconds();
 }
 
-static void
-release_state_owner(struct nfs4_stateid *stp, int flag)
-{
-	struct nfs4_stateowner *sop = stp->st_stateowner;
-
-	dprintk("NFSD: release_state_owner\n");
-	release_stateid(stp, flag);
-
-	/* place unused nfs4_stateowners on so_close_lru list to be
-	 * released by the laundromat service after the lease period
-	 * to enable us to handle CLOSE replay
-	 */
-	if (sop->so_confirmed && list_empty(&sop->so_stateids))
-		move_to_close_lru(sop);
-}
-
 static int
 cmp_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner, clientid_t *clid) {
 	return ((sop->so_owner.len == owner->len) && 
@@ -2423,15 +2406,19 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 					CHECK_FH | OPEN_STATE | CLOSE_STATE,
 					&close->cl_stateowner, &stp, NULL)))
 		goto out; 
-	/*
-	*  Return success, but first update the stateid.
-	*/
 	status = nfs_ok;
 	update_stateid(&stp->st_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));
 
-	/* release_state_owner() calls nfsd_close() if needed */
-	release_state_owner(stp, OPEN_STATE);
+	/* release_stateid() calls nfsd_close() if needed */
+	release_stateid(stp, OPEN_STATE);
+
+	/* place unused nfs4_stateowners on so_close_lru list to be
+	 * released by the laundromat service after the lease period
+	 * to enable us to handle CLOSE replay
+	 */
+	if (list_empty(&close->cl_stateowner->so_stateids))
+		move_to_close_lru(close->cl_stateowner);
 out:
 	if (close->cl_stateowner) {
 		nfs4_get_stateowner(close->cl_stateowner);


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
