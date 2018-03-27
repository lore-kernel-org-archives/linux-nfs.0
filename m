Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:52461 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752300AbeC0Oxe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 10:53:34 -0400
Received: by mail-it0-f68.google.com with SMTP id k135-v6so15531752ite.2
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 07:53:33 -0700 (PDT)
Subject: [PATCH v2 14/18] nfsd: Add I/O trace points in the NFSv4 write path
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 27 Mar 2018 10:53:27 -0400
Message-ID: <20180327145327.7710.90629.stgit@oracle-ib-101.nfsv4bat.org>
In-Reply-To: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
References: <20180327144420.7710.82288.stgit@oracle-ib-101.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 write compound processing invokes nfsd_vfs_write directly. The
trace points currently in nfsd_write are not effective for NFSv4
writes.

Move the trace points into the shared nfsd_vfs_write() helper.

After the I/O, we also want to record any local I/O error that
might have occurred, and the total count of bytes that were actually
moved (rather than the requested number).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |    7 +++++--
 fs/nfsd/trace.h    |   33 +++++++++++++++++++++++++++++++++
 fs/nfsd/vfs.c      |   23 ++++++++++++-----------
 3 files changed, 50 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 10c7620..b93673e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1001,6 +1001,9 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
+	cnt = write->wr_buflen;
+	trace_nfsd_write_start(rqstp, &cstate->current_fh,
+			       write->wr_offset, cnt);
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 						stateid, WR_STATE, &filp, NULL);
 	if (status) {
@@ -1008,7 +1011,6 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 		return status;
 	}
 
-	cnt = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
 	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
 
@@ -1021,7 +1023,8 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 	fput(filp);
 
 	write->wr_bytes_written = cnt;
-
+	trace_nfsd_write_done(rqstp, &cstate->current_fh,
+			      write->wr_offset, cnt);
 	return status;
 }
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 30e0485..653e9ee 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -51,6 +51,39 @@
 DEFINE_NFSD_IO_EVENT(write_io_done);
 DEFINE_NFSD_IO_EVENT(write_done);
 
+DECLARE_EVENT_CLASS(nfsd_err_class,
+	TP_PROTO(struct svc_rqst *rqstp,
+		 struct svc_fh	*fhp,
+		 loff_t		offset,
+		 int		status),
+	TP_ARGS(rqstp, fhp, offset, status),
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, fh_hash)
+		__field(loff_t, offset)
+		__field(int, status)
+	),
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
+		__entry->offset = offset;
+		__entry->status = status;
+	),
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%lld status=%d",
+		  __entry->xid, __entry->fh_hash,
+		  __entry->offset, __entry->status)
+)
+
+#define DEFINE_NFSD_ERR_EVENT(name)		\
+DEFINE_EVENT(nfsd_err_class, nfsd_##name,	\
+	TP_PROTO(struct svc_rqst *rqstp,	\
+		 struct svc_fh	*fhp,		\
+		 loff_t		offset,		\
+		 int		len),		\
+	TP_ARGS(rqstp, fhp, offset, len))
+
+DEFINE_NFSD_ERR_EVENT(write_err);
+
 #include "state.h"
 
 DECLARE_EVENT_CLASS(nfsd_stateid_class,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 8570319..ee59a0b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -965,13 +965,15 @@ static int wait_for_concurrent_writes(struct file *file)
 {
 	struct svc_export	*exp;
 	struct iov_iter		iter;
-	__be32			err = 0;
+	__be32			nfserr;
 	int			host_err;
 	int			use_wgather;
 	loff_t			pos = offset;
 	unsigned int		pflags = current->flags;
 	rwf_t			flags = 0;
 
+	trace_nfsd_write_opened(rqstp, fhp, offset, *cnt);
+
 	if (test_bit(RQ_LOCAL, &rqstp->rq_flags))
 		/*
 		 * We want less throttling in balance_dirty_pages()
@@ -994,22 +996,23 @@ static int wait_for_concurrent_writes(struct file *file)
 	host_err = vfs_iter_write(file, &iter, &pos, flags);
 	if (host_err < 0)
 		goto out_nfserr;
-	*cnt = host_err;
-	nfsdstats.io_write += host_err;
+	nfsdstats.io_write += *cnt;
 	fsnotify_modify(file);
 
 	if (stable && use_wgather)
 		host_err = wait_for_concurrent_writes(file);
 
 out_nfserr:
-	dprintk("nfsd: write complete host_err=%d\n", host_err);
-	if (host_err >= 0)
-		err = 0;
-	else
-		err = nfserrno(host_err);
+	if (host_err >= 0) {
+		trace_nfsd_write_io_done(rqstp, fhp, offset, *cnt);
+		nfserr = nfs_ok;
+	} else {
+		trace_nfsd_write_err(rqstp, fhp, offset, host_err);
+		nfserr = nfserrno(host_err);
+	}
 	if (test_bit(RQ_LOCAL, &rqstp->rq_flags))
 		current_restore_flags(pflags, PF_LESS_THROTTLE);
-	return err;
+	return nfserr;
 }
 
 /*
@@ -1067,9 +1070,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (err)
 		goto out;
 
-	trace_nfsd_write_opened(rqstp, fhp, offset, *cnt);
 	err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt, stable);
-	trace_nfsd_write_io_done(rqstp, fhp, offset, *cnt);
 	fput(file);
 out:
 	trace_nfsd_write_done(rqstp, fhp, offset, *cnt);

