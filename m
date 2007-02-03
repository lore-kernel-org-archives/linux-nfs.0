From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 7/14] nfsd4: Convert NFSv4 to new lock interface
Date: Sat,  3 Feb 2007 00:34:03 -0500
Message-ID: <33597.1863511533$1170480898@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email->
	<11704808502512-git-send-email-> <11704808513862-git-send-email->
	<1170480851972-git-send-email->
	<11704808513070-git-send-email-> <117048085185-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDDXS-0001Ha-Iz
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:17 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDDXU-0001Bl-5L
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:16 -0800
In-Reply-To: <117048085185-git-send-email->
Message-Id: <d1c313156428c533721d67f938ca72759b192156.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Convert NFSv4 to the new lock interface.  We don't define any callback for now,
so we're not taking advantage of the asynchronous feature--that's less critical
for the multi-threaded nfsd then it is for the single-threaded lockd.  But this
does allow a cluster filesystems to export cluster-coherent locking to NFS.

Note that it's cluster filesystems that are the issue--of the filesystems that
define lock methods (nfs, cifs, etc.), most are not exportable by nfsd.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9de89df..5d5a454 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -50,6 +50,7 @@
 #include <linux/nfsd/xdr4.h>
 #include <linux/namei.h>
 #include <linux/mutex.h>
+#include <linux/lockd/bind.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -2772,7 +2773,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * locks_copy_lock: */
 	conflock.fl_ops = NULL;
 	conflock.fl_lmops = NULL;
-	err = posix_lock_file_conf(filp, &file_lock, &conflock);
+	err = vfs_lock_file_conf(filp, &file_lock, &conflock);
 	switch (-err) {
 	case 0: /* success! */
 		update_stateid(&lock_stp->st_stateid);
@@ -2789,7 +2790,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_deadlock;
 		break;
 	default:        
-		dprintk("NFSD: nfsd4_lock: posix_lock_file_conf() failed! status %d\n",err);
+		dprintk("NFSD: nfsd4_lock: vfs_lock_file_conf() failed! status %d\n",err);
 		status = nfserr_resource;
 		break;
 	}
@@ -2815,6 +2816,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file file;
 	struct file_lock file_lock;
 	struct file_lock conflock;
+	int error;
 	__be32 status;
 
 	if (nfs4_in_grace())
@@ -2870,16 +2872,23 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_transform_lock_offset(&file_lock);
 
-	/* posix_test_lock uses the struct file _only_ to resolve the inode.
+	/* vfs_test_lock uses the struct file _only_ to resolve the inode.
 	 * since LOCKT doesn't require an OPEN, and therefore a struct
-	 * file may not exist, pass posix_test_lock a struct file with
+	 * file may not exist, pass vfs_test_lock a struct file with
 	 * only the dentry:inode set.
 	 */
 	memset(&file, 0, sizeof (struct file));
 	file.f_path.dentry = cstate->current_fh.fh_dentry;
 
 	status = nfs_ok;
-	if (posix_test_lock(&file, &file_lock, &conflock)) {
+	conflock.fl_ops = NULL;
+	conflock.fl_lmops = NULL;
+	error = vfs_test_lock(&file, &file_lock, &conflock);
+	if (error) {
+		status = nfserrno(error);
+		goto out;
+	}
+	if (conflock.fl_type != F_UNLCK) {
 		status = nfserr_denied;
 		nfs4_set_lock_denied(&conflock, &lockt->lt_denied);
 	}
@@ -2934,9 +2943,9 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/*
 	*  Try to unlock the file in the VFS.
 	*/
-	err = posix_lock_file(filp, &file_lock);
+	err = vfs_lock_file(filp, F_SETLK, &file_lock);
 	if (err) {
-		dprintk("NFSD: nfs4_locku: posix_lock_file failed!\n");
+		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
 		goto out_nfserr;
 	}
 	/*
-- 
1.5.0.rc1.g72fe


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
