Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:16636 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808Ab3HTTfV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 15:35:21 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 08/16] NFSv4: Add tracepoints for debugging lookup/create operations
Date: Tue, 20 Aug 2013 15:35:04 -0400
Message-ID: <1377027312-45957-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377027312-45957-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-8-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up basic tracepoints for debugging NFSv4 lookup, unlink/remove,
symlink, mkdir, mknod, fs_locations and secinfo.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  | 37 +++++++++++++++++++++++--------------
 fs/nfs/nfs4trace.h | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78e2ff4..8da223c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3026,6 +3026,7 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 	int err;
 	do {
 		err = _nfs4_proc_lookup(client, dir, name, fhandle, fattr, label);
+		trace_nfs4_lookup(dir, name, err);
 		switch (err) {
 		case -NFS4ERR_BADNAME:
 			err = -ENOENT;
@@ -3261,8 +3262,9 @@ static int nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_remove(dir, name),
+		err = _nfs4_proc_remove(dir, name);
+		trace_nfs4_remove(dir, name, err);
+		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -3291,10 +3293,12 @@ static void nfs4_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlin
 
 static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	struct nfs_removeres *res = task->tk_msg.rpc_resp;
+	struct nfs_unlinkdata *data = task->tk_calldata;
+	struct nfs_removeres *res = &data->res;
 
 	if (!nfs4_sequence_done(task, &res->seq_res))
 		return 0;
+	trace_nfs4_remove_async(dir, &data->args.name, task->tk_status);
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
@@ -3533,9 +3537,9 @@ static int nfs4_proc_symlink(struct inode *dir, struct dentry *dentry,
 	label = nfs4_label_init_security(dir, dentry, sattr, &l);
 
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_symlink(dir, dentry, page,
-							len, sattr, label),
+		err = _nfs4_proc_symlink(dir, dentry, page, len, sattr, label);
+		trace_nfs4_symlink(dir, &dentry->d_name, err);
+		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
 	} while (exception.retry);
 
@@ -3572,8 +3576,9 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 
 	sattr->ia_mode &= ~current_umask();
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_mkdir(dir, dentry, sattr, label),
+		err = _nfs4_proc_mkdir(dir, dentry, sattr, label);
+		trace_nfs4_mkdir(dir, &dentry->d_name, err);
+		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
 	} while (exception.retry);
 	nfs4_label_release_security(label);
@@ -3680,8 +3685,9 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 
 	sattr->ia_mode &= ~current_umask();
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_mknod(dir, dentry, sattr, label, rdev),
+		err = _nfs4_proc_mknod(dir, dentry, sattr, label, rdev);
+		trace_nfs4_mknod(dir, &dentry->d_name, err);
+		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
 	} while (exception.retry);
 
@@ -5801,8 +5807,10 @@ int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_fs_locations(client, dir, name, fs_locations, page),
+		err = _nfs4_proc_fs_locations(client, dir, name,
+				fs_locations, page);
+		trace_nfs4_get_fs_locations(dir, name, err);
+		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -5836,8 +5844,9 @@ int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dir),
-				_nfs4_proc_secinfo(dir, name, flavors),
+		err = _nfs4_proc_secinfo(dir, name, flavors);
+		trace_nfs4_secinfo(dir, name, err);
+		err = nfs4_handle_exception(NFS_SERVER(dir), err,
 				&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index feb0eb5..ec379c3 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -408,6 +408,57 @@ DEFINE_NFS4_LOCK_EVENT(nfs4_lock_reclaim);
 DEFINE_NFS4_LOCK_EVENT(nfs4_lock_expired);
 DEFINE_NFS4_LOCK_EVENT(nfs4_unlock);
 
+DECLARE_EVENT_CLASS(nfs4_lookup_event,
+		TP_PROTO(
+			const struct inode *dir,
+			const struct qstr *name,
+			int error
+		),
+
+		TP_ARGS(dir, name, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(int, error)
+			__field(u64, dir)
+			__string(name, name->name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->error = error;
+			__assign_str(name, name->name);
+		),
+
+		TP_printk(
+			"error=%d (%s) name=%02x:%02x:%llu/%s",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+#define DEFINE_NFS4_LOOKUP_EVENT(name) \
+	DEFINE_EVENT(nfs4_lookup_event, name, \
+			TP_PROTO( \
+				const struct inode *dir, \
+				const struct qstr *name, \
+				int error \
+			), \
+			TP_ARGS(dir, name, error))
+
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_lookup);
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_symlink);
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_mkdir);
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_mknod);
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_remove);
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_remove_async);
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_get_fs_locations);
+DEFINE_NFS4_LOOKUP_EVENT(nfs4_secinfo);
+
 #endif /* _TRACE_NFS4_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
1.8.3.1

