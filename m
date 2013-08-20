Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:52205 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474Ab3HTTfY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 15:35:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 15/16] NFSv4.1: Add tracepoints for debugging layoutget/return/commit
Date: Tue, 20 Aug 2013 15:35:11 -0400
Message-ID: <1377027312-45957-16-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377027312-45957-15-git-send-email-Trond.Myklebust@netapp.com>
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-12-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-13-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-14-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-15-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |  6 ++++++
 fs/nfs/nfs4trace.h | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b2edaec..274e0e3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6859,6 +6859,10 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	status = nfs4_wait_for_completion_rpc_task(task);
 	if (status == 0)
 		status = task->tk_status;
+	trace_nfs4_layoutget(lgp->args.ctx,
+			&lgp->args.range,
+			&lgp->res.range,
+			status);
 	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
 	if (status == 0 && lgp->res.layoutp->len)
 		lseg = pnfs_layout_process(lgp);
@@ -6944,6 +6948,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = task->tk_status;
+	trace_nfs4_layoutreturn(lrp->args.inode, status);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	rpc_put_task(task);
 	return status;
@@ -7130,6 +7135,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 	if (status != 0)
 		goto out;
 	status = task->tk_status;
+	trace_nfs4_layoutcommit(data->args.inode, status);
 out:
 	dprintk("%s: status %d\n", __func__, status);
 	rpc_put_task(task);
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 7546c74..4420523 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -904,6 +904,61 @@ DECLARE_EVENT_CLASS(nfs4_commit_event,
 DEFINE_NFS4_COMMIT_EVENT(nfs4_commit);
 #ifdef CONFIG_NFS_V4_1
 DEFINE_NFS4_COMMIT_EVENT(nfs4_pnfs_commit_ds);
+
+#define show_pnfs_iomode(iomode) \
+	__print_symbolic(iomode, \
+		{ IOMODE_READ, "READ" }, \
+		{ IOMODE_RW, "RW" }, \
+		{ IOMODE_ANY, "ANY" })
+
+TRACE_EVENT(nfs4_layoutget,
+		TP_PROTO(
+			const struct nfs_open_context *ctx,
+			const struct pnfs_layout_range *args,
+			const struct pnfs_layout_range *res,
+			int error
+		),
+
+		TP_ARGS(ctx, args, res, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(u32, iomode)
+			__field(u64, offset)
+			__field(u64, count)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = ctx->dentry->d_inode;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->iomode = args->iomode;
+			__entry->offset = args->offset;
+			__entry->count = args->length;
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"iomode=%s offset=%llu count=%llu",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			show_pnfs_iomode(__entry->iomode),
+			(unsigned long long)__entry->offset,
+			(unsigned long long)__entry->count
+		)
+);
+
+DEFINE_NFS4_INODE_EVENT(nfs4_layoutcommit);
+DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn);
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* _TRACE_NFS4_H */
-- 
1.8.3.1

