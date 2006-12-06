From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2/10] nfsd4: Convert NFSv4 to new lock interface
Date: Wed,  6 Dec 2006 00:34:12 -0500
Message-ID: <11653832603105-git-send-email-bfields@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org> <1165383260627-git-send-email-bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <1165383260627-git-send-email-bfields@fieldses.org>
Message-Id: <cc7b88076df17bb41ac5d536de174b44eda6b73c.1165380893.git.bfields@citi.umich.edu>
In-Reply-To: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
To: me <bfields@umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@fieldses.org>

Convert NFSv4 to the new lock interface.  We don't define any callback for
now, so we're not taking advantage of the asynchronous feature--that's less
critical for the multi-threaded nfsd then it is for the single-threaded
lockd.  But this does allow a cluster filesystem to export cluster-coherent
locking to NFS.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc0634d..140298a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -50,6 +50,7 @@
 #include <linux/nfsd/xdr4.h>
 #include <linux/namei.h>
 #include <linux/mutex.h>
+#include <linux/lockd/bind.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -2759,7 +2760,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock
 	 * locks_copy_lock: */
 	conflock.fl_ops = NULL;
 	conflock.fl_lmops = NULL;
-	err = posix_lock_file_conf(filp, &file_lock, &conflock);
+	err = vfs_lock_file_conf(filp, &file_lock, &conflock);
 	switch (-err) {
 	case 0: /* success! */
 		update_stateid(&lock_stp->st_stateid);
@@ -2776,7 +2777,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock
 		status = nfserr_deadlock;
 		break;
 	default:        
-		dprintk("NFSD: nfsd4_lock: posix_lock_file_conf() failed! status %d\n",err);
+		dprintk("NFSD: nfsd4_lock: vfs_lock_file_conf() failed! status %d\n",err);
 		status = nfserr_resource;
 		break;
 	}
@@ -2856,16 +2857,16 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock
 
 	nfs4_transform_lock_offset(&file_lock);
 
-	/* posix_test_lock uses the struct file _only_ to resolve the inode.
+	/* vfs_test_lock uses the struct file _only_ to resolve the inode.
 	 * since LOCKT doesn't require an OPEN, and therefore a struct
-	 * file may not exist, pass posix_test_lock a struct file with
+	 * file may not exist, pass vfs_test_lock a struct file with
 	 * only the dentry:inode set.
 	 */
 	memset(&file, 0, sizeof (struct file));
 	file.f_dentry = current_fh->fh_dentry;
 
 	status = nfs_ok;
-	if (posix_test_lock(&file, &file_lock, &conflock)) {
+	if (vfs_test_lock(&file, &file_lock, &conflock)) {
 		status = nfserr_denied;
 		nfs4_set_lock_denied(&conflock, &lockt->lt_denied);
 	}
@@ -2919,9 +2920,9 @@ nfsd4_locku(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lock
 	/*
 	*  Try to unlock the file in the VFS.
 	*/
-	err = posix_lock_file(filp, &file_lock);
+	err = vfs_lock_file(filp, &file_lock);
 	if (err) {
-		dprintk("NFSD: nfs4_locku: posix_lock_file failed!\n");
+		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
 		goto out_nfserr;
 	}
 	/*
-- 
1.4.4.1

