From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 15 of 18] nfsd4: move some nfsd4_process_open2 code to nfs4_new_open
Date: Fri, 24 Sep 2004 14:54:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6g-0000kw-5D@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7q-0008EP-9j
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:06 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7n-0006Fe-Tm
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:56:05 -0700
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



Move most of the code in the new_open case of nfsd4_process_open2 to
nfs4_new_open.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   44 +++++++++++++++++++++++++++-----------------
 1 files changed, 27 insertions(+), 17 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:48:40.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:40.000000000 +1000
@@ -1261,6 +1261,30 @@ out:
 }
 
 static int
+nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_stateid **stpp,
+		struct svc_fh *cur_fh, int flags)
+{
+	struct nfs4_stateid *stp;
+	int status;
+
+	stp = kmalloc(sizeof(struct nfs4_stateid), GFP_KERNEL);
+	if (stp == NULL)
+		return nfserr_resource;
+
+	status = nfsd_open(rqstp, cur_fh, S_IFREG, flags, &stp->st_vfs_file);
+	if (status) {
+		if (status == nfserr_dropit)
+			status = nfserr_jukebox;
+		kfree(stp);
+		return status;
+	}
+	vfsopen++;
+	stp->st_vfs_set = 1;
+	*stpp = stp;
+	return 0;
+}
+
+static int
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_stateid *stp, struct nfsd4_open *open)
 {
 	struct file *filp = stp->st_vfs_file;
@@ -1345,26 +1369,15 @@ nfsd4_process_open2(struct svc_rqst *rqs
 		if (status)
 			goto out;
 	} else {
+		/* Stateid was not found, this is a new OPEN */
 		int flags = 0;
-
-		status = nfserr_resource;
-		if ((stp = kmalloc(sizeof(struct nfs4_stateid),
-						GFP_KERNEL)) == NULL)
-			goto out;
-
 		if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 			flags = MAY_WRITE;
 		else
 			flags = MAY_READ;
-		if ((status = nfsd_open(rqstp, current_fh,  S_IFREG,
-			                      flags,
-			                      &stp->st_vfs_file)) != 0)
-			goto out_free;
-
-		vfsopen++;
-
+		if ((status = nfs4_new_open(rqstp, &stp, current_fh, flags)))
+			goto out;
 		init_stateid(stp, fp, sop, open);
-		stp->st_vfs_set = 1;
 	}
 	dprintk("nfs4_process_open2: stateid=(%08x/%08x/%08x/%08x)\n\n",
 	            stp->st_stateid.si_boot, stp->st_stateid.si_stateownerid,
@@ -1395,9 +1408,6 @@ out:
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 
 	return status;
-out_free:
-	kfree(stp);
-	goto out;
 }
 
 static struct work_struct laundromat_work;


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
