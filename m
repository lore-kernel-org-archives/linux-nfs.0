From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 1 of 18] nfsd4 fix: nfsd oopsed when encountering a conflict with a local lock
Date: Fri, 24 Sep 2004 14:54:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6e-0000jo-Ue@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7D-00089M-Md
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:27 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7D-0006Br-26
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



Bug Fix: Non NFSD conflicting byte-range locks were causing an Oops.

Encode a zero length owner and zero clientid for non NFSD conflicting locks 
in the lock_denied response.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-09-24 14:47:18.000000000 +1000
@@ -1995,13 +1995,18 @@ nfsd4_encode_lock_denied(struct nfsd4_co
 {
 	ENCODE_HEAD;
 
-	RESERVE_SPACE(32 + XDR_LEN(ld->ld_sop->so_owner.len));
+	RESERVE_SPACE(32 + XDR_LEN(ld->ld_sop ? ld->ld_sop->so_owner.len : 0));
 	WRITE64(ld->ld_start);
 	WRITE64(ld->ld_length);
 	WRITE32(ld->ld_type);
-	WRITEMEM(&ld->ld_sop->so_client->cl_clientid, 8);
-	WRITE32(ld->ld_sop->so_owner.len);
-	WRITEMEM(ld->ld_sop->so_owner.data, ld->ld_sop->so_owner.len);
+	if (ld->ld_sop) {
+		WRITEMEM(&ld->ld_sop->so_client->cl_clientid, 8);
+		WRITE32(ld->ld_sop->so_owner.len);
+		WRITEMEM(ld->ld_sop->so_owner.data, ld->ld_sop->so_owner.len);
+	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
+		WRITE64((u64)0); /* clientid */
+		WRITE32(0); /* length of owner name */
+	}
 	ADJUST_ARGS();
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
