From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 34 - Nfsdv4 pointer cleanup
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006HI-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPq4-0006rq-Dp
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:16 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPpj-0005Zj-JS
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:49:55 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:41 +1100
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


From: "William A.(Andy) Adamson" <andros@citi.umich.edu>

Compare inode pointers instead of dentry pointers when checking an
inode refered to by a stateid against an inode refered to by a file
handle.

Set st_vfs_set to 0 if the stateid/file handle check fails to
avoid referencing bad state when reaping stateid's.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:30.000000000 +1100
@@ -1303,7 +1303,8 @@ find_openstateowner_id(u32 st_id) {
 static inline int
 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stateid *stp)
 {
-	return (fhp->fh_dentry != stp->st_vfs_file.f_dentry);
+	return (stp->st_vfs_set == 0 ||
+		fhp->fh_dentry->d_inode != stp->st_vfs_file.f_dentry->d_inode);
 }
 
 static int
@@ -1346,6 +1347,7 @@ nfs4_preprocess_stateid_op(struct svc_fh
 	}
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
 		dprintk("NFSD: preprocess_stateid_op: fh-stateid mismatch!\n");
+		stp->st_vfs_set = 0;
 		goto out;
 	}
 	if (!stp->st_stateowner->so_confirmed) {
@@ -1414,6 +1416,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
 		printk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
+		stp->st_vfs_set = 0;
 		goto out;
 	}
 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
