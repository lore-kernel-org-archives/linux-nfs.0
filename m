Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:16636 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814Ab3HTTfW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 15:35:22 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 10/16] NFSv4: Add tracepoints for debugging rename
Date: Tue, 20 Aug 2013 15:35:06 -0400
Message-ID: <1377027312-45957-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377027312-45957-10-git-send-email-Trond.Myklebust@netapp.com>
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
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints to debug both synchronous and asynchronous renames.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  | 13 +++++++++----
 fs/nfs/nfs4trace.h | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e2f0627..a7543b9 100644
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
index 2f3d0fc..90d2083 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -459,6 +459,61 @@ DEFINE_NFS4_LOOKUP_EVENT(nfs4_remove_async);
 DEFINE_NFS4_LOOKUP_EVENT(nfs4_get_fs_locations);
 DEFINE_NFS4_LOOKUP_EVENT(nfs4_secinfo);
 
+DECLARE_EVENT_CLASS(nfs4_rename_event,
+		TP_PROTO(
+			const struct inode *olddir,
+			const struct qstr *oldname,
+			const struct inode *newdir,
+			const struct qstr *newname,
+			int error
+		),
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
+		TP_printk(
+			"error=%d (%s) oldname=%02x:%02x:%llu/%s "
+			"newname=%02x:%02x:%llu/%s",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->olddir,
+			__get_str(oldname),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->newdir,
+			__get_str(newname)
+		)
+);
+#define DEFINE_NFS4_RENAME_EVENT(name) \
+	DEFINE_EVENT(nfs4_rename_event, name, \
+			TP_PROTO( \
+				const struct inode *olddir, \
+				const struct qstr *oldname, \
+				const struct inode *newdir, \
+				const struct qstr *newname, \
+				int error \
+			), \
+			TP_ARGS(olddir, oldname, newdir, newname, error))
+DEFINE_NFS4_RENAME_EVENT(nfs4_rename);
+DEFINE_NFS4_RENAME_EVENT(nfs4_rename_async);
+
 DECLARE_EVENT_CLASS(nfs4_inode_event,
 		TP_PROTO(
 			const struct inode *inode,
-- 
1.8.3.1

