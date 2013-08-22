Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:10289 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806Ab3HVAYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 04/21] NFS: Add event tracing for generic NFS lookups
Date: Wed, 21 Aug 2013 20:24:02 -0400
Message-ID: <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints for lookup, lookup_revalidate and atomic_open

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |   7 ++
 fs/nfs/nfstrace.c |   1 +
 fs/nfs/nfstrace.h | 195 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 203 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 29d5463..2263a6b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1102,7 +1102,9 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (IS_ERR(label))
 		goto out_error;
 
+	trace_nfs_lookup_revalidate_enter(dir, dentry, flags);
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
+	trace_nfs_lookup_revalidate_exit(dir, dentry, flags, error);
 	if (error)
 		goto out_bad;
 	if (nfs_compare_fh(NFS_FH(inode), fhandle))
@@ -1315,6 +1317,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
 
 	parent = dentry->d_parent;
 	/* Protect against concurrent sillydeletes */
+	trace_nfs_lookup_enter(dir, dentry, flags);
 	nfs_block_sillyrename(parent);
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
 	if (error == -ENOENT)
@@ -1341,6 +1344,7 @@ no_entry:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 out_unblock_sillyrename:
 	nfs_unblock_sillyrename(parent);
+	trace_nfs_lookup_exit(dir, dentry, flags, error);
 	nfs4_label_free(label);
 out:
 	nfs_free_fattr(fattr);
@@ -1451,12 +1455,14 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	if (IS_ERR(ctx))
 		goto out;
 
+	trace_nfs_atomic_open_enter(dir, ctx, open_flags);
 	nfs_block_sillyrename(dentry->d_parent);
 	inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr);
 	nfs_unblock_sillyrename(dentry->d_parent);
 	if (IS_ERR(inode)) {
 		put_nfs_open_context(ctx);
 		err = PTR_ERR(inode);
+		trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 		switch (err) {
 		case -ENOENT:
 			d_drop(dentry);
@@ -1477,6 +1483,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	}
 
 	err = nfs_finish_open(ctx, ctx->dentry, file, open_flags, opened);
+	trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 out:
 	return err;
 
diff --git a/fs/nfs/nfstrace.c b/fs/nfs/nfstrace.c
index cc91461..4eb0aea 100644
--- a/fs/nfs/nfstrace.c
+++ b/fs/nfs/nfstrace.c
@@ -2,6 +2,7 @@
  * Copyright (c) 2013 Trond Myklebust <Trond.Myklebust@netapp.com>
  */
 #include <linux/nfs_fs.h>
+#include <linux/namei.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 73c8e1e..fba194b 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -157,6 +157,201 @@ DEFINE_NFS_INODE_EVENT_DONE(nfs_fsync_exit);
 DEFINE_NFS_INODE_EVENT(nfs_access_enter);
 DEFINE_NFS_INODE_EVENT_DONE(nfs_access_exit);
 
+#define show_lookup_flags(flags) \
+	__print_flags((unsigned long)flags, "|", \
+			{ LOOKUP_AUTOMOUNT, "AUTOMOUNT" }, \
+			{ LOOKUP_DIRECTORY, "DIRECTORY" }, \
+			{ LOOKUP_OPEN, "OPEN" }, \
+			{ LOOKUP_CREATE, "CREATE" }, \
+			{ LOOKUP_EXCL, "EXCL" })
+
+DECLARE_EVENT_CLASS(nfs_lookup_event,
+		TP_PROTO(
+			const struct inode *dir,
+			const struct dentry *dentry,
+			unsigned int flags
+		),
+
+		TP_ARGS(dir, dentry, flags),
+
+		TP_STRUCT__entry(
+			__field(unsigned int, flags)
+			__field(dev_t, dev)
+			__field(u64, dir)
+			__string(name, dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->flags = flags;
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk(
+			"flags=%u (%s) name=%02x:%02x:%llu/%s",
+			__entry->flags,
+			show_lookup_flags(__entry->flags),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+#define DEFINE_NFS_LOOKUP_EVENT(name) \
+	DEFINE_EVENT(nfs_lookup_event, name, \
+			TP_PROTO( \
+				const struct inode *dir, \
+				const struct dentry *dentry, \
+				unsigned int flags \
+			), \
+			TP_ARGS(dir, dentry, flags))
+
+DECLARE_EVENT_CLASS(nfs_lookup_event_done,
+		TP_PROTO(
+			const struct inode *dir,
+			const struct dentry *dentry,
+			unsigned int flags,
+			int error
+		),
+
+		TP_ARGS(dir, dentry, flags, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(unsigned int, flags)
+			__field(dev_t, dev)
+			__field(u64, dir)
+			__string(name, dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->error = error;
+			__entry->flags = flags;
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk(
+			"error=%d flags=%u (%s) name=%02x:%02x:%llu/%s",
+			__entry->error,
+			__entry->flags,
+			show_lookup_flags(__entry->flags),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+#define DEFINE_NFS_LOOKUP_EVENT_DONE(name) \
+	DEFINE_EVENT(nfs_lookup_event_done, name, \
+			TP_PROTO( \
+				const struct inode *dir, \
+				const struct dentry *dentry, \
+				unsigned int flags, \
+				int error \
+			), \
+			TP_ARGS(dir, dentry, flags, error))
+
+DEFINE_NFS_LOOKUP_EVENT(nfs_lookup_enter);
+DEFINE_NFS_LOOKUP_EVENT_DONE(nfs_lookup_exit);
+DEFINE_NFS_LOOKUP_EVENT(nfs_lookup_revalidate_enter);
+DEFINE_NFS_LOOKUP_EVENT_DONE(nfs_lookup_revalidate_exit);
+
+#define show_open_flags(flags) \
+	__print_flags((unsigned long)flags, "|", \
+		{ O_CREAT, "O_CREAT" }, \
+		{ O_EXCL, "O_EXCL" }, \
+		{ O_TRUNC, "O_TRUNC" }, \
+		{ O_APPEND, "O_APPEND" }, \
+		{ O_DSYNC, "O_DSYNC" }, \
+		{ O_DIRECT, "O_DIRECT" }, \
+		{ O_DIRECTORY, "O_DIRECTORY" })
+
+#define show_fmode_flags(mode) \
+	__print_flags(mode, "|", \
+		{ ((__force unsigned long)FMODE_READ), "READ" }, \
+		{ ((__force unsigned long)FMODE_WRITE), "WRITE" }, \
+		{ ((__force unsigned long)FMODE_EXEC), "EXEC" })
+
+TRACE_EVENT(nfs_atomic_open_enter,
+		TP_PROTO(
+			const struct inode *dir,
+			const struct nfs_open_context *ctx,
+			unsigned int flags
+		),
+
+		TP_ARGS(dir, ctx, flags),
+
+		TP_STRUCT__entry(
+			__field(unsigned int, flags)
+			__field(unsigned int, fmode)
+			__field(dev_t, dev)
+			__field(u64, dir)
+			__string(name, ctx->dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->flags = flags;
+			__entry->fmode = (__force unsigned int)ctx->mode;
+			__assign_str(name, ctx->dentry->d_name.name);
+		),
+
+		TP_printk(
+			"flags=%u (%s) fmode=%s name=%02x:%02x:%llu/%s",
+			__entry->flags,
+			show_open_flags(__entry->flags),
+			show_fmode_flags(__entry->fmode),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+TRACE_EVENT(nfs_atomic_open_exit,
+		TP_PROTO(
+			const struct inode *dir,
+			const struct nfs_open_context *ctx,
+			unsigned int flags,
+			int error
+		),
+
+		TP_ARGS(dir, ctx, flags, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(unsigned int, flags)
+			__field(unsigned int, fmode)
+			__field(dev_t, dev)
+			__field(u64, dir)
+			__string(name, ctx->dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->error = error;
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->flags = flags;
+			__entry->fmode = (__force unsigned int)ctx->mode;
+			__assign_str(name, ctx->dentry->d_name.name);
+		),
+
+		TP_printk(
+			"error=%d flags=%u (%s) fmode=%s "
+			"name=%02x:%02x:%llu/%s",
+			__entry->error,
+			__entry->flags,
+			show_open_flags(__entry->flags),
+			show_fmode_flags(__entry->fmode),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
 #endif /* _TRACE_NFS_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
1.8.3.1

