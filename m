From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 14 of 18] nfsd4: move open_upgrade code into a separate function
Date: Fri, 24 Sep 2004 14:54:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6g-0000kk-3t@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7E-00089s-V7
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:28 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7E-0008JY-09
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



Move most of the code for the open_upgrade case into a separate
nfs4_upgrade_open.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   58 +++++++++++++++++++++++++-------------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:40.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:40.000000000 +1000
@@ -1131,20 +1131,6 @@ nfs4_share_conflict(struct svc_fh *curre
 	return nfs_ok;
 }
 
-static inline int
-nfs4_file_upgrade(struct file *filp, unsigned int share_access)
-{
-int status;
-
-	if (share_access & NFS4_SHARE_ACCESS_WRITE) {
-		status = get_write_access(filp->f_dentry->d_inode);
-		if (status)
-			return nfserrno(status);
-		filp->f_mode = (filp->f_mode | FMODE_WRITE) & ~FMODE_READ;
-	}
-	return nfs_ok;
-}
-
 static inline void
 nfs4_file_downgrade(struct file *filp, unsigned int share_access)
 {
@@ -1274,6 +1260,33 @@ out:
 	return status;
 }
 
+static int
+nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_stateid *stp, struct nfsd4_open *open)
+{
+	struct file *filp = stp->st_vfs_file;
+	struct inode *inode = filp->f_dentry->d_inode;
+	unsigned int share_access;
+	int status;
+
+	set_access(&share_access, stp->st_access_bmap);
+	share_access = ~share_access;
+	share_access &= open->op_share_access;
+
+	/* update the struct file */
+	if (share_access & NFS4_SHARE_ACCESS_WRITE) {
+		status = get_write_access(inode);
+		if (status)
+			return nfserrno(status);
+
+		/* remember the open */
+		filp->f_mode = (filp->f_mode | FMODE_WRITE) & ~FMODE_READ;
+		set_bit(open->op_share_access, &stp->st_access_bmap);
+		set_bit(open->op_share_deny, &stp->st_deny_bmap);
+	}
+	return nfs_ok;
+}
+
+
 /* decrement seqid on successful reclaim, it will be bumped in encode_open */
 static void
 nfs4_set_claim_prev(struct nfsd4_open *open, int *status)
@@ -1327,21 +1340,10 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	}
 
 	if (stp) {
-		/* This is an upgrade of an existing OPEN.
-		 * OR the incoming share with the existing
-		 * nfs4_stateid share */
-		unsigned int share_access;
-
-		set_access(&share_access, stp->st_access_bmap);
-		share_access = ~share_access;
-		share_access &= open->op_share_access;
-
-		/* update the struct file */
-		if ((status = nfs4_file_upgrade(stp->st_vfs_file, share_access)))
+		/* Stateid was found, this is an OPEN upgrade */
+		status = nfs4_upgrade_open(rqstp, current_fh, stp, open);
+		if (status)
 			goto out;
-		/* remember the open */
-		set_bit(open->op_share_access, &stp->st_access_bmap);
-		set_bit(open->op_share_deny, &stp->st_deny_bmap);
 	} else {
 		int flags = 0;
 


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
