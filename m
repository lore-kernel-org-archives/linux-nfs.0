From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 019 of 28] nfsd4: fix setclientid_confirm error return
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006if-Iv@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3X-0005yF-VR
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:23 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3W-0005PI-0Q
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:23 -0700
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


NFS4_INVAL is not a valid error for setclientid_confirm, and INUSE is the more
logical error here anyway.

>From Fred Isaman
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:04.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:04.000000000 +1000
@@ -849,12 +849,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	nfs4_lock_state();
 	clp = find_confirmed_client(clid);
 	if (clp) {
-		status = nfserr_inval;
-		/* 
-		 * Found a record for this clientid. If the IP addresses
-		 * don't match, return ERR_INVAL just as if the record had
-		 * not been found.
-		 */
+		status = nfserr_clid_inuse;
 		if (clp->cl_addr != ip_addr) { 
 			printk("NFSD: setclientid: string in use by client"
 			"(clientid %08x/%08x)\n",
@@ -865,7 +860,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	}
 	clp = find_unconfirmed_client(clid);
 	if (clp) {
-		status = nfserr_inval;
+		status = nfserr_clid_inuse;
 		if (clp->cl_addr != ip_addr) { 
 			printk("NFSD: setclientid: string in use by client"
 			"(clientid %08x/%08x)\n",
@@ -949,7 +944,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 		goto out;
 	}
 	/* check that we have hit one of the cases...*/
-	status = nfserr_inval;
+	status = nfserr_clid_inuse;
 	goto out;
 out:
 	if (!status)


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
