Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58245 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933054AbbFEPB4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2015 11:01:56 -0400
From: Petr Mladek <pmladek@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>
Cc: Richard Weinberger <richard@nod.at>, Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
        Petr Mladek <pmladek@suse.cz>
Subject: [RFC PATCH 05/18] freezer/scheduler: Add freezable_cond_resched()
Date: Fri,  5 Jun 2015 17:01:04 +0200
Message-Id: <1433516477-5153-6-git-send-email-pmladek@suse.cz>
In-Reply-To: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It makes sense to call cond_resched() in freezable kthreads.
But there is the chicken&egg problem whether to call try_to_freeze()
before or after the schedule.

This patch adds freezable_cond_resched(). It uses the same trick as
freezable_schedule(). It tells the freezer that it might ignore
the sleeping process.

Note that it might be used only on locations where the freezing
is safe. It means that no lock is taken and we are ready to sleep
for a very long time.

Signed-off-by: Petr Mladek <pmladek@suse.cz>
---
 include/linux/freezer.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 6b7fd9cf5ea2..1446f210dfc6 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -172,6 +172,14 @@ static inline void freezable_schedule(void)
 	freezer_count();
 }
 
+/* Like cond_resched(), but should not block the freezer. */
+static inline void freezable_cond_resched(void)
+{
+	freezer_do_not_count();
+	cond_resched();
+	freezer_count();
+}
+
 /* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
 static inline void freezable_schedule_unsafe(void)
 {
-- 
1.8.5.6

