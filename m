Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f202.google.com ([209.85.213.202]:54956 "EHLO
	mail-ye0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758750Ab3EFX6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:58:30 -0400
Received: by mail-ye0-f202.google.com with SMTP id r13so448554yen.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:58:30 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Colin Cross <ccross@android.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Darren Hart <dvhart@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Randy Dunlap <rdunlap@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v3 13/16] futex: use freezable blocking call
Date: Mon,  6 May 2013 16:50:18 -0700
Message-Id: <1367884221-20462-14-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid waking up every thread sleeping in a futex_wait call during
suspend and resume by calling a freezable blocking call.  Previous
patches modified the freezer to avoid sending wakeups to threads
that are blocked in freezable blocking calls.

This call was selected to be converted to a freezable call because
it doesn't hold any locks or release any resources when interrupted
that might be needed by another freezing task or a kernel driver
during suspend, and is a common site where idle userspace tasks are
blocked.

Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Darren Hart <dvhart@linux.intel.com>
Signed-off-by: Colin Cross <ccross@android.com>
---
 kernel/futex.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/futex.c b/kernel/futex.c
index b26dcfc..d710fae 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -61,6 +61,7 @@
 #include <linux/nsproxy.h>
 #include <linux/ptrace.h>
 #include <linux/sched/rt.h>
+#include <linux/freezer.h>
 
 #include <asm/futex.h>
 
@@ -1807,7 +1808,7 @@ static void futex_wait_queue_me(struct futex_hash_bucket *hb, struct futex_q *q,
 		 * is no timeout, or if it has yet to expire.
 		 */
 		if (!timeout || timeout->task)
-			schedule();
+			freezable_schedule();
 	}
 	__set_current_state(TASK_RUNNING);
 }
-- 
1.8.2.1

