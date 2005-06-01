From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 010 of 28] nfsd4: remove nfs4_reclaim_init
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006iA-Hu@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3J-0005vw-08
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3H-0002Q4-M0
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


nfs4_reclaim_init is no longer performing any useful function.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    3 ---
 1 files changed, 3 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:00.000000000 +1000
@@ -54,7 +54,6 @@
 /* Globals */
 static time_t lease_time = 90;     /* default lease time */
 static time_t user_lease_time = 90;
-static u32 nfs4_reclaim_init = 0;
 time_t boot_time;
 static time_t grace_end = 0;
 static u32 current_clientid = 1;
@@ -3128,7 +3127,6 @@ nfs4_release_reclaim(void)
 	struct nfs4_client_reclaim *crp = NULL;
 	int i;
 
-	BUG_ON(!nfs4_reclaim_init);
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		while (!list_empty(&reclaim_str_hashtbl[i])) {
 			crp = list_entry(reclaim_str_hashtbl[i].next,
@@ -3214,7 +3212,6 @@ nfs4_state_init(void)
 	for (i = 0; i < CLIENT_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
 	reclaim_str_hashtbl_size = 0;
-	nfs4_reclaim_init = 1;
 }
 
 /* initialization to perform when the nfsd service is started: */


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
