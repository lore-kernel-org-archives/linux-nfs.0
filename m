From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 009 of 19] nfsd4: comment indentation
Date: Mon, 04 Jul 2005 11:01:43 +1000
Message-ID: <E1DpFLD-0007Ga-QX@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM7-0001ku-M6
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:39 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFM6-0007Zo-Uc
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


Yeah, it's trivial, but this drives me up the wall....

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:52.000000000 +1000
@@ -2704,11 +2704,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
-	/*
-	 * Client indicates that this is a new lockowner.
-	 * Use open owner and open stateid to create lock owner and lock 
-	 * stateid.
-	 */
+		/*
+		 * Client indicates that this is a new lockowner.
+		 * Use open owner and open stateid to create lock owner and
+		 * lock stateid.
+		 */
 		struct nfs4_stateid *open_stp = NULL;
 		struct nfs4_file *fp;
 		
@@ -2842,10 +2842,10 @@ conflicting_lock:
 out_destroy_new_stateid:
 	if (lock->lk_is_new) {
 		dprintk("NFSD: nfsd4_lock: destroy new stateid!\n");
-	/*
-	* An error encountered after instantiation of the new
-	* stateid has forced us to destroy it.
-	*/
+		/*
+		 * An error encountered after instantiation of the new
+		 * stateid has forced us to destroy it.
+		 */
 		if (!seqid_mutating_err(status))
 			open_sop->so_seqid--;
 


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
