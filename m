Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144AbcGAXo6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 19:44:58 -0400
From: Daniel Bristot de Oliveira <bristot@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] tracing: Use __get_str() when manipulating strings
Date: Fri,  1 Jul 2016 20:44:36 -0300
Message-Id: <ea260df91817411cca2a1f3db2abd88860094788.1467407618.git.bristot@redhat.com>
In-Reply-To: <cover.1467407618.git.bristot@redhat.com>
References: <cover.1467407618.git.bristot@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use __get_str(str) rather than __get_dynamic_array(str) when
deadling with strings.

It is just a code cleanup, no changes on tracepoint ABI.

Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Daniel Bristot de Oliveira <bristot@redhat.com>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

---
 fs/nfs/nfs4trace.h            | 4 ++--
 fs/nfs/nfstrace.h             | 4 ++--
 include/trace/events/printk.h | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 2c8d05d..adec59a 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1235,8 +1235,8 @@ DECLARE_EVENT_CLASS(nfs4_idmap_event,
 				len = 0;
 			__entry->error = error < 0 ? error : 0;
 			__entry->id = id;
-			memcpy(__get_dynamic_array(name), name, len);
-			((char *)__get_dynamic_array(name))[len] = 0;
+			memcpy(__get_str(name), name, len);
+			__get_str(name)[len] = 0;
 		),
 
 		TP_printk(
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 9f80a08..32ff934 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -707,9 +707,9 @@ TRACE_EVENT(nfs_sillyrename_unlink,
 			__entry->dev = dir->i_sb->s_dev;
 			__entry->dir = NFS_FILEID(dir);
 			__entry->error = error;
-			memcpy(__get_dynamic_array(name),
+			memcpy(__get_str(name),
 				data->args.name.name, len);
-			((char *)__get_dynamic_array(name))[len] = 0;
+			__get_str(name)[len] = 0;
 		),
 
 		TP_printk(
diff --git a/include/trace/events/printk.h b/include/trace/events/printk.h
index c008bc9..542a755 100644
--- a/include/trace/events/printk.h
+++ b/include/trace/events/printk.h
@@ -16,8 +16,8 @@ TRACE_EVENT(console,
 	),
 
 	TP_fast_assign(
-		memcpy(__get_dynamic_array(msg), text, len);
-		((char *)__get_dynamic_array(msg))[len] = 0;
+		memcpy(__get_str(msg), text, len);
+		__get_str(msg)[len] = 0;
 	),
 
 	TP_printk("%s", __get_str(msg))
-- 
2.7.4

