From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 22 of 23] Add to the laundromat service for delegations.
Date: Fri, 17 Dec 2004 16:23:57 +1100
Message-ID: <E1CfAar-0002em-H2@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAc4-0005Bd-3y
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:12 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAby-0004GI-OP
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:12 -0800
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


Walk the recall_lru and reap unused or timed-out delegations.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:51.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:51.000000000 +1100
@@ -1844,14 +1844,15 @@ nfs4_laundromat(void)
 {
 	struct nfs4_client *clp;
 	struct nfs4_stateowner *sop;
+	struct nfs4_delegation *dp;
 	struct list_head *pos, *next;
 	time_t cutoff = get_seconds() - NFSD_LEASE_TIME;
 	time_t t, clientid_val = NFSD_LEASE_TIME;
-	time_t u, close_val = NFSD_LEASE_TIME;
+	time_t u, test_val = NFSD_LEASE_TIME;
 
 	nfs4_lock_state();
 
-	dprintk("NFSD: laundromat service - starting, examining clients\n");
+	dprintk("NFSD: laundromat service - starting\n");
 	list_for_each_safe(pos, next, &client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
@@ -1864,12 +1865,30 @@ nfs4_laundromat(void)
 			clp->cl_clientid.cl_id);
 		expire_client(clp);
 	}
+	spin_lock(&recall_lock);
+	list_for_each_safe(pos, next, &del_recall_lru) {
+		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
+		if (atomic_read(&dp->dl_state) == NFS4_RECALL_COMPLETE)
+			goto reap;
+		if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
+			u = dp->dl_time - cutoff;
+			if (test_val > u)
+				test_val = u;
+			break;
+		}
+reap:
+		dprintk("NFSD: purging unused delegation dp %p, fp %p\n",
+			            dp, dp->dl_flock);
+		release_delegation(dp);
+	}
+	spin_unlock(&recall_lock);
+	test_val = NFSD_LEASE_TIME;
 	list_for_each_safe(pos, next, &close_lru) {
 		sop = list_entry(pos, struct nfs4_stateowner, so_close_lru);
 		if (time_after((unsigned long)sop->so_time, (unsigned long)cutoff)) {
 			u = sop->so_time - cutoff;
-			if (close_val > u)
-				close_val = u;
+			if (test_val > u)
+				test_val = u;
 			break;
 		}
 		dprintk("NFSD: purging unused open stateowner (so_id %d)\n",


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
