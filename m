Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:57562 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819Ab1HMAaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 20:30:21 -0400
Message-ID: <4E45C594.1030609@panasas.com>
Date: Fri, 12 Aug 2011 17:30:12 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [RFC] nfsd4: This is: "fix failure to end nfsd4 grace period" ++
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce hi

This is the patch I'm currently using to be able to run. It is
your patch but the cl_firststate = 1 is promoted to before any
failures.

Please Also consider adding and promoting some of these prints
to DMESGs so Admins can know they have a broken setup. Like
directories do not exist or permission not properly set.
Though I admit the messages should be properly worded.

Thanks
Boaz

---
From: "J. Bruce Fields" <bfields@redhat.com>
Date: Fri, 12 Aug 2011 17:18:04 -0700
Subject: [PATCH] nfsd4: This is: "fix failure to end nfsd4 grace period" ++

J. Bruce Fields:
    Even if we fail to write a recovery record to stable storage, we should
    still mark the client as having acquired its first state.  Otherwise we
    leave 4.1 clients with indefinite ERR_GRACE returns.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Boaz Harrosh:

    I don't think this fix is enough what about the failure of nfs4_save_creds
    It can only fail with -ENOMEM do you hang the client in this case?

    I think Some of these prints should be delegated to a KERN_ERR since
    it is a possible setup problem.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/nfs4recover.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 29d77f6..baedd89 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -129,9 +129,12 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	if (!rec_file || clp->cl_firststate)
 		return 0;
 
+	clp->cl_firststate = 1;
 	status = nfs4_save_creds(&original_cred);
-	if (status < 0)
+	if (unlikely(status < 0)) {
+		printk(KERN_ERR "!!!nfs4_save_creds Returned => %d\n", status);
 		return status;
+	}
 
 	dir = rec_file->f_path.dentry;
 	/* lock the parent */
@@ -140,26 +143,30 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	dentry = lookup_one_len(dname, dir, HEXDIR_LEN-1);
 	if (IS_ERR(dentry)) {
 		status = PTR_ERR(dentry);
+		printk(KERN_ERR "NFSD: lookup_one_len => %d\n", status);
 		goto out_unlock;
 	}
 	status = -EEXIST;
 	if (dentry->d_inode) {
-		dprintk("NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS\n");
+		printk(KERN_ERR "NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS\n");
 		goto out_put;
 	}
 	status = mnt_want_write(rec_file->f_path.mnt);
-	if (status)
+	if (unlikely(status)) {
+		printk(KERN_ERR "!!!mnt_want_write Returned => %d\n", status);
 		goto out_put;
+	}
 	status = vfs_mkdir(dir->d_inode, dentry, S_IRWXU);
+	if (unlikely(status))
+		printk(KERN_ERR "!!!vfs_mkdir Returned => %d\n", status);
+
 	mnt_drop_write(rec_file->f_path.mnt);
 out_put:
 	dput(dentry);
 out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
-	if (status == 0) {
-		clp->cl_firststate = 1;
+	if (status == 0)
 		vfs_fsync(rec_file, 0);
-	}
 	nfs4_reset_creds(original_cred);
 	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
 	return status;
-- 
1.7.6

