From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 24 of 54] nfsd4: simplify verify_clientid
Date: Tue, 08 Mar 2005 17:06:43 +1100
Message-ID: <E1D8Xrf-00018L-Tu@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsK-0002BE-Hy
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsJ-0007xH-Ni
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
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



Simplify verify_clientid out of existance.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:57.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:57.000000000 +1100
@@ -1247,21 +1247,6 @@ find_openstateowner_str(unsigned int has
 	return 0;
 }
 
-/* see if clientid is in confirmed hash table */
-static int
-verify_clientid(struct nfs4_client **client, clientid_t *clid) {
-
-	struct nfs4_client *clp;
-
-	clp = find_confirmed_client(clid);
-	if (clp) {
-		*client = clp;
-		return 1;
-	}
-	*client = NULL;
-	return 0;
-}
-
 /* search file_hashtbl[] for file */
 static int
 find_file(unsigned int hashval, struct inode *ino, struct nfs4_file **fp) {
@@ -1514,7 +1499,8 @@ nfsd4_process_open1(struct nfsd4_open *o
 		 * client's lease expiring.
 		 */
 		status = nfserr_expired;
-		if (!verify_clientid(&clp, clientid))
+		clp = find_confirmed_client(clientid);
+		if (clp == NULL)
 			goto out;
 	}
 	status = nfserr_resource;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
