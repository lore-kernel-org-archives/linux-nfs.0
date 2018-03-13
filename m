Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32918 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934937AbeCMPoj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 11:44:39 -0400
Received: by mail-io0-f194.google.com with SMTP id f1so653625iob.0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2018 08:44:39 -0700 (PDT)
Subject: [PATCH 11/15] nfsd: Record request byte count, not count of vectors
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 13 Mar 2018 11:44:37 -0400
Message-ID: <20180313154437.21531.89300.stgit@klimt.1015granger.net>
In-Reply-To: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Byte count is more helpful to know than vector count.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.h |   15 +++++----------
 fs/nfsd/vfs.c   |   16 ++++++++--------
 2 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 3aa3f3b..9b79506 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -15,26 +15,21 @@
 	TP_PROTO(struct svc_rqst *rqstp,
 		 struct svc_fh	*fhp,
 		 loff_t		offset,
-		 int		len),
+		 unsigned long	len),
 	TP_ARGS(rqstp, fhp, offset, len),
 	TP_STRUCT__entry(
 		__field(u32, xid)
 		__field(u32, fh_hash)
 		__field(loff_t, offset)
-		__field(int, len)
+		__field(unsigned long, len)
 	),
 	TP_fast_assign(
 		__entry->xid = be32_to_cpu(rqstp->rq_xid);
-		do {
-			struct knfsd_fh fh;
-
-			fh_copy_shallow(&fh, &fhp->fh_handle);
-			__entry->fh_hash = knfsd_fh_hash(&fh);
-		} while (0);
+		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
 		__entry->offset = offset;
 		__entry->len = len;
 	),
-	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%lld len=%d",
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%lld len=%lu",
 		  __entry->xid, __entry->fh_hash,
 		  __entry->offset, __entry->len)
 )
@@ -44,7 +39,7 @@
 	TP_PROTO(struct svc_rqst *rqstp,	\
 		 struct svc_fh	*fhp,		\
 		 loff_t		offset,		\
-		 int		len),		\
+		 unsigned long	len),		\
 	TP_ARGS(rqstp, fhp, offset, len))
 
 DEFINE_NFSD_IO_EVENT(read_start);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a3c9bfa..e2eab4c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1024,27 +1024,27 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct raparms	*ra;
 	__be32 err;
 
-	trace_read_start(rqstp, fhp, offset, vlen);
+	trace_read_start(rqstp, fhp, offset, *count);
 	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
 	if (err)
 		return err;
 
 	ra = nfsd_init_raparms(file);
 
-	trace_read_opened(rqstp, fhp, offset, vlen);
+	trace_read_opened(rqstp, fhp, offset, *count);
 
 	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &rqstp->rq_flags))
 		err = nfsd_splice_read(rqstp, file, offset, count);
 	else
 		err = nfsd_readv(file, offset, vec, vlen, count);
 
-	trace_read_io_done(rqstp, fhp, offset, vlen);
+	trace_read_io_done(rqstp, fhp, offset, *count);
 
 	if (ra)
 		nfsd_put_raparams(file, ra);
 	fput(file);
 
-	trace_read_done(rqstp, fhp, offset, vlen);
+	trace_read_done(rqstp, fhp, offset, *count);
 
 	return err;
 }
@@ -1061,18 +1061,18 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct file *file = NULL;
 	__be32 err = 0;
 
-	trace_write_start(rqstp, fhp, offset, vlen);
+	trace_write_start(rqstp, fhp, offset, *cnt);
 
 	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
 	if (err)
 		goto out;
 
-	trace_write_opened(rqstp, fhp, offset, vlen);
+	trace_write_opened(rqstp, fhp, offset, *cnt);
 	err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt, stable);
-	trace_write_io_done(rqstp, fhp, offset, vlen);
+	trace_write_io_done(rqstp, fhp, offset, *cnt);
 	fput(file);
 out:
-	trace_write_done(rqstp, fhp, offset, vlen);
+	trace_write_done(rqstp, fhp, offset, *cnt);
 	return err;
 }
 

