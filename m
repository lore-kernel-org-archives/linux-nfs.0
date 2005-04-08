From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 002 of 16] nfsd4: callback create rpc client returns
Date: Fri, 08 Apr 2005 11:00:15 +1000
Message-ID: <E1DJhr5-0006dS-4m@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006U0-B5
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikM-0000uT-BF
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
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



rpc_create_clnt and friends return errors, not NULL, on failure.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4callback.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4callback.c~current~ ./fs/nfsd/nfs4callback.c
--- ./fs/nfsd/nfs4callback.c~current~	2005-04-08 10:31:12.000000000 +1000
+++ ./fs/nfsd/nfs4callback.c	2005-04-08 10:34:37.000000000 +1000
@@ -405,7 +405,8 @@ nfsd4_probe_callback(struct nfs4_client 
 	timeparms.to_exponential = 1;
 
 	/* Create RPC transport */
-	if (!(xprt = xprt_create_proto(IPPROTO_TCP, &addr, &timeparms))) {
+	xprt = xprt_create_proto(IPPROTO_TCP, &addr, &timeparms);
+	if (IS_ERR(xprt)) {
 		dprintk("NFSD: couldn't create callback transport!\n");
 		goto out_err;
 	}
@@ -426,7 +427,8 @@ nfsd4_probe_callback(struct nfs4_client 
 	 * XXX AUTH_UNIX only - need AUTH_GSS....
 	 */
 	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(addr.sin_addr.s_addr));
-	if (!(clnt = rpc_create_client(xprt, hostname, program, 1, RPC_AUTH_UNIX))) {
+	clnt = rpc_create_client(xprt, hostname, program, 1, RPC_AUTH_UNIX);
+	if (IS_ERR(clnt)) {
 		dprintk("NFSD: couldn't create callback client\n");
 		goto out_err;
 	}


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
