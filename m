Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59509 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab2C0COI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 22:14:08 -0400
Message-ID: <4F712246.6030201@panasas.com>
Date: Mon, 26 Mar 2012 19:13:26 -0700
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
Subject: [PATCH 5/6] kmod: Add new call_usermodehelper_timeout() API
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com>
In-Reply-To: <4F711EA2.4030608@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


In the blasphemous occasions that the Kernel must call a user-mode program
half of the times it is more robust to not wait forever but limit the wait
for a specified timeout.

So add a new  call_usermodehelper_timeout() that implements that.
(Users of this new API will be added once this API is in mainline)

call_usermodehelper_fns() is added an extra timeout parameter which
is then implemented in call_usermodehelper_exec. The few users of
call_usermodehelper_fns() are also changed in this patch.

Also an gfp_t parameter is added, for finer allocation control

The code in call_usermodehelper_exec is simplified by the use of
the all-mighty wait_for_completion_timeout_state() which is able
to wait in all the different modes. See:
	completion: Add wait_for_completion_timeout_state()

Should some wait-forever callers today, be converted to this new
schema?

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exec.c                   |    4 ++--
 include/linux/kmod.h        |   19 ++++++++++++++-----
 kernel/kmod.c               |   24 ++++++++++++------------
 kernel/sys.c                |    2 +-
 security/keys/request_key.c |    2 +-
 5 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 23559c2..8789ba8 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -2185,8 +2185,8 @@ void do_coredump(long signr, int exit_code, struct pt_regs *regs)
 		}
 
 		retval = call_usermodehelper_fns(helper_argv[0], helper_argv,
-					NULL, UMH_WAIT_EXEC, umh_pipe_setup,
-					NULL, &cprm);
+					NULL, UMH_WAIT_EXEC, 0, 0,
+					umh_pipe_setup, NULL, &cprm);
 		argv_free(helper_argv);
 		if (retval) {
  			printk(KERN_INFO "Core dump to %s pipe failed\n",
diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index ae3f9623..4d9f202 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -60,21 +60,30 @@ struct subprocess_info {
 	char **argv;
 	char **envp;
 	int wait;
+	unsigned long timeout;
 	int retval;
 	int (*init)(struct subprocess_info *info, struct cred *new);
 	void (*cleanup)(struct subprocess_info *info);
 	void *data;
 };
 
-extern int
-call_usermodehelper_fns(char *path, char **argv, char **envp, int wait,
-			int (*init)(struct subprocess_info *info, struct cred *new),
-			void (*cleanup)(struct subprocess_info *), void *data);
+extern int call_usermodehelper_fns(char *path, char **argv, char **envp,
+	int wait, unsigned long timeout, gfp_t gfp,
+	int (*init)(struct subprocess_info *info, struct cred *new),
+	void (*cleanup)(struct subprocess_info *), void *data);
 
 static inline int
 call_usermodehelper(char *path, char **argv, char **envp, int wait)
 {
-	return call_usermodehelper_fns(path, argv, envp, wait,
+	return call_usermodehelper_fns(path, argv, envp, wait, 0, 0,
+				       NULL, NULL, NULL);
+}
+
+static inline int
+call_usermodehelper_timeout(char *path, char **argv, char **envp,
+			    int wait, unsigned long timeout, gfp_t gfp)
+{
+	return call_usermodehelper_fns(path, argv, envp, wait, timeout, gfp,
 				       NULL, NULL, NULL);
 }
 
diff --git a/kernel/kmod.c b/kernel/kmod.c
index b404f99..588cb6f 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -90,7 +90,7 @@ static int call_modprobe(char *module_name, int wait)
 	argv[4] = NULL;
 
 	return call_usermodehelper_fns(modprobe_path, argv, envp,
-		wait | UMH_KILLABLE, NULL, free_modprobe_argv, NULL);
+		wait | UMH_KILLABLE, 0, 0, NULL, free_modprobe_argv, NULL);
 free_argv:
 	kfree(argv);
 out:
@@ -522,6 +522,7 @@ void call_usermodehelper_setfns(struct subprocess_info *info,
 int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 {
 	DECLARE_COMPLETION_ONSTACK(done);
+	int wait_state;
 	int retval = 0;
 
 	helper_lock();
@@ -540,19 +541,15 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 	if (wait == UMH_NO_WAIT)	/* task has freed sub_info */
 		goto unlock;
 
-	if (wait & UMH_KILLABLE) {
-		retval = wait_for_completion_killable(&done);
-		if (!retval)
-			goto wait_done;
-
+	wait_state = (wait & UMH_KILLABLE) ? TASK_KILLABLE : 0;
+	retval = wait_for_completion_timeout_state(&done, sub_info->timeout,
+						   wait_state);
+	if (unlikely(retval)) {
 		/* umh_complete() will see NULL and free sub_info */
 		if (xchg(&sub_info->complete, NULL))
 			goto unlock;
-		/* fallthrough, umh_complete() was already called */
 	}
 
-	wait_for_completion(&done);
-wait_done:
 	retval = sub_info->retval;
 out:
 	call_usermodehelper_freeinfo(sub_info);
@@ -561,13 +558,15 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 	return retval;
 }
 
-int call_usermodehelper_fns(
-	char *path, char **argv, char **envp, int wait,
+int call_usermodehelper_fns(char *path, char **argv, char **envp,
+	int wait, unsigned long timeout, gfp_t gfp_mask,
 	int (*init)(struct subprocess_info *info, struct cred *new),
 	void (*cleanup)(struct subprocess_info *), void *data)
 {
 	struct subprocess_info *info;
-	gfp_t gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
+
+	if (!gfp_mask)
+		gfp_mask = (wait == UMH_NO_WAIT) ? GFP_ATOMIC : GFP_KERNEL;
 
 	info = call_usermodehelper_setup(path, argv, envp, gfp_mask);
 
@@ -575,6 +574,7 @@ int call_usermodehelper_fns(
 		return -ENOMEM;
 
 	call_usermodehelper_setfns(info, init, cleanup, data);
+	info->timeout = timeout;
 
 	return call_usermodehelper_exec(info, wait);
 }
diff --git a/kernel/sys.c b/kernel/sys.c
index 37b1971..16d14d1 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2020,7 +2020,7 @@ int orderly_poweroff(bool force)
 		goto out;
 	}
 
-	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_NO_WAIT,
+	ret = call_usermodehelper_fns(argv[0], argv, envp, UMH_NO_WAIT, 0, 0,
 				      NULL, argv_cleanup, NULL);
 out:
 	if (likely(!ret))
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 000e750..aa94dbb 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -93,7 +93,7 @@ static void umh_keys_cleanup(struct subprocess_info *info)
 static int call_usermodehelper_keys(char *path, char **argv, char **envp,
 					struct key *session_keyring, int wait)
 {
-	return call_usermodehelper_fns(path, argv, envp, wait,
+	return call_usermodehelper_fns(path, argv, envp, wait, 0, 0,
 				       umh_keys_init, umh_keys_cleanup,
 				       key_get(session_keyring));
 }
-- 
1.7.6.5


