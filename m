From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 012 of 28] nfsd4: setclientid simplification
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006iI-Pe@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3J-0005w1-5C
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:09 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0002Pa-OD
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
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


We can be a little more concise here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:01.000000000 +1000
@@ -674,23 +674,13 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		 * or different ip_address
 		 */
 		status = nfserr_clid_inuse;
-		if (!cmp_creds(&clp->cl_cred,&rqstp->rq_cred)) {
+		if (!cmp_creds(&clp->cl_cred,&rqstp->rq_cred)
+				|| clp->cl_addr != ip_addr) {
 			printk("NFSD: setclientid: string in use by client"
 			"(clientid %08x/%08x)\n",
 			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
 			goto out;
 		}
-		if (clp->cl_addr != ip_addr) { 
-			printk("NFSD: setclientid: string in use by client"
-			"(clientid %08x/%08x)\n",
-			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
-			goto out;
-		}
-
-		/* 
-	 	 * cl_name match from a previous SETCLIENTID operation
-	 	 * XXX check for additional matches?
-		 */
 		conf = clp;
 		break;
 	}


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
