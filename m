Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:41133 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752043AbeC0Oxr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:53:47 -0400
Received: by mail-io0-f196.google.com with SMTP id m83so27916367ioi.8
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:53:47 -0700 (PDT)
Subject: [PATCH v2 15/18] nfsd: Add I/O trace points in the NFSv4 read proc
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:53:40 -0400
Message-ID: <20180327145340.7710.93006.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 read compound processing invokes nfsd_splice_read and
nfs_readv directly, so the trace points currently in nfsd_read are
not effective for NFSv4 reads.

Move and copy the trace points so that NFSv4 reads are captured.
Also, we want to record any local I/O error that occurs, and
the total count of bytes that were actually moved. And, also
whether splice or vectored read was used.

The svc_fh is not passed to the read helpers, so some code
duplication is necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |    5 +++++
 fs/nfsd/nfs4xdr.c  |   56 +++++++++++++++++++++++++++++++++++++---------------
 fs/nfsd/trace.h    |    4 +++-
 fs/nfsd/vfs.c      |   54 ++++++++++++++++++++++----------------------------
 fs/nfsd/vfs.h      |    8 ++++---
 5 files changed, 76 insertions(+), 51 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b93673e..39016b6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -751,6 +751,9 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
+	trace_nfsd_read_start(rqstp, &cstate->current_fh,
+			      read->rd_offset, read->rd_length);
+
 	/*
 	 * If we do a zero copy read, then a client will see read data
 	 * that reflects the state of the file *after* performing the
@@ -783,6 +786,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 {
 	if (u->read.rd_filp)
 		fput(u->read.rd_filp);
+	trace_nfsd_read_done(u->read.rd_rqstp, u->read.rd_fhp,
+			     u->read.rd_offset, u->read.rd_length);
 }
 
 static __be32
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e502fd1..d03059a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -37,6 +37,7 @@
 #include <linux/file.h>
 #include <linux/slab.h>
 #include <linux/namei.h>
+#include <linux/fsnotify.h>
 #include <linux/statfs.h>
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
@@ -50,6 +51,7 @@
 #include "cache.h"
 #include "netns.h"
 #include "pnfs.h"
+#include "trace.h"
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 #include <linux/security.h>
@@ -3416,28 +3418,28 @@ static __be32 nfsd4_encode_splice_read(
 {
 	struct xdr_stream *xdr = &resp->xdr;
 	struct xdr_buf *buf = xdr->buf;
+	int host_err;
 	u32 eof;
 	long len;
 	int space_left;
-	__be32 nfserr;
 	__be32 *p = xdr->p - 2;
 
 	/* Make sure there will be room for padding if needed */
 	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
+	trace_nfsd_read_splice(resp->rqstp, read->rd_fhp,
+			       read->rd_offset, maxcount);
 	len = maxcount;
-	nfserr = nfsd_splice_read(read->rd_rqstp, file,
+	host_err = nfsd_splice_read(read->rd_rqstp, file,
 				  read->rd_offset, &maxcount);
-	if (nfserr) {
-		/*
-		 * nfsd_splice_actor may have already messed with the
-		 * page length; reset it so as not to confuse
-		 * xdr_truncate_encode:
-		 */
-		buf->page_len = 0;
-		return nfserr;
-	}
+	if (host_err < 0)
+		goto err;
+	trace_nfsd_read_io_done(read->rd_rqstp, read->rd_fhp,
+				read->rd_offset, maxcount);
+	maxcount = host_err;
+	nfsdstats.io_read += maxcount;
+	fsnotify_access(file);
 
 	eof = nfsd_eof_on_read(len, maxcount, read->rd_offset,
 				d_inode(read->rd_fhp->fh_dentry)->i_size);
@@ -3470,6 +3472,17 @@ static __be32 nfsd4_encode_splice_read(
 	xdr->end = (__be32 *)((void *)xdr->end + space_left);
 
 	return 0;
+
+err:
+	/*
+	 * nfsd_splice_actor may have already messed with the
+	 * page length; reset it so as not to confuse
+	 * xdr_truncate_encode:
+	 */
+	buf->page_len = 0;
+	trace_nfsd_read_err(read->rd_rqstp, read->rd_fhp,
+			    read->rd_offset, host_err);
+	return nfserrno(host_err);
 }
 
 static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
@@ -3477,12 +3490,12 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 				 struct file *file, unsigned long maxcount)
 {
 	struct xdr_stream *xdr = &resp->xdr;
+	int host_err;
 	u32 eof;
 	int v;
 	int starting_len = xdr->buf->len - 8;
 	long len;
 	int thislen;
-	__be32 nfserr;
 	__be32 tmp;
 	__be32 *p;
 	u32 zzz = 0;
@@ -3510,11 +3523,18 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	}
 	read->rd_vlen = v;
 
+	trace_nfsd_read_vector(resp->rqstp, read->rd_fhp,
+			       read->rd_offset, maxcount);
 	len = maxcount;
-	nfserr = nfsd_readv(file, read->rd_offset, resp->rqstp->rq_vec,
-			read->rd_vlen, &maxcount);
-	if (nfserr)
-		return nfserr;
+	host_err = nfsd_readv(file, read->rd_offset, resp->rqstp->rq_vec,
+			      read->rd_vlen, &maxcount);
+	if (host_err < 0)
+		goto err;
+	trace_nfsd_read_io_done(resp->rqstp, read->rd_fhp,
+				read->rd_offset, maxcount);
+	nfsdstats.io_read += maxcount;
+	fsnotify_access(file);
+
 	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
 
 	eof = nfsd_eof_on_read(len, maxcount, read->rd_offset,
@@ -3530,6 +3550,10 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 								&zzz, pad);
 	return 0;
 
+err:
+	trace_nfsd_read_err(resp->rqstp, read->rd_fhp,
+			    read->rd_offset, host_err);
+	return nfserrno(host_err);
 }
 
 static __be32
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 653e9ee..a8bbd9d 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -43,7 +43,8 @@
 	TP_ARGS(rqstp, fhp, offset, len))
 
 DEFINE_NFSD_IO_EVENT(read_start);
-DEFINE_NFSD_IO_EVENT(read_opened);
+DEFINE_NFSD_IO_EVENT(read_splice);
+DEFINE_NFSD_IO_EVENT(read_vector);
 DEFINE_NFSD_IO_EVENT(read_io_done);
 DEFINE_NFSD_IO_EVENT(read_done);
 DEFINE_NFSD_IO_EVENT(write_start);
@@ -82,6 +83,7 @@
 		 int		len),		\
 	TP_ARGS(rqstp, fhp, offset, len))
 
+DEFINE_NFSD_ERR_EVENT(read_err);
 DEFINE_NFSD_ERR_EVENT(write_err);
 
 #include "state.h"
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ee59a0b..0fa54b5 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -881,19 +881,7 @@ static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,
 	return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
 }
 
-static __be32
-nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
-{
-	if (host_err >= 0) {
-		nfsdstats.io_read += host_err;
-		*count = host_err;
-		fsnotify_access(file);
-		return 0;
-	} else 
-		return nfserrno(host_err);
-}
-
-__be32 nfsd_splice_read(struct svc_rqst *rqstp,
+int nfsd_splice_read(struct svc_rqst *rqstp,
 		     struct file *file, loff_t offset, unsigned long *count)
 {
 	struct splice_desc sd = {
@@ -902,23 +890,18 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp,
 		.pos		= offset,
 		.u.data		= rqstp,
 	};
-	int host_err;
 
 	rqstp->rq_next_page = rqstp->rq_respages + 1;
-	host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
-	return nfsd_finish_read(file, count, host_err);
+	return splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
 }
 
-__be32 nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
-		unsigned long *count)
+int nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
+	       unsigned long *count)
 {
 	struct iov_iter iter;
-	int host_err;
 
 	iov_iter_kvec(&iter, READ | ITER_KVEC, vec, vlen, *count);
-	host_err = vfs_iter_read(file, &iter, &offset, 0);
-
-	return nfsd_finish_read(file, count, host_err);
+	return vfs_iter_read(file, &iter, &offset, 0);
 }
 
 /*
@@ -1025,6 +1008,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	struct file *file;
 	struct raparms	*ra;
+	int host_err;
 	__be32 err;
 
 	trace_nfsd_read_start(rqstp, fhp, offset, *count);
@@ -1034,14 +1018,24 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	ra = nfsd_init_raparms(file);
 
-	trace_nfsd_read_opened(rqstp, fhp, offset, *count);
-
-	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &rqstp->rq_flags))
-		err = nfsd_splice_read(rqstp, file, offset, count);
-	else
-		err = nfsd_readv(file, offset, vec, vlen, count);
-
-	trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
+	if (file->f_op->splice_read &&
+	    test_bit(RQ_SPLICE_OK, &rqstp->rq_flags)) {
+		trace_nfsd_read_splice(rqstp, fhp, offset, *count);
+		host_err = nfsd_splice_read(rqstp, file, offset, count);
+	} else {
+		trace_nfsd_read_vector(rqstp, fhp, offset, *count);
+		host_err = nfsd_readv(file, offset, vec, vlen, count);
+	}
+	if (host_err >= 0) {
+		trace_nfsd_read_io_done(rqstp, fhp, offset, host_err);
+		nfsdstats.io_read += host_err;
+		*count = host_err;
+		fsnotify_access(file);
+		err = nfs_ok;
+	} else  {
+		trace_nfsd_read_err(rqstp, fhp, offset, host_err);
+		err = nfserrno(host_err);
+	}
 
 	if (ra)
 		nfsd_put_raparams(file, ra);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index be6d8e0..d9131c3 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -78,10 +78,10 @@ __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
 struct raparms;
-__be32		nfsd_splice_read(struct svc_rqst *,
-				struct file *, loff_t, unsigned long *);
-__be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
-				unsigned long *);
+int		nfsd_splice_read(struct svc_rqst *rqstp, struct file *file,
+				loff_t offset, unsigned long *count);
+int		nfsd_readv(struct file *file, loff_t offset, struct kvec *vec,
+				int vlen, unsigned long *count);
 __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
 __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *, loff_t,

