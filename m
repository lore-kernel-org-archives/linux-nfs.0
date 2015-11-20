Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:17636 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761139AbbKTVwI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 16:52:08 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Adding stateid information to tracepoints
Date: Fri, 20 Nov 2015 16:51:51 -0500
Message-ID: <1448056311-93218-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Operations to which stateid information is added:
close, delegreturn, open, read, setattr, layoutget, layoutcommit, test_stateid,
write, lock, locku, lockt

Format is "stateid=<seqid>:<crc32 hash stateid.other>", also "openstateid=",
"layoutstateid=", and "lockstateid=" for open_file, layoutget, set_lock
tracepoints.

New function is added to internal.h, nfs_stateid_hash(), to compute the hash

trace_nfs4_setattr() is moved from nfs4_do_setattr() to _nfs4_do_setattr()
to get access to stateid.

trace_nfs4_setattr and trace_nfs4_delegreturn are changed from INODE_EVENT
to new event type, INODE_STATEID_EVENT which is same as INODE_EVENT but adds
stateid information

for locking tracepoints, moved trace_nfs4_set_lock() into _nfs4_do_setlk()
to get access to stateid information, and removed trace_nfs4_lock_reclaim(),
trace_nfs4_lock_expired() as they call into _nfs4_do_setlk() and both were
previously same LOCK_EVENT type.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/internal.h  |   9 ++
 fs/nfs/nfs4proc.c  |  13 ++-
 fs/nfs/nfs4trace.h | 255 +++++++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 245 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 56cfde2..41aee6d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -696,9 +696,18 @@ static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
 {
 	return ~crc32_le(0xFFFFFFFF, &fh->data[0], fh->size);
 }
+static inline u32 nfs_stateid_hash(const nfs4_stateid *stateid)
+{
+	return ~crc32_le(0xFFFFFFFF, &stateid->other[0],
+				NFS4_STATEID_OTHER_SIZE);
+}
 #else
 static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
 {
 	return 0;
 }
+static inline u32 nfs_stateid_hash(nfs4_stateid *stateid)
+{
+	return 0;
+}
 #endif
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ed8f2c..5c891c3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2703,6 +2703,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
+	trace_nfs4_setattr(inode, &arg.stateid, status);
 	return status;
 }
 
@@ -2719,7 +2720,6 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	int err;
 	do {
 		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
-		trace_nfs4_setattr(inode, err);
 		switch (err) {
 		case -NFS4ERR_OPENMODE:
 			if (!(sattr->ia_valid & ATTR_SIZE)) {
@@ -5426,7 +5426,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 	int err;
 	do {
 		err = _nfs4_proc_delegreturn(inode, cred, stateid, issync);
-		trace_nfs4_delegreturn(inode, err);
+		trace_nfs4_delegreturn(inode, stateid, err);
 		switch (err) {
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_EXPIRED:
@@ -5947,6 +5947,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 		data->cancelled = 1;
 	rpc_put_task(task);
 	dprintk("%s: done, ret = %d!\n", __func__, ret);
+	trace_nfs4_set_lock(fl, state, &data->res.stateid, cmd, ret);
 	return ret;
 }
 
@@ -5963,7 +5964,6 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_RECLAIM);
-		trace_nfs4_lock_reclaim(request, state, F_SETLK, err);
 		if (err != -NFS4ERR_DELAY)
 			break;
 		nfs4_handle_exception(server, err, &exception);
@@ -5990,7 +5990,6 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_EXPIRED);
-		trace_nfs4_lock_expired(request, state, F_SETLK, err);
 		switch (err) {
 		default:
 			goto out;
@@ -6098,7 +6097,6 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
 
 	do {
 		err = _nfs4_proc_setlk(state, cmd, request);
-		trace_nfs4_set_lock(request, state, cmd, err);
 		if (err == -NFS4ERR_DENIED)
 			err = -EAGAIN;
 		err = nfs4_handle_exception(NFS_SERVER(state->inode),
@@ -7999,6 +7997,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 	trace_nfs4_layoutget(lgp->args.ctx,
 			&lgp->args.range,
 			&lgp->res.range,
+			&lgp->res.stateid,
 			status);
 	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
 	if (status == 0 && lgp->res.layoutp->len)
@@ -8106,7 +8105,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 		return PTR_ERR(task);
 	if (sync)
 		status = task->tk_status;
-	trace_nfs4_layoutreturn(lrp->args.inode, status);
+	trace_nfs4_layoutreturn(lrp->args.inode, &lrp->args.stateid, status);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	rpc_put_task(task);
 	return status;
@@ -8254,7 +8253,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 		return PTR_ERR(task);
 	if (sync)
 		status = task->tk_status;
-	trace_nfs4_layoutcommit(data->args.inode, status);
+	trace_nfs4_layoutcommit(data->args.inode, &data->args.stateid, status);
 	dprintk("%s: status %d\n", __func__, status);
 	rpc_put_task(task);
 	return status;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 671cf68..d59845a 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -399,6 +399,10 @@ DECLARE_EVENT_CLASS(nfs4_open_event,
 			__field(u64, fileid)
 			__field(u64, dir)
 			__string(name, ctx->dentry->d_name.name)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
+			__field(int, openstateid_seq)
+			__field(u32, openstateid_hash)
 		),
 
 		TP_fast_assign(
@@ -409,8 +413,22 @@ DECLARE_EVENT_CLASS(nfs4_open_event,
 			__entry->flags = flags;
 			__entry->fmode = (__force unsigned int)ctx->mode;
 			__entry->dev = ctx->dentry->d_sb->s_dev;
-			if (!IS_ERR_OR_NULL(state))
+			if (!IS_ERR_OR_NULL(state)) {
 				inode = state->inode;
+				__entry->stateid_seq =
+					be32_to_cpu(state->stateid.seqid);
+				__entry->stateid_hash =
+					nfs_stateid_hash(&state->stateid);
+				__entry->openstateid_seq =
+					be32_to_cpu(state->open_stateid.seqid);
+				__entry->openstateid_hash =
+					nfs_stateid_hash(&state->open_stateid);
+			} else {
+				__entry->stateid_seq = 0;
+				__entry->stateid_hash = 0;
+				__entry->openstateid_seq = 0;
+				__entry->openstateid_hash = 0;
+			}
 			if (inode != NULL) {
 				__entry->fileid = NFS_FILEID(inode);
 				__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
@@ -425,7 +443,8 @@ DECLARE_EVENT_CLASS(nfs4_open_event,
 		TP_printk(
 			"error=%d (%s) flags=%d (%s) fmode=%s "
 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
-			"name=%02x:%02x:%llu/%s",
+			"name=%02x:%02x:%llu/%s stateid=%d:0x%08x "
+			"openstateid=%d:0x%08x",
 			 __entry->error,
 			 show_nfsv4_errors(__entry->error),
 			 __entry->flags,
@@ -436,7 +455,9 @@ DECLARE_EVENT_CLASS(nfs4_open_event,
 			 __entry->fhandle,
 			 MAJOR(__entry->dev), MINOR(__entry->dev),
 			 (unsigned long long)__entry->dir,
-			 __get_str(name)
+			 __get_str(name),
+			 __entry->stateid_seq, __entry->stateid_hash,
+			 __entry->openstateid_seq, __entry->openstateid_hash
 		)
 );
 
@@ -468,6 +489,8 @@ TRACE_EVENT(nfs4_close,
 			__field(u64, fileid)
 			__field(unsigned int, fmode)
 			__field(int, error)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
 		),
 
 		TP_fast_assign(
@@ -478,18 +501,23 @@ TRACE_EVENT(nfs4_close,
 			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
 			__entry->fmode = (__force unsigned int)state->state;
 			__entry->error = error;
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
 		),
 
 		TP_printk(
 			"error=%d (%s) fmode=%s fileid=%02x:%02x:%llu "
-			"fhandle=0x%08x",
+			"fhandle=0x%08x openstateid=%d:0x%08x",
 			__entry->error,
 			show_nfsv4_errors(__entry->error),
 			__entry->fmode ?  show_fmode_flags(__entry->fmode) :
 					  "closed",
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
-			__entry->fhandle
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash
 		)
 );
 
@@ -523,6 +551,8 @@ DECLARE_EVENT_CLASS(nfs4_lock_event,
 			__field(dev_t, dev)
 			__field(u32, fhandle)
 			__field(u64, fileid)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
 		),
 
 		TP_fast_assign(
@@ -536,11 +566,16 @@ DECLARE_EVENT_CLASS(nfs4_lock_event,
 			__entry->dev = inode->i_sb->s_dev;
 			__entry->fileid = NFS_FILEID(inode);
 			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
 		),
 
 		TP_printk(
 			"error=%d (%s) cmd=%s:%s range=%lld:%lld "
-			"fileid=%02x:%02x:%llu fhandle=0x%08x",
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"stateid=%d:0x%08x",
 			__entry->error,
 			show_nfsv4_errors(__entry->error),
 			show_lock_cmd(__entry->cmd),
@@ -549,7 +584,8 @@ DECLARE_EVENT_CLASS(nfs4_lock_event,
 			(long long)__entry->end,
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
-			__entry->fhandle
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash
 		)
 );
 
@@ -563,11 +599,73 @@ DECLARE_EVENT_CLASS(nfs4_lock_event,
 			), \
 			TP_ARGS(request, state, cmd, error))
 DEFINE_NFS4_LOCK_EVENT(nfs4_get_lock);
-DEFINE_NFS4_LOCK_EVENT(nfs4_set_lock);
-DEFINE_NFS4_LOCK_EVENT(nfs4_lock_reclaim);
-DEFINE_NFS4_LOCK_EVENT(nfs4_lock_expired);
 DEFINE_NFS4_LOCK_EVENT(nfs4_unlock);
 
+TRACE_EVENT(nfs4_set_lock,
+		TP_PROTO(
+			const struct file_lock *request,
+			const struct nfs4_state *state,
+			const nfs4_stateid *lockstateid,
+			int cmd,
+			int error
+		),
+
+		TP_ARGS(request, state, lockstateid, cmd, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(int, cmd)
+			__field(char, type)
+			__field(loff_t, start)
+			__field(loff_t, end)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
+			__field(int, lockstateid_seq)
+			__field(u32, lockstateid_hash)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = state->inode;
+
+			__entry->error = error;
+			__entry->cmd = cmd;
+			__entry->type = request->fl_type;
+			__entry->start = request->fl_start;
+			__entry->end = request->fl_end;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
+			__entry->lockstateid_seq =
+				be32_to_cpu(lockstateid->seqid);
+			__entry->lockstateid_hash =
+				nfs_stateid_hash(lockstateid);
+		),
+
+		TP_printk(
+			"error=%d (%s) cmd=%s:%s range=%lld:%lld "
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"stateid=%d:0x%08x lockstateid=%d:0x%08x",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			show_lock_cmd(__entry->cmd),
+			show_lock_type(__entry->type),
+			(long long)__entry->start,
+			(long long)__entry->end,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash,
+			__entry->lockstateid_seq, __entry->lockstateid_hash
+		)
+);
+
 DECLARE_EVENT_CLASS(nfs4_set_delegation_event,
 		TP_PROTO(
 			const struct inode *inode,
@@ -621,20 +719,28 @@ TRACE_EVENT(nfs4_delegreturn_exit,
 			__field(dev_t, dev)
 			__field(u32, fhandle)
 			__field(int, error)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
 		),
 
 		TP_fast_assign(
 			__entry->dev = res->server->s_dev;
 			__entry->fhandle = nfs_fhandle_hash(args->fhandle);
 			__entry->error = error;
+			__entry->stateid_seq =
+				be32_to_cpu(args->stateid->seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(args->stateid);
 		),
 
 		TP_printk(
-			"error=%d (%s) dev=%02x:%02x fhandle=0x%08x",
+			"error=%d (%s) dev=%02x:%02x fhandle=0x%08x "
+			"stateid=%d:0x%08x",
 			__entry->error,
 			show_nfsv4_errors(__entry->error),
 			MAJOR(__entry->dev), MINOR(__entry->dev),
-			__entry->fhandle
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash
 		)
 );
 
@@ -653,6 +759,8 @@ DECLARE_EVENT_CLASS(nfs4_test_stateid_event,
 			__field(dev_t, dev)
 			__field(u32, fhandle)
 			__field(u64, fileid)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
 		),
 
 		TP_fast_assign(
@@ -662,15 +770,21 @@ DECLARE_EVENT_CLASS(nfs4_test_stateid_event,
 			__entry->dev = inode->i_sb->s_dev;
 			__entry->fileid = NFS_FILEID(inode);
 			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
 		),
 
 		TP_printk(
-			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x",
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"stateid=%d:0x%08x",
 			__entry->error,
 			show_nfsv4_errors(__entry->error),
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
-			__entry->fhandle
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash
 		)
 );
 
@@ -820,7 +934,6 @@ DECLARE_EVENT_CLASS(nfs4_inode_event,
 			), \
 			TP_ARGS(inode, error))
 
-DEFINE_NFS4_INODE_EVENT(nfs4_setattr);
 DEFINE_NFS4_INODE_EVENT(nfs4_access);
 DEFINE_NFS4_INODE_EVENT(nfs4_readlink);
 DEFINE_NFS4_INODE_EVENT(nfs4_readdir);
@@ -831,7 +944,59 @@ DEFINE_NFS4_INODE_EVENT(nfs4_get_security_label);
 DEFINE_NFS4_INODE_EVENT(nfs4_set_security_label);
 #endif /* CONFIG_NFS_V4_SECURITY_LABEL */
 DEFINE_NFS4_INODE_EVENT(nfs4_recall_delegation);
-DEFINE_NFS4_INODE_EVENT(nfs4_delegreturn);
+
+DECLARE_EVENT_CLASS(nfs4_inode_stateid_event,
+		TP_PROTO(
+			const struct inode *inode,
+			const nfs4_stateid *stateid,
+			int error
+		),
+
+		TP_ARGS(inode, stateid, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(int, error)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
+		),
+
+		TP_fast_assign(
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->error = error;
+			__entry->stateid_seq =
+				be32_to_cpu(stateid->seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(stateid);
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"stateid=%d:0x%08x",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash
+		)
+);
+
+#define DEFINE_NFS4_INODE_STATEID_EVENT(name) \
+	DEFINE_EVENT(nfs4_inode_stateid_event, name, \
+			TP_PROTO( \
+				const struct inode *inode, \
+				const nfs4_stateid *stateid, \
+				int error \
+			), \
+			TP_ARGS(inode, stateid, error))
+
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_setattr);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_delegreturn);
 
 DECLARE_EVENT_CLASS(nfs4_getattr_event,
 		TP_PROTO(
@@ -1005,28 +1170,37 @@ DECLARE_EVENT_CLASS(nfs4_read_event,
 			__field(loff_t, offset)
 			__field(size_t, count)
 			__field(int, error)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
 		),
 
 		TP_fast_assign(
 			const struct inode *inode = hdr->inode;
+			const struct nfs4_state *state =
+				hdr->args.context->state;
 			__entry->dev = inode->i_sb->s_dev;
 			__entry->fileid = NFS_FILEID(inode);
 			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
 			__entry->offset = hdr->args.offset;
 			__entry->count = hdr->args.count;
 			__entry->error = error;
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
 		),
 
 		TP_printk(
 			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
-			"offset=%lld count=%zu",
+			"offset=%lld count=%zu stateid=%d:0x%08x",
 			__entry->error,
 			show_nfsv4_errors(__entry->error),
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
 			__entry->fhandle,
 			(long long)__entry->offset,
-			__entry->count
+			__entry->count,
+			__entry->stateid_seq, __entry->stateid_hash
 		)
 );
 #define DEFINE_NFS4_READ_EVENT(name) \
@@ -1056,28 +1230,37 @@ DECLARE_EVENT_CLASS(nfs4_write_event,
 			__field(loff_t, offset)
 			__field(size_t, count)
 			__field(int, error)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
 		),
 
 		TP_fast_assign(
 			const struct inode *inode = hdr->inode;
+			const struct nfs4_state *state =
+				hdr->args.context->state;
 			__entry->dev = inode->i_sb->s_dev;
 			__entry->fileid = NFS_FILEID(inode);
 			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
 			__entry->offset = hdr->args.offset;
 			__entry->count = hdr->args.count;
 			__entry->error = error;
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
 		),
 
 		TP_printk(
 			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
-			"offset=%lld count=%zu",
+			"offset=%lld count=%zu stateid=%d:0x%08x",
 			__entry->error,
 			show_nfsv4_errors(__entry->error),
 			MAJOR(__entry->dev), MINOR(__entry->dev),
 			(unsigned long long)__entry->fileid,
 			__entry->fhandle,
 			(long long)__entry->offset,
-			__entry->count
+			__entry->count,
+			__entry->stateid_seq, __entry->stateid_hash
 		)
 );
 
@@ -1154,10 +1337,11 @@ TRACE_EVENT(nfs4_layoutget,
 			const struct nfs_open_context *ctx,
 			const struct pnfs_layout_range *args,
 			const struct pnfs_layout_range *res,
+			const nfs4_stateid *layout_stateid,
 			int error
 		),
 
-		TP_ARGS(ctx, args, res, error),
+		TP_ARGS(ctx, args, res, layout_stateid, error),
 
 		TP_STRUCT__entry(
 			__field(dev_t, dev)
@@ -1167,10 +1351,15 @@ TRACE_EVENT(nfs4_layoutget,
 			__field(u64, offset)
 			__field(u64, count)
 			__field(int, error)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
+			__field(int, layoutstateid_seq)
+			__field(u32, layoutstateid_hash)
 		),
 
 		TP_fast_assign(
 			const struct inode *inode = d_inode(ctx->dentry);
+			const struct nfs4_state *state = ctx->state;
 			__entry->dev = inode->i_sb->s_dev;
 			__entry->fileid = NFS_FILEID(inode);
 			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
@@ -1178,11 +1367,25 @@ TRACE_EVENT(nfs4_layoutget,
 			__entry->offset = args->offset;
 			__entry->count = args->length;
 			__entry->error = error;
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
+			if (!error) {
+				__entry->layoutstateid_seq =
+				be32_to_cpu(layout_stateid->seqid);
+				__entry->layoutstateid_hash =
+				nfs_stateid_hash(layout_stateid);
+			} else {
+				__entry->layoutstateid_seq = 0;
+				__entry->layoutstateid_hash = 0;
+			}
 		),
 
 		TP_printk(
 			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x "
-			"iomode=%s offset=%llu count=%llu",
+			"iomode=%s offset=%llu count=%llu stateid=%d:0x%08x "
+			"layoutstateid=%d:0x%08x",
 			__entry->error,
 			show_nfsv4_errors(__entry->error),
 			MAJOR(__entry->dev), MINOR(__entry->dev),
@@ -1190,12 +1393,14 @@ TRACE_EVENT(nfs4_layoutget,
 			__entry->fhandle,
 			show_pnfs_iomode(__entry->iomode),
 			(unsigned long long)__entry->offset,
-			(unsigned long long)__entry->count
+			(unsigned long long)__entry->count,
+			__entry->stateid_seq, __entry->stateid_hash,
+			__entry->layoutstateid_seq, __entry->layoutstateid_hash
 		)
 );
 
-DEFINE_NFS4_INODE_EVENT(nfs4_layoutcommit);
-DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_layoutcommit);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_layoutreturn);
 DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn_on_close);
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.8.3.1

