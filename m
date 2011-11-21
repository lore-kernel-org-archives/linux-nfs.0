Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35515 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753573Ab1KURka (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 12:40:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: rjw@sisk.pl
Cc: linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, john@calva.com,
        tj@kernel.org, trond.myklebust@netapp.com
Subject: [PATCH 1/2] sunrpc: make rpc_wait_bit_killable handle freeze events
Date: Mon, 21 Nov 2011 12:40:20 -0500
Message-Id: <1321897221-2278-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
References: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the freezer to skip wait_on_bit_killable sleeps in the sunrpc
layer. This should allow suspend and hibernate events to proceed, even
when there are RPC's pending on the wire.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/freezer.h |   12 ++++++++++++
 net/sunrpc/sched.c      |    3 ++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index a5386e3..8b60dd0 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -135,6 +135,16 @@ static inline void set_freezable_with_signal(void)
 }
 
 /*
+ * Freezer-friendly macro around schedule() in the kernel.
+ */
+#define freezable_schedule()						\
+({									\
+	freezer_do_not_count();						\
+	schedule();							\
+	freezer_count();						\
+})
+
+/*
  * Freezer-friendly wrappers around wait_event_interruptible(),
  * wait_event_killable() and wait_event_interruptible_timeout(), originally
  * defined in <linux/wait.h>
@@ -194,6 +204,8 @@ static inline int freezer_should_skip(struct task_struct *p) { return 0; }
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

