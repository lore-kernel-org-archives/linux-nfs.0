Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59576 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab2C0CQE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 22:16:04 -0400
Message-ID: <4F7122C0.2070800@panasas.com>
Date: Mon, 26 Mar 2012 19:15:28 -0700
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
Subject: [PATCH 6/6] kmod: optional: Convert the use of xchg to a kref
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
In-Reply-To: <4F711EA2.4030608@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


if we use a kref instead of xchg to govern the lifetime
of struct subprocess_info, the code becomes simpler and
more generic. We can avoid some of the special cases.

Actually I like the xchg use here. But if it will break
some ARCHs that do not like xchg, then here is the work
needed.

No functional change

CC: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/kmod.h |    4 +++-
 kernel/kmod.c        |   43 +++++++++++++++++--------------------------
 2 files changed, 20 insertions(+), 27 deletions(-)

diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index 4d9f202..bd0c3c9 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -25,6 +25,7 @@
 #include <linux/compiler.h>
 #include <linux/workqueue.h>
 #include <linux/sysctl.h>
+#include <linux/kref.h>
 
 #define KMOD_PATH_LEN 256
 
@@ -54,8 +55,9 @@ extern __printf(2, 3)
 #define UMH_KILLABLE	4	/* wait for EXEC/PROC killable */
 
 struct subprocess_info {
+	struct kref kref;
 	struct work_struct work;
-	struct completion *complete;
+	struct completion complete;
 	char *path;
 	char **argv;
 	char **envp;
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 588cb6f..948a674 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -221,9 +221,11 @@ static int ____call_usermodehelper(void *data)
 	return 0;
 }
 
-static
-void call_usermodehelper_freeinfo(struct subprocess_info *info)
+static void call_usermodehelper_freeinfo(struct kref *kref)
 {
+	struct subprocess_info *info =
+		container_of(kref, struct subprocess_info, kref);
+
 	if (info->cleanup)
 		(*info->cleanup)(info);
 	kfree(info);
@@ -231,15 +233,8 @@ void call_usermodehelper_freeinfo(struct subprocess_info *info)
 
 static void umh_complete(struct subprocess_info *sub_info)
 {
-	struct completion *comp = xchg(&sub_info->complete, NULL);
-	/*
-	 * See call_usermodehelper_exec(). If xchg() returns NULL
-	 * we own sub_info, the UMH_KILLABLE caller has gone away.
-	 */
-	if (comp)
-		complete(comp);
-	else
-		call_usermodehelper_freeinfo(sub_info);
+	complete(&sub_info->complete);
+	kref_put(&sub_info->kref, call_usermodehelper_freeinfo);
 }
 
 /* Keventd can't block, but this (a child) can. */
@@ -302,7 +297,7 @@ static void __call_usermodehelper(struct work_struct *work)
 
 	switch (wait) {
 	case UMH_NO_WAIT:
-		call_usermodehelper_freeinfo(sub_info);
+		kref_put(&sub_info->kref,  call_usermodehelper_freeinfo);
 		break;
 
 	case UMH_WAIT_PROC:
@@ -431,6 +426,8 @@ struct subprocess_info *call_usermodehelper_setup(char *path, char **argv,
 	if (!sub_info)
 		goto out;
 
+	kref_init(&sub_info->kref);
+	init_completion(&sub_info->complete);
 	INIT_WORK(&sub_info->work, __call_usermodehelper);
 	sub_info->path = path;
 	sub_info->argv = argv;
@@ -521,7 +518,6 @@ void call_usermodehelper_setfns(struct subprocess_info *info,
 static
 int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 {
-	DECLARE_COMPLETION_ONSTACK(done);
 	int wait_state;
 	int retval = 0;
 
@@ -534,26 +530,21 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 		goto out;
 	}
 
-	sub_info->complete = &done;
 	sub_info->wait = wait;
 
+	/* Balanced in __call_usermodehelper or wait_for_helper */
+	kref_get(&sub_info->kref);
 	queue_work(khelper_wq, &sub_info->work);
 	if (wait == UMH_NO_WAIT)	/* task has freed sub_info */
-		goto unlock;
+		goto out;
 
 	wait_state = (wait & UMH_KILLABLE) ? TASK_KILLABLE : 0;
-	retval = wait_for_completion_timeout_state(&done, sub_info->timeout,
-						   wait_state);
-	if (unlikely(retval)) {
-		/* umh_complete() will see NULL and free sub_info */
-		if (xchg(&sub_info->complete, NULL))
-			goto unlock;
-	}
-
-	retval = sub_info->retval;
+	retval = wait_for_completion_timeout_state(&sub_info->complete,
+						sub_info->timeout, wait_state);
+	if (likely(!retval))
+		retval = sub_info->retval;
 out:
-	call_usermodehelper_freeinfo(sub_info);
-unlock:
+	kref_put(&sub_info->kref, call_usermodehelper_freeinfo);
 	helper_unlock();
 	return retval;
 }
-- 
1.7.6.5


