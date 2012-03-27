Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59386 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395Ab2C0CHY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 22:07:24 -0400
Message-ID: <4F7120B6.2090509@panasas.com>
Date: Mon, 26 Mar 2012 19:06:46 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        <linux-security-module@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>,
        Thomas Gleixner <tglx@linutronix.de>
CC: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>
Subject: [PATCH 4/6 OPTION-A] completion: Add new wait_for_completion_timeout_state
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
In-Reply-To: <4F711EA2.4030608@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


There are sometime places where an API hides a completion
inside it's implementation, and needs to expose the kind of
wait it does to it's upper users. Instead of such cases that
now need an ugly switch case to call the different
wait_for_completion_xxx function define a generic one
which can do all.

A new user will be added to this API in linux/kmod.h.

The return value from this member is a more Linux Kernel natural.
It will return:
	0  - If the wait was actually completed by a complete() signal.
	-ERESTARTSYS - If interrupted
	-ETIMEDOUT - If timeout expired

CC: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/completion.h |    2 +
 kernel/sched/core.c        |   56 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/include/linux/completion.h b/include/linux/completion.h
index 51494e6..c41b836 100644
--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -85,6 +85,8 @@ extern long wait_for_completion_interruptible_timeout(
 	struct completion *x, unsigned long timeout);
 extern long wait_for_completion_killable_timeout(
 	struct completion *x, unsigned long timeout);
+extern int wait_for_completion_timeout_state(
+	struct completion *x, unsigned long timeout, int state);
 extern bool try_wait_for_completion(struct completion *x);
 extern bool completion_done(struct completion *x);
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 503d642..023ba27 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3664,6 +3664,62 @@ int __sched wait_for_completion_killable(struct completion *x)
 EXPORT_SYMBOL(wait_for_completion_killable_timeout);
 
 /**
+ * wait_for_completion_timeout_state: - waits for completion of a task all modes
+ * @x:  holds the state of this particular completion
+ * @timeout:  timeout value in jiffies
+ * @state: Can be either 0 or TASK_KILLABLE or TASK_INTERRUPTIBLE
+ *
+ * This waits for either a completion of a specific task to be
+ * signaled or for a specified timeout to expire.
+ * If @state == TASK_KILLABLE It can be interrupted by a kill signal only.
+ * If @state == TASK_INTERRUPTIBLE It can be interrupted by any signal.
+ *
+ * This is a Swiss-army-knife of all the above, for API's that needs to hide
+ * a completion, and needs to expose it's control to users.
+ *
+ * The return value is:
+ *	0 means completion was signaled with a complete call.
+ *	-ERESTARTSYS if interrupted
+ *	-ETIMEDOUT if timeout expired
+ *  Be careful the return value is Boolean opposite to the above _timeout
+ *  members.
+ */
+int __sched
+wait_for_completion_timeout_state(struct completion *x,
+				  unsigned long timeout, int state)
+{
+	long t;
+	int ret;
+
+	if (!timeout)
+		timeout = MAX_SCHEDULE_TIMEOUT;
+
+	switch(state) {
+	default:
+		WARN_ON_ONCE(1);
+		/* fall through */
+	case 0:
+		state = TASK_UNINTERRUPTIBLE;
+		break;
+	case TASK_KILLABLE:
+	case TASK_INTERRUPTIBLE:
+		break;
+	}
+
+	t = wait_for_common(x, timeout, state);
+	if (likely(t > 0)) {
+		ret = 0;
+	} else  {
+		if (t < 0)
+			ret = t;
+		else
+			ret = -ETIMEDOUT;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(wait_for_completion_timeout_state);
+
+/**
  *	try_wait_for_completion - try to decrement a completion without blocking
  *	@x:	completion structure
  *
-- 
1.7.6.5


