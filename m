Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:10024 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3HVAY2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:28 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 10/21] NFSv4: Add tracepoints for debugging file open
Date: Wed, 21 Aug 2013 20:24:08 -0400
Message-ID: <1377131059-40121-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-10-git-send-email-Trond.Myklebust@netapp.com>
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
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up basic tracepoints for debugging NFSv4 file open/close

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |   4 ++
 fs/nfs/nfs4trace.h | 125 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 129 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f077487..ce37c68 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1438,6 +1438,7 @@ static int nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 	int err;
 	do {
 		err = _nfs4_do_open_reclaim(ctx, state);
+		trace_nfs4_open_reclaim(ctx, 0, err);
 		if (nfs4_clear_cap_atomic_open_v1(server, err, &exception))
 			continue;
 		if (err != -NFS4ERR_DELAY)
@@ -1893,6 +1894,7 @@ static int nfs4_do_open_expired(struct nfs_open_context *ctx, struct nfs4_state
 
 	do {
 		err = _nfs4_open_expired(ctx, state);
+		trace_nfs4_open_expired(ctx, 0, err);
 		if (nfs4_clear_cap_atomic_open_v1(server, err, &exception))
 			continue;
 		switch (err) {
@@ -2195,6 +2197,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 	do {
 		status = _nfs4_do_open(dir, ctx, flags, sattr, label);
 		res = ctx->state;
+		trace_nfs4_open_file(ctx, flags, status);
 		if (status == 0)
 			break;
 		/* NOTE: BAD_SEQID means the server and client disagree about the
@@ -2385,6 +2388,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	dprintk("%s: begin!\n", __func__);
 	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
 		return;
+	trace_nfs4_close(state, &calldata->arg, &calldata->res, task->tk_status);
         /* hmm. we are done with the inode, and in the process of freeing
 	 * the state_owner. we keep this around to process errors
 	 */
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 9653feb..a558dc9 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -161,6 +161,19 @@
 		{ -NFS4ERR_WRONG_TYPE, "WRONG_TYPE" }, \
 		{ -NFS4ERR_XDEV, "XDEV" })
 
+#define show_open_flags(flags) \
+	__print_flags(flags, "|", \
+		{ O_CREAT, "O_CREAT" }, \
+		{ O_EXCL, "O_EXCL" }, \
+		{ O_TRUNC, "O_TRUNC" }, \
+		{ O_DIRECT, "O_DIRECT" })
+
+#define show_fmode_flags(mode) \
+	__print_flags(mode, "|", \
+		{ ((__force unsigned long)FMODE_READ), "READ" }, \
+		{ ((__force unsigned long)FMODE_WRITE), "WRITE" }, \
+		{ ((__force unsigned long)FMODE_EXEC), "EXEC" })
+
 DECLARE_EVENT_CLASS(nfs4_clientid_event,
 		TP_PROTO(
 			const struct nfs_client *clp,
@@ -211,6 +224,118 @@ DEFINE_NFS4_CLIENTID_EVENT(nfs4_sequence);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_reclaim_complete);
 #endif /* CONFIG_NFS_V4_1 */
 
+DECLARE_EVENT_CLASS(nfs4_open_event,
+		TP_PROTO(
+			const struct nfs_open_context *ctx,
+			int flags,
+			int error
+		),
+
+		TP_ARGS(ctx, flags, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(unsigned int, flags)
+			__field(unsigned int, fmode)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(u64, dir)
+			__string(name, ctx->dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			const struct nfs4_state *state = ctx->state;
+			const struct inode *inode = NULL;
+
+			__entry->error = error;
+			__entry->flags = flags;
+			__entry->fmode = (__force unsigned int)ctx->mode;
+			__entry->dev = ctx->dentry->d_sb->s_dev;
+			if (!IS_ERR(state))
+				inode = state->inode;
+			if (inode != NULL) {
+				__entry->fileid = NFS_FILEID(inode);
+				__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			} else {
+				__entry->fileid = 0;
+				__entry->fhandle = 0;
+			}
+			__entry->dir = NFS_FILEID(ctx->dentry->d_parent->d_inode);
+			__assign_str(name, ctx->dentry->d_name.name);
+		),
+
+		TP_printk(
+			"error=%d (%s) flags=%d (%s) fmode=%s "
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"name=%02x:%02x:%llu/%s",
+			 __entry->error,
+			 show_nfsv4_errors(__entry->error),
+			 __entry->flags,
+			 show_open_flags(__entry->flags),
+			 show_fmode_flags(__entry->fmode),
+			 MAJOR(__entry->dev), MINOR(__entry->dev),
+			 (unsigned long long)__entry->fileid,
+			 __entry->fhandle,
+			 MAJOR(__entry->dev), MINOR(__entry->dev),
+			 (unsigned long long)__entry->dir,
+			 __get_str(name)
+		)
+);
+
+#define DEFINE_NFS4_OPEN_EVENT(name) \
+	DEFINE_EVENT(nfs4_open_event, name, \
+			TP_PROTO( \
+				const struct nfs_open_context *ctx, \
+				int flags, \
+				int error \
+			), \
+			TP_ARGS(ctx, flags, error))
+DEFINE_NFS4_OPEN_EVENT(nfs4_open_reclaim);
+DEFINE_NFS4_OPEN_EVENT(nfs4_open_expired);
+DEFINE_NFS4_OPEN_EVENT(nfs4_open_file);
+
+TRACE_EVENT(nfs4_close,
+		TP_PROTO(
+			const struct nfs4_state *state,
+			const struct nfs_closeargs *args,
+			const struct nfs_closeres *res,
+			int error
+		),
+
+		TP_ARGS(state, args, res, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(unsigned int, fmode)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = state->inode;
+
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->fmode = (__force unsigned int)state->state;
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"error=%d (%s) fmode=%s fileid=%02x:%02x:%llu "
+			"fhandle=0x%08x",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			__entry->fmode ?  show_fmode_flags(__entry->fmode) :
+					  "closed",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle
+		)
+);
+
 #endif /* _TRACE_NFS4_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
1.8.3.1

