Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:10024 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740Ab3HVAY0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:26 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 08/21] NFS: Add tracepoints for debugging NFS hard links
Date: Wed, 21 Aug 2013 20:24:06 -0400
Message-ID: <1377131059-40121-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-8-git-send-email-Trond.Myklebust@netapp.com>
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
index dca7deb..4ce7f76 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1860,6 +1860,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry->d_parent->d_name.name, old_dentry->d_name.name,
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
+	trace_nfs_link_enter(inode, dir, dentry);
 	NFS_PROTO(inode)->return_delegation(inode);
 
 	d_drop(dentry);
@@ -1868,6 +1869,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		ihold(inode);
 		d_add(dentry, inode);
 	}
+	trace_nfs_link_exit(inode, dir, dentry, error);
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_link);
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index a20f0d1..89fe741 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -512,6 +512,76 @@ DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_unlink_exit);
 DEFINE_NFS_DIRECTORY_EVENT(nfs_symlink_enter);
 DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_symlink_exit);
 
+TRACE_EVENT(nfs_link_enter,
+		TP_PROTO(
+			const struct inode *inode,
+			const struct inode *dir,
+			const struct dentry *dentry
+		),
+
+		TP_ARGS(inode, dir, dentry),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u64, fileid)
+			__field(u64, dir)
+			__string(name, dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->dir = NFS_FILEID(dir);
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu name=%02x:%02x:%llu/%s",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			__entry->fileid,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
+TRACE_EVENT(nfs_link_exit,
+		TP_PROTO(
+			const struct inode *inode,
+			const struct inode *dir,
+			const struct dentry *dentry,
+			int error
+		),
+
+		TP_ARGS(inode, dir, dentry, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(dev_t, dev)
+			__field(u64, fileid)
+			__field(u64, dir)
+			__string(name, dentry->d_name.name)
+		),
+
+		TP_fast_assign(
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->dir = NFS_FILEID(dir);
+			__entry->error = error;
+			__assign_str(name, dentry->d_name.name);
+		),
+
+		TP_printk(
+			"error=%d fileid=%02x:%02x:%llu name=%02x:%02x:%llu/%s",
+			__entry->error,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			__entry->fileid,
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->dir,
+			__get_str(name)
+		)
+);
+
 DECLARE_EVENT_CLASS(nfs_rename_event,
 		TP_PROTO(
 			const struct inode *old_dir,
-- 
1.8.3.1

