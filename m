From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 31 of 54] nfsd4: make nfsd4_cb_recall return void
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018n-Bx@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrp-00027a-Tv
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xro-0007tM-UT
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:53 -0800
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



The return value of nfsd4_cb_recall isn't really used (and the errors we were
returning were incorrect anyway).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c     |   21 +++++++--------------
 ./include/linux/nfsd/state.h |    2 +-
 2 files changed, 8 insertions(+), 15 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:35:59.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:36:26.000000000 +1100
@@ -499,7 +499,6 @@ nfs4_cb_recall_done(struct rpc_task *tas
 {
 	struct nfs4_cb_recall *cbr = (struct nfs4_cb_recall *)task->tk_calldata;
 	struct nfs4_delegation *dp = cbr->cbr_dp;
-	int status;
 
 	/* all is well... */
 	if (task->tk_status == 0)
@@ -536,15 +535,14 @@ retry:
 	atomic_inc(&dp->dl_recall_cnt);
 	/* sleep 2 seconds before retrying recall */
 	ssleep(2);
-	status = nfsd4_cb_recall(dp);
-	dprintk("NFSD: nfs4_cb_recall_done: retry status: %d  dp %p dl_flock %p\n",status,dp, dp->dl_flock);
+	nfsd4_cb_recall(dp);
 }
 
 /*
  * called with dp->dl_count inc'ed.
  * nfs4_lock_state() may or may not have been called.
  */
-int
+void
 nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp;
@@ -559,26 +557,21 @@ nfsd4_cb_recall(struct nfs4_delegation *
 
 	clp = dp->dl_client;
 	clnt = clp->cl_callback.cb_client;
-	status = EIO;
 	if ((!atomic_read(&clp->cl_callback.cb_set)) || !clnt)
-		goto out_fail;
+		return;
 
 	msg.rpc_argp = cbr;
 	msg.rpc_resp = cbr;
 	msg.rpc_cred = nfsd4_lookupcred(clp,0);
+	if (IS_ERR(msg.rpc_cred))
+		return;
 
 	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
 	cbr->cbr_dp = dp;
 
 	if ((status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
-		nfs4_cb_recall_done, cbr ))) {
+		nfs4_cb_recall_done, cbr )))
 		dprintk("NFSD: recall_delegation: rpc_call_async failed %d\n",
 			status);
-		goto out_fail;
-	}
-out:
-	return status;
-out_fail:
-	status = nfserrno(status);
-	goto out;
+	return;
 }

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 11:36:26.000000000 +1100
@@ -289,7 +289,7 @@ extern int nfs4_check_open_reclaim(clien
 extern void put_nfs4_client(struct nfs4_client *clp);
 extern void nfs4_free_stateowner(struct kref *kref);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
-extern int nfsd4_cb_recall(struct nfs4_delegation *dp);
+extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 
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
