From: David Shaw <dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org>
Subject: [PATCH] Short write in nfsd becomes a full write to the client
Date: Thu, 5 Mar 2009 20:16:14 -0500
Message-ID: <20090306011614.GA10357@jabberwocky.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from walrus.jabberwocky.com ([173.9.29.57]:53081 "EHLO
	walrus.jabberwocky.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbZCFBQo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 20:16:44 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a filesystem being written to via NFS returns a short write count
(as opposed to an error) to nfsd, nfsd treats that as a success for
the entire write, rather than the short count that actually succeeded.

For example, given a 8192 byte write, if the underlying filesystem
only writes 4096 bytes, nfsd will ack back to the nfs client that all
8192 bytes were written.  The nfs client does have retry logic for
short writes, but this is never called as the client is told the
complete write succeeded.

There are probably other ways it could happen, but in my case it
happened with a fuse (filesystem in userspace) filesystem which can
rather easily have a partial write.

Here is a patch to properly return the short write count to the
client.

Signed-off-by: David Shaw <dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org>
---

 fs/nfsd/nfs3proc.c        |    5 +++--
 fs/nfsd/nfs4proc.c        |    7 +++++--
 fs/nfsd/nfsproc.c         |    3 ++-
 fs/nfsd/vfs.c             |   12 +++++++-----
 include/linux/nfsd/nfsd.h |    2 +-
 5 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 9dbd2eb..9f262b3 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -202,6 +202,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
 					 struct nfsd3_writeres  *resp)
 {
 	__be32	nfserr;
+	unsigned long cnt = argp->len;
 
 	dprintk("nfsd: WRITE(3)    %s %d bytes at %ld%s\n",
 				SVCFH_fmt(&argp->fh),
@@ -214,9 +215,9 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
 	nfserr = nfsd_write(rqstp, &resp->fh, NULL,
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
-				   argp->len,
+				   &cnt,
 				   &resp->committed);
-	resp->count = argp->count;
+	resp->count = cnt;
 	RETURN_STATUS(nfserr);
 }
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9fa60a3..8ed1b93 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -685,6 +685,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file *filp = NULL;
 	u32 *p;
 	__be32 status = nfs_ok;
+	unsigned long cnt;
 
 	/* no need to check permission - this will be done in nfsd_write() */
 
@@ -703,7 +704,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return status;
 	}
 
-	write->wr_bytes_written = write->wr_buflen;
+	cnt = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
 	p = (u32 *)write->wr_verifier.data;
 	*p++ = nfssvc_boot.tv_sec;
@@ -711,10 +712,12 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status =  nfsd_write(rqstp, &cstate->current_fh, filp,
 			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
-			     write->wr_buflen, &write->wr_how_written);
+			     &cnt, &write->wr_how_written);
 	if (filp)
 		fput(filp);
 
+	write->wr_bytes_written = cnt;
+
 	if (status == nfserr_symlink)
 		status = nfserr_inval;
 	return status;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 6f7f263..e298e26 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -180,6 +180,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
 {
 	__be32	nfserr;
 	int	stable = 1;
+	unsigned long cnt = argp->len;
 
 	dprintk("nfsd: WRITE    %s %d bytes at %d\n",
 		SVCFH_fmt(&argp->fh),
@@ -188,7 +189,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
 	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
-				   argp->len,
+			           &cnt,
 				   &stable);
 	return nfsd_return_attrs(nfserr, resp);
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6e50aaa..d3c8429 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -960,7 +960,7 @@ static void kill_suid(struct dentry *dentry)
 static __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				loff_t offset, struct kvec *vec, int vlen,
-	   			unsigned long cnt, int *stablep)
+	   			unsigned long *cnt, int *stablep)
 {
 	struct svc_export	*exp;
 	struct dentry		*dentry;
@@ -974,7 +974,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	err = nfserr_perm;
 
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
-		(!lock_may_write(file->f_path.dentry->d_inode, offset, cnt)))
+		(!lock_may_write(file->f_path.dentry->d_inode, offset, *cnt)))
 		goto out;
 #endif
 
@@ -1006,7 +1006,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
 	set_fs(oldfs);
 	if (host_err >= 0) {
-		nfsdstats.io_write += cnt;
+		nfsdstats.io_write += host_err;
 		fsnotify_modify(file->f_path.dentry);
 	}
 
@@ -1051,8 +1051,10 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	}
 
 	dprintk("nfsd: write complete host_err=%d\n", host_err);
-	if (host_err >= 0)
+	if (host_err >= 0) {
 		err = 0;
+		*cnt = host_err;
+	}
 	else 
 		err = nfserrno(host_err);
 out:
@@ -1095,7 +1097,7 @@ out:
  */
 __be32
 nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
-		loff_t offset, struct kvec *vec, int vlen, unsigned long cnt,
+		loff_t offset, struct kvec *vec, int vlen, unsigned long *cnt,
 		int *stablep)
 {
 	__be32			err = 0;
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index e19f459..eefa241 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -105,7 +105,7 @@ void		nfsd_close(struct file *);
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *, struct file *,
 				loff_t, struct kvec *, int, unsigned long *);
 __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
-				loff_t, struct kvec *,int, unsigned long, int *);
+				loff_t, struct kvec *,int, unsigned long *, int *);
 __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
 __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
