Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33400 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbcLWBcV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Dec 2016 20:32:21 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so3089120pfg.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Dec 2016 17:32:21 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 1/3] NFSD: pass an integer for stable type to nfsd_vfs_write
Message-ID: <0df957d0-3405-b12f-0d39-210a0edd6f60@gmail.com>
Date: Fri, 23 Dec 2016 09:32:15 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit fae5096ad217 "nfsd: assume writeable exportabled filesystems have f_sync"
have remove the setting of stable.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs3proc.c |  2 +-
 fs/nfsd/nfs4proc.c |  2 +-
 fs/nfsd/nfs4xdr.c  |  2 +-
 fs/nfsd/nfsproc.c  |  3 +--
 fs/nfsd/vfs.c      | 11 +++++------
 fs/nfsd/vfs.h      |  4 ++--
 6 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index d818e4f..69cd0f1 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -197,7 +197,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp, struct nfsd3_writeargs *argp,
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
 				   &cnt,
-				   &resp->committed);
+				   resp->committed);
 	resp->count = cnt;
 	RETURN_STATUS(nfserr);
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 74a6e57..2d4eb47 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -983,7 +983,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
 				write->wr_offset, rqstp->rq_vec, nvecs, &cnt,
-				&write->wr_how_written);
+				write->wr_how_written);
 	fput(filp);
 
 	write->wr_bytes_written = cnt;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7ecf16b..3a02c9b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1250,7 +1250,7 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
 	READ_BUF(16);
 	p = xdr_decode_hyper(p, &write->wr_offset);
 	write->wr_stable_how = be32_to_cpup(p++);
-	if (write->wr_stable_how > 2)
+	if (write->wr_stable_how > NFS_FILE_SYNC)
 		goto xdr_error;
 	write->wr_buflen = be32_to_cpup(p++);
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 010aff5..f157c7e 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -204,7 +204,6 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
 					struct nfsd_attrstat  *resp)
 {
 	__be32	nfserr;
-	int	stable = 1;
 	unsigned long cnt = argp->len;
 
 	dprintk("nfsd: WRITE    %s %d bytes at %d\n",
@@ -215,7 +214,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, struct nfsd_writeargs *argp,
 				   argp->offset,
 				   rqstp->rq_vec, argp->vlen,
 			           &cnt,
-				   &stable);
+				   NFS_DATA_SYNC);
 	return nfsd_return_attrs(nfserr, resp);
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7a21abe..cc80d2d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -940,14 +940,13 @@ static int wait_for_concurrent_writes(struct file *file)
 __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				loff_t offset, struct kvec *vec, int vlen,
-				unsigned long *cnt, int *stablep)
+				unsigned long *cnt, int stable)
 {
 	struct svc_export	*exp;
 	struct inode		*inode;
 	mm_segment_t		oldfs;
 	__be32			err = 0;
 	int			host_err;
-	int			stable = *stablep;
 	int			use_wgather;
 	loff_t			pos = offset;
 	unsigned int		pflags = current->flags;
@@ -968,7 +967,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	use_wgather = (rqstp->rq_vers == 2) && EX_WGATHER(exp);
 
 	if (!EX_ISSYNC(exp))
-		stable = 0;
+		stable = NFS_UNSTABLE;
 
 	if (stable && !use_wgather)
 		flags |= RWF_SYNC;
@@ -1037,7 +1036,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 __be32
 nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		loff_t offset, struct kvec *vec, int vlen, unsigned long *cnt,
-		int *stablep)
+		int stable)
 {
 	__be32			err = 0;
 
@@ -1050,7 +1049,7 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 			goto out;
 		trace_write_opened(rqstp, fhp, offset, vlen);
 		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
-				stablep);
+				stable);
 		trace_write_io_done(rqstp, fhp, offset, vlen);
 	} else {
 		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
@@ -1060,7 +1059,7 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		trace_write_opened(rqstp, fhp, offset, vlen);
 		if (cnt)
 			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
-					     cnt, stablep);
+					     cnt, stable);
 		trace_write_io_done(rqstp, fhp, offset, vlen);
 		fput(file);
 	}
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 0bf9e7b..8458d8c 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -84,11 +84,11 @@ __be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
 __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
-				loff_t, struct kvec *,int, unsigned long *, int *);
+				loff_t, struct kvec *,int, unsigned long *, int);
 __be32		nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct file *file, loff_t offset,
 				struct kvec *vec, int vlen, unsigned long *cnt,
-				int *stablep);
+				int stable);
 __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
 __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
-- 
2.9.3

