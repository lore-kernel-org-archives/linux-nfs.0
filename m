From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 8 of 18] nfsd4: fix race in xdr encoding of lock_denied response.
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000kK-GA@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7E-00089U-4D
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:28 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7C-0008Ja-Hz
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:28 -0700
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



We take a reference on the stateowner, and copy the clientid, instead of just
hoping no one destroys the stateowner before we reference it in
nfsd4_encode_lock_denied.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |    5 ++++-
 ./fs/nfsd/nfs4xdr.c         |    3 ++-
 ./include/linux/nfsd/xdr4.h |    1 +
 3 files changed, 7 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:38.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:39.000000000 +1000
@@ -1948,8 +1948,11 @@ nfs4_set_lock_denied(struct file_lock *f
 	unsigned int hval = lockownerid_hashval(sop->so_id);
 
 	deny->ld_sop = NULL;
-	if (nfs4_verify_lock_stateowner(sop, hval))
+	if (nfs4_verify_lock_stateowner(sop, hval)) {
+		kref_get(&sop->so_ref);
 		deny->ld_sop = sop;
+		deny->ld_clientid = sop->so_client->cl_clientid;
+	}
 	deny->ld_start = fl->fl_start;
 	deny->ld_length = ~(u64)0;
 	if (fl->fl_end != ~(u64)0)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-09-24 14:48:38.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-09-24 14:48:39.000000000 +1000
@@ -1994,9 +1994,10 @@ nfsd4_encode_lock_denied(struct nfsd4_co
 	WRITE64(ld->ld_length);
 	WRITE32(ld->ld_type);
 	if (ld->ld_sop) {
-		WRITEMEM(&ld->ld_sop->so_client->cl_clientid, 8);
+		WRITEMEM(&ld->ld_clientid, 8);
 		WRITE32(ld->ld_sop->so_owner.len);
 		WRITEMEM(ld->ld_sop->so_owner.data, ld->ld_sop->so_owner.len);
+		kref_put(&ld->ld_sop->so_ref, nfs4_free_stateowner);
 	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
 		WRITE64((u64)0); /* clientid */
 		WRITE32(0); /* length of owner name */

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2004-09-24 14:48:39.000000000 +1000
@@ -116,6 +116,7 @@ struct nfsd4_link {
 };
 
 struct nfsd4_lock_denied {
+	clientid_t	ld_clientid;
 	struct nfs4_stateowner   *ld_sop;
 	u64             ld_start;
 	u64             ld_length;


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
