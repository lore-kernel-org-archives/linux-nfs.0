Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:63017 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3HVAYX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 02/21] NFS: Add event tracing for generic NFS events
Date: Wed, 21 Aug 2013 20:24:00 -0400
Message-ID: <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints for inode attribute updates, attribute revalidation,
writeback start/end fsync start/end, attribute change start/end,
permission check start/end.

The intention is to enable performance tracing using 'perf'as well as
improving debugging.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/Makefile   |   3 +-
 fs/nfs/dir.c      |  16 ++++--
 fs/nfs/file.c     |   5 ++
 fs/nfs/inode.c    |  29 +++++++++-
 fs/nfs/nfstrace.c |   8 +++
 fs/nfs/nfstrace.h | 166 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/write.c    |  15 ++++-
 7 files changed, 231 insertions(+), 11 deletions(-)
 create mode 100644 fs/nfs/nfstrace.c
 create mode 100644 fs/nfs/nfstrace.h

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index e0bb048..6bd483b 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -4,9 +4,10 @@
 
 obj-$(CONFIG_NFS_FS) += nfs.o
 
+CFLAGS_nfstrace.o += -I$(src)
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   direct.o pagelist.o read.o symlink.o unlink.o \
-			   write.o namespace.o mount_clnt.o
+			   write.o namespace.o mount_clnt.o nfstrace.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_SYSCTL)	+= sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5d737bd..be3da6f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -43,6 +43,8 @@
 #include "internal.h"
 #include "fscache.h"
 
+#include "nfstrace.h"
+
 /* #define NFS_DEBUG_VERBOSE 1 */
 
 static int nfs_opendir(struct inode *, struct file *);
@@ -2178,9 +2180,11 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	struct nfs_access_entry cache;
 	int status;
 
+	trace_nfs_access_enter(inode);
+
 	status = nfs_access_get_cached(inode, cred, &cache);
 	if (status == 0)
-		goto out;
+		goto out_cached;
 
 	/* Be clever: ask server to check for all possible rights */
 	cache.mask = MAY_EXEC | MAY_WRITE | MAY_READ;
@@ -2193,13 +2197,15 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 			if (!S_ISDIR(inode->i_mode))
 				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
 		}
-		return status;
+		goto out;
 	}
 	nfs_access_add_cache(inode, &cache);
+out_cached:
+	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) != 0)
+		status = -EACCES;
 out:
-	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
-		return 0;
-	return -EACCES;
+	trace_nfs_access_exit(inode, status);
+	return status;
 }
 
 static int nfs_open_permission_mask(int openflags)
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 94e94bd..d6a9db0 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -37,6 +37,8 @@
 #include "iostat.h"
 #include "fscache.h"
 
+#include "nfstrace.h"
+
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
 static const struct vm_operations_struct nfs_file_vm_ops;
@@ -294,6 +296,8 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	int ret;
 	struct inode *inode = file_inode(file);
 
+	trace_nfs_fsync_enter(inode);
+
 	do {
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
@@ -310,6 +314,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		end = LLONG_MAX;
 	} while (ret == -EAGAIN);
 
+	trace_nfs_fsync_exit(inode, ret);
 	return ret;
 }
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9a98b04..4bcb00a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -51,6 +51,8 @@
 #include "nfs.h"
 #include "netns.h"
 
+#include "nfstrace.h"
+
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
 #define NFS_64_BIT_INODE_NUMBERS_ENABLED	1
@@ -503,6 +505,8 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	if ((attr->ia_valid & ~(ATTR_FILE|ATTR_OPEN)) == 0)
 		return 0;
 
+	trace_nfs_setattr_enter(inode);
+
 	/* Write all dirty data */
 	if (S_ISREG(inode->i_mode)) {
 		nfs_inode_dio_wait(inode);
@@ -522,6 +526,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 		error = nfs_refresh_inode(inode, fattr);
 	nfs_free_fattr(fattr);
 out:
+	trace_nfs_setattr_exit(inode, error);
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_setattr);
@@ -591,6 +596,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
 
+	trace_nfs_getattr_enter(inode);
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
 		nfs_inode_dio_wait(inode);
@@ -621,6 +627,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
 	}
 out:
+	trace_nfs_getattr_exit(inode, err);
 	return err;
 }
 EXPORT_SYMBOL_GPL(nfs_getattr);
@@ -875,6 +882,8 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
 		inode->i_sb->s_id, (long long)NFS_FILEID(inode));
 
+	trace_nfs_revalidate_inode_enter(inode);
+
 	if (is_bad_inode(inode))
 		goto out;
 	if (NFS_STALE(inode))
@@ -925,6 +934,7 @@ err_out:
 	nfs4_label_free(label);
 out:
 	nfs_free_fattr(fattr);
+	trace_nfs_revalidate_inode_exit(inode, status);
 	return status;
 }
 
@@ -975,6 +985,7 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 	spin_unlock(&inode->i_lock);
 	nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
 	nfs_fscache_wait_on_invalidate(inode);
+
 	dfprintk(PAGECACHE, "NFS: (%s/%Ld) data cache invalidated\n",
 			inode->i_sb->s_id, (long long)NFS_FILEID(inode));
 	return 0;
@@ -1008,8 +1019,12 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 		if (ret < 0)
 			goto out;
 	}
-	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
+	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
+		trace_nfs_invalidate_mapping_enter(inode);
 		ret = nfs_invalidate_mapping(inode, mapping);
+		trace_nfs_invalidate_mapping_exit(inode, ret);
+	}
+
 out:
 	return ret;
 }
@@ -1268,9 +1283,17 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
 
 static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
+	int ret;
+
+	trace_nfs_refresh_inode_enter(inode);
+
 	if (nfs_inode_attrs_need_update(inode, fattr))
-		return nfs_update_inode(inode, fattr);
-	return nfs_check_inode_attributes(inode, fattr);
+		ret = nfs_update_inode(inode, fattr);
+	else
+		ret = nfs_check_inode_attributes(inode, fattr);
+
+	trace_nfs_refresh_inode_exit(inode, ret);
+	return ret;
 }
 
 /**
diff --git a/fs/nfs/nfstrace.c b/fs/nfs/nfstrace.c
new file mode 100644
index 0000000..cc91461
--- /dev/null
+++ b/fs/nfs/nfstrace.c
@@ -0,0 +1,8 @@
+/*
+ * Copyright (c) 2013 Trond Myklebust <Trond.Myklebust@netapp.com>
+ */
+#include <linux/nfs_fs.h>
+#include "internal.h"
+
+#define CREATE_TRACE_POINTS
+#include "nfstrace.h"
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
new file mode 100644
index 0000000..73c8e1e
--- /dev/null
+++ b/fs/nfs/nfstrace.h
@@ -0,0 +1,166 @@
+/*
+ * Copyright (c) 2013 Trond Myklebust <Trond.Myklebust@netapp.com>
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM nfs
+
+#if !defined(_TRACE_NFS_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_NFS_H
+
+#include <linux/tracepoint.h>
+
+#define nfs_show_file_type(ftype) \
+	__print_symbolic(ftype, \
+			{ DT_UNKNOWN, "UNKNOWN" }, \
+			{ DT_FIFO, "FIFO" }, \
+			{ DT_CHR, "CHR" }, \
+			{ DT_DIR, "DIR" }, \
+			{ DT_BLK, "BLK" }, \
+			{ DT_REG, "REG" }, \
+			{ DT_LNK, "LNK" }, \
+			{ DT_SOCK, "SOCK" }, \
+			{ DT_WHT, "WHT" })
+
+#define nfs_show_cache_validity(v) \
+	__print_flags(v, "|", \
+			{ NFS_INO_INVALID_ATTR, "INVALID_ATTR" }, \
+			{ NFS_INO_INVALID_DATA, "INVALID_DATA" }, \
+			{ NFS_INO_INVALID_ATIME, "INVALID_ATIME" }, \
+			{ NFS_INO_INVALID_ACCESS, "INVALID_ACCESS" }, \
+			{ NFS_INO_INVALID_ACL, "INVALID_ACL" }, \
+			{ NFS_INO_REVAL_PAGECACHE, "REVAL_PAGECACHE" }, \
+			{ NFS_INO_REVAL_FORCED, "REVAL_FORCED" }, \
+			{ NFS_INO_INVALID_LABEL, "INVALID_LABEL" })
+
+#define nfs_show_nfsi_flags(v) \
+	__print_flags(v, "|", \
+			{ 1 << NFS_INO_ADVISE_RDPLUS, "ADVISE_RDPLUS" }, \
+			{ 1 << NFS_INO_STALE, "STALE" }, \
+			{ 1 << NFS_INO_FLUSHING, "FLUSHING" }, \
+			{ 1 << NFS_INO_FSCACHE, "FSCACHE" }, \
+			{ 1 << NFS_INO_COMMIT, "COMMIT" }, \
+			{ 1 << NFS_INO_LAYOUTCOMMIT, "NEED_LAYOUTCOMMIT" }, \
+			{ 1 << NFS_INO_LAYOUTCOMMITTING, "LAYOUTCOMMIT" })
+
+DECLARE_EVENT_CLASS(nfs_inode_event,
+		TP_PROTO(
+			const struct inode *inode
+		),
+
+		TP_ARGS(inode),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(u64, version)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+			__entry->version = inode->i_version;
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x version=%llu ",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			(unsigned long long)__entry->version
+		)
+);
+
+DECLARE_EVENT_CLASS(nfs_inode_event_done,
+		TP_PROTO(
+			const struct inode *inode,
+			int error
+		),
+
+		TP_ARGS(inode, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(unsigned char, type)
+			__field(u64, fileid)
+			__field(u64, version)
+			__field(loff_t, size)
+			__field(unsigned long, nfsi_flags)
+			__field(unsigned long, cache_validity)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+			__entry->error = error;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(&nfsi->fh);
+			__entry->type = nfs_umode_to_dtype(inode->i_mode);
+			__entry->version = inode->i_version;
+			__entry->size = i_size_read(inode);
+			__entry->nfsi_flags = nfsi->flags;
+			__entry->cache_validity = nfsi->cache_validity;
+		),
+
+		TP_printk(
+			"error=%d fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"type=%u (%s) version=%llu size=%lld "
+			"cache_validity=%lu (%s) nfs_flags=%ld (%s)",
+			__entry->error,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->type,
+			nfs_show_file_type(__entry->type),
+			(unsigned long long)__entry->version,
+			(long long)__entry->size,
+			__entry->cache_validity,
+			nfs_show_cache_validity(__entry->cache_validity),
+			__entry->nfsi_flags,
+			nfs_show_nfsi_flags(__entry->nfsi_flags)
+		)
+);
+
+#define DEFINE_NFS_INODE_EVENT(name) \
+	DEFINE_EVENT(nfs_inode_event, name, \
+			TP_PROTO( \
+				const struct inode *inode \
+			), \
+			TP_ARGS(inode))
+#define DEFINE_NFS_INODE_EVENT_DONE(name) \
+	DEFINE_EVENT(nfs_inode_event_done, name, \
+			TP_PROTO( \
+				const struct inode *inode, \
+				int error \
+			), \
+			TP_ARGS(inode, error))
+DEFINE_NFS_INODE_EVENT(nfs_refresh_inode_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_refresh_inode_exit);
+DEFINE_NFS_INODE_EVENT(nfs_revalidate_inode_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_revalidate_inode_exit);
+DEFINE_NFS_INODE_EVENT(nfs_invalidate_mapping_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_invalidate_mapping_exit);
+DEFINE_NFS_INODE_EVENT(nfs_getattr_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_getattr_exit);
+DEFINE_NFS_INODE_EVENT(nfs_setattr_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_setattr_exit);
+DEFINE_NFS_INODE_EVENT(nfs_writeback_page_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_writeback_page_exit);
+DEFINE_NFS_INODE_EVENT(nfs_writeback_inode_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_writeback_inode_exit);
+DEFINE_NFS_INODE_EVENT(nfs_fsync_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_fsync_exit);
+DEFINE_NFS_INODE_EVENT(nfs_access_enter);
+DEFINE_NFS_INODE_EVENT_DONE(nfs_access_exit);
+
+#endif /* _TRACE_NFS_H */
+
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH .
+#define TRACE_INCLUDE_FILE nfstrace
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f1bdb72..d37e8ca 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -31,6 +31,8 @@
 #include "fscache.h"
 #include "pnfs.h"
 
+#include "nfstrace.h"
+
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
 #define MIN_POOL_WRITE		(32)
@@ -1732,8 +1734,14 @@ int nfs_wb_all(struct inode *inode)
 		.range_start = 0,
 		.range_end = LLONG_MAX,
 	};
+	int ret;
+
+	trace_nfs_writeback_inode_enter(inode);
+
+	ret = sync_inode(inode, &wbc);
 
-	return sync_inode(inode, &wbc);
+	trace_nfs_writeback_inode_exit(inode, ret);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_wb_all);
 
@@ -1781,6 +1789,8 @@ int nfs_wb_page(struct inode *inode, struct page *page)
 	};
 	int ret;
 
+	trace_nfs_writeback_page_enter(inode);
+
 	for (;;) {
 		wait_on_page_writeback(page);
 		if (clear_page_dirty_for_io(page)) {
@@ -1789,14 +1799,15 @@ int nfs_wb_page(struct inode *inode, struct page *page)
 				goto out_error;
 			continue;
 		}
+		ret = 0;
 		if (!PagePrivate(page))
 			break;
 		ret = nfs_commit_inode(inode, FLUSH_SYNC);
 		if (ret < 0)
 			goto out_error;
 	}
-	return 0;
 out_error:
+	trace_nfs_writeback_page_exit(inode, ret);
 	return ret;
 }
 
-- 
1.8.3.1

