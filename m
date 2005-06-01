From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 004 of 28] nfsd4: nfs4_check_open_reclaim cleanup
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006hp-55@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3I-0005vl-J6
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0005ML-E9
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


Minor cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    6 +-----
 1 files changed, 1 insertion(+), 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:20:59.000000000 +1000
@@ -3155,11 +3155,7 @@ nfs4_find_reclaim_client(clientid_t *cli
 int
 nfs4_check_open_reclaim(clientid_t *clid)
 {
-	struct nfs4_client_reclaim *crp;
-
-	if ((crp = nfs4_find_reclaim_client(clid)) == NULL)
-		return nfserr_reclaim_bad;
-	return nfs_ok;
+	return nfs4_find_reclaim_client(clid) ? nfs_ok : nfserr_reclaim_bad;
 }
 
 


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
