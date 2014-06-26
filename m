Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:53168 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaFZTP1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:27 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so3141188qab.20
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:26 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: [PATCH v2 074/117] lockdep: add lockdep_assert_not_held
Date: Thu, 26 Jun 2014 15:12:54 -0400
Message-Id: <1403810017-16062-75-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently have the ability to call lockdep_assert_held to throw a
warning when a spinlock isn't held in a codepath. There are also times
when we'd like to throw a warning when a lock is held (i.e. when there
is the potential for deadlock with atomic_dec_and_lock or similar).

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/lockdep.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 008388f920d7..1e5f1d544029 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -362,6 +362,8 @@ extern void lockdep_trace_alloc(gfp_t mask);
 		WARN_ON(debug_locks && !lockdep_is_held(l));	\
 	} while (0)
 
+#define lockdep_assert_not_held(l) WARN_ON(debug_locks && lockdep_is_held(l))
+
 #define lockdep_recursing(tsk)	((tsk)->lockdep_recursion)
 
 #else /* !CONFIG_LOCKDEP */
@@ -413,6 +415,8 @@ struct lock_class_key { };
 
 #define lockdep_assert_held(l)			do { (void)(l); } while (0)
 
+#define lockdep_assert_not_held(l)		(void)(l)
+
 #define lockdep_recursing(tsk)			(0)
 
 #endif /* !LOCKDEP */
-- 
1.9.3

