From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 39 of 54] nfsd4: fix laundromat delegation reaping
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00019L-QK@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xru-00028I-I3
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:58 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrq-0007tj-Lq
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:58 -0800
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



The laundromat is freeing any delegation it finds in the RECALL_COMPLETE state.
But note that RECALL_COMPLETE is the state that the delegation recall callback
leaves the state in.  We shouldn't actually be giving up on the delegation till
either the client has had a chance to call delegreturn, or the lease time has
run out.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    3 ---
 1 files changed, 3 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:26:43.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:27:24.000000000 +1100
@@ -1861,15 +1861,12 @@ nfs4_laundromat(void)
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		if (atomic_read(&dp->dl_state) == NFS4_RECALL_COMPLETE)
-			goto reap;
 		if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
 			u = dp->dl_time - cutoff;
 			if (test_val > u)
 				test_val = u;
 			break;
 		}
-reap:
 		dprintk("NFSD: purging unused delegation dp %p, fp %p\n",
 			            dp, dp->dl_flock);
 		release_delegation(dp);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
