From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 23 of 23] Clear the recall_lru of delegations at shutdown
Date: Fri, 17 Dec 2004 16:23:57 +1100
Message-ID: <E1CfAar-0002eq-JW@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbz-0005Aw-L2
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:07 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAby-0004GJ-9E
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:07 -0800
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


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   10 ++++++++++
 1 files changed, 10 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:51.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:51.000000000 +1100
@@ -3208,6 +3208,8 @@ __nfs4_state_shutdown(void)
 {
 	int i;
 	struct nfs4_client *clp = NULL;
+	struct nfs4_delegation *dp = NULL;
+	struct list_head *pos, *next;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		while (!list_empty(&conf_id_hashtbl[i])) {
@@ -3219,6 +3221,14 @@ __nfs4_state_shutdown(void)
 			expire_client(clp);
 		}
 	}
+	spin_lock(&recall_lock);
+	list_for_each_safe(pos, next, &del_recall_lru) {
+		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
+		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+		release_delegation(dp);
+	}
+	spin_unlock(&recall_lock);
+
 	release_all_files();
 	cancel_delayed_work(&laundromat_work);
 	flush_scheduled_work();


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
