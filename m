Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935712AbdEVQWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:22:50 -0400
Subject: [PATCH 2/9] Implement containers as kernel objects
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:22:42 +0100
Message-ID: <149547016213.10599.1969443294414531853.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A container is then a kernel object that contains the following things:

 (1) Namespaces.

 (2) A root directory.

 (3) A set of processes, including one designated as the 'init' process.

A container is created and attached to a file descriptor by:

	int cfd = container_create(const char *name, unsigned int flags);

this inherits all the namespaces of the parent container unless otherwise
the mask calls for new namespaces.

	CONTAINER_NEW_FS_NS
	CONTAINER_NEW_EMPTY_FS_NS
	CONTAINER_NEW_CGROUP_NS [root only]
	CONTAINER_NEW_UTS_NS
	CONTAINER_NEW_IPC_NS
	CONTAINER_NEW_USER_NS
	CONTAINER_NEW_PID_NS
	CONTAINER_NEW_NET_NS

Other flags include:

	CONTAINER_KILL_ON_CLOSE
	CONTAINER_CLOSE_ON_EXEC

Note that I've added a pointer to the current container to task_struct.
This doesn't make the nsproxy pointer redundant as you can still make new
namespaces with clone().

I've also added a list_head to task_struct to form a list in the container
of its member processes.  This is convenient, but redundant since the code
could iterate over all the tasks looking for ones that have a matching
task->container.


==================
FUTURE DEVELOPMENT
==================

 (1) Setting up the container.

     It should then be possible for the supervising process to modify the
     new container by:

	container_mount(int cfd,
			const char *source,
			const char *target, /* NULL -> root */
			const char *filesystemtype,
			unsigned long mountflags,
			const void *data);
	container_chroot(int cfd, const char *path);
	container_bind_mount_across(int cfd,
				    const char *source,
				    const char *target); /* NULL -> root */
	mkdirat(int cfd, const char *path, mode_t mode);
	mknodat(int cfd, const char *path, mode_t mode, dev_t dev);
	int fd = openat(int cfd, const char *path,
			unsigned int flags, mode_t mode);
	int fd = container_socket(int cfd, int domain, int type,
				  int protocol);

     Opening a netlink socket inside the container should allow management
     of the container's network namespace.

 (2) Starting the container.

     Once all modifications are complete, the container's 'init' process
     can be started by:

	fork_into_container(int cfd);

     This precludes further external modification of the mount tree within
     the container.  Before this point, the container is simply destroyed
     if the container fd is closed.

 (3) Waiting for the container to complete.

     The container fd can then be polled to wait for init process therein
     to complete and the exit code collected by:

	container_wait(int container_fd, int *_wstatus, unsigned int wait,
		       struct rusage *rusage);

     The container and everything in it can be terminated or killed off:

	container_kill(int container_fd, int initonly, int signal);

     If 'init' dies, all other processes in the container are preemptively
     SIGKILL'd by the kernel.

     By default, if the container is active and its fd is closed, the
     container is left running and wil be cleaned up when its 'init' exits.
     The default can be changed with the CONTAINER_KILL_ON_CLOSE flag.

 (4) Supervising the container.

     Given that we have an fd attached to the container, we could make it
     such that the supervising process could monitor and override EPERM
     returns for mount and other privileged operations within the
     container.

 (5) Device restriction.

     Containers could come with a list of device IDs that the container is
     allowed to open.  Perhaps a list major numbers, each with a bitmap of
     permitted minor numbers.

 (6) Per-container keyring.

     Each container could be given a per-container keyring for the holding
     of integrity keys and filesystem keys.  This list would be only
     modifiable by the container's 'root' user and the supervisor process:

	container_add_key(const char *type, const char *description,
                          const void *payload, size_t plen,
                          int container_fd);

     The keys on the keyring would, however, be accessible/usable by all
     processes within the keyring.


===============
EXAMPLE PROGRAM
===============

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#define CONTAINER_NEW_FS_NS		0x00000001 /* Dup current fs namespace */
#define CONTAINER_NEW_EMPTY_FS_NS	0x00000002 /* Provide new empty fs namespace */
#define CONTAINER_NEW_CGROUP_NS		0x00000004 /* Dup current cgroup namespace [priv] */
#define CONTAINER_NEW_UTS_NS		0x00000008 /* Dup current uts namespace */
#define CONTAINER_NEW_IPC_NS		0x00000010 /* Dup current ipc namespace */
#define CONTAINER_NEW_USER_NS		0x00000020 /* Dup current user namespace */
#define CONTAINER_NEW_PID_NS		0x00000040 /* Dup current pid namespace */
#define CONTAINER_NEW_NET_NS		0x00000080 /* Dup current net namespace */
#define CONTAINER_KILL_ON_CLOSE		0x00000100 /* Kill all member processes when fd closed */
#define CONTAINER_FD_CLOEXEC		0x00000200 /* Close the fd on exec */
#define CONTAINER__FLAG_MASK		0x000003ff

static inline int container_create(const char *name, unsigned int mask)
{
	return syscall(333, name, mask, 0, 0, 0);
}

static inline int fork_into_container(int containerfd)
{
	return syscall(334, containerfd);
}

int main()
{
	pid_t pid;
	int fd, ws;

	fd = container_create("foo-test",
			      CONTAINER__FLAG_MASK & ~(
				      CONTAINER_NEW_EMPTY_FS_NS |
				      CONTAINER_NEW_CGROUP_NS));
	if (fd == -1) {
		perror("container_create");
		exit(1);
	}

	system("cat /proc/containers");

	switch ((pid = fork_into_container(fd))) {
	case -1:
		perror("fork_into_container");
		exit(1);
	case 0:
		close(fd);
		setenv("PS1", "container>", 1);
		execl("/bin/bash", "bash", NULL);
		perror("execl");
		exit(1);
	default:
		if (waitpid(pid, &ws, 0) < 0) {
			perror("waitpid");
			exit(1);
		}
	}
	close(fd);
	exit(0);
}

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 fs/namespace.c                         |    5 
 include/linux/container.h              |   85 ++++++
 include/linux/init_task.h              |    4 
 include/linux/lsm_hooks.h              |   21 +
 include/linux/sched.h                  |    3 
 include/linux/security.h               |   15 +
 include/linux/syscalls.h               |    3 
 include/uapi/linux/container.h         |   28 ++
 include/uapi/linux/magic.h             |    1 
 init/Kconfig                           |    7 
 kernel/Makefile                        |    2 
 kernel/container.c                     |  462 ++++++++++++++++++++++++++++++++
 kernel/exit.c                          |    1 
 kernel/fork.c                          |    7 
 kernel/namespaces.h                    |   15 +
 kernel/nsproxy.c                       |   23 +-
 kernel/sys_ni.c                        |    4 
 security/security.c                    |   13 +
 20 files changed, 688 insertions(+), 13 deletions(-)
 create mode 100644 include/linux/container.h
 create mode 100644 include/uapi/linux/container.h
 create mode 100644 kernel/container.c
 create mode 100644 kernel/namespaces.h

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index abe6ea95e0e6..9ccd0f52f874 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -393,3 +393,4 @@
 384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
 385	i386	fsopen			sys_fsopen
 386	i386	fsmount			sys_fsmount
+387	i386	container_create	sys_container_create
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 0977c5079831..dab92591511e 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -341,6 +341,7 @@
 332	common	statx			sys_statx
 333	common	fsopen			sys_fsopen
 334	common	fsmount			sys_fsmount
+335	common	container_create	sys_container_create
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/namespace.c b/fs/namespace.c
index 4e9ad16db79c..7e2d5fe5728b 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -28,6 +28,7 @@
 #include <linux/file.h>
 #include <linux/sched/task.h>
 #include <linux/sb_config.h>
+#include <linux/container.h>
 
 #include "pnode.h"
 #include "internal.h"
@@ -3510,6 +3511,10 @@ static void __init init_mount_tree(void)
 
 	set_fs_pwd(current->fs, &root);
 	set_fs_root(current->fs, &root);
+#ifdef CONFIG_CONTAINERS
+	path_get(&root);
+	init_container.root = root;
+#endif
 }
 
 void __init mnt_init(void)
diff --git a/include/linux/container.h b/include/linux/container.h
new file mode 100644
index 000000000000..084ea9982fe6
--- /dev/null
+++ b/include/linux/container.h
@@ -0,0 +1,85 @@
+/* Container objects
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#ifndef _LINUX_CONTAINER_H
+#define _LINUX_CONTAINER_H
+
+#include <uapi/linux/container.h>
+#include <linux/refcount.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/wait.h>
+#include <linux/path.h>
+#include <linux/seqlock.h>
+
+struct fs_struct;
+struct nsproxy;
+struct task_struct;
+
+/*
+ * The container object.
+ */
+struct container {
+	char			name[24];
+	refcount_t		usage;
+	int			exit_code;	/* The exit code of 'init' */
+	const struct cred	*cred;		/* Creds for this container, including userns */
+	struct nsproxy		*ns;		/* This container's namespaces */
+	struct path		root;		/* The root of the container's fs namespace */
+	struct task_struct	*init;		/* The 'init' task for this container */
+	struct container	*parent;	/* Parent of this container. */
+	void			*security;	/* LSM data */
+	struct list_head	members;	/* Member processes, guarded with ->lock */
+	struct list_head	child_link;	/* Link in parent->children */
+	struct list_head	children;	/* Child containers */
+	wait_queue_head_t	waitq;		/* Someone waiting for init to exit waits here */
+	unsigned long		flags;
+#define CONTAINER_FLAG_INIT_STARTED	0	/* Init is started - certain ops now prohibited */
+#define CONTAINER_FLAG_DEAD		1	/* Init has died */
+#define CONTAINER_FLAG_KILL_ON_CLOSE	2	/* Kill init if container handle closed */
+	spinlock_t		lock;
+	seqcount_t		seq;		/* Track changes in ->root */
+};
+
+extern struct container init_container;
+
+#ifdef CONFIG_CONTAINERS
+extern const struct file_operations containerfs_fops;
+
+extern int copy_container(unsigned long flags, struct task_struct *tsk,
+			  struct container *container);
+extern void exit_container(struct task_struct *tsk);
+extern void put_container(struct container *c);
+
+static inline struct container *get_container(struct container *c)
+{
+	refcount_inc(&c->usage);
+	return c;
+}
+
+static inline bool is_container_file(struct file *file)
+{
+	return file->f_op == &containerfs_fops;
+}
+
+#else
+
+static inline int copy_container(unsigned long flags, struct task_struct *tsk,
+				 struct container *container)
+{ return 0; }
+static inline void exit_container(struct task_struct *tsk) { }
+static inline void put_container(struct container *c) {}
+static inline struct container *get_container(struct container *c) { return NULL; }
+static inline bool is_container_file(struct file *file) { return false; }
+
+#endif /* CONFIG_CONTAINERS */
+
+#endif /* _LINUX_CONTAINER_H */
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index e049526bc188..488385ad79db 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -9,6 +9,7 @@
 #include <linux/ipc.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/container.h>
 #include <linux/securebits.h>
 #include <linux/seqlock.h>
 #include <linux/rbtree.h>
@@ -273,6 +274,9 @@ extern struct cred init_cred;
 	.signal		= &init_signals,				\
 	.sighand	= &init_sighand,				\
 	.nsproxy	= &init_nsproxy,				\
+	.container	= &init_container,				\
+	.container_link.next = &init_container.members,			\
+	.container_link.prev = &init_container.members,			\
 	.pending	= {						\
 		.list = LIST_HEAD_INIT(tsk.pending.list),		\
 		.signal = {{0}}},					\
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 7064c0c15386..7b0d484a6a25 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1368,6 +1368,17 @@
  *	@inode we wish to get the security context of.
  *	@ctx is a pointer in which to place the allocated security context.
  *	@ctxlen points to the place to put the length of @ctx.
+ *
+ * Security hooks for containers:
+ *
+ * @container_alloc:
+ *	Permit creation of a new container and assign security data.
+ *	@container: The new container.
+ *
+ * @container_free:
+ *	Free security data attached to a container.
+ *	@container: The container.
+ *
  * This is the main security structure.
  */
 
@@ -1699,6 +1710,12 @@ union security_list_options {
 				struct audit_context *actx);
 	void (*audit_rule_free)(void *lsmrule);
 #endif /* CONFIG_AUDIT */
+
+	/* Container management security hooks */
+#ifdef CONFIG_CONTAINERS
+	int (*container_alloc)(struct container *container, unsigned int flags);
+	void (*container_free)(struct container *container);
+#endif
 };
 
 struct security_hook_heads {
@@ -1919,6 +1936,10 @@ struct security_hook_heads {
 	struct list_head audit_rule_match;
 	struct list_head audit_rule_free;
 #endif /* CONFIG_AUDIT */
+#ifdef CONFIG_CONTAINERS
+	struct list_head container_alloc;
+	struct list_head container_free;
+#endif /* CONFIG_CONTAINERS */
 };
 
 /*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index eba196521562..d9b92a98f99f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -33,6 +33,7 @@ struct backing_dev_info;
 struct bio_list;
 struct blk_plug;
 struct cfs_rq;
+struct container;
 struct fs_struct;
 struct futex_pi_state;
 struct io_context;
@@ -741,6 +742,8 @@ struct task_struct {
 
 	/* Namespaces: */
 	struct nsproxy			*nsproxy;
+	struct container		*container;
+	struct list_head		container_link;
 
 	/* Signal handlers: */
 	struct signal_struct		*signal;
diff --git a/include/linux/security.h b/include/linux/security.h
index 8c06e158c195..01bdf7637ec6 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -68,6 +68,7 @@ struct ctl_table;
 struct audit_krule;
 struct user_namespace;
 struct timezone;
+struct container;
 
 /* These functions are in security/commoncap.c */
 extern int cap_capable(const struct cred *cred, struct user_namespace *ns,
@@ -1672,6 +1673,20 @@ static inline void security_audit_rule_free(void *lsmrule)
 #endif /* CONFIG_SECURITY */
 #endif /* CONFIG_AUDIT */
 
+#ifdef CONFIG_CONTAINERS
+#ifdef CONFIG_SECURITY
+int security_container_alloc(struct container *container, unsigned int flags);
+void security_container_free(struct container *container);
+#else
+static inline int security_container_alloc(struct container *container,
+					   unsigned int flags)
+{
+	return 0;
+}
+static inline void security_container_free(struct container *container) {}
+#endif
+#endif /* CONFIG_CONTAINERS */
+
 #ifdef CONFIG_SECURITYFS
 
 extern struct dentry *securityfs_create_file(const char *name, umode_t mode,
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 07e4f775f24d..5a0324dd024c 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -908,5 +908,8 @@ asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
 asmlinkage long sys_fsopen(const char *fs_name, int containerfd, unsigned int flags);
 asmlinkage long sys_fsmount(int fsfd, int dfd, const char *path, unsigned int at_flags,
 			    unsigned int flags);
+asmlinkage long sys_container_create(const char __user *name, unsigned int flags,
+				     unsigned long spare3, unsigned long spare4,
+				     unsigned long spare5);
 
 #endif
diff --git a/include/uapi/linux/container.h b/include/uapi/linux/container.h
new file mode 100644
index 000000000000..43748099b28d
--- /dev/null
+++ b/include/uapi/linux/container.h
@@ -0,0 +1,28 @@
+/* Container UAPI
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_CONTAINER_H
+#define _UAPI_LINUX_CONTAINER_H
+
+
+#define CONTAINER_NEW_FS_NS		0x00000001 /* Dup current fs namespace */
+#define CONTAINER_NEW_EMPTY_FS_NS	0x00000002 /* Provide new empty fs namespace */
+#define CONTAINER_NEW_CGROUP_NS		0x00000004 /* Dup current cgroup namespace */
+#define CONTAINER_NEW_UTS_NS		0x00000008 /* Dup current uts namespace */
+#define CONTAINER_NEW_IPC_NS		0x00000010 /* Dup current ipc namespace */
+#define CONTAINER_NEW_USER_NS		0x00000020 /* Dup current user namespace */
+#define CONTAINER_NEW_PID_NS		0x00000040 /* Dup current pid namespace */
+#define CONTAINER_NEW_NET_NS		0x00000080 /* Dup current net namespace */
+#define CONTAINER_KILL_ON_CLOSE		0x00000100 /* Kill all member processes when fd closed */
+#define CONTAINER_FD_CLOEXEC		0x00000200 /* Close the fd on exec */
+#define CONTAINER__FLAG_MASK		0x000003ff
+
+#endif /* _UAPI_LINUX_CONTAINER_H */
diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
index 88ae83492f7c..758705412b44 100644
--- a/include/uapi/linux/magic.h
+++ b/include/uapi/linux/magic.h
@@ -85,5 +85,6 @@
 #define BALLOON_KVM_MAGIC	0x13661366
 #define ZSMALLOC_MAGIC		0x58295829
 #define FS_FS_MAGIC		0x66736673
+#define CONTAINERFS_MAGIC	0x636f6e74
 
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/init/Kconfig b/init/Kconfig
index 1d3475fc9496..3a0ee88df6c8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1288,6 +1288,13 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config CONTAINERS
+	bool "Container support"
+	default y
+	help
+	  Allow userspace to create and manipulate containers as objects that
+	  have namespaces and hold a set of processes.
+
 endif # NAMESPACES
 
 config SCHED_AUTOGROUP
diff --git a/kernel/Makefile b/kernel/Makefile
index 72aa080f91f0..117479b05fb1 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -7,7 +7,7 @@ obj-y     = fork.o exec_domain.o panic.o \
 	    sysctl.o sysctl_binary.o capability.o ptrace.o user.o \
 	    signal.o sys.o kmod.o workqueue.o pid.o task_work.o \
 	    extable.o params.o \
-	    kthread.o sys_ni.o nsproxy.o \
+	    kthread.o sys_ni.o nsproxy.o container.o \
 	    notifier.o ksysfs.o cred.o reboot.o \
 	    async.o range.o smpboot.o ucount.o
 
diff --git a/kernel/container.c b/kernel/container.c
new file mode 100644
index 000000000000..eef1566835eb
--- /dev/null
+++ b/kernel/container.c
@@ -0,0 +1,462 @@
+/* Implement container objects.
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/poll.h>
+#include <linux/wait.h>
+#include <linux/init_task.h>
+#include <linux/fs.h>
+#include <linux/fs_struct.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+#include <linux/container.h>
+#include <linux/magic.h>
+#include <linux/syscalls.h>
+#include <linux/printk.h>
+#include <linux/security.h>
+#include "namespaces.h"
+
+struct container init_container = {
+	.name		= ".init",
+	.usage		= REFCOUNT_INIT(2),
+	.cred		= &init_cred,
+	.ns		= &init_nsproxy,
+	.init		= &init_task,
+	.members.next	= &init_task.container_link,
+	.members.prev	= &init_task.container_link,
+	.children	= LIST_HEAD_INIT(init_container.children),
+	.flags		= (1 << CONTAINER_FLAG_INIT_STARTED),
+	.lock		= __SPIN_LOCK_UNLOCKED(init_container.lock),
+	.seq		= SEQCNT_ZERO(init_fs.seq),
+};
+
+#ifdef CONFIG_CONTAINERS
+
+static struct vfsmount *containerfs_mnt __read_mostly;
+
+/*
+ * Drop a ref on a container and clear it if no longer in use.
+ */
+void put_container(struct container *c)
+{
+	struct container *parent;
+
+	while (c && refcount_dec_and_test(&c->usage)) {
+		BUG_ON(!list_empty(&c->members));
+		if (c->ns)
+			put_nsproxy(c->ns);
+		path_put(&c->root);
+
+		parent = c->parent;
+		if (parent) {
+			spin_lock(&parent->lock);
+			list_del(&c->child_link);
+			spin_unlock(&parent->lock);
+		}
+
+		if (c->cred)
+			put_cred(c->cred);
+		security_container_free(c);
+		kfree(c);
+		c = parent;
+	}
+}
+
+/*
+ * Allow the user to poll for the container dying.
+ */
+static unsigned int containerfs_poll(struct file *file, poll_table *wait)
+{
+	struct container *container = file->private_data;
+	unsigned int mask = 0;
+
+	poll_wait(file, &container->waitq, wait);
+
+	if (test_bit(CONTAINER_FLAG_DEAD, &container->flags))
+		mask |= POLLHUP;
+
+	return mask;
+}
+
+static int containerfs_release(struct inode *inode, struct file *file)
+{
+	struct container *container = file->private_data;
+
+	put_container(container);
+	return 0;
+}
+
+const struct file_operations containerfs_fops = {
+	.poll		= containerfs_poll,
+	.release	= containerfs_release,
+};
+
+/*
+ * Indicate the name we want to display the container file as.
+ */
+static char *containerfs_dname(struct dentry *dentry, char *buffer, int buflen)
+{
+	return dynamic_dname(dentry, buffer, buflen, "container:[%lu]",
+			     d_inode(dentry)->i_ino);
+}
+
+static const struct dentry_operations containerfs_dentry_operations = {
+	.d_dname	= containerfs_dname,
+};
+
+/*
+ * Allocate a container.
+ */
+static struct container *alloc_container(const char __user *name)
+{
+	struct container *c;
+	long len;
+	int ret;
+
+	c = kzalloc(sizeof(struct container), GFP_KERNEL);
+	if (!c)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&c->members);
+	INIT_LIST_HEAD(&c->children);
+	init_waitqueue_head(&c->waitq);
+	spin_lock_init(&c->lock);
+	refcount_set(&c->usage, 1);
+
+	ret = -EFAULT;
+	len = strncpy_from_user(c->name, name, sizeof(c->name));
+	if (len < 0)
+		goto err;
+	ret = -ENAMETOOLONG;
+	if (len >= sizeof(c->name))
+		goto err;
+	ret = -EINVAL;
+	if (strchr(c->name, '/'))
+		goto err;
+
+	c->name[len] = 0;
+	return c;
+
+err:
+	kfree(c);
+	return ERR_PTR(ret);
+}
+
+/*
+ * Create a supervisory file for a new container
+ */
+static struct file *create_container_file(struct container *c)
+{
+	struct inode *inode;
+	struct file *f;
+	struct path path;
+	int ret;
+
+	inode = alloc_anon_inode(containerfs_mnt->mnt_sb);
+	if (!inode)
+		return ERR_PTR(-ENFILE);
+	inode->i_fop = &containerfs_fops;
+
+	ret = -ENOMEM;
+	path.dentry = d_alloc_pseudo(containerfs_mnt->mnt_sb, &empty_name);
+	if (!path.dentry)
+		goto err_inode;
+	path.mnt = mntget(containerfs_mnt);
+
+	d_instantiate(path.dentry, inode);
+
+	f = alloc_file(&path, 0, &containerfs_fops);
+	if (IS_ERR(f)) {
+		ret = PTR_ERR(f);
+		goto err_file;
+	}
+
+	f->private_data = c;
+	return f;
+
+err_file:
+	path_put(&path);
+	return ERR_PTR(ret);
+
+err_inode:
+	iput(inode);
+	return ERR_PTR(ret);
+}
+
+static const struct super_operations containerfs_ops = {
+	.drop_inode	= generic_delete_inode,
+	.destroy_inode	= free_inode_nonrcu,
+	.statfs		= simple_statfs,
+};
+
+/*
+ * containerfs should _never_ be mounted by userland - too much of security
+ * hassle, no real gain from having the whole whorehouse mounted.  So we don't
+ * need any operations on the root directory.  However, we need a non-trivial
+ * d_name - container: will go nicely and kill the special-casing in procfs.
+ */
+static struct dentry *containerfs_mount(struct file_system_type *fs_type,
+					int flags, const char *dev_name,
+					void *data)
+{
+	return mount_pseudo(fs_type, "container:", &containerfs_ops,
+			    &containerfs_dentry_operations, CONTAINERFS_MAGIC);
+}
+
+static struct file_system_type container_fs_type = {
+	.name		= "containerfs",
+	.mount		= containerfs_mount,
+	.kill_sb	= kill_anon_super,
+};
+
+static int __init init_container_fs(void)
+{
+	int ret;
+
+	ret = register_filesystem(&container_fs_type);
+	if (ret < 0)
+		panic("Cannot register containerfs\n");
+
+	containerfs_mnt = kern_mount(&container_fs_type);
+	if (IS_ERR(containerfs_mnt))
+		panic("Cannot mount containerfs: %ld\n",
+		      PTR_ERR(containerfs_mnt));
+
+	return 0;
+}
+
+fs_initcall(init_container_fs);
+
+/*
+ * Handle fork/clone.
+ *
+ * A process inherits its parent's container.  The first process into the
+ * container is its 'init' process and the life of everything else in there is
+ * dependent upon that.
+ */
+int copy_container(unsigned long flags, struct task_struct *tsk,
+		   struct container *container)
+{
+	struct container *c = container ?: tsk->container;
+	int ret = -ECANCELED;
+
+	spin_lock(&c->lock);
+
+	if (!test_bit(CONTAINER_FLAG_DEAD, &c->flags)) {
+		list_add_tail(&tsk->container_link, &c->members);
+		get_container(c);
+		tsk->container = c;
+		if (!c->init) {
+			set_bit(CONTAINER_FLAG_INIT_STARTED, &c->flags);
+			c->init = tsk;
+		}
+		ret = 0;
+	}
+
+	spin_unlock(&c->lock);
+	return ret;
+}
+
+/*
+ * Remove a dead process from a container.
+ *
+ * If the 'init' process in a container dies, we kill off all the other
+ * processes in the container.
+ */
+void exit_container(struct task_struct *tsk)
+{
+	struct task_struct *p;
+	struct container *c = tsk->container;
+	struct siginfo si = {
+		.si_signo = SIGKILL,
+		.si_code  = SI_KERNEL,
+	};
+
+	spin_lock(&c->lock);
+
+	list_del(&tsk->container_link);
+
+	if (c->init == tsk) {
+		c->init = NULL;
+		c->exit_code = tsk->exit_code;
+		smp_wmb(); /* Order exit_code vs CONTAINER_DEAD. */
+		set_bit(CONTAINER_FLAG_DEAD, &c->flags);
+		wake_up_bit(&c->flags, CONTAINER_FLAG_DEAD);
+
+		list_for_each_entry(p, &c->members, container_link) {
+			si.si_pid = task_tgid_vnr(p);
+			send_sig_info(SIGKILL, &si, p);
+		}
+	}
+
+	spin_unlock(&c->lock);
+	put_container(c);
+}
+
+/*
+ * Create some creds for the container.  We don't want to pin things we don't
+ * have to, so drop all keyrings from the new cred.  The LSM gets to audit the
+ * cred struct when security_container_alloc() is invoked.
+ */
+static const struct cred *create_container_creds(unsigned int flags)
+{
+	struct cred *new;
+	int ret;
+
+	new = prepare_creds();
+	if (!new)
+		return ERR_PTR(-ENOMEM);
+
+#ifdef CONFIG_KEYS
+	key_put(new->thread_keyring);
+	new->thread_keyring = NULL;
+	key_put(new->process_keyring);
+	new->process_keyring = NULL;
+	key_put(new->session_keyring);
+	new->session_keyring = NULL;
+	key_put(new->request_key_auth);
+	new->request_key_auth = NULL;
+#endif
+
+	if (flags & CONTAINER_NEW_USER_NS) {
+		ret = create_user_ns(new);
+		if (ret < 0)
+			goto err;
+		new->euid = new->user_ns->owner;
+		new->egid = new->user_ns->group;
+	}
+
+	new->fsuid = new->suid = new->uid = new->euid;
+	new->fsgid = new->sgid = new->gid = new->egid;
+	return new;
+
+err:
+	abort_creds(new);
+	return ERR_PTR(ret);
+}
+
+/*
+ * Create a new container.
+ */
+static struct container *create_container(const char *name, unsigned int flags)
+{
+	struct container *parent, *c;
+	struct fs_struct *fs;
+	struct nsproxy *ns;
+	const struct cred *cred;
+	int ret;
+
+	c = alloc_container(name);
+	if (IS_ERR(c))
+		return c;
+
+	if (flags & CONTAINER_KILL_ON_CLOSE)
+		__set_bit(CONTAINER_FLAG_KILL_ON_CLOSE, &c->flags);
+
+	cred = create_container_creds(flags);
+	if (IS_ERR(cred)) {
+		ret = PTR_ERR(cred);
+		goto err_cont;
+	}
+	c->cred = cred;
+
+	ret = -ENOMEM;
+	fs = copy_fs_struct(current->fs);
+	if (!fs)
+		goto err_cont;
+
+	ns = create_new_namespaces(
+		(flags & CONTAINER_NEW_FS_NS	 ? CLONE_NEWNS : 0) |
+		(flags & CONTAINER_NEW_CGROUP_NS ? CLONE_NEWCGROUP : 0) |
+		(flags & CONTAINER_NEW_UTS_NS	 ? CLONE_NEWUTS : 0) |
+		(flags & CONTAINER_NEW_IPC_NS	 ? CLONE_NEWIPC : 0) |
+		(flags & CONTAINER_NEW_PID_NS	 ? CLONE_NEWPID : 0) |
+		(flags & CONTAINER_NEW_NET_NS	 ? CLONE_NEWNET : 0),
+		current->nsproxy, cred->user_ns, fs);
+	if (IS_ERR(ns)) {
+		ret = PTR_ERR(ns);
+		goto err_fs;
+	}
+
+	c->ns = ns;
+	c->root = fs->root;
+	c->seq = fs->seq;
+	fs->root.mnt = NULL;
+	fs->root.dentry = NULL;
+
+	ret = security_container_alloc(c, flags);
+	if (ret < 0)
+		goto err_fs;
+
+	parent = current->container;
+	get_container(parent);
+	c->parent = parent;
+	spin_lock(&parent->lock);
+	list_add_tail(&c->child_link, &parent->children);
+	spin_unlock(&parent->lock);
+	return c;
+
+err_fs:
+	free_fs_struct(fs);
+err_cont:
+	put_container(c);
+	return ERR_PTR(ret);
+}
+
+/*
+ * Create a new container object.
+ */
+SYSCALL_DEFINE5(container_create,
+		const char __user *, name,
+		unsigned int, flags,
+		unsigned long, spare3,
+		unsigned long, spare4,
+		unsigned long, spare5)
+{
+	struct container *c;
+	struct file *f;
+	int ret, fd;
+
+	if (!name ||
+	    flags & ~CONTAINER__FLAG_MASK ||
+	    spare3 != 0 || spare4 != 0 || spare5 != 0)
+		return -EINVAL;
+	if ((flags & (CONTAINER_NEW_FS_NS | CONTAINER_NEW_EMPTY_FS_NS)) ==
+	    (CONTAINER_NEW_FS_NS | CONTAINER_NEW_EMPTY_FS_NS))
+		return -EINVAL;
+
+	c = create_container(name, flags);
+	if (IS_ERR(c))
+		return PTR_ERR(c);
+
+	f = create_container_file(c);
+	if (IS_ERR(f)) {
+		ret = PTR_ERR(f);
+		goto err_cont;
+	}
+
+	ret = get_unused_fd_flags(flags & CONTAINER_FD_CLOEXEC ? O_CLOEXEC : 0);
+	if (ret < 0)
+		goto err_file;
+
+	fd = ret;
+	fd_install(fd, f);
+	return fd;
+
+err_file:
+	fput(f);
+	return ret;
+err_cont:
+	put_container(c);
+	return ret;
+}
+
+#endif /* CONFIG_CONTAINERS */
diff --git a/kernel/exit.c b/kernel/exit.c
index 31b8617aee04..1ff87f7e40a2 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -875,6 +875,7 @@ void __noreturn do_exit(long code)
 	if (group_dead)
 		disassociate_ctty(1);
 	exit_task_namespaces(tsk);
+	exit_container(tsk);
 	exit_task_work(tsk);
 	exit_thread(tsk);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index aec6672d3f0e..ff2779426fe9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1728,9 +1728,12 @@ static __latent_entropy struct task_struct *copy_process(
 	retval = copy_namespaces(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_mm;
-	retval = copy_io(clone_flags, p);
+	retval = copy_container(clone_flags, p, NULL);
 	if (retval)
 		goto bad_fork_cleanup_namespaces;
+	retval = copy_io(clone_flags, p);
+	if (retval)
+		goto bad_fork_cleanup_container;
 	retval = copy_thread_tls(clone_flags, stack_start, stack_size, p, tls);
 	if (retval)
 		goto bad_fork_cleanup_io;
@@ -1918,6 +1921,8 @@ static __latent_entropy struct task_struct *copy_process(
 bad_fork_cleanup_io:
 	if (p->io_context)
 		exit_io_context(p);
+bad_fork_cleanup_container:
+	exit_container(p);
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
diff --git a/kernel/namespaces.h b/kernel/namespaces.h
new file mode 100644
index 000000000000..c44e3cf0e254
--- /dev/null
+++ b/kernel/namespaces.h
@@ -0,0 +1,15 @@
+/* Local namespaces defs
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+extern struct nsproxy *create_new_namespaces(unsigned long flags,
+					     struct nsproxy *nsproxy,
+					     struct user_namespace *user_ns,
+					     struct fs_struct *new_fs);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f6c5d330059a..4bb5184b3a80 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -27,6 +27,7 @@
 #include <linux/syscalls.h>
 #include <linux/cgroup.h>
 #include <linux/perf_event.h>
+#include "namespaces.h"
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -61,8 +62,8 @@ static inline struct nsproxy *create_nsproxy(void)
  * Return the newly created nsproxy.  Do not attach this to the task,
  * leave it to the caller to do proper locking and attach it to task.
  */
-static struct nsproxy *create_new_namespaces(unsigned long flags,
-	struct task_struct *tsk, struct user_namespace *user_ns,
+struct nsproxy *create_new_namespaces(unsigned long flags,
+	struct nsproxy *nsproxy, struct user_namespace *user_ns,
 	struct fs_struct *new_fs)
 {
 	struct nsproxy *new_nsp;
@@ -72,39 +73,39 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	if (!new_nsp)
 		return ERR_PTR(-ENOMEM);
 
-	new_nsp->mnt_ns = copy_mnt_ns(flags, tsk->nsproxy->mnt_ns, user_ns, new_fs);
+	new_nsp->mnt_ns = copy_mnt_ns(flags, nsproxy->mnt_ns, user_ns, new_fs);
 	if (IS_ERR(new_nsp->mnt_ns)) {
 		err = PTR_ERR(new_nsp->mnt_ns);
 		goto out_ns;
 	}
 
-	new_nsp->uts_ns = copy_utsname(flags, user_ns, tsk->nsproxy->uts_ns);
+	new_nsp->uts_ns = copy_utsname(flags, user_ns, nsproxy->uts_ns);
 	if (IS_ERR(new_nsp->uts_ns)) {
 		err = PTR_ERR(new_nsp->uts_ns);
 		goto out_uts;
 	}
 
-	new_nsp->ipc_ns = copy_ipcs(flags, user_ns, tsk->nsproxy->ipc_ns);
+	new_nsp->ipc_ns = copy_ipcs(flags, user_ns, nsproxy->ipc_ns);
 	if (IS_ERR(new_nsp->ipc_ns)) {
 		err = PTR_ERR(new_nsp->ipc_ns);
 		goto out_ipc;
 	}
 
 	new_nsp->pid_ns_for_children =
-		copy_pid_ns(flags, user_ns, tsk->nsproxy->pid_ns_for_children);
+		copy_pid_ns(flags, user_ns, nsproxy->pid_ns_for_children);
 	if (IS_ERR(new_nsp->pid_ns_for_children)) {
 		err = PTR_ERR(new_nsp->pid_ns_for_children);
 		goto out_pid;
 	}
 
 	new_nsp->cgroup_ns = copy_cgroup_ns(flags, user_ns,
-					    tsk->nsproxy->cgroup_ns);
+					    nsproxy->cgroup_ns);
 	if (IS_ERR(new_nsp->cgroup_ns)) {
 		err = PTR_ERR(new_nsp->cgroup_ns);
 		goto out_cgroup;
 	}
 
-	new_nsp->net_ns = copy_net_ns(flags, user_ns, tsk->nsproxy->net_ns);
+	new_nsp->net_ns = copy_net_ns(flags, user_ns, nsproxy->net_ns);
 	if (IS_ERR(new_nsp->net_ns)) {
 		err = PTR_ERR(new_nsp->net_ns);
 		goto out_net;
@@ -162,7 +163,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 		(CLONE_NEWIPC | CLONE_SYSVSEM)) 
 		return -EINVAL;
 
-	new_ns = create_new_namespaces(flags, tsk, user_ns, tsk->fs);
+	new_ns = create_new_namespaces(flags, tsk->nsproxy, user_ns, tsk->fs);
 	if (IS_ERR(new_ns))
 		return  PTR_ERR(new_ns);
 
@@ -203,7 +204,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
 		return -EPERM;
 
-	*new_nsp = create_new_namespaces(unshare_flags, current, user_ns,
+	*new_nsp = create_new_namespaces(unshare_flags, current->nsproxy, user_ns,
 					 new_fs ? new_fs : current->fs);
 	if (IS_ERR(*new_nsp)) {
 		err = PTR_ERR(*new_nsp);
@@ -251,7 +252,7 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	if (nstype && (ns->ops->type != nstype))
 		goto out;
 
-	new_nsproxy = create_new_namespaces(0, tsk, current_user_ns(), tsk->fs);
+	new_nsproxy = create_new_namespaces(0, tsk->nsproxy, current_user_ns(), tsk->fs);
 	if (IS_ERR(new_nsproxy)) {
 		err = PTR_ERR(new_nsproxy);
 		goto out;
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index a0fe764bd5dd..99b1e1f58d05 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -262,3 +262,7 @@ cond_syscall(sys_pkey_free);
 /* fd-based mount */
 cond_syscall(sys_fsopen);
 cond_syscall(sys_fsmount);
+
+/* Containers */
+cond_syscall(sys_container_create);
+
diff --git a/security/security.c b/security/security.c
index f4136ca5cb1b..b5c5b5ae1266 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1668,3 +1668,16 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 				actx);
 }
 #endif /* CONFIG_AUDIT */
+
+#ifdef CONFIG_CONTAINERS
+
+int security_container_alloc(struct container *container, unsigned int flags)
+{
+	return call_int_hook(container_alloc, 0, container, flags);
+}
+
+void security_container_free(struct container *container)
+{
+	call_void_hook(container_free, container);
+}
+#endif /* CONFIG_CONTAINERS */

