Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f74.google.com ([209.85.212.74]:53901 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932390Ab3EFXua (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:50:30 -0400
Received: by mail-vb0-f74.google.com with SMTP id q16so447327vbe.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:50:27 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Colin Cross <ccross@android.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>
Subject: [PATCH v3 06/16] freezer: skip waking up tasks with PF_FREEZER_SKIP set
Date: Mon,  6 May 2013 16:50:11 -0700
Message-Id: <1367884221-20462-7-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Android goes through suspend/resume very often (every few seconds when
on a busy wifi network with the screen off), and a significant portion
of the energy used to go in and out of suspend is spent in the
freezer.  If a task has called freezer_do_not_count(), don't bother
waking it up.  If it happens to wake up later it will call
freezer_count() and immediately enter the refrigerator.

Combined with patches to convert freezable helpers to use
freezer_do_not_count() and convert common sites where idle userspace
tasks are blocked to use the freezable helpers, this reduces the
time and energy required to suspend and resume.

Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Pavel Machek <pavel@ucw.cz>
Signed-off-by: Colin Cross <ccross@android.com>
---
v2:  move check to freeze_task()

 kernel/freezer.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/kernel/freezer.c b/kernel/freezer.c
index c38893b..8b2afc1 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -110,6 +110,18 @@ bool freeze_task(struct task_struct *p)
 {
 	unsigned long flags;
 
+	/*
+	 * This check can race with freezer_do_not_count, but worst case that
+	 * will result in an extra wakeup being sent to the task.  It does not
+	 * race with freezer_count(), the barriers in freezer_count() and
+	 * freezer_should_skip() ensure that either freezer_count() sees
+	 * freezing == true in try_to_freeze() and freezes, or
+	 * freezer_should_skip() sees !PF_FREEZE_SKIP and freezes the task
+	 * normally.
+	 */
+	if (freezer_should_skip(p))
+		return false;
+
 	spin_lock_irqsave(&freezer_lock, flags);
 	if (!freezing(p) || frozen(p)) {
 		spin_unlock_irqrestore(&freezer_lock, flags);
-- 
1.8.2.1

