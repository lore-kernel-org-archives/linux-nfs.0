From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 47 of 54] nfsd4: fix sleep under spinlock
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019r-9b@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000285-NB
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrq-0007tp-Qy
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


We shouldn't be calling release_deleg under a spinlock.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   35 ++++++++++++++++++++++++++++-------
 1 files changed, 28 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:32:18.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:33:39.000000000 +1100
@@ -207,7 +207,9 @@ release_delegation(struct nfs4_delegatio
 {
 	list_del_init(&dp->dl_del_perfile);
 	list_del_init(&dp->dl_del_perclnt);
+	spin_lock(&recall_lock);
 	list_del_init(&dp->dl_recall_lru);
+	spin_unlock(&recall_lock);
 	nfs4_close_delegation(dp);
 	nfs4_put_delegation(dp);
 }
@@ -321,6 +323,7 @@ expire_client(struct nfs4_client *clp)
 	struct nfs4_delegation *dp;
 	struct nfs4_callback *cb = &clp->cl_callback;
 	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
+	struct list_head reaplist;
 
 	dprintk("NFSD: expire_client cl_count %d\n",
 	                    atomic_read(&clp->cl_count));
@@ -330,6 +333,8 @@ expire_client(struct nfs4_client *clp)
 		rpc_shutdown_client(clnt);
 		clnt = clp->cl_callback.cb_client = NULL;
 	}
+
+	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	while (!list_empty(&clp->cl_del_perclnt)) {
 		dp = list_entry(clp->cl_del_perclnt.next, struct nfs4_delegation, dl_del_perclnt);
@@ -338,9 +343,15 @@ expire_client(struct nfs4_client *clp)
 
 		/* force release of delegation. */
 		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
-		release_delegation(dp);
+		list_del_init(&dp->dl_del_perclnt);
+		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);
+	while (!list_empty(&reaplist)) {
+		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
+		release_delegation(dp);
+	}
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
 	list_del(&clp->cl_lru);
@@ -1812,7 +1823,7 @@ nfs4_laundromat(void)
 	struct nfs4_client *clp;
 	struct nfs4_stateowner *sop;
 	struct nfs4_delegation *dp;
-	struct list_head *pos, *next;
+	struct list_head *pos, *next, reaplist;
 	time_t cutoff = get_seconds() - NFSD_LEASE_TIME;
 	time_t t, clientid_val = NFSD_LEASE_TIME;
 	time_t u, test_val = NFSD_LEASE_TIME;
@@ -1832,6 +1843,7 @@ nfs4_laundromat(void)
 			clp->cl_clientid.cl_id);
 		expire_client(clp);
 	}
+	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
@@ -1843,9 +1855,14 @@ nfs4_laundromat(void)
 		}
 		dprintk("NFSD: purging unused delegation dp %p, fp %p\n",
 			            dp, dp->dl_flock);
-		release_delegation(dp);
+		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);
+	list_for_each_safe(pos, next, &reaplist) {
+		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
+		release_delegation(dp);
+	}
 	test_val = NFSD_LEASE_TIME;
 	list_for_each_safe(pos, next, &close_lru) {
 		sop = list_entry(pos, struct nfs4_stateowner, so_close_lru);
@@ -2049,9 +2066,7 @@ nfs4_preprocess_stateid_op(struct svc_fh
 		renew_client(dp->dl_client);
 		if (flags & DELEG_RET) {
 			atomic_set(&dp->dl_state,NFS4_RECALL_COMPLETE);
-			spin_lock(&recall_lock);
 			release_delegation(dp);
-			spin_unlock(&recall_lock);
 		}
 	}
 	status = nfs_ok;
@@ -3197,7 +3212,7 @@ __nfs4_state_shutdown(void)
 	struct nfs4_client *clp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	struct nfs4_stateowner *sop = NULL;
-	struct list_head *pos, *next;
+	struct list_head *pos, *next, reaplist;
 
 	list_for_each_safe(pos, next, &close_lru) {
 		sop = list_entry(pos, struct nfs4_stateowner, so_close_lru);
@@ -3215,13 +3230,19 @@ __nfs4_state_shutdown(void)
 			expire_client(clp);
 		}
 	}
+	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
-		release_delegation(dp);
+		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);
+	list_for_each_safe(pos, next, &reaplist) {
+		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
+		release_delegation(dp);
+	}
 
 	release_all_files();
 	cancel_delayed_work(&laundromat_work);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
