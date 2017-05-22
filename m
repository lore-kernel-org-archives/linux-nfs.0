Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36594 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935695AbdEVQXE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:23:04 -0400
Subject: [PATCH 4/9] Allow processes to be forked and upcalled into a
 container
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:22:57 +0100
Message-ID: <149547017779.10599.5194903072778182309.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow a single process to be forked directly into a container using a new
syscall:

	pid_t pid = fork_into_container(int container_fd);

Further attempts to fork into the container will be rejected.

Kernel upcalls will happen in the context of current's container, using
that containers namespaces.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 include/linux/cred.h                   |    3 +
 include/linux/kmod.h                   |    1 
 include/linux/lsm_hooks.h              |    4 +
 include/linux/nsproxy.h                |    7 ++
 include/linux/sched/task.h             |    4 +
 include/linux/security.h               |    5 +
 include/linux/syscalls.h               |    1 
 init/main.c                            |    4 +
 kernel/cred.c                          |   45 ++++++++++++
 kernel/fork.c                          |  117 ++++++++++++++++++++++++++------
 kernel/kmod.c                          |   13 +++-
 kernel/kthread.c                       |    3 +
 kernel/nsproxy.c                       |   13 +++-
 kernel/sys_ni.c                        |    2 -
 security/security.c                    |    5 +
 security/selinux/hooks.c               |    3 +
 18 files changed, 188 insertions(+), 44 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 9ccd0f52f874..0d5a9875ead2 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -394,3 +394,4 @@
 385	i386	fsopen			sys_fsopen
 386	i386	fsmount			sys_fsmount
 387	i386	container_create	sys_container_create
+388	i386	fork_into_container	sys_fork_into_container
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index dab92591511e..e4005cc579b6 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -342,6 +342,7 @@
 333	common	fsopen			sys_fsopen
 334	common	fsmount			sys_fsmount
 335	common	container_create	sys_container_create
+336	common	fork_into_container	sys_fork_into_container
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/cred.h b/include/linux/cred.h
index b03e7d049a64..834f10962014 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -23,6 +23,7 @@
 
 struct cred;
 struct inode;
+struct container;
 
 /*
  * COW Supplementary groups list
@@ -149,7 +150,7 @@ struct cred {
 
 extern void __put_cred(struct cred *);
 extern void exit_creds(struct task_struct *);
-extern int copy_creds(struct task_struct *, unsigned long);
+extern int copy_creds(struct task_struct *, unsigned long, struct container *);
 extern const struct cred *get_task_cred(struct task_struct *);
 extern struct cred *cred_alloc_blank(void);
 extern struct cred *prepare_creds(void);
diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index c4e441e00db5..7f004a261a1c 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -56,6 +56,7 @@ struct file;
 struct subprocess_info {
 	struct work_struct work;
 	struct completion *complete;
+	struct container *container;
 	const char *path;
 	char **argv;
 	char **envp;
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 7b0d484a6a25..37ac19645cca 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -564,6 +564,7 @@
  *	Check permission before creating a child process.  See the clone(2)
  *	manual page for definitions of the @clone_flags.
  *	@clone_flags contains the flags indicating what should be shared.
+ *	@container indicates the container the task is being created in (or NULL)
  *	Return 0 if permission is granted.
  * @task_alloc:
  *	@task task being allocated.
@@ -1535,7 +1536,8 @@ union security_list_options {
 	int (*file_receive)(struct file *file);
 	int (*file_open)(struct file *file, const struct cred *cred);
 
-	int (*task_create)(unsigned long clone_flags);
+	int (*task_create)(unsigned long clone_flags,
+			   struct container *container);
 	int (*task_alloc)(struct task_struct *task, unsigned long clone_flags);
 	void (*task_free)(struct task_struct *task);
 	int (*cred_alloc_blank)(struct cred *cred, gfp_t gfp);
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index ac0d65bef5d0..40478a65ab0a 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -10,6 +10,7 @@ struct ipc_namespace;
 struct pid_namespace;
 struct cgroup_namespace;
 struct fs_struct;
+struct container;
 
 /*
  * A structure to contain pointers to all per-process
@@ -62,9 +63,13 @@ extern struct nsproxy init_nsproxy;
  *         * /
  *     task_unlock(task);
  *
+ *  4. Container namespaces are set at container creation and cannot be
+ *     changed.
+ *
  */
 
-int copy_namespaces(unsigned long flags, struct task_struct *tsk);
+int copy_namespaces(unsigned long flags, struct task_struct *tsk,
+		    struct container *container);
 void exit_task_namespaces(struct task_struct *tsk);
 void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
 void free_nsproxy(struct nsproxy *ns);
diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index a978d7189cfd..025193fd0260 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -70,10 +70,10 @@ extern void do_group_exit(int);
 extern void exit_files(struct task_struct *);
 extern void exit_itimers(struct signal_struct *);
 
-extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
+extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long, struct container *);
 extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
 struct task_struct *fork_idle(int);
-extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
+extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags, struct container *);
 
 extern void free_task(struct task_struct *tsk);
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 01bdf7637ec6..ac8625b72d0e 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -314,7 +314,7 @@ int security_file_send_sigiotask(struct task_struct *tsk,
 				 struct fown_struct *fown, int sig);
 int security_file_receive(struct file *file);
 int security_file_open(struct file *file, const struct cred *cred);
-int security_task_create(unsigned long clone_flags);
+int security_task_create(unsigned long clone_flags, struct container *container);
 int security_task_alloc(struct task_struct *task, unsigned long clone_flags);
 void security_task_free(struct task_struct *task);
 int security_cred_alloc_blank(struct cred *cred, gfp_t gfp);
@@ -885,7 +885,8 @@ static inline int security_file_open(struct file *file,
 	return 0;
 }
 
-static inline int security_task_create(unsigned long clone_flags)
+static inline int security_task_create(unsigned long clone_flags,
+				       struct container *container)
 {
 	return 0;
 }
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 5a0324dd024c..7ca6c287ce84 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -911,5 +911,6 @@ asmlinkage long sys_fsmount(int fsfd, int dfd, const char *path, unsigned int at
 asmlinkage long sys_container_create(const char __user *name, unsigned int flags,
 				     unsigned long spare3, unsigned long spare4,
 				     unsigned long spare5);
+asmlinkage long sys_fork_into_container(int containerfd);
 
 #endif
diff --git a/init/main.c b/init/main.c
index f866510472d7..f638cb44826a 100644
--- a/init/main.c
+++ b/init/main.c
@@ -397,9 +397,9 @@ static noinline void __ref rest_init(void)
 	 * the init task will end up wanting to create kthreads, which, if
 	 * we schedule it before we create kthreadd, will OOPS.
 	 */
-	kernel_thread(kernel_init, NULL, CLONE_FS);
+	kernel_thread(kernel_init, NULL, CLONE_FS, NULL);
 	numa_default_policy();
-	pid = kernel_thread(kthreadd, NULL, CLONE_FS | CLONE_FILES);
+	pid = kernel_thread(kthreadd, NULL, CLONE_FS | CLONE_FILES, NULL);
 	rcu_read_lock();
 	kthreadd_task = find_task_by_pid_ns(pid, &init_pid_ns);
 	rcu_read_unlock();
diff --git a/kernel/cred.c b/kernel/cred.c
index 2bc66075740f..363ccd333267 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -312,6 +312,43 @@ struct cred *prepare_exec_creds(void)
 }
 
 /*
+ * Handle forking a process into a container.
+ */
+static struct cred *copy_container_creds(struct container *container)
+{
+	struct cred *new;
+
+	validate_process_creds();
+
+	new = kmem_cache_alloc(cred_jar, GFP_KERNEL);
+	if (!new)
+		return NULL;
+
+	kdebug("prepare_creds() alloc %p", new);
+
+	memcpy(new, container->cred, sizeof(struct cred));
+
+	atomic_set(&new->usage, 1);
+	set_cred_subscribers(new, 0);
+	get_group_info(new->group_info);
+	get_uid(new->user);
+	get_user_ns(new->user_ns);
+
+#ifdef CONFIG_SECURITY
+	new->security = NULL;
+#endif
+
+	if (security_prepare_creds(new, container->cred, GFP_KERNEL) < 0)
+		goto error;
+	validate_creds(new);
+	return new;
+
+error:
+	abort_creds(new);
+	return NULL;
+}
+
+/*
  * Copy credentials for the new process created by fork()
  *
  * We share if we can, but under some circumstances we have to generate a new
@@ -320,7 +357,8 @@ struct cred *prepare_exec_creds(void)
  * The new process gets the current process's subjective credentials as its
  * objective and subjective credentials
  */
-int copy_creds(struct task_struct *p, unsigned long clone_flags)
+int copy_creds(struct task_struct *p, unsigned long clone_flags,
+	       struct container *container)
 {
 	struct cred *new;
 	int ret;
@@ -341,7 +379,10 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 		return 0;
 	}
 
-	new = prepare_creds();
+	if (container)
+		new = copy_container_creds(container);
+	else
+		new = prepare_creds();
 	if (!new)
 		return -ENOMEM;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index ff2779426fe9..d185c13820d7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1241,9 +1241,33 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	return retval;
 }
 
-static int copy_fs(unsigned long clone_flags, struct task_struct *tsk)
+static int copy_fs(unsigned long clone_flags, struct task_struct *tsk,
+		   struct container *container)
 {
 	struct fs_struct *fs = current->fs;
+
+#ifdef CONFIG_CONTAINERS
+	if (container) {
+		fs = kmem_cache_alloc(fs_cachep, GFP_KERNEL);
+		if (!fs)
+			return -ENOMEM;
+
+		fs->users = 1;
+		fs->in_exec = 0;
+		spin_lock_init(&fs->lock);
+		seqcount_init(&fs->seq);
+		fs->umask = 0022;
+
+		spin_lock(&container->lock);
+		fs->pwd = fs->root = container->root;
+		path_get(&fs->root);
+		path_get(&fs->pwd);
+		spin_unlock(&container->lock);
+		tsk->fs = fs;
+		return 0;
+	}
+#endif
+
 	if (clone_flags & CLONE_FS) {
 		/* tsk->fs is already what we want */
 		spin_lock(&fs->lock);
@@ -1521,7 +1545,8 @@ static __latent_entropy struct task_struct *copy_process(
 					struct pid *pid,
 					int trace,
 					unsigned long tls,
-					int node)
+					int node,
+					struct container *container)
 {
 	int retval;
 	struct task_struct *p;
@@ -1568,7 +1593,7 @@ static __latent_entropy struct task_struct *copy_process(
 			return ERR_PTR(-EINVAL);
 	}
 
-	retval = security_task_create(clone_flags);
+	retval = security_task_create(clone_flags, container);
 	if (retval)
 		goto fork_out;
 
@@ -1594,7 +1619,7 @@ static __latent_entropy struct task_struct *copy_process(
 	}
 	current->flags &= ~PF_NPROC_EXCEEDED;
 
-	retval = copy_creds(p, clone_flags);
+	retval = copy_creds(p, clone_flags, container);
 	if (retval < 0)
 		goto bad_fork_free;
 
@@ -1713,7 +1738,7 @@ static __latent_entropy struct task_struct *copy_process(
 	retval = copy_files(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_semundo;
-	retval = copy_fs(clone_flags, p);
+	retval = copy_fs(clone_flags, p, container);
 	if (retval)
 		goto bad_fork_cleanup_files;
 	retval = copy_sighand(clone_flags, p);
@@ -1725,15 +1750,15 @@ static __latent_entropy struct task_struct *copy_process(
 	retval = copy_mm(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_signal;
-	retval = copy_namespaces(clone_flags, p);
+	retval = copy_container(clone_flags, p, container);
 	if (retval)
 		goto bad_fork_cleanup_mm;
-	retval = copy_container(clone_flags, p, NULL);
+	retval = copy_namespaces(clone_flags, p, container);
 	if (retval)
-		goto bad_fork_cleanup_namespaces;
+		goto bad_fork_cleanup_container;
 	retval = copy_io(clone_flags, p);
 	if (retval)
-		goto bad_fork_cleanup_container;
+		goto bad_fork_cleanup_namespaces;
 	retval = copy_thread_tls(clone_flags, stack_start, stack_size, p, tls);
 	if (retval)
 		goto bad_fork_cleanup_io;
@@ -1921,10 +1946,10 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_cleanup_io:
 	if (p->io_context)
 		exit_io_context(p);
-bad_fork_cleanup_container:
-	exit_container(p);
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
+bad_fork_cleanup_container:
+	exit_container(p);
 bad_fork_cleanup_mm:
 	if (p->mm)
 		mmput(p->mm);
@@ -1976,7 +2001,7 @@ struct task_struct *fork_idle(int cpu)
 {
 	struct task_struct *task;
 	task = copy_process(CLONE_VM, 0, 0, NULL, &init_struct_pid, 0, 0,
-			    cpu_to_node(cpu));
+			    cpu_to_node(cpu), NULL);
 	if (!IS_ERR(task)) {
 		init_idle_pids(task->pids);
 		init_idle(task, cpu);
@@ -1988,15 +2013,16 @@ struct task_struct *fork_idle(int cpu)
 /*
  *  Ok, this is the main fork-routine.
  *
- * It copies the process, and if successful kick-starts
- * it and waits for it to finish using the VM if required.
+ * It copies the process into the specified container, and if successful
+ * kick-starts it and waits for it to finish using the VM if required.
  */
 long _do_fork(unsigned long clone_flags,
 	      unsigned long stack_start,
 	      unsigned long stack_size,
 	      int __user *parent_tidptr,
 	      int __user *child_tidptr,
-	      unsigned long tls)
+	      unsigned long tls,
+	      struct container *container)
 {
 	struct task_struct *p;
 	int trace = 0;
@@ -2020,8 +2046,32 @@ long _do_fork(unsigned long clone_flags,
 			trace = 0;
 	}
 
+	if (container) {
+		/* A process spawned into a container doesn't share anything
+		 * with the parent other than namespaces.
+		 */
+		if (clone_flags & (CLONE_CHILD_CLEARTID |
+				   CLONE_CHILD_SETTID |
+				   CLONE_FILES |
+				   CLONE_FS |
+				   CLONE_IO |
+				   CLONE_PARENT |
+				   CLONE_PARENT_SETTID |
+				   CLONE_PTRACE |
+				   CLONE_SETTLS |
+				   CLONE_SIGHAND |
+				   CLONE_SYSVSEM |
+				   CLONE_THREAD))
+			return -EINVAL;
+
+		/* However, we do have to let kernel threads borrow a VM. */
+		if ((clone_flags & CLONE_VM) && current->mm)
+			return -EINVAL;
+	}
+	
 	p = copy_process(clone_flags, stack_start, stack_size,
-			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE);
+			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE,
+			 container);
 	add_latent_entropy();
 	/*
 	 * Do this prior waking up the new thread - the thread pointer
@@ -2073,24 +2123,25 @@ long do_fork(unsigned long clone_flags,
 	      int __user *child_tidptr)
 {
 	return _do_fork(clone_flags, stack_start, stack_size,
-			parent_tidptr, child_tidptr, 0);
+			parent_tidptr, child_tidptr, 0, NULL);
 }
 #endif
 
 /*
  * Create a kernel thread.
  */
-pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
+pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags,
+		    struct container *container)
 {
 	return _do_fork(flags|CLONE_VM|CLONE_UNTRACED, (unsigned long)fn,
-		(unsigned long)arg, NULL, NULL, 0);
+			(unsigned long)arg, NULL, NULL, 0, container);
 }
 
 #ifdef __ARCH_WANT_SYS_FORK
 SYSCALL_DEFINE0(fork)
 {
 #ifdef CONFIG_MMU
-	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0);
+	return _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, NULL);
 #else
 	/* can not support in nommu mode */
 	return -EINVAL;
@@ -2102,10 +2153,31 @@ SYSCALL_DEFINE0(fork)
 SYSCALL_DEFINE0(vfork)
 {
 	return _do_fork(CLONE_VFORK | CLONE_VM | SIGCHLD, 0,
-			0, NULL, NULL, 0);
+			0, NULL, NULL, 0, NULL);
 }
 #endif
 
+SYSCALL_DEFINE1(fork_into_container, int, containerfd)
+{
+#ifdef CONFIG_CONTAINERS
+	struct fd f = fdget(containerfd);
+	int ret;
+
+	if (!f.file)
+		return -EBADF;
+	ret = -EINVAL;
+	if (is_container_file(f.file)) {
+		struct container *c = f.file->private_data;
+
+		ret = _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, c);
+	}
+	fdput(f);
+	return ret;
+#else
+	return -ENOSYS;
+#endif
+}
+
 #ifdef __ARCH_WANT_SYS_CLONE
 #ifdef CONFIG_CLONE_BACKWARDS
 SYSCALL_DEFINE5(clone, unsigned long, clone_flags, unsigned long, newsp,
@@ -2130,7 +2202,8 @@ SYSCALL_DEFINE5(clone, unsigned long, clone_flags, unsigned long, newsp,
 		 unsigned long, tls)
 #endif
 {
-	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls);
+	return _do_fork(clone_flags, newsp, 0, parent_tidptr, child_tidptr, tls,
+			NULL);
 }
 #endif
 
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 563f97e2be36..1857a3bb9e61 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -42,6 +42,7 @@
 #include <linux/ptrace.h>
 #include <linux/async.h>
 #include <linux/uaccess.h>
+#include <linux/container.h>
 
 #include <trace/events/module.h>
 
@@ -160,7 +161,7 @@ int __request_module(bool wait, const char *fmt, ...)
 	 * would be to run the parents of this process, counting how many times
 	 * kmod was invoked.  That would mean accessing the internals of the
 	 * process tables to get the command line, proc_pid_cmdline is static
-	 * and it is not worth changing the proc code just to handle this case. 
+	 * and it is not worth changing the proc code just to handle this case.
 	 * KAO.
 	 *
 	 * "trace the ppid" is simple, but will fail if someone's
@@ -194,6 +195,7 @@ static void call_usermodehelper_freeinfo(struct subprocess_info *info)
 {
 	if (info->cleanup)
 		(*info->cleanup)(info);
+	put_container(info->container);
 	kfree(info);
 }
 
@@ -274,7 +276,8 @@ static void call_usermodehelper_exec_sync(struct subprocess_info *sub_info)
 
 	/* If SIGCLD is ignored sys_wait4 won't populate the status. */
 	kernel_sigaction(SIGCHLD, SIG_DFL);
-	pid = kernel_thread(call_usermodehelper_exec_async, sub_info, SIGCHLD);
+	pid = kernel_thread(call_usermodehelper_exec_async, sub_info, SIGCHLD,
+			    sub_info->container);
 	if (pid < 0) {
 		sub_info->retval = pid;
 	} else {
@@ -335,7 +338,7 @@ static void call_usermodehelper_exec_work(struct work_struct *work)
 		 * that always ignores SIGCHLD to ensure auto-reaping.
 		 */
 		pid = kernel_thread(call_usermodehelper_exec_async, sub_info,
-				    CLONE_PARENT | SIGCHLD);
+				    CLONE_PARENT | SIGCHLD, sub_info->container);
 		if (pid < 0) {
 			sub_info->retval = pid;
 			umh_complete(sub_info);
@@ -531,6 +534,8 @@ struct subprocess_info *call_usermodehelper_setup(const char *path, char **argv,
 
 	INIT_WORK(&sub_info->work, call_usermodehelper_exec_work);
 
+	sub_info->container = current->container;
+
 #ifdef CONFIG_STATIC_USERMODEHELPER
 	sub_info->path = CONFIG_STATIC_USERMODEHELPER_PATH;
 #else
@@ -564,6 +569,8 @@ int call_usermodehelper_exec(struct subprocess_info *sub_info, int wait)
 	DECLARE_COMPLETION_ONSTACK(done);
 	int retval = 0;
 
+	get_container(sub_info->container);
+
 	if (!sub_info->path) {
 		call_usermodehelper_freeinfo(sub_info);
 		return -EINVAL;
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 26db528c1d88..ca0090f90645 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -251,7 +251,8 @@ static void create_kthread(struct kthread_create_info *create)
 	current->pref_node_fork = create->node;
 #endif
 	/* We want our own signal handler (we take no signals by default). */
-	pid = kernel_thread(kthread, create, CLONE_FS | CLONE_FILES | SIGCHLD);
+	pid = kernel_thread(kthread, create, CLONE_FS | CLONE_FILES | SIGCHLD,
+			    NULL);
 	if (pid < 0) {
 		/* If user was SIGKILLed, I release the structure. */
 		struct completion *done = xchg(&create->done, NULL);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 4bb5184b3a80..9743cf23df93 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -136,12 +136,19 @@ struct nsproxy *create_new_namespaces(unsigned long flags,
  * called from clone.  This now handles copy for nsproxy and all
  * namespaces therein.
  */
-int copy_namespaces(unsigned long flags, struct task_struct *tsk)
+int copy_namespaces(unsigned long flags, struct task_struct *tsk,
+		    struct container *container)
 {
 	struct nsproxy *old_ns = tsk->nsproxy;
 	struct user_namespace *user_ns = task_cred_xxx(tsk, user_ns);
 	struct nsproxy *new_ns;
 
+	if (container) {
+		get_nsproxy(container->ns);
+		tsk->nsproxy = container->ns;
+		return 0;
+	}
+
 	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
 			      CLONE_NEWPID | CLONE_NEWNET |
 			      CLONE_NEWCGROUP)))) {
@@ -151,7 +158,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 
 	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
-
+	
 	/*
 	 * CLONE_NEWIPC must detach from the undolist: after switching
 	 * to a new ipc namespace, the semaphore arrays from the old
@@ -163,7 +170,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 		(CLONE_NEWIPC | CLONE_SYSVSEM)) 
 		return -EINVAL;
 
-	new_ns = create_new_namespaces(flags, tsk->nsproxy, user_ns, tsk->fs);
+	new_ns = create_new_namespaces(flags, old_ns, user_ns, tsk->fs);
 	if (IS_ERR(new_ns))
 		return  PTR_ERR(new_ns);
 
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 99b1e1f58d05..b685ffe3591f 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -265,4 +265,4 @@ cond_syscall(sys_fsmount);
 
 /* Containers */
 cond_syscall(sys_container_create);
-
+cond_syscall(sys_fork_into_container);
diff --git a/security/security.c b/security/security.c
index b5c5b5ae1266..21e14aa26cd3 100644
--- a/security/security.c
+++ b/security/security.c
@@ -961,9 +961,10 @@ int security_file_open(struct file *file, const struct cred *cred)
 	return fsnotify_perm(file, MAY_OPEN);
 }
 
-int security_task_create(unsigned long clone_flags)
+int security_task_create(unsigned long clone_flags,
+			 struct container *container)
 {
-	return call_int_hook(task_create, 0, clone_flags);
+	return call_int_hook(task_create, 0, clone_flags, container);
 }
 
 int security_task_alloc(struct task_struct *task, unsigned long clone_flags)
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 877b7e7bd2d5..23bdbb0c2de5 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3865,7 +3865,8 @@ static int selinux_file_open(struct file *file, const struct cred *cred)
 
 /* task security operations */
 
-static int selinux_task_create(unsigned long clone_flags)
+static int selinux_task_create(unsigned long clone_flags,
+			       struct container *container)
 {
 	u32 sid = current_sid();
 

