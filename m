Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:58766 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740Ab3HVAYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:32 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 18/21] NFSv4: Add tracepoints for debugging reads and writes
Date: Wed, 21 Aug 2013 20:24:16 -0400
Message-ID: <1377131059-40121-19-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-18-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-12-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-13-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-14-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-15-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-16-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-17-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-18-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up tracepoints to track read, write and commit, as well as
pNFS reads and writes and commits to the data server.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   4 ++
 fs/nfs/nfs4proc.c       |   3 +
 fs/nfs/nfs4trace.c      |   5 ++
 fs/nfs/nfs4trace.h      | 154 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c           |   3 +
 5 files changed, 169 insertions(+)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 17ed87e..a70cb3a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -39,6 +39,7 @@
 #include "internal.h"
 #include "delegation.h"
 #include "nfs4filelayout.h"
+#include "nfs4trace.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
@@ -247,6 +248,7 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 	struct nfs_pgio_header *hdr = data->header;
 	int err;
 
+	trace_nfs4_pnfs_read(data, task->tk_status);
 	err = filelayout_async_handle_error(task, data->args.context->state,
 					    data->ds_clp, hdr->lseg);
 
@@ -363,6 +365,7 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 	struct nfs_pgio_header *hdr = data->header;
 	int err;
 
+	trace_nfs4_pnfs_write(data, task->tk_status);
 	err = filelayout_async_handle_error(task, data->args.context->state,
 					    data->ds_clp, hdr->lseg);
 
@@ -395,6 +398,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 {
 	int err;
 
+	trace_nfs4_pnfs_commit_ds(data, task->tk_status);
 	err = filelayout_async_handle_error(task, NULL, data->ds_clp,
 					    data->lseg);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d6c98bd..e9551ae 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3877,6 +3877,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->header->inode);
 
+	trace_nfs4_read(data, task->tk_status);
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
@@ -3938,6 +3939,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 {
 	struct inode *inode = data->header->inode;
 	
+	trace_nfs4_write(data, task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
@@ -4029,6 +4031,7 @@ static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_commit_data *da
 {
 	struct inode *inode = data->inode;
 
+	trace_nfs4_commit(data, task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
diff --git a/fs/nfs/nfs4trace.c b/fs/nfs/nfs4trace.c
index 3f02183..f840974 100644
--- a/fs/nfs/nfs4trace.c
+++ b/fs/nfs/nfs4trace.c
@@ -8,3 +8,8 @@
 #define CREATE_TRACE_POINTS
 #include "nfs4trace.h"
 
+#ifdef CONFIG_NFS_V4_1
+EXPORT_TRACEPOINT_SYMBOL_GPL(nfs4_pnfs_read);
+EXPORT_TRACEPOINT_SYMBOL_GPL(nfs4_pnfs_write);
+EXPORT_TRACEPOINT_SYMBOL_GPL(nfs4_pnfs_commit_ds);
+#endif
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 99d1b1e..1ea6983 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -742,6 +742,160 @@ DEFINE_NFS4_IDMAP_EVENT(nfs4_map_group_to_gid);
 DEFINE_NFS4_IDMAP_EVENT(nfs4_map_uid_to_name);
 DEFINE_NFS4_IDMAP_EVENT(nfs4_map_gid_to_group);
 
+DECLARE_EVENT_CLASS(nfs4_read_event,
+		TP_PROTO(
+			const struct nfs_read_data *data,
+			int error
+		),
+
+		TP_ARGS(data, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(loff_t, offset)
+			__field(size_t, count)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = data->header->inode;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->offset = data->args.offset;
+			__entry->count = data->args.count;
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%zu",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			(long long)__entry->offset,
+			__entry->count
+		)
+);
+#define DEFINE_NFS4_READ_EVENT(name) \
+	DEFINE_EVENT(nfs4_read_event, name, \
+			TP_PROTO( \
+				const struct nfs_read_data *data, \
+				int error \
+			), \
+			TP_ARGS(data, error))
+DEFINE_NFS4_READ_EVENT(nfs4_read);
+#ifdef CONFIG_NFS_V4_1
+DEFINE_NFS4_READ_EVENT(nfs4_pnfs_read);
+#endif /* CONFIG_NFS_V4_1 */
+
+DECLARE_EVENT_CLASS(nfs4_write_event,
+		TP_PROTO(
+			const struct nfs_write_data *data,
+			int error
+		),
+
+		TP_ARGS(data, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(loff_t, offset)
+			__field(size_t, count)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = data->header->inode;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->offset = data->args.offset;
+			__entry->count = data->args.count;
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%zu",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			(long long)__entry->offset,
+			__entry->count
+		)
+);
+
+#define DEFINE_NFS4_WRITE_EVENT(name) \
+	DEFINE_EVENT(nfs4_write_event, name, \
+			TP_PROTO( \
+				const struct nfs_write_data *data, \
+				int error \
+			), \
+			TP_ARGS(data, error))
+DEFINE_NFS4_WRITE_EVENT(nfs4_write);
+#ifdef CONFIG_NFS_V4_1
+DEFINE_NFS4_WRITE_EVENT(nfs4_pnfs_write);
+#endif /* CONFIG_NFS_V4_1 */
+
+DECLARE_EVENT_CLASS(nfs4_commit_event,
+		TP_PROTO(
+			const struct nfs_commit_data *data,
+			int error
+		),
+
+		TP_ARGS(data, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(loff_t, offset)
+			__field(size_t, count)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = data->inode;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->offset = data->args.offset;
+			__entry->count = data->args.count;
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%zu",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			(long long)__entry->offset,
+			__entry->count
+		)
+);
+#define DEFINE_NFS4_COMMIT_EVENT(name) \
+	DEFINE_EVENT(nfs4_commit_event, name, \
+			TP_PROTO( \
+				const struct nfs_commit_data *data, \
+				int error \
+			), \
+			TP_ARGS(data, error))
+DEFINE_NFS4_COMMIT_EVENT(nfs4_commit);
+#ifdef CONFIG_NFS_V4_1
+DEFINE_NFS4_COMMIT_EVENT(nfs4_pnfs_commit_ds);
+#endif /* CONFIG_NFS_V4_1 */
+
 #endif /* _TRACE_NFS4_H */
 
 #undef TRACE_INCLUDE_PATH
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3a3a79d..d75d938 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -33,6 +33,7 @@
 #include "internal.h"
 #include "pnfs.h"
 #include "iostat.h"
+#include "nfs4trace.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
 #define PNFS_LAYOUTGET_RETRY_TIMEOUT (120*HZ)
@@ -1526,6 +1527,7 @@ void pnfs_ld_write_done(struct nfs_write_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
 
+	trace_nfs4_pnfs_write(data, hdr->pnfs_error);
 	if (!hdr->pnfs_error) {
 		pnfs_set_layoutcommit(data);
 		hdr->mds_ops->rpc_call_done(&data->task, data);
@@ -1680,6 +1682,7 @@ void pnfs_ld_read_done(struct nfs_read_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
 
+	trace_nfs4_pnfs_read(data, hdr->pnfs_error);
 	if (likely(!hdr->pnfs_error)) {
 		__nfs4_read_done_cb(data);
 		hdr->mds_ops->rpc_call_done(&data->task, data);
-- 
1.8.3.1

