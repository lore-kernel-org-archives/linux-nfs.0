Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:60760 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbcGPHQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Jul 2016 03:16:51 -0400
Message-Id: <20160716071647.654172487@goodmis.org>
Date: Sat, 16 Jul 2016 03:16:23 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Ingo Molnar <mingo@redhat.com>, <linux-nfs@vger.kernel.org>,
        Daniel Bristot de Oliveira <bristot@redhat.com>
Subject: [for-next][PATCH 6/7] tracing: Use __get_str() when manipulating strings
References: <20160716071617.711980454@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Daniel Bristot de Oliveira <bristot@redhat.com>

Use __get_str(str) rather than __get_dynamic_array(str) when
deadling with strings.

It is just a code cleanup, no changes on tracepoint ABI.

Link: http://lkml.kernel.org/r/ea260df91817411cca2a1f3db2abd88860094788.1467407618.git.bristot@redhat.com

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-nfs@vger.kernel.org
Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Daniel Bristot de Oliveira <bristot@redhat.com>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 fs/nfs/nfs4trace.h            | 4 ++--
 fs/nfs/nfstrace.h             | 4 ++--
 include/trace/events/printk.h | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 9c150b153782..cfb8f7ce5cf6 100644
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
index 0b9e5cc9a747..31c7763b94d5 100644
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
index c008bc99f9fa..542a7558154a 100644
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
2.8.1


