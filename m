From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 49 of 54] nfsd4: remove dl_state
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019z-Bb@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrs-00028A-9H
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrr-0005DF-Ab
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



The dl_state flag isn't actually useful.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c     |    1 -
 ./fs/nfsd/nfs4state.c        |   23 +++++------------------
 ./include/linux/nfsd/state.h |    7 -------
 3 files changed, 5 insertions(+), 26 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 13:30:33.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 13:34:56.000000000 +1100
@@ -540,7 +540,6 @@ nfsd4_cb_recall(struct nfs4_delegation *
 		atomic_set(&clp->cl_callback.cb_set, 0);
 	/* Success or failure, now we're either waiting for lease expiration
 	 * or deleg_return. */
-	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
 	nfs4_put_delegation(dp);
 	dprintk("NFSD: nfs4_cb_recall: dp %p dl_flock %p dl_count %d\n",dp, dp->dl_flock, atomic_read(&dp->dl_count));
 	put_rpccred(msg.rpc_cred);

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:34:30.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:34:56.000000000 +1100
@@ -159,7 +159,6 @@ alloc_init_deleg(struct nfs4_client *clp
 	memcpy(dp->dl_fhval, &current_fh->fh_handle.fh_base,
 		        current_fh->fh_handle.fh_size);
 	dp->dl_time = 0;
-	atomic_set(&dp->dl_state, NFS4_NO_RECALL);
 	atomic_set(&dp->dl_count, 1);
 	list_add(&dp->dl_del_perfile, &fp->fi_del_perfile);
 	list_add(&dp->dl_del_perclnt, &clp->cl_del_perclnt);
@@ -193,7 +192,6 @@ nfs4_close_delegation(struct nfs4_delega
 
 	dprintk("NFSD: close_delegation dp %p\n",dp);
 	dp->dl_vfs_file = NULL;
-	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
 	/* The following nfsd_close may not actually close the file,
 	 * but we want to remove the lease in any case. */
 	remove_lease(dp->dl_flock);
@@ -338,11 +336,8 @@ expire_client(struct nfs4_client *clp)
 	spin_lock(&recall_lock);
 	while (!list_empty(&clp->cl_del_perclnt)) {
 		dp = list_entry(clp->cl_del_perclnt.next, struct nfs4_delegation, dl_del_perclnt);
-		dprintk("NFSD: expire client. dp %p, dl_state %d, fp %p\n",
-				dp, atomic_read(&dp->dl_state), dp->dl_flock);
-
-		/* force release of delegation. */
-		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+		dprintk("NFSD: expire client. dp %p, fp %p\n", dp,
+				dp->dl_flock);
 		list_del_init(&dp->dl_del_perclnt);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
@@ -1355,7 +1350,6 @@ void nfsd_break_deleg_cb(struct file_loc
 	atomic_inc(&dp->dl_count);
 
 	spin_lock(&recall_lock);
-	atomic_set(&dp->dl_state, NFS4_RECALL_IN_PROGRESS);
 	list_add_tail(&dp->dl_recall_lru, &del_recall_lru);
 	spin_unlock(&recall_lock);
 
@@ -1385,11 +1379,10 @@ void nfsd_release_deleg_cb(struct file_l
 {
 	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
 
-	dprintk("NFSD nfsd_release_deleg_cb: fl %p dp %p dl_count %d, dl_state %d\n", fl,dp, atomic_read(&dp->dl_count), atomic_read(&dp->dl_state));
+	dprintk("NFSD nfsd_release_deleg_cb: fl %p dp %p dl_count %d\n", fl,dp, atomic_read(&dp->dl_count));
 
 	if (!(fl->fl_flags & FL_LEASE) || !dp)
 		return;
-	atomic_set(&dp->dl_state,NFS4_RECALL_COMPLETE);
 	dp->dl_flock = NULL;
 }
 
@@ -1514,11 +1507,8 @@ nfs4_check_deleg_recall(struct nfs4_file
 	int status = 0;
 
 	list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
-		dprintk("NFSD: found delegation %p with dl_state %d\n",
-		 	                 dp, atomic_read(&dp->dl_state));
 		if (op->op_share_access & NFS4_SHARE_ACCESS_WRITE
-			|| op->op_stateowner->so_client == dp->dl_client
-			|| atomic_read(&dp->dl_state) != NFS4_NO_RECALL) {
+			|| op->op_stateowner->so_client == dp->dl_client) {
 			*flag = NFS4_OPEN_DELEGATE_NONE;
 			goto out;
 		}
@@ -2064,10 +2054,8 @@ nfs4_preprocess_stateid_op(struct svc_fh
 		if ((status = nfs4_check_delegmode(dp, flags)))
 			goto out;
 		renew_client(dp->dl_client);
-		if (flags & DELEG_RET) {
-			atomic_set(&dp->dl_state,NFS4_RECALL_COMPLETE);
+		if (flags & DELEG_RET)
 			release_delegation(dp);
-		}
 		if (filpp)
 			*filpp = dp->dl_vfs_file;
 	}
@@ -3236,7 +3224,6 @@ __nfs4_state_shutdown(void)
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 13:31:46.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 13:34:56.000000000 +1100
@@ -67,12 +67,6 @@ extern stateid_t onestateid;
 #define ZERO_STATEID(stateid)       (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
 #define ONE_STATEID(stateid)        (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
-/* Delegation recall states */
-#define NFS4_NO_RECALL			0x000
-#define NFS4_RECALL_IN_PROGRESS		0x001
-#define NFS4_RECALL_COMPLETE		0x002
-#define NFS4_REAP_DELEG			0x004
-
 struct nfs4_cb_recall {
 	u32			cbr_ident;
 	int			cbr_trunc;
@@ -87,7 +81,6 @@ struct nfs4_delegation {
 	struct list_head	dl_del_perclnt; /* nfs4_client->cl_del_perclnt*/
 	struct list_head	dl_recall_lru;  /* delegation recalled */
 	atomic_t		dl_count;       /* ref count */
-	atomic_t		dl_state;       /* recall state */
 	struct nfs4_client	*dl_client;
 	struct nfs4_file	*dl_file;
 	struct file_lock	*dl_flock;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
