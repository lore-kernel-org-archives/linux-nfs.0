Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:42539 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760187Ab3HNXZO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 19:25:14 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 07/13] NFSv4: Add tracepoints for debugging rename
Date: Wed, 14 Aug 2013 19:24:52 -0400
Message-ID: <1376522698-44596-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376522698-44596-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1376522698-44596-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-2-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-3-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-4-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-5-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-6-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-7-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints to debug both synchronous and asynchronous renames.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  | 13 +++++++++----
 fs/nfs/nfs4trace.h | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 28909ca..1b39139 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3330,10 +3330,14 @@ static void nfs4_proc_rename_rpc_prepare(struct rpc_task *task, struct nfs_renam
 static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 				 struct inode *new_dir)
 {
-	struct nfs_renameres *res = task->tk_msg.rpc_resp;
+	struct nfs_renamedata *data = task->tk_calldata;
+	struct nfs_renameres *res = &data->res;
 
 	if (!nfs4_sequence_done(task, &res->seq_res))
 		return 0;
+	trace_nfs4_rename_async(old_dir, data->args.old_name,
+			new_dir, data->args.new_name,
+			task->tk_status);
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 
@@ -3376,9 +3380,10 @@ static int nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(old_dir),
-				_nfs4_proc_rename(old_dir, old_name,
-					new_dir, new_name),
+		err = _nfs4_proc_rename(old_dir, old_name,
+					new_dir, new_name);
+		trace_nfs4_rename(old_dir, old_name, new_dir, new_name, err);
+		err = nfs4_handle_exception(NFS_SERVER(old_dir), err,
 				&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index a9414cf..d707366 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -437,6 +437,56 @@ DEFINE_NFS4_LOOKUP_EVENT(nfs4_remove_async);
 DEFINE_NFS4_LOOKUP_EVENT(nfs4_get_fs_locations);
 DEFINE_NFS4_LOOKUP_EVENT(nfs4_secinfo);
 
+DECLARE_EVENT_CLASS(nfs4_rename_event,
+		TP_PROTO(const struct inode *olddir,
+			const struct qstr *oldname,
+			const struct inode *newdir,
+			const struct qstr *newname,
+			int error),
+
+		TP_ARGS(olddir, oldname, newdir, newname, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(int, error)
+			__field(u64, olddir)
+			__string(oldname, oldname->name)
+			__field(u64, newdir)
+			__string(newname, newname->name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = olddir->i_sb->s_dev;
+			__entry->olddir = NFS_FILEID(olddir);
+			__entry->newdir = NFS_FILEID(newdir);
+			__entry->error = error;
+			__assign_str(oldname, oldname->name);
+			__assign_str(newname, newname->name);
+		),
+
+		TP_printk("error=%d (%s), oldname=%02x:%02x:%lld/%s, "
+			  "newname=%02x:%02x:%lld/%s",
+			  __entry->error,
+			  show_nfsv4_errors(__entry->error),
+			  MAJOR(__entry->dev), MINOR(__entry->dev),
+			  (unsigned long long)__entry->olddir,
+			  __get_str(oldname),
+			  MAJOR(__entry->dev), MINOR(__entry->dev),
+			  (unsigned long long)__entry->newdir,
+			  __get_str(newname)
+		)
+);
+#define DEFINE_NFS4_RENAME_EVENT(name)				\
+	DEFINE_EVENT(nfs4_rename_event, name,			\
+		TP_PROTO(const struct inode *olddir,		\
+			const struct qstr *oldname,		\
+			const struct inode *newdir,		\
+			const struct qstr *newname,		\
+			int error),				\
+		TP_ARGS(olddir, oldname, newdir, newname, error))
+DEFINE_NFS4_RENAME_EVENT(nfs4_rename);
+DEFINE_NFS4_RENAME_EVENT(nfs4_rename_async);
+
 DECLARE_EVENT_CLASS(nfs4_inode_event,
 		TP_PROTO(const struct inode *inode,
 			int error),
-- 
1.8.3.1

