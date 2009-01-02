Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60763 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbZABAgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jan 2009 19:36:54 -0500
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Cc: Marc Eshel <eshel@almaden.ibm.com>,
        "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd: do a temporary open for LOCKT
Date: Thu,  1 Jan 2009 19:36:51 -0500
Message-Id: <1230856611-32574-3-git-send-email-bfields@citi.umich.edu>
In-Reply-To: <1230856611-32574-2-git-send-email-bfields@citi.umich.edu>
References: <1230856611-32574-1-git-send-email-bfields@citi.umich.edu>
 <1230856611-32574-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I've got a slight fear that the problem Marc tripped across won't be the
last that's caused by this hack of faking up a struct file with only
some fields initialized.  We may as well just do an open, just as we do
with reads and writes in the v2/v3 case, and get a proper struct file.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   33 ++++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 83f8e21..800b531 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2770,6 +2770,25 @@ out:
 }
 
 /*
+ * The NFSv4 spec allows a client to do a LOCKT without holding an OPEN,
+ * so we do a temporary open here just to get an open file to pass to
+ * vfs_test_lock.  (Arguably perhaps test_lock should be done with an
+ * inode operation.)
+ */
+static int nfsd_test_lock(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file_lock *lock)
+{
+	struct file *file;
+	int err;
+
+	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
+	if (err)
+		return err;
+	err = vfs_test_lock(file, lock);
+	nfsd_close(file);
+	return err;
+}
+
+/*
  * LOCKT operation
  */
 __be32
@@ -2777,7 +2796,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_lockt *lockt)
 {
 	struct inode *inode;
-	struct file file;
 	struct file_lock file_lock;
 	int error;
 	__be32 status;
@@ -2835,19 +2853,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_transform_lock_offset(&file_lock);
 
-	/*
-	 * vfs_test_lock uses the struct file _only_ to resolve the inode.
-	 * since LOCKT doesn't require an OPEN, and therefore a struct
-	 * file may not exist, pass vfs_test_lock a struct file with
-	 * only the dentry and i_fop (in case the filesystem defines
-	 * its own lock method) set.
-	 */
-	memset(&file, 0, sizeof (struct file));
-	file.f_path.dentry = cstate->current_fh.fh_dentry;
-	file.f_op = inode->i_fop;
-
 	status = nfs_ok;
-	error = vfs_test_lock(&file, &file_lock);
+	error = nfsd_test_lock(rqstp, &cstate->current_fh, &file_lock);
 	if (error) {
 		status = nfserrno(error);
 		goto out;
-- 
1.5.5.rc1

