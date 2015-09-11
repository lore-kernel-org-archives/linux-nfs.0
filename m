Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:36722 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbbIKKyy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 06:54:54 -0400
Received: by ykdt18 with SMTP id t18so66771680ykd.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 03:54:53 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v4 01/16] locks: change tracepoint for generic_add_lease
Date: Fri, 11 Sep 2015 06:54:27 -0400
Message-Id: <1441968882-7851-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
References: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...add some more helpful info.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/trace/events/filelock.h | 38 +++++++++++++++++++++++++++++++++++---
 1 file changed, 35 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
index a0d008070962..c72f2dc01d0b 100644
--- a/include/trace/events/filelock.h
+++ b/include/trace/events/filelock.h
@@ -81,15 +81,47 @@ DEFINE_EVENT(filelock_lease, break_lease_block, TP_PROTO(struct inode *inode, st
 DEFINE_EVENT(filelock_lease, break_lease_unblock, TP_PROTO(struct inode *inode, struct file_lock *fl),
 		TP_ARGS(inode, fl));
 
-DEFINE_EVENT(filelock_lease, generic_add_lease, TP_PROTO(struct inode *inode, struct file_lock *fl),
-		TP_ARGS(inode, fl));
-
 DEFINE_EVENT(filelock_lease, generic_delete_lease, TP_PROTO(struct inode *inode, struct file_lock *fl),
 		TP_ARGS(inode, fl));
 
 DEFINE_EVENT(filelock_lease, time_out_leases, TP_PROTO(struct inode *inode, struct file_lock *fl),
 		TP_ARGS(inode, fl));
 
+TRACE_EVENT(generic_add_lease,
+	TP_PROTO(struct inode *inode, struct file_lock *fl),
+
+	TP_ARGS(inode, fl),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, i_ino)
+		__field(int, wcount)
+		__field(int, dcount)
+		__field(int, icount)
+		__field(dev_t, s_dev)
+		__field(fl_owner_t, fl_owner)
+		__field(unsigned int, fl_flags)
+		__field(unsigned char, fl_type)
+	),
+
+	TP_fast_assign(
+		__entry->s_dev = inode->i_sb->s_dev;
+		__entry->i_ino = inode->i_ino;
+		__entry->wcount = atomic_read(&inode->i_writecount);
+		__entry->dcount = d_count(fl->fl_file->f_path.dentry);
+		__entry->icount = atomic_read(&inode->i_count);
+		__entry->fl_owner = fl ? fl->fl_owner : NULL;
+		__entry->fl_flags = fl ? fl->fl_flags : 0;
+		__entry->fl_type = fl ? fl->fl_type : 0;
+	),
+
+	TP_printk("dev=0x%x:0x%x ino=0x%lx wcount=%d dcount=%d icount=%d fl_owner=0x%p fl_flags=%s fl_type=%s",
+		MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
+		__entry->i_ino, __entry->wcount, __entry->dcount,
+		__entry->icount, __entry->fl_owner,
+		show_fl_flags(__entry->fl_flags),
+		show_fl_type(__entry->fl_type))
+);
+
 #endif /* _TRACE_FILELOCK_H */
 
 /* This part must be outside protection */
-- 
2.4.3

