From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 7 of 9] nfsd4: postpone release of stateowner on CLOSE
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-00043A-Ix@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uO-000057-Im
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:36 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uN-0007KU-Qw
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:36 -0700
To: Andrew Morton <akpm@osdl.org>
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



Postpone the release of a stateowner on CLOSE for lease time to enable the
CLOSE replay cache. Place stateowner on the close_lru list to be reaped by the
laundromat service.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-03 11:57:34.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-03 11:57:34.000000000 +1000
@@ -908,7 +908,7 @@ release_stateid_lockowner(struct nfs4_st
 }
 
 static void
-release_stateowner(struct nfs4_stateowner *sop)
+unhash_stateowner(struct nfs4_stateowner *sop)
 {
 	struct nfs4_stateid *stp;
 
@@ -916,7 +916,6 @@ release_stateowner(struct nfs4_stateowne
 	list_del(&sop->so_strhash);
 	list_del(&sop->so_perclient);
 	list_del(&sop->so_perlockowner);
-	list_del(&sop->so_close_lru);
 	del_perclient++;
 	while (!list_empty(&sop->so_perfilestate)) {
 		stp = list_entry(sop->so_perfilestate.next, 
@@ -926,6 +925,13 @@ release_stateowner(struct nfs4_stateowne
 		else
 			release_stateid(stp, LOCK_STATE);
 	}
+}
+
+static void
+release_stateowner(struct nfs4_stateowner *sop)
+{
+	unhash_stateowner(sop);
+	list_del(&sop->so_close_lru);
 	free_stateowner(sop);
 }
 
@@ -986,11 +992,8 @@ void
 move_to_close_lru(struct nfs4_stateowner *sop)
 {
 	dprintk("NFSD: move_to_close_lru nfs4_stateowner %p\n", sop);
-	/* remove stateowner from all other hash lists except perclient */
-	list_del_init(&sop->so_idhash);
-	list_del_init(&sop->so_strhash);
-	list_del_init(&sop->so_perlockowner);
 
+	unhash_stateowner(sop);
 	list_add_tail(&sop->so_close_lru, &close_lru);
 	sop->so_time = get_seconds();
 }
@@ -1456,7 +1459,8 @@ nfs4_laundromat(void)
 		}
 		dprintk("NFSD: purging unused open stateowner (so_id %d)\n",
 			sop->so_id);
-		release_stateowner(sop);
+		list_del(&sop->so_close_lru);
+		free_stateowner(sop);
 	}
 	if (clientid_val < NFSD_LAUNDROMAT_MINTIMEOUT)
 		clientid_val = NFSD_LAUNDROMAT_MINTIMEOUT;


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
