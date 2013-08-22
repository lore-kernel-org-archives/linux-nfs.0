Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:63017 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063Ab3HVAYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 05/21] NFS: Add tracepoints for debugging generic file create events
Date: Wed, 21 Aug 2013 20:24:03 -0400
Message-ID: <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c      |  2 ++
 fs/nfs/nfstrace.h | 70 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2263a6b..9c07812 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1612,7 +1612,9 @@ int nfs_create(struct inode *dir, struct dentry *dentry,
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
+	trace_nfs_create_enter(dir, dentry, open_flags);
 	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags);
+	trace_nfs_create_exit(dir, dentry, open_flags, error);
 	if (error != 0)
 		goto out_err;
 	return 0;
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index fba194b..2963a05 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -352,6 +352,76 @@ TRACE_EVENT(nfs_atomic_open_exit,
 		)
 );
 
+TRACE_EVENT(nfs_create_enter,
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
+			show_open_flags(__entry->flags),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+TRACE_EVENT(nfs_create_exit,
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
+			__entry->error = error;
+			__entry->dev = dir->i_sb->s_dev;
+			__entry->dir = NFS_FILEID(dir);
+			__entry->flags = flags;
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk(
+			"error=%d flags=%u (%s) name=%02x:%02x:%llu/%s",
+			__entry->error,
+			__entry->flags,
+			show_open_flags(__entry->flags),
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

