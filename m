From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 38 of 54] nfsd4: keep lockowners off perclient list
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00019H-Oe@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrs-00028B-BK
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:56 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0005Cy-KA
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


There's no reason to have the lockowners hang off the same list on the client
struct as the openowners do; you can always get to the lockowners from their
original openowners instead.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:26:15.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:26:43.000000000 +1100
@@ -1109,9 +1109,11 @@ unhash_stateowner(struct nfs4_stateowner
 
 	list_del(&sop->so_idhash);
 	list_del(&sop->so_strhash);
-	list_del(&sop->so_perclient);
+	if (sop->so_is_open_owner) {
+		list_del(&sop->so_perclient);
+		del_perclient++;
+	}
 	list_del(&sop->so_perlockowner);
-	del_perclient++;
 	while (!list_empty(&sop->so_perfilestate)) {
 		stp = list_entry(sop->so_perfilestate.next, 
 			struct nfs4_stateid, st_perfilestate);
@@ -2575,9 +2577,7 @@ alloc_init_lock_stateowner(unsigned int 
 	sop->so_time = 0;
 	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
 	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
-	list_add(&sop->so_perclient, &clp->cl_perclient);
 	list_add(&sop->so_perlockowner, &open_stp->st_perlockowner);
-	add_perclient++;
 	sop->so_is_open_owner = 0;
 	sop->so_id = current_ownerid++;
 	sop->so_client = clp;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
