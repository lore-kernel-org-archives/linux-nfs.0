From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - kNFSd in 2.5.15 - Cleanup of nfsd_open
Date: Wed, 15 May 2002 15:27:23 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15585.61883.17544.546267@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177rKC-0002qV-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 22:27:45 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <hch@infradead.org>) By tone With Smtp ;
	Wed, 15 May 2002 15:27:36 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: Christoph Hellwig <hch@infradead.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 14 May 2002 13:02:50 +0100

This patch makes nfsd_open use init_private_file to initilize
the file pointer the caller had allocated on stack.  In addition
a number of small cleanups:

 - format comments to be readable on 80char ANSI terminal
 - don't fop_get (and fop_put in nfsd_close), out file already
   is a reference to the inode so they can't go away.
 - don't decrement f_count on failure - it won't be checked anyway
 - don't check for filp->f_op n nfsd_close, it can't be NULL

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |   54 +++++++++++++++++++++---------------------------------
 1 files changed, 21 insertions(+), 33 deletions(-)

--- ./fs/nfsd/vfs.c	2002/05/15 05:09:12	1.1
+++ ./fs/nfsd/vfs.c	2002/05/15 05:14:49	1.2
@@ -414,11 +414,13 @@
 {
 	struct dentry	*dentry;
 	struct inode	*inode;
-	int		err;
+	int		flags = O_RDONLY|O_LARGEFILE, mode = FMODE_READ, err;
 
-	/* If we get here, then the client has already done an "open", and (hopefully)
-	 * checked permission - so allow OWNER_OVERRIDE in case a chmod has now revoked
-	 * permission */
+	/*
+	 * If we get here, then the client has already done an "open",
+	 * and (hopefully) checked permission - so allow OWNER_OVERRIDE
+	 * in case a chmod has now revoked permission.
+	 */
 	err = fh_verify(rqstp, fhp, type, access | MAY_OWNER_OVERRIDE);
 	if (err)
 		goto out;
@@ -443,37 +445,24 @@
 	if (err)
 		goto out_nfserr;
 
-	if ((access & MAY_WRITE) && (err = get_write_access(inode)) != 0)
-		goto out_nfserr;
-
-	memset(filp, 0, sizeof(*filp));
-	filp->f_op    = fops_get(inode->i_fop);
-	atomic_set(&filp->f_count, 1);
-	filp->f_dentry = dentry;
-	filp->f_vfsmnt = fhp->fh_export->ex_mnt;
 	if (access & MAY_WRITE) {
-		filp->f_flags = O_WRONLY|O_LARGEFILE;
-		filp->f_mode  = FMODE_WRITE;
+		err = get_write_access(inode);
+		if (err)
+			goto out_nfserr;
+
+		flags = O_WRONLY|O_LARGEFILE;
+		mode  = FMODE_WRITE;
+
 		DQUOT_INIT(inode);
-	} else {
-		filp->f_flags = O_RDONLY|O_LARGEFILE;
-		filp->f_mode  = FMODE_READ;
 	}
 
-	err = 0;
-	if (filp->f_op && filp->f_op->open) {
-		err = filp->f_op->open(inode, filp);
-		if (err) {
-			fops_put(filp->f_op);
-			if (access & MAY_WRITE)
-				put_write_access(inode);
-
-			/* I nearly added put_filp() call here, but this filp
-			 * is really on callers stack frame. -DaveM
-			 */
-			atomic_dec(&filp->f_count);
-		}
-	}
+	err = init_private_file(filp, dentry, mode);
+	if (!err) {
+		filp->f_flags = flags;
+		filp->f_vfsmnt = fhp->fh_export->ex_mnt;
+	} else if (access & MAY_WRITE)
+		put_write_access(inode);
+
 out_nfserr:
 	if (err)
 		err = nfserrno(err);
@@ -490,9 +479,8 @@
 	struct dentry	*dentry = filp->f_dentry;
 	struct inode	*inode = dentry->d_inode;
 
-	if (filp->f_op && filp->f_op->release)
+	if (filp->f_op->release)
 		filp->f_op->release(inode, filp);
-	fops_put(filp->f_op);
 	if (filp->f_mode & FMODE_WRITE)
 		put_write_access(inode);
 }

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
