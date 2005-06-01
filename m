From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 017 of 28] nfsd4: fix uncomfirmed list
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006iZ-Fe@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3I-0005va-6n
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0002Pe-W9
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:07 -0700
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


Setclientid code assumes there is only one match in unconfirmed list.
Make sure that assumption holds.

>From Fred Isaman
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:03.000000000 +1000
@@ -743,10 +743,13 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		 * nfs4_client,  but with the new callback info and a 
 		 * new cl_confirm
 		 */
-		if ((unconf) && 
-		    cmp_verf(&unconf->cl_verifier, &conf->cl_verifier) &&
-		     cmp_clid(&unconf->cl_clientid, &conf->cl_clientid)) {
-				expire_client(unconf);
+		if (unconf) {
+			/* Note this is removing unconfirmed {*x***},
+			 * which is stronger than RFC recommended {vxc**}.
+			 * This has the advantage that there is at most
+			 * one {*x***} in either list at any time.
+			 */
+			expire_client(unconf);
 		}
 		new = create_client(clname, dname);
 		if (new == NULL)


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
