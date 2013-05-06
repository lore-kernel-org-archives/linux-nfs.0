Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f74.google.com ([209.85.212.74]:48624 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465Ab3EFXuc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:50:32 -0400
Received: by mail-vb0-f74.google.com with SMTP id q16so447330vbe.1
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
        Tejun Heo <tj@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        =?UTF-8?q?Arve=20Hj=C3=B8nnev=C3=A5g?= <arve@android.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Sachin Kamat <sachin.kamat@linaro.org>, devel@driverdev.osuosl.org
Subject: [PATCH v3 10/16] binder: use freezable blocking calls
Date: Mon,  6 May 2013 16:50:15 -0700
Message-Id: <1367884221-20462-11-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid waking up every thread sleeping in a binder call during
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
 drivers/staging/android/binder.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/android/binder.c b/drivers/staging/android/binder.c
index 24456a0..af8fba4 100644
--- a/drivers/staging/android/binder.c
+++ b/drivers/staging/android/binder.c
@@ -20,6 +20,7 @@
 #include <asm/cacheflush.h>
 #include <linux/fdtable.h>
 #include <linux/file.h>
+#include <linux/freezer.h>
 #include <linux/fs.h>
 #include <linux/list.h>
 #include <linux/miscdevice.h>
@@ -2140,13 +2141,13 @@ retry:
 			if (!binder_has_proc_work(proc, thread))
 				ret = -EAGAIN;
 		} else
-			ret = wait_event_interruptible_exclusive(proc->wait, binder_has_proc_work(proc, thread));
+			ret = wait_event_freezable_exclusive(proc->wait, binder_has_proc_work(proc, thread));
 	} else {
 		if (non_block) {
 			if (!binder_has_thread_work(thread))
 				ret = -EAGAIN;
 		} else
-			ret = wait_event_interruptible(thread->wait, binder_has_thread_work(thread));
+			ret = wait_event_freezable(thread->wait, binder_has_thread_work(thread));
 	}
 
 	binder_lock(__func__);
-- 
1.8.2.1

