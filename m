From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 32 of 54] nfsd4: fix callback cred refcnt leak
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018r-Db@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000280-5V
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0007tX-Oa
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



The rpc creds we look up in the callback code need puts.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:36:26.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:36:31.000000000 +1100
@@ -450,6 +450,7 @@ nfsd4_probe_callback(struct nfs4_client 
 
 	msg.rpc_cred = nfsd4_lookupcred(clp,0);
 	status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, nfs4_cb_null, NULL);
+	put_rpccred(msg.rpc_cred);
 
 	if (status != 0) {
 		dprintk("NFSD: asynchronous NFSPROC4_CB_NULL failed!\n");
@@ -573,5 +574,6 @@ nfsd4_cb_recall(struct nfs4_delegation *
 		nfs4_cb_recall_done, cbr )))
 		dprintk("NFSD: recall_delegation: rpc_call_async failed %d\n",
 			status);
+	put_rpccred(msg.rpc_cred);
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
