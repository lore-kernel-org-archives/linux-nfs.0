Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:38536 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753527AbdHUTAv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Aug 2017 15:00:51 -0400
Received: by mail-io0-f196.google.com with SMTP id g71so3836912ioe.5
        for <linux-nfs@vger.kernel.org>; Mon, 21 Aug 2017 12:00:51 -0700 (PDT)
Received: from manet.1015granger.net (c-68-46-169-226.hsd1.mi.comcast.net. [68.46.169.226])
        by smtp.gmail.com with ESMTPSA id c67sm6139170ioj.73.2017.08.21.12.00.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 12:00:49 -0700 (PDT)
Subject: [PATCH RFC] NFS: Add static NFS I/O tracepoints
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 21 Aug 2017 15:00:49 -0400
Message-ID: <20170821190049.11352.87544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tools like tcpdump and rpcdebug can be very useful. But there are
plenty of environments where they are difficult or impossible to
use. For example, we've had customers report I/O failures during
workloads so heavy that collecting network traffic or enabling
RPC debugging are themselves onerous.

The kernel's static tracepoints are lightweight (less likely to
introduce timing changes) and efficient (the trace data is compact).
They also work in scenarios where capturing network traffic is not
possible due to lack of hardware support (some InfiniBand HCAs) or
where data or network privacy is a concern.

Introduce tracepoints that show when an NFS READ, WRITE, or COMMIT
is initiated, and when it completes. Record the arguments and
results of each operation, which are not shown by existing sunrpc
module's tracepoints.

For instance, the recorded offset and count can be used to match an
"initiate" event to a "done" event. If an NFS READ result returns
fewer bytes than requested or zero, seeing the EOF flag can be
probative. Seeing an NFS4ERR_BAD_STATEID result is also indication
of a particular class of problems. The timing information attached
to each event record can often be useful as well.

Usage example:

[root@manet tmp]# trace-cmd record -e nfs:*initiate* -e nfs:*done
/sys/kernel/debug/tracing/events/nfs/*initiate*/filter
/sys/kernel/debug/tracing/events/nfs/*done/filter
Hit Ctrl^C to stop recording
^CKernel buffer statistics:
  Note: "entries" are the entries left in the kernel ring buffer and are not
        recorded in the trace data. They should all be zero.

CPU: 0
entries: 0
overrun: 0
commit overrun: 0
bytes: 3680
oldest event ts:    78.367422
now ts:   100.124419
dropped events: 0
read events: 74

... and so on.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfstrace.h |  248 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/read.c     |    4 +
 fs/nfs/write.c    |    7 +
 3 files changed, 259 insertions(+)

diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 2ca9167..5517110 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -719,6 +719,254 @@
 			__get_str(name)
 		)
 );
+
+TRACE_EVENT(nfs_initiate_read,
+		TP_PROTO(
+			const struct inode *inode,
+			loff_t offset, unsigned long count
+		),
+
+		TP_ARGS(inode, offset, count),
+
+		TP_STRUCT__entry(
+			__field(loff_t, offset)
+			__field(unsigned long, count)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+
+			__entry->offset = offset;
+			__entry->count = count;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%lu",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->offset, __entry->count
+		)
+);
+
+TRACE_EVENT(nfs_readpage_done,
+		TP_PROTO(
+			const struct inode *inode,
+			int status, loff_t offset, bool eof
+		),
+
+		TP_ARGS(inode, status, offset, eof),
+
+		TP_STRUCT__entry(
+			__field(int, status)
+			__field(loff_t, offset)
+			__field(bool, eof)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+
+			__entry->status = status;
+			__entry->offset = offset;
+			__entry->eof = eof;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld status=%d%s",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->offset, __entry->status,
+			__entry->eof ? " eof" : ""
+		)
+);
+
+/*
+ * XXX: I tried using NFS_UNSTABLE and friends in this table, but they
+ * all evaluate to 0 for some reason, even if I include linux/nfs.h.
+ */
+#define nfs_show_stable(stable) \
+	__print_symbolic(stable, \
+			{ 0, " (UNSTABLE)" }, \
+			{ 1, " (DATA_SYNC)" }, \
+			{ 2, " (FILE_SYNC)" })
+
+TRACE_EVENT(nfs_initiate_write,
+		TP_PROTO(
+			const struct inode *inode,
+			loff_t offset, unsigned long count,
+			enum nfs3_stable_how stable
+		),
+
+		TP_ARGS(inode, offset, count, stable),
+
+		TP_STRUCT__entry(
+			__field(loff_t, offset)
+			__field(unsigned long, count)
+			__field(enum nfs3_stable_how, stable)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+
+			__entry->offset = offset;
+			__entry->count = count;
+			__entry->stable = stable;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%lu stable=%d%s",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->offset, __entry->count,
+			__entry->stable, nfs_show_stable(__entry->stable)
+		)
+);
+
+TRACE_EVENT(nfs_writeback_done,
+		TP_PROTO(
+			const struct inode *inode,
+			int status,
+			loff_t offset,
+			struct nfs_writeverf *writeverf
+		),
+
+		TP_ARGS(inode, status, offset, writeverf),
+
+		TP_STRUCT__entry(
+			__field(int, status)
+			__field(loff_t, offset)
+			__field(enum nfs3_stable_how, stable)
+			__field(unsigned long long, verifier)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+
+			__entry->status = status;
+			__entry->offset = offset;
+			__entry->stable = writeverf->committed;
+			memcpy(&__entry->verifier, &writeverf->verifier,
+			       sizeof(__entry->verifier));
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld status=%d stable=%d%s "
+			"verifier 0x%016llx",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->offset, __entry->status,
+			__entry->stable, nfs_show_stable(__entry->stable),
+			__entry->verifier
+		)
+);
+
+TRACE_EVENT(nfs_initiate_commit,
+		TP_PROTO(
+			const struct nfs_commit_data *data
+		),
+
+		TP_ARGS(data),
+
+		TP_STRUCT__entry(
+			__field(loff_t, offset)
+			__field(unsigned long, count)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = data->inode;
+			const struct nfs_inode *nfsi = NFS_I(inode);
+
+			__entry->offset = data->args.offset;
+			__entry->count = data->args.count;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%lu",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->offset, __entry->count
+		)
+);
+
+TRACE_EVENT(nfs_commit_done,
+		TP_PROTO(
+			const struct nfs_commit_data *data
+		),
+
+		TP_ARGS(data),
+
+		TP_STRUCT__entry(
+			__field(int, status)
+			__field(loff_t, offset)
+			__field(unsigned long long, verifier)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = data->inode;
+			const struct nfs_inode *nfsi = NFS_I(inode);
+
+			__entry->status = data->res.op_status;
+			__entry->offset = data->args.offset;
+			memcpy(&__entry->verifier, &data->verf.verifier,
+			       sizeof(__entry->verifier));
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld status=%d verifier 0x%016llx",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->offset, __entry->status,
+			__entry->verifier
+		)
+);
+
 #endif /* _TRACE_NFS_H */
 
 #undef TRACE_INCLUDE_PATH
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index a8421d9..bbc6fa5 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -25,6 +25,7 @@
 #include "iostat.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfstrace.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -200,6 +201,7 @@ static void nfs_initiate_read(struct nfs_pgio_header *hdr,
 
 	task_setup_data->flags |= swap_flags;
 	rpc_ops->read_setup(hdr, msg);
+	trace_nfs_initiate_read(inode, hdr->io_start, hdr->good_bytes);
 }
 
 static void
@@ -232,6 +234,8 @@ static int nfs_readpage_done(struct rpc_task *task,
 		return status;
 
 	nfs_add_stats(inode, NFSIOS_SERVERREADBYTES, hdr->res.count);
+	trace_nfs_readpage_done(inode, task->tk_status,
+				hdr->args.offset, hdr->res.eof);
 
 	if (task->tk_status == -ESTALE) {
 		set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b1af5de..bc7ad5cb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1399,6 +1399,8 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
 
 	task_setup_data->priority = priority;
 	rpc_ops->write_setup(hdr, msg);
+	trace_nfs_initiate_write(hdr->inode, hdr->io_start, hdr->good_bytes,
+				 hdr->args.stable);
 
 	nfs4_state_protect_write(NFS_SERVER(hdr->inode)->nfs_client,
 				 &task_setup_data->rpc_client, msg, hdr);
@@ -1557,7 +1559,10 @@ static int nfs_writeback_done(struct rpc_task *task,
 	status = NFS_PROTO(inode)->write_done(task, hdr);
 	if (status != 0)
 		return status;
+
 	nfs_add_stats(inode, NFSIOS_SERVERWRITTENBYTES, hdr->res.count);
+	trace_nfs_writeback_done(inode, task->tk_status,
+				 hdr->args.offset, hdr->res.verf);
 
 	if (hdr->res.verf->committed < hdr->args.stable &&
 	    task->tk_status >= 0) {
@@ -1686,6 +1691,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 	};
 	/* Set up the initial task struct.  */
 	nfs_ops->commit_setup(data, &msg);
+	trace_nfs_initiate_commit(data);
 
 	dprintk("NFS: initiated commit call\n");
 
@@ -1810,6 +1816,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 
 	/* Call the NFS version-specific code */
 	NFS_PROTO(data->inode)->commit_done(task, data);
+	trace_nfs_commit_done(data);
 }
 
 static void nfs_commit_release_pages(struct nfs_commit_data *data)

