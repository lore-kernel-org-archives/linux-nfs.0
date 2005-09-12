From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 004 of 5] nfsd4: fix setclientid unlock of unlocked state lock
Date: Mon, 12 Sep 2005 16:25:41 +1000
Message-ID: <1050912062541.4005@cse.unsw.edu.au>
References: <20050912162037.1825.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EEhlI-0005MC-JZ
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:52 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EEhlF-0000SJ-Vq
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:52 -0700
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


We could try to unlock the state lock here without having first locked it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-09-12 16:12:02.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-09-12 16:12:13.000000000 +1000
@@ -678,13 +678,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 	int 			status;
 	char                    dname[HEXDIR_LEN];
 	
-	status = nfserr_inval;
 	if (!check_name(clname))
-		goto out;
+		return nfserr_inval;
 
 	status = nfs4_make_rec_clidname(dname, &clname);
 	if (status)
-		goto out;
+		return status;
 
 	/* 
 	 * XXX The Duplicate Request Cache (DRC) has been checked (??)


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
