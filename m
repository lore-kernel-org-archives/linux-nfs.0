Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f201.google.com ([209.85.161.201]:38013 "EHLO
	mail-gg0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757771Ab3EFX5j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:57:39 -0400
Received: by mail-gg0-f201.google.com with SMTP id k25so425605ggl.0
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:57:38 -0700 (PDT)
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
Subject: [PATCH v3 11/16] epoll: use freezable blocking call
Date: Mon,  6 May 2013 16:50:16 -0700
Message-Id: <1367884221-20462-12-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid waking up every thread sleeping in an epoll_wait call during
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
 fs/eventpoll.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 9fec183..65245e7 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -34,6 +34,7 @@
 #include <linux/mutex.h>
 #include <linux/anon_inodes.h>
 #include <linux/device.h>
+#include <linux/freezer.h>
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/mman.h>
@@ -1543,7 +1544,8 @@ fetch_events:
 			}
 
 			spin_unlock_irqrestore(&ep->lock, flags);
-			if (!schedule_hrtimeout_range(to, slack, HRTIMER_MODE_ABS))
+			if (!freezable_schedule_hrtimeout_range(to, slack,
+								HRTIMER_MODE_ABS))
 				timed_out = 1;
 
 			spin_lock_irqsave(&ep->lock, flags);
-- 
1.8.2.1

