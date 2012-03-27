Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59419 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757075Ab2C0CJ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 22:09:58 -0400
Message-ID: <4F712153.5020205@panasas.com>
Date: Mon, 26 Mar 2012 19:09:23 -0700
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
Subject: [PATCH 4/6 option-B] kmod: add new wait_for_completion_timeout_state()
 helper
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
In-Reply-To: <4F711EA2.4030608@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch is if the more desirable patch is not accepted:

    completion: Add new wait_for_completion_timeout_state

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

It can be seen that done here is more complicated/ugly then if
done at kernel/sched/core.c

Note that at this stage there is a warning:
kernel/kmod.c:473:1: warning: 'wait_for_completion_timeout_state' defined but not used [-Wunused-function]

Until the next patch. I keep it separate for the different options
to be taken

CC: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 kernel/kmod.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/kernel/kmod.c b/kernel/kmod.c
index 309299a..b404f99 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -466,6 +466,46 @@ void call_usermodehelper_setfns(struct subprocess_info *info,
 	info->data = data;
 }
 
+/* Used by call_usermodehelper_exec below should be considered for
+ * kernel/sched/core.c
+ */
+static int
+wait_for_completion_timeout_state(struct completion *x,
+				  unsigned long timeout, int state)
+{
+	long t;
+	int ret;
+
+	if (!timeout)
+		timeout = MAX_SCHEDULE_TIMEOUT;
+
+	switch (state) {
+	default:
+		WARN_ON_ONCE(1);
+		/* fall through */
+	case 0:
+		wait_for_completion(x);
+		t = 1;
+		break;
+	case TASK_KILLABLE:
+		t = wait_for_completion_killable_timeout(x, timeout);
+		break;
+	case TASK_INTERRUPTIBLE:
+		t = wait_for_completion_interruptible_timeout(x, timeout);
+		break;
+	}
+
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
+
 /**
  * call_usermodehelper_exec - start a usermode application
  * @sub_info: information about the subprocessa
-- 
1.7.6.5


