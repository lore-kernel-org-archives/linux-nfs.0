From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 51 of 54] nfsd4: fix_release_state_owner prototype
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-0001A7-Gj@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000286-Qo
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0005D3-VA
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
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



Note that the second parameter is unused.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:37:15.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:37:26.000000000 +1100
@@ -1186,8 +1186,7 @@ move_to_close_lru(struct nfs4_stateowner
 }
 
 void
-release_state_owner(struct nfs4_stateid *stp, struct nfs4_stateowner **sopp,
-		int flag)
+release_state_owner(struct nfs4_stateid *stp, int flag)
 {
 	struct nfs4_stateowner *sop = stp->st_stateowner;
 	struct nfs4_file *fp = stp->st_file;
@@ -2337,7 +2336,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 	/* release_state_owner() calls nfsd_close() if needed */
-	release_state_owner(stp, &close->cl_stateowner, OPEN_STATE);
+	release_state_owner(stp, OPEN_STATE);
 out:
 	if (close->cl_stateowner)
 		nfs4_get_stateowner(close->cl_stateowner);
@@ -2780,7 +2779,7 @@ out_destroy_new_stateid:
 		if (!seqid_mutating_err(status))
 			open_sop->so_seqid--;
 
-		release_state_owner(lock_stp, &lock->lk_stateowner, LOCK_STATE);
+		release_state_owner(lock_stp, LOCK_STATE);
 	}
 out:
 	if (lock->lk_stateowner)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
