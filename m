From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 10 of 18] nfsd4: move open owner checks from nfsd4_process_open2 into new function
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000kS-JR@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7D-00089E-HO
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:27 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7C-0006Bq-Pu
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:27 -0700
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



nfsd4_process_open2 has become a bit long and contorted.  The following patches
break nfsd4_process_open2 into smaller functions and add comments to describe
logic flow, in preparation for delegation state.

We begin by pulling out the code that searches for conflicting open owners into
a separate function.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   49 +++++++++++++++++++++++++++++++++----------------
 1 files changed, 33 insertions(+), 16 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:39.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:39.000000000 +1000
@@ -1249,6 +1249,31 @@ out:
 		status = nfserr_reclaim_bad;
 	return status;
 }
+
+static int
+nfs4_check_open(struct nfs4_file *fp, struct nfs4_stateowner *sop, struct nfsd4_open *open, struct nfs4_stateid **stpp)
+{
+	struct nfs4_stateid *local;
+	int status = nfserr_share_denied;
+
+	list_for_each_entry(local, &fp->fi_perfile, st_perfile) {
+		/* have we seen this open owner */
+		if (local->st_stateowner == sop) {
+			*stpp = local;
+			continue;
+		}
+		/* ignore lock owners */
+		if (local->st_stateowner->so_is_open_owner == 0)
+			continue;
+		/* check for conflicting share reservations */
+		if (!test_share(local, open))
+			goto out;
+	}
+	status = 0;
+out:
+	return status;
+}
+
 /*
  * called with nfs4_lock_state() held.
  */
@@ -1260,7 +1285,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct nfs4_file *fp = NULL;
 	struct inode *ino;
 	unsigned int fi_hashval;
-	struct nfs4_stateid *stq, *stp = NULL;
+	struct nfs4_stateid *stp = NULL;
 	int status;
 
 	status = nfserr_resource;
@@ -1272,24 +1297,16 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	status = nfserr_inval;
 	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
 		goto out;
-
+	/*
+	 * Lookup file; if found, lookup stateid and check open request;
+	 * not found, create
+	 */
 	fi_hashval = file_hashval(ino);
 	if (find_file(fi_hashval, ino, &fp)) {
-		/* Search for conflicting share reservations */
-		status = nfserr_share_denied;
-		list_for_each_entry(stq, &fp->fi_perfile, st_perfile) {
-			if (stq->st_stateowner == sop) {
-				stp = stq;
-				continue;
-			}
-			/* ignore lock owners */
-			if (stq->st_stateowner->so_is_open_owner == 0)
-				continue;
-			if (!test_share(stq,open))	
-				goto out;
-		}
+		status = nfs4_check_open(fp, sop, open, &stp);
+		if (status)
+			goto out;
 	} else {
-	/* No nfs4_file found; allocate and init a new one */
 		status = nfserr_resource;
 		if ((fp = alloc_init_file(fi_hashval, ino)) == NULL)
 			goto out;


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
