Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:46209 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757629Ab3HMSgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 14:36:04 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 04/10] NFSv4: Add tracepoints for debugging file locking
Date: Tue, 13 Aug 2013 14:35:46 -0400
Message-ID: <1376418952-12481-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376418952-12481-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1376418952-12481-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376418952-12481-2-git-send-email-Trond.Myklebust@netapp.com>
 <1376418952-12481-3-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up basic tracepoints for debugging NFSv4 file lock/unlock

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |  9 +++++--
 fs/nfs/nfs4trace.h | 77 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 213c519..3be9bb3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4963,8 +4963,9 @@ static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *
 	int err;
 
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(state->inode),
-				_nfs4_proc_getlk(state, cmd, request),
+		err = _nfs4_proc_getlk(state, cmd, request);
+		trace_nfs4_get_lock(request, state, cmd, err);
+		err = nfs4_handle_exception(NFS_SERVER(state->inode), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -5162,6 +5163,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	rpc_put_task(task);
 out:
 	request->fl_flags = fl_flags;
+	trace_nfs4_unlock(request, state, F_SETLK, status);
 	return status;
 }
 
@@ -5385,6 +5387,7 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_RECLAIM);
+		trace_nfs4_lock_reclaim(request, state, F_SETLK, err);
 		if (err != -NFS4ERR_DELAY)
 			break;
 		nfs4_handle_exception(server, err, &exception);
@@ -5407,6 +5410,7 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_EXPIRED);
+		trace_nfs4_lock_expired(request, state, F_SETLK, err);
 		switch (err) {
 		default:
 			goto out;
@@ -5529,6 +5533,7 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
 
 	do {
 		err = _nfs4_proc_setlk(state, cmd, request);
+		trace_nfs4_set_lock(request, state, cmd, err);
 		if (err == -NFS4ERR_DENIED)
 			err = -EAGAIN;
 		err = nfs4_handle_exception(NFS_SERVER(state->inode),
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 251806f..45972f2 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -308,6 +308,83 @@ TRACE_EVENT(nfs4_close,
 		)
 );
 
+#define show_lock_cmd(type)						\
+	__print_symbolic((int)type,					\
+		{ F_GETLK,			"GETLK" },		\
+		{ F_SETLK,			"SETLK" },		\
+		{ F_SETLKW,			"SETLKW" })
+#define show_lock_type(type)						\
+	__print_symbolic((int)type,					\
+		{ F_RDLCK,			"RDLCK" },		\
+		{ F_WRLCK,			"WRLCK" },		\
+		{ F_UNLCK,			"UNLCK" })
+
+DECLARE_EVENT_CLASS(nfs4_lock_event,
+		TP_PROTO(const struct file_lock *request,
+			const struct nfs4_state *state,
+			int cmd,
+			int error),
+
+		TP_ARGS(request, state, cmd, error),
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
+			__field(u64, dir)
+			__string(name, request->fl_file->f_path.dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			struct dentry *dentry = request->fl_file->f_path.dentry;
+			struct inode *inode = state->inode;
+
+			__entry->error = error;
+			__entry->cmd = cmd;
+			__entry->type = request->fl_type;
+			__entry->start = request->fl_start;
+			__entry->end = request->fl_end;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->dir = NFS_FILEID(dentry->d_parent->d_inode);
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk("error=%d (%s), cmd=%s:%s range=%lld:%lld "
+			  "fileid=%lld, fhandle=%0x08x name=%02x:%02x:%lld/%s",
+			  __entry->error,
+			  show_nfsv4_errors(__entry->error),
+			  show_lock_cmd(__entry->cmd),
+			  show_lock_type(__entry->type),
+			  (unsigned long long)__entry->start,
+			  (unsigned long long)__entry->end,
+			  (unsigned long long)__entry->fileid,
+			  __entry->fhandle,
+			  MAJOR(__entry->dev), MINOR(__entry->dev),
+			  (unsigned long long)__entry->dir,
+			  __get_str(name)
+		)
+);
+
+#define DEFINE_NFS4_LOCK_EVENT(name)		\
+DEFINE_EVENT(nfs4_lock_event, name,			\
+		TP_PROTO(const struct file_lock *request,\
+			const struct nfs4_state *state,	\
+			int cmd,			\
+			int error),			\
+		TP_ARGS(request, state, cmd, error))
+DEFINE_NFS4_LOCK_EVENT(nfs4_get_lock);
+DEFINE_NFS4_LOCK_EVENT(nfs4_set_lock);
+DEFINE_NFS4_LOCK_EVENT(nfs4_lock_reclaim);
+DEFINE_NFS4_LOCK_EVENT(nfs4_lock_expired);
+DEFINE_NFS4_LOCK_EVENT(nfs4_unlock);
+
 #endif /* _TRACE_NFS4_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
1.8.3.1

