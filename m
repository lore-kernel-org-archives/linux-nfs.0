From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 13 of 16] nfsd4: rename release_delegation
Date: Tue, 22 Mar 2005 16:42:02 +1100
Message-ID: <E1DDc9S-0002Ku-0F@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDc9b-0006ka-Sm
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:11 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9b-0005e0-1f
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:11 -0800
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


Release_delegation is responsible for removing the delegation's connection with
the v4 state and with the lease subsystem.  The word "unhash" seems closer than
"release" as a description of this....

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-22 16:36:35.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-22 16:36:36.000000000 +1100
@@ -176,15 +176,11 @@ nfs4_put_delegation(struct nfs4_delegati
 	}
 }
 
-/* release_delegation:
- *
- * Remove the associated file_lock first, then remove the delegation.
+/* Remove the associated file_lock first, then remove the delegation.
  * lease_modify() is called to remove the FS_LEASE file_lock from
  * the i_flock list, eventually calling nfsd's lock_manager
  * fl_release_callback.
- *
  */
-
 static void
 nfs4_close_delegation(struct nfs4_delegation *dp)
 {
@@ -201,7 +197,7 @@ nfs4_close_delegation(struct nfs4_delega
 
 /* Called under the state lock. */
 static void
-release_delegation(struct nfs4_delegation *dp)
+unhash_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_del_perfile);
 	list_del_init(&dp->dl_del_perclnt);
@@ -345,7 +341,7 @@ expire_client(struct nfs4_client *clp)
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		release_delegation(dp);
+		unhash_delegation(dp);
 	}
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
@@ -1859,7 +1855,7 @@ nfs4_laundromat(void)
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		release_delegation(dp);
+		unhash_delegation(dp);
 	}
 	test_val = NFSD_LEASE_TIME;
 	list_for_each_safe(pos, next, &close_lru) {
@@ -2064,7 +2060,7 @@ nfs4_preprocess_stateid_op(struct svc_fh
 			goto out;
 		renew_client(dp->dl_client);
 		if (flags & DELEG_RET)
-			release_delegation(dp);
+			unhash_delegation(dp);
 		if (filpp)
 			*filpp = dp->dl_vfs_file;
 	}
@@ -3239,7 +3235,7 @@ __nfs4_state_shutdown(void)
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		release_delegation(dp);
+		unhash_delegation(dp);
 	}
 
 	release_all_files();


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
