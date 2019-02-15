Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48D98C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 16E4C21927
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391426AbfBOQIm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:08:42 -0500
Received: from mx1.redhat.com ([209.132.183.28]:32834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727084AbfBOQIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:08:42 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 607DFC0C2349;
        Fri, 15 Feb 2019 16:08:41 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5B966608C4;
        Fri, 15 Feb 2019 16:08:30 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 08/27] containers, vfs: Honour CONTAINER_NEW_EMPTY_FS_NS
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:08:29 +0000
Message-ID: <155024690964.21651.13823458384398366556.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 15 Feb 2019 16:08:41 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Allow a container to be created with an empty mount namespace, as specified
by passing CONTAINER_NEW_EMPTY_FS_NS to container_create(), and allow a
root filesystem to be mounted into the container:

	cfd = container_create("foo", CONTAINER_NEW_EMPTY_FS_NS);

	fsfd = fsopen("ext3", 0);
	fsconfig(fsfd, FSCONFIG_SET_CONTAINER, NULL, NULL, cfd);
	fsconfig(fsfd, FSCONFIG_SET_STRING, "source", "/dev/sda3", 0);
	fsconfig(fsfd, FSCONFIG_SET_FLAG, "user_xattr", NULL, 0);
	fsconfig(fsfd, FSCONFIG_CMD_CREATE, NULL, NULL, 0);
	...
	rfd = fsmount(fsfd, 0, 0);
	move_mount(rfd, "", cfd, "/",
		   MOVE_MOUNT_F_EMPTY_PATH | MOVE_MOUNT_T_CONTAINER_ROOT);

	pfd = fsopen("proc", 0);
	write(pfd, "n c=<cfd>");
	...
	procfd = fsmount(pfd, 0, 0);
	move_mount(procfd, "", cfd, "proc", MOVE_MOUNT_F_EMPTY_PATH);

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namespace.c             |   95 +++++++++++++++++++++++++++++++++++++++-----
 include/uapi/linux/mount.h |    3 +
 kernel/container.c         |    6 +++
 kernel/fork.c              |    6 ++-
 4 files changed, 97 insertions(+), 13 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index cc5d56f7ae29..22cf4a8f8065 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3513,6 +3513,63 @@ SYSCALL_DEFINE3(fsmount, int, fs_fd, unsigned int, flags,
 	return ret;
 }
 
+/*
+ * Create a mount namespace for a container and set the root mount in it.
+ */
+static int set_container_root(struct path *path, int fd)
+{
+	struct mnt_namespace *mnt_ns;
+	struct container *container;
+	struct mount *mnt;
+	struct fd f;
+	int ret;
+
+	f = fdget(fd);
+	if (!f.file)
+		return -EBADF;
+	ret = -EINVAL;
+	if (!is_container_file(f.file))
+		goto out_fd;
+
+	ret = -EBUSY;
+	container = f.file->private_data;
+	if (container->ns->mnt_ns)
+		goto out_fd;
+
+	mnt_ns = alloc_mnt_ns(container->cred->user_ns, false);
+	if (IS_ERR(mnt_ns)) {
+		ret = PTR_ERR(mnt_ns);
+		goto out_fd;
+	}
+
+	mnt = real_mount(path->mnt);
+	mnt_add_count(mnt, 1);
+	mnt->mnt_ns = mnt_ns;
+	mnt_ns->root = mnt;
+	mnt_ns->mounts++;
+	list_add(&mnt->mnt_list, &mnt_ns->list);
+
+	ret = -EBUSY;
+	spin_lock(&container->lock);
+	if (!container->ns->mnt_ns) {
+		container->ns->mnt_ns = mnt_ns;
+		write_seqcount_begin(&container->seq);
+		container->root.mnt = path->mnt;
+		container->root.dentry = path->dentry;
+		write_seqcount_end(&container->seq);
+		path_get(&container->root);
+		mnt_ns = NULL;
+		ret = 0;
+	}
+	spin_unlock(&container->lock);
+
+	if (ret < 0)
+		put_mnt_ns(mnt_ns);
+out_fd:
+	fdput(f);
+	return ret;
+}
+
 /*
  * Move a mount from one place to another.  In combination with
  * fsopen()/fsmount() this is used to install a new mount and in combination
@@ -3528,6 +3585,7 @@ SYSCALL_DEFINE5(move_mount,
 {
 	struct path from_path, to_path;
 	unsigned int lflags;
+	char buf[2];
 	int ret = 0;
 
 	if (!may_mount())
@@ -3536,6 +3594,17 @@ SYSCALL_DEFINE5(move_mount,
 	if (flags & ~MOVE_MOUNT__MASK)
 		return -EINVAL;
 
+	if (flags & MOVE_MOUNT_T_CONTAINER_ROOT) {
+		if (flags & (MOVE_MOUNT_T_SYMLINKS |
+			     MOVE_MOUNT_T_AUTOMOUNTS |
+			     MOVE_MOUNT_T_EMPTY_PATH))
+			return -EINVAL;
+		if (strncpy_from_user(buf, to_pathname, 2) < 0)
+			return -EFAULT;
+		if (buf[0] != '/' || buf[1] != '\0')
+			return -EINVAL;
+	}
+
 	/* If someone gives a pathname, they aren't permitted to move
 	 * from an fd that requires unmount as we can't get at the flag
 	 * to clear it afterwards.
@@ -3549,20 +3618,24 @@ SYSCALL_DEFINE5(move_mount,
 	if (ret < 0)
 		return ret;
 
-	lflags = 0;
-	if (flags & MOVE_MOUNT_T_SYMLINKS)	lflags |= LOOKUP_FOLLOW;
-	if (flags & MOVE_MOUNT_T_AUTOMOUNTS)	lflags |= LOOKUP_AUTOMOUNT;
-	if (flags & MOVE_MOUNT_T_EMPTY_PATH)	lflags |= LOOKUP_EMPTY;
+	if (flags & MOVE_MOUNT_T_CONTAINER_ROOT) {
+		ret = set_container_root(&from_path, to_dfd);
+	} else {
+		lflags = 0;
+		if (flags & MOVE_MOUNT_T_SYMLINKS)	lflags |= LOOKUP_FOLLOW;
+		if (flags & MOVE_MOUNT_T_AUTOMOUNTS)	lflags |= LOOKUP_AUTOMOUNT;
+		if (flags & MOVE_MOUNT_T_EMPTY_PATH)	lflags |= LOOKUP_EMPTY;
 
-	ret = user_path_at(to_dfd, to_pathname, lflags, &to_path);
-	if (ret < 0)
-		goto out_from;
+		ret = user_path_at(to_dfd, to_pathname, lflags, &to_path);
+		if (ret < 0)
+			goto out_from;
 
-	ret = security_move_mount(&from_path, &to_path);
-	if (ret < 0)
-		goto out_to;
+		ret = security_move_mount(&from_path, &to_path);
+		if (ret < 0)
+			goto out_to;
 
-	ret = do_move_mount(&from_path, &to_path);
+		ret = do_move_mount(&from_path, &to_path);
+	}
 
 out_to:
 	path_put(&to_path);
diff --git a/include/uapi/linux/mount.h b/include/uapi/linux/mount.h
index f60bbe6f4099..cfaa75fa0594 100644
--- a/include/uapi/linux/mount.h
+++ b/include/uapi/linux/mount.h
@@ -70,7 +70,8 @@
 #define MOVE_MOUNT_T_SYMLINKS		0x00000010 /* Follow symlinks on to path */
 #define MOVE_MOUNT_T_AUTOMOUNTS		0x00000020 /* Follow automounts on to path */
 #define MOVE_MOUNT_T_EMPTY_PATH		0x00000040 /* Empty to path permitted */
-#define MOVE_MOUNT__MASK		0x00000077
+#define MOVE_MOUNT_T_CONTAINER_ROOT	0x00000080 /* Set as container root */
+#define MOVE_MOUNT__MASK		0x000000f7
 
 /*
  * fsopen() flags.
diff --git a/kernel/container.c b/kernel/container.c
index fd3b2a6849a1..360284db959b 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -21,6 +21,7 @@
 #include <linux/printk.h>
 #include <linux/security.h>
 #include <linux/proc_fs.h>
+#include <linux/mnt_namespace.h>
 #include "namespaces.h"
 
 struct container init_container = {
@@ -400,6 +401,11 @@ static struct container *create_container(const char __user *name, unsigned int
 	fs->root.mnt = NULL;
 	fs->root.dentry = NULL;
 
+	if (flags & CONTAINER_NEW_EMPTY_FS_NS) {
+		put_mnt_ns(ns->mnt_ns);
+		ns->mnt_ns = NULL;
+	}
+
 	ret = security_container_alloc(c, flags);
 	if (ret < 0)
 		goto err_fs;
diff --git a/kernel/fork.c b/kernel/fork.c
index 09de5f35d312..6ec507a5f739 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2374,7 +2374,11 @@ SYSCALL_DEFINE1(fork_into_container, int, containerfd)
 	if (is_container_file(f.file)) {
 		struct container *dest_container = f.file->private_data;
 
-		ret = _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0, dest_container);
+		if (!dest_container->ns->mnt_ns)
+			ret = -ENOENT;
+		else
+			ret = _do_fork(SIGCHLD, 0, 0, NULL, NULL, 0,
+				       dest_container);
 	}
 	fdput(f);
 	return ret;

