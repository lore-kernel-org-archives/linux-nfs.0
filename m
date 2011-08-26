Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33362 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566Ab1HZUTN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 16:19:13 -0400
Date: Fri, 26 Aug 2011 16:19:10 -0400
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] nfsd4: This is: "fix failure to end nfsd4 grace period"
 ++
Message-ID: <20110826201910.GB17196@fieldses.org>
References: <4E45C594.1030609@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E45C594.1030609@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 12, 2011 at 05:30:12PM -0700, Boaz Harrosh wrote:
> Bruce hi
> 
> This is the patch I'm currently using to be able to run. It is
> your patch but the cl_firststate = 1 is promoted to before any
> failures.

Makes sense, thanks.

> Please Also consider adding and promoting some of these prints
> to DMESGs so Admins can know they have a broken setup. Like
> directories do not exist or permission not properly set.

OK, I agree, though a printk in every failure case seems overkill; could
you live with the following?

--b.

commit 1f2c6beb157790cfb253e0c856e97c80e8b1bbfd
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Aug 12 17:30:12 2011 -0700

    nfsd4: fix failure to end nfsd4 grace period
    
    Even if we fail to write a recovery record, we should still mark the
    client as having acquired its first state.  Otherwise we leave 4.1
    clients with indefinite ERR_GRACE returns.
    
    However, an inability to write stable storage records may cause failures
    of reboot recovery, and the problem should still be brought to the
    server administrator's attention.
    
    So, make sure the error is logged.
    
    These errors shouldn't normally be triggered on a corectly functioning
    server--this isn't a case where a misconfigured client could spam the
    logs.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 02eb38e..1ea241a 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -129,6 +129,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	if (!rec_file || clp->cl_firststate)
 		return 0;
 
+	clp->cl_firststate = 1;
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
 		return status;
@@ -143,10 +144,8 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 		goto out_unlock;
 	}
 	status = -EEXIST;
-	if (dentry->d_inode) {
-		dprintk("NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS\n");
+	if (dentry->d_inode)
 		goto out_put;
-	}
 	status = mnt_want_write(rec_file->f_path.mnt);
 	if (status)
 		goto out_put;
@@ -156,12 +155,14 @@ out_put:
 	dput(dentry);
 out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
-	if (status == 0) {
-		clp->cl_firststate = 1;
+	if (status == 0)
 		vfs_fsync(rec_file, 0);
-	}
+	else
+		printk(KERN_ERR "NFSD: failed to write recovery record"
+				" (err %d); please check that recovery"
+				" directory exists and is writeable",
+				status);
 	nfs4_reset_creds(original_cred);
-	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
 	return status;
 }
 
