From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 33 of 54] nfsd4: use sync rpc for delegation recall
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018v-EX@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrm-00026Z-R5
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:50 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrm-0005CZ-Aa
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:50 -0800
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



Use a synchronous rpc for the delegation recall.  This is simpler and
avoids putting rpciod to sleep for 2 seconds on retries.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:36:31.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:36:31.000000000 +1100
@@ -496,17 +496,16 @@ out:
  *  Called with dp->dl_count incremented
  */
 static void
-nfs4_cb_recall_done(struct rpc_task *task)
+nfs4_cb_recall_done(struct nfs4_cb_recall *cbr, int status)
 {
-	struct nfs4_cb_recall *cbr = (struct nfs4_cb_recall *)task->tk_calldata;
 	struct nfs4_delegation *dp = cbr->cbr_dp;
 
 	/* all is well... */
-	if (task->tk_status == 0)
+	if (status == 0)
 		goto out;
 
 	/* network partition, retry nfsd4_cb_recall once.  */
-	if (task->tk_status == -EIO) {
+	if (status == -EIO) {
 		if (atomic_read(&dp->dl_recall_cnt) == 0)
 			goto retry;
 		else
@@ -518,7 +517,7 @@ nfs4_cb_recall_done(struct rpc_task *tas
 	* Client may have received recall prior to delegation. retry recall
 	* once.
 	*/
-	if ((task->tk_status == -EBADHANDLE) || (task->tk_status == -NFS4ERR_BAD_STATEID)){
+	if ((status == -EBADHANDLE) || (status == -NFS4ERR_BAD_STATEID)){
 		if (atomic_read(&dp->dl_recall_cnt) == 0)
 			goto retry;
 	}
@@ -570,10 +569,11 @@ nfsd4_cb_recall(struct nfs4_delegation *
 	cbr->cbr_trunc = 0; /* XXX need to implement truncate optimization */
 	cbr->cbr_dp = dp;
 
-	if ((status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
-		nfs4_cb_recall_done, cbr )))
+	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
+	if (status)
 		dprintk("NFSD: recall_delegation: rpc_call_async failed %d\n",
 			status);
+	nfs4_cb_recall_done(cbr, status);
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
