From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 8 of 54] nfsd4: cbnull refcount leak
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00017J-MK@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrm-00026X-3b
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:50 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrl-0007sk-54
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:49 -0800
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



Properly decrement refcount on failure in nfsd4_probe_callback.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-03-07 11:34:24.000000000 +1100
+++ ./fs/nfsd/nfs4callback.c	2005-03-07 11:35:09.000000000 +1100
@@ -435,7 +435,6 @@ nfsd4_probe_callback(struct nfs4_client 
 	clnt->cl_intr = 1;
 	clnt->cl_softrtry = 1;
 	clnt->cl_chatty = 1;
-	cb->cb_client = clnt;
 
 	/* Kick rpciod, put the call on the wire. */
 
@@ -445,6 +444,7 @@ nfsd4_probe_callback(struct nfs4_client 
 	}
 
 	/* the task holds a reference to the nfs4_client struct */
+	cb->cb_client = clnt;
 	atomic_inc(&clp->cl_count);
 
 	msg.rpc_cred = nfsd4_lookupcred(clp,0);
@@ -457,6 +457,7 @@ nfsd4_probe_callback(struct nfs4_client 
 	return;
 
 out_rpciod:
+	atomic_dec(&clp->cl_count);
 	rpciod_down();
 out_clnt:
 	rpc_shutdown_client(clnt);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
