From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 18 of 23] Remove unnecessary stateowner existence check.
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002eW-Vk@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbz-0005Au-9K
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:07 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAby-0006Ak-0r
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:07 -0800
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


At OPEN:
Check for delegations in the process of being recalled.
Attempt to hand out a delegation.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   36 +++++++++++++++++++-----------------
 1 files changed, 19 insertions(+), 17 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:50.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:51.000000000 +1100
@@ -1708,28 +1708,24 @@ nfsd4_process_open2(struct svc_rqst *rqs
 {
 	struct nfs4_stateowner *sop = open->op_stateowner;
 	struct nfs4_file *fp = NULL;
-	struct inode *ino;
+	struct inode *ino = current_fh->fh_dentry->d_inode;
 	unsigned int fi_hashval;
 	struct nfs4_stateid *stp = NULL;
-	int status;
-
-	status = nfserr_resource;
-	if (!sop)
-		return status;
-
-	ino = current_fh->fh_dentry->d_inode;
+	int status, delegflag = 0;
 
 	status = nfserr_inval;
 	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
 		goto out;
 	/*
-	 * Lookup file; if found, lookup stateid and check open request;
-	 * not found, create
+	 * Lookup file; if found, lookup stateid and check open request,
+	 * and check for delegations in the process of being recalled.
+	 * If not found, create the nfs4_file struct
 	 */
 	fi_hashval = file_hashval(ino);
 	if (find_file(fi_hashval, ino, &fp)) {
-		status = nfs4_check_open(fp, sop, open, &stp);
-		if (status)
+		if ((status = nfs4_check_open(fp, sop, open, &stp)))
+			goto out;
+		if ((status = nfs4_check_deleg_recall(fp, open, &delegflag)))
 			goto out;
 	} else {
 		status = nfserr_resource;
@@ -1769,14 +1765,20 @@ nfsd4_process_open2(struct svc_rqst *rqs
 			}
 		}
 	}
-	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n",
-	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,
-	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
-
 	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
 
-	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
+	/*
+	* Attempt to hand out a delegation. No error return, because the
+	* OPEN succeeds even if we fail.
+	*/
+	nfs4_open_delegation(current_fh, open, stp, &delegflag);
+	open->op_delegate_type = delegflag;
+
 	status = nfs_ok;
+
+	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n",
+	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,
+	            stp->st_stateid.si_fileid, stp->st_stateid.si_generation);
 out:
 	/* take the opportunity to clean up unused state */
 	if (fp && list_empty(&fp->fi_perfile))


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
