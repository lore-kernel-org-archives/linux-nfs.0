From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 30 of 54] nfsd4: remove incorrect kfree from callback
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018j-Aj@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsH-0002Az-JK
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:21 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsG-0005Gq-Tx
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:21 -0800
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



Remove incorrect kfree.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    4 +---
 1 files changed, 1 insertion(+), 3 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:35:59.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:35:59.000000000 +1100
@@ -561,7 +561,7 @@ nfsd4_cb_recall(struct nfs4_delegation *
 	clnt = clp->cl_callback.cb_client;
 	status = EIO;
 	if ((!atomic_read(&clp->cl_callback.cb_set)) || !clnt)
-		goto out_free;
+		goto out_fail;
 
 	msg.rpc_argp = cbr;
 	msg.rpc_resp = cbr;
@@ -580,7 +580,5 @@ out:
 	return status;
 out_fail:
 	status = nfserrno(status);
-	out_free:
-	kfree(cbr);
 	goto out;
 }


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
