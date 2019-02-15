Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75E1FC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:07:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3089D21927
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:07:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391475AbfBOQHi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:07:38 -0500
Received: from mx1.redhat.com ([209.132.183.28]:65487 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388763AbfBOQHh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:07:37 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8595C1301AC;
        Fri, 15 Feb 2019 16:07:36 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0A1145D6A9;
        Fri, 15 Feb 2019 16:07:33 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 02/27] containers: Implement containers as kernel objects
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:07:33 +0000
Message-ID: <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 15 Feb 2019 16:07:36 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Implement a kernel container object such that it contains the following
things:

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

It might make sense to use fsconfig() to configure the container:

	fsconfig(cfd, FSCONFIG_SET_NAMESPACE, "user", NULL, userns_fd);
	fsconfig(cfd, FSCONFIG_SET_NAMESPACE, "mnt", NULL, mntns_fd);
	fsconfig(cfd, FSCONFIG_SET_FD, "rootfs", NULL, root_fd);
	fsconfig(cfd, FSCONFIG_CMD_CREATE_CONTAINER, NULL, NULL, 0);


==================
FUTURE DEVELOPMENT
==================

 (1) Setting up the container.

     A container would be created with, say:

	int cfd = container_create("fred", CONTAINER_NEW_EMPTY_FS_NS);

     Once created, it should then be possible for the supervising process
     to modify the new container.  Mounts can be created inside of the
     container's namespaces:

	fsfd = fsopen("ext4", 0);
	fsconfig(fsfd, FSCONFIG_SET_CONTAINER, NULL, NULL, cfd);
	fsconfig(fsfd, FSCONFIG_SET_STRING, "source", "/dev/sda3", 0);
	fsconfig(fsfd, FSCONFIG_SET_FLAG, "user_xattr", NULL, 0);
	fsconfig(fsfd, FSCONFIG_CMD_CREATE, NULL, NULL, 0);
	mfd = fsmount(fsfd, 0, 0);

     and then mounted into the namespace:

	move_mount(mfd, "", cfd, "/",
		   MOVE_MOUNT_F_EMPTY_PATH | MOVE_MOUNT_T_CONTAINER_ROOT);

     Further mounts can be added by:

	move_mount(mfd, "", cfd, "proc", MOVE_MOUNT_F_EMPTY_PATH);

     Files and devices can be created by supplying the container fd as the
     dirfd argument:

	mkdirat(int cfd, const char *path, mode_t mode);
	mknodat(int cfd, const char *path, mode_t mode, dev_t dev);
	int fd = openat(int cfd, const char *path,
			unsigned int flags, mode_t mode);

     [*] Note that when using cfd as dirfd, the path must not contain a '/'
     	 at the front.

     Sockets, such as netlink, can be opened inside of the container's
     namespaces:

	int fd = container_socket(int cfd, int domain, int type,
				  int protocol);

     This should allow management of the container's network namespace from
     outside.

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

 (5) Per-container keyring.

     Each container can point to a per-container keyring for the holding of
     integrity keys and filesystem keys for use inside the container.  This
     would be attached:

	keyctl(KEYCTL_SET_CONTAINER_KEYRING, cfd, keyring)

     This keyring would be searched by request_key() after it has searched
     the thread, process and session keyrings.

 (6) Running different LSM policies by container.  This might particularly
     make sense with something like Apparmor where different path-based
     rules might be required inside a container to inside the parent.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    1 
 fs/namespace.c                         |    5 
 include/linux/container.h              |   86 ++++++++
 include/linux/init_task.h              |    1 
 include/linux/lsm_hooks.h              |   20 ++
 include/linux/sched.h                  |    3 
 include/linux/security.h               |   15 +
 include/linux/syscalls.h               |    3 
 include/uapi/linux/container.h         |   28 +++
 init/Kconfig                           |    7 +
 init/init_task.c                       |    3 
 kernel/Makefile                        |    2 
 kernel/container.c                     |  348 ++++++++++++++++++++++++++++++++
 kernel/exit.c                          |    1 
 kernel/fork.c                          |    7 +
 kernel/namespaces.h                    |   15 +
 kernel/nsproxy.c                       |   23 +-
 kernel/sys_ni.c                        |    3 
 security/security.c                    |   12 +
 20 files changed, 571 insertions(+), 13 deletions(-)
 create mode 100644 include/linux/container.h
 create mode 100644 include/uapi/linux/container.h
 create mode 100644 kernel/container.c
 create mode 100644 kernel/namespaces.h

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index c9db9d51a7df..3564814a5d21 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -407,3 +407,4 @@
 393	i386	fsinfo			sys_fsinfo			__ia32_sys_fsinfo
 394	i386	mount_notify		sys_mount_notify		__ia32_sys_mount_notify
 395	i386	sb_notify		sys_sb_notify			__ia32_sys_sb_notify
+396	i386	container_create	sys_container_create		__ia32_sys_container_create
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 17869bf7788a..aa6cccbe5271 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -352,6 +352,7 @@
 341	common	fsinfo			__x64_sys_fsinfo
 342	common	mount_notify		__x64_sys_mount_notify
 343	common	sb_notify		__x64_sys_sb_notify
+344	common	container_create	__x64_sys_container_create
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/namespace.c b/fs/namespace.c
index f378cfc63043..ea005f55ec4c 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -30,6 +30,7 @@
 #include <uapi/linux/mount.h>
 #include <linux/fs_context.h>
 #include <linux/fsinfo.h>
+#include <linux/container.h>
 
 #include "pnode.h"
 #include "internal.h"
@@ -3742,6 +3743,10 @@ static void __init init_mount_tree(void)
 
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
index 000000000000..0a8918435097
--- /dev/null
+++ b/include/linux/container.h
@@ -0,0 +1,86 @@
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
+	u64			id;		/* Container ID */
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
+extern const struct file_operations container_fops;
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
+	return file->f_op == &container_fops;
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
index a7083a45a26c..f016cadece24 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -10,6 +10,7 @@
 #include <linux/ipc.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/container.h>
 #include <linux/securebits.h>
 #include <linux/seqlock.h>
 #include <linux/rbtree.h>
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 52d0f3f4c786..0f310d911815 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1460,6 +1460,16 @@
  * @bpf_prog_free_security:
  *	Clean up the security information stored inside bpf prog.
  *
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
  */
 union security_list_options {
 	int (*binder_set_context_mgr)(struct task_struct *mgr);
@@ -1825,6 +1835,12 @@ union security_list_options {
 	int (*bpf_prog_alloc_security)(struct bpf_prog_aux *aux);
 	void (*bpf_prog_free_security)(struct bpf_prog_aux *aux);
 #endif /* CONFIG_BPF_SYSCALL */
+
+	/* Container management security hooks */
+#ifdef CONFIG_CONTAINERS
+	int (*container_alloc)(struct container *container, unsigned int flags);
+	void (*container_free)(struct container *container);
+#endif
 };
 
 struct security_hook_heads {
@@ -2069,6 +2085,10 @@ struct security_hook_heads {
 	struct hlist_head bpf_prog_alloc_security;
 	struct hlist_head bpf_prog_free_security;
 #endif /* CONFIG_BPF_SYSCALL */
+#ifdef CONFIG_CONTAINERS
+	struct hlist_head container_alloc;
+	struct hlist_head container_free;
+#endif /* CONFIG_CONTAINERS */
 } __randomize_layout;
 
 /*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d2f90fa92468..073a3a930514 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -36,6 +36,7 @@ struct backing_dev_info;
 struct bio_list;
 struct blk_plug;
 struct cfs_rq;
+struct container;
 struct fs_struct;
 struct futex_pi_state;
 struct io_context;
@@ -870,6 +871,8 @@ struct task_struct {
 
 	/* Namespaces: */
 	struct nsproxy			*nsproxy;
+	struct container		*container;
+	struct list_head		container_link;
 
 	/* Signal handlers: */
 	struct signal_struct		*signal;
diff --git a/include/linux/security.h b/include/linux/security.h
index da538c06766f..acd0c14c6e95 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -70,6 +70,7 @@ struct ctl_table;
 struct audit_krule;
 struct user_namespace;
 struct timezone;
+struct container;
 
 enum lsm_event {
 	LSM_POLICY_CHANGE,
@@ -1751,6 +1752,20 @@ static inline void security_audit_rule_free(void *lsmrule)
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
index 10127b1d923b..dac42098c2dd 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -943,6 +943,9 @@ asmlinkage long sys_mount_notify(int dfd, const char __user *path,
 				 unsigned int at_flags, int watch_fd, int watch_id);
 asmlinkage long sys_sb_notify(int dfd, const char __user *path,
 			      unsigned int at_flags, int watch_fd, int watch_id);
+asmlinkage long sys_container_create(const char __user *name, unsigned int flags,
+				     unsigned long spare3, unsigned long spare4,
+				     unsigned long spare5);
 
 /*
  * Architecture-specific system calls
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
diff --git a/init/Kconfig b/init/Kconfig
index 5984dd7f2156..ab37c3a55aa1 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -992,6 +992,13 @@ config NET_NS
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
 
 config CHECKPOINT_RESTORE
diff --git a/init/init_task.c b/init/init_task.c
index 5aebe3be4d7c..90c7439a195b 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -108,6 +108,9 @@ struct task_struct init_task
 	.signal		= &init_signals,
 	.sighand	= &init_sighand,
 	.nsproxy	= &init_nsproxy,
+	.container	= &init_container,
+	.container_link.next = &init_container.members,
+	.container_link.prev = &init_container.members,
 	.pending	= {
 		.list = LIST_HEAD_INIT(init_task.pending.list),
 		.signal = {{0}}
diff --git a/kernel/Makefile b/kernel/Makefile
index 6aa7543bcdb2..98cdd18cecef 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -8,7 +8,7 @@ obj-y     = fork.o exec_domain.o panic.o \
 	    sysctl.o sysctl_binary.o capability.o ptrace.o user.o \
 	    signal.o sys.o umh.o workqueue.o pid.o task_work.o \
 	    extable.o params.o \
-	    kthread.o sys_ni.o nsproxy.o \
+	    kthread.o sys_ni.o nsproxy.o container.o \
 	    notifier.o ksysfs.o cred.o reboot.o \
 	    async.o range.o smpboot.o ucount.o
 
diff --git a/kernel/container.c b/kernel/container.c
new file mode 100644
index 000000000000..ca4012632cfa
--- /dev/null
+++ b/kernel/container.c
@@ -0,0 +1,348 @@
+/* Implement container objects.
+ *
+ * Copyright (C) 2018 Red Hat, Inc. All Rights Reserved.
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
+#include <linux/anon_inodes.h>
+#include <linux/container.h>
+#include <linux/syscalls.h>
+#include <linux/printk.h>
+#include <linux/security.h>
+#include "namespaces.h"
+
+struct container init_container = {
+	.name		= ".init",
+	.id		= 1,
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
+static atomic64_t container_id_counter = ATOMIC_INIT(1);
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
+static unsigned int container_poll(struct file *file, poll_table *wait)
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
+static int container_release(struct inode *inode, struct file *file)
+{
+	struct container *container = file->private_data;
+
+	put_container(container);
+	return 0;
+}
+
+const struct file_operations container_fops = {
+	.poll		= container_poll,
+	.release	= container_release,
+};
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
+	struct kernel_siginfo si = {
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
+static struct container *create_container(const char __user *name, unsigned int flags)
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
+	c->id = atomic64_inc_return(&container_id_counter);
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
+	int fd;
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
+	fd = anon_inode_getfd("container", &container_fops, c,
+			      O_RDWR | (flags & CONTAINER_FD_CLOEXEC ? O_CLOEXEC : 0));
+	if (fd < 0)
+		put_container(c);
+	return fd;
+}
+
+#endif /* CONFIG_CONTAINERS */
diff --git a/kernel/exit.c b/kernel/exit.c
index 284f2fe9a293..78f6065ad799 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -864,6 +864,7 @@ void __noreturn do_exit(long code)
 	if (group_dead)
 		disassociate_ctty(1);
 	exit_task_namespaces(tsk);
+	exit_container(tsk);
 	exit_task_work(tsk);
 	exit_thread(tsk);
 	exit_umh(tsk);
diff --git a/kernel/fork.c b/kernel/fork.c
index b69248e6f0e0..009cf7e63894 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1920,9 +1920,12 @@ static __latent_entropy struct task_struct *copy_process(
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
@@ -2121,6 +2124,8 @@ static __latent_entropy struct task_struct *copy_process(
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
index a4e7131b2509..f0455cbb91cf 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -136,6 +136,9 @@ COND_SYSCALL(acct);
 COND_SYSCALL(capget);
 COND_SYSCALL(capset);
 
+/* kernel/container.c */
+COND_SYSCALL(container_create);
+
 /* kernel/exec_domain.c */
 
 /* kernel/exit.c */
diff --git a/security/security.c b/security/security.c
index b49732c02e21..259be9a1746c 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1864,3 +1864,15 @@ void security_bpf_prog_free(struct bpf_prog_aux *aux)
 	call_void_hook(bpf_prog_free_security, aux);
 }
 #endif /* CONFIG_BPF_SYSCALL */
+
+#ifdef CONFIG_CONTAINERS
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

