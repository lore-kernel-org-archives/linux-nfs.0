From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 18 of 18] nfsd4: move code to truncate on open to separate function
Date: Fri, 24 Sep 2004 14:54:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6g-0000l8-Am@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7r-0008Ec-Qs
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:07 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7r-0008Mi-2Y
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:07 -0700
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


for OPEN with O_TRUNC, if the truncate fails, the open fails. for
nfs4_open_upgrade, this means undo the get_write_access. for new OPENs, this
means release the newly created stateid.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:41.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:41.000000000 +1000
@@ -1301,6 +1301,18 @@ nfs4_upgrade_open(struct svc_rqst *rqstp
 		status = get_write_access(inode);
 		if (status)
 			return nfserrno(status);
+		if (open->op_truncate) {
+			struct iattr iattr = {
+				.ia_valid = ATTR_SIZE,
+				.ia_size = 0,
+			};
+			status = nfsd_setattr(rqstp, cur_fh, &iattr, 0,
+					(time_t)0);
+			if (status) {
+				put_write_access(inode);
+				return status;
+			}
+		}
 
 		/* remember the open */
 		filp->f_mode = (filp->f_mode | FMODE_WRITE) & ~FMODE_READ;
@@ -1331,7 +1343,6 @@ nfs4_set_claim_prev(struct nfsd4_open *o
 int
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
-	struct iattr iattr;
 	struct nfs4_stateowner *sop = open->op_stateowner;
 	struct nfs4_file *fp = NULL;
 	struct inode *ino;
@@ -1382,18 +1393,23 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		if ((status = nfs4_new_open(rqstp, &stp, current_fh, flags)))
 			goto out;
 		init_stateid(stp, fp, sop, open);
+		if (open->op_truncate) {
+			struct iattr iattr = {
+				.ia_valid = ATTR_SIZE,
+				.ia_size = 0,
+			};
+			status = nfsd_setattr(rqstp, current_fh, &iattr, 0,
+					(time_t)0);
+			if (status) {
+				release_stateid(stp, OPEN_STATE);
+				goto out;
+			}
+		}
 	}
 	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n",
 	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,
 	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
 
-	if (open->op_truncate) {
-		iattr.ia_valid = ATTR_SIZE;
-		iattr.ia_size = 0;
-		status = nfsd_setattr(rqstp, current_fh, &iattr, 0, (time_t)0);
-		if (status)
-			goto out;
-	}
 	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
