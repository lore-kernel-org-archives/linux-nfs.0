Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:10024 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3HVAY0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:26 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 07/21] NFS: Add tracepoints for debugging NFS rename and sillyrename issues
Date: Wed, 21 Aug 2013 20:24:05 -0400
Message-ID: <1377131059-40121-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-7-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |   3 ++
 fs/nfs/nfstrace.h | 138 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/unlink.c   |   5 ++
 3 files changed, 146 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e41dec5..dca7deb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1909,6 +1909,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		 new_dentry->d_parent->d_name.name, new_dentry->d_name.name,
 		 d_count(new_dentry));
 
+	trace_nfs_rename_enter(old_dir, old_dentry, new_dir, new_dentry);
 	/*
 	 * For non-directories, check whether the target is busy and if so,
 	 * make a copy of the dentry and then do a silly-rename. If the
@@ -1955,6 +1956,8 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 out:
 	if (rehash)
 		d_rehash(rehash);
+	trace_nfs_rename_exit(old_dir, old_dentry,
+			new_dir, new_dentry, error);
 	if (!error) {
 		if (new_inode != NULL)
 			nfs_drop_nlink(new_inode);
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 5827906..a20f0d1 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -512,6 +512,144 @@ DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_unlink_exit);
 DEFINE_NFS_DIRECTORY_EVENT(nfs_symlink_enter);
 DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_symlink_exit);
 
+DECLARE_EVENT_CLASS(nfs_rename_event,
+		TP_PROTO(
+			const struct inode *old_dir,
+			const struct dentry *old_dentry,
+			const struct inode *new_dir,
+			const struct dentry *new_dentry
+		),
+
+		TP_ARGS(old_dir, old_dentry, new_dir, new_dentry),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u64, old_dir)
+			__field(u64, new_dir)
+			__string(old_name, old_dentry->d_name.name)
+			__string(new_name, new_dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = old_dir->i_sb->s_dev;
+			__entry->old_dir = NFS_FILEID(old_dir);
+			__entry->new_dir = NFS_FILEID(new_dir);
+			__assign_str(old_name, old_dentry->d_name.name);
+			__assign_str(new_name, new_dentry->d_name.name);
+		),
+
+		TP_printk(
+			"old_name=%02x:%02x:%llu/%s new_name=%02x:%02x:%llu/%s",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->old_dir,
+			__get_str(old_name),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->new_dir,
+			__get_str(new_name)
+		)
+);
+#define DEFINE_NFS_RENAME_EVENT(name) \
+	DEFINE_EVENT(nfs_rename_event, name, \
+			TP_PROTO( \
+				const struct inode *old_dir, \
+				const struct dentry *old_dentry, \
+				const struct inode *new_dir, \
+				const struct dentry *new_dentry \
+			), \
+			TP_ARGS(old_dir, old_dentry, new_dir, new_dentry))
+
+DECLARE_EVENT_CLASS(nfs_rename_event_done,
+		TP_PROTO(
+			const struct inode *old_dir,
+			const struct dentry *old_dentry,
+			const struct inode *new_dir,
+			const struct dentry *new_dentry,
+			int error
+		),
+
+		TP_ARGS(old_dir, old_dentry, new_dir, new_dentry, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(int, error)
+			__field(u64, old_dir)
+			__string(old_name, old_dentry->d_name.name)
+			__field(u64, new_dir)
+			__string(new_name, new_dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = old_dir->i_sb->s_dev;
+			__entry->old_dir = NFS_FILEID(old_dir);
+			__entry->new_dir = NFS_FILEID(new_dir);
+			__entry->error = error;
+			__assign_str(old_name, old_dentry->d_name.name);
+			__assign_str(new_name, new_dentry->d_name.name);
+		),
+
+		TP_printk(
+			"error=%d old_name=%02x:%02x:%llu/%s "
+			"new_name=%02x:%02x:%llu/%s",
+			__entry->error,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->old_dir,
+			__get_str(old_name),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->new_dir,
+			__get_str(new_name)
+		)
+);
+#define DEFINE_NFS_RENAME_EVENT_DONE(name) \
+	DEFINE_EVENT(nfs_rename_event_done, name, \
+			TP_PROTO( \
+				const struct inode *old_dir, \
+				const struct dentry *old_dentry, \
+				const struct inode *new_dir, \
+				const struct dentry *new_dentry, \
+				int error \
+			), \
+			TP_ARGS(old_dir, old_dentry, new_dir, \
+				new_dentry, error))
+
+DEFINE_NFS_RENAME_EVENT(nfs_rename_enter);
+DEFINE_NFS_RENAME_EVENT_DONE(nfs_rename_exit);
+
+DEFINE_NFS_RENAME_EVENT_DONE(nfs_sillyrename_rename);
+
+TRACE_EVENT(nfs_sillyrename_unlink,
+		TP_PROTO(
+			const struct nfs_unlinkdata *data,
+			int error
+		),
+
+		TP_ARGS(data, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(int, error)
+			__field(u64, dir)
+			__dynamic_array(char, name, data->args.name.len + 1)
+		),
+
+		TP_fast_assign(
+			struct inode *dir = data->dir;
+			size_t len = data->args.name.len;
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->error = error;
+			memcpy(__get_dynamic_array(name),
+				data->args.name.name, len);
+			((char *)__get_dynamic_array(name))[len] = 0;
+		),
+
+		TP_printk(
+			"error=%d name=%02x:%02x:%llu/%s",
+			__entry->error,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
 #endif /* _TRACE_NFS_H */
 
 #undef TRACE_INCLUDE_PATH
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 488fd16..2c1485d 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -20,6 +20,8 @@
 #include "iostat.h"
 #include "delegation.h"
 
+#include "nfstrace.h"
+
 /**
  * nfs_free_unlinkdata - release data from a sillydelete operation.
  * @data: pointer to unlink structure.
@@ -77,6 +79,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 	struct nfs_unlinkdata *data = calldata;
 	struct inode *dir = data->dir;
 
+	trace_nfs_sillyrename_unlink(data, task->tk_status);
 	if (!NFS_PROTO(dir)->unlink_done(task, dir))
 		rpc_restart_call_prepare(task);
 }
@@ -336,6 +339,8 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
 	struct inode *new_dir = data->new_dir;
 	struct dentry *old_dentry = data->old_dentry;
 
+	trace_nfs_sillyrename_rename(old_dir, old_dentry,
+			new_dir, data->new_dentry, task->tk_status);
 	if (!NFS_PROTO(old_dir)->rename_done(task, old_dir, new_dir)) {
 		rpc_restart_call_prepare(task);
 		return;
-- 
1.8.3.1

