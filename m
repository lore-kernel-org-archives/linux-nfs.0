From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 34 of 54] nfsd4: trivial callback cleanup
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018z-FO@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrs-000288-4V
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrq-0005D8-Ed
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



Whitespace, etc.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:36:31.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:36:32.000000000 +1100
@@ -310,7 +310,7 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *
 	if (status)
 		goto out;
 	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
-out	:
+out:
 	return status;
 }
 
@@ -545,24 +545,20 @@ retry:
 void
 nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
-	struct nfs4_client *clp;
-	struct rpc_clnt *clnt;
+	struct nfs4_client *clp = dp->dl_client;
+	struct rpc_clnt *clnt = clp->cl_callback.cb_client;
+	struct nfs4_cb_recall *cbr = &dp->dl_recall;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
+		.rpc_argp = cbr,
+		.rpc_resp = cbr,
 	};
-	struct nfs4_cb_recall *cbr = &dp->dl_recall;
 	int status;
 
-	dprintk("NFSD: nfsd4_cb_recall NFS4_enc_cb_recall_sz %d NFS4_dec_cb_recall_sz %d \n",NFS4_enc_cb_recall_sz,NFS4_dec_cb_recall_sz);
-
-	clp = dp->dl_client;
-	clnt = clp->cl_callback.cb_client;
 	if ((!atomic_read(&clp->cl_callback.cb_set)) || !clnt)
 		return;
 
-	msg.rpc_argp = cbr;
-	msg.rpc_resp = cbr;
-	msg.rpc_cred = nfsd4_lookupcred(clp,0);
+	msg.rpc_cred = nfsd4_lookupcred(clp, 0);
 	if (IS_ERR(msg.rpc_cred))
 		return;
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
