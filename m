Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752614AbdFNPQR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:16:17 -0400
Subject: [PATCH 06/27] Provide supplementary error message facility [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:16:11 +0100
Message-ID: <149745337097.10897.6533194783327792549.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a way for the kernel to pass supplementary error messages to
userspace.  This will make it easier for userspace, particularly in
containers to find out what went wrong during mounts and automounts, but is
also made available to any other syscalls that want to use it.

Two prctl() functions are added for this:

 (1) int old_setting = prctl(PR_ERRMSG_ENABLE, int setting);

     Enable (setting == 1) or disable (setting == 0) the facility.
     Disabling the facility clears the error buffer.

 (2) int size = prctl(PR_ERRMSG_READ, char *buffer, int buf_size);

     Reads the next error string into the buffer.  The string is truncated
     if it won't fit.  Strings are discarded as they're read.

     If there isn't a string, ENODATA is indicated.

I've done it this way rather than a proc file because procfs might not be
accessible.

The interface inside the kernel is a pair of macros:

 (*) void errorf(const char *fmt, ...);
 (*) int invalf(const char *fmt, ...);

Both of them snprintf() the string into the current process's error message
buffer if the facility is enabled.  The string is truncated if it exceeds
the limit.  invalf() returns -EINVAL whereas errof() has no return.

Note that this is very crude and could be made to store multiple strings,
allocate storage as required and not duplicate unformatted strings that are
stored in the rodata section (like kvasprintf_const).  Unfortunately,
specially handling rodata strings wouldn't gain a lot as most strings are
likely to be in modules, where the string's life can be terminated by
rmmod.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/sched.h      |   29 +++++++++++++++++++++++++++++
 include/uapi/linux/prctl.h |    6 ++++++
 kernel/exit.c              |    1 +
 kernel/fork.c              |    1 +
 kernel/sys.c               |   38 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 75 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2b69fc650201..a6002b60b0b9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1051,6 +1051,8 @@ struct task_struct {
 	/* Used by LSM modules for access restriction: */
 	void				*security;
 #endif
+#define ERROR_MSG_SIZE 256
+	char				*error_msg;
 	/* CPU-specific state of this task: */
 	struct thread_struct		thread;
 
@@ -1573,4 +1575,31 @@ extern long sched_getaffinity(pid_t pid, struct cpumask *mask);
 #define TASK_SIZE_OF(tsk)	TASK_SIZE
 #endif
 
+/**
+ * errorf - Store supplementary error message
+ * @fmt: The format string
+ *
+ * Store the supplementary error message for the process if the process has
+ * enabled the facility.
+ */
+#define errorf(fmt, ...)			\
+	do {					\
+		if (current->error_msg)					\
+			snprintf(current->error_msg, ERROR_MSG_SIZE, fmt, ## __VA_ARGS__); \
+	} while(0)
+
+/**
+ * invalf - Store supplementary invalid argument error message
+ * @fmt: The format string
+ *
+ * Store the supplementary error message for the process if the process has
+ * enabled the facility and return -EINVAL.
+ */
+#define invalf(fmt, ...)			\
+	({					\
+		errorf(fmt, ## __VA_ARGS__);	\
+		-EINVAL;			\
+	})
+
+
 #endif
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759a9e40..b1203850dac8 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,10 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+/*
+ * Control the supplementary error message gathering facility.
+ */
+#define PR_ERRMSG_ENABLE		48
+#define PR_ERRMSG_READ			49
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/exit.c b/kernel/exit.c
index 516acdb0e0ec..31b8617aee04 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -932,6 +932,7 @@ void __noreturn do_exit(long code)
 		__this_cpu_add(dirty_throttle_leaks, tsk->nr_dirtied);
 	exit_rcu();
 	TASKS_RCU(__srcu_read_unlock(&tasks_rcu_exit_srcu, tasks_rcu_i));
+	kfree(tsk->error_msg);
 
 	do_task_dead();
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index e53770d2bf95..177b4c82fcb9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1912,6 +1912,7 @@ static __latent_entropy struct task_struct *copy_process(
 
 	trace_task_newtask(p, clone_flags);
 	uprobe_copy_process(p, clone_flags);
+	p->error_msg = NULL;
 
 	return p;
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 8a94b4eabcaa..b784905c4806 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2295,6 +2295,44 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+
+	case PR_ERRMSG_ENABLE:
+		switch (arg2) {
+		case 0:
+			if (!current->error_msg)
+				return 0;
+			kfree(current->error_msg);
+			current->error_msg = NULL;
+			return 1;
+		case 1:
+			if (current->error_msg)
+				return 1;
+			current->error_msg = kmalloc(ERROR_MSG_SIZE, GFP_KERNEL);
+			if (!current->error_msg)
+				return -ENOMEM;
+			current->error_msg[0] = 0;
+			return 0;
+		default:
+			error = -EINVAL;
+			break;
+		}
+		break;
+
+	case PR_ERRMSG_READ:
+		if (!arg2 || !arg3)
+			return -EINVAL;
+		if (!current->error_msg)
+			return -EINVAL;
+		if (!current->error_msg[0])
+			return -ENODATA;
+		error = strlen(current->error_msg);
+		if (arg3 < error)
+			error = arg3;
+		if (copy_to_user((char __user *)arg2, current->error_msg, error))
+			return -EFAULT;
+		current->error_msg[0] = 0;
+		return error;
+
 	default:
 		error = -EINVAL;
 		break;

