From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 43 of 54] nfsd4: fix delegation refcounting
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019b-3q@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsG-0002Ap-A7
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:20 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsF-0005Gd-Ik
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:20 -0800
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


The delegation recall callback is setting the REAP_DELEGATION state when it
drops the reference count to zero instead of just freeing the thing itself,
which is needlessly complicated and bug-prone.  It's simpler just to define a
nfs4_put_delegation() which works in the usual way and have the delegation
recall code do call that itself.

Eventually I'll convert all the nfsd4 state reference counts to struct krefs
which will be harder to abuse in this way....

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c     |    6 +-----
 ./fs/nfsd/nfs4state.c        |   27 ++++++++++-----------------
 ./include/linux/nfsd/state.h |    1 +
 3 files changed, 12 insertions(+), 22 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 13:24:14.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 13:30:33.000000000 +1100
@@ -541,11 +541,7 @@ nfsd4_cb_recall(struct nfs4_delegation *
 	/* Success or failure, now we're either waiting for lease expiration
 	 * or deleg_return. */
 	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
-
-	if (atomic_dec_and_test(&dp->dl_count))
-		atomic_set(&dp->dl_state, NFS4_REAP_DELEG);
-	BUG_ON(atomic_read(&dp->dl_count) < 0);
-
+	nfs4_put_delegation(dp);
 	dprintk("NFSD: nfs4_cb_recall: dp %p dl_flock %p dl_count %d\n",dp, dp->dl_flock, atomic_read(&dp->dl_count));
 	put_rpccred(msg.rpc_cred);
 	return;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:29:58.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:30:33.000000000 +1100
@@ -167,17 +167,14 @@ alloc_init_deleg(struct nfs4_client *clp
 	return dp;
 }
 
-/*
- * Free the delegation structure.
- * Called with the recall_lock held.
- */
-static void
-nfs4_free_delegation(struct nfs4_delegation *dp)
+void
+nfs4_put_delegation(struct nfs4_delegation *dp)
 {
-	dprintk("NFSD: nfs4_free_delegation freeing dp %p\n",dp);
-	list_del(&dp->dl_recall_lru);
-	kfree(dp);
-	free_delegation++;
+	if (atomic_dec_and_test(&dp->dl_count)) {
+		dprintk("NFSD: freeing dp %p\n",dp);
+		kfree(dp);
+		free_delegation++;
+	}
 }
 
 /* release_delegation:
@@ -219,12 +216,8 @@ release_delegation(struct nfs4_delegatio
 		remove_lease(dp->dl_flock);
 		list_del_init(&dp->dl_del_perfile);
 		list_del_init(&dp->dl_del_perclnt);
-		/* dl_count > 0 => outstanding recall rpc */
-		dprintk("NFSD: release_delegation free deleg dl_count %d\n",
-			           atomic_read(&dp->dl_count));
-		if ((atomic_read(&dp->dl_state) == NFS4_REAP_DELEG)
-		     || atomic_dec_and_test(&dp->dl_count))
-			nfs4_free_delegation(dp);
+		list_del_init(&dp->dl_recall_lru);
+		nfs4_put_delegation(dp);
 	}
 }
 
@@ -1692,7 +1685,7 @@ nfs4_open_delegation(struct svc_fh *fh, 
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
 		list_del(&dp->dl_del_perfile);
 		list_del(&dp->dl_del_perclnt);
-		kfree(dp);
+		nfs4_put_delegation(dp);
 		free_delegation++;
 		*flag = NFS4_OPEN_DELEGATE_NONE;
 		return;

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 13:28:51.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 13:30:33.000000000 +1100
@@ -288,6 +288,7 @@ extern void put_nfs4_client(struct nfs4_
 extern void nfs4_free_stateowner(struct kref *kref);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
+extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
