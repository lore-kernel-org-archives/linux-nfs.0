From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: nfsd: Use vfs_fsync_range() in nfsd_commit
Date: Fri, 29 Jan 2010 16:18:26 -0500
Message-ID: <1264799906.3644.21.camel@localhost>
References: <1264796353.3644.4.camel@localhost>
	 <20100129205022.GA14449@infradead.org> <1264798623.3644.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>,
	"Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12784 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017Ab0A2VS2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 16:18:28 -0500
In-Reply-To: <1264798623.3644.18.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-29 at 15:57 -0500, Trond Myklebust wrote: 
> OK. I missed your patch as it flew by on the list, but I assume it is
> this one:
> 
> http://git.linux-nfs.org/?p=bfields/linux.git;a=commitdiff;h=6a68f89ee1f2d177af4a5410fa7a45734c975fd6;hp=de3cab793c6a5c8505d66bee111edcc7098380ba
> 
> 
> I'll separate out the vfs_sync_range() changes and cobble up a patch on
> top of the above changeset...
> 
> Cheers
>   Trond

Here it is....

Cheers
  Trond
------------------------------------------------------------------------------------------------------------------- 
nfsd: Use vfs_fsync_range() in nfsd_commit

From: Trond Myklebust <Trond.Myklebust@netapp.com>

The NFS COMMIT operation allows the client to specify the exact byte range
that it wishes to sync to disk in order to optimise server performance.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/vfs.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)


diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 79d216f..cc046ca 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1141,8 +1141,6 @@ out:
 #ifdef CONFIG_NFSD_V3
 /*
  * Commit all pending writes to stable storage.
- * Strictly speaking, we could sync just the indicated file region here,
- * but there's currently no way we can ask the VFS to do so.
  *
  * Unfortunately we cannot lock the file to make sure we return full WCC
  * data to the client, as locking happens lower down in the filesystem.
@@ -1152,23 +1150,32 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
                loff_t offset, unsigned long count)
 {
 	struct file	*file;
-	__be32		err;
+	loff_t		end = LLONG_MAX;
+	__be32		err = nfserr_inval;
 
-	if ((u64)count > ~(u64)offset)
-		return nfserr_inval;
+	if (offset < 0)
+		goto out;
+	if (count != 0) {
+		end = offset + (loff_t)count - 1;
+		if (end < offset)
+			goto out;
+	}
 
 	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
 	if (err)
-		return err;
+		goto out;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		if (file->f_op && file->f_op->fsync) {
-			err = nfserrno(vfs_fsync(file, file->f_path.dentry, 0));
-		} else {
+		int err2 = vfs_fsync_range(file, file->f_path.dentry,
+				offset, end, 0);
+
+		if (err2 != -EINVAL)
+			err = nfserrno(err2);
+		else
 			err = nfserr_notsupp;
-		}
 	}
 
 	nfsd_close(file);
+out:
 	return err;
 }
 #endif /* CONFIG_NFSD_V3 */

