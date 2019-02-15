Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26B44C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E9C2D21927
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391570AbfBOQI1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:08:27 -0500
Received: from mx1.redhat.com ([209.132.183.28]:56792 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728911AbfBOQIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:08:25 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6DA80561CC;
        Fri, 15 Feb 2019 16:08:24 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 021C95D717;
        Fri, 15 Feb 2019 16:08:17 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 07/27] containers: Make fsopen() able to create a
 superblock in a container
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:08:16 +0000
Message-ID: <155024689635.21651.15943029551519736259.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 15 Feb 2019 16:08:24 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Make it possible for fsopen() to create a superblock in a specified
container, using the namespaces associated with that container to cover UID
translation, networking and filesystem content.  This involves adding a new
fsconfig command to specify the container.

For example:

	cfd = container_create("fred", CONTAINER_NEW_FS_NS);

	fsfd = fsopen("ext4", 0);
	fsconfig(fsfd, FSCONFIG_SET_CONTAINER, NULL, NULL, cfd);
	fsconfig(fsfd, FSCONFIG_SET_STRING, "source", "/dev/sda3", 0);
	fsconfig(fsfd, FSCONFIG_SET_FLAG, "user_xattr", NULL, 0);
	fsconfig(fsfd, FSCONFIG_CMD_CREATE, NULL, NULL, 0);
	mfd = fsmount(fsfd, 0, MOUNT_ATTR_RDONLY);
	move_mount(mfd, "", cfd, "/",
		   MOVE_MOUNT_F_EMPTY_PATH | MOVE_MOUNT_T_CONTAINER_ROOT);

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fs_context.c            |   19 +++++++++++++++
 fs/fsopen.c                |   54 +++++++++++++++++++++++++++++++++++++-------
 fs/namespace.c             |   19 +++++++++++----
 fs/proc/root.c             |   11 +++++++--
 include/linux/container.h  |    1 +
 include/linux/fs_context.h |    3 ++
 include/linux/pid.h        |    5 +++-
 include/linux/proc_ns.h    |    6 +++--
 include/uapi/linux/mount.h |    1 +
 kernel/container.c         |    4 +++
 kernel/fork.c              |    2 +-
 kernel/pid.c               |    4 ++-
 12 files changed, 108 insertions(+), 21 deletions(-)

diff --git a/fs/fs_context.c b/fs/fs_context.c
index a47ccd5a4a78..fc76ac02d618 100644
--- a/fs/fs_context.c
+++ b/fs/fs_context.c
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 #include <linux/magic.h>
 #include <linux/security.h>
+#include <linux/container.h>
 #include <linux/mnt_namespace.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
@@ -169,6 +170,21 @@ int vfs_parse_fs_param(struct fs_context *fc, struct fs_parameter *param)
 }
 EXPORT_SYMBOL(vfs_parse_fs_param);
 
+/*
+ * Specify a container in which a superblock will exist.
+ */
+void vfs_set_container(struct fs_context *fc, struct container *container)
+{
+	if (container) {
+		put_user_ns(fc->user_ns);
+		put_net(fc->net_ns);
+
+		fc->container = get_container(container);
+		fc->user_ns = get_user_ns(container->cred->user_ns);
+		fc->net_ns = get_net(container->ns->net_ns);
+	}
+}
+
 /**
  * vfs_parse_fs_string - Convenience function to just parse a string.
  */
@@ -364,6 +380,8 @@ struct fs_context *vfs_dup_fs_context(struct fs_context *src_fc)
 	fc->source	= NULL;
 	fc->security	= NULL;
 	get_filesystem(fc->fs_type);
+	if (fc->container)
+		get_container(fc->container);
 	get_net(fc->net_ns);
 	get_user_ns(fc->user_ns);
 	get_cred(fc->cred);
@@ -510,6 +528,7 @@ void put_fs_context(struct fs_context *fc)
 	put_net(fc->net_ns);
 	put_user_ns(fc->user_ns);
 	put_cred(fc->cred);
+	put_container(fc->container);
 	kfree(fc->subtype);
 	put_fc_log(fc);
 	put_filesystem(fc->fs_type);
diff --git a/fs/fsopen.c b/fs/fsopen.c
index 3bb9c0c8cbcc..d0fe9e563ebb 100644
--- a/fs/fsopen.c
+++ b/fs/fsopen.c
@@ -17,11 +17,33 @@
 #include <linux/security.h>
 #include <linux/anon_inodes.h>
 #include <linux/namei.h>
+#include <linux/container.h>
 #include <linux/file.h>
 #include <uapi/linux/mount.h>
 #include "internal.h"
 #include "mount.h"
 
+/*
+ * Configure the destination container on a filesystem context.  This must be
+ * done before any other parameters are offered.  Containers are presented as
+ * fds attached to such objects given by the auxiliary parameter.
+ *
+ * For example:
+ *
+ *	fsconfig(fsfd, FSCONFIG_SET_CONTAINER, NULL, NULL, container_fd);
+ */
+static int fsconfig_set_container(struct fs_context *fc, struct fs_parameter *param)
+{
+	struct container *c;
+
+	if (!is_container_file(param->file))
+		return -EINVAL;
+
+	c = param->file->private_data;
+	vfs_set_container(fc, c);
+	return 0;
+}
+
 /*
  * Allow the user to read back any error, warning or informational messages.
  */
@@ -111,10 +133,6 @@ static int fscontext_alloc_log(struct fs_context *fc)
 
 /*
  * Open a filesystem by name so that it can be configured for mounting.
- *
- * We are allowed to specify a container in which the filesystem will be
- * opened, thereby indicating which namespaces will be used (notably, which
- * network namespace will be used for network filesystems).
  */
 SYSCALL_DEFINE2(fsopen, const char __user *, _fs_name, unsigned int, flags)
 {
@@ -143,7 +161,7 @@ SYSCALL_DEFINE2(fsopen, const char __user *, _fs_name, unsigned int, flags)
 	if (IS_ERR(fc))
 		return PTR_ERR(fc);
 
-	fc->phase = FS_CONTEXT_CREATE_PARAMS;
+	fc->phase = FS_CONTEXT_CREATE_NS;
 
 	ret = fscontext_alloc_log(fc);
 	if (ret < 0)
@@ -228,7 +246,8 @@ static int vfs_fsconfig_locked(struct fs_context *fc, int cmd,
 		return ret;
 	switch (cmd) {
 	case FSCONFIG_CMD_CREATE:
-		if (fc->phase != FS_CONTEXT_CREATE_PARAMS)
+		if (fc->phase != FS_CONTEXT_CREATE_NS &&
+		    fc->phase != FS_CONTEXT_CREATE_PARAMS)
 			return -EBUSY;
 		fc->phase = FS_CONTEXT_CREATING;
 		ret = vfs_get_tree(fc);
@@ -259,9 +278,17 @@ static int vfs_fsconfig_locked(struct fs_context *fc, int cmd,
 			break;
 		vfs_clean_context(fc);
 		return 0;
+
+	case FSCONFIG_SET_CONTAINER:
+		if (fc->phase != FS_CONTEXT_CREATE_NS)
+			return -EBUSY;
+		return fsconfig_set_container(fc, param);
+
 	default:
-		if (fc->phase != FS_CONTEXT_CREATE_PARAMS &&
-		    fc->phase != FS_CONTEXT_RECONF_PARAMS)
+		if (fc->phase == FS_CONTEXT_CREATE_NS)
+			fc->phase = FS_CONTEXT_CREATE_PARAMS;
+		else if (fc->phase != FS_CONTEXT_CREATE_PARAMS &&
+			 fc->phase != FS_CONTEXT_RECONF_PARAMS)
 			return -EBUSY;
 
 		return vfs_parse_fs_param(fc, param);
@@ -353,6 +380,10 @@ SYSCALL_DEFINE5(fsconfig,
 		if (!_key || _value || aux < 0)
 			return -EINVAL;
 		break;
+	case FSCONFIG_SET_CONTAINER:
+		if (_key || _value || aux < 0)
+			return -EINVAL;
+		break;
 	case FSCONFIG_CMD_CREATE:
 	case FSCONFIG_CMD_RECONFIGURE:
 		if (_key || _value || aux)
@@ -438,6 +469,12 @@ SYSCALL_DEFINE5(fsconfig,
 		if (!param.file)
 			goto out_key;
 		break;
+	case FSCONFIG_SET_CONTAINER:
+		ret = -EBADF;
+		param.file = fget(aux);
+		if (!param.file)
+			goto out_key;
+		break;
 	default:
 		break;
 	}
@@ -463,6 +500,7 @@ SYSCALL_DEFINE5(fsconfig,
 			putname(param.name);
 		break;
 	case FSCONFIG_SET_FD:
+	case FSCONFIG_SET_CONTAINER:
 		if (param.file)
 			fput(param.file);
 		break;
diff --git a/fs/namespace.c b/fs/namespace.c
index ea005f55ec4c..cc5d56f7ae29 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -781,9 +781,16 @@ static void put_mountpoint(struct mountpoint *mp)
 	}
 }
 
+static inline int __check_mnt(struct mount *mnt, struct mnt_namespace *mnt_ns)
+{
+	if (!mnt_ns)
+		mnt_ns = current->nsproxy->mnt_ns;
+	return mnt->mnt_ns == mnt_ns;
+}
+
 static inline int check_mnt(struct mount *mnt)
 {
-	return mnt->mnt_ns == current->nsproxy->mnt_ns;
+	return __check_mnt(mnt, NULL);
 }
 
 /*
@@ -2696,7 +2703,8 @@ static int do_move_mount_old(struct path *path, const char *old_name)
 /*
  * add a mount into a namespace's mount tree
  */
-static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
+static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags,
+			struct mnt_namespace *mnt_ns)
 {
 	struct mountpoint *mp;
 	struct mount *parent;
@@ -2710,7 +2718,7 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 
 	parent = real_mount(path->mnt);
 	err = -EINVAL;
-	if (unlikely(!check_mnt(parent))) {
+	if (unlikely(!__check_mnt(parent, mnt_ns))) {
 		/* that's acceptable only for automounts done in private ns */
 		if (!(mnt_flags & MNT_SHRINKABLE))
 			goto unlock;
@@ -2765,7 +2773,8 @@ static int do_new_mount_fc(struct fs_context *fc, struct path *mountpoint,
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 
-	error = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
+	error = do_add_mount(real_mount(mnt), mountpoint, mnt_flags,
+			     fc->container ? fc->container->ns->mnt_ns : NULL);
 	if (error < 0)
 		mntput(mnt);
 	return error;
@@ -2839,7 +2848,7 @@ int finish_automount(struct vfsmount *m, struct path *path)
 		goto fail;
 	}
 
-	err = do_add_mount(mnt, path, path->mnt->mnt_flags | MNT_SHRINKABLE);
+	err = do_add_mount(mnt, path, path->mnt->mnt_flags | MNT_SHRINKABLE, NULL);
 	if (!err)
 		return 0;
 fail:
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 6927b29ece76..aa802006d855 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -18,6 +18,7 @@
 #include <linux/sched/stat.h>
 #include <linux/module.h>
 #include <linux/bitops.h>
+#include <linux/container.h>
 #include <linux/user_namespace.h>
 #include <linux/fs_context.h>
 #include <linux/mount.h>
@@ -186,8 +187,12 @@ static int proc_init_fs_context(struct fs_context *fc)
 	ctx = kzalloc(sizeof(struct proc_fs_context), GFP_KERNEL);
 	if (!ctx)
 		return -ENOMEM;
+	
+	if (fc->container)
+		ctx->pid_ns = get_pid_ns(fc->container->pid_ns);
+	else
+		ctx->pid_ns = get_pid_ns(task_active_pid_ns(current));
 
-	ctx->pid_ns = get_pid_ns(task_active_pid_ns(current));
 	fc->fs_private = ctx;
 	fc->ops = &proc_fs_context_ops;
 	return 0;
@@ -300,7 +305,7 @@ struct proc_dir_entry proc_root = {
 	.name		= "/proc",
 };
 
-int pid_ns_prepare_proc(struct pid_namespace *ns)
+int pid_ns_prepare_proc(struct pid_namespace *ns, struct container *container)
 {
 	struct proc_fs_context *ctx;
 	struct fs_context *fc;
@@ -315,6 +320,8 @@ int pid_ns_prepare_proc(struct pid_namespace *ns)
 		fc->user_ns = get_user_ns(ns->user_ns);
 	}
 
+	vfs_set_container(fc, container);
+	
 	ctx = fc->fs_private;
 	if (ctx->pid_ns != ns) {
 		put_pid_ns(ctx->pid_ns);
diff --git a/include/linux/container.h b/include/linux/container.h
index 0a8918435097..087aa1885ef7 100644
--- a/include/linux/container.h
+++ b/include/linux/container.h
@@ -37,6 +37,7 @@ struct container {
 	struct path		root;		/* The root of the container's fs namespace */
 	struct task_struct	*init;		/* The 'init' task for this container */
 	struct container	*parent;	/* Parent of this container. */
+	struct pid_namespace	*pid_ns;	/* The process ID namespace for this container */
 	void			*security;	/* LSM data */
 	struct list_head	members;	/* Member processes, guarded with ->lock */
 	struct list_head	child_link;	/* Link in parent->children */
diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
index dc8c9fcba341..45486080eb84 100644
--- a/include/linux/fs_context.h
+++ b/include/linux/fs_context.h
@@ -40,6 +40,7 @@ enum fs_context_purpose {
  * Userspace usage phase for fsopen/fspick.
  */
 enum fs_context_phase {
+	FS_CONTEXT_CREATE_NS,		/* Set namespaces for sb creation */
 	FS_CONTEXT_CREATE_PARAMS,	/* Loading params for sb creation */
 	FS_CONTEXT_CREATING,		/* A superblock is being created */
 	FS_CONTEXT_AWAITING_MOUNT,	/* Superblock created, awaiting fsmount() */
@@ -93,6 +94,7 @@ struct fs_context {
 	struct file_system_type	*fs_type;
 	void			*fs_private;	/* The filesystem's context */
 	struct dentry		*root;		/* The root and superblock */
+	struct container	*container;	/* The container in which the mount will exist */
 	struct user_namespace	*user_ns;	/* The user namespace for this mount */
 	struct net		*net_ns;	/* The network namespace for this mount */
 	const struct cred	*cred;		/* The mounter's credentials */
@@ -136,6 +138,7 @@ extern int vfs_parse_fs_param(struct fs_context *fc, struct fs_parameter *param)
 extern int vfs_parse_fs_string(struct fs_context *fc, const char *key,
 			       const char *value, size_t v_size);
 extern int generic_parse_monolithic(struct fs_context *fc, void *data);
+extern void vfs_set_container(struct fs_context *fc, struct container *container);
 extern int vfs_get_tree(struct fs_context *fc);
 extern void put_fs_context(struct fs_context *fc);
 
diff --git a/include/linux/pid.h b/include/linux/pid.h
index 14a9a39da9c7..16dc152ceef1 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -73,6 +73,8 @@ static inline struct pid *get_pid(struct pid *pid)
 	return pid;
 }
 
+struct container;
+
 extern void put_pid(struct pid *pid);
 extern struct task_struct *pid_task(struct pid *pid, enum pid_type);
 extern struct task_struct *get_pid_task(struct pid *pid, enum pid_type);
@@ -111,7 +113,8 @@ extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, unsigned int last);
 
-extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid(struct pid_namespace *ns,
+			     struct container *container);
 extern void free_pid(struct pid *pid);
 extern void disable_pid_allocation(struct pid_namespace *ns);
 
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index d31cb6215905..dee0881eca5c 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -47,14 +47,16 @@ enum {
 
 #ifdef CONFIG_PROC_FS
 
-extern int pid_ns_prepare_proc(struct pid_namespace *ns);
+extern int pid_ns_prepare_proc(struct pid_namespace *ns,
+			       struct container *container);
 extern void pid_ns_release_proc(struct pid_namespace *ns);
 extern int proc_alloc_inum(unsigned int *pino);
 extern void proc_free_inum(unsigned int inum);
 
 #else /* CONFIG_PROC_FS */
 
-static inline int pid_ns_prepare_proc(struct pid_namespace *ns) { return 0; }
+static inline int pid_ns_prepare_proc(struct pid_namespace *ns, struct container *container)
+{ return 0; }
 static inline void pid_ns_release_proc(struct pid_namespace *ns) {}
 
 static inline int proc_alloc_inum(unsigned int *inum)
diff --git a/include/uapi/linux/mount.h b/include/uapi/linux/mount.h
index 96a0240f23fe..f60bbe6f4099 100644
--- a/include/uapi/linux/mount.h
+++ b/include/uapi/linux/mount.h
@@ -97,6 +97,7 @@ enum fsconfig_command {
 	FSCONFIG_SET_FD		= 5,	/* Set parameter, supplying an object by fd */
 	FSCONFIG_CMD_CREATE	= 6,	/* Invoke superblock creation */
 	FSCONFIG_CMD_RECONFIGURE = 7,	/* Invoke superblock reconfiguration */
+	FSCONFIG_SET_CONTAINER	= 8,	/* Set a container, supplied by fd */
 };
 
 /*
diff --git a/kernel/container.c b/kernel/container.c
index 1d2cb1c1e9b1..fd3b2a6849a1 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -30,6 +30,7 @@ struct container init_container = {
 	.cred		= &init_cred,
 	.ns		= &init_nsproxy,
 	.init		= &init_task,
+	.pid_ns		= &init_pid_ns,
 	.members.next	= &init_task.container_link,
 	.members.prev	= &init_task.container_link,
 	.children	= LIST_HEAD_INIT(init_container.children),
@@ -51,6 +52,8 @@ void put_container(struct container *c)
 
 	while (c && refcount_dec_and_test(&c->usage)) {
 		BUG_ON(!list_empty(&c->members));
+		if (c->pid_ns)
+			put_pid_ns(c->pid_ns);
 		if (c->ns)
 			put_nsproxy(c->ns);
 		path_put(&c->root);
@@ -391,6 +394,7 @@ static struct container *create_container(const char __user *name, unsigned int
 	}
 
 	c->ns = ns;
+	c->pid_ns = get_pid_ns(c->ns->pid_ns_for_children);
 	c->root = fs->root;
 	c->seq = fs->seq;
 	fs->root.mnt = NULL;
diff --git a/kernel/fork.c b/kernel/fork.c
index 71401deb4434..09de5f35d312 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1958,7 +1958,7 @@ static __latent_entropy struct task_struct *copy_process(
 	stackleak_task_init(p);
 
 	if (pid != &init_struct_pid) {
-		pid = alloc_pid(p->nsproxy->pid_ns_for_children);
+		pid = alloc_pid(p->nsproxy->pid_ns_for_children, dest_container);
 		if (IS_ERR(pid)) {
 			retval = PTR_ERR(pid);
 			goto bad_fork_cleanup_thread;
diff --git a/kernel/pid.c b/kernel/pid.c
index 20881598bdfa..6528a75e6c0d 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -156,7 +156,7 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
 
-struct pid *alloc_pid(struct pid_namespace *ns)
+struct pid *alloc_pid(struct pid_namespace *ns, struct container *container)
 {
 	struct pid *pid;
 	enum pid_type type;
@@ -205,7 +205,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 	}
 
 	if (unlikely(is_child_reaper(pid))) {
-		if (pid_ns_prepare_proc(ns))
+		if (pid_ns_prepare_proc(ns, container))
 			goto out_free;
 	}
 

