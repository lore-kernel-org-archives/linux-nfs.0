From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 36 of 54] nfsd4: remove dl_recall_cnt
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-000197-J0@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrq-00027y-WA
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrq-0005D4-0e
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
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



We don't need dl_recall_cnt any more, we're just using a local variable
in nfsd4_cb_recall.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |    1 -
 ./include/linux/nfsd/state.h |    1 -
 2 files changed, 2 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:07:01.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:25:47.000000000 +1100
@@ -161,7 +161,6 @@ alloc_init_deleg(struct nfs4_client *clp
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_state, NFS4_NO_RECALL);
 	atomic_set(&dp->dl_count, 1);
-	atomic_set(&dp->dl_recall_cnt, 0);
 	list_add(&dp->dl_del_perfile, &fp->fi_del_perfile);
 	list_add(&dp->dl_del_perclnt, &clp->cl_del_perclnt);
 	alloc_delegation++;

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 13:07:01.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 13:25:47.000000000 +1100
@@ -86,7 +86,6 @@ struct nfs4_delegation {
 	struct list_head	dl_del_perfile; /* nfs4_file->fi_del_perfile */
 	struct list_head	dl_del_perclnt; /* nfs4_client->cl_del_perclnt*/
 	struct list_head	dl_recall_lru;  /* delegation recalled */
-	atomic_t		dl_recall_cnt;  /* resend cb_recall only once */
 	atomic_t		dl_count;       /* ref count */
 	atomic_t		dl_state;       /* recall state */
 	struct nfs4_client	*dl_client;


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
