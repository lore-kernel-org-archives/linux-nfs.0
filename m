From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 006 of 16] nfsd4: don't reopen for delegated client
Date: Fri, 08 Apr 2005 11:00:16 +1000
Message-ID: <E1DJhr6-0006di-5d@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006U5-KH
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikM-0000uc-GV
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
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



We don't really need to be doing a separate open for every stateid.  And in the
case of an open from a client that already has a delegation on a file, it
unnecessarily results in a delegation recall.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   44 ++++++++++++++++++++++++++++++++++++--------
 1 files changed, 36 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:39:12.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:39:52.000000000 +1000
@@ -1547,6 +1547,24 @@ find_delegation_file(struct nfs4_file *f
 	return NULL;
 }
 
+static void
+nfs4_check_deleg(struct nfs4_file *fp, struct nfsd4_open *open,
+		struct nfs4_delegation **dp)
+{
+	int flags;
+	int status;
+
+	*dp = find_delegation_file(fp, &open->op_delegate_stateid);
+	if (*dp == NULL)
+		return;
+	flags = open->op_share_access == NFS4_SHARE_ACCESS_READ ?
+						RD_STATE : WR_STATE;
+	status = nfs4_check_delegmode(*dp, flags);
+	if (status)
+		*dp = NULL;
+	return;
+}
+
 static int
 nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_stateid **stpp)
 {
@@ -1572,21 +1590,28 @@ out:
 
 static int
 nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_stateid **stpp,
+		struct nfs4_delegation *dp,
 		struct svc_fh *cur_fh, int flags)
 {
 	struct nfs4_stateid *stp;
-	int status;
 
 	stp = kmalloc(sizeof(struct nfs4_stateid), GFP_KERNEL);
 	if (stp == NULL)
 		return nfserr_resource;
 
-	status = nfsd_open(rqstp, cur_fh, S_IFREG, flags, &stp->st_vfs_file);
-	if (status) {
-		if (status == nfserr_dropit)
-			status = nfserr_jukebox;
-		kfree(stp);
-		return status;
+	if (dp) {
+		get_file(dp->dl_vfs_file);
+		stp->st_vfs_file = dp->dl_vfs_file;
+	} else {
+		int status;
+		status = nfsd_open(rqstp, cur_fh, S_IFREG, flags,
+				&stp->st_vfs_file);
+		if (status) {
+			if (status == nfserr_dropit)
+				status = nfserr_jukebox;
+			kfree(stp);
+			return status;
+		}
 	}
 	vfsopen++;
 	*stpp = stp;
@@ -1720,6 +1745,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_stateid *stp = NULL;
+	struct nfs4_delegation *dp = NULL;
 	int status;
 
 	status = nfserr_inval;
@@ -1734,6 +1760,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	if (fp) {
 		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
+		nfs4_check_deleg(fp, open, &dp);
 	} else {
 		status = nfserr_resource;
 		fp = alloc_init_file(ino);
@@ -1757,7 +1784,8 @@ nfsd4_process_open2(struct svc_rqst *rqs
 			flags = MAY_WRITE;
 		else
 			flags = MAY_READ;
-		if ((status = nfs4_new_open(rqstp, &stp, current_fh, flags)))
+		status = nfs4_new_open(rqstp, &stp, dp, current_fh, flags);
+		if (status)
 			goto out;
 		init_stateid(stp, fp, open);
 		status = nfsd4_truncate(rqstp, current_fh, open);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
