Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50882 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964879AbdEVQXN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:23:13 -0400
Subject: [PATCH 5/9] Open a socket inside a container
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:23:09 +0100
Message-ID: <149547018960.10599.15111664486917892206.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a system call to open a socket inside of a container, using that
container's network namespace.  This allows netlink to be used to manage
the container.

	fd = container_socket(int container_fd,
			      int domain, int type, int protocol);

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 include/linux/syscalls.h               |    2 ++
 kernel/sys_ni.c                        |    1 +
 net/socket.c                           |   37 +++++++++++++++++++++++++++++---
 5 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 0d5a9875ead2..04a2f6b4799b 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -395,3 +395,4 @@
 386	i386	fsmount			sys_fsmount
 387	i386	container_create	sys_container_create
 388	i386	fork_into_container	sys_fork_into_container
+389	i386	container_socket	sys_container_socket
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index e4005cc579b6..825c05462245 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -343,6 +343,7 @@
 334	common	fsmount			sys_fsmount
 335	common	container_create	sys_container_create
 336	common	fork_into_container	sys_fork_into_container
+337	common	container_socket	sys_container_socket
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 7ca6c287ce84..af4c0bbd2f10 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -912,5 +912,7 @@ asmlinkage long sys_container_create(const char __user *name, unsigned int flags
 				     unsigned long spare3, unsigned long spare4,
 				     unsigned long spare5);
 asmlinkage long sys_fork_into_container(int containerfd);
+asmlinkage long sys_container_socket(int containerfd,
+				     int domain, int type, int protocol);
 
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index b685ffe3591f..1f2fe4720df5 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -266,3 +266,4 @@ cond_syscall(sys_fsmount);
 /* Containers */
 cond_syscall(sys_container_create);
 cond_syscall(sys_fork_into_container);
+cond_syscall(sys_container_socket);
diff --git a/net/socket.c b/net/socket.c
index c2564eb25c6b..69f0f72995fc 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -89,6 +89,7 @@
 #include <linux/magic.h>
 #include <linux/slab.h>
 #include <linux/xattr.h>
+#include <linux/container.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
@@ -1255,9 +1256,9 @@ int sock_create_kern(struct net *net, int family, int type, int protocol, struct
 }
 EXPORT_SYMBOL(sock_create_kern);
 
-SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
+static long __sys_socket(struct net *net, int family, int type, int protocol)
 {
-	int retval;
+	long retval;
 	struct socket *sock;
 	int flags;
 
@@ -1275,7 +1276,7 @@ SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
 		flags = (flags & ~SOCK_NONBLOCK) | O_NONBLOCK;
 
-	retval = sock_create(family, type, protocol, &sock);
+	retval = __sock_create(net, family, type, protocol, &sock, 0);
 	if (retval < 0)
 		goto out;
 
@@ -1292,6 +1293,36 @@ SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 	return retval;
 }
 
+SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
+{
+	return __sys_socket(current->nsproxy->net_ns, family, type, protocol);
+}
+
+/*
+ * Create a socket inside a container.
+ */
+SYSCALL_DEFINE4(container_socket,
+		int, containerfd, int, family, int, type, int, protocol)
+{
+#ifdef CONFIG_CONTAINERS
+	struct fd f = fdget(containerfd);
+	long ret;
+
+	if (!f.file)
+		return -EBADF;
+	ret = -EINVAL;
+	if (is_container_file(f.file)) {
+		struct container *c = f.file->private_data;
+
+		ret = __sys_socket(c->ns->net_ns, family, type, protocol);
+	}
+	fdput(f);
+	return ret;
+#else
+	return -ENOSYS;
+#endif
+}
+
 /*
  *	Create a pair of connected sockets.
  */

