From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 35 of 54] nfsd4: nfs4_cb_recall cleanup
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-000193-H6@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrt-00028F-FI
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:57 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrs-0007uR-Ok
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:57 -0800
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


Miscellaneous cleanup including:
	remove recursion
	use a local variable instead of dl_recall_cnt

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |   85 +++++++++++++++++------------------------------
 1 files changed, 31 insertions(+), 54 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:36:32.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 13:24:14.000000000 +1100
@@ -493,54 +493,7 @@ out:
 }
 
 /*
- *  Called with dp->dl_count incremented
- */
-static void
-nfs4_cb_recall_done(struct nfs4_cb_recall *cbr, int status)
-{
-	struct nfs4_delegation *dp = cbr->cbr_dp;
-
-	/* all is well... */
-	if (status == 0)
-		goto out;
-
-	/* network partition, retry nfsd4_cb_recall once.  */
-	if (status == -EIO) {
-		if (atomic_read(&dp->dl_recall_cnt) == 0)
-			goto retry;
-		else
-			/* callback channel no longer available */
-			atomic_set(&dp->dl_client->cl_callback.cb_set, 0);
-	}
-
-	/* Race: a recall occurred miliseconds after a delegation was granted.
-	* Client may have received recall prior to delegation. retry recall
-	* once.
-	*/
-	if ((status == -EBADHANDLE) || (status == -NFS4ERR_BAD_STATEID)){
-		if (atomic_read(&dp->dl_recall_cnt) == 0)
-			goto retry;
-	}
-	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
-
-out:
-	if (atomic_dec_and_test(&dp->dl_count))
-		atomic_set(&dp->dl_state, NFS4_REAP_DELEG);
-	BUG_ON(atomic_read(&dp->dl_count) < 0);
-	dprintk("NFSD: nfs4_cb_recall_done: dp %p dl_flock %p dl_count %d\n",dp, dp->dl_flock, atomic_read(&dp->dl_count));
-	return;
-
-retry:
-	dprintk("NFSD: nfs4_cb_recall_done RETRY\n");
-	atomic_inc(&dp->dl_recall_cnt);
-	/* sleep 2 seconds before retrying recall */
-	ssleep(2);
-	nfsd4_cb_recall(dp);
-}
-
-/*
  * called with dp->dl_count inc'ed.
- * nfs4_lock_state() may or may not have been called.
  */
 void
 nfsd4_cb_recall(struct nfs4_delegation *dp)
@@ -551,25 +504,49 @@ nfsd4_cb_recall(struct nfs4_delegation *
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
 		.rpc_argp = cbr,
-		.rpc_resp = cbr,
 	};
-	int status;
+	int retries = 1;
+	int status = 0;
 
 	if ((!atomic_read(&clp->cl_callback.cb_set)) || !clnt)
 		return;
 
 	msg.rpc_cred = nfsd4_lookupcred(clp, 0);
 	if (IS_ERR(msg.rpc_cred))
-		return;
+		goto out;
 
 	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
 	cbr->cbr_dp = dp;
 
 	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
-	if (status)
-		dprintk("NFSD: recall_delegation: rpc_call_async failed %d\n",
-			status);
-	nfs4_cb_recall_done(cbr, status);
+	while (retries--) {
+		switch (status) {
+			case -EIO:
+				/* Network partition? */
+			case -EBADHANDLE:
+			case -NFS4ERR_BAD_STATEID:
+				/* Race: client probably got cb_recall
+				 * before open reply granting delegation */
+				break;
+			default:
+				goto out;
+		}
+		ssleep(2);
+		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
+	}
+
+ out:
+	if (status == -EIO)
+		atomic_set(&clp->cl_callback.cb_set, 0);
+	/* Success or failure, now we're either waiting for lease expiration
+	 * or deleg_return. */
+	atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+
+	if (atomic_dec_and_test(&dp->dl_count))
+		atomic_set(&dp->dl_state, NFS4_REAP_DELEG);
+	BUG_ON(atomic_read(&dp->dl_count) < 0);
+
+	dprintk("NFSD: nfs4_cb_recall: dp %p dl_flock %p dl_count %d\n",dp, dp->dl_flock, atomic_read(&dp->dl_count));
 	put_rpccred(msg.rpc_cred);
 	return;
 }


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
