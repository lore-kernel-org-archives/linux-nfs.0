From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 002 of 3] Fix some more errno/nfserr confusion in vfs.c
Date: Fri, 13 Jan 2006 14:14:28 +1100
Message-ID: <1060113031428.4660@cse.unsw.edu.au>
References: <20060113141059.4573.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExFOc-0001rZ-Ex
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 19:14:34 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExFOb-0002FY-OW
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 19:14:34 -0800
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


From: NeilBrown <neilb@suse.de>

nfsd_sync* return an errno, which usually needs to be converted to an errno,
sometimes immediately, sometimes a little later.

Also, nfsd_setattr returns an nfserr which SHOULDN'T be converted from
an errno (because it isn't one).

Also some tidyups of the form:
  err = XX
  err = nfserrno(err)
and
  err = XX
  if (err)
      err = nfserrno(err)
become
  err = nfserrno(XX)

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2006-01-13 12:37:26.000000000 +1100
+++ ./fs/nfsd/vfs.c	2006-01-13 13:20:55.000000000 +1100
@@ -891,9 +891,9 @@ nfsd_vfs_write(struct svc_rqst *rqstp, s
 	int			err = 0;
 	int			stable = *stablep;
 
+#ifdef MSNFS
 	err = nfserr_perm;
 
-#ifdef MSNFS
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
 		(!lock_may_write(file->f_dentry->d_inode, offset, cnt)))
 		goto out;
@@ -1065,8 +1065,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
 		if (file->f_op && file->f_op->fsync) {
-			err = nfsd_sync(file);
-			err = nfserrno(err);
+			err = nfserrno(nfsd_sync(file));
 		} else {
 			err = nfserr_notsupp;
 		}
@@ -1177,7 +1176,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
 		goto out_nfserr;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfsd_sync_dir(dentry);
+		err = nfserrno(nfsd_sync_dir(dentry));
 		write_inode_now(dchild->d_inode, 1);
 	}
 
@@ -1310,9 +1309,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		goto out_nfserr;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfsd_sync_dir(dentry);
-		if (err)
-			err = nfserrno(err);
+		err = nfserrno(nfsd_sync_dir(dentry));
 		/* setattr will sync the child (or not) */
 	}
 
@@ -1339,7 +1336,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID)) != 0) {
  		int err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
 		if (err2)
-			err = nfserrno(err2);
+			err = err2;
 	}
 
 	/*
@@ -1514,10 +1511,8 @@ nfsd_link(struct svc_rqst *rqstp, struct
 	err = vfs_link(dold, dirp, dnew);
 	if (!err) {
 		if (EX_ISSYNC(ffhp->fh_export)) {
-			err = nfsd_sync_dir(ddir);
+			err = nfserrno(nfsd_sync_dir(ddir));
 			write_inode_now(dest, 1);
-			if (err)
-				err = nfserrno(err);
 		}
 	} else {
 		if (err == -EXDEV && rqstp->rq_vers == 2)


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
