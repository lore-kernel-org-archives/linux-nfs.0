Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f74.google.com ([209.85.128.74]:45466 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323Ab3EFXu2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:50:28 -0400
Received: by mail-qe0-f74.google.com with SMTP id 1so447689qec.1
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
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>,
        Len Brown <len.brown@intel.com>
Subject: [PATCH v3 04/16] lockdep: check that no locks held at freeze time
Date: Mon,  6 May 2013 16:50:09 -0700
Message-Id: <1367884221-20462-5-git-send-email-ccross@android.com>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mandeep Singh Baines <msb@chromium.org>

We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
deadlock if the lock is later acquired in the suspend or hibernate path
(e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
cgroup_freezer if a lock is held inside a frozen cgroup that is later
acquired by a process outside that group.

History:
This patch was originally applied as 6aa9707099c and reverted in
dbf520a9d7d4 because NFS was freezing with locks held.  It was
deemed better to keep the bad freeze point in NFS to allow laptops
to suspend consistently.  The previous patch in this series converts
NFS to call _unsafe versions of the freezable helpers so that
lockdep doesn't complain about them until a more correct fix
can be applied.

[akpm@linux-foundation.org: export debug_check_no_locks_held]
Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
Cc: Ben Chan <benchan@chromium.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Ingo Molnar <mingo@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
[ccross@android.com: don't warn if try_to_freeze_unsafe is called]
Signed-off-by: Colin Cross <ccross@android.com>
---
 include/linux/freezer.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index d3c038e..bcf9e65 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -3,6 +3,7 @@
 #ifndef FREEZER_H_INCLUDED
 #define FREEZER_H_INCLUDED
 
+#include <linux/debug_locks.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
 #include <linux/atomic.h>
@@ -60,6 +61,8 @@ static inline bool try_to_freeze_unsafe(void)
 
 static inline bool try_to_freeze(void)
 {
+	if (!(current->flags & PF_NOFREEZE))
+		debug_check_no_locks_held();
 	return try_to_freeze_unsafe();
 }
 
-- 
1.8.2.1

