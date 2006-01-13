From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 004 of 26] nfsd4: misc lock fixes
Date: Fri, 13 Jan 2006 12:00:51 +1100
Message-ID: <1060113010051.22974@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJN-0002Y7-Tn
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:01 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJN-0006iM-Ft
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:02 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:55 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:52 +1100
To: nfs@lists.sourceforge.net
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


Logic fixes for LOCK and UNLOCK.

- Move the permission check on the current file handle outside of
nfs4_lock_state()
- remove the file manager fl_release_private calls; fl_ops is not set.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:50:54.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:05.000000000 +1100
@@ -2700,6 +2700,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	if (check_lock_length(lock->lk_offset, lock->lk_length))
 		 return nfserr_inval;
 
+	if ((status = fh_verify(rqstp, current_fh, S_IFREG, MAY_LOCK))) {
+		dprintk("NFSD: nfsd4_lock: permission denied!\n");
+		return status;
+	}
+
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
@@ -2757,11 +2762,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	/* lock->lk_stateowner and lock_stp have been created or found */
 	filp = lock_stp->st_vfs_file;
 
-	if ((status = fh_verify(rqstp, current_fh, S_IFREG, MAY_LOCK))) {
-		dprintk("NFSD: nfsd4_lock: permission denied!\n");
-		goto out;
-	}
-
 	status = nfserr_grace;
 	if (nfs4_in_grace() && !lock->lk_reclaim)
 		goto out;
@@ -2802,8 +2802,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	*/
 
 	status = posix_lock_file(filp, &file_lock);
-	if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
-		file_lock.fl_ops->fl_release_private(&file_lock);
 	dprintk("NFSD: nfsd4_lock: posix_lock_file status %d\n",status);
 	switch (-status) {
 	case 0: /* success! */
@@ -2977,8 +2975,6 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	*  Try to unlock the file in the VFS.
 	*/
 	status = posix_lock_file(filp, &file_lock); 
-	if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
-		file_lock.fl_ops->fl_release_private(&file_lock);
 	if (status) {
 		dprintk("NFSD: nfs4_locku: posix_lock_file failed!\n");
 		goto out_nfserr;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
