From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 46 of 54] nfsd4: fix delegation filp sharing
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019n-8p@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrs-00028C-Ih
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrr-0007u0-MC
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
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



The st_vfs_file pointer is set when the open that originally got the delegation
is closed, and then in release_deleg we attempt to distinguish between the case
when the original open has been closed and when it hasn't.  The resulting logic
is complicated and buggy.

It's much simpler just to keep a reference count on the struct file.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   57 ++++++++++++--------------------------------------
 1 files changed, 14 insertions(+), 43 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:31:46.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:32:18.000000000 +1100
@@ -145,7 +145,8 @@ alloc_init_deleg(struct nfs4_client *clp
 	dp->dl_client = clp;
 	dp->dl_file = fp;
 	dp->dl_flock = NULL;
-	dp->dl_vfs_file = NULL;
+	get_file(stp->st_vfs_file);
+	dp->dl_vfs_file = stp->st_vfs_file;
 	dp->dl_type = type;
 	dp->dl_recall.cbr_dp = NULL;
 	dp->dl_recall.cbr_ident = cb->cb_ident;
@@ -183,16 +184,6 @@ nfs4_put_delegation(struct nfs4_delegati
  * the i_flock list, eventually calling nfsd's lock_manager
  * fl_release_callback.
  *
- * call either:
- *   nfsd_close : if last close, locks_remove_flock calls lease_modify.
- *                otherwise, recalled state set to NFS4_RECALL_COMPLETE
- *                so that it will be reaped by the laundromat service.
- * or
- *   remove_lease (calls time_out_lease which calls lease_modify).
- *   and nfs4_free_delegation.
- *
- * Called with nfs_lock_state() held.
- * Called with the recall_lock held.
  */
 
 static void
@@ -203,6 +194,9 @@ nfs4_close_delegation(struct nfs4_delega
 	dprintk("NFSD: close_delegation dp %p\n",dp);
 	dp->dl_vfs_file = NULL;
 	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+	/* The following nfsd_close may not actually close the file,
+	 * but we want to remove the lease in any case. */
+	remove_lease(dp->dl_flock);
 	nfsd_close(filp);
 	vfsclose++;
 }
@@ -211,18 +205,11 @@ nfs4_close_delegation(struct nfs4_delega
 static void
 release_delegation(struct nfs4_delegation *dp)
 {
-	/* delayed nfsd_close */
-	if (dp->dl_vfs_file)
-		nfs4_close_delegation(dp);
-	else {
-		dprintk("NFSD: release_delegation remove lease dl_flock %p\n",
-			dp->dl_flock);
-		remove_lease(dp->dl_flock);
-		list_del_init(&dp->dl_del_perfile);
-		list_del_init(&dp->dl_del_perclnt);
-		list_del_init(&dp->dl_recall_lru);
-		nfs4_put_delegation(dp);
-	}
+	list_del_init(&dp->dl_del_perfile);
+	list_del_init(&dp->dl_del_perclnt);
+	list_del_init(&dp->dl_recall_lru);
+	nfs4_close_delegation(dp);
+	nfs4_put_delegation(dp);
 }
 
 /* 
@@ -1153,38 +1140,22 @@ init_stateid(struct nfs4_stateid *stp, s
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 }
 
-/*
-* Because nfsd_close() can call locks_remove_flock() which removes leases,
-* delay nfsd_close() for delegations from the nfsd_open() clientid
-* until the delegation is reaped.
-*/
 static void
 release_stateid(struct nfs4_stateid *stp, int flags)
 {
-	struct nfs4_delegation *dp;
-	struct nfs4_file *fp = stp->st_file;
+	struct file *filp = stp->st_vfs_file;
 
 	list_del(&stp->st_hash);
 	list_del_perfile++;
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perfilestate);
 	if (flags & OPEN_STATE) {
-		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
-			if(cmp_clid(&dp->dl_client->cl_clientid,
-			    &stp->st_stateowner->so_client->cl_clientid)) {
-				dp->dl_vfs_file = stp->st_vfs_file;
-				release_stateid_lockowners(stp);
-				return;
-			}
-		}
 		release_stateid_lockowners(stp);
-		nfsd_close(stp->st_vfs_file);
+		stp->st_vfs_file = NULL;
+		nfsd_close(filp);
 		vfsclose++;
-	} else if (flags & LOCK_STATE) {
-		struct file *filp = stp->st_vfs_file;
-
+	} else if (flags & LOCK_STATE)
 		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
-	}
 	kfree(stp);
 	stp = NULL;
 }


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
