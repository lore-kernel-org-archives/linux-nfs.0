From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 011 of 19] nfsd4: seqid comments
Date: Mon, 04 Jul 2005 11:01:43 +1000
Message-ID: <E1DpFLD-0007Gi-U2@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM7-0001kp-GG
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:39 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFM5-0007Zh-WB
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:39 -0700
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


Add some comments on the use of so_seqid, in an attempt to avoid some of
the confusion outlined in the previous patch....

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c          |    8 ++++----
 ./include/linux/nfsd/state.h |    4 +++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2005-07-04 10:57:52.000000000 +1000
@@ -1210,10 +1210,10 @@ nfsd4_decode_compound(struct nfsd4_compo
 	save = resp->p;
 
 /*
- * Routine for encoding the result of a
- * "seqid-mutating" NFSv4 operation.  This is
- * where seqids are incremented, and the
- * replay cache is filled.
+ * Routine for encoding the result of a "seqid-mutating" NFSv4 operation.  This
+ * is where sequence id's are incremented, and the replay cache is filled.
+ * Note that we increment sequence id's here, at the last moment, so we're sure
+ * we know whether the error to be returned is a sequence id mutating error.
  */
 
 #define ENCODE_SEQID_OP_TAIL(stateowner) do {			\

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-07-04 10:57:52.000000000 +1000
@@ -203,7 +203,9 @@ struct nfs4_stateowner {
 	int			so_is_open_owner; /* 1=openowner,0=lockowner */
 	u32                     so_id;
 	struct nfs4_client *    so_client;
-	u32                     so_seqid;    
+	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
+	 * sequence id expected from the client: */
+	u32                     so_seqid;
 	struct xdr_netobj       so_owner;     /* open owner name */
 	int                     so_confirmed; /* successful OPEN_CONFIRM? */
 	struct nfs4_replay	so_replay;


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
