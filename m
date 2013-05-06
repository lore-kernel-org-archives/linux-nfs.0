Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f202.google.com ([209.85.220.202]:35683 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932558Ab3EFXug (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:50:36 -0400
Received: by mail-vc0-f202.google.com with SMTP id gf12so447585vcb.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:50:35 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Colin Cross <ccross@android.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 15/16] sigtimedwait: use freezable blocking call
Date: Mon,  6 May 2013 16:50:20 -0700
Message-Id: <1367884221-20462-16-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid waking up every thread sleeping in a sigtimedwait call during
suspend and resume by calling a freezable blocking call.  Previous
patches modified the freezer to avoid sending wakeups to threads
that are blocked in freezable blocking calls.

This call was selected to be converted to a freezable call because
it doesn't hold any locks or release any resources when interrupted
that might be needed by another freezing task or a kernel driver
during suspend, and is a common site where idle userspace tasks are
blocked.

Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Colin Cross <ccross@android.com>
---
 kernel/signal.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 598dc06..10a70a0 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2845,7 +2845,7 @@ int do_sigtimedwait(const sigset_t *which, siginfo_t *info,
 		recalc_sigpending();
 		spin_unlock_irq(&tsk->sighand->siglock);
 
-		timeout = schedule_timeout_interruptible(timeout);
+		timeout = freezable_schedule_timeout_interruptible(timeout);
 
 		spin_lock_irq(&tsk->sighand->siglock);
 		__set_task_blocked(tsk, &tsk->real_blocked);
-- 
1.8.2.1

