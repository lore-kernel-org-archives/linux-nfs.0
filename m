Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:41909 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083AbaFSOw3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:29 -0400
Received: by mail-qg0-f53.google.com with SMTP id i50so2170495qgf.40
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:28 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 062/104] lockdep: add lockdep_assert_not_held
Date: Thu, 19 Jun 2014 10:50:08 -0400
Message-Id: <1403189450-18729-63-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently have the ability to call lockdep_assert_held to throw a
warning when a spinlock isn't held in a codepath. There are also times
when we'd like to throw a warning when a lock is held (i.e. when there
is the potential for deadlock).

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/lockdep.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 008388f920d7..ab0cc8e224ee 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -362,6 +362,10 @@ extern void lockdep_trace_alloc(gfp_t mask);
 		WARN_ON(debug_locks && !lockdep_is_held(l));	\
 	} while (0)
 
+#define lockdep_assert_not_held(l)	do {				\
+		WARN_ON(debug_locks && lockdep_is_held(l));	\
+	} while (0)
+
 #define lockdep_recursing(tsk)	((tsk)->lockdep_recursion)
 
 #else /* !CONFIG_LOCKDEP */
@@ -413,6 +417,8 @@ struct lock_class_key { };
 
 #define lockdep_assert_held(l)			do { (void)(l); } while (0)
 
+#define lockdep_assert_not_held(l)		do { (void)(l); } while (0)
+
 #define lockdep_recursing(tsk)			(0)
 
 #endif /* !LOCKDEP */
-- 
1.9.3

