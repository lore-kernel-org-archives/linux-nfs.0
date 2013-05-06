Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f74.google.com ([209.85.128.74]:59680 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932494Ab3EFXuc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:50:32 -0400
Received: by mail-qe0-f74.google.com with SMTP id 1so447754qec.5
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:50:31 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Colin Cross <ccross@android.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v3 12/16] select: use freezable blocking call
Date: Mon,  6 May 2013 16:50:17 -0700
Message-Id: <1367884221-20462-13-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid waking up every thread sleeping in a select call during
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
 fs/select.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/select.c b/fs/select.c
index 8c1c96c..6b14dc7 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -27,6 +27,7 @@
 #include <linux/rcupdate.h>
 #include <linux/hrtimer.h>
 #include <linux/sched/rt.h>
+#include <linux/freezer.h>
 
 #include <asm/uaccess.h>
 
@@ -236,7 +237,8 @@ int poll_schedule_timeout(struct poll_wqueues *pwq, int state,
 
 	set_current_state(state);
 	if (!pwq->triggered)
-		rc = schedule_hrtimeout_range(expires, slack, HRTIMER_MODE_ABS);
+		rc = freezable_schedule_hrtimeout_range(expires, slack,
+							HRTIMER_MODE_ABS);
 	__set_current_state(TASK_RUNNING);
 
 	/*
-- 
1.8.2.1

