Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46950 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733Ab1K1UBj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 15:01:39 -0500
From: Jeff Layton <jlayton@redhat.com>
To: rjw@sisk.pl
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, tj@kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
Subject: [PATCH v3 1/2] sunrpc: make rpc_wait_bit_killable handle freeze events
Date: Mon, 28 Nov 2011 15:01:27 -0500
Message-Id: <1322510488-21189-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
References: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the freezer to skip wait_on_bit_killable sleeps in the sunrpc
layer. This should allow suspend and hibernate events to proceed, even
when there are RPC's pending on the wire.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/freezer.h |   21 +++++++++++++++++++++
 net/sunrpc/sched.c      |    3 ++-
 2 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index a5386e3..fda3ac6 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -135,6 +135,25 @@ static inline void set_freezable_with_signal(void)
 }
 
 /*
+ * These macros are intended to be used whenever you want allow a task that's
+ * sleeping in TASK_UNINTERRUPTIBLE or TASK_KILLABLE state to be frozen.
+ *
+ */
+
+/*
+ * Like schedule(), but should not block the freezer. It may return immediately
+ * if it ends up racing with the freezer. Callers must be able to deal with
+ * spurious wakeups.
+ */
+#define freezable_schedule()						\
+({									\
+	freezer_do_not_count();						\
+	if (!try_to_freeze())						\
+		schedule();						\
+	freezer_count();						\
+})
+
+/*
  * Freezer-friendly wrappers around wait_event_interruptible(),
  * wait_event_killable() and wait_event_interruptible_timeout(), originally
  * defined in <linux/wait.h>
@@ -194,6 +213,8 @@ static inline int freezer_should_skip(struct task_struct *p) { return 0; }
 static inline void set_freezable(void) {}
 static inline void set_freezable_with_signal(void) {}
 
+#define freezable_schedule()  schedule()
+
 #define wait_event_freezable(wq, condition)				\
 		wait_event_interruptible(wq, condition)
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index d12ffa5..5317b93 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -18,6 +18,7 @@
 #include <linux/smp.h>
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
+#include <linux/freezer.h>
 
 #include <linux/sunrpc/clnt.h>
 
@@ -231,7 +232,7 @@ static int rpc_wait_bit_killable(void *word)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
-	schedule();
+	freezable_schedule();
 	return 0;
 }
 
-- 
1.7.6.4

