Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:47525 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806Ab3HTTfU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 15:35:20 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 07/16] NFSv4: Add tracepoints for debugging file locking
Date: Tue, 20 Aug 2013 15:35:03 -0400
Message-ID: <1377027312-45957-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377027312-45957-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-7-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up basic tracepoints for debugging NFSv4 file lock/unlock

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |  9 +++++--
 fs/nfs/nfs4trace.h | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 784748b..78e2ff4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4964,8 +4964,9 @@ static int nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock *
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
@@ -5163,6 +5164,7 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	rpc_put_task(task);
 out:
 	request->fl_flags = fl_flags;
+	trace_nfs4_unlock(request, state, F_SETLK, status);
 	return status;
 }
 
@@ -5386,6 +5388,7 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_RECLAIM);
+		trace_nfs4_lock_reclaim(request, state, F_SETLK, err);
 		if (err != -NFS4ERR_DELAY)
 			break;
 		nfs4_handle_exception(server, err, &exception);
@@ -5408,6 +5411,7 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_EXPIRED);
+		trace_nfs4_lock_expired(request, state, F_SETLK, err);
 		switch (err) {
 		default:
 			goto out;
@@ -5530,6 +5534,7 @@ static int nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *
 
 	do {
 		err = _nfs4_proc_setlk(state, cmd, request);
+		trace_nfs4_set_lock(request, state, cmd, err);
 		if (err == -NFS4ERR_DENIED)
 			err = -EAGAIN;
 		err = nfs4_handle_exception(NFS_SERVER(state->inode),
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index beb1db7..feb0eb5 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -333,6 +333,81 @@ TRACE_EVENT(nfs4_close,
 		)
 );
 
+#define show_lock_cmd(type) \
+	__print_symbolic((int)type, \
+		{ F_GETLK, "GETLK" }, \
+		{ F_SETLK, "SETLK" }, \
+		{ F_SETLKW, "SETLKW" })
+#define show_lock_type(type) \
+	__print_symbolic((int)type, \
+		{ F_RDLCK, "RDLCK" }, \
+		{ F_WRLCK, "WRLCK" }, \
+		{ F_UNLCK, "UNLCK" })
+
+DECLARE_EVENT_CLASS(nfs4_lock_event,
+		TP_PROTO(
+			const struct file_lock *request,
+			const struct nfs4_state *state,
+			int cmd,
+			int error
+		),
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
+		),
+
+		TP_printk(
+			"error=%d (%s) cmd=%s:%s range=%lld:%lld "
+			"fileid=%02x:%02x:%llu fhandle=0x%08x",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			show_lock_cmd(__entry->cmd),
+			show_lock_type(__entry->type),
+			(long long)__entry->start,
+			(long long)__entry->end,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle
+		)
+);
+
+#define DEFINE_NFS4_LOCK_EVENT(name) \
+	DEFINE_EVENT(nfs4_lock_event, name, \
+			TP_PROTO( \
+				const struct file_lock *request, \
+				const struct nfs4_state *state, \
+				int cmd, \
+				int error \
+			), \
+			TP_ARGS(request, state, cmd, error))
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

