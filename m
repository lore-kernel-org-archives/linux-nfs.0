From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 16] nfsd4: fix share conflict tests
Date: Tue, 22 Mar 2005 16:42:01 +1100
Message-ID: <E1DDc9R-0002KG-Bs@notabene.cse.unsw.edu.au>
References: <20050322163830.8762.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDc9e-0006lB-AD
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:14 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDc9b-00055u-DI
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 21:42:14 -0800
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


In nfs4_check_open():

Move 'is_open_owner' check to be first.  Remove continue so as to call
test_share on OPENs with a previously seen open_owner as per rfc3530.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-22 16:35:20.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-22 16:36:34.000000000 +1100
@@ -1535,14 +1535,12 @@ nfs4_check_open(struct nfs4_file *fp, st
 	int status = nfserr_share_denied;
 
 	list_for_each_entry(local, &fp->fi_perfile, st_perfile) {
-		/* have we seen this open owner */
-		if (local->st_stateowner == sop) {
-			*stpp = local;
-			continue;
-		}
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
 			continue;
+		/* remember if we have seen this open owner */
+		if (local->st_stateowner == sop)
+			*stpp = local;
 		/* check for conflicting share reservations */
 		if (!test_share(local, open))
 			goto out;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
