From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 12 of 18] nfsd4: move seqid decrement on reclaim to separate function
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000ka-Mc@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi6u-00084h-9V
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:08 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi6t-00069a-Os
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:08 -0700
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


Move seqid decrement on reclaim to separate function

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:39.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:40.000000000 +1000
@@ -1274,6 +1274,20 @@ out:
 	return status;
 }
 
+/* decrement seqid on successful reclaim, it will be bumped in encode_open */
+static void
+nfs4_set_claim_prev(struct nfsd4_open *open, int *status)
+{
+	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
+		if (*status)
+			*status = nfserr_reclaim_bad;
+		else {
+			open->op_stateowner->so_confirmed = 1;
+			open->op_stateowner->so_seqid--;
+		}
+	}
+}
+
 /*
  * called with nfs4_lock_state() held.
  */
@@ -1369,17 +1383,8 @@ out:
 	if (fp && list_empty(&fp->fi_perfile))
 		release_file(fp);
 
-	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
-		if (status)
-			status = nfserr_reclaim_bad;
-		else {
-		/* successful reclaim. so_seqid is decremented because
-		* it will be bumped in encode_open
-		*/
-			open->op_stateowner->so_confirmed = 1;
-			open->op_stateowner->so_seqid--;
-		}
-	}
+	/* CLAIM_PREVIOUS has different error returns */
+	nfs4_set_claim_prev(open, &status);
 	/*
 	* To finish the open response, we just need to set the rflags.
 	*/


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
