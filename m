From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 16 of 18] Clean up nfsd4_process_open2
Date: Fri, 24 Sep 2004 14:54:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6g-0000l0-6q@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7o-0008E2-8a
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:04 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7n-0006Ff-GY
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:04 -0700
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


Comments, dprintk cleanup

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:40.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:41.000000000 +1000
@@ -1363,6 +1363,10 @@ nfsd4_process_open2(struct svc_rqst *rqs
 			goto out;
 	}
 
+	/*
+	 * OPEN the file, or upgrade an existing OPEN.
+	 * If truncate fails, the OPEN fails.
+	 */
 	if (stp) {
 		/* Stateid was found, this is an OPEN upgrade */
 		status = nfs4_upgrade_open(rqstp, current_fh, stp, open);
@@ -1379,7 +1383,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 			goto out;
 		init_stateid(stp, fp, sop, open);
 	}
-	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n\n",
+	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n",
 	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,
 	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
 
@@ -1395,6 +1399,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
 	status = nfs_ok;
 out:
+	/* take the opportunity to clean up unused state */
 	if (fp && list_empty(&fp->fi_perfile))
 		release_file(fp);
 


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
